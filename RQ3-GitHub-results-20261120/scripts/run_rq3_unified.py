#!/usr/bin/env python3
"""Serial host coordinator, writes durable raw samples and results after each run."""
import argparse
import csv
import datetime
import json
import os
from pathlib import Path
import shlex
import shutil
import statistics
import subprocess
import tarfile
import time

BASE=Path(__file__).resolve().parent.parent
DOCKER=r'C:\Program Files\Docker\Docker\resources\bin\docker.exe'
SSH_WRAPPER='/mnt/c/Users/lenovo/Documents/Codex/2026-11-15/ban/work/baseline-guest.sh'
SUBJECTS=['doubleFree','CS_account','CS_lazy01','CS_twostage','CS_reorder_3','CS_circular_buffer','CB_stringbuffer','CS_reorder_4','CS_token_ring','CS_bluetooth_driver','CS_wronglock_3']
RUN_ID='unified20261120v2'
OUT=BASE/'outputs'/'RQ3-unified-20261120-v2'

def shell(cmd,timeout=420):
    p=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=timeout)
    if p.returncode:
        raise RuntimeError('COMMAND FAILED: '+repr(cmd)+'\n'+p.stdout.decode('utf-8','replace')+'\n'+p.stderr.decode('utf-8','replace'))
    return p.stdout.decode('utf-8','replace')

def guest(cmd,timeout=420):
    return shell(['wsl.exe','-d','Ubuntu','-u','root','--exec','/bin/bash','-c',
                  'bash '+shlex.quote(SSH_WRAPPER)+' '+shlex.quote(shlex.join(cmd))],timeout)

def root(backend):
    return ('/workdir/' if backend=='period' else '/home/sct/')+'rq3-'+RUN_ID

def deploy():
    for name in ['rq3_worker.py','rq3_timing.py']:
        shell([DOCKER,'cp',str(BASE/'work'/name),'period-env:/tmp/'+name])
    files=' '.join('/mnt/c/Users/lenovo/Documents/Codex/2026-11-15/ban/work/'+n for n in ['rq3_worker.py','rq3_timing.py'])
    shell(['wsl.exe','-d','Ubuntu','-u','root','--exec','/bin/bash','-c',
           'scp -O -q -i /opt/period-baseline-vm/id_ed25519 -o BatchMode=yes -o UserKnownHostsFile=/opt/period-baseline-vm/known_hosts -P 2226 '+files+' sct@127.0.0.1:/tmp/'])

def action(backend,what,subject='doubleFree',tool='native',repeat=0,budget=20,cap=30):
    args=['env','LC_ALL=C.UTF-8','LANG=C.UTF-8','PYTHONIOENCODING=utf-8','python3','/tmp/rq3_worker.py','--backend',backend,'--action',what,
          '--root',root(backend),'--run-id',RUN_ID,'--subject',subject,'--tool',tool,
          '--repeat',str(repeat),'--budget',str(budget),'--wall-timeout',str(cap),
          '--native-batch','20' if repeat else '5','--target-timeout','5']
    print(datetime.datetime.now().isoformat(timespec='seconds'),backend,what,subject,tool,repeat,flush=True)
    output=shell([DOCKER,'exec','period-env']+args,cap+360) if backend=='period' else guest(args,cap+360)
    lines=[s[len('RQ3_RESULT='):] for s in output.splitlines() if s.startswith('RQ3_RESULT=')]
    if not lines: raise RuntimeError('No result JSON: '+output)
    row=json.loads(lines[-1])
    if what=='run':
        dest=OUT/'raw'/backend/subject/tool/str(repeat)
        dest.mkdir(parents=True,exist_ok=True)
        archive=dest/'artifacts.tar.gz'
        if backend=='period':
            shell([DOCKER,'cp','period-env:'+row['log_dir']+'/artifacts.tar.gz',str(archive)])
        else:
            win_to_wsl='/mnt/'+str(archive)[0].lower()+str(archive)[2:].replace('\\','/')
            shell(['wsl.exe','-d','Ubuntu','-u','root','--exec','/bin/bash','-c',
                   'scp -O -q -i /opt/period-baseline-vm/id_ed25519 -o BatchMode=yes -o UserKnownHostsFile=/opt/period-baseline-vm/known_hosts -P 2226 '+shlex.quote('sct@127.0.0.1:'+row['log_dir']+'/artifacts.tar.gz')+' '+shlex.quote(win_to_wsl)])
        with tarfile.open(archive) as t: t.extractall(dest,filter='data')
        row['local_log_dir']=str(dest)
        (dest/'host_result.json').write_text(json.dumps(row,indent=2),encoding='utf-8')
        refresh()
    else:
        dest=OUT/'preparation'/backend
        dest.mkdir(parents=True,exist_ok=True)
        (dest/(subject+'-'+what+'.json')).write_text(json.dumps(row,indent=2),encoding='utf-8')
    print('RESULT',json.dumps(row,ensure_ascii=False),flush=True)
    return row

def refresh():
    rows=[]
    for p in (OUT/'raw').glob('*/*/*/*/host_result.json'):
        row=json.loads(p.read_text())
        if row['repeat']>0: rows.append(row)
    rows.sort(key=lambda r:(SUBJECTS.index(r['subject']),r['backend'],r['tool'],r['repeat']))
    natives={(r['backend'],r['subject'],r['repeat']):r for r in rows if r['tool']=='native'}
    for r in rows:
        native=natives.get((r['backend'],r['subject'],r['repeat']))
        r['native_s']=native.get('mean_execution_s') if native and native['status']=='OK' else None
        r['tool_s']=r['mean_execution_s']
        r['slowdown']=(r['tool_s']/r['native_s']) if r['native_s'] and r['tool_s'] and r['status']=='OK' else None
        r['schedules']=r['completed_executions'] if r['tool']!='native' else None
        r['errors']=r['program_error_executions']
    if rows:
        keys=['subject','tool','backend','repeat','status','native_s','tool_s','slowdown','schedules','errors']
        keys+=sorted(set().union(*(r.keys() for r in rows))-set(keys))
        # Use a unique temporary name; the progress viewer may have the prior
        # CSV open briefly while importing it on Windows.
        tmp=OUT/('rq3_overhead.tmp.{}.csv'.format(os.getpid()))
        with tmp.open('w',newline='',encoding='utf-8-sig') as f:
            w=csv.DictWriter(f,fieldnames=keys); w.writeheader(); w.writerows(rows)
        target=OUT/'rq3_overhead.csv'
        for _ in range(20):
            try:
                os.replace(tmp,target)
                break
            except PermissionError:
                time.sleep(0.25)
        else:
            # Keep the previous durable CSV and let the experiment continue;
            # the next completed slot will refresh it again.
            try: tmp.unlink()
            except OSError: pass
    summary=[]
    for subject in SUBJECTS:
        for backend,tool in [('period','native'),('baseline','native'),('period','Period'),('baseline','IPB'),('baseline','IDB')]:
            selected=[r for r in rows if (r['subject'],r['backend'],r['tool'])==(subject,backend,tool)]
            if not selected: continue
            ok=[r for r in selected if r['status']=='OK' and r['slowdown'] is not None]
            ratios=[r['slowdown'] for r in ok]
            summary.append(dict(subject=subject,tool=tool,backend=backend,planned_slots=len(selected),
                                attempts=sum(r.get('attempted',True) for r in selected),ok=len(ok),
                                blocked=sum(not r.get('attempted',True) for r in selected),
                                timeouts=sum(r['status']=='TIMEOUT' for r in selected),
                                slowdown_mean=statistics.mean(ratios) if ratios else None,
                                slowdown_stdev=statistics.stdev(ratios) if len(ratios)>1 else None))
    if summary:
        with (OUT/'rq3_summary.csv').open('w',newline='',encoding='utf-8-sig') as f:
            w=csv.DictWriter(f,fieldnames=list(summary[0])); w.writeheader(); w.writerows(summary)
    (OUT/'progress.json').write_text(json.dumps(dict(updated=datetime.datetime.now().isoformat(),
            processed_slots=len(rows),actual_measurements=sum(r.get('attempted',True) for r in rows),planned_slots=550,summary=summary),indent=2),encoding='utf-8')

def main():
    p=argparse.ArgumentParser(); p.add_argument('--pilot-only',action='store_true'); p.add_argument('--continue-formal',action='store_true')
    a=p.parse_args()
    OUT.mkdir(parents=True,exist_ok=True)
    shutil.copy2(__file__,OUT/Path(__file__).name)
    for name in ['rq3_worker.py','rq3_timing.py']: shutil.copy2(BASE/'work'/name,OUT/name)
    protocol=dict(run_id=RUN_ID,subjects=SUBJECTS,repeats=10,budget=10000,bug_depth=3,
                  ipb_idb_bounds=[0,1,2,3],outer_wall_limit_s=300,target_timeout_s=5,native_batch=20,
                  tools=['Period','IPB','IDB'],native_references=['period','baseline'],
                  timing='mean target process invocation latency including launcher; search wall time stored separately',
                  limitations=['Different kernels and compilers across backend environments; normalize against native in each environment',
                               'Bound/schedule definitions differ across tools; completed invocations are not unique schedules',
                               'Timeout attempts retained; slowdown left empty for incomplete runs; no claim of exact Figure 7 reproduction'])
    (OUT/'protocol.json').write_text(json.dumps(protocol,indent=2),encoding='utf-8')
    deploy()
    if a.continue_formal:
        for backend in ['period','baseline']: action(backend,'instrument',subject='CS_account')
    if not a.continue_formal:
        for backend in ['period','baseline']:
            action(backend,'instrument',subject='CS_account')
            result=action(backend,'prepare',subject='CS_account')
            if result['status']!='READY': raise RuntimeError('Pilot build failed')
            action(backend,'run',subject='CS_account',tool='native')
        for backend,tool in [('period','Period'),('baseline','IPB'),('baseline','IDB')]:
            result=action(backend,'run',subject='CS_account',tool=tool)
            if result['status']!='OK': raise RuntimeError('Pilot failed: '+json.dumps(result))
        print('PILOT_COMPLETE',flush=True)
    if a.pilot_only: return
    for subject in SUBJECTS:
        for backend in ['period','baseline']:
            prepared=OUT/'preparation'/backend/(subject+'-prepare.json')
            if not prepared.exists() or json.loads(prepared.read_text()).get('status')!='READY':
                result=action(backend,'prepare',subject)
                if result['status']!='READY' and not result.get('native_ready'):
                    raise RuntimeError('Preparation failed: '+json.dumps(result))
        hashes=[json.loads((OUT/'preparation'/b/(subject+'-prepare.json')).read_text()).get('source_hashes') for b in ['period','baseline']]
        if hashes[0]!=hashes[1]: raise RuntimeError('Source hash mismatch: '+subject)
        for repeat in range(1,11):
            for backend,tool in [('period','native'),('baseline','native'),('period','Period'),('baseline','IPB'),('baseline','IDB')]:
                previous=OUT/'raw'/backend/subject/tool/str(repeat)/'host_result.json'
                if previous.exists(): continue
                prepared=json.loads((OUT/'preparation'/backend/(subject+'-prepare.json')).read_text())
                if tool in ['IPB','IDB'] and prepared['status']!='READY':
                    previous.parent.mkdir(parents=True,exist_ok=True)
                    row=dict(subject=subject,tool=tool,backend=backend,repeat=repeat,status=prepared['status'],
                             attempted=False,mean_execution_s=None,search_wall_s=None,completed_executions=None,
                             program_error_executions=None,tool_error_executions=None,target_timeouts=None,
                             exit_code=None,reason='Race preparation failed; no valid controlled measurement attempted',
                             local_log_dir=str(previous.parent))
                    previous.write_text(json.dumps(row,indent=2),encoding='utf-8')
                    refresh()
                    print('BLOCKED',subject,tool,repeat,prepared['status'],flush=True)
                    continue
                action(backend,'run',subject,tool,repeat,budget=10000,cap=300)
    print('ALL_MEASUREMENTS_FINISHED',flush=True)

if __name__=='__main__': main()

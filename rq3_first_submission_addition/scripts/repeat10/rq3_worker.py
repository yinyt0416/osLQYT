#!/usr/bin/env python3
"""One isolated preparation or measurement; compatible with Python 3.4+."""
import argparse
import csv
import hashlib
import json
import os
import re
import shutil
import signal
import statistics
import subprocess
import sys
import time
import tarfile
import resource

SUBJECTS = [
 ('CVE-2017-6346','evaluation/ConVul-CVE-Benchmarks/CVE-2017-6346','2017-6346',['2017-6346.cpp'],True),
 ('doubleFree','test/doubleFree','df',['df.c'],True),
 ('CS_account','evaluation/CS/account','account_bad',['account_bad.c'],False),
 ('CS_lazy01','evaluation/CS/lazy01','lazy01_bad',['lazy01_bad.c'],False),
 ('CS_twostage','evaluation/CS/twostage','twostage_bad',['twostage_bad.c'],False),
 ('CS_reorder_3','evaluation/CS/reorder_3','reorder_3_bad',['reorder_3_bad.c'],False),
 ('CS_circular_buffer','evaluation/CS/circular_buffer','circular_buffer_bad',['circular_buffer_bad.c'],False),
 ('CB_stringbuffer','evaluation/CB/stringbuffer-jdk1.4','main',['main.cpp','stringbuffer.cpp','stringbuffer.hpp'],True),
 ('CS_reorder_4','evaluation/CS/reorder_4','reorder_4_bad',['reorder_4_bad.c'],False),
 ('CS_token_ring','evaluation/CS/token_ring','token_ring_bad',['token_ring_bad.c','common.inc'],False),
 ('CS_bluetooth_driver','evaluation/CS/bluetooth_driver','bluetooth_driver_bad',['bluetooth_driver_bad.c','common.inc'],False),
 ('CS_wronglock_3','evaluation/CS/wronglock_3','wronglock_3_bad',['wronglock_3_bad.c'],False),
]
SCT='/home/sct/sctbench'
PERIOD='/workdir/PERIOD'

def mkdir(p):
    if not os.path.isdir(p): os.makedirs(p)

def write(p, s):
    with open(p,'w',encoding='utf-8') as f: f.write(s)

def descendants(root):
    parent={}
    for name in os.listdir('/proc'):
        if name.isdigit():
            try:
                s=open('/proc/'+name+'/stat').read()
                parent[int(name)]=int(s[s.rfind(')')+2:].split()[1])
            except (IOError, ValueError, IndexError): pass
    found=set([root])
    while True:
        more=set(pid for pid,ppid in parent.items() if ppid in found)
        if more.issubset(found): break
        found.update(more)
    return found

def stop_tree(pid):
    # Stop the owned supervisor first so it cannot create new children.
    try: os.kill(pid,signal.SIGSTOP)
    except OSError: pass
    owned=descendants(pid)
    for p in owned:
        try: os.kill(p,signal.SIGKILL)
        except OSError: pass

def execute(cmd, cwd, logfile, env=None, cap=300):
    start=time.monotonic()
    with open(logfile,'wb') as f:
        p=subprocess.Popen(cmd,cwd=cwd,env=env,stdout=f,stderr=subprocess.STDOUT,preexec_fn=os.setsid)
        try:
            rc=p.wait(timeout=cap)
            timed=False
        except subprocess.TimeoutExpired:
            stop_tree(p.pid)
            p.wait()
            rc=124
            timed=True
    return rc,time.monotonic()-start,timed

def copied_runner(a):
    if a.backend=='period':
        original=os.path.join(PERIOD,'tool/DBDS/run_PDS.py')
        dest=os.path.join(PERIOD,'tool/DBDS/run_PDS_rq3_unified.py')
        text=open(original,encoding='utf-8').read()
        header='import time\nfrom rq3_timing import wrap_process\n'
        text=header+text
        needle='def create_DBDS_subprocess(check_STDOUT, check_STDERR):\n'
        if text.count(needle)!=1: raise RuntimeError('Unexpected PERIOD function')
        text=text.replace(needle,needle+'    rq3_started = time.monotonic()\n',1)
        text=text.replace('    return process\n','    return wrap_process(process, rq3_started, globals().get("rounds", -1))\n',1)
        write(dest,text)
        shutil.copy2('/tmp/rq3_timing.py',os.path.join(PERIOD,'tool/DBDS/rq3_timing.py'))
        return dest
    original=os.path.join(SCT,'maple/script/maple/runner.py')
    text=open(original,encoding='utf-8').read()
    text='import json\nimport re\n'+text
    needle='            proc = subprocess.Popen(pincmd + argv, preexec_fn=os.setsid)'
    if text.count(needle)!=1: raise RuntimeError('Unexpected SCT runner function')
    text=text.replace(needle,'            rq3_started=time.time()\n            rq3_offset=os.lseek(1,0,os.SEEK_CUR)\n'+needle)
    hook='''
        rq3_elapsed=time.time()-rq3_started
        rq3_data=''
        try:
            with open(os.readlink('/proc/self/fd/1'),'rb') as rq3_f:
                rq3_f.seek(rq3_offset)
                rq3_data=rq3_f.read()
        except IOError:
            pass
        rq3_bug=bool(re.search(r'AddressSanitizer:|Assertion .*failed|assertion .*failed|double free or corruption|Segmentation fault',rq3_data,re.I) or proc.returncode in [-6,-11,134,139])
        rq3_invalid=bool(re.search(r'E:Attach|Unable to load|Internal Error|unsupported linux release|unexpected AUX VEC|Pin:.*(?:error|abort)|AddressSanitizer CHECK failed|AddressSanitizer failed to deallocate',rq3_data,re.I) or ('not malloc()-ed' in rq3_data and 'libdl' in rq3_data))
        if os.environ.get('RQ3_TIMING_OUT'):
            with open(os.environ['RQ3_TIMING_OUT'],'a') as rq3_f:
                rq3_f.write(json.dumps(dict(seconds=rq3_elapsed,schedule=i,bound=bound,completed=True,timeout=False,returncode=proc.returncode,program_error=rq3_bug,tool_error=rq3_invalid))+'\\n')
'''
    needle='        proc.communicate()\n'
    if text.count(needle)!=1: raise RuntimeError('Unexpected communicate count')
    text=text.replace(needle,needle+hook,1)
    dest=os.path.join(SCT,'maple/script/maple/rq3_runner.py')
    write(dest,text)
    return dest

def prepare(a,sub):
    subject,rel,binname,files,asan=sub
    subj=os.path.join(a.root,'subjects',subject)
    mkdir(subj)
    source=os.path.join(PERIOD,rel) if a.backend=='period' else os.path.join('/home/sct/rq3-staging/rq3-preparation/rq3-period-matched',subject,'run')
    log=os.path.join(subj,'build.log')
    if a.backend=='period':
        isolated=os.path.join(a.root,'source','PERIOD')
        mkdir(isolated)
        for name in ['tool','clang+llvm']:
            link=os.path.join(isolated,name)
            if not os.path.lexists(link): os.symlink(os.path.join(PERIOD,name),link)
        dest=os.path.join(isolated,rel)
        mkdir(dest)
        for name in files+['build.sh','cleanDIR.sh','Makefile']:
            src=os.path.join(source,name)
            if os.path.isfile(src): shutil.copy2(src,os.path.join(dest,name))
        source=dest
        rc,elapsed,timed=execute(['bash','build.sh'],source,log,cap=300)
        if rc: return dict(action='prepare',subject=subject,status='FAIL_BUILD',exit_code=rc,log=log)
        shutil.copy2(os.path.join(source,binname),os.path.join(subj,'instrumented'))
        npz='mempair.'+binname+'.npz'
        if not os.path.isfile(os.path.join(source,npz)): raise RuntimeError('Missing '+npz)
        shutil.copy2(os.path.join(source,npz),os.path.join(subj,'mempair.instrumented.npz'))
    for f in files: shutil.copy2(os.path.join(source,f),os.path.join(subj,f))
    inputs=[os.path.join(subj,f) for f in files if f.endswith(('.c','.cpp'))]
    cc=('clang++' if inputs[0].endswith('.cpp') else 'clang') if a.backend=='period' else ('g++' if inputs[0].endswith('.cpp') else 'gcc')
    cmd=[cc,'-O0','-g']+(['-fsanitize=address'] if asan else [])+inputs+['-o',os.path.join(subj,'native'),'-pthread','-ldl']
    rc,elapsed,timed=execute(cmd,subj,os.path.join(subj,'native-build.log'),cap=60)
    hashes={f:hashlib.sha256(open(os.path.join(subj,f),'rb').read().replace(b'\r\n',b'\n')).hexdigest() for f in files}
    write(os.path.join(subj,'build_manifest.json'),json.dumps(dict(command=cmd,source_hashes=hashes,asan=asan),indent=2))
    if rc: return dict(action='prepare',subject=subject,status='FAIL_NATIVE_BUILD',exit_code=rc)
    if a.backend=='baseline':
        # Dedicated suite and measurement wrapper; do not replace stock SCTBench runners.
        suite=os.path.join(SCT,'benchmarks','rq3-unified-'+a.run_id)
        mkdir(suite)
        rundir=os.path.join(suite,subject,'run')
        mkdir(rundir)
        shutil.copy2(os.path.join(subj,'native'),os.path.join(rundir,'program'))
        run='#!/bin/bash\nset -e\ncd "$(dirname "$0")/$1/run"\nexport PYTHONPATH="'+SCT+'/maple/script:${PYTHONPATH:-}"\nexec python "'+SCT+'/maple/script/maple/rq3_runner.py" ./program\n'
        write(os.path.join(suite,'run.sh'),run)
        os.chmod(os.path.join(suite,'run.sh'),0o755)
        listing=os.path.join(subj,'subject.txt')
        write(listing,'rq3-unified-'+a.run_id+' '+subject+' 3 100\n')
        env=base_env(a)
        env.pop('RQ3_TIMING_OUT',None)
        cmd=['python',os.path.join(SCT,'scripts/run_many.py'),'--mode','race','--max','10','--timelimit','10',listing]
        rc,elapsed,timed=execute(cmd,SCT,os.path.join(subj,'race.log'),env,cap=120)
        if rc: return dict(action='prepare',subject=subject,status='FAIL_RACE_PREP',exit_code=rc)
        if not os.path.isfile(os.path.join(suite,subject,'run_race','race.db')):
            return dict(action='prepare',subject=subject,status='UNSUPPORTED_ASAN_PIN' if asan else 'FAIL_RACE_DATABASE',
                        native_ready=True,source_hashes=hashes,log=os.path.join(subj,'race.log'))
    return dict(action='prepare',subject=subject,status='READY',source_hashes=hashes)

def base_env(a):
    env=os.environ.copy()
    env['ASAN_OPTIONS']='abort_on_error=1:detect_leaks=0'
    if a.backend=='baseline':
        env.update(ROOT=SCT,MAPLE_HOME=SCT+'/maple',PIN_HOME=SCT+'/pin',cluster='0',PROTOBUF_HOME='/usr')
        env['PATH']=SCT+'/scripts:'+SCT+'/maple/script:'+env['PATH']
    return env

def run(a,sub):
    subject=sub[0]
    subj=os.path.join(a.root,'subjects',subject)
    runpath=os.path.join(a.root,'runs',subject,a.tool,str(a.repeat))
    mkdir(runpath)
    env=base_env(a)
    samplepath=os.path.join(runpath,'executions.jsonl')
    if os.path.exists(samplepath): raise RuntimeError('Refusing to overwrite measurement: '+samplepath)
    write(samplepath,'')
    logfile=os.path.join(runpath,'search.log')
    start=time.monotonic()
    if a.tool=='native':
        from rq3_timing import classify
        events=[]
        for i in range(a.native_batch):
            with open(os.path.join(runpath,'native_{:03d}.log'.format(i)),'wb') as f:
                t=time.monotonic()
                p=subprocess.Popen([os.path.join(subj,'native')],cwd=runpath,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,preexec_fn=os.setsid)
                try:
                    data,_=p.communicate(timeout=a.target_timeout)
                    rc=p.returncode
                    timed=False
                except subprocess.TimeoutExpired:
                    stop_tree(p.pid); data,_=p.communicate(); rc=124; timed=True
                sec=time.monotonic()-t
                f.write(data)
            data=open(os.path.join(runpath,'native_{:03d}.log'.format(i)),'rb').read()
            bug,invalid=classify(data,rc)
            invalid=invalid or (rc!=0 and not bug and not timed)
            row=dict(seconds=sec,schedule=i+1,returncode=rc,completed=not timed,timeout=timed,program_error=bug,tool_error=invalid)
            events.append(row)
            with open(samplepath,'a') as f: f.write(json.dumps(row)+'\n')
        outer_rc=0; outer_timeout=False; wall=time.monotonic()-start
    else:
        env['RQ3_TIMING_OUT']=samplepath
        if a.tool=='Period':
            shutil.copy2(os.path.join(subj,'instrumented'),os.path.join(runpath,'program'))
            shutil.copy2(os.path.join(subj,'mempair.instrumented.npz'),os.path.join(runpath,'mempair.program.npz'))
            cmd=['python3','-u',os.path.join(PERIOD,'tool/DBDS/run_PDS_rq3_unified.py'),'-y','-d','3','-f',str(a.budget),'-t',str(a.target_timeout),'./program']
            cwd=runpath
        else:
            mode={'IPB':'pb','IDB':'db','PCT':'pct'}[a.tool]
            # The PERIOD evaluation uses PCT with bug depth d=3. IPB/IDB
            # iterate bounds 0..4, matching the existing unified baseline plan.
            max_bound='3' if a.tool=='PCT' else '4'
            cmd=['python','-u',os.path.join(SCT,'scripts/run_many.py'),'--mode',mode,'--max',max_bound,'--limit',str(a.budget),'--timelimit',str(a.wall_timeout),'--numjobs','1',os.path.join(subj,'subject.txt')]
            cwd=SCT
        outer_rc,wall,outer_timeout=execute(cmd,cwd,logfile,env,cap=a.wall_timeout)
        events=[]
        for line in open(samplepath):
            try: events.append(json.loads(line))
            except ValueError: pass
        if a.backend=='baseline':
            # run_many routes target output to its own timestamped raw log files.
            destinations=set()
            for match in re.findall(r"(/home/sct/sctbench/benchmarks/__results/[^'\s]+)",open(logfile,encoding='utf-8',errors='replace').read()):
                path=match.rstrip('],')
                if os.path.isdir(path): destinations.add(path)
            # Child argv previews may be buffered; use execution timestamps as fallback.
            rawdir=os.path.join(runpath,'raw')
            mkdir(rawdir)
            for dirname,dirs,files in os.walk(os.path.join(SCT,'benchmarks/__results')):
                for name in files:
                    if '--'+subject+'--' in name:
                        p=os.path.join(dirname,name)
                        if os.path.getmtime(p)>=time.time()-wall-3:
                            shutil.copy2(p,os.path.join(rawdir,name))
    complete=[e for e in events if e.get('completed') and not e.get('tool_error')]
    invalid=sum(bool(e.get('tool_error')) for e in events)
    timeouts=sum(bool(e.get('timeout')) for e in events)
    status='OK'
    if outer_timeout: status='TIMEOUT'
    elif outer_rc: status='FAIL_RUNNER'
    elif invalid: status='TOOL_ERROR'
    elif not complete: status='NO_COMPLETED_EXECUTIONS'
    elif timeouts: status='TARGET_TIMEOUTS'
    if a.tool=='Period' and status=='OK' and 'End Testing!' not in open(logfile,encoding='utf-8',errors='replace').read(): status='INCOMPLETE'
    row=dict(subject=subject,tool=a.tool,repeat=a.repeat,backend=a.backend,status=status,
             mean_execution_s=statistics.mean([e['seconds'] for e in complete]) if complete else None,
             search_wall_s=wall,completed_executions=len(complete),
             program_error_executions=sum(bool(e.get('program_error')) for e in complete),
             target_timeouts=timeouts,tool_error_executions=invalid,exit_code=outer_rc,
             budget=a.budget,wall_timeout_s=a.wall_timeout,target_timeout_s=a.target_timeout,
             log_dir=runpath,native_batch=a.native_batch if a.tool=='native' else '',
             timing_definition='mean_target_process_invocation_latency_including_launcher',
             schedule_definition='completed_target_invocations_including_retests_and_repeated_bounds')
    if a.tool=='Period':
        txt=open(logfile,encoding='utf-8',errors='replace').read()
        m=re.findall(r'Total Error Interleavings: (\d+)',txt)
        row['tool_reported_errors']=int(m[-1]) if m else None
    write(os.path.join(runpath,'result.json'),json.dumps(row,indent=2,sort_keys=True))
    with tarfile.open(os.path.join(runpath,'artifacts.tar.gz'),'w:gz') as archive:
        for name in os.listdir(runpath):
            if name.endswith(('.json','.jsonl','.log')) or name=='raw':
                archive.add(os.path.join(runpath,name),arcname=name)
    return row

def main():
    resource.setrlimit(resource.RLIMIT_CORE,(0,0))
    os.environ.setdefault('LLVM_COMPILER','clang')
    p=argparse.ArgumentParser()
    p.add_argument('--backend',choices=['period','baseline'],required=True)
    p.add_argument('--action',choices=['prepare','run','instrument'],required=True)
    p.add_argument('--root',required=True)
    p.add_argument('--run-id',required=True)
    p.add_argument('--subject',default='doubleFree')
    p.add_argument('--tool',default='native')
    p.add_argument('--repeat',type=int,default=1)
    p.add_argument('--budget',type=int,default=10000)
    p.add_argument('--wall-timeout',type=int,default=300)
    p.add_argument('--target-timeout',type=int,default=5)
    p.add_argument('--native-batch',type=int,default=20)
    a=p.parse_args()
    mkdir(a.root)
    if a.action=='instrument':
        row=dict(action='instrument',path=copied_runner(a),status='READY')
    else:
        sub=next(s for s in SUBJECTS if s[0]==a.subject)
        row=prepare(a,sub) if a.action=='prepare' else run(a,sub)
    print('RQ3_RESULT='+json.dumps(row,sort_keys=True))

if __name__=='__main__': main()

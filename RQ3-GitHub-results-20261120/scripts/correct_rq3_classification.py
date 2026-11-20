"""Correct classifier flags from preserved raw output, without changing timing samples."""
import json
import pathlib
import re
import shutil
import statistics

root=pathlib.Path(__file__).resolve().parent.parent/'outputs/RQ3-unified-20261120-v2/raw/baseline'
invalid_re=re.compile(r'E:Attach|Unable to load|Internal Error|unsupported linux release|unexpected AUX VEC|Pin:.*(?:error|abort)|AddressSanitizer CHECK failed|AddressSanitizer failed to deallocate',re.I)
for host in root.glob('*/*/*/host_result.json'):
    row=json.loads(host.read_text())
    samples=host.parent/'executions.jsonl'
    if row['tool']=='native' or not samples.exists(): continue
    events=[json.loads(s) for s in samples.read_text().splitlines()]
    mapping={}
    for logfile in (host.parent/'raw').glob('*.txt'):
        bound_match=re.search(r'--(?:pb|db)--(\d+)--',logfile.name)
        if not bound_match: continue
        bound=int(bound_match.group(1))
        for segment in logfile.read_text(errors='replace').split('Starting execution\n')[1:]:
            execution=re.search(r'finished execution (\d+)',segment)
            if execution:
                mapping[(bound,int(execution.group(1)))]=bool(invalid_re.search(segment) or ('not malloc()-ed' in segment and 'libdl' in segment))
    changed=False
    for event in events:
        key=(event.get('bound'),event['schedule'])
        if key in mapping and event['tool_error']!=mapping[key]:
            event['tool_error']=mapping[key]
            changed=True
    if not changed: continue
    for path in [host,samples,host.parent/'result.json']:
        backup=path.with_name(path.name+'.before-classifier-fix')
        if path.exists() and not backup.exists(): shutil.copy2(path,backup)
    samples.write_text(''.join(json.dumps(e,sort_keys=True)+'\n' for e in events))
    completed=[e for e in events if e.get('completed') and not e.get('tool_error')]
    row.update(completed_executions=len(completed),
               mean_execution_s=statistics.mean(e['seconds'] for e in completed) if completed else None,
               program_error_executions=sum(bool(e['program_error']) for e in completed),
               tool_error_executions=sum(bool(e['tool_error']) for e in events))
    if row['status']=='TOOL_ERROR' and row['tool_error_executions']==0: row['status']='OK'
    row['classifier_revision']='2: exit code 1 alone is not a Pin tool error; validated against original output'
    temp=host.with_suffix('.tmp')
    temp.write_text(json.dumps(row,indent=2))
    temp.replace(host)
    (host.parent/'result.json').write_text(json.dumps({k:v for k,v in row.items() if k!='local_log_dir'},indent=2))
    print('Corrected classification only:',row['subject'],row['tool'],row['repeat'],len(completed))

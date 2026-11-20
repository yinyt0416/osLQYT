"""Timing-only wrapper; never changes target return values or schedule choices."""
import json
import os
import re
import subprocess
import time

BUG = re.compile(br'AddressSanitizer:|Assertion .*failed|assertion .*failed|double free or corruption|Segmentation fault', re.I)
TOOL_ERROR = re.compile(br'Pin:.*(?:error|abort)|E:Attach|Unable to load|Internal Error|unsupported linux release|sched_setattr: Invalid argument|unexpected AUX VEC', re.I)

def append_sample(row):
    dest = os.environ.get('RQ3_TIMING_OUT')
    if dest:
        with open(dest, 'a') as f:
            f.write(json.dumps(row, sort_keys=True) + '\n')

def classify(data, rc):
    return bool(BUG.search(data) or rc in (-6, -11, 134, 139)), bool(TOOL_ERROR.search(data))

def wrap_process(proc, started, schedule):
    original = proc.communicate
    recorded = [False]
    def communicate(*args, **kwargs):
        try:
            result = original(*args, **kwargs)
        except subprocess.TimeoutExpired:
            if not recorded[0]:
                append_sample(dict(seconds=time.monotonic()-started, schedule=schedule,
                                   completed=False, timeout=True, returncode=None,
                                   program_error=False, tool_error=False))
                recorded[0] = True
            raise
        if not recorded[0]:
            data = b'\n'.join(x for x in result if isinstance(x, bytes))
            bug, invalid = classify(data, proc.returncode)
            append_sample(dict(seconds=time.monotonic()-started, schedule=schedule,
                               completed=True, timeout=False, returncode=proc.returncode,
                               program_error=bug, tool_error=invalid))
            recorded[0] = True
        return result
    proc.communicate = communicate
    return proc

# RQ3 SCTBench baseline results

## Scope and protocol

The run evaluates the ten SCTBench subjects matched to the ten non-smoke PERIOD RQ3 subjects. SCTBench first constructs race databases and then executes IPB (`pb`), IDB (`db`), and PCT (`pct`). The driver used a schedule limit of 10,000, a per-invocation time limit of 300 seconds, and one worker job. It is resumable and skips combinations already present in `phase_status.csv`.

Environment and provenance:

- SCTBench commit: `d59ab26ddaedcd575ffb6a1f5e9711f7d6d2d9f2`
- Guest kernel: `3.2.0-23-generic`
- Python: `2.7.3`
- Subjects: `scripts/baselines/rq3_sctbench_matched.txt`
- Driver: `scripts/baselines/run_sctbench_rq3.sh`
- Completion evidence: `results/rq3/sctbench/COMPLETE`

## Aggregate results

| Phase | OK | Timeout/error | Total | Sum of recorded wall time |
|---|---:|---:|---:|---:|
| Race construction | 10 | 0 | 10 | 50 s |
| IPB | 5 | 5 | 10 | 6,130 s |
| IDB | 7 | 3 | 10 | 2,689 s |
| PCT | 0 | 10 | 10 | 5,267 s |
| **Total** | **22** | **18** | **40** | **14,136 s** |

## Per-subject terminal status

| Subject | IPB | IDB | PCT |
|---|---:|---:|---:|
| `stringbuffer-jdk1.4` | OK (75 s) | OK (58 s) | TIMEOUT_OR_ERROR (322 s) |
| `account_bad` | OK (117 s) | OK (56 s) | TIMEOUT_OR_ERROR (1,232 s) |
| `bluetooth_driver_bad` | OK (159 s) | OK (135 s) | TIMEOUT_OR_ERROR (322 s) |
| `circular_buffer_bad` | TIMEOUT_OR_ERROR (697 s) | TIMEOUT_OR_ERROR (488 s) | TIMEOUT_OR_ERROR (322 s) |
| `lazy01_bad` | OK (351 s) | OK (167 s) | TIMEOUT_OR_ERROR (323 s) |
| `reorder_3_bad` | TIMEOUT_OR_ERROR (1,711 s) | OK (325 s) | TIMEOUT_OR_ERROR (322 s) |
| `reorder_4_bad` | TIMEOUT_OR_ERROR (419 s) | TIMEOUT_OR_ERROR (485 s) | TIMEOUT_OR_ERROR (1,458 s) |
| `token_ring_bad` | TIMEOUT_OR_ERROR (739 s) | OK (182 s) | TIMEOUT_OR_ERROR (322 s) |
| `twostage_bad` | OK (141 s) | OK (122 s) | TIMEOUT_OR_ERROR (322 s) |
| `wronglock_3_bad` | TIMEOUT_OR_ERROR (1,721 s) | TIMEOUT_OR_ERROR (671 s) | TIMEOUT_OR_ERROR (322 s) |

The race-construction phase completed with `OK` for all ten subjects in 4–6 seconds each.

## Interpretation and evidence policy

The table reports the driver's terminal classification without converting timeouts into successes or defects. A `TIMEOUT_OR_ERROR` row is still a completed experimental observation: its process ended under the configured policy and its exception trace or partial output is retained. Claims about bug exposure should be derived from the corresponding raw file and log, not solely from the aggregate status label.

For audit and re-analysis, use these sources in order:

1. `results/rq3/sctbench/phase_status.csv` for the authoritative 40-row terminal-status table.
2. `results/rq3/sctbench/logs/<phase>--<subject>.log` for the exact invocation and traceback.
3. `results/rq3/sctbench/raw/__results/` for benchmark-level output, assertions, signals, and schedule evidence. The VM path prefix was removed only to keep repository paths Windows-compatible.
4. `results/rq3/sctbench/progress.log` and `run.meta` for execution chronology and resume points.

## Reproduction

On the matching legacy guest, place the subject list at `benchmarks/rq3_matched.txt`, ensure SCTBench is at the recorded commit, and run:

```bash
SCHEDULE_LIMIT=10000 TIME_LIMIT=300 bash scripts/baselines/run_sctbench_rq3.sh
```

The driver records each terminal combination in `phase_status.csv`; rerunning it resumes from that table rather than repeating completed combinations.

# RQ3 SCTBench reproduction package

This directory is a repository-ready evidence package for the completed RQ3 SCTBench baseline run.

## Completion

- All 40 tool/subject combinations have terminal records.
- The `COMPLETE` marker is present.
- Start: `2026-11-20T20:58:56Z` (2026-11-21 04:58:56, Asia/Shanghai).
- Finish: `2026-11-21T10:25:33Z` (2026-11-21 18:25:33, Asia/Shanghai).
- SCTBench commit: `d59ab26ddaedcd575ffb6a1f5e9711f7d6d2d9f2`.
- Kernel: `3.2.0-23-generic`; Python: `2.7.3`.

## Result overview

| Tool label | Meaning | OK | TIMEOUT_OR_ERROR | Total | Recorded wall time |
|---|---|---:|---:|---:|---:|
| `race` | race database construction | 10 | 0 | 10 | 50 s |
| `pb` | IPB | 5 | 5 | 10 | 6,130 s |
| `db` | IDB | 7 | 3 | 10 | 2,689 s |
| `pct` | PCT | 0 | 10 | 10 | 5,267 s |
| **Total** |  | **22** | **18** | **40** | **14,136 s** |

`TIMEOUT_OR_ERROR` is the driver's terminal classification. It means the benchmark invocation returned non-zero or exceeded its configured limit; it does not mean that SSH, Vagrant, Pin, or the experiment driver failed. The per-subject logs and raw outputs are preserved so each classification is auditable.

## Evidence layout

- `phase_status.csv`: authoritative machine-readable 40-row status table.
- `progress.log`: chronological phase and subject transitions.
- `logs/`: driver output and exception traces for every combination.
- `raw/__results/`: raw SCTBench timestamp directories with the long VM path prefix removed for Windows Git compatibility.
- `run.meta`: limits, commit, start/resume/finish timestamps.
- `COMPLETE`: driver completion marker.
- `provenance/environment.txt`: captured environment identity.
- `provenance/result-directories.txt`: source directories used to assemble the raw evidence.

Related repository files:

- `../../../reports/rq3-sctbench-final.md`: result report and interpretation boundary.
- `../../../scripts/baselines/rq3_sctbench_matched.txt`: matched subject list.
- `../../../scripts/baselines/run_sctbench_rq3.sh`: resumable driver used for this run.
- `../../../scripts/baselines/run_sctbench_preflight.sh`: environment preflight checks.

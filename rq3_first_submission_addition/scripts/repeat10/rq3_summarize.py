#!/usr/bin/env python3
"""Summarize paired native/PERIOD RQ3 runs without hiding invalid rounds."""
from __future__ import print_function

import csv
import json
import os
import statistics
import sys


def load(path):
    with open(path, "r", encoding="utf-8") as handle:
        return json.load(handle)


def mean(values):
    return statistics.mean(values) if values else None


def stdev(values):
    return statistics.stdev(values) if len(values) > 1 else 0.0 if values else None


def main(root):
    rows = []
    for repeat in range(1, 11):
        base = os.path.join(root, "runs", "CVE-2017-6346")
        native = load(os.path.join(base, "native", str(repeat), "result.json"))
        period = load(os.path.join(base, "Period", str(repeat), "result.json"))
        valid = native["status"] == "OK" and period["status"] == "OK"
        slowdown = None
        if valid and native.get("mean_execution_s"):
            slowdown = period["mean_execution_s"] / native["mean_execution_s"]
        rows.append({
            "repeat": repeat,
            "valid_pair": valid,
            "native_status": native["status"],
            "period_status": period["status"],
            "native_mean_s": native.get("mean_execution_s"),
            "period_mean_s": period.get("mean_execution_s"),
            "slowdown": slowdown,
            "period_wall_s": period.get("search_wall_s"),
            "period_completed": period.get("completed_executions"),
            "period_program_errors": period.get("program_error_executions"),
            "period_reported_errors": period.get("tool_reported_errors"),
            "period_target_timeouts": period.get("target_timeouts"),
            "period_tool_errors": period.get("tool_error_executions"),
        })

    valid = [row for row in rows if row["valid_pair"]]
    slowdowns = [row["slowdown"] for row in valid]
    summary = {
        "subject": "CVE-2017-6346",
        "total_pairs": len(rows),
        "valid_pairs": len(valid),
        "excluded_repeats": [row["repeat"] for row in rows if not row["valid_pair"]],
        "exclusion_reasons": {
            str(row["repeat"]): {
                "native_status": row["native_status"],
                "period_status": row["period_status"],
                "period_target_timeouts": row["period_target_timeouts"],
            }
            for row in rows if not row["valid_pair"]
        },
        "valid_native_mean_s": mean([row["native_mean_s"] for row in valid]),
        "valid_period_mean_s": mean([row["period_mean_s"] for row in valid]),
        "valid_slowdown_mean": mean(slowdowns),
        "valid_slowdown_stdev": stdev(slowdowns),
        "valid_slowdown_min": min(slowdowns) if slowdowns else None,
        "valid_slowdown_max": max(slowdowns) if slowdowns else None,
        "valid_period_wall_mean_s": mean([row["period_wall_s"] for row in valid]),
        "valid_period_completed_mean": mean([row["period_completed"] for row in valid]),
        "valid_period_reported_errors_mean": mean([row["period_reported_errors"] for row in valid]),
    }

    csv_path = os.path.join(root, "rq3_repeat10_rounds.csv")
    with open(csv_path, "w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    json_path = os.path.join(root, "rq3_repeat10_summary.json")
    with open(json_path, "w", encoding="utf-8") as handle:
        json.dump(summary, handle, indent=2, sort_keys=True)
        handle.write("\n")
    print(json.dumps({"rounds": rows, "summary": summary}, indent=2, sort_keys=True))


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("usage: rq3_summarize.py EVIDENCE_ROOT")
    main(sys.argv[1])

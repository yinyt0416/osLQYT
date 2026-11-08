#!/bin/bash
# Merge per-tool TSVs into compare_summary.tsv (empty/NOT_RUN until tools run).
set -u
# shellcheck disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/env.sh"
OUT="$OUT_DIR/compare_summary.tsv"
echo -e "tool\tsubject\tbugs_found\tschedules\ttime_s\tstatus\tnotes" > "$OUT"
shopt -s nullglob
for f in "$OUT_DIR"/*_results.tsv; do
  tail -n +2 "$f" >> "$OUT"
done
echo "Merged -> $OUT ($(wc -l < "$OUT") lines incl header)"

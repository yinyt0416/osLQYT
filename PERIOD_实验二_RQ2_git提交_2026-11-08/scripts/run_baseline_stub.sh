#!/bin/bash
# Stub runner that emits comparable TSV rows. Real tool invocation is filled
# after sctbench tools are built. Until then rows are marked NOT_RUN.
# Columns: tool, subject, bugs_found, schedules, time_s, status, notes
set -u
# shellcheck disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/env.sh"
TOOL="${1:?tool name: IPB|IDB|DFS|PCT|Random|Maple|Period}"
OUT_TSV="$OUT_DIR/${TOOL}_results.tsv"
mkdir -p "$OUT_DIR"
echo -e "tool\tsubject\tbugs_found\tschedules\ttime_s\tstatus\tnotes" > "$OUT_TSV"

# Prefer subjects that PERIOD already finished cleanly (DONE)
while IFS=$'\t' read -r subject prior qs errors tests dur depth notes; do
  [ "$subject" = "subject" ] && continue
  # skip huge by default
  case "$subject" in
    CS_reorder_50|CS_reorder_100|CS_twostage_50|CS_twostage_100|CS_twostage_20)
      echo -e "${TOOL}\t${subject}\tNA\tNA\tNA\tSKIP\thuge/partial; set RUN_HUGE=1 later" >> "$OUT_TSV"
      continue
      ;;
  esac
  if [ "$TOOL" = "Period" ]; then
    # Reference only — copy prior PERIOD numbers if DONE, else TODO
    if [ "$qs" = "DONE" ]; then
      echo -e "Period\t${subject}\t${errors}\t${tests}\t${dur}\tPRIOR_REF\tfrom reference_period_results; not a fresh run" >> "$OUT_TSV"
    else
      echo -e "Period\t${subject}\tNA\tNA\tNA\tTODO\tprior=${prior}" >> "$OUT_TSV"
    fi
    continue
  fi
  # Placeholder for real baseline invocation
  # Expected future body (example):
  #   timeout 480 $SCTBENCH_DIR/bin/${TOOL,,} ./$bin ...
  echo -e "${TOOL}\t${subject}\tNA\tNA\tNA\tNOT_RUN\tbuild sctbench tools first; see scripts/clone_baselines.sh" >> "$OUT_TSV"
done < "$SUBJECTS_TSV"

echo "Wrote $OUT_TSV"
wc -l "$OUT_TSV"

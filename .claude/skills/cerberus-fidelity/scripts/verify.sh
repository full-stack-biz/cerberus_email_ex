#!/usr/bin/env bash
# Verify every ported template against upstream Cerberus.
#
# Usage (from the project root): .claude/skills/cerberus-fidelity/scripts/verify.sh [work_dir]
#   work_dir defaults to ./tmp/cerberus-fidelity (gitignored). Upstream is cloned there once
#   with `gh`; delete <work_dir>/Cerberus to re-fetch.
# Exit code: 0 all identical, 1 any difference.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
work="${1:-tmp/cerberus-fidelity}"
mkdir -p "${work}"

if [[ ! -d "${work}/Cerberus" ]]; then
  gh repo clone emailmonday/Cerberus "${work}/Cerberus" -- --depth 1
fi

status=0
for t in hybrid responsive fluid; do
  mix run "${here}/render.exs" "${t}" "${work}/${t}.html"
  for tool in structdiff cssdiff; do
    printf '%-11s %-11s ' "${t}" "${tool}"
    if out="$(python3 -I "${here}/${tool}.py" "${work}/Cerberus/cerberus-${t}.html" "${work}/${t}.html")"; then
      echo "${out}" | head -1
    else
      status=1
      echo "DIFFERENT"
      echo "${out}"
    fi
  done
done

if [[ "${status}" -eq 0 ]]; then
  echo "ALL IDENTICAL"
else
  echo "DIFFERENCES FOUND"
fi
exit "${status}"

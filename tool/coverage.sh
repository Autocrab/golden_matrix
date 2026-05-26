#!/usr/bin/env bash
# Summarise `coverage/lcov.info` produced by `flutter test --coverage`.
#
# Usage:
#   tool/coverage.sh              # TOTAL line + per-file breakdown sorted by path
#   tool/coverage.sh --total      # only the TOTAL line (useful for CI gates)
#   tool/coverage.sh <pattern>    # one matched file (substring of SF: path)
set -euo pipefail
LCOV="${LCOV:-coverage/lcov.info}"
if [ ! -f "$LCOV" ]; then
  echo "error: $LCOV not found. Run \`flutter test --coverage\` first." >&2
  exit 1
fi
case "${1:-}" in
  --total)
    awk '/^SF:/{f=$0} /^DA:/{split($0,a,",");t++;if(a[2]+0>0)h++} END{printf "TOTAL: %d/%d (%.1f%%)\n",h,t,h*100/t}' "$LCOV"
    ;;
  "")
    awk '/^SF:/{if(f && tt>0){printf "%-60s %4d/%4d (%5.1f%%)\n",f,hh,tt,hh*100/tt} f=$0;sub("SF:","",f);hh=0;tt=0} /^DA:/{split($0,a,",");tt++;if(a[2]+0>0)hh++} END{if(f && tt>0){printf "%-60s %4d/%4d (%5.1f%%)\n",f,hh,tt,hh*100/tt}} ' "$LCOV" | sort
    echo
    awk '/^SF:/{f=$0} /^DA:/{split($0,a,",");t++;if(a[2]+0>0)h++} END{printf "TOTAL: %d/%d (%.1f%%)\n",h,t,h*100/t}' "$LCOV"
    ;;
  *)
    pattern="$1"
    awk -v p="$pattern" 'BEGIN{found=0;hit=0;total=0} /^SF:/{if(found && total>0){printf "%s: %d/%d (%.1f%%)\n",sf,hit,total,hit*100/total;found=0;hit=0;total=0} if(index($0,p)>0){sf=$0;sub("SF:","",sf);found=1}} found && /^DA:/{split($0,a,",");total++;if(a[2]+0>0)hit++} END{if(found && total>0)printf "%s: %d/%d (%.1f%%)\n",sf,hit,total,hit*100/total}' "$LCOV"
    ;;
esac

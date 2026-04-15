#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CSV_FILE="${ROOT_DIR}/doc/進行状況.csv"

if [[ ! -f "${CSV_FILE}" ]]; then
  echo "進行状況ファイルが見つかりません: ${CSV_FILE}" >&2
  exit 1
fi

echo "== 進行状況サマリ =="

awk -F',' '
NR == 1 { next }
{
  phase_id=$1
  phase_name=$2
  status=$3
  evidence=$4
  updated=$5
  owner=$6
  note=$7

  gsub(/^"|"$/, "", evidence)
  gsub(/^"|"$/, "", note)

  if (status == "完了") {
    completed++
  } else {
    incomplete++
    if (current_id == "" || phase_id < current_id) {
      current_id=phase_id
      current_name=phase_name
      current_status=status
      current_evidence=evidence
      current_updated=updated
      current_owner=owner
      current_note=note
    }
  }
}
END {
  total = completed + incomplete
  printf("完了: %d / %d\n", completed, total)

  if (incomplete == 0) {
    print "現在工程: すべて完了"
    exit 0
  }

  print "現在工程: " current_id " " current_name
  print "状態: " current_status
  if (current_evidence != "") print "根拠: " current_evidence
  if (current_updated != "") print "更新日: " current_updated
  if (current_owner != "") print "担当: " current_owner
  if (current_note != "") print "メモ: " current_note
}
' "${CSV_FILE}"

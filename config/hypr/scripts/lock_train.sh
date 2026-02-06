#!/usr/bin/env bash
# Hyprlock SL-ish train: fixes top-line jitter by using braille blanks for leading spaces.

set -euo pipefail

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
STATE="$CACHE_DIR/hyprlock_train.pos"
mkdir -p "$CACHE_DIR"

COLS=52

# Braille blank (U+2800) – looks like space, doesn't collapse like normal spaces.
BB=$'\u2800'

# Replace ONLY leading ASCII spaces with braille blanks.
lead_spaces_to_bb() {
  local s="$1"
  local i=0
  while [[ $i -lt ${#s} && "${s:$i:1}" == " " ]]; do
    ((i++))
  done
  printf "%s%s" "$(printf "%*s" "$i" "" | tr ' ' "$BB")" "${s:$i}"
}

# State
smoke=( "  ." " . " ".  " " o " " O " " o " )
si=0
pos=0
if [[ -f "$STATE" ]]; then
  read -r pos si < "$STATE" || true
fi
pos=$((pos + 1))
si=$(( (si + 1) % ${#smoke[@]} ))
echo "$pos $si" > "$STATE"

s="${smoke[$si]}"

# Train sprite (4 lines)
l1="        ${s}                     "
l2="    ____/\\____      __________   "
l3=" __/ _  \\_/  _ \\____|  _  _  \\__ "
l4="|__|(_)____(_)|_____(o)(o)(o)___\\"

# Add 2 cars
c1="   __________   "
c2=" _|  _  _  |_\\_ "
c3="|_| |_| |_| |__|"
c4="  (o) (o) (o)   "

l1="$l1$c1$c1"
l2="$l2$c2$c2"
l3="$l3$c3$c3"
l4="$l4$c4$c4"

# Fix ONLY the top line's leading spaces (prevents "spazzing")
l1="$(lead_spaces_to_bb "$l1")"

# Equalize lengths
maxlen=${#l1}
for line in "$l2" "$l3" "$l4"; do
  (( ${#line} > maxlen )) && maxlen=${#line}
done
pad() { printf "%-*s" "$maxlen" "$1"; }

l1="$(pad "$l1")"
l2="$(pad "$l2")"
l3="$(pad "$l3")"
l4="$(pad "$l4")"

TLEN=$maxlen
TOTAL=$(( COLS + TLEN + 2 ))
pos=$(( pos % TOTAL ))
start=$(( pos - TLEN ))

render() {
  local sprite="$1"
  local left_pad=$(( start < 0 ? 0 : start ))
  local right_edge=$(( start + TLEN ))
  local right_pad=$(( right_edge < COLS ? COLS - right_edge : 0 ))
  local out
  out=$(printf "%*s%s%*s" "$left_pad" "" "$sprite" "$right_pad" "")
  printf "%s" "${out:0:COLS}"
}

printf "%s\n%s\n%s\n%s" \
  "$(render "$l1")" \
  "$(render "$l2")" \
  "$(render "$l3")" \
  "$(render "$l4")"


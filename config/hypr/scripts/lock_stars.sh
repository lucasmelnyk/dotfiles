#!/usr/bin/env bash

frames=(
"      ·       ✦
   ✦        ·
        ·         ✦"

"   ✦       ·
        ·        ✦
     ·         ✦"

"        ·        ✦
   ·       ✦
     ✦         ·"
)

i=$(( $(date +%s) % ${#frames[@]} ))
printf "%s" "${frames[$i]}"


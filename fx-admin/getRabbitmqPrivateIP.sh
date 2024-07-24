#!/bin/bash

set -e

eval "$(jq -r '@sh "URL=\(.url)"')"
url="$URL"

output=$(dig +short $(echo $url:5671 | cut -d'/' -f3 | cut -d':' -f1) | grep -v '\\.$')
IP=$(echo "$output" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | tail -n 1)
jq -n --arg IP "$IP" '{"ip":$IP}'
#!/bin/bash
website_url=$1
methods="methods.txt"

result_dir="$(dirname "$0")/../results"
mkdir -p "$result_dir"

base_name=$(echo "$website_url" | sed 's|https\?://||' | sed 's|/|_|g')
result_file="${result_dir}/${base_name}_HTTP_scan_results.txt" 

counter=1
while [[ -e "$result_file" ]]; do
    result_file="${result_dir}/${base_name}_HTTP_scan_results(${counter}).txt"
    ((counter++))
done

> "$result_file"

while IFS= read -r line; do
    echo "method: $line"
    scan=$(curl -s -o /dev/null -I -w "%{http_code}" -X $line "$website_url")
    printf "$scan"
    echo "$line : $scan" >> "$result_file"
    printf '\n'
done < "$methods"

safe_status_codes="200" "404" "501"

while IFS= read -r result; do
    status_code=$(echo "$result" | awk '{print $NF}')

    found=false
    for code in "${safe_status_codes[@]}"; do
        if [[ "$status_code" == "$code" ]]; then
            found=true
            break
        fi
    done
 
    if [[ "$found" == false ]]; then
        echo "other status codes: $result"
    fi
done < "$result_file"

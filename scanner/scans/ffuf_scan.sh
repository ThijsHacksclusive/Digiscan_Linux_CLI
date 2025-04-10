#!/bin/bash

website_url=$1
result_dir="$(dirname "$0")/../results"
mkdir -p "$result_dir"

base_name=$(echo "$website_url" | sed 's|https\?://||' | sed 's|/|_|g')
result_file="${result_dir}/${base_name}_FUZZ_scan_results.csv"

counter=1
while [[ -e "$result_file" ]]; do
    result_file="${result_dir}/${base_name}_FUZZ_scan_results(${counter}).csv"
    ((counter++))
done

WORDLIST="wordlist.txt"
TEMP_OUTPUT_FILE="temp_results.csv"
OUTPUT_FILE="$result_file"
FUZZ_URL="$website_url/FUZZ"

ffuf -u "$FUZZ_URL" -rate 30 -w "$WORDLIST" -of csv -o "$TEMP_OUTPUT_FILE"

MOST_COMMON_CODES=$(tail -n +2 "$TEMP_OUTPUT_FILE" \
    | awk -F',' '{count[$5]++} END {for (c in count) print count[c], c}' \
    | sort -nr | head -n 2 | awk '{print $2}' | paste -sd "," -)

MOST_COMMON_LENGTHS=$(tail -n +2 "$TEMP_OUTPUT_FILE" \
    | awk -F',' '{count[$6]++} END {for (c in count) print count[c], c}' \
    | sort -nr | head -n 2 | awk '{print $2}' | paste -sd "," -)

echo "🔍 Filtering most common status codes: $MOST_COMMON_CODES"
echo "🔍 Filtering most common content lengths: $MOST_COMMON_LENGTHS"

ffuf -u "$FUZZ_URL" -w "$WORDLIST" -rate 30 -of csv -o "$OUTPUT_FILE" -e .asp,.csv,.php,.html,.txt -fc "$MOST_COMMON_CODES" -fs "$MOST_COMMON_LENGTHS"

rm "$TEMP_OUTPUT_FILE"

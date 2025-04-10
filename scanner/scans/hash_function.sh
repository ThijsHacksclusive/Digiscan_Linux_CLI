#!/bin/bash
# Usage: ./hash_function.sh csv1.csv csv2.csv

if [ $# -lt 2 ]; then
    echo "Usage: $0 csv1.csv csv2.csv"
    exit 1
fi

csv1="$1"
csv2="$2"

# Helper function to trim
trim() {
    echo "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# Read the assessment headers from csv2
IFS=';' read -r _ header_goed header_voldoende header_onvoldoende < "$csv2"
header_goed=$(trim "$header_goed")
header_voldoende=$(trim "$header_voldoende")
header_onvoldoende=$(trim "$header_onvoldoende")

# Lookup function for assessment
lookup_assessment() {
    local target="$1"
    local result="Not found"

    while IFS=';' read -r func good voldoende onvoldoende; do
        func_norm=$(echo "$func" | tr -d '-' | xargs)
        if [[ "$func_norm" == "$target" ]]; then
            if [[ "$good" == "X" ]]; then
                result="$header_goed"
            elif [[ "$voldoende" == "X" ]]; then
                result="$header_voldoende"
            elif [[ "$onvoldoende" == "X" ]]; then
                result="$header_onvoldoende"
            fi
            break
        fi
    done < <(tail -n +2 "$csv2")

    echo "$result"
}

echo "Processing results..."
echo "------------------------------------------"

# Process each matching line in csv1
grep 'cert_signatureAlgorithm' "$csv1" | while IFS=',' read -r id ip finding cve cwe; do
    id=$(echo "$id" | tr -d '"' | xargs)
    ip=$(echo "$ip" | tr -d '"' | xargs)
    finding=$(echo "$finding" | tr -d '"' | xargs)

    # Extract and normalize hash
    hash=$(echo "$finding" | grep -o -E 'SHA-?[0-9]+')
    if [ -z "$hash" ]; then
        echo "ID: $id | IP: $ip | No valid hash found."
        continue
    fi
    hash_normalized=$(echo "$hash" | tr -d '-' | xargs)

    # Lookup assessment
    assessment=$(lookup_assessment "$hash_normalized")

    echo "ID: $id | IP: $ip | Finding: $finding | Extracted: $hash_normalized | Assessment: $assessment"
done

echo "------------------------------------------"

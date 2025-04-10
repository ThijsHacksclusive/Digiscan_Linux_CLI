#!/bin/bash

cd testssl_results_csvverzameling || exit 1

output="../../results/combined.csv"

# Force the correct header
echo "finding,ip,result" > "$output"

# Append all CSV contents, skipping their headers
tail -n +2 -q *.csv >> "$output"

# Deduplicate combined.csv (remove exact duplicates)
sort -u "$output" -o "$output"

# Show the combined output
echo -e "\n\033[1mCombined CSV:\033[0m"
while IFS=',' read -r finding ip result; do
    # Skip the header line
    if [[ "$finding" == "finding" ]]; then
        continue
    fi

    # Match result and color
    case "$result" in
        "Goed") color="\033[0;32m" ;;
        "Voldoende") color="\033[1;33m" ;;
        "Uit te faseren") color="\033[0;35m" ;;
        "Onvoldoende") color="\033[0;31m" ;;
        *) color="\033[0m" ;;
    esac

    # Print formatted and colorized row
    printf "%-50s %-50s ${color}%-50s\033[0m\n" "$finding" "$ip" "$result"
done < "$output"

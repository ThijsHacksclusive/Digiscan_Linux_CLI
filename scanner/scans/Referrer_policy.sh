#!/usr/bin/env bash

input_file="filtered_output.csv"
output_file="testssl_results_csvverzameling/Referrer_policy_results.csv"

OS="${2:-unknown}"  # Optional OS passthrough
echo "Running Referrer Policy check on OS: $OS"
echo "Input file: $input_file"
echo "Output file: $output_file"

# CSV header
echo "Referrer Policy,ip,result" > "$output_file"

# Filter and process Referrer-Policy rows
grep '"Referrer-Policy"' "$input_file" | while IFS=',' read -r id fqdn_ip finding cve cwe; do
  clean_finding=$(echo "$finding" | tr -d '"')
  ip=$(echo "$fqdn_ip" | tr -d '"')

  if [[ "$clean_finding" == same-origin* ]]; then
    result="Goed"
  elif [[ "$clean_finding" == no-referrer* ]]; then
    result="Goed"
  else
    result="Onvoldoende"
  fi

  echo "Referrer Policy is $clean_finding,$ip,$result" >> "$output_file"
done

cat "$output_file"

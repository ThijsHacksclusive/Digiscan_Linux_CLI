#!/usr/bin/env bash

input_file="filtered_output.csv"
output_file="testssl_results_csvverzameling/ocsp_stapling_results.csv"

OS="${2:-unknown}"  # Optional OS passthrough
echo "Running OCSP stapling check on OS: $OS"
echo "Input file: $input_file"
echo "Output file: $output_file"

# CSV header
echo "OCSP stapling,ip,result" > "$output_file"

# Filter and process OCSP_stapling rows
grep '^"OCSP_stapling' "$input_file" | while IFS=',' read -r id fqdn_ip finding cve cwe; do
  clean_finding=$(echo "$finding" | tr -d '"')
  ip=$(echo "$fqdn_ip" | tr -d '"')

  if [[ "$clean_finding" == "offered" ]]; then
    result="Goed"
  elif [[ "$clean_finding" == "not offered" ]]; then
    result="Voldoende"
  else
    result="Onvoldoende"
  fi

  echo "OCSP stapling is $clean_finding,$ip,$result" >> "$output_file"
done

cat "$output_file"

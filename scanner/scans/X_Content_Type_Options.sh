#!/usr/bin/env bash

input_file="filtered_output.csv"
output_file="testssl_results_csvverzameling/x_content_type_options_results.csv"

echo "Input file: $input_file"
echo "Output file: $output_file"

echo "X-Content-Type-Options,ip,result" > "$output_file"

# Track if we found any relevant lines
found_any=false

# Filter and process matching lines
grep '"X-Content-Type-Options"' "$input_file" | while IFS=',' read -r id fqdn_ip finding cve cwe; do
  found_any=true
  clean_finding=$(echo "$finding" | tr -d '"')
  ip=$(echo "$fqdn_ip" | tr -d '"')

  if [[ "$clean_finding" == "nosniff" ]]; then
    result="Goed"
  else
    result="Onvoldoende"
  fi

  echo "X-Content-Type-Options found: $clean_finding,$ip,$result" >> "$output_file"
done

# Handle case where nothing was found
if ! grep -q '"X-Content-Type-Options"' "$input_file"; then
  echo "No X-Content-Type-Options found,N.V.T,Onvoldoende" >> "$output_file"
fi

cat "$output_file"

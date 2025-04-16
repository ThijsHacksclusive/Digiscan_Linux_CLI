#!/usr/bin/env bash

input_file="filtered_output.csv"
output_file="testssl_results_csvverzameling/cert_keysize_results.csv"

echo "Input file: $input_file"
echo "Output file: $output_file"

# CSV header
echo "RSA,ip,result" > "$output_file"

# Filter and process cert_keySize rows
grep '^"cert_keySize' "$input_file" | while IFS=',' read -r id fqdn_ip finding cve cwe; do
  bit_size=$(echo "$finding" | grep -oE 'RSA [0-9]+' | awk '{print $2}')
  ip=$(echo "$fqdn_ip" | tr -d '"')

  # Skip if no RSA size found
  [[ -z "$bit_size" ]] && continue

  if (( bit_size >= 3072 )); then
    result="Goed"
  elif (( bit_size >= 2048 )); then
    result="Voldoende"
  else
    result="Onvoldoende"
  fi

  echo "RSA Keysize: $bit_size,$ip,$result" >> "$output_file"
done

cat "$output_file"

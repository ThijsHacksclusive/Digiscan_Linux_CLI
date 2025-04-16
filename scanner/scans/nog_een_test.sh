#!/usr/bin/env bash

input_file=$(cat /tmp/latest_testssl_csv)
output_file="filtered_output.csv"

echo "Using input: $input_file"

# Define ID keywords: exact matches and prefixes
declare -a exact_ids=(
  "X-Content-Type-Options"
  "Content-Security-Policy"
  "Referrer-Policy"
  "secure_renego"
  "secure_client_renego"
  "FS_ECDHE_curves"
  "DH_groups"
  "Cache-Control"
)

declare -a prefix_ids=(
  "cert_keySize"
  "cert_signatureAlgorithm"
  "OCSP_stapling"
)

# Output header
echo '"id","fqdn/ip","finding","cve","cwe"' > "$output_file"

# Loop through lines in CSV (skip header)
tail -n +2 "$input_file" | while IFS=',' read -r id fqdn_ip port severity finding cve cwe; do
  clean_id=$(echo "$id" | tr -d '"')

  matched=0

  # Check exact matches
  for match in "${exact_ids[@]}"; do
    [[ "$clean_id" == "$match" ]] && matched=1 && break
  done

  # Check prefix matches
  if [[ $matched -eq 0 ]]; then
    for prefix in "${prefix_ids[@]}"; do
      if [[ "$clean_id" == "$prefix"* ]]; then
        matched=1
        break
      fi
    done
  fi

  if [[ $matched -eq 1 ]]; then
    echo "$id,$fqdn_ip,$finding,$cve,$cwe" >> "$output_file"
  fi
done

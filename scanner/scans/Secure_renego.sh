#!/usr/bin/env bash

input_file="filtered_output.csv"
output_file_serego="testssl_results_csvverzameling/Secure_renego_results.csv"
output_file_seclrego="testssl_results_csvverzameling/Secure_client_renego_results.csv"

OS="${2:-unknown}"  # Optional OS passthrough
echo "Running Secure Renegotiation checks on OS: $OS"
echo "Input file: $input_file"
echo "Output files: $output_file_serego and $output_file_seclrego"

# Header for secure renegotiation
echo "Secure Renegotiation,ip,result" > "$output_file_serego"

# Process secure_renego entries
grep '"secure_renego"' "$input_file" | while IFS=',' read -r id fqdn_ip finding cve cwe; do
  clean_finding=$(echo "$finding" | tr -d '"')
  ip=$(echo "$fqdn_ip" | tr -d '"')

  if [[ "$clean_finding" == supported* ]]; then
    result="Goed"
  else
    result="Onvoldoende"
  fi
  echo "Secure Renegotiation $clean_finding,$ip,$result" >> "$output_file_serego"
done

# Header for secure client renegotiation
echo "Secure client Renegotiation,ip,result" > "$output_file_seclrego"

# Process secure_client_renego entries
grep '"secure_client_renego"' "$input_file" | while IFS=',' read -r id fqdn_ip finding cve cwe; do
  clean_finding=$(echo "$finding" | tr -d '"')
  ip=$(echo "$fqdn_ip" | tr -d '"')

  if [[ "$clean_finding" == "not vulnerable" ]]; then
    result="Goed"
  else
    result="Onvoldoende"
  fi

  echo "Secure client Renegotiation $clean_finding,$ip,$result" >> "$output_file_seclrego"
done

# Show results
cat "$output_file_seclrego"
cat "$output_file_serego"

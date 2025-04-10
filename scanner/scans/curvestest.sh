#!/usr/bin/env bash

input_file="filtered_output.csv"
check_file="testssl_eisen/Elliptic_curves.csv"
output_file="testssl_results_csvverzameling/curve_results.csv"

OS="${2:-unknown}"  # Optional second argument for OS type
echo "Running curve test on OS: $OS"
echo "Input file: $input_file"
echo "Output file: $output_file"

echo "curve,ip,result" > "$output_file"

# Normalize curve names
normalize_curve() {
  local curve="$1"
  case "$curve" in
    X25519) echo "curve 25519" ;;
    X448) echo "curve 448" ;;
    prime256v1) echo "secp256r1" ;;
    prime521v1) echo "secp521r1" ;;
    *) echo "$curve" ;;
  esac
}

# Get classification result from check file
get_result() {
  local norm_curve="$1"
  while IFS=';' read -r name goed uit_te_faseren onvoldoende; do
    if [[ "$name" == "$norm_curve" ]]; then
      if [[ "$goed" =~ [Xx] ]]; then
        echo "Goed"
      elif [[ "$uit_te_faseren" =~ [Xx] ]]; then
        echo "Uit te faseren"
      elif [[ "$onvoldoende" =~ [Xx] ]]; then
        echo "Onvoldoende"
      else
        echo "Onvoldoende"
      fi
      return
    fi
  done < <(tail -n +2 "$check_file")
  echo "Onvoldoende"  # Default if not found
}

# Filter only FS_ECDHE_curves rows
grep '"FS_ECDHE_curves"' "$input_file" | while IFS=',' read -r id fqdn_ip finding cve cwe; do
  curves=$(echo "$finding" | tr -d '"' | tr ' ' '\n')
  ip="${fqdn_ip//\"/}"   

  while IFS= read -r curve; do
    [[ -z "$curve" ]] && continue
    norm_curve=$(normalize_curve "$curve")
    result=$(get_result "$norm_curve")
    echo "$curve,$ip,$result" >> "$output_file"
  done <<< "$curves"
done

cat "$output_file"

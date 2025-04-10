#!/usr/bin/env bash

csv_file="filtered_output.csv"
output_file="testssl_results_csvverzameling/CSP_findings.csv"

OS="${2:-unknown}"  # Passed OS or fallback
echo "Running CSP check on OS: $OS"
echo "Reading from: $csv_file"
echo "Writing to: $output_file"

# CSV header
echo "finding,ip,result" > "$output_file"

check_src() {
    local directive_line="$1"
    local directive_name="${directive_line%% *}"
    local sources="${directive_line#* }"
    sources=$(echo "$sources" | xargs)  # Trim whitespace

    for token in $sources; do
        if [[ "$token" == http://* ]]; then
            echo "$directive_name contains insecure URL,Onvoldoende"
            return
        fi
    done

    echo "$directive_name,Goed"
}

awk -F',' '$1 ~ /"Content-Security-Policy"/ {print $2 "," $3}' "$csv_file" | while IFS=',' read -r fqdn_ip raw_finding; do
    ip="${fqdn_ip//\"/}"           
    finding="${raw_finding//\"/}"     

    IFS=';' read -ra directives <<< "$finding"
    for directive in "${directives[@]}"; do
        directive=$(echo "$directive" | xargs)
        dname="${directive%% *}"

        if [[ "$dname" == *-src ]]; then
            result=$(check_src "$directive")
            finding_name="${result%%,*}"
            finding_result="${result#*,}"
            echo "$finding_name,$ip,$finding_result" >> "$output_file"
        fi
    done

    # Check for unsafe-inline
    if [[ "$finding" == *"'unsafe-inline'"* ]]; then
        if [[ "$finding" == *"nonce"* ]]; then
            echo "'unsafe-inline' with nonce,$ip,Goed" >> "$output_file"
        else
            echo "'unsafe-inline' without nonce,$ip,Onvoldoende" >> "$output_file"
        fi
    fi

    # Check for unsafe-eval
    if [[ "$finding" == *"'unsafe-eval'"* ]]; then
        echo "'unsafe-eval',$ip,Onvoldoende" >> "$output_file"
    fi

    # Check for upgrade-insecure-requests
    if [[ "$finding" == *"upgrade-insecure-requests"* ]]; then
        echo "upgrade-insecure-requests,$ip,Goed" >> "$output_file"
    else
        echo "upgrade-insecure-requests,$ip,Onvoldoende" >> "$output_file"
    fi
done

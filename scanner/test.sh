#!/usr/bin/env bash

website_url="$1"
scan_type="$2"

cd "$(dirname "$0")/scans" || exit 1

run_parallel() {
    parallel --lb --jobs 0 ::: "$@"
}

case $scan_type in 
    1) 
        run_parallel \
            "echo $website_url && bash ./testssl_scans.sh $website_url" \
            "echo $website_url && bash ./HTTP_method_scanner.sh $website_url" \
            "echo $website_url && bash ./portscan.sh $website_url"
        ;;
    2)
        bash ./testssl_scans.sh "$website_url"
        bash ./nog_een_test.sh "$website_url"
        bash ./CSP_check.sh
        bash ./curvestest.sh
        bash ./ff_groupstest.sh
        bash ./maxage.sh
        bash ./OCSP_stapling_check.sh
        bash ./Referrer_policy.sh
        bash ./RSA_keysize_check.sh
        bash ./Secure_renego.sh
        bash ./X_Content_Type_Options.sh
        bash ./alles_bij_elkaar.sh
        ;;
    3)
        bash ./HTTP_method_scanner.sh "$website_url"
        ;;
    4)
        bash ./portscan.sh "$website_url"
        ;;
    5)
        run_parallel \
            "bash ./ffuf_scan.sh $website_url" \
            "bash ./webanalyse.sh $website_url"
        ;;
    6)
        cd testssl_eisen || exit 1
        bash ./csv_editor.sh
        ;;
    *)
        echo "Invalid scan type: $scan_type"
        ;;
esac

#!/usr/bin/env bash

website_url="$1"
scan_type="$2"
tmux
case $scan_type in
    1)
        # Open new tmux windows for each scan command
        tmux new-window -n "TestSSL" "cd scans && echo $website_url && bash ./testssl_scans.sh $website_url" &
        tmux new-window -n "HTTP_Method" "cd scans && echo $website_url && bash ./HTTP_method_scanner.sh $website_url && read -p 'Press enter to quit'" &
        tmux new-window -n "PortScan" "cd scans && echo $website_url && bash ./portscan.sh $website_url"
        ;;
    2)
        tmux new-window -n "FullScan" "cd scans && echo $website_url && bash ./testssl_scans.sh $website_url && ./nog_een_test.sh $website_url && ./CSP_check.sh && ./curvestest.sh && ./ff_groupstest.sh && ./maxage.sh && ./OCSP_stapling_check.sh && ./Referrer_policy.sh && ./RSA_keysize_check.sh && ./Secure_renego.sh && ./X_Content_Type_Options.sh && ./alles_bij_elkaar.sh && read -p 'Press enter to quit'"
        ;;
    3)
        tmux new-window -n "HTTP_Scanner" "cd scans && echo $website_url && bash ./HTTP_method_scanner.sh $website_url && read -p 'Press enter to quit'"
        ;;
    4)
        tmux new-window -n "PortScanner" "cd scans && echo $website_url && bash ./portscan.sh $website_url && read -p 'Press enter to quit'"
        ;;
    5)
        tmux new-window -n "FFUF_Scan" "cd scans && echo $website_url && bash ./ffuf_scan.sh $website_url && read -p 'Press enter to quit'" &
        tmux new-window -n "WebAnalyse" "cd scans && echo $website_url && bash ./webanalyse.sh $website_url && read -p 'Press enter to quit'"
        ;;
    6)
        tmux new-window -n "CSV_Edit" "cd scans/testssl_eisen && bash ./csv_editor.sh && read -p 'Press enter to quit'"
        ;;
    *)
        echo "Invalid scan type: $scan_type"
        ;;
esac


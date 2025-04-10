#!/usr/bin/env bash

website_url="$1"
scan_type="$2"
OS="$3"  # Passed from main script

# Fallback if not passed
if [ -z "$OS" ]; then
    OS="unknown"
fi

launch_cmd() {
    case "$OS" in
        macos)
            osascript -e "tell application \"Terminal\" to do script \"$cmd\""
            ;;
        *)
            continue
    esac
}

case "$OS" in
    wsl)
        case $scan_type in 
            1) 
                wt.exe --window last new-tab bash -ic "cd scans && echo $website_url && bash ./testssl_scans.sh $website_url" &
                wt.exe --window last new-tab bash -ic "cd scans && echo $website_url && bash ./HTTP_method_scanner.sh $website_url && read -p 'press enter to quit'" &
                wt.exe --window last new-tab bash -ic "cd scans && echo $website_url && bash ./portscan.sh $website_url"
                ;;
            2)
                wt.exe --window last new-tab bash -ic "cd scans && echo $website_url && bash ./testssl_scans.sh $website_url && ./nog_een_test.sh $website_url && ./CSP_check.sh && ./curvestest.sh && ./ff_groupstest.sh  && ./maxage.sh && ./OCSP_stapling_check.sh  && ./Referrer_policy.sh && ./RSA_keysize_check.sh && ./Secure_renego.sh && ./X_Content_Type_Options.sh && ./alles_bij_elkaar.sh && read -p 'press enter to quit'"
                ;;
            3)
                wt.exe --window last new-tab bash -ic "cd scans && echo $website_url && bash ./HTTP_method_scanner.sh $website_url && read -p 'press enter to quit'"
                ;;
            4)
                wt.exe --window last new-tab bash -ic "cd scans && echo $website_url && bash ./portscan.sh $website_url && read -p 'press enter to quit'"
                ;;
            5)
                wt.exe --window last new-tab bash -ic "cd scans && echo $website_url && bash ./ffuf_scan.sh $website_url && read -p 'press enter to quit'" &
                wt.exe --window last new-tab bash -ic "cd scans && echo $website_url && bash ./webanalyse.sh $website_url && read -p 'press enter to quit'"
                ;;
            6)
                wt.exe --window last new-tab bash -ic "cd scans/testssl_eisen && bash ./csv_editor.sh && read -p 'press enter to quit'"
                ;;
            *)
                echo "Invalid scan type: $scan_type"
                ;;
        esac
        ;;
    macos)
        case "$scan_type" in 
            1) 
                launch_cmd "cd scans && echo $website_url && bash ./testssl_scans.sh $website_url" &
                launch_cmd "cd scans && echo $website_url && bash ./HTTP_method_scanner.sh $website_url" &
                launch_cmd "cd scans && echo $website_url && bash ./portscan.sh $website_url"
                ;;
            2)
                cmd="cd Digiscan && cd scanner && cd scans && echo $website_url && bash ./testssl_scans.sh $website_url && ./nog_een_test.sh $website_url && ./CSP_check.sh && ./curvestest.sh && ./ff_groupstest.sh && ./maxage.sh && ./OCSP_stapling_check.sh && ./Referrer_policy.sh && ./RSA_keysize_check.sh && ./Secure_renego.sh && ./X_Content_Type_Options.sh && ./alles_bij_elkaar.sh"
                if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then 
                    ttab "cd scans && echo $website_url && bash ./testssl_scans.sh $website_url && ./nog_een_test.sh $website_url && ./CSP_check.sh && ./curvestest.sh && ./ff_groupstest.sh && ./maxage.sh && ./OCSP_stapling_check.sh && ./Referrer_policy.sh && ./RSA_keysize_check.sh && ./Secure_renego.sh && ./X_Content_Type_Options.sh && ./alles_bij_elkaar.sh"
                elif [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then 
                    osascript <<EOF
tell application "iTerm2"
    tell current window
        create tab with default profile
        tell current session
            write text "$cmd"
        end tell
    end tell
end tell
EOF
                fi
                ;;
            3)
                cmd="cd Digiscan && cd scanner && cd scans && echo $website_url && bash ./HTTP_method_scanner.sh $website_url"
                if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then 
                    ttab "cd scans && echo $website_url && bash ./HTTP_method_scanner.sh $website_url"
                elif [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then 
                    osascript <<EOF
tell application "iTerm2"
    tell current window
        create tab with default profile
        tell current session
            write text "$cmd"
        end tell
    end tell
end tell
EOF
                fi
                ;;
            4)
                cmd="cd Digiscan && cd scanner && cd scans && echo $website_url && bash ./portscan.sh $website_url"
                if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then 
                    ttab "cd scans && echo $website_url && bash ./portscan.sh $website_url"
                elif [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then 
                    osascript <<EOF
tell application "iTerm2"
    tell current window
        create tab with default profile
        tell current session
            write text "$cmd"
        end tell
    end tell
end tell
EOF
                fi
                ;;
            5)
                launch_cmd "cd Digiscan && cd scanner && cd scans && echo $website_url && bash ./ffuf_scan.sh $website_url" &
                launch_cmd "cd Digiscan && cd scanner && cd scans && echo $website_url && bash ./webanalyse.sh $website_url"
                ;;
            6)
                launch_cmd "cd Digiscan && cd scanner && cd scans/testssl_eisen && bash ./csv_editor.sh"
                ;;
            *)
                echo "❌ Invalid scan type: $scan_type"
                ;;
        esac
        ;;
    *)
        # Default fallback (Windows Terminal if available)
        if command -v wt.exe &> /dev/null; then
            wt.exe --window last new-tab bash -ic "$cmd"
        else
            echo "⚠️ No GUI terminal found. Running inline:"
            bash -c "$cmd"
        fi
        ;;
esac


#!/usr/bin/env bash

# Function to process website URL
process_website() {
    website_url=$1

    echo "Website URL: $website_url"

    for choice in "${choices_array[@]}"; do
        case $choice in
            1) echo "- Option 1 (Executing external script...)"
               bash ./test.sh "$website_url" 1 
               ;;
            2) echo "- Option 2  (Executing external script...)"
               bash ./test.sh "$website_url" 2 
               ;;
            3) echo "- Option 3 (Executing external script...)"
               bash ./test.sh "$website_url" 3 
               ;;
            4) echo "- Option 4 (Executing external script...)"
               bash ./test.sh "$website_url" 4 
               ;;
            5) echo "- Option 5 (Executing external script...)"
               bash ./test.sh "$website_url" 5 
               ;;
            *) echo "Invalid choice: $choice"
               ;;
        esac
    done
}

# --- Main Program ---


echo "Select options (separate multiple choices with spaces):"
echo "1) HTTP Methods (Runs external script)"
echo "2) testssl"
echo "3) Port scan"
echo "4) Option 4"
echo "5) Option 5 ffuf"
echo "6) Edit Audit Settings (does NOT require a website)"
prinft "Enter your choices: "
read choices

choices_array=($choices)

# Handle Option 6 (no website required)
if [[ " ${choices_array[*]} " == *" 6 "* ]]; then
    echo "- Option 6 (Executing external script...)"
    bash ./test.sh "https://dummy.url" 6 

    # Remove 6 from the choices_array
    new_choices_array=()
    for choice in "${choices_array[@]}"; do
        if [[ "$choice" != "6" ]]; then
            new_choices_array+=("$choice")
        fi
    done
    choices_array=("${new_choices_array[@]}")
fi

# Prompt for URLs if any other options are selected
if [[ ${#choices_array[@]} -gt 0 ]]; then
    url_list=()

    echo "Enter website URLs (any format), one per line. Type 'done' when finished."
    while true; do
        printf "Enter a website URL: "
        read website_url
        if [[ "$website_url" == "done" ]]; then
            break
        fi
        url_list+=("$website_url")
    done

    for website_url in "${url_list[@]}"; do
        process_website "$website_url"
    done
fi

website_url=$1
result_dir="$(dirname "$0")/../results"
mkdir -p "$result_dir"

base_name=$(echo "$website_url" | sed 's|https\?://||' | sed 's|/|_|g')
result_file="${result_dir}/${base_name}_Webanalyse_scan_results.csv"

counter=1
while [[ -e "$result_file" ]]; do
    result_file="${result_dir}/${base_name}_Webanalyse_scan_results(${counter}).csv"
    ((counter++))
done

webanalyze -host $website_url -crawl 5 -output csv -search -redirect true  >> $result_file
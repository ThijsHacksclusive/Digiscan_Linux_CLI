#!/bin/bash

website_url=$1
website_url=${website_url#https://}


result_dir="$(dirname "$0")/../results"
mkdir -p "$result_dir"

base_name=$(echo "$website_url" | sed 's|https\?://||' | sed 's|/|_|g')
result_file_tcp="${result_dir}/${base_name}_tcp_scan_results.txt" 
result_file_udp="${result_dir}/${base_name}_udp_scan_results.txt"

counter_tcp=1
while [[ -e "$result_file_tcp" ]]; do
    result_file_tcp="${result_dir}/${base_name}_tcp_scan_results(${counter_tcp}).txt"
    ((counter_tcp++))
done

counter_udp=1
while [[ -e "$result_file_udp" ]]; do
    result_file_udp="${result_dir}/${base_name}_udp_scan_results(${counter_udp}).txt"
    ((counter_udp++))
done

nmap -sT -p- $website_url -oN $result_file_tcp
sudo nmap $website_url --resolve-all --top-ports 1000 -Pn -d -v --min-rate 10000 -sU -sV -T4 --max-retries 1 -oN $result_file_udp
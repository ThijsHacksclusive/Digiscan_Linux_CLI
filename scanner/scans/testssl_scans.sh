#!/usr/bin/env bash

website_url="$1"

base_name=$(echo "$website_url" | sed 's|https\?://||' | sed 's|/|_|g')

result_dir="$(dirname "$0")/../results"
mkdir -p "$result_dir"

result_file_csv="${result_dir}/${base_name}_testssl_scan.csv"

counter_csv=1
while [[ -e "$result_file_csv" ]]; do
    result_file_csv="${result_dir}/${base_name}_testssl_scan(${counter_csv}).csv"
    ((counter_csv++))
done

testssl_dir="$(dirname "$0")/../testssl.sh"
"$testssl_dir/testssl.sh" --quiet --show-each --color 3 -oC "$result_file_csv" "$website_url"

# ----- Filtering ciphers -----
csv_file="$result_file_csv"
output_csv="extracted_tls_ciphers.csv"
echo 'ID,Target,TLS suite' > "$output_csv"

awk -F',' '
BEGIN { OFS="," }
NR > 1 {
    gsub(/^"|"$/, "", $1)
    gsub(/^"|"$/, "", $2)
    gsub(/^"|"$/, "", $5)
    if ($1 ~ /^cipher-tls/) {
        n = split($5, words, /[[:space:]]+/)
        cipher = ""
        for (i = n; i > 0; i--) {
            if (words[i] ~ /^TLS_/) {
                cipher = words[i]
                break
            }
        }
        if (cipher != "") {
            print $1, $2, cipher
        }
    }
}
' "$csv_file" >> "$output_csv"

echo "Filtered TLS cipher data extracted to: $output_csv"

# ----- Checking ciphers -----
input_csv="extracted_tls_ciphers.csv"
output_csv="processed_tls_ciphers.csv"
echo "ID,Target,TLS_version,sleuteluitwisseling,certificaatverificatie,bulkversleuteling,hashing" > "$output_csv"

tail -n +2 "$input_csv" | while IFS=',' read -r id target tls_suite; do
    if [[ "$id" == cipher-tls1_2* ]]; then
        if [[ $tls_suite =~ ^TLS_([^_]+)_([^_]+)_WITH_(.+)_([^_]+)$ ]]; then
            sleuteluitwisseling="${BASH_REMATCH[1]}"
            certificaatverificatie="${BASH_REMATCH[2]}"
            bulkversleuteling="${BASH_REMATCH[3]}"
            hashing="${BASH_REMATCH[4]}"
            bulkversleuteling=$(echo "$bulkversleuteling" | sed 's/_$//')
            echo "$id,$target,TLS1.2,$sleuteluitwisseling,$certificaatverificatie,$bulkversleuteling,$hashing" >> "$output_csv"
        fi
    elif [[ "$id" == cipher-tls1_3* ]]; then
        if [[ $tls_suite =~ ^TLS_([^_]+_[^_]+_[^_]+)_(SHA[0-9]+)$ ]]; then
            bulkversleuteling="${BASH_REMATCH[1]}"
            hashing="${BASH_REMATCH[2]}"
        elif [[ $tls_suite =~ ^TLS_([^_]+_[^_]+)_(SHA[0-9]+)$ ]]; then
            bulkversleuteling="${BASH_REMATCH[1]}"
            hashing="${BASH_REMATCH[2]}"
        elif [[ $tls_suite =~ ^TLS_SHA(256|384)_SHA(256|384)$ ]]; then
            bulkversleuteling="None"
            hashing="SHA${BASH_REMATCH[2]}"
        else
            bulkversleuteling="Unknown"
            hashing="Unknown"
        fi
        bulkversleuteling=$(echo "$bulkversleuteling" | sed 's/_$//')
        echo "$id,$target,TLS1.3,,,$bulkversleuteling,$hashing" >> "$output_csv"
    fi
done

echo "Processed data saved to: $output_csv"

# ----- Classify ciphers -----
INPUT_FILE="processed_tls_ciphers.csv"
OUTPUT_FILE="checked_tls_ciphers.csv"

KEYEX_FILE="testssl_eisen/Sleuteluitwisseling_Algoritmes.csv"
CERT_FILE="testssl_eisen/Certificaatverificatie_algoritmes.csv"
BULK_FILE="testssl_eisen/Algoritmes_bulkversleuteling.csv"
HASH_FILE="testssl_eisen/Hashfuncties_bulkversleuteling.csv"

mkdir -p tmp_lookups

parse_lookup() {
    input="$1"
    output="$2"
    tail -n +2 "$input" | while IFS=';' read -r name goed vold uitf onv; do
        [[ -z "$name" ]] && continue
        norm_name=$(echo "$name" | tr '[:lower:]' '[:upper:]' | tr -d ' _-' | tr -dc '[:alnum:]')
        if [[ "$goed" =~ [Xx] ]]; then score="Goed"
        elif [[ "$vold" =~ [Xx] ]]; then score="Voldoende"
        elif [[ "$uitf" =~ [Xx] ]]; then score="Uit te faseren"
        elif [[ "$onv" =~ [Xx] ]]; then score="Onvoldoende"
        else score="Onvoldoende"
        fi
        echo "$norm_name:$score" >> "$output"
    done
}

parse_lookup "$KEYEX_FILE" tmp_lookups/keyex.txt
parse_lookup "$CERT_FILE" tmp_lookups/cert.txt
parse_lookup "$BULK_FILE" tmp_lookups/bulk.txt
parse_lookup "$HASH_FILE" tmp_lookups/hash.txt

normalize() {
    echo "$1" | tr '[:lower:]' '[:upper:]' | tr -d ' _-' | tr -dc '[:alnum:]'
}

lookup_rating() {
    value=$(normalize "$1")
    file="$2"
    grep -E "^$value:" "$file" | cut -d':' -f2 | head -n 1
}

echo "ID,Target,TLS_version,sleuteluitwisseling,certificaatverificatie,bulkversleuteling,hashing" > "$OUTPUT_FILE"

first=true
while IFS=',' read -r id target tls keyex cert bulk hash; do
    if $first; then first=false; continue; fi

    tls_u=$(echo "$tls" | tr '[:lower:]' '[:upper:]')
    case "$tls_u" in
        TLS1.3) tls_rating="Goed" ;;
        TLS1.2) tls_rating="Voldoende" ;;
        TLS1.0|TLS1.1) tls_rating="Uit te faseren" ;;
        *) tls_rating="Onvoldoende" ;;
    esac

    if [[ "$tls_u" == "TLS1.3" ]]; then
        keyex_rating=""
        cert_rating=""
    else
        keyex_rating=$(lookup_rating "$keyex" tmp_lookups/keyex.txt)
        [[ -z "$keyex_rating" ]] && keyex_rating="Onvoldoende"

        cert_rating=$(lookup_rating "$cert" tmp_lookups/cert.txt)
        [[ -z "$cert_rating" ]] && cert_rating="Onvoldoende"
    fi

    bulk_rating=$(lookup_rating "$bulk" tmp_lookups/bulk.txt)
    [[ -z "$bulk_rating" ]] && bulk_rating="Onvoldoende"

    hash_rating=$(lookup_rating "$hash" tmp_lookups/hash.txt)
    [[ -z "$hash_rating" ]] && hash_rating="Onvoldoende"

    echo "$id,$target,$tls_rating,$keyex_rating,$cert_rating,$bulk_rating,$hash_rating" >> "$OUTPUT_FILE"
done < "$INPUT_FILE"

echo "✅ Done! Results saved to $OUTPUT_FILE"

rm -r tmp_lookups

score_weight() {
    case "$1" in
        Goed) echo 3 ;;
        Voldoende) echo 2 ;;
        "Uit te faseren") echo 1 ;;
        Onvoldoende) echo 0 ;;
        *) echo -1 ;;
    esac
}

MIN_RATING_FILE="${result_dir}/${base_name}_minimum_ratings.csv"
echo "ID,Target,Laagste_beoordeling" > "$MIN_RATING_FILE"

tail -n +2 "$OUTPUT_FILE" | while IFS=',' read -r id target tls keyex cert bulk hash; do
    lowest=""
    low_weight=99

    for score in "$tls" "$keyex" "$cert" "$bulk" "$hash"; do
        [[ -z "$score" ]] && continue 
        w=$(score_weight "$score")
        if (( w >= 0 && w < low_weight )); then
            low_weight=$w
            lowest="$score"
        fi
    done

    echo "$id,$target,$lowest" >> "$MIN_RATING_FILE"
done

echo "✅ Lowest-rating export saved to $MIN_RATING_FILE"

echo "$result_file_csv" > /tmp/latest_testssl_csv

rm processed_tls_ciphers.csv
rm checked_tls_ciphers.csv
rm extracted_tls_ciphers.csv

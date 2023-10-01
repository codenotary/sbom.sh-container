#!/usr/local/bin/bash

# Define the function sendsbom
sendsbom() {
    local sbom_file="/app/$1"
    if [[ -f "$sbom_file" ]]; then
        local output=$(curl -s -X POST -H "Content-Type: application/json" --data-binary "@$sbom_file" "$SBOM_SH_SERVER")
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to send SBOM to server."
            exit 1
        fi
        local document_id=$(echo "$output" | jq -r '.documentid')
        echo "$output" | jq -r '.ShareUrl'
        curl -sX POST "https://sbom.sh/sbomscore/$document_id" > /dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to initiate SBOM score calculation."
            exit 1
        fi
    else
        echo "Error: File '$sbom_file' not found."
        exit 1
    fi
}

process_output() {
    local output="$1"
    local command="$2"
    local vulnscan_flag="$3"
    local document_id=$(echo "$output" | jq -r '.documentid')
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to parse output from server."
        exit 1
    fi
    echo "$output" | jq -r '.ShareUrl'
    if [[ "$vulnscan_flag" == "vulnscan" && ! ("$command" == "grypefs" || "$command" == "grypeimage") ]]; then
        curl -sX POST "https://sbom.sh/vulnscan/$document_id" > /dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to initiate vulnerability scan."
            exit 1
        fi
        sleep 3
        curl -sX POST "https://sbom.sh/sbomscore/$document_id" > /dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to initiate SBOM score calculation."
            exit 1
        fi
    fi
}

run_scan() {
    local command="$1"
    local vulnscan_flag="$2"
    local args="$3"
    local scan_cmd=""
    case "$command" in
        trivyfs)
            scan_cmd="exec trivy fs /app -f cyclonedx --scanners vuln -q"
            ;;
        trivyimage)
            scan_cmd="exec trivy image $args -f cyclonedx --scanners vuln -q"
            ;;
        grypefs)
            scan_cmd="exec grype /app -o cyclonedx-json -q"
            ;;
        grypeimage)
            scan_cmd="exec grype registry:$args -o cyclonedx-json -q"
            ;;
        syftfs)
            scan_cmd="exec syft /app -o cyclonedx-json -q"
            ;;
        syftimage)
            scan_cmd="exec syft registry:$args -o cyclonedx-json -q"
            ;;
    esac
    local output=$(eval "$scan_cmd" | curl -sd @- "$SBOM_SH_SERVER" -H "Content-Type: application/json")
    process_output "$output" "$command" "$vulnscan_flag"
}

handle_command() {
    local command="$1"
    shift
    local vulnscan_flag=""
    if [[ "$1" == "vulnscan" ]]; then
        vulnscan_flag="vulnscan"
        shift
    fi
    local args="$@"
    run_scan "$command" "$vulnscan_flag" "$args"
}

case "$1" in
    sendsbom)
        shift
        sendsbom "$@"
        ;;
    trivyfs|trivyimage|grypefs|grypeimage|syftfs|syftimage)
        handle_command "$@"
        ;;
    *)
        echo "Usage:"
        echo "  $0 trivyfs [vulnscan] #make sure to map /app via -v"
        echo "  $0 trivyimage [vulnscan] [image-name]"
        echo "  $0 grypefs #make sure to map /app via -v"
        echo "  $0 grypeimage [image-name]"
        echo "  $0 syftfs #make sure to map /app via -v"
        echo "  $0 syftimage [vulnscan] [image-name]"
        echo "  $0 sendsbom [sbom-file-name] #make sure to map /app via -v"
        exit 1
        ;;
esac

#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  --client-id           Client ID for authentication (required)"
    echo "  --client-secret       Client secret for authentication (required)"
    echo "  --fiid                Date for the report in YYYY-MM-DD format (required)"
    echo "  --product             Product type (required)"
    echo "  --report              Type of report to download (required)"
    echo "  --date                Date for the report in YYYY-MM-DD format (required)"
    echo "  --output-dir          Directory to save downloaded files (optional)"
    echo "  --api-url             API URL (optional)"
    echo "  --help                Display this help message"
    echo
    echo "Example:"
    echo "  $0 --client-id myclient --client-secret mysecret --product mydebit --report SETL01 --date 2024-11-08"
    echo "  $0 --client-id myclient --client-secret mysecret --product san --report DFCUP --date 2024-11-08"
    echo "  $0 --client-id myclient --client-secret mysecret --product mydebit --report SETL01_C1 --date 2024-11-08 --output-dir ./downloads"
    exit 1
}

help() {
    echo "Run '$0 --help' for usage information"
    exit 1
}

generate_signature() {
    local timestamp="$1"
    local secret="$2"
    
    # Use OpenSSL to generate HMAC-SHA256 signature (lowercase hex output)
    echo -n "$timestamp" | openssl dgst -sha256 -hmac "$secret" | sed 's/^.* //'
}

extract_filename() {
    local header="$1"
    local filename

    if [[ $header =~ filename=\"?([^\"]+)\"? ]]; then
        filename="${BASH_REMATCH[1]}"
        echo "$filename"
    else
        return 1
    fi
}

# Default values
if [ -z "$API_URL" ]; then
    API_URL="https://api.reports.paynet.my"
fi

if [ -z "$OUTPUT_DIR" ]; then    
    OUTPUT_DIR="./"
fi


# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --client-id)
            if [[ -z "$2" || "$2" == --* ]]; then
                echo "ERROR: Empty value provided for --client-id"
                exit 1
            fi
            CLIENT_ID="$2"
            shift 2
            ;;
        --client-secret)
            if [[ -z "$2" || "$2" == --* ]]; then
                echo "ERROR: Empty value provided for --client-secret"
                exit 1
            fi
            CLIENT_SECRET="$2"
            shift 2
            ;;
        --fiid)
            if [[ -z "$2" || "$2" == --* ]]; then
                echo "ERROR: Empty value provided for --fiid"
                exit 1
            fi
            FIID="$2"
            shift 2
            ;;
        --report)
            if [[ -z "$2" || "$2" == --* ]]; then
                echo "ERROR: Empty value provided for --report"
                exit 1
            fi
            REPORT_TYPE="$2"
            shift 2
            ;;
        --date)
            if [[ -z "$2" || "$2" == --* ]]; then
                echo "ERROR: Empty value provided for --date"
                exit 1
            fi
            DATE="$2"
            shift 2
            ;;
        --product)
            if [[ -z "$2" || "$2" == --* ]]; then
                echo "ERROR: Empty value provided for --product"
                exit 1
            fi

            # Convert to lowercase for case-insensitive comparison
            prod_lower=$(echo "$2" | tr '[:upper:]' '[:lower:]')
            
            # Validate that product is either "san" or "mydebit" (case insensitive)
            if [[ "$prod_lower" != "san" && "$prod_lower" != "mydebit" ]]; then
                echo "ERROR: Invalid product value. Allowed values: san, mydebit (case insensitive)"
                help
            fi
            
            PRODUCT="$2"
            shift 2
            ;;
        --api-url)
        if [[ -z "$2" || "$2" == --* ]]; then
                echo "ERROR: Empty value provided for --api-url"
                exit 1
            fi
            API_URL="$2"
            shift 2
            ;;
        --output-dir)
        if [[ -z "$2" || "$2" == --* ]]; then
                echo "ERROR: Empty value provided for --output-dir"
                exit 1
            fi
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate required parameters
# Validate required parameters - terminate on first missing parameter
if [ -z "$CLIENT_ID" ]; then
    echo "ERROR: Missing required parameter: --client-id"
    help
fi

if [ -z "$CLIENT_SECRET" ]; then
    echo "ERROR: Missing required parameter: --client-secret"
    help
fi

if [ -z "$FIID" ]; then
    echo "ERROR: Missing required parameter: --fiid"
    help
fi

if [ -z "$REPORT_TYPE" ]; then
    echo "ERROR: Missing required parameter: --report"
    help
fi

if [ -z "$DATE" ]; then
    echo "ERROR: Missing required parameter: --date"
    help
fi

if [ -z "$PRODUCT" ]; then
    echo "ERROR: Missing required parameter: --product"
    help
fi

# Validate date format
if ! [[ $DATE =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "ERROR: Date must be in YYYY-MM-DD format"
    exit 1
fi

# Check if output directory is provided and valid
if [ -n "$OUTPUT_DIR" ]; then
    if [ ! -d "$OUTPUT_DIR" ]; then
        echo "Creating output directory: $OUTPUT_DIR"
        mkdir -p "$OUTPUT_DIR" || { echo "Failed to create output directory"; exit 1; }
    fi
    # Make sure path ends with a slash
    OUTPUT_DIR="${OUTPUT_DIR%/}/"
    echo "Files will be saved to: $OUTPUT_DIR"
fi

echo "Configuration:"
echo " - API URL: $API_URL"
echo " - FIID: $FIID"
echo " - Report Type: $REPORT_TYPE"
echo " - Product: $PRODUCT"
echo " - Date: $DATE"

# Get OAuth token
echo "Requesting OAuth token..."
TOKEN_RESPONSE=$(curl -s -X POST "$API_URL/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=client_credentials&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET")

ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$ACCESS_TOKEN" ]; then
    echo "Failed to obtain access token"
    echo "Token response: $TOKEN_RESPONSE"
    exit 1
fi

echo "Access token obtained successfully"

# Prepare JSON payload based on whether WINDOW is provided
PAYLOAD="{\"fiid\":\"$FIID\",\"report_type\":\"$REPORT_TYPE\",\"product\":\"$PRODUCT\",\"date\":\"$DATE\",\"window\":\"$WINDOW\"}"


TIMESTAMP=$(date +%s)
SIGNATURE=$(generate_signature "$TIMESTAMP" "$CLIENT_SECRET")

echo "Generated signature for download request:"
echo " - Timestamp: $TIMESTAMP"
echo " - Signature: $SIGNATURE"

# Send request to API
echo "Sending report request..."
RESPONSE=$(curl -s -X POST "$API_URL/v1/reports/download" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "X-Timestamp: $TIMESTAMP" \
    -H "X-Signature: $SIGNATURE" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD")

# Extract the URL from the response
if ! echo "$RESPONSE" | grep -q '"url":' ; then
    echo "Failed to get download URL"
    echo "Response: $RESPONSE"
    exit 1
fi

DOWNLOAD_URL=$(echo "$RESPONSE" | sed 's/.*"url":"\([^"]*\)".*/\1/')

if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" = "$RESPONSE" ]; then
    echo "Failed to get download URL - URL extraction failed"
    echo "Response: $RESPONSE"
    exit 1
fi

# Replace \u0026 with & in the URL
NEW_URL=$(echo "$DOWNLOAD_URL" | sed 's/\\u0026/\&/g')

echo "Download URL obtained: ${NEW_URL}"

# Download the file with a single request
echo "Downloading file..."

# Create a temporary file for headers
HEADERS_FILE=$(mktemp)

# Download the file in a single request while capturing headers
HTTP_CODE=$(curl -s -w "%{http_code}" -D "${HEADERS_FILE}" -o "${OUTPUT_DIR}temp_download" "$NEW_URL")

if [ "$HTTP_CODE" != "200" ]; then
    echo "Download failed with HTTP code: $HTTP_CODE"
    echo "Headers from server:"
    cat "${HEADERS_FILE}"
    rm -f "${HEADERS_FILE}" "${OUTPUT_DIR}temp_download"
    exit 1
fi

# Extract filename from headers
FILENAME=$(grep -i "Content-Disposition:" "${HEADERS_FILE}" | sed -E 's/.*filename="?([^";]+)"?.*/\1/')

# Clean up the headers file
rm -f "${HEADERS_FILE}"

# If no filename found, generate one based on report parameters
if [ -z "$FILENAME" ]; then
    echo "No filename found in headers, generating one based on report parameters"
    FILENAME="${PRODUCT}_${REPORT_TYPE}_${DATE}_$(date +%s).csv"
fi

# Move temp file to final destination
mv "${OUTPUT_DIR}temp_download" "${OUTPUT_DIR}${FILENAME}"

echo "File successfully downloaded and saved to: ${OUTPUT_DIR}${FILENAME}"
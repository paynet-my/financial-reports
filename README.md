# PayNet Financial Report Script

## Getting started

This is a public facing OSP's reporting API

## Check which report codes your Institution can access

The table above lists every report the API supports. The codes your FI is actually
entitled to depend on your client credentials (each report is gated by an
include/exclude FI list). Call `GET /v1/reports/types` to get the authoritative,
per-FI view.

**Environments**

| Environment | Base URL |
|---|---|
| UAT | `https://api.reports.uat.inet.paynet.my` |
| Production | `https://api.reports.paynet.my` |

**Step 1 — get an access token**

```bash
curl --location --request POST 'https://api.reports.paynet.my/token' \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode 'grant_type=client_credentials' \
  --data-urlencode 'client_id=YOUR_CLIENT_ID' \
  --data-urlencode 'client_secret=YOUR_CLIENT_SECRET'
```

Response:

```json
{ "access_token": "eyJraWQiOi...", "token_type": "Bearer", "expires_in": 3600 }
```

**Step 2 — sign the request**

`X-Timestamp` is the current Unix time (seconds). `X-Signature` is the
HMAC-SHA256 of that timestamp, keyed with your client secret, as lowercase hex.

```bash
TS=$(date +%s)
SIG=$(printf '%s' "$TS" | openssl dgst -sha256 -hmac "YOUR_CLIENT_SECRET" | sed 's/^.* //')
```

**Step 3 — list the report types**

```bash
curl --location 'https://api.reports.paynet.my/v1/reports/types' \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --header "X-Timestamp: $TS" \
  --header "X-Signature: $SIG"
```

The response lists the report types available to your FI — use these `type`
values with `--report`. Reports your FI is not entitled to are omitted:

```json
{
    "success": true,
    "data": [
        {
            "type": "AIR02",
            "name": "Acquirer Itemized Report",
            "description": "Acquirer Itemized Report",
            "supported_products": [
                "SAN"
            ]
        }
      ]
}
```

### Supported report code

A handful of reports run on a settlement cycle (`AM`, `PM`, or `ALL`) instead of a single daily run. For those, `--report` must include the cycle suffix: `_C1` for `AM` and `_C2` for `PM` (e.g. `SETL01_C1`, `SETL01_C2`); `ALL` uses the ebase code as-is (e.g. `SETL01`).

| Base Code | Description | Category | Cycle |
|---|---|---|---|
| AIR02 | Acquirer Itemized Report | SAN | ALL |
| BFMR05 | Monthly Bank Fee Report | SAN | ALL |
| BFR04 | Daily Bank Fee Report | SAN | ALL |
| BSR01 | Bank Settlement Report | SAN | ALL |
| BSR01_C1 | Bank Settlement Report | SAN | AM |
| BSR01_C2 | Bank Settlement Report | SAN | PM |
| DFCUP | Daily Forex Report for UPI / CUP | SAN | ALL |
| DIT308 | Details Instant Transfer Report | SAN | ALL |
| FFCUP | Fee Forex Report for UPI / CUP | SAN | ALL |
| IIR03 | Issuer Itemized Report | SAN | ALL |
| RECON | Reconciliation File for Participant | SAN | ALL |
| SETL01 | Settlement Report | SAN | ALL |
| SETL01_C1 | Settlement Report | SAN | AM |
| SETL01_C2 | Settlement Report | SAN | PM |
| SETL02 | Net Settlement Report | SAN | ALL |
| SETL02_C1 | Net Settlement Report | SAN | AM |
| SETL02_C2 | Net Settlement Report | SAN | PM |
| SFCUP | Summary Forex Report for UPI / CUP | SAN | ALL |
| SFDISC | Summary Forex Report for Discover | SAN | ALL |
| SIT307 | Summary Instant Transfer Report | SAN | ALL |
| ST1527 | Monthly Fee Summary Report | SAN | ALL |
| ST1528 | Monthly Fee Summary Report for IBFT 1, 2 & 4 (<= RM 5k) | SAN | ALL |
| ST1529 | Monthly Fee Summary Report for IBFT 1, 2 & 4 (> RM 5k) | SAN | ALL |
| STAT09 | Transaction Detail Report | SAN | ALL |
| STAT09ACQ | Acquirer Report | SAN | ALL |
| STAT09ISS | Issuer Report | SAN | ALL |
| STD1527 | Daily Fee Summary Report | SAN | ALL |
| STD1528 | Daily Fee Summary Report for IBFT 1, 2 & 4 (<= RM 5k) | SAN | ALL |
| STD1529 | Daily Fee Summary Report for IBFT 1, 2 & 4 (> RM 5k) | SAN | ALL |
| STMUPI | Monthly UPI Fee Report | SAN | ALL |


## How to use the automation script

Below is a concise guide on how to use the provided Bash (`.sh`) and Batch (`.bat`) scripts for downloading reports.

## Script **flags**

**Options**

- `--client-id` – Client ID for authentication (required)
- `--client-secret` – Client secret for authentication (required)
- `--fiid` – (Optional) FIID or financial institution ID
- `--report` – Report type to download (required)
- `--date` – Date (YYYY-MM-DD) for the report (required)
- `--product` - Product type; SAN or MYDEBIT (required)
- `--output-dir` – (Optional) Directory to save downloaded files; defaults to current directory if missing
- `--api-url` – (Optional) Report service API URL; defaults to https://api.reports.paynet.my
- `--help` – Display the script’s built-in usage message

### Bash Script (Linux/macOS)
**Prerequisites**

- Bash shell environment (e.g., Linux or macOS terminal).
- OpenSSL for generating HMAC signatures.
- curl for sending HTTP requests.

**How to Run**
```bash
./download_report.sh [OPTIONS]
```

If the script isn’t marked as executable, make it executable first:

```bash
chmod +x download_report.sh
```

Example
```bash
./download_report.sh \
  --client-id myclient \
  --client-secret mysecret \
  --report SETL01 \
  --date 2026-07-15 \
  --product SAN \
  --fiid FIID \
  --api-url https://api.reports.paynet.my \
  --output-dir ./downloads
```

### Batch Script (Windows)

**Prerequisites**

- Windows environment (Command Prompt or PowerShell)
- curl.exe in your PATH

**How to Run**
Open Command Prompt or PowerShell, then run:

```shell
download_report.bat [OPTIONS]
```

Adjust the path if the script is not in the current directory.

**Example**

```shell
download_report.bat ^
  --client-id myclient ^
  --client-secret mysecret ^
  --report SETL01 ^
  --date 2026-07-15 ^
  --product SAN ^
  --fiid FIID ^
  --api-url https://api.reports.paynet.my
```

## Troubleshooting

### Using a Proxy

If your environment requires routing traffic through a proxy, set the `HTTPS_PROXY` or `HTTP_PROXY` environment variable before running the script.

**Linux/macOS (Bash)**
```bash
export HTTPS_PROXY=http://proxy.acme.com
./download_report.sh --client-id myclient --client-secret mysecret ...
```

**Windows (Command Prompt)**
```shell
set HTTPS_PROXY=http://proxy.acme.com
download_report.bat --client-id myclient --client-secret mysecret ...
```

`curl` automatically honours `HTTPS_PROXY` and `HTTP_PROXY`. Use `HTTPS_PROXY` for HTTPS endpoints (recommended) and `HTTP_PROXY` as a fallback for HTTP endpoints.

### Command Not Found Errors
- **OpenSSL/curl missing**: Install required tools or add them to your system PATH
- **Permission denied (Linux/macOS)**: Run `chmod +x download_report.sh` to make the script executable

### Authentication Problems
- **Invalid token**: Verify your client credentials are correct
- **Authentication failed**: Check HMAC signature generation and timestamp

### Download Issues
- **Empty/missing file**: The one-time download URL may have expired - retry with fresh credentials
- **OTT Invalid**: One-time token has been used or expired - generate a new download request

### Best Practices

- Store credentials securely and NEVER hardcoding them in scripts

### Additional Resources

For more information , please visit the following online resource available on PayNet's Developer's Portal 

- [Overview](https://docs.developer.paynet.my/docs/operations/financial-reports/tech-refresh/overview) 
- [API Explorer](https://docs.developer.paynet.my/api-reference/reports/reports) 

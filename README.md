# PayNet Financial Report Script

## Getting started

This is a public facing OSP's reporting API

### Supported report code

| Base Code | Description | Category |
|---|---|---|
| AIR02 | Acquirer Itemized Report | SAN |
| BFMR05 | Monthly Bank Fee Report | SAN |
| BFR04 | Daily Bank Fee Report | SAN |
| BSR01 | Bank Settlement Report | SAN |
| DFCUP | Daily Forex Report for UPI / CUP | SAN |
| DIT308 | Details Instant Transfer Report | SAN |
| FFCUP | Fee Forex Report for UPI / CUP | SAN |
| IIR03 | Issuer Itemized Report | SAN |
| RECON | Reconciliation File for Participant | SAN |
| SETL01 | Settlement Report | SAN |
| SETL02 | Net Settlement Report | SAN |
| SFCUP | Summary Forex Report for UPI / CUP | SAN |
| SFDISC | Summary Forex Report for Discover | SAN |
| SIT307 | Summary Instant Transfer Report | SAN |
| ST1527 | Monthly Fee Summary Report | SAN |
| ST1528 | Monthly Fee Summary Report for IBFT 1, 2 & 4 (<= RM 5k) | SAN |
| ST1529 | Monthly Fee Summary Report for IBFT 1, 2 & 4 (> RM 5k) | SAN |
| STAT09 | Transaction Detail Report | SAN |
| STAT09ACQ | Acquirer Report | SAN |
| STAT09ISS | Issuer Report | SAN |
| STD1527 | Daily Fee Summary Report | SAN |
| STD1528 | Daily Fee Summary Report for IBFT 1, 2 & 4 (<= RM 5k) | SAN |
| STD1529 | Daily Fee Summary Report for IBFT 1, 2 & 4 (> RM 5k) | SAN |
| STMUPI | Monthly UPI Fee Report | SAN |


## How to use the automation script

Below is a concise guide on how to use the provided Bash (`.sh`) and Batch (`.bat`) scripts for downloading reports.

## Script flags

**Commands**

- `types` – (Optional, must be the first argument) Retrieve available report types instead of downloading a report; only `--client-id`/`--client-secret` (and optionally `--api-url`) are required when this is passed
- *(none)* – Downloads a report (default behavior)

**Options**

- `--client-id` – Client ID for authentication (required)
- `--client-secret` – Client secret for authentication (required)
- `--fiid` – (Optional) FIID or financial institution ID
- `--report` – Report type to download (required for download)
- `--date` – Date (YYYY-MM-DD) for the report (required for download)
- `--product` - Product type; SAN or MYDEBIT (required for download)
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
./download_report.sh [COMMAND] [OPTIONS]
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
download_report.bat [COMMAND] [OPTIONS]
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

### Retrieving report types

Pass `types` as the first argument to fetch the list of available report types instead of downloading a report. Only `--client-id`/`--client-secret` (and optionally `--api-url`) are needed — `--report`, `--date`, `--product`, and `--output-dir` are not used. The raw JSON response is printed to stdout.

**Bash**
```bash
./download_report.sh types --client-id myclient --client-secret mysecret
```

**Batch**
```shell
download_report.bat types --client-id myclient --client-secret mysecret
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

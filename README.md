# PayNet Financial Report Script

## Getting started

This is a public facing OSP's reporting API

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
  --report SETEL01 \
  --date 2025-12-31 \
  --product SAN \
  --fiid FIID \
  --api-url https://api.reports.uat.inet.paynet.my \
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
  --report SETEL01 ^
  --date 2025-12-31 ^
  --product SAN ^
  --fiid FIID ^
  --api-url https://api.reports.uat.inet.paynet.my
```
**Command Not Found Errors**
- **OpenSSL/curl missing**: Install required tools or add them to your system PATH
- **Permission denied (Linux/macOS)**: Run `chmod +x download_report.sh` to make the script executable

**Authentication Problems**
- **Invalid token**: Verify your client credentials are correct
- **Authentication failed**: Check HMAC signature generation and timestamp

**Download Issues**
- **Empty/missing file**: The one-time download URL may have expired - retry with fresh credentials
- **OTT Invalid**: One-time token has been used or expired - generate a new download request

### Best Practices

- Store credentials securely and NEVER hardcoding them in scripts

### Additional Resources

For more information , please visit the following online resource available on PayNet's Developer's Portal 

- [Overview](https://docs.developer.paynet.my/docs/operations/financial-reports/tech-refresh/overview) 
- [API Explorer](https://docs.developer.paynet.my/api-reference/reports/reports) 

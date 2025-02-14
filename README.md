# ArchiverX 📂

ArchiverX is a Linux shell scripting tool that automates log file archiving, compressing and organizing logs to reduce manual effort and optimize storage. It compresses logs into a `.tar.gz` archive and stores them in a dedicated directory with a timestamp.

---

## Features

- Compresses logs into a `.tar.gz` archive.
- Stores archives in a dedicated directory (`archived_logs`).
- Logs the date and time of each archive.
- Easy to use from the command line.

---

## Usage

### Basic Usage

Run the script with the log directory as an argument:

```bash
./log-archive.sh <log-directory>
```
Example:
To archive logs from ` /var/log` :
```bash
./log-archive.sh /var/log
```
---
## Requirenments

- Bash shell: The script is written for Unix-based systems.
- `tar` command: Used for compressing logs.
 
---
## Installation

1. Clone the repository:
``` bash
git clone https://github.com/bavitha01/ArchiverX.git
```
2. Navigate to the project directory:
``` bash
cd ArchiverX
```
3. Make the script executable:
``` bash
chmod +x log-archive.sh
```
---
## Output
- Archives: Compressed `.tar.gz` files are stored in the `archived_logs` directory.
- Log File: A log of each archive operation is saved in `archived_logs/archive_log.txt`.

---
## Final Thoughts :)
The script is designed to be non-destructive and only creates archives of your logs. It won’t modify or delete your original files unless you explicitly add such functionality (e.g., log rotation).


# ArchiverX 📂

ArchiverX is a powerful Linux shell scripting tool that automates log file archiving, compressing, and organizing logs to reduce manual effort and optimize storage. It provides advanced features for log management, including compression, rotation, and cleanup.

## Features

Here's what ArchiverX can do for you:
- Compress your log files into `.tar.gz` archives
- Keep your log directories neat and organized
- Save space by compressing old logs
- Keep track of what was archived and when

## Getting Started

First, let's get ArchiverX set up on your system:

```bash
# Get the code
git clone https://github.com/bavitha01/ArchiverX.git

# Move into the directory
cd ArchiverX

# Make it executable
chmod +x bin/log-archive.sh
```

## Using ArchiverX

The basic command is simple:
```bash
./bin/log-archive.sh /path/to/your/logs
```

Want to see what would be archived without actually doing it? Use the -n flag:
```bash
./bin/log-archive.sh -n /path/to/your/logs
```

## Real-World Examples

Here are some ways I use ArchiverX:

1. Archiving system logs:
```bash
./bin/log-archive.sh /var/log
```

2. When I need maximum compression:
```bash
./bin/log-archive.sh -c 9 /var/log
```

3. Keeping archives longer:
```bash
./bin/log-archive.sh -a 60 /var/log
```

## How It Works

The script follows these steps:

1. First, it checks:
   - Can it read your log directory?
   - Is there enough disk space?
   - Do you have the right permissions?

2. Then it archives:
   - Creates a file like `logs_archive_20240315_123456.tar.gz`
   - Compresses everything to save space
   - Makes sure the archive isn't corrupted

3. Finally, it cleans up:
   - Keeps a log of what was archived
   - Removes old archives based on your settings
   - Rotates log files to keep them from getting too big

## Command Options ⚙️

Here are all the options you can use:
```
-d <dir>    Where to put archives (default: ./archived_logs)
-l <size>   Biggest log file size (default: 10MB)
-f <num>    Number of log files to keep (default: 5)
-a <days>   How long to keep archives (default: 30 days)
-c <level>  How much to compress (1-9, default: 6)
-n          Just show what would be archived
-h          Show help
```

## Where Are My Archives? 📁

Your archives will be in:
- `archived_logs` by default
- `~/archiverx_archives` if you can't write to the default location
- Check `archive_log.txt` to see what was archived and when

## Troubleshooting

If something's not working, try these:
1. Can you read the log directory?
2. Do you have enough disk space?
3. Are your paths correct?

## Pro Tips

- Always use -n first to see what would be archived
- Start with the defaults, then adjust as needed
- Check the archive log to see what's happening


## Requirements 📋

- Unix-like system (Linux, macOS)
- Basic commands: `tar`, `gzip`, `find`, `du`, `df`

## Final Thoughts

The script is designed to be non-destructive and only creates archives of your logs. It won't modify or delete your original files unless you explicitly add such functionality (e.g., log rotation). The tool uses absolute paths to ensure reliable execution from any location.


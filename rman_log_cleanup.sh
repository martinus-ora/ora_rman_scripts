#!/bin/bash

# ===== CONFIGURATION =====
LOG_DIR="/path/to/logs"
ARCHIVE_DIR="${LOG_DIR}/archives"
TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
ARCHIVE_FILE="${ARCHIVE_DIR}/old_logs_${TIMESTAMP}.tar.gz"
LOGFILE="${LOG_DIR}/log_cleanup_${TIMESTAMP}.log"

# ===== INITIALIZE =====
echo "===== RMAN Log Cleanup Started at $(date) =====" > "$LOGFILE"

# Create archive dir if missing
if [ ! -d "$ARCHIVE_DIR" ]; then
  mkdir -p "$ARCHIVE_DIR"
  echo "Created archive directory: $ARCHIVE_DIR" >> "$LOGFILE"
fi

# Find .log files older than 60 days
cd "$LOG_DIR" || exit 1
OLD_LOGS=$(find "$LOG_DIR" -maxdepth 1 -name "*.log" -type f -mtime +60)

if [ -n "$OLD_LOGS" ]; then
  echo "Found old log files:" >> "$LOGFILE"
  echo "$OLD_LOGS" >> "$LOGFILE"

  # Archive and compress
  tar -czf "$ARCHIVE_FILE" $OLD_LOGS
  echo "Archived logs to: $ARCHIVE_FILE" >> "$LOGFILE"

  # Remove original files
  rm -f $OLD_LOGS
  echo "Deleted original old log files." >> "$LOGFILE"
else
  echo "No log files older than 60 days found." >> "$LOGFILE"
fi

echo "===== RMAN Log Cleanup Completed at $(date) =====" >> "$LOGFILE"
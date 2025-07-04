#!/bin/bash

# ===== CONFIGURATION =====
TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
LOG_DIR="/path/to/logs"
ARCHIVE_DIR="${LOG_DIR}/archives"
LOGFILE="${LOG_DIR}/rman_backup_level0_${TIMESTAMP}.log"
ARCHIVE_FILE="${ARCHIVE_DIR}/old_logs_${TIMESTAMP}.tar.gz"

export ORACLE_SID=your_sid
export ORAENV_ASK=NO
. /usr/local/bin/oraenv >> "$LOGFILE" 2>&1

START_TIME=$(date +%s)
echo "===== RMAN Backup Level 0 Started at $(date) =====" >> "$LOGFILE"

rman target / <<EOF >> "$LOGFILE" 2>&1
RUN {
  # Allocate sbt_tape channels
  ALLOCATE CHANNEL c1 DEVICE TYPE sbt_tape;
  ALLOCATE CHANNEL c2 DEVICE TYPE sbt_tape;
  ALLOCATE CHANNEL c3 DEVICE TYPE sbt_tape;
  ALLOCATE CHANNEL c4 DEVICE TYPE sbt_tape;

  # Optional: Validate database blocks before backup
  # BACKUP VALIDATE DATABASE;

  # Level 0 backup with archive logs, tag, and DELETE INPUT
  BACKUP AS COMPRESSED BACKUPSET
    TAG 'FULL_LVL0_WITH_ARCHIVELOG'
    INCREMENTAL LEVEL 0
    DATABASE
    PLUS ARCHIVELOG DELETE INPUT;

  # Backup SPFILE and current control file together
  BACKUP SPFILE INCLUDE CURRENT CONTROLFILE;

  # Backup control file to disk using REUSE
  BACKUP REUSE CURRENT CONTROLFILE FORMAT '/path/to/ctrl_backup.ctl';

  # Crosscheck and cleanup
  CROSSCHECK BACKUP;
  REPORT OBSOLETE;
  DELETE NOPROMPT OBSOLETE;
}
EXIT;
EOF

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
echo "===== RMAN Backup Completed at $(date) =====" >> "$LOGFILE"
echo "Total Duration: ${DURATION} seconds" >> "$LOGFILE"

# ===== EMAIL NOTIFICATION =====
mailx -s "RMAN Level 0 Backup Completed on $ORACLE_SID [$(date)]" you@example.com < "$LOGFILE"

# ===== LOGFILE CLEANUP =====
if [ ! -d "$ARCHIVE_DIR" ]; then
  mkdir -p "$ARCHIVE_DIR"
  echo "Created archive directory: $ARCHIVE_DIR" >> "$LOGFILE"
fi

cd "$LOG_DIR" || exit 1
OLDER_LOGS=$(ls -1t rman_backup_level0_*.log | tail -n +61)

if [ -n "$OLDER_LOGS" ]; then
  echo "Archiving older log files..." >> "$LOGFILE"
  tar -czf "$ARCHIVE_FILE" $OLDER_LOGS
  echo "Archive created: $ARCHIVE_FILE" >> "$LOGFILE"

  echo "Removing archived log files..." >> "$LOGFILE"
  rm -f $OLDER_LOGS
else
  echo "No old logs to clean up." >> "$LOGFILE"
fi


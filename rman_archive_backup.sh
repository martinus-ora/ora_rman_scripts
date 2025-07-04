#!/bin/bash

TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
LOG_DIR="/path/to/logs"
ARCHIVE_DIR="${LOG_DIR}/archives"
LOGFILE="${LOG_DIR}/rman_backup_archivelog_${TIMESTAMP}.log"
ARCHIVE_FILE="${ARCHIVE_DIR}/old_logs_${TIMESTAMP}.tar.gz"

export ORACLE_SID=your_sid
export ORAENV_ASK=NO
. /usr/local/bin/oraenv >> "$LOGFILE" 2>&1

START_TIME=$(date +%s)
echo "===== RMAN Archivelog Backup Started at $(date) =====" >> "$LOGFILE"

rman target / <<EOF >> "$LOGFILE" 2>&1
RUN {
  ALLOCATE CHANNEL c1 DEVICE TYPE sbt_tape;

  BACKUP AS BACKUPSET
    TAG 'ARCHIVELOG_ONLY'
    ARCHIVELOG ALL DELETE INPUT;

  BACKUP CURRENT CONTROLFILE;
  BACKUP REUSE CURRENT CONTROLFILE FORMAT '/path/to/ctrl_backup.ctl';

  CROSSCHECK BACKUP;
  REPORT OBSOLETE;
  DELETE NOPROMPT OBSOLETE;
}
EXIT;
EOF

END_TIME=$(date +%s)
echo "===== RMAN Archivelog Backup Completed at $(date) =====" >> "$LOGFILE"
echo "Total Duration: $((END_TIME - START_TIME)) seconds" >> "$LOGFILE"

mailx -s "RMAN Archivelog Backup Completed [$ORACLE_SID]" you@example.com < "$LOGFILE"

if [ ! -d "$ARCHIVE_DIR" ]; then
  mkdir -p "$ARCHIVE_DIR"
  echo "Created archive directory: $ARCHIVE_DIR" >> "$LOGFILE"
fi

cd "$LOG_DIR" || exit 1
OLDER_LOGS=$(ls -1t rman_backup_archivelog_*.log | tail -n +61)

if [ -n "$OLDER_LOGS" ]; then
  tar -czf "$ARCHIVE_FILE" $OLDER_LOGS
  rm -f $OLDER_LOGS
  echo "Archived old logs to: $ARCHIVE_FILE" >> "$LOGFILE"
else
  echo "No archivelog logs to archive." >> "$LOGFILE"
fi
#!/bin/bash

# ===== CONFIGURATION =====
TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
LOG_DIR="/path/to/logs"
LOGFILE="${LOG_DIR}/rman_backup_archivelog_${TIMESTAMP}.log"

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

# ===== EMAIL NOTIFICATION =====
mailx -s "RMAN Archivelog Backup Completed [$ORACLE_SID]" you@example.com < "$LOGFILE"

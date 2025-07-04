#!/bin/bash

# ===== CONFIGURATION =====
TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
LOG_DIR="/path/to/logs"
LOGFILE="${LOG_DIR}/rman_backup_level1_${TIMESTAMP}.log"
EMAIL="you@example.com"

export ORACLE_SID=your_sid
export ORAENV_ASK=NO
. /usr/local/bin/oraenv >> "$LOGFILE" 2>&1

START_TIME=$(date +%s)
echo "===== RMAN Level 1 Backup Started at $(date) =====" >> "$LOGFILE"

rman target / <<EOF >> "$LOGFILE" 2>&1
RUN {
  ALLOCATE CHANNEL c1 DEVICE TYPE sbt_tape;
  ALLOCATE CHANNEL c2 DEVICE TYPE sbt_tape;

  BACKUP AS BACKUPSET
    TAG 'INCR_LVL1_WITH_ARCHIVELOG'
    INCREMENTAL LEVEL 1
    DATABASE
    PLUS ARCHIVELOG DELETE INPUT;

  BACKUP SPFILE INCLUDE CURRENT CONTROLFILE;
  BACKUP REUSE CURRENT CONTROLFILE FORMAT '/path/to/ctrl_backup.ctl';

  CROSSCHECK BACKUP;
  REPORT OBSOLETE;
  DELETE NOPROMPT OBSOLETE;
}
EXIT;
EOF

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
echo "===== RMAN Level 1 Backup Completed at $(date) =====" >> "$LOGFILE"
echo "Total Duration: ${DURATION} seconds" >> "$LOGFILE"

# ===== EMAIL NOTIFICATION =====
mailx -s "RMAN Level 1 Backup Completed [$ORACLE_SID] - ${DURATION}s" "$EMAIL" < "$LOGFILE"

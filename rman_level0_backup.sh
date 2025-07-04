#!/bin/bash

# ===== CONFIGURATION =====
TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
LOG_DIR="/path/to/logs"
LOGFILE="${LOG_DIR}/rman_backup_level0_${TIMESTAMP}.log"

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

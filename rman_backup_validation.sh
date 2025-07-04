#!/bin/bash

# ===== CONFIGURATION =====
TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
LOG_DIR="/path/to/logs"
LOGFILE="${LOG_DIR}/rman_validate_${TIMESTAMP}.log"
EMAIL="you@example.com"

export ORACLE_SID=your_sid
export ORAENV_ASK=NO
. /usr/local/bin/oraenv >> "$LOGFILE" 2>&1

START_TIME=$(date +%s)
echo "===== RMAN Backup Validation Started at $(date) =====" > "$LOGFILE"

rman target / <<EOF >> "$LOGFILE" 2>&1
RUN {
  # ===== Channel Allocation =====
  ALLOCATE CHANNEL c1 DEVICE TYPE sbt_tape;
  ALLOCATE CHANNEL c2 DEVICE TYPE sbt_tape;

  # ===== Physical Restore Simulation =====
  RESTORE DATABASE VALIDATE;

  # ===== Logical Corruption Check =====
  BACKUP VALIDATE CHECK LOGICAL DATABASE;

  # ===== Control File & SPFILE =====
  RESTORE CONTROLFILE VALIDATE;
  RESTORE SPFILE VALIDATE;

  # ===== Archived Logs =====
  RESTORE ARCHIVELOG ALL VALIDATE;

  # ===== Release Channels =====
  RELEASE CHANNEL c1;
  RELEASE CHANNEL c2;
}
EXIT;
EOF

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "===== RMAN Validation Completed at $(date) =====" >> "$LOGFILE"
echo "Total Duration: ${DURATION} seconds" >> "$LOGFILE"

# ===== EMAIL NOTIFICATION =====
mailx -s "RMAN Backup Validation Completed [$ORACLE_SID] - ${DURATION}s" "$EMAIL" < "$LOGFILE"
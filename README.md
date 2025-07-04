# Oracle RMAN Backup Scripts

A curated suite of production-grade Oracle RMAN shell scripts for backup, validation, and housekeeping. These scripts automate Level 0, Level 1, and archived log backups—with integrated logging, compression, and notifications.

---

## 🗃️ Included Scripts

### `rman_level0_backup.sh`
Performs a full **incremental Level 0 compressed** backup:
- Backs up the entire database
- Includes all archived logs (`DELETE INPUT`)
- Backs up SPFILE and control file (to tape and disk)
- Logs duration and status, emails result

### `rman_level1_backup.sh`
Performs an **incremental Level 1 compressed** backup:
- Backs up changes since last Level 0
- Includes archived logs (`DELETE INPUT`)
- Includes control file and SPFILE
- Logs duration and status, emails result

### `rman_archivelog_backup.sh`
Backs up **only archived logs**, with compression:
- Deletes logs after successful backup
- Validates and backs up current control file
- Logs duration and status, emails result

### `rman_backup_validation.sh`
Validates RMAN backups and detects logical corruption:
- Uses `RESTORE VALIDATE` for physical checks
- Uses `BACKUP VALIDATE CHECK LOGICAL` for block integrity
- Validates control file, SPFILE, and archived logs
- Allocates tape channels
- Logs duration and result, emails summary

### `rman_log_cleanup.sh`
Standalone log rotation script:
- Finds `.log` files in `LOG_DIR` older than 60 days
- Archives them to `.tar.gz` under `archives/`
- Logs cleanup activity separately

---

## 🧰 Prerequisites

- Oracle RMAN with `sbt_tape` integration
- Environment variables: `ORACLE_SID`, `oraenv` configured
- External tools required:
  - `mailx` for email alerts
  - `tar`, `find`, `date` for log handling and archiving

---

## 📬 Notifications

Each script uses a shared `EMAIL` variable to send status updates and logs.  
Edit this line to set your email:
```bash
EMAIL="you@example.com"
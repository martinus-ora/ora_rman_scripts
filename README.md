# Oracle RMAN Backup Scripts

A collection of production-grade Oracle RMAN shell scripts for automating backups. Includes Level 0, Level 1, and archived log-only backups with built-in logging, cleanup, and notification features.

---

## 🗃️ Included Scripts

### 1. `rman_level0_backup.sh`
Performs a full **incremental Level 0** backup:
- Backs up the entire database
- Includes all archived logs (`DELETE INPUT`)
- Backs up SPFILE and control file (to tape and disk)
- Generates timestamped log files
- Archives older logs (>60) to a `.tar.gz` file

### 2. `rman_level1_backup.sh`
Performs an **incremental Level 1** backup:
- Backs up changes since last Level 0
- Includes archived logs (`DELETE INPUT`)
- Backs up SPFILE and control file
- Retains last 60 logs and archives the rest

### 3. `rman_archivelog_backup.sh`
Backs up **only archived logs**:
- Deletes logs after successful backup
- Backs up current control file
- Compresses old logfiles into archive

---

## 🧰 Prerequisites

- Oracle RMAN configured with `sbt_tape` device
- Shell environment variables: `ORACLE_SID`, `oraenv`
- External commands:
  - `mailx` for email alerts
  - `tar` for log archiving
- Proper directory paths defined in each script

---

## 📨 Notifications

Each script sends an email with the backup log to a specified address. Update:
```bash
you@example.com

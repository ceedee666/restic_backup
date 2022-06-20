# Restic backup scripts for MacOS

This repository contains the shell scripts I wrote to perform regular backups using [restic](https://github.com/restic/restic). The backup is performed using SFTP to an Synology disk station. 

The script expects the following environmet variables to be set. 

```shell
BACKUP_PATHS=
EXCLUDE_FILE=

RESTIC_REPOSITORY=
RESTIC_PASSWORD=

RETENTION_LAST=24
RETENTION_DAYS=7
RETENTION_WEEKS=4
RETENTION_MONTHS=6
```

In my script these variable afre set by sourcing a file named `restic.conf`.

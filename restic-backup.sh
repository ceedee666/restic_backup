#!/bin/bash

PID_FILE=~/.config/restic/.restic_backup.pid
CONFIG_FILE=~/.config/restic/restic.conf

if [[ -f "$CONFIG_FILE" ]]; then
	source $CONFIG_FILE
else
	echo $(date +"%Y-%m-%d %T") "File $CONFIG_FILE does not exist. Please create the required config file."
	exit 1
fi

if [[ -f "$PID_FILE" ]]; then
	if ps -p $(cat $PID_FILE) >/dev/null; then
		echo $(date +"%Y-%m-%d %T") "File $PID_FILE exist. Probably backup is already in progress."
		exit 2
	else
		echo $(date +"%Y-%m-%d %T") "File $PID_FILE exist but process " $(cat $PID_FILE) " not found. Removing PID file."
		rm $PID_FILE
	fi
fi

if [[ $(ipconfig getsummary en0 | grep -E "Mat-Mina-Rus-Ada|other-networks") == "" ]]; then
	echo $(date +"%Y-%m-%d %T") "Unsupported network."
	osascript -e 'display notification "Restic backup not started." with title "Restic" subtitle "Not connected to home network."'
	exit 3
fi

#if [[ $(pmset -g ps | head -1) =~ "Battery" ]]; then
#  echo $(date +"%Y-%m-%d %T") "Computer is not connected to the power source."
#  exit 4
#fi

# Backup
echo $$ >$PID_FILE
echo $(date +"%Y-%m-%d %T") "Backup start"

export RESTIC_REPOSITORY
export RESTIC_PASSWORD

# sometimes there are stale locks
# remove them to be sure the backup runs
/opt/homebrew/bin/restic unlock
/opt/homebrew/bin/restic backup --verbose $BACKUP_PATHS --exclude-file=$EXCLUDE_FILE

if [[ $? = 0 ]]; then
	echo $(date +"%Y-%m-%d %T") "Backup finished successfully."
	osascript -e 'display notification "Restic backup finished successfully." with title "Restic" subtitle "Backup successfull."'
else
	echo $(date +"%Y-%m-%d %T") "Backup not sucessfull."
	osascript -e 'display notification "Restic backup not successfull! Check log for details." with title "Restic" subtitle "Backup failed."'
fi
# Housekeeping
echo $(date +"%Y-%m-%d %T") "Housekeeping start"

/opt/homebrew/bin/restic forget --keep-last $RETENTION_LAST --keep-daily $RETENTION_DAYS --keep-weekly $RETENTION_WEEKS --keep-monthly $RETENTION_MONTHS
/opt/homebrew/bin/restic prune --verbose

echo $(date +"%Y-%m-%d %T") "Housekeeping finished"

rm $PID_FILE

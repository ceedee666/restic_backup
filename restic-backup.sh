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
  if ps -p $(cat $PID_FILE) > /dev/null; then
    echo $(date +"%Y-%m-%d %T") "File $PID_FILE exist. Probably backup is already in progress."
    exit 2
  else
    echo $(date +"%Y-%m-%d %T") "File $PID_FILE exist but process " $(cat $PID_FILE) " not found. Removing PID file."
    rm $PID_FILE
  fi
fi

if [[ $(networksetup -getairportnetwork en0 | grep -E "Mat-Mina-Rus-Ada|other-networks") == "" ]]; then
  echo $(date +"%Y-%m-%d %T") "Unsupported network."
  exit 3
fi

#if [[ $(pmset -g ps | head -1) =~ "Battery" ]]; then
#  echo $(date +"%Y-%m-%d %T") "Computer is not connected to the power source."
#  exit 4
#fi

# Backup
echo $$ > $PID_FILE
echo $(date +"%Y-%m-%d %T") "Backup start"

export RESTIC_REPOSITORY
export RESTIC_PASSWORD

/opt/homebrew/bin/restic backup --verbose $BACKUP_PATHS --exclude-file=$EXCLUDE_FILE 

echo $(date +"%Y-%m-%d %T") "Backup finished"

# Housekeeping
echo $(date +"%Y-%m-%d %T") "Housekeeping start"

/opt/homebrew/bin/restic forget --keep-last $RETENTION_LAST --keep-daily $RETENTION_DAYS --keep-weekly $RETENTION_WEEKS --keep-monthly $RETENTION_MONTHS
/opt/homebrew/bin/restic prune 

echo $(date +"%Y-%m-%d %T") "Housekeeping finished"

rm $PID_FILE

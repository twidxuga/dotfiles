#!/bin/zsh

# 1. Backup Documents to Dropbox
echo "=================================================================="
echo "[$(date '+%Y-%m-%d %H:%M:%S')] START - BACKUP DOCUMENTS TO DROPBOX"
echo "=================================================================="
rsync -av --delete "${HOME}/Documents/" "${HOME}/Dropbox/Backups/Documents/"
echo "=================================================================="
echo "[$(date '+%Y-%m-%d %H:%M:%S')] END - BACKUP DOCUMENTS TO DROPBOX"
echo "=================================================================="
echo
echo "=================================================================="
echo "[$(date '+%Y-%m-%d %H:%M:%S')] START - BACKUP DOTFILES"
echo "=================================================================="
echo "Start - Syncing arch packages"
${HOME}/Scripts/pacbac.sh b
echo "End - Syncing arch packages"
pushd "$HOME/.dotfiles"
git add -A
git commit -a -m "$(date) - Scripted dotfile sync from $HOST" 
git push
git st
popd
echo "=================================================================="
echo "[$(date '+%Y-%m-%d %H:%M:%S')] END - BACKUP DOTFILES"
echo "=================================================================="

BACKUP="${HOME}/Media/warehouse/Backup-latest"
if ! [[ -e "${BACKUP}" ]]; then mkdir $BACKUP 2> /dev/null; fi
if [[ -e "${BACKUP}" ]]
then
  echo
  echo "=================================================================="
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] START - BACKUP TO EXTERNAL STORAGE"
  echo "=================================================================="
  echo "Backup Documents"
  # Note that sudo commands requires configuration with visudo
  rsync -av --delete "${HOME}/Documents/" "${BACKUP}/Documents/"
  rsync -av --delete "${HOME}/Dropbox/QuickAccess/" "${BACKUP}/QuickAccess/"
  rsync -av --delete "${HOME}/.dotfiles/" "${BACKUP}/dot-dotfiles/"
  rsync -av --delete "${HOME}/Scripts/" "${BACKUP}/Scripts/"
  sudo rsync -av --delete "${HOME}/Projects/" "${BACKUP}/Projects/"
  rsync -av --delete "${HOME}/Desktop/" "${BACKUP}/Desktop/"
  rsync -av --delete "${HOME}/Books/" "${BACKUP}/Books/"
  rsync -av --delete "${HOME}/Photos/" "${BACKUP}/Photos/"
  rsync -av --delete "${HOME}/Apps/" "${BACKUP}/Apps/"
  rsync -av --delete "${HOME}/Pictures/" "${BACKUP}/Pictures/"
  rsync -av --delete "${HOME}/Audio/Aebersold/" "${BACKUP}/Audio/Aebersold/"
  rsync -av --delete "${HOME}/Audio/Ardour/" "${BACKUP}/Audio/Ardour/"
  rsync -av --delete "${HOME}/Audio/EqPresets/" "${BACKUP}/Audio/EqPresets/"
  rsync -av --delete "${HOME}/Audio/FromFriends/" "${BACKUP}/Audio/FromFriends/"
  rsync -av --delete "${HOME}/Audio/MusicAuthoredByMe/" "${BACKUP}/Audio/MusicAuthoredByMe/"
  rsync -av --delete "${HOME}/Video/" "${BACKUP}/Video/"
  sudo rsync -av --no-owner --no-group --delete "/etc/" "${BACKUP}/etc/"
  echo "=================================================================="
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] END - BACKUP TO EXTERNAL STORAGE"
  echo "=================================================================="
else
  echo "WARNING: Could not create or access $BACKUP. Not mounted?"
fi


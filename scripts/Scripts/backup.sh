#!/bin/zsh

# 1. Backup Documents to Dropbox
echo "[$(date '+%Y-%m-%d %H:%M:%S')] START - BACKUP DOCUMENTS TO DROPBOX"
echo "=================================================================="
rsync -av --delete "${HOME}/Documents/" "${HOME}/Dropbox/Backups/Documents/"
echo "=================================================================="
echo "[$(date '+%Y-%m-%d %H:%M:%S')] END - BACKUP DOCUMENTS TO DROPBOX"

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
echo "[$(date '+%Y-%m-%d %H:%M:%S')] END - BACKUP DOTFILES"
echo "=================================================================="

echo "[$(date '+%Y-%m-%d %H:%M:%S')] START - BACKUP TO EXTERNAL STORAGE"
echo "=================================================================="
BACKUP="${HOME}/Media/warehouse/Backup-latest"
if [[ -e "${BACKUP}" ]]
then
  echo "Backup Documents"
  rsync -av --delete "${HOME}/Documents/" "${BACKUP}/Documents/"
  rsync -av --delete "${HOME}/.dotfiles/" "${BACKUP}/dot-dotfiles/"
  rsync -av --delete "${HOME}/Scripts/" "${BACKUP}/Scripts/"
  rsync -av --delete "${HOME}/Projects/" "${BACKUP}/Projects/"
  rsync -av --delete "${HOME}/Desktop/" "${BACKUP}/Desktop/"
  rsync -av --delete "${HOME}/Books/" "${BACKUP}/Books/"
  rsync -av --delete "${HOME}/Photos/" "${BACKUP}/Photos/"
  rsync -av --delete "${HOME}/Apps/" "${BACKUP}/Apps/"
  rsync -av --delete "${HOME}/Pictures/" "${BACKUP}/Pictures/"
  rsync -av --delete "${HOME}/Audio/" "${BACKUP}/Audio/"
  rsync -av --delete "${HOME}/Video/" "${BACKUP}/Video/"
fi
echo "[$(date '+%Y-%m-%d %H:%M:%S')] END - BACKUP TO EXTERNAL STORAGE"
echo "=================================================================="
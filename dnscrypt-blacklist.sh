#!/usr/bin/env bash
#
# PREREQUISITES:
#   sudoers: jerome ALL=(ALL) NOPASSWD: /usr/local/bin/brew services restart dnscrypt-proxy
#   MacOS Preferences: Security & Privacy: Full Disk Access: add 'cron'

set -e
set -u

# Configuration
ETC_BLACKLIST=dnscrypt-blacklist.txt
ETC_TMP_BLACKLIST=dnscrypt-blacklist.tmp
ETC_DIR_DNSCRYPT=/usr/local/etc
PRG_BREW=/usr/local/bin/brew
PRG_CURL=/usr/bin/curl
PRG_SUDO=/usr/bin/sudo
URL_OISD="https://dbl.oisd.nl"

# Fetching the last blacklist
${PRG_CURL} --silent --output "${ETC_DIR_DNSCRYPT}/${ETC_TMP_BLACKLIST}" "${URL_OISD}"

# Installing the blacklist
size=$(wc -l "${ETC_DIR_DNSCRYPT}/${ETC_TMP_BLACKLIST}"|cut -d' ' -f3)
if [ "$size" -gt 0 ]; then
  # replace dnscrypt-blacklist.txt with the new dnscrypt-blacklist.tmp
  mv "${ETC_DIR_DNSCRYPT}/${ETC_TMP_BLACKLIST}" "${ETC_DIR_DNSCRYPT}/${ETC_BLACKLIST}"

  # restart dnscrypt-proxy
  output=$(${PRG_SUDO} ${PRG_BREW} services restart dnscrypt-proxy 2>&1)
  [ "$?" -ne 0 ] && echo $output
fi

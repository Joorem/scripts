#!/bin/sh
#
# https://www.freebsd.org/doc/handbook/makeworld.html

PRG_CHFLAGS=/bin/chflags
PRG_FUPDATE=/usr/sbin/freebsd-update
PRG_GREP=/usr/bin/grep
PRG_MAKE=/usr/bin/make
PRG_MV=/bin/mv
PRG_NOHUP=/usr/bin/nohup
PRG_RM=/bin/rm

set -e
set -u

# functions
buildkernel() {
  echo -n 'Building kernel... '
  ${PRG_NOHUP} ${PRG_MAKE} buildkernel 2>/dev/null
  ${PRG_MV} nohup.out nohup.buildkernel
  print_ok
}

buildworld() {
  echo -n 'Building world... '
  ${PRG_NOHUP} ${PRG_MAKE} -j4 buildworld 2>/dev/null
  ${PRG_MV} nohup.out nohup.world
  print_ok
}

clean() {
  echo -n 'Cleaning workstree... '

  [ -d /usr/obj/lib32 ] && (${PRG_CHFLAGS} -Rf noschg /usr/obj/lib32; ${PRG_RM} -Rf /usr/obj/lib32)
  [ -d /usr/obj/usr ] && (${PRG_CHFLAGS} -Rf noschg /usr/obj/usr; ${PRG_RM} -Rf /usr/obj/usr)

  cd /usr/src
  ${PRG_MAKE} cleandir >/dev/null
  ${PRG_MAKE} cleandir >/dev/null

  print_ok
}

help() {
    echo "$0 [-h]
      -h: this help screen"

    exit 1
}

installkernel() {
  echo -n 'Installaing kernel... '
  ${PRG_NOHUP} ${PRG_MAKE} installkernel 2>/dev/null
  ${PRG_MV} nohup.out nohup.installkernel
  print_ok
}

print_ok() {
  echo -e "\033[32mOk\033[0m"
}

update() {
  echo -n 'Installing updates... '
  ${PRG_FUPDATE} install 2>/dev/null
  print_ok
}

# work
force=0

if [ $# -gt 0 ]; then
  case "$1" in
    "-h")
      help
      ;;
    "-f")
      force=1
      ;;
  esac
fi

echo -n 'Checking for updates... '
if (`${PRG_FUPDATE} fetch|${PRG_GREP} -q 'No updates needed'`); then
  if [ $force -eq 0 ]; then
    echo 'Nothing to do!'
    exit 0
  fi
else
  print_ok
  update
fi

clean
buildworld
buildkernel
installkernel

echo -n "Read logs in \`/usr/src/' and reboot! [Enter]"
read input

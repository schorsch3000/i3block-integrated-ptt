#!/usr/bin/env bash
[[ "$BLOCK_BUTTON" == "1" ]] && BLOCK_BUTTON=0 "$0" toggle
set -a
SCRIPT_PATH="$(realpath "$0")"
MYHOME="$(dirname "$SCRIPT_PATH")"
. "$MYHOME/config.sh"
set +a


function setMute(){
  grep -q '^MUTE$' "$MYHOME/STATE" && {
    pactl set-source-mute "$MUTEABLE_SOURCE" 1
    return
  }
  grep -q '^UNMUTE$' "$MYHOME/STATE" && {
    pactl set-source-mute "$MUTEABLE_SOURCE" 0
    return
  }
  pactl set-source-mute "$MUTEABLE_SOURCE" "$1"
}


case "$1" in
  xbindkeysrc)
    gomplate -f "$MYHOME/xbindkeysrc.tpl"
    ;;
  push)
    setMute 0
    ;;
  release)
    setMute 1
    ;;
  mute)
    echo MUTE > "$MYHOME/STATE"
    setMute
    ;;
  unmute)
    echo UNMUTE > "$MYHOME/STATE"
    setMute
    ;;
  ptt)
    echo PTT > "$MYHOME/STATE"
    setMute 1
    ;;
  getstate)
    cat "$MYHOME/STATE"
    ;;
  toggle)
    grep -q '^UNMUTE$' "$MYHOME/STATE" && {
      "$0" ptt
      exit

    }
    grep -q '^MUTE$' "$MYHOME/STATE" && {
      "$0" unmute
       exit
    }

    "$0" mute
    ;;
  *)
    echo "
ptt.sh <command>
availible commands are:
xbindkeysrc   prints your xbindkeysrc according to the config in config.sh
mute          sets the current state to always mute, ignoring your PTT-Button
unmute        sets the current state to always speak, ignoring your PTT-Button
ptt           sets the current state to ptt, mutes initially
toggle        cycles throu states in the order mute unmute ptt
getstate      shows the current state
push          is used via xbindkeys, unmutes your source if mode is ptt
release       is used via xbindkeys, mutes your source if mode is ptt
"

esac
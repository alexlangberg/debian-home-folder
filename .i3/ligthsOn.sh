#!/usr/bin/env bash

# Copyright (c) 2015 Andrzej Krentosz
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## @file lighstOn-NG
#
#  Script that prevents screensaver from activating when selected applications
#  are running. Applications can be defined using two lists below:
#  one list for fullscreen applications and one for other applications. This
#  can be used to disable screensaver when browser is playing fulscreen Flash
#  or HTML5 videos. It supports xscreensaver, kscreensaver, gnome-screensaver
#  (gnome2), mate-screensacer and cinamon-screensaver, as well as generic DPMS.
#
#  Usage:
#  ./lightsOn-NG [timeout]
#  'timeout' is an optional parameter that specifies delay (in seconds) between
#  executions of checks. You want it to be less than your screensaver timeout
#  by few seconds. Script can autodetect optimal value for xscreensaver
#  and kscreensaver. You can also specify default value below.

###
# Configuration variables.

## @brief Default timeout value for this script, in seconds.
#
#  This value should be somewhat less than your screensaver's timeout.
default_timeout=50

## @brief Does the script should be verbose?
verbose=false

## @brief Fullscreen process names to search for.
#
#  If any of processes listed here will be running and its window will be
#  fullscreen, screensaver will be delayed. You can use regular expressions.
#  Don't forget to use quotation marks when necessary (if unsure, just
#  use them). Whole commandline is matched.
#  Default list contains some popular media players and browsers. Note that
#  this will work for fullscreen Flash and HTML5 video.
fullscreen_apps=( "vlc" \
                  "mplayer" \
                  "smplayer" \
                  "minitube" \
                  "totem" \
                  "chrome" \
                  "chromium" \
                  "firefox" )

## @brief Other application that should trigger delaying.
#
#  You can add some other applications here.
#  If any of processes listed here will be running, screensaver will be
#  delayed. You can use regular expressions. Don't forget to use
#  quotation marks when necessary (if unsure, just use them).
#  Whole commandline is matched.
delay_apps=()

###############################################################################
#                                                                             #
#          You should not need to modify anything below this line.            #
#                                                                             #
###############################################################################

###
# Global variables.

## @brief Known screensavers along with delay function names.
declare -A screensavers
screensavers=( ["xscreensaver"]="delayXscreensaver" \
               ["gnome-screensaver"]="delayGnome-screensaver" \
               ["mate-screensaver"]="delayMate-screensaver" \
               ["cinamon-screensaver"]="delayCinamon-screensaver" \
               ["kscreensaver"]="delayKscreensaver" )

###
# Functions.

## @brief Prints some info mesage to stderr.
#
#  stderr is used because some functions return (echo) values to stdout.
info() {
  local date=$(date +"%F %T")
  echo "[$date] $1" >&2
}

## @brief Prints some error mesage to stderr and exits.
error() {
  info "$1"
  exit 1
}

## @brief Checks if any given string matches existing processes using pgrep -f.
#  @param $1..$N List of strings to check.
#  @return string Echoes first string that matches process or nothing.
processesExist() {
  local process

  for process; do
    if $(pgrep -f $process > /dev/null); then
      echo "$process"
      return 0
    fi
  done

  # Not found.
  return 1
}

## @brief Checks if command is available.
#  @param $1 Command name.
commandExits() {
  hash "$1" 2> /dev/null
  return $?
}

## @brief Echoes kscreensaver config file if it exists.
findKscreensaverConfig() {
  local config_file="share/config/kscreensaverrc"
  local kde_home=$(kde4-config --localprefix)
  local kscreensaver_config="$kde_home/$config_file"

  if [[ -r "$kscreensaver_config" ]]; then
    echo $kscreensaver_config
    return 0
  fi

  return 1
}

## @brief Tries to determine which screensaver is in use.
#  @return string Echoes determined screensaver type or 'none'.
findScreensaver() {

  local screensaver

  # Iterate over known screensavers.
  for screensaver in "${!screensavers[@]}"; do
    # Check if process is running.
    if processesExist $screensaver; then
      # If it's running echo its name and return success.
      echo $screensaver
      return 0
    fi
  done

  # Check if KDE screensaver is enabled. New versions of KDE don't use
  # kscreensaver process.

  local kscreensaver_config=$(findKscreensaverConfig)
  if [[ $? -eq 0 ]]; then
    local kscreensaver_enabled=$(grep -m 1 "^Enabled=" \
                                 "$kscreensaver_config" 2>/dev/null)
    if [[ "${kscreensaver_enabled#Enabled=}" == "true" ]]; then
      echo "kscreensaver"
      return 0
    fi
  fi

  # Nothing found, return failure.
  echo "none"
  return 1
}

## @brief Tries to determine if DPMS is enabled.
findDpms() {
  xset -q | grep -c 'DPMS is Enabled' > /dev/null
  return $?
}

## @brief Tries to determine optimal timeout value.
#  @param $1 number Default timeout value (seconds).
#  @param $2 string Screensaver type.
#  @return number Echoes determined timeout.
#
#  This funcion can determine timeout value for xscreensaver and kscreensaver.
#  10 seconds are then substracted from this value to get "optimal" timeout for
#  script. If something fails, default number ($1) is echoed.
findOptimalTimeout() {
  local optimal_timeout=$1

  if [[ "$2" == "xscreensaver" ]]; then
    # xscreensaver timeout value in minutes.
    local x_timeout=$(grep -m 1 timeout ~/.xscreensaver | cut -d ':' -f 3)
    $verbose && info "xscreensaver timeout value: $x_timeout minutes"

    # Make sure number is correct, and value is greater than 1 minute.
    if [[ $x_timeout != *[!0-9]* && $x_timeout -gt 0 ]]; then
      optimal_timeout=$(( $x_timeout * 60 - 10 ))
    else
      $verbose && info "Value is not correct!"
    fi

  elif [[ "$2" == "kscreensaver" ]]; then
    # kscreensaver timeout value in seconds.
    local kscreensaver_config=$(findKscreensaverConfig)
    local k_timeout=$(grep -m 1 "Timeout" "$kscreensaver_config")
    k_timeout=${k_timeout#Timeout=}
    $verbose && info "kscreensaver timeout value: $k_timeout seconds"

    # Make sure number is correct, and value is greater than 10 seconds.
    if [[ $k_timeout != *[!0-9]* && $k_timeout -gt 10 ]]; then
      optimal_timeout=$(( $k_timeout- 10 ))
    else
      $verbose && info "Value is not correct!"
    fi

  else
    $verbose && info "Couldn't find optimal timeout value, using default."
  fi

  echo $optimal_timeout
  return 0
}

## @brief Function that delays xscreensaver.
delayXscreensaver() {
  xscreensaver-command -deactivate > /dev/null
}

## @brief Function that delays gnome-screensaver.
delayGnome-screensaver() {
  dbus-send --session --type=method_call --dest=org.gnome.ScreenSaver \
            --reply-timeout=20000 /org/gnome/ScreenSaver \
            org.gnome.ScreenSaver.SimulateUserActivity > /dev/null
}

## @brief Function that delays mate-screensaver.
#
#  This command should work now:
#  https://github.com/mate-desktop/mate-screensaver/issues/4
delayMate-screensaver() {
  mate-screensaver-command --poke > /dev/null
}

## @brief Function that delays cinamon-screensaver.
delayCinamon-screensaver() {
  cinnamon-screensaver-command --deactivate > /dev/null
}

## @brief Function that delays kscreensaver.
delayKscreensaver() {
  qdbus org.freedesktop.ScreenSaver /ScreenSaver SimulateUserActivity \
        > /dev/null
}

## @brief Function that delays DPMS.
delayDpms() {
  xset -dpms
  xset dpms
}

## @brief Query for active window info.
activeWindowInfo() {
  local active_id=$(xprop -root _NET_ACTIVE_WINDOW)
  # Cut everything to the last space (5th field) to get id.
  xprop -id ${active_id##* }
}

## @brief Determines if selected apps are running fullscreen.
detectFulscreenApps() {
  local window_info=$(activeWindowInfo)

  # Check if active window is fullscreen.
  if grep -q _NET_WM_STATE_FULLSCREEN <<<"$window_info"; then

    # Query for window PID.
    local window_pid=$(grep "_NET_WM_PID(CARDINAL)" <<<"$window_info")
    window_pid=${window_pid#"_NET_WM_PID(CARDINAL) = "}

    $verbose && info "Fulscreen window PID: $window_pid."

    local commandline=$(cat /proc/$window_pid/cmdline)
    local app

    # For each selected fullscreen aplication.
    for app in "${fullscreen_apps[@]}"; do
      # Check if current window commandline matches this application.
      if [[ $commandline =~ $app ]]; then
        $verbose && info "'$app' process matched."
        return 0;
      fi

    done
   fi

  # Nothig found.
  return 1;
}

## @brief Determines if any of processes from users list is running.
detectDelayApps() {
  match=$(processesExist ${delay_apps[@]})

  if [[ $? -eq 0 ]]; then
    $verbose && info "Custom process '$match' is running."
    return 0;
  fi

  return 1;
}

## @brief Calls appropriate delay function when screensaver should be delayed.
#  @param $1 string Screensaver type.
#  @param $2 bool DPMS state.
delayScreensaver() {
  if detectFulscreenApps || detectDelayApps; then
    $verbose && info " ***  Delaying screensaver!"

    if [[ "$1" != "none" ]]; then
      $(${screensavers[$1]})
    fi

    if "$2"; then
      delayDpms
    fi
  fi
}

###
# Script.

$verbose && info "lightsOn-NG"

# Check required commands.
for reqCommand in lsof xset xprop; do
  commandExits "$reqCommand" || error "$reqCommand command not found! Exiting."
done

# Determine screensaver.
screensaver=$(findScreensaver)
if [[ "$screensaver" == "none" ]]; then
  $verbose && info "No known screensaver found."
else
  $verbose && info "Screensaver found: '$screensaver'"
fi

# Determine DPMS status.
if findDpms; then
  has_dpms=true
else
  has_dpms=false
fi
$verbose && info "DPMS: $has_dpms"

# Check if anything can be delayed.
if [[ "$screensaver" == "none" && ! $has_dpms ]]; then
  error "No known screensaver found and DPMS is disabled. Exiting."
fi

# Check argument.
# If argument is empty try to determine optimal timeout or use default value.
if [[ -z "$1" ]]; then
  timeout=$(findOptimalTimeout $default_timeout $screensaver)
else
  # Check if argument is correct.
  if [[ $1 != *[!0-9]* ]]; then
    timeout=$1
  else
    error "The argument '$1' is not valid, positive integer expected. Exiting."
  fi
fi

$verbose && info "Using $timeout seconds as timeout value."

$verbose && info "Setup done, starting loop."

# Main loop.
while true; do
  delayScreensaver "$screensaver" "$has_dpms"
  sleep "$timeout"
done
# autolog.tcl v1.0 (13 July 2000)
# copyright (c) 2000 by slennox <slennox@egghelp.org>
# slennox's eggdrop page - http://www.egghelp.org/
#
# When you want to make your bot keep a logfile for a new channel, you have
# to manually add a new 'logfile' command to the bot's config file. This
# can be a problem if your bot frequently joins new channels and you want
# to keep a log for each. This script automatically enables a logfile for
# each channel the bot joins, so that you don't need to enable it manually.
# The idea for this script came from Zsolt.
#
# v1.0 - Initial release.

# Set the modes for new logfiles. These determine what type of things are
# logged (e.g. 'k' for kicks, bans, and mode changes). These modes are
# explained in the logfile section of eggdrop.conf.dist.
set autolog_modes "jkp"

# Specify how the logfiles should be named. There are two variables you can
# use here:
#  %chan for the channel name
#  %stripchan for the channel name with leading #+&! character removed
set autolog_file "%chan.log"

# The script will create a new logfile for every channel the bot joins for
# which no logfile is already specified. If you have some channels you
# don't want the script to create a log for, specify them here in the
# format "#chan1 #chan2 #etc".
set autolog_exempt ""


# Don't edit below unless you know what you're doing.

proc autolog_join {nick uhost hand chan} {
  global botnick autolog_exempt autolog_file autolog_modes
  if {$nick == $botnick} {
    set stlchan [string tolower $chan]
    if {$autolog_exempt != "" && [lsearch -exact [string tolower [split $autolog_exempt]] $stlchan] != -1} {return 0}
    foreach logfile [logfile] {
      if {[string tolower [lindex $logfile 1]] == $stlchan} {
        return 0
      }
    }
    regsub -all -- "%chan" $autolog_file $chan file
    regsub -all -- "%stripchan" $file [string trim $chan "#+&!"] file
    logfile $autolog_modes $chan $file
  }
  return 0
}

bind join - * autolog_join

putlog "Loaded autolog.tcl v1.0 by slennox"

return

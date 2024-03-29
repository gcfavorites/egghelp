# cronchk.tcl v1.0 (8 November 1999)
# copyright � 1999 by slennox <slennox@egghelp.org>
# slennox's eggdrop page - http://www.egghelp.org/
#
# This script is useful if
# a) You often forget to setup a crontab entry for your bots;
# b) Your crontab entries often magically disappear from the shell after
#    reboots, etc.
#
# Since it's a pain to manually check crontab on each and every shell on a
# regular basis, this script automatically checks your crontab once a day
# and sends you a note if it has become empty.
#
# For this script to work properly, the 'crontab -l' command must be
# accessible on the shell. Login to the shell and type 'crontab -l' to test
# for this. The script also requires the notes module or equivalent to be
# loaded.

# Send a note to these users if the crontab is found to be empty. You must
# set this for the script to work properly. This setting can be one user
# like "Tom", or a list like "Tom Dick Harry".
set cc_note "YourNick"


# Don't edit below unless you know what you're doing.

if {[info commands sendnote] == ""} {
  putlog "cronchk.tcl could not find the notes module or equivalent. Not loading cronchk.tcl."
  return
}

proc cc_check {min hour day month year} {
  global cc_note
  putlog "Checking crontab..."
  catch {exec crontab -l} cron
  if {[string match "no crontab for *" $cron]} {
    foreach recipient [split $cc_note] {
      if {[validuser $recipient]} {
        sendnote CRONCHK $recipient "Crontab was found to be empty."
      }
    }
  }
  return 0
}

bind time - "53 23 * * *" cc_check

putlog "Loaded cronchk.tcl v1.0 by slennox"

return

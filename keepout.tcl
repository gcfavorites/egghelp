# keepout.tcl v1.3 (27 May 2000)
# copyright (c) 1999-2000 by slennox <slennox@egghelp.org>
# slennox's eggdrop page - http://www.egghelp.org/
#
# This script checks users who join +i (invite-only) or +k (keyed)
# channels, kicking and/or banning them if they don't match the specified
# flags. Useful for getting rid of undesirables who join the channel via a
# netsplit.
#
# This script was requested by Bejon.
#
# Note: don't load this script on all bots, as a bot can potentially flood
# itself off the server if it kicks many nicknames who join too quickly.
#
# v1.0 - Initial release.
# v1.3 - Added support for +k channels.
#        Added support for ban type if Moretools.tcl is loaded.
#        Added a logfile entry option.

# Channels in which to enable the script. This can be one channel like
# "#good", a list of channels like "#good #bad #ugly", or "" for all
# channels. The script will only be active if the channel is +i and/or +k.
set ko_chans ""

# Flags for users who are allowed in +i and +k channels (in
# globalflags|chanflags format).
set ko_flags "fo|fo"

# Length of time to ban (in minutes). If you want the script to kick only,
# set this to 0.
set ko_ban 0

# Ban type. This feature requires Moretools.tcl. If Moretools.tcl isn't
# loaded, the ban type will be *!*@host.domain.
#  0 - *!user@host.domain
#  1 - *!*user@host.domain
#  2 - *!*@host.domain
#  3 - *!*user@*.domain
#  4 - *!*@*.domain
#  5 - nick!user@host.domain
#  6 - nick!*user@host.domain
#  7 - nick!*@host.domain
#  8 - nick!*user@*.domain
#  9 - nick!*@*.domain
set ko_bantype 0

# Specify the kick/ban reason.
set ko_reason "keep out"

# Add a logfile entry when an unknown user enters a +i or +k channel? 1 to
# enable, 0 to disable.
set ko_log 1


# Don't edit below unless you know what you're doing.

proc ko_join {nick uhost hand chan} {
  global ko_ban ko_bantype ko_chans ko_flags ko_log ko_reason
  if {(($ko_chans != "") && ([lsearch -exact $ko_chans [string tolower $chan]] == -1))} {return 0}
  set chanmodes [lindex [getchanmode $chan] 0]
  if {((([string match *i* $chanmodes]) || ([string match *k* $chanmodes])) && (![matchattr $hand $ko_flags $chan]))} {
    putserv "KICK $chan $nick :$ko_reason"
    if {$ko_ban} {
      if {[info commands masktype] != ""} {
        set ban [masktype $nick!$uhost $ko_bantype]
      } else {
        set ban *!*[string tolower [string range $uhost [string first @ $uhost] end]]
      }
      newchanban $chan $ban keepout $ko_reason $ko_ban
    }
    if {$ko_log} {
      putlog "keepout: unknown user $nick!$uhost entered $chan"
    }
  }
  return 0
}

set ko_chans [split [string tolower $ko_chans]]

bind join - * ko_join

putlog "Loaded keepout.tcl v1.3 by slennox"

return

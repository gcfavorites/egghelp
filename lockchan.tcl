# lockchan.tcl v1.5 (22 November 1998) by slennox <slenny@ozemail.com.au>
#
# This script temporarily sets modes +mi on channels which are being CTCP
# flooded. It's designed to stop flooders before they're able to flood
# users off your channel. It now also sets +i on channels where the ban
# list has become full, and protects your bot from CTCP floods.
#
# There are also two public commands for global/channel +o users to lock
# or open the channel manually ("lc" for lock, "oc" for open). These can
# now be disabled if desired.
#
# Note that this script has only been tested for eggdrop 1.3.x.
#
# Note: At the moment the script only handles one channel CTCP flood at a
# time. That is, it won't respond to any flood in other channels until
# $locktime has expired - which is two minutes by default. So if your bot
# is on channels #abc and #xyz, and both channels are flooded within
# $locktime seconds of one another, lockchan will only set +mi on the
# channel from which it detected the flood first. However if #abc and #xyz
# are flooded more than $locktime seconds apart, lockchan will deal with
# both floods.
#
# Credits: the flood protection mechanism is based on that used in
# DeathHand's bitchxpack.tcl, and the +i on full ban list borrows a bit
# from Salvation's bansfull.tcl. I'd also like to thank guppy for his
# helpful suggestions.
#
# v1.0 - Initial release
# v1.1 - Minor update to streamline CTCP bindings to only those types which
# reply when to sent to channel (also added PING and TIME - did I miss any?)
# v1.2 - Added flood protection for bot (not just channels), changed
# chanlocktime timer to a utimer, +mi is no longer removed automatically
# after using "lc" public command
# v1.3 - Added +i on full channel ban list (very important as the bot can
# flood itself off or crash if it keeps trying to kickban floodbots while
# the ban list is full), added option to notice channel after setting +mi
# or +i on CTCP floods and full ban lists respectively, added option to
# switch public commands on/off
# v1.4 - Oops, fixed problem with new +i on full ban list which would have
# potentially sent multiple unnecessary mode changes and notices, also
# added putlog entry when reacting to full ban list
# v1.5 - Streamlined script a bit (especially 'if' stuff), rebound 'lc' and
# 'oc' public commands to +m users only
#
# For better channel protection, I highly recommend you use a channel
# userlimiter script, such as chanlimit1.0.tcl, in combination with this
# script.
#
# If you like the features of lockchan.tcl and also need BitchX cloaking,
# be sure to check out sentinel.tcl.

# Allow $chanfloodctcp channel CTCPs in $chanfloodtime seconds
set chanfloodctcp 4
set chanfloodtime 20

# Length of time in seconds to lock channel if CTCP flooded
set chanlocktime 120

# Allow $botfloodctcp CTCPs to bot in $botfloodtime seconds
set botfloodctcp 5
set botfloodtime 30

# Notice channel after setting +mi if CTCP flooded?
set ctcpnotice 1

# If set to notice channel when CTCP flooded, what notice to send?
set ctcpnoticemsg "Channel locked temporarily due to CTCP flood, sorry for any inconvenience this may cause :-)"

# Number of bans to allow in the channel ban list before setting the channel invite-only
set maxbans 18

# Notice channel after setting +i if ban list is full?
set bannotice 1

# If set to notice channel when ban list is full, what notice to send?
set bannoticemsg "Channel locked due to full ban list, sorry for any inconvenience this may cause :-)"

# Enable 'lc' and 'oc' public commands for locking/opening channel?
set lockcommands 1


# Don't edit anything below unless you know what you're doing

proc lockflood {nick uhost handle dest key arg} {
  global chanlocktime chanflooded chanfloodcheck chanfloodctcp chanfloodtime floodedchan ctcpnotice ctcpnoticemsg
  set lockfloodchan [string tolower $dest]
  if {[string match *$lockfloodchan* [string tolower [channels]]]} {
    if {[botisop $lockfloodchan] && !$chanflooded} {
      incr chanfloodcheck
      utimer $chanfloodtime chanfloodreset
      if {$chanfloodcheck > $chanfloodctcp} {
        putserv "MODE $lockfloodchan +mi"
        set floodedchan $lockfloodchan
        utimer $chanlocktime { putserv "MODE $floodedchan -mi" }
        putlog "lockchan: channel CTCP flood detected on $lockfloodchan! Channel locked temporarily."
        set chanflooded 1
        utimer $chanlocktime "set chanflooded 0"
        if {$ctcpnotice} {
          putserv "NOTICE $lockfloodchan :$ctcpnoticemsg"
        }
        return 1
      }
    }
  }
   
  global botflooded botfloodcheck botfloodctcp botfloodtime
  incr botfloodcheck
  utimer $botfloodtime botfloodreset
  if {$botflooded} {return 1}
  if {$botfloodcheck > $botfloodctcp} {
    putlog "lockchan: CTCP flood detected on me! Stopped answering CTCPs temporarily."
    set botflooded 1
    utimer $botfloodtime "set botflooded 0"
    return 1
  }
}

proc chanfloodreset {} {
  global chanfloodcheck
  incr chanfloodcheck -1
}

proc botfloodreset {} {
  global botfloodcheck
  incr botfloodcheck -1
}

proc lockchan {nick uhost handle channel arg} {
  putserv "MODE $channel +mi"
  putcmdlog "lockchan: channel lock requested by $handle on $channel."
}

proc unlock {nick uhost handle channel arg} {
  putserv "MODE $channel -mi"
  putcmdlog "lockchan: channel unlock requested by $handle on $channel."
}

proc bansfull {nick uhost handle channel mchange} {
  global maxbans bannotice bannoticemsg waitfori
  set mode [lindex $mchange 0]
  if {$mode != "+b" || $waitfori || [string match +*i* [lindex [getchanmode $channel] 0]] || ![botisop $channel]} {return 0}
    set numbans [llength [chanbans $channel]]
    if {$numbans >= $maxbans} {
      putserv "MODE $channel +i"
      set waitfori 1
      utimer 3 "set waitfori 0"
      putlog "lockchan: locked $channel due to full ban list."
      if {$bannotice} {
        putserv "NOTICE $channel :$bannoticemsg"
      }
    }
  }
}

set chanfloodcheck 0
set botfloodcheck 0
set chanflooded 0
set botflooded 0
set waitfori 0

set lockversion "v1.5"

if {$lockcommands} {
  bind pub m|m lc lockchan
  bind pub m|m oc unlock
}
bind ctcp - ACTION lockflood
bind ctcp - CLIENTINFO lockflood
bind ctcp - DCC lockflood
bind ctcp - ECHO lockflood
bind ctcp - ERRMSG lockflood
bind ctcp - FINGER lockflood
bind ctcp - PING lockflood
bind ctcp - SED lockflood
bind ctcp - TIME lockflood
bind ctcp - USERINFO lockflood
bind ctcp - UTC lockflood
bind ctcp - VERSION lockflood
bind mode - * bansfull

putlog "Loaded lockchan.tcl $lockversion by slennox"
putlog "- Allowing $chanfloodctcp channel CTCPs in $chanfloodtime seconds"
putlog "- Channel locktime is $chanlocktime seconds"
putlog "- Allowing $botfloodctcp CTCPs to bot in $botfloodtime seconds"
putlog "- Allowing $maxbans bans in channel ban list"

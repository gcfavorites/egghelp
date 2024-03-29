# mainserver.tcl v1.04 (31 January 1999) by slennox <slenny@ozemail.com.au>
# Latest versions can be found at www.ozemail.com.au/~slenny/eggdrop/
#
# This script tries to keep a bot on a particular server. Useful if you
# have two or more bots and you wish to keep them on different servers
# which you know each is able to connect to, but also need other servers in
# the config file list for backup.
#
# DCC commands
# .mainserver to display server/timer details for the bot
# .mainservers to display server details for all linked bots
# .jumpreset to restart the server checking timer
#
# Note that this script has only been tested for eggdrop 1.3.x
#
# v1.00 - Initial release
# v1.01 - Needed to add 'checktime' as a global variable to tryagain proc
# v1.02 - Fixed another problem with tryagain proc which failed to reset
# timer if bot is unable to jump
# v1.03 - Added option to set how many other bots need to be on 'checkchan'
# before jumping and added check to make sure those bots are linked
# v1.04 - Oops, tryagain proc was running timer for doublecheck instead of
# forgetit proc
#
# Credits: many thanks to guppy for his helpful suggestions.

# Server you want the bot to stay on - this needs to be the actual server
# name, e.g. if connecting to irc.chitchat.net puts your bot on
# irc1.chitchat.net this must be the latter. This server should also be the
# first server in the bot config file server list.
set mainserver "irc1.chitchat.net"

# Port to connect to
set mainport 6667

# How frequently the bot should check to see if it's on its main server (in
# minutes)
set checktime 30

# If the bot fails to reconnect to its main server, time before trying once
# more (in minutes)
set tryagain 240

# Who to send a note to if the bot fails to connect to its main server
# after the second attempt
set failnote "yournick"

# Before I jump, check this channel for other opped and linked bots to make
# sure I will be reopped after jumping
set checkchan "#yourchannel"

# Number of other opped and linked bots required before bot will jump
set needbots 2


# Don't edit below unless you know what you're doing

if {![info exists mainloaded]} {
  set mainloaded 1
  set failedjump 0
  timer $checktime checkserver
}

proc checkserver {} {
  global server mainserver mainport checkchan checktime needbots
  if {[string tolower [lindex [split $server :] 0]] != [string tolower [lindex [split $mainserver :] 0]]} {
    putlog "mainserver: I'm not on $mainserver - checking to see if I can jump.."
    set foundbot 0
    foreach jumpbot [bots] {
      if {[matchattr $jumpbot b] && [matchattr $jumpbot o|o $checkchan] && [isop [hand2nick $jumpbot $checkchan] $checkchan] && ![onchansplit [hand2nick $jumpbot $checkchan] $checkchan] && [string match *$jumpbot* [bots]]} {
        incr foundbot 1
        if {$foundbot >= $needbots} {
          putlog "mainserver: found $needbots bots to reop me on rejoin - jumping to $mainserver"
          jump $mainserver $mainport
          utimer 60 doublecheck
          return 0
        }
      }
    }
    putlog "mainserver: I can't jump because there aren't $needbots other bots to reop me when I rejoin my channels."
    timer $checktime checkserver
  } else {
    timer $checktime checkserver
  }
}

proc doublecheck {} {
  global server mainserver mainport mainjump checktime tryagain failedjump
  if {[string tolower [lindex [split $server :] 0]] != [string tolower [lindex [split $mainserver :] 0]]} {
    putlog "mainserver: failed to connect to $mainserver - will try once more in $tryagain minutes."
    set failedjump 1
    timer $tryagain tryagain
  } else {
    set failedjump 0
    putlog "mainserver: successful jump to $mainserver detected."
    timer $checktime checkserver
  }
}

proc tryagain {} {
  global server mainserver mainport checkchan checktime tryagain needbots
  if {[string tolower [lindex [split $server :] 0]] != [string tolower [lindex [split $mainserver :] 0]]} {
    putlog "mainserver: failed to connect to $mainserver $tryagain minutes ago - trying once more.."
    set foundbot 0
    foreach jumpbot [bots] {
      if {[matchattr $jumpbot b] && [matchattr $jumpbot o|o $checkchan] && [isop [hand2nick $jumpbot $checkchan] $checkchan] && ![onchansplit [hand2nick $jumpbot $checkchan] $checkchan] && [string match *$jumpbot* [bots]]} {
        incr foundbot 1
        if {$foundbot >= $needbots} {
          putlog "mainserver: found $needbots bots to reop me on rejoin - jumping to $mainserver"
          jump $mainserver $mainport
          utimer 60 forgetit
          return 0
        }
      }
    }
    putlog "mainserver: I can't jump because there aren't $needbots other bots to reop me when I rejoin my channels - will try again in $tryagain minutes."
    timer $tryagain tryagain
  } else {
    set failedjump 0
    timer $checktime checkserver
  }
}

proc forgetit {} {
  global server mainserver failnote checktime failedjump mainloaded
  if {[string tolower [lindex [split $server :] 0]] != [string tolower [lindex [split $mainserver :] 0]]} {
    putlog "mainserver: failed to connect to $mainserver on second attempt - sent note to inform $failnote"
    set failedjump 2
    set mainloaded 0
    sendnote MAINSERVER $failnote "Failed to connect to $mainserver"
  } else {
    set failedjump 0
    putlog "mainserver: successful jump to $mainserver detected."
    timer $checktime checkserver
  }
}

proc dcc_mainserver {handle idx arg} {
  global failedjump mainserver mainport server mainversion {default-port}
  if {$arg != ""} {
    set mainserver [lindex $arg 0]
    set mainport [lindex $arg 1]
    if {$mainport == ""} {
      putidx $idx "Temporarily changed main server to $mainserver:${default-port}"
    } else {
      putidx $idx "Temporarily changed main server to $mainserver:$mainport"
    }
    return 0
  }
  putidx $idx "mainserver.tcl $mainversion by slennox"
  putidx $idx "Use .mainserver <server> <port> to temporarily change main server."
  putidx $idx "This bot's main server is: $mainserver:$mainport"
  if {[string tolower [lindex [split $server :] 0]] == $mainserver} {
    putidx $idx "Connected to my main server :-)"
  } elseif {$server == ""} {
    putidx $idx "Not connected to a server."
  } else {
    putidx $idx "Connected to: $server"
  }
  if {$failedjump==1} {
    putidx $idx "Jump status: failed first attempt to connect to $mainserver"
  }
  if {$failedjump==2} {
    putidx $idx "Jump status: failed both attempts to connect to $mainserver"
  }
  foreach timer [timers] {
    if {[lindex $timer 1] != "checkserver"} {continue}
    putidx $idx "Timer status: [lindex $timer 0] minutes until the next server check."
    set timeron 1
  }
  foreach timer [timers] {
    if {[lindex $timer 1] != "tryagain"} {continue}
    putidx $idx "Timer status: [lindex $timer 0] minutes until the second attempt to connect to $mainserver"
    set timeron 1
  }
  foreach timer [utimers] {
    if {[lindex $timer 1] != "doublecheck"} {continue}
    putidx $idx "Timer status: waiting to check if attempt to jump to $mainserver was successful.."
    set timeron 1
  }
  foreach timer [utimers] {
    if {[lindex $timer 1] != "forgetit"} {continue}
    putidx $idx "Timer status: waiting to check if second attempt to jump to $mainserver was successful.."
    set timeron 1
  }
  if {![info exists timeron]} {
    putidx $idx "Timer status: server checking not active - use .jumpreset to restart the timer."
  }
}

proc dcc_mainservers {handle idx arg} {
  global botnick server mainserver mainport whoreq
  set whoreq [hand2idx $handle]
  if {$server == ""} {
    putidx $idx "$botnick is not connected to a server (main server is $mainserver:$mainport)"
  } elseif {[string tolower [lindex [split $server :] 0]] == $mainserver} {
    putidx $idx "$botnick is connected to $server (its main server)"
  } else {
    putidx $idx "$botnick is connected to $server (main server is $mainserver:$mainport)"
  }
  putallbots "give_mainservers"
}

proc give_mainservers {frombot command arg} {
  global botnick server mainserver mainport
  if {$server == ""} {
    set currserver "none"
  } else {
    set currserver $server
  }
  putbot $frombot "reply_mainservers $currserver $mainserver $mainport"
}

proc reply_mainservers {frombot command arg} {
  global whoreq
  set serveron [lindex $arg 0]
  set servermain [lindex $arg 1]
  set serverport [lindex $arg 2]
  if {$serveron == "none"} {
    putidx $whoreq "$frombot is not connected to a server (main server is $servermain:$serverport)"
  } elseif {[string tolower [lindex [split $serveron :] 0]] == $servermain} {
    putidx $whoreq "$frombot is connected to $serveron (its main server)"
  } else {
    putidx $whoreq "$frombot is connected to $serveron (main server is $servermain:$serverport)"
  }
}

proc dcc_jumpreset {handle idx arg} {
  global mainloaded mainserver failedjump checktime
  if {$mainloaded} {
    putidx $idx "Timer is already running."
  } else {
    set mainloaded 1
    set failedjump 0
    timer $checktime checkserver
    putidx $idx "Reset mainserver.tcl timer, will resume checking to make sure I'm on $mainserver"
  }
}

set mainversion "v1.04"

bind dcc n|n mainserver dcc_mainserver
bind dcc n|n mainservers dcc_mainservers
bind dcc n|n jumpreset dcc_jumpreset
bind bot - give_mainservers give_mainservers
bind bot - reply_mainservers reply_mainservers

putlog "Loaded mainserver.tcl $mainversion by slennox"
putlog "This bot's main server is: $mainserver:$mainport"

# botnetop.tcl v2.23 (27 February 2001)
# copyright (c) 1998-2001 by slennox <slennox@egghelp.org>
# slennox's eggdrop page - http://www.egghelp.org/

# This script was written mainly as an alternative to getops.tcl. It allows
# linked bots to securely give ops to one another on their channels. It
# also automatically invites linked bots to channels which are invite-only,
# shares keys with linked bots for channels which are keyed, raises a
# channel's limit if a bot can't get in because the channel is full, unbans
# a bot if it can't get in because it matches a ban, and automatically adds
# new hostmasks when a bot's user@host info has changed. There is a delayed
# op mechanism to prevent mode +o flooding whenever a bot joins a channel,
# and op/invite checking routines are significantly more secure than those
# in getops.tcl.
#
# botnetop.tcl v2.xx is compatible with bots running older versions of
# botnetop.tcl (v1.00 and up) and bots running the botnetop.tcl component
# of netbots.tcl.
#
# Note that this script was developed on the eggdrop 1.3, 1.4, and 1.6
# series and may not work properly on other versions.
#
# v2.00 - New standalone release. Contains refinements and features from
#         the netbots.tcl version of botnetop.tcl.
# v2.02 - Improved support for leading +-^= characters in hostmasks.
#         Fixed 'islinked' problem on eggdrop 1.3.24 and earlier.
# v2.10 - Requests to unopped bots were causing high CPU usage and botnet
#         traffic on some large opless botnets - rewrote proc to request
#         from opped bots only.
#         Added bop_modeop feature to provide faster opping.
#         Convinced myself to change putquick back to pushmode (suits
#         bop_modeop better).
# v2.20 - pushmode sanity checking in eggdrop 1.4+ prevents bop_osync from 
#         working properly - putquick is now automatically used when
#         bop_osync is enabled on a 1.4+ bot.
#         Fixed bug in bop_reqop that was causing "bot is not in the
#         botnet" errors.
#         Updated to support eggdrop 1.6 (includes 'bind need' support),
#         requires only a single need bind for all requests.
#         Variables are now cleared after removing a channel.
#         Removed unnecessary botonchan checks throughout components where
#         botisop already checks for that.
#         Removed all unnecessary use of parentheses.
#         bop_needi was not defined as a global variable in bop_settimer.
# v2.21 - Universal need bind could cause bop_ errors on 1.6 bots.
# v2.23 - Added bop_clearneeds to eliminate need-related errors.
#         Made bop_settimer aggressive again.
#         Removed unused putquick compatibility proc.

# Maximum number of seconds to delay before asking a non-opped bot if it
# needs ops. This is used by the bot giving ops. Higher settings help
# reduce +o flooding when a bot joins. Note that the delay is automatically
# skipped if there are fewer than 3 bots opped on the channel.
set bop_delay 20
# Valid settings: 0 to disable delayed op, otherwise 1 or higher.

# Maximum number of bots to request ops from at a time. This is used by the
# bot requesting ops. This feature can completely eliminate +o flooding
# when a bot joins, but the bot will request ops from fewer bots.
set bop_maxreq 3
# Valid settings: 0 to disable, otherwise 1 or higher.

# More info on bop_delay and bop_maxreq can be found at the end of this
# documentation section.

# Make the bot send an op request when it sees a bot become opped on a
# channel? This will make your bot get ops sooner when another bot is given
# ops.
set bop_modeop 0
# Valid settings: 1 to enable, 0 to disable.

# Make the bot send an op request when a bot links? This will make your bot
# get ops sooner if linking is delayed, and provides a better chance of the
# bots opping one another if there are linking problems.
set bop_linkop 1
# Valid settings: 1 to enable, 0 to disable.

# Check a bot's user@host before inviting it to a channel? Normally, the
# bot can sometimes invite the wrong user to +i channel if there are splits
# occurring. Enabling this check can prevent that.
set bop_icheck 0
# Valid settings: 1 to enable, 0 to disable.

# Give ops to a bot even if it looks like it's already opped on the
# channel? Normally, the script will ignore a request for ops from a bot if
# that bot is already opped. But in some desync situations, a bot may
# appear to be opped even when it isn't, so you might want to enable this
# if you often have desync problems. Note that enabling this can result in
# +o flooding.
set bop_osync 0
# Valid settings: 1 to enable, 0 to disable.

# Let the script automatically add new hostmasks for bots? (e.g. if you
# change a bot's vhost). This feature doesn't work all the time due to
# complications with protect-telnet, strict-host, bot host sharing flaws,
# security concerns, etc., but it's convenient when it works.
set bop_addhost 0
# Valid settings: 1 to enable, 0 to disable.

# By default, botnetop.tcl logs all ops, op requests, invite/key
# limit/unban requests/responses, and host additions. This
# setting lets you reduce the amount of logging.
set bop_log 2
# Valid settings: 2 to enable all logging, 1 to disable logging of ops/op
# requests, 0 to disable all logging except host additions.

# About the bop_delay and bop_maxreq settings: botnetop.tcl uses two
# methods to reduce/eliminate mode +o flooding - bop_delay is used by the
# bot giving ops, while bop_maxreq is used by the bot asking for ops. You
# can use both features, one or the other, or disable both. Below is an
# explanation of some possible combinations.
#
# bop_delay 20; bop_maxreq 0: all bots will ask a non-opped bot if it needs
# ops after a delay of between 0-20 seconds (different bots will delay for
# different amounts of time). The bot that needs ops will respond to all
# offers.
#
# bop_delay 0; bop_maxreq 2: all bots will ask a non-opped bot if it needs
# ops without any delay. The bot that needs ops will respond to a maximum
# of 2 offers.
#
# bop_delay 20; bop_maxreq 3: all bots will ask a non-opped bot if it needs
# ops after a delay of between 0-20 seconds. The bot that needs ops will
# respond to a maximum of 3 offers.
#
# bop_delay 0; bop_maxreq 0: all bots will ask a non-opped bot if it needs
# ops without any delay. The bot that needs ops will respond to all offers.


# Don't edit below unless you know what you're doing.

if {$numversion < 1032500} {
  proc islinked {bot} {
    if {[lsearch -exact [string tolower [bots]] [string tolower $bot]] == -1} {return 0}
    return 1
  }
  if {$numversion < 1032400} {
    proc botonchan {chan} {
      global botnick
      if {![validchan $chan]} {
        error "illegal channel: $chan"
      } elseif {![onchan $botnick $chan]} {
        return 0
      }
      return 1
    }
  }
}

proc bop_jointmr {nick uhost hand chan} {
  global bop_asktmr bop_delay botnick numversion
  if {$nick != $botnick} {
    if {![matchattr $hand b] || ![matchattr $hand o|o $chan] || [matchattr $hand d|d $chan]} {return 0}
    set stlchan [string tolower $chan]
    if {[info exists bop_asktmr($hand:$stlchan)]} {return 0}
    set bop_asktmr($hand:$stlchan) 1
    if {!$bop_delay || [bop_lowbots $chan]} {
      utimer 5 [split "bop_askbot $hand $chan"]
    } else {
      utimer [expr [rand $bop_delay] + 5] [split "bop_askbot $hand $chan"]
    }
  } else {
    bop_setneed $chan
  }
  return 0
}

proc bop_linkop {bot via} {
  global botnet-nick
  if {$bot == ${botnet-nick} || $via == ${botnet-nick}} {
    if {![string match *bop_linkreq* [utimers]]} {
      utimer 2 bop_linkreq
    }
  }
  return 0
}

proc bop_linkreq {} {
  foreach chan [channels] {
    if {![botisop $chan]} {
      bop_reqop $chan op
    }
  }
  return
}

proc bop_reqop {chan need} {
  global bop_needi
  if {![info exists bop_needi([string tolower $chan])]} {
    bop_setneed $chan
  }
  if {$need == "op"} {
    foreach bot [chanlist $chan b] {
      if {[isop $bot $chan] && [matchattr [set hand [nick2hand $bot $chan]] o|o $chan] && [islinked $hand]} {
        putbot $hand "reqops $chan"
      }
    }
  } else {
    bop_letmein $chan $need
  }
  return 0
}

if {$bop_modeop} {
proc bop_modeop {nick uhost hand chan mode opped} {
  global botnick
  if {$mode == "+o" && ![botisop $chan] && $nick != $botnick && $opped != $botnick && [matchattr [set obot [nick2hand $opped $chan]] b] && [matchattr $obot o|o $chan] && [islinked $obot]} {
    putbot $obot "reqops $chan"
  }
  return
}
}

proc bop_reqtmr {frombot cmd arg} {
  global bop_asktmr bop_delay
  set chan [lindex [split $arg] 0]
  if {![validchan $chan]} {return 0}
  if {![matchattr $frombot b] || ![matchattr $frombot o|o $chan] || [matchattr $frombot d|d $chan]} {return 0}
  set stlchan [string tolower $chan]
  if {[info exists bop_asktmr($frombot:$stlchan)]} {return 0}
  set bop_asktmr($frombot:$stlchan) 1
  if {!$bop_delay || [bop_lowbots $chan]} {
    utimer 2 [split "bop_askbot $frombot $chan"]
  } else {
    utimer [expr [rand $bop_delay] + 2] [split "bop_askbot $frombot $chan"]
  }
  return 0
}

proc bop_askbot {hand chan} {
  global botnick bop_asktmr
  set stlchan [string tolower $chan]
  if {[info exists bop_asktmr($hand:$stlchan)]} {
    unset bop_asktmr($hand:$stlchan)
  }
  if {![validchan $chan] || ![botonchan $chan] || ![botisop $chan]} {return 0}
  if {![matchattr $hand b] || ![matchattr $hand o|o $chan] || [matchattr $hand d|d $chan]} {return 0}
  if {![islinked $hand]} {return 0}
  putbot $hand "doyawantops $chan $botnick"
  return 0
}

proc bop_doiwantops {frombot cmd arg} {
  global bop_log bop_maxreq bop_opreqs botname botnick
  set chan [lindex [split $arg] 0] ; set fromnick [lindex [split $arg] 1]
  if {![validchan $chan] || ![botonchan $chan] || [botisop $chan]} {return 0}
  set stlchan [string tolower $chan]
  if {$bop_maxreq && $bop_opreqs($stlchan) >= $bop_maxreq} {return 0}
  if {![onchan $fromnick $chan] || [onchansplit $fromnick $chan] || ![isop $fromnick $chan]} {return 0}
  if {![matchattr [nick2hand $fromnick $chan] o|o $chan]} {return 0}
  if {![islinked $frombot]} {return 0}
  putbot $frombot "yesiwantops $chan $botnick [string trimleft [lindex [split $botname !] 1] "~+-^="]"
  incr bop_opreqs($stlchan)
  if {$bop_maxreq} {
    bop_killutimer "bop_opreqsreset $stlchan"
    utimer 30 [split "bop_opreqsreset $stlchan"]
  }
  if {$bop_log >= 2} {
    putlog "botnetop: requested ops from $frombot on $chan"
  }
  return 0
}

proc bop_botwantsops {frombot cmd arg} {
  global bop_addhost bop_log bop_osync numversion strict-host
  set chan [lindex [split $arg] 0] ; set fromnick [lindex [split $arg] 1] ; set fromhost [lindex [split $arg] 2]
  if {![botonchan $chan] || ![botisop $chan]} {return 0}
  if {![onchan $fromnick $chan] || [onchansplit $fromnick $chan]} {return 0}
  if {![matchattr $frombot b] || ![matchattr $frombot o|o $chan] || [matchattr $frombot d|d $chan]} {return 0}
  if {$fromhost != "" && $fromhost != [string trimleft [getchanhost $fromnick $chan] "~+-^="]} {return 0}
  if {![matchattr [nick2hand $fromnick $chan] o|o $chan]} {
    if {$fromhost == "" || !$bop_addhost} {return 0}
    if {${strict-host} == 0} {
      set host *![string trimleft [getchanhost $fromnick $chan] "~+-^="]
    } else {
      set host *![getchanhost $fromnick $chan]
    }
    setuser $frombot HOSTS $host
    putlog "botnetop: added host $host to $frombot"
  }
  if {$bop_osync} {
    if {$numversion < 1040000} {
      pushmode $chan +o $fromnick
    } else {
      putquick "MODE $chan +o $fromnick"
    }
  } else {
    if {[isop $fromnick $chan]} {return 0}
    pushmode $chan +o $fromnick
  }
  if {$bop_log >= 2} {
    if {$fromnick != $frombot} {
      putlog "botnetop: gave ops to $frombot (using nick $fromnick) on $chan"
    } else {
      putlog "botnetop: gave ops to $frombot on $chan"
    }
  }
  return 0
}

proc bop_letmein {chan need} {
  global botname botnick bop_log bop_needk bop_needi bop_needl bop_needu
  if {[bots] == "" || [botonchan $chan]} {return 0}
  set stlchan [string tolower $chan]
  switch -exact -- $need {
    "key" {
      if {$bop_needk($stlchan)} {return 0}
      set reqlist ""
      foreach bot [bots] {
        if {![matchattr $bot b] || ![matchattr $bot o|o $chan]} {continue}
        putbot $bot "wantkey $chan $botnick"
        lappend reqlist $bot
      }
      if {$bop_log >= 1 && $reqlist != ""} {
        regsub -all -- " " [join $reqlist] ", " reqlist
        putlog "botnetop: requested key for $chan from $reqlist"
      }
      set bop_needk($stlchan) 1
      utimer 30 [split "set bop_needk($stlchan) 0"]
    }
    "invite" {
      if {$bop_needi($stlchan)} {return 0}
      set reqlist ""
      foreach bot [bots] {
        if {![matchattr $bot b] || ![matchattr $bot o|o $chan]} {continue}
        if {$botname != ""} {
          putbot $bot "wantinvite $chan $botnick [string trimleft [lindex [split $botname !] 1] "~+-^="]"
        } else {
          putbot $bot "wantinvite $chan $botnick"
        }
        lappend reqlist $bot
      }
      if {$bop_log >= 1 && $reqlist != ""} {
        regsub -all -- " " [join $reqlist] ", " reqlist
        putlog "botnetop: requested invite to $chan from $reqlist"
      }
      set bop_needi($stlchan) 1
      utimer 30 [split "set bop_needi($stlchan) 0"]
    }
    "limit" {
      if {$bop_needl($stlchan)} {return 0}
      set reqlist ""
      foreach bot [bots] {
        if {![matchattr $bot b] || ![matchattr $bot o|o $chan]} {continue}
        putbot $bot "wantlimit $chan $botnick"
        lappend reqlist $bot
      }
      if {$bop_log >= 1 && $reqlist != ""} {
        regsub -all -- " " [join $reqlist] ", " reqlist
        putlog "botnetop: requested limit raise on $chan from $reqlist"
      }
      set bop_needl($stlchan) 1
      utimer 30 [split "set bop_needl($stlchan) 0"]
    }
    "unban" {
      if {$bop_needu($stlchan)} {return 0}
      set reqlist ""
      foreach bot [bots] {
        if {![matchattr $bot b] || ![matchattr $bot o|o $chan]} {continue}
        putbot $bot "wantunban $chan $botnick $botname"
        lappend reqlist $bot
      }
      if {$bop_log >= 1 && $reqlist != ""} {
        regsub -all -- " " [join $reqlist] ", " reqlist
        putlog "botnetop: requested unban on $chan from $reqlist"
      }
      set bop_needu($stlchan) 1
      utimer 30 [split "set bop_needu($stlchan) 0"]
    }
  }
  return 0
}

proc bop_botwantsin {frombot cmd arg} {
  global bop_icheck bop_log bop_who
  set chan [lindex [split $arg] 0]
  if {![validchan $chan] || ![botisop $chan]} {return 0}
  if {![matchattr $frombot b] || ![matchattr $frombot fo|fo $chan]} {return 0}
  set fromhost [lindex [split $arg] 2]
  switch -exact -- $cmd {
    "wantkey" {
      if {[string match *k* [lindex [split [getchanmode $chan]] 0]]} {
        putbot $frombot "thekey $chan [lindex [split [getchanmode $chan]] 1]"
        if {$bop_log >= 1} {
          putlog "botnetop: gave key for $chan to $frombot"
        }
      }
    }
    "wantinvite" {
      set fromnick [lindex [split $arg] 1]
      if {$bop_icheck && $fromhost != ""} {
        if {![info exists bop_who($fromnick)]} {
          set bop_who($fromnick) "$chan $frombot $fromhost"
          utimer 60 [split "bop_whounset $fromnick"]
        }
        putserv "WHO $fromnick"
      } else {
        putserv "INVITE $fromnick $chan"
        if {$bop_log >= 1} {
          if {$fromnick != $frombot} {
            putlog "botnetop: invited $frombot (using nick $fromnick) to $chan"
          } else {
            putlog "botnetop: invited $frombot to $chan"
          }
        }
      }
    }
    "wantlimit" {
      pushmode $chan +l [expr [llength [chanlist $chan]] + 1]
      if {$bop_log >= 1} {
        putlog "botnetop: raised limit on $chan as requested by $frombot"
      }
    }
    "wantunban" {
      foreach ban [chanbans $chan] {
        if {[string match [string tolower [lindex $ban 0]] [string tolower $fromhost]]} {
          pushmode $chan -b [lindex $ban 0]
          if {$bop_log >= 1} {
            putlog "botnetop: unbanned $frombot on $chan"
          }
        }
      }
    }
  }
  return 0
}

proc bop_who {from keyword arg} {
  global bop_log bop_who
  set fromnick [lindex [split $arg] 5]
  if {[info exists bop_who($fromnick)]} {
    set chan [lindex [split $bop_who($fromnick)] 0] ; set frombot [lindex [split $bop_who($fromnick)] 1] ; set fromhost [lindex [split $bop_who($fromnick)] 2]
    unset bop_who($fromnick)
    if {$fromhost == [string trimleft [lindex [split $arg] 2]@[lindex [split $arg] 3] "~+-^="]} {
      putserv "INVITE $fromnick $chan"
      if {$bop_log >= 1} {
        if {$fromnick != $frombot} {
          putlog "botnetop: invited $frombot (using nick $fromnick) to $chan"
        } else {
          putlog "botnetop: invited $frombot to $chan"
        }
      }
    }
  }
  return 0
}

proc bop_whounset {fromnick} {
  global bop_who
  if {[info exists bop_who($fromnick)]} {
    unset bop_who($fromnick)
  }
  return
}

proc bop_joinkey {frombot cmd arg} {
  global bop_kjoin
  set chan [lindex [split $arg] 0] ; set stlchan [string tolower $chan]
  if {[botonchan $chan] || $bop_kjoin($stlchan)} {return 0}
  putserv "JOIN $chan [lindex [split $arg] 1]"
  set bop_kjoin($stlchan) 1
  utimer 10 [split "set bop_kjoin($stlchan) 0"]
  return 0
}

proc bop_lowbots {chan} {
  global botnick
  set bots 1
  foreach bot [chanlist $chan b] {
    if {$bot != $botnick && [isop $bot $chan]} {
      incr bots
    }
  }
  if {$bots < 3} {return 1}
  return 0
}

proc bop_opreqsreset {stlchan} {
  global bop_opreqs
  set bop_opreqs($stlchan) 0
  return
}

proc bop_setneed {chan} {
  global bop_kjoin bop_needk bop_needi bop_needl bop_needu bop_opreqs numversion
  set stlchan [string tolower $chan]
  set bop_opreqs($stlchan) 0 ; set bop_kjoin($stlchan) 0
  set bop_needk($stlchan) 0 ; set bop_needi($stlchan) 0
  set bop_needl($stlchan) 0 ; set bop_needu($stlchan) 0
  if {$numversion < 1060000} {
    channel set $chan need-op [split "bop_reqop $chan op"]
    channel set $chan need-key [split "bop_letmein $chan key"]
    channel set $chan need-invite [split "bop_letmein $chan invite"]
    channel set $chan need-limit [split "bop_letmein $chan limit"]
    channel set $chan need-unban [split "bop_letmein $chan unban"]
  }
  return
}

proc bop_unsetneed {nick uhost hand chan {msg ""}} {
  global bop_kjoin bop_needk bop_needi bop_needl bop_needu bop_opreqs botnick
  if {$nick == $botnick && ![validchan $chan]} {
    set stlchan [string tolower $chan]
    catch {unset bop_opreqs($stlchan)} ; catch {unset bop_kjoin($stlchan)}
    catch {unset bop_needk($stlchan)} ; catch {unset bop_needi($stlchan)}
    catch {unset bop_needl($stlchan)} ; catch {unset bop_needu($stlchan)}
  }
  return 0
}

proc bop_clearneeds {} {
  foreach chan [channels] {
    channel set $chan need-op ""
    channel set $chan need-invite ""
    channel set $chan need-key ""
    channel set $chan need-limit ""
    channel set $chan need-unban ""
  }
  bop_settimer
  return
}

proc bop_settimer {} {
  foreach chan [channels] {
    bop_setneed $chan
  }
  if {![string match *bop_settimer* [timers]]} {
    timer 5 bop_settimer
  }
  return 0
}

proc bop_killutimer {cmd} {
  set n 0
  regsub -all -- {\[} $cmd {\[} cmd ; regsub -all -- {\]} $cmd {\]} cmd
  foreach tmr [utimers] {
    if {[string match $cmd [join [lindex $tmr 1]]]} {
      killutimer [lindex $tmr 2]
      incr n
    }
  }
  return $n
}

if {$numversion >= 1060000} {
  bind need - * bop_reqop
}

utimer 2 bop_clearneeds

bind mode - * bop_modeop
if {!$bop_modeop} {unbind mode - * bop_modeop}
bind link - * bop_linkop
if {!$bop_linkop} {unbind link - * bop_linkop}
bind bot - doyawantops bop_doiwantops
bind bot - yesiwantops bop_botwantsops
bind bot - reqops bop_reqtmr
bind bot - wantkey bop_botwantsin
bind bot - wantinvite bop_botwantsin
bind bot - wantlimit bop_botwantsin
bind bot - wantunban bop_botwantsin
bind bot - thekey bop_joinkey
bind join - * bop_jointmr
bind part - * bop_unsetneed
bind raw - 352 bop_who

putlog "Loaded botnetop.tcl v2.23 by slennox"

return

##
# Protect Ops v2.0.6
#  by MC_8 - Carl M. Gregory <mc8@purehype.net>
#  This script will only run on eggdrop 1.6.14 or greater.
#
#    R.I.P. Mom, To always be remembered; Nancy Marie Gregory.
#
# My Website - http://mc.purehype.net/
# Have a bug or script not working correctly?
#   http://mc.purehype.net/bugzilla/
# Have a question?
#   http://forum.purehype.net/viewforum.php?f=5
##

##
# Description
##
# This script basically does what 'chanset''s 'protectops' and 'dontkickops'
# does, but with more options and customized reactions.  A "super protectops" as
# someone called it, wording in relation to slennox's script "super bitch".
#
# This can also be setup to protect others, not just op's.
##

##
# Commands
##
# DCC:
#
#   chanset <channel> <+/->mc.protect_ops
#     This will enable (+) or disable (-) the script for the specific
#     channel.
##

##
# Configuration
##
#

## Kick protection settings.

# What op'd users do you want to protect from op kick's?  If you want to protect
# every op that is currently op'd, regardless if there a registered op in the
# bot, then set this to "-|-".  Set this to "" to disable kick protection.  Flag
# syntax, <global>|<channel>
set mc_po(:config:kick:protect) "o|o"

# What do you want to do upon other op kicking an op?  Separate each command
# with a new line.
# Valid commands are:
#   /msg <nick|channel> <text>
#   /notice <nick|channel> <text>
#   /ban <channel> <nick> [time [reason]]
#     If time is specified;
#        0 = Perm ban.
#        Any number greater than 0 is the ban expiration in min's.
#     If the number is greater than 0, the reason will be put into the
#     bot's internal banlist record as the reason for adding the ban.  Otherwise
#     the ban is considered a server ban and reason is just ignored.  Also, if
#     you want the ban to be "sticky" (read up on '.help stick') then append the
#     time with an '!' (exclamation point).
#   /kick <channel> <nick>
#   /deop <channel> <nick>
#   /raw <raw_irc_code>
#     See: http://www.user-com.undernet.org/documents/rfc1459.txt
#   /chattr <handle> <flag changes> [channel]
#     This acts exactly the same way as a '.chattr' in the DCC console, see
#     '.help chattr'.
#   /note <handle> <text>
#     Sends an internal note via the notes module to <handle>.
#   /flagnote <flag [channel]> <text>
#     Sends an internal note via the notes module to all whom match the
#     specified flag(s).  Flag format is global|channel.
# Valid replacement variables are;
#   %botnick       - The bot's IRC nickname.
#   %channel       - The channel the action took place in.
#   %reason        - The reason specified for the action.
#   %nick          - The IRC nickname that performed the action.
#   %ident         - The ident of the IRC nickname that performed the action.
#   %host          - The host of the IRC nickname that performed the action.
#   %handle        - The handle of the IRC nickname that performed the action.
#   %victim_nick   - The IRC nickname of the victim.
#   %victim_ident  - The ident of the victim.
#   %victim_host   - The host of the victim.
#   %victim_handle - The handle of the victim.
set mc_po(:config:kick:do) {
  /deop %channel %nick
  /chattr %handle -mtfo|-mtfo %channel
  /msg %nick You just kicked %victim_nick, that's an op!
}


## Ban protection settings.

# What op'd users do you want to protect from op ban's?  If you want to protect
# every op that is currently op'd, regardless if there a registered op in the
# bot, then set this to "-|-".  Set this to "" to disable ban protection.  Flag
# syntax: <global>|<channel>
set mc_po(:config:ban:protect) "o|o"

# What do you want to do upon other op banning an op?  Separate each command
# with a new line.
# Valid commands are:
#   /msg <nick|channel> <text>
#   /notice <nick|channel> <text>
#   /ban <channel> <nick> [time [reason]]
#     If time is specified;
#        0 = Perm ban.
#        Any number greater than 0 is the ban expiration in min's.
#     If the number is greater than 0, the reason will be put into the
#     bot's internal banlist record as the reason for adding the ban.  Otherwise
#     the ban is considered a server ban and reason is just ignored.  Also, if
#     you want the ban to be "sticky" (read up on '.help stick') then append the
#     time with an '!' (exclamation point).
#   /kick <channel> <nick>
#   /deop <channel> <nick>
#   /raw <raw_irc_code>
#     See: http://www.user-com.undernet.org/documents/rfc1459.txt
#   /chattr <handle> <flag changes> [channel]
#     This acts exactly the same way as a '.chattr' in the DCC console, see
#     '.help chattr'.
#   /note <handle> <text>
#     Sends an internal note via the notes module to <handle>.
#   /flagnote <flag [channel]> <text>
#     Sends an internal note via the notes module to all whom match the
#     specified flag(s).  Flag format is global|channel.
#   /reverse [option]
#     Removes the ban set.  If option is set to 'valid_only', it will only
#     reverse the ban if the user that matches the ban is a valid op (registered
#     with the bot and has the 'o' flag).
# Valid replacement variables are;
#   %botnick       - The bot's IRC nickname.
#   %channel       - The channel the action took place in.
#   %nick          - The IRC nickname that performed the action.
#   %ident         - The ident of the IRC nickname that performed the action.
#   %host          - The host of the IRC nickname that performed the action.
#   %handle        - The handle of the IRC nickname that performed the action.
#   %victim_nick   - The IRC nickname of the victim.
#   %victim_ident  - The ident of the victim.
#   %victim_host   - The host of the victim.
#   %victim_handle - The handle of the victim.
#   %banmask       - The banmask that triggered this.
set mc_po(:config:ban:do) {
  /deop %channel %nick
  /chattr %handle -mtfo|-mtfo %channel
  /msg %nick You just banned %victim_nick, that's an op!
  /reverse valid_only
}


## Deop protection settings.

# What op'd users do you want to protect from op deop's?  If you want to protect
# every op that is currently op'd, regardless if there a registered op in the
# bot, then set this to "-|-".  Set this to "" to disable deop protection.  Flag
# syntax: <global>|<channel>
set mc_po(:config:deop:protect) "o|o"

# What do you want to do upon other op deopping an op?  Separate each command
# with a new line.
# Valid commands are:
#   /msg <nick|channel> <text>
#   /notice <nick|channel> <text>
#   /ban <channel> <nick> [time [reason]]
#     If time is specified;
#        0 = Perm ban.
#        Any number greater than 0 is the ban expiration in min's.
#     If the number is greater than 0, the reason will be put into the
#     bot's internal banlist record as the reason for adding the ban.  Otherwise
#     the ban is considered a server ban and reason is just ignored.  Also, if
#     you want the ban to be "sticky" (read up on '.help stick') then append the
#     time with an '!' (exclamation point).
#   /kick <channel> <nick>
#   /deop <channel> <nick>
#   /raw <raw_irc_code>
#     See: http://www.user-com.undernet.org/documents/rfc1459.txt
#   /chattr <handle> <flag changes> [channel]
#     This acts exactly the same way as a '.chattr' in the DCC console, see
#     '.help chattr'.
#   /note <handle> <text>
#     Sends an internal note via the notes module to <handle>.
#   /flagnote <flag [channel]> <text>
#     Sends an internal note via the notes module to all whom match the
#     specified flag(s).  Flag format is global|channel.
#   /reverse [option]
#     Re-ops the victim.  If option is set to 'valid_only', it will only reverse
#     the op status if the user is a valid op (registered with the bot and has
#     the 'o' flag).
# Valid replacement variables are;
#   %botnick       - The bot's IRC nickname.
#   %channel       - The channel the action took place in.
#   %nick          - The IRC nickname that performed the action.
#   %ident         - The ident of the IRC nickname that performed the action.
#   %host          - The host of the IRC nickname that performed the action.
#   %handle        - The handle of the IRC nickname that performed the action.
#   %victim_nick   - The IRC nickname of the victim.
#   %victim_ident  - The ident of the victim.
#   %victim_host   - The host of the victim.
#   %victim_handle - The handle of the victim.
set mc_po(:config:deop:do) {
  /deop %channel %nick
  /chattr %handle -mtfo|-mtfo %channel
  /msg %nick You just deopped %victim_nick, that's an op!
  /reverse valid_only
}


## Miscellaneous settings.

# What flagged users do you want to exempt from this script?  Set to "" to exempt
# no one.
set mc_po(:config:exempt) "b|"

# What other flagged users do you want to protect as well?  This is useful if
# the matching flagged user is not op'd, the script will still protect him/her.
# Set this to "" to disable.  Flag syntax: <global>|<channel>
set mc_po(:config:also:protect) "ov|ov"

# [0=no/1=yes] If the bot is not opped, do you want to perform the *:do command
# setup above?  In respects to /msg, /notice, /ban, and /kick -- with proper
# respects to the channels (/msg and /notice being the channel the action took
# place in -- the others being the channels specified).
set mc_po(:config:bigtalker) 0

# How do you want to mask hosts?  This is used for banning and adding
# a user to the userfile (if either enabled).
#         0 - *!user@host.domain
#         1 - *!*user@host.domain
#         2 - *!*@host.domain
#         3 - *!*user@*.domain
#         4 - *!*@*.domain
#         5 - nick!user@host.domain
#         6 - nick!*user@host.domain
#         7 - nick!*@host.domain
#         8 - nick!*user@*.domain
#         9 - nick!*@*.domain
#       You can also specify a type of 10-19 which corresponds to types 0-9,
#       using this sub rule;  If host.domain is a(n)-
#         name - Instead of using a * wildcard to replace portions of the
#                host.domain, it replaces the numbers in the host.domain with a
#                '?' (question mark) wildcard.
#         ip   - It will mask as normal, with no '?' (question mark)
#                replacements as does hostname.
set mc_po(:config:maskhostbytype) 3

## SVS Client (Script Version Service) v4.1.2 ##
# Once a day, the SVS Client will connect to MC_8's SVS Server to determine if
# there is a newer version of this script available.  If a newer version is
# found, the script will be auto updated.

# [0=no/1=yes] Do you want to enable auto updating?  If you chose to disable
# auto updating, it will not automatically update the script upon finding a
# newer version.
set mc_po(:config:svs:enable) 1

#
##

##
# Done with configurations, do not edit past here unless you know TCL.
##
#

## SVS insert (pre code)
#Script:mc_po
catch {unset temp}

foreach temp(bind) [binds mc:po:*] {
  foreach {temp(1) temp(2) temp(3) temp(4) temp(5)} $temp(bind) break
  catch {unbind $temp(1) $temp(2) $temp(3) $temp(5)}
}

set mc_po(info:vars) ""
foreach {temp(name) temp(value)} [array get mc_po :config:*] {
  lappend mc_po(info:vars) [list $temp(name) $temp(value)]
}
set mc_po(info:loc) [info script]
array set mc_po [list \
  script                 "Protect Ops" \
  version                "v2.0.6" \
  svs:script             "protectops" \
  svs:version            "002000006000" \
  svs:client_version     "v4.1.2" \
  svs:client_svs_version "004001002000" \
  svs:server             "mc.svs.purehype.net" \
  svs:port               "80" \
  svs:get                "/index.tcl"]
set mc_po(svs:query)    "svs=$mc_po(svs:script)&"
append mc_po(svs:query) "version=$mc_po(svs:version)&"
append mc_po(svs:query) \
  "svs_version=$mc_po(svs:client_svs_version)"

if {![info exists numversion] || 
    ([string range $numversion 0 4] < "10614") ||
    (([string range $numversion 0 4] == "10614") &&
     ([string range $numversion 5 6] != "00"))} {
  set temp(tag) "$mc_po(script) $mc_po(version)"
  putloglev o * \
    "$temp(tag) by MC_8 will only work on eggdrop 1.6.14 (stable) or greater."
  putloglev o * "$temp(tag) will not work with eggdrop $version."
  putloglev o * "$temp(tag) not loaded."
  uplevel #0 {
    if {[info exists temp] && ![array exists temp]} {unset temp}
    set temp(svs_return) [list 0 "Need to upgrade eggdrop."]
  }; return 1
}
## ^

setudef flag mc.protect_ops

# Error Catching System (ECS), v4.1.
proc mc:po:errchk {command args} {
  
  # Enable (1) or disable (0) auto reporting of bugs to mc8@purehype.net.
  # This setting here for those who want to disable it in fear of privacy
  # violations.
  set enable_auto_reporting 1
  
  if {![info exists ::lastCommand]} {set ::lastCommand [list]}
  set ::lastCommand \
    "[list [list [clock seconds] $command $args]] $::lastCommand"
  set ::lastCommand [lrange $::lastCommand 0 4]
  if {![catch {eval $command $args} return]} {return $return}
  if {$::errorCode == "mc.ecs.done"} {return -errorcode mc.ecs.done -code error}
  
  set temp(lastbind) [expr {[info exists ::lastbind]?$::lastbind:"-NULL-"}]
  set temp(eversion) [expr {[info exists ::version]?$::version:"-NULL-"}]
  set message "
    ************************************
    (ECS 4.1) Error found in TCL script.
    --------------
    Script name   : $::mc_po(script)
    Script version: $::mc_po(version)
    Egg. Version  : $temp(eversion)
    TCL Version   : [info tclversion] ([info patchlevel])
    --------------
    Last Bind     : $temp(lastbind)
    Last Commands :"
  foreach line $::lastCommand {
    foreach {time command arg} $line break
    append message "\n        ${time}- $command $arg"
  }
  append message "\n    Error stack   :"
  foreach line [split $::errorInfo \n] {
    append message "\n        $line"
  }
  append message "\n    --------------"
  
  set message [lrange [split $message \n] 1 end]
  set offset [string first * [lindex $message 0]]
  set new_message [list]
  foreach line $message {lappend new_message [string range $line $offset end]}
  set message $new_message
  
  if {!$enable_auto_reporting ||
      [catch {socket -async mc.purehype.net 80} sid]} {
    foreach line $message {putloglev o * $line}
    putloglev o * "Submit this bug to http://mc.purehype.net/bugzilla/ . If"
    putloglev o * "you are experiencing problems with bugzilla, contact MC_8"
    putloglev o * "via email at mc8@purehype.net. Please include all"
    putloglev o * "information shown here, in this ECS report."
    putloglev o * "************************************"
    return -errorcode mc.ecs.done -code error
  }
  fconfigure $sid -blocking 0 -buffering line

  set query [list]
  # This info is passed should I need to hunt down the bot's owner for more
  # information.
  lappend query "Admin   : [expr {[info exists ::admin]?$::admin:""}]"
  lappend query "Owner   : [expr {[info exists ::owner]?$::owner:""}]"
  lappend query "Botnick : [expr {[info exists ::botnick]?$::botnick:""}]"
  lappend query "Server  : [expr {[info exists ::server]?$::server:""}]"
  lappend query "Channels: [join [lsort -dictionary [channels]] ", "]"
  lappend query ""
  
  foreach line $message {lappend query $line}
  lappend query "************************************"
  
  set new_query [list]
  foreach line $query {
    regsub -all -- "(\002|\017|\026|\037)" $line "" line
    regsub -all -- "\003(\[0-9\]\[0-9\]?(,\[0-9\]\[0-9\]?)?)?" $line "" line
    regsub -all {\%} $line "%25" line
    set i [string length $line]
    while {[regexp {[^a-zA-Z0-9%]} $line toh] && ($i >= 0)} {
      scan "$toh" %c dec
      regsub -all -- "\\${toh}" $line "%[format %X $dec]" line
      incr i -1
    }; lappend new_query $line
  }; set query $new_query
  
  set query "message=[join $query %0a]"
  puts $sid "POST /report_bug.tcl HTTP/1.0\
           \nHost: mc.purehype.net:80\
           \nContent-type: application/x-www-form-urlencoded\
           \nContent-Length: [expr [string length $query] +2]"
  puts $sid \n$query
  close $sid

  foreach line $message {putloglev o * $line}
  putloglev o * "Automatically sending bug report to MC_8."
  putloglev o * "If you have a firewall setup, it may block the sending of this"
  putloglev o * "report. You can check the status of your bug, as soon as MC_8"
  putloglev o * "adds it, at http://mc.purehype.net/bugzilla/ ."
  putloglev o * "************************************"
  
  return -errorcode mc.ecs.done -code error
}
# ^

bind join - * mc:po:bind:join
proc mc:po:bind:join {nick uhost handle channel} {
  return [mc:po:errchk mc:po:bind:join_ $nick $uhost $handle $channel]
}
proc mc:po:bind:join_ {nick uhost handle channel} {
  if {![isbotnick $nick]} {mc:po:list ial add $nick $uhost $channel}
}

bind raw - 315 mc:po:bind:raw
proc mc:po:bind:raw {from keyword arg} {
  return [mc:po:errchk mc:po:bind:raw_ $from $keyword $arg]
}
proc mc:po:bind:raw_ {from keyword arg} {
  set channel [lindex [split $arg] 1]
  if {![validchan $channel]} {return 0}
  mc:po:list ial remove "" $channel
  foreach temp(user) [chanlist $channel] {
    if {[isbotnick $temp(user)]} {continue}
    mc:po:list ial add $temp(user) [getchanhost $temp(user) $channel] $channel
  }
  return 0
}

bind part - * mc:po:bind:part
proc mc:po:bind:part {nick uhost handle channel text} {
  return [mc:po:errchk mc:po:bind:part_ $nick $uhost $handle $channel $text]
}
proc mc:po:bind:part_ {nick uhost handle channel text} {
  if {[isbotnick $nick]} {mc:po:list ial remove "" $channel} \
  else {mc:po:list ial schedule_remove $nick $channel 30}
}

bind sign - * mc:po:bind:sign
proc mc:po:bind:sign {nick uhost handle channel reason} {
  return [mc:po:errchk mc:po:bind:sign_ $nick $uhost $handle $channel $reason]
}
proc mc:po:bind:sign_ {nick uhost handle channel reason} {
  if {[isbotnick $nick]} {mc:po:list ial remove "" $channel} \
  else {mc:po:list ial schedule_remove $nick $channel 30}
}

bind kick - * mc:po:bind:kick
proc mc:po:bind:kick {nick uhost handle channel target reason} {
  return [mc:po:errchk mc:po:bind:kick_ \
    $nick $uhost $handle $channel $target $reason]
}
proc mc:po:bind:kick_ {nick uhost handle channel target reason} {
  if {[isbotnick $target]} {mc:po:list ial remove "" $channel} \
  elseif {$nick == $target} {mc:po:list ial schedule_remove $nick $channel 30} \
  else {
    mc:po:list eval $nick $channel kick $target $reason
    mc:po:list ial schedule_remove $target $channel 30
  }
}

bind mode - * mc:po:bind:mode
proc mc:po:bind:mode {nick uhost handle channel mode victim} {
  return [mc:po:errchk mc:po:bind:mode_ \
    $nick $uhost $handle $channel $mode $victim]
}
proc mc:po:bind:mode_ {nick uhost handle channel mode victim} {
  if {[isbotnick $nick] || ($nick == "")} {return 0}
  switch -- $mode {
    "+b" {
      foreach temp(user) [mc:po:list ial find $channel $victim] {
        set temp(nick) [lindex $temp(user) 0]
        if {$temp(nick) == $nick} {continue}
        set temp() [mc:po:list eval $nick $channel ban $temp(nick) \
          [lindex $temp(user) 1] $victim]
        if {$temp() == "1"} {
          # Action taken.
          break
        }
      }
    }
    "-o" {
      if {$victim != $nick} {mc:po:list eval $nick $channel deop $victim}
    }
  }
}

bind nick - * mc:po:bind:nick
proc mc:po:bind:nick {nick uhost handle channel newnick} {
  return [mc:po:errchk mc:po:bind:nick_ $nick $uhost $handle $channel $newnick]
}
proc mc:po:bind:nick_ {nick uhost handle channel newnick} {
  if {![isbotnick $newnick]} {
    mc:po:list ial remove $nick $channel
    mc:po:list ial add $newnick $uhost $channel
  }
}


proc mc:po:list {command {args ""}} {
  return [mc:po:errchk mc:po:list_ $command $args]
}
proc mc:po:list_ {command arg} {
  set args $arg
  global mc_po
  switch -- $command {

    "ial" {
      # Ial format; nick uhost channel
      if {![info exists mc_po(:ial:)]} {set mc_po(:ial:) ""}
      set temp(command) [lindex $args 0]
      set args [lrange $args 1 end]
      switch -- $temp(command) {

        "add" {
          # mc:po:list ial add <nick> <uhost> <channel>
          foreach {nick uhost channel} $args break
          mc:po:list ial remove $nick $channel
          lappend mc_po(:ial:) [list $nick $uhost $channel]
        }

        "remove" {
          # mc:po:list ial remove [nick] [channel]
          set nick ""; set channel ""
          foreach {nick channel} $args break

          set temp(new_list) ""
          foreach temp(entry) [mc:po:list ial list] {
            set temp(nick) [string tolower [lindex $temp(entry) 0]]
            set temp(channel) [string tolower [lindex $temp(entry) 2]]
            if {(($nick == "") || ($temp(nick) == [string tolower $nick])) &&
                (($channel == "") ||
                 ($temp(channel) == [string tolower $channel]))} {
              mc:po:list ial kill_schedule $temp(nick) $temp(channel)
              continue
            }
            lappend temp(new_list) $temp(entry)
          }
          set mc_po(:ial:) $temp(new_list)
        }

        "find" {
          # mc:po:list ial find <channel> <nick!user@host*>
          foreach {channel nuhost_masked} $args break
          set nuhost_masked [string tolower $nuhost_masked]

          set temp(return) ""
          foreach temp(entry) [mc:po:list ial list $channel] {
            set temp(nick) [string tolower [lindex $temp(entry) 0]]
            set temp(uhost) [string tolower [lindex $temp(entry) 1]]
            if {[string match $nuhost_masked $temp(nick)!$temp(uhost)]} {
              lappend temp(return) [lrange $temp(entry) 0 1]
            }
          }
          return $temp(return)
        }

        "list" {
          # mc:po:list ial list [channel]
          set channel ""
          foreach channel $args break

          if {$channel == ""} {return $mc_po(:ial:)}

          set temp(return) ""
          foreach temp(entry) $mc_po(:ial:) {
            set temp(channel) [string tolower [lindex $temp(entry) 2]]
            if {$temp(channel) == [string tolower $channel]} {
              lappend temp(return) $temp(entry)
            }
          }
          return $temp(return)
        }

        "schedule_remove" {
          # mc:po:list ial schedule_remove <nick> <channel> <seconds>
          foreach {nick channel time} $args break
          set nick [string tolower $nick]
          set channel [string tolower $channel]

          set temp(list) [list mc:po:list remove $nick $channel]

          foreach temp(utimer) [utimers] {
            if {[lsearch -exact $temp(utimer) $temp(list)] == "1"} {
              return 0
            }
          }

          utimer $time $temp(list)
        }

        "kill_schedule" {
          # mc:po:list ial kill_schedule <nick> <channel>
          foreach {nick channel} $args break
          set nick [string tolower $nick]
          set channel [string tolower $channel]

          set temp(list) [list mc:po:list remove $nick $channel]

          foreach temp(utimer) [utimers] {
            if {[lsearch -exact $temp(utimer) $temp(list)] == "1"} {
              killutimer [lindex $temp(utimer) 2]
              break
            }
          }
        }

      }
    }

    "is_protected" {
      # mc:po:list is_protected <nick> <handle> <channel> <type> \
      #   <punisher_handle>
      foreach {nick handle channel type punisher_handle} $args break
      global botnet-nick

      if {
        ([channel get $channel mc.protect_ops]) &&
        ((($nick != "") && ([onchan $nick $channel])) ||
         ($nick == "")) &&
        ($punisher_handle != ${botnet-nick}) &&
        ((($mc_po(:config:${type}:protect) == "-|-") &&
          ((($type == "deop") && ([wasop $nick $channel])) ||
           ((($type == "kick") || ($type == "ban")) &&
            ([isop $nick $channel])))) ||
         (($mc_po(:config:${type}:protect) != "") &&
          ([matchattr $handle $mc_po(:config:${type}:protect) $channel])) ||
         (($mc_po(:config:also:protect) != "") &&
          ([matchattr $handle $mc_po(:config:also:protect) $channel]))) &&
        (($mc_po(:config:exempt) != "") &&
         (![matchattr $punisher_handle $mc_po(:config:exempt) $channel]))
      } {return 1} else {return 0}
    }

    "eval" {
      # mc:po:list eval <nick> <channel> kick <target_nick> [reason]
      # mc:po:list eval <nick> <channel> deop <target_nick>
      # mc:po:list eval <nick> <channel> ban  <target_nick> <target_uhost> \
      #   <banmask>
      global botnick botnet-nick
      set reason ""; set banmask ""
      foreach {nick channel type target_nick reason banmask} $args break

      if {($nick != "") && ([set uhost [getchanhost $nick]] != "")} {
        regexp -- {^(.*)@(.*)$} $uhost -> ident host
        set handle [nick2hand $nick]
      } else {
        set ident ""
        set host ""
        set handle ""
      }

      if {$type == "ban"} {
        regexp -- {^(.*)@(.*)$} $reason -> target_ident target_host
        set target_handle [finduser $target_nick!$reason]
        set reason ""
      } else {
        regexp -- {^(.*)@(.*)$} [getchanhost $target_nick $channel] -> \
          target_ident target_host
        set target_handle [nick2hand $target_nick $channel]
      }

      if {
   ![mc:po:list is_protected $target_nick $target_handle $channel $type $handle]
      } {return 0}

      set temp(return_number) 1

      set temp(do) [mc:po:replace -- $mc_po(:config:${type}:do) [list \
        %botnick       $botnick      \
        %channel       $channel      \
        %reason        $reason       \
        %nick          $nick         \
        %ident         $ident        \
        %host          $host         \
        %handle        $handle       \
        %victim_nick   $target_nick  \
        %victim_ident  $target_ident \
        %victim_host   $target_host  \
        %victim_handle $target_handle\
        %banmask       $banmask]]
      foreach temp(command) [split $temp(do) \n] {
        set temp(command) [string trim $temp(command) " \t"]
        if {$temp(command) == ""} {continue}
        set temp(command) [split $temp(command)]
        set temp(args) [lrange $temp(command) 1 end]
        set temp(command) [string tolower [lindex $temp(command) 0]]
        switch -- $temp(command) {
          "/msg" {
            if {![botisop $channel] && !$mc_po(:config:bigtalker)} {continue}

            set temp(to) [lindex $temp(args) 0]
            if {$temp(to) == ""} {continue} ;# Server action?
            putserv "PRIVMSG $temp(to) :[join [lrange $temp(args) 1 end]]"
          }
          "/notice" {
            if {![botisop $channel] && !$mc_po(:config:bigtalker)} {continue}

            set temp(to) [lindex $temp(args) 0]
            if {$temp(to) == ""} {continue} ;# Server action?
            putserv "NOTICE $temp(to) :[join [lrange $temp(args) 1 end]]"
           }
          "/ban" {
            foreach {temp(channel) temp(nick) temp(time) temp(reason)} \
              $temp(args) break

            if {$temp(nick) == ""} {continue} ;# Server action?

            if {![validchan $temp(channel)]} {
              set temp() "$temp(command) [join $temp(args)]"
              putloglev o * "$mc_po(script): Invalid channel; $temp()"
              continue
            }

            if {![onchan $temp(nick) $temp(channel)]} {
              set temp() "$temp(command) [join $temp(args)]"
              putloglev o * "$mc_po(script): Nickname not on channel; $temp()"
              continue
            }

            if {![botisop $temp(channel)] && !$mc_po(:config:bigtalker)} {
              continue
            }

            set temp(banmask) [mc:po:maskhostbytype \
              $temp(nick)![getchanhost $temp(nick)] \
              $mc_po(:config:maskhostbytype)]

            if {$temp(time) == ""} {
              putserv "MODE $temp(channel) +b $temp(banmask)"
              continue
            }

            set temp(sticky) [string match *! $temp(time)]
            regexp -- {^(.*)!?$} $temp(time) -> temp(time)

            if {[regexp -- {[^0-9]} $temp(time)]} {
              set temp() "$temp(command) [join $temp(args)]"
              putloglev o * "$mc_po(script): Invalid time format; $temp()"
              continue
            }

            newchanban $temp(channel) $temp(banmask) ${botnet-nick} $reason \
              $temp(time) [expr {$temp(sticky)?"sticky":"none"}]
           }
          "/kick" {
            set temp(channel) [lindex $temp(args) 0]
            set temp(nick) [lindex $temp(args) 1]

            if {![validchan $temp(channel)]} {
              set temp() "$temp(command) [join $temp(args)]"
              putloglev o * "$mc_po(script): Invalid channel; $temp()"
              continue
            }

            if {![onchan $temp(nick) $temp(channel)]} {
              set temp() "$temp(command) [join $temp(args)]"
              putloglev o * "$mc_po(script): Nickname not on channel; $temp()"
              continue
            }

            if {![botisop $temp(channel)] && !$mc_po(:config:bigtalker)} {
              continue
            }

            putserv "KICK $temp(channel) $temp(nick) :$reason"
          }
          "/deop" {
            set temp(channel) [lindex $temp(args) 0]
            set temp(nick) [lindex $temp(args) 1]

            if {![validchan $temp(channel)]} {
              set temp() "$temp(command) [join $temp(args)]"
              putloglev o * "$mc_po(script): Invalid channel; $temp()"
              continue
            }

            if {![onchan $temp(nick) $temp(channel)]} {
              set temp() "$temp(command) [join $temp(args)]"
              putloglev o * "$mc_po(script): Nickname not on channel; $temp()"
              continue
            }

            if {![botisop $temp(channel)] && !$mc_po(:config:bigtalker)} {
              continue
            }
            if {![isop $temp(nick) $temp(channel)]} {continue}

            putserv "MODE $temp(channel) -o $temp(nick)"
          }
          "/chattr" {
            set temp(handle) [lindex $temp(args) 0]
            set temp(flags) [lindex $temp(args) 1]
            set temp(channel) [lindex $temp(args) 2]

            if {($temp(handle) == "") || ($temp(handle) == "*")} {
              continue
            }

            if {(![validchan $temp(channel)]) && ($temp(channel) != "")} {
              set temp() "$temp(command) [join $temp(args)]"
              putloglev o * "$mc_po(script): Invalid channel; $temp()"
              continue
            }

            if {$temp(channel) == ""} {chattr $temp(handle) $temp(flags)} \
            else {chattr $temp(handle) $temp(flags) $temp(channel)}
          }
          "/raw" {
            putserv [join $temp(args)]
          }
          "/note" {
            set temp(handle) [lindex $temp(args) 0]
            set temp(message) [join [lrange $temp(args) 1 end]]

            if {![validuser $temp(handle)]} {
              set temp() "$temp(command) [join $temp(args)]"
              putloglev o * "$mc_po(script): Invalid handle; $temp()"
              continue
            }

            if {[sendnote ${botnet-nick} $temp(handle) $temp(message)] == "3"} {
              set temp() "note box too full"
              putloglev o * \
                "$mc_po(script): Cannot send note to $temp(handle), $temp()."
            }
          }
          "/flagnote" {
            set temp(flag) [lindex $temp(args) 0]
            set temp(channel) [lindex $temp(args) 1]
            set temp(message) [join [lrange $temp(args) 2 end]]
            if {![validchan $temp(channel)]} {
              set temp(channel) ""
              set temp(message) [join [lrange $temp(args) 1 end]]
            }

            if {$temp(channel) == ""} {
              set temp(userlist) [userlist $temp(flag)]
            } else {
              set temp(userlist) [userlist $temp(flag) $temp(channel)]
            }

            foreach temp(handle) $temp(userlist) {
              if {
                [sendnote ${botnet-nick} $temp(handle) $temp(message)] == "3"
              } {
                set temp() "note box too full"
                putloglev o * \
                  "$mc_po(script): Cannot send note to $temp(handle), $temp()."
              }
            }
          }
          "/reverse" {
            if {![regexp {^(ban|deop)$} $type]} {continue}

            set temp(option) [lindex $temp(args) 0]

            if {($temp(option) == "valid_only") &&
                (![matchattr $target_handle o|o $channel])} {
              if {$type == "ban"} {set temp(return_number) 0}
              continue
            }

            set temp(return_number) 1
            if {$type == "ban"} {putserv "MODE $channel -b $banmask"} \
            else {putserv "MODE $channel +o $target_nick"}
          }
          default {
            set temp() "$temp(command) [join $temp(args)]"
            putloglev o * "$mc_po(script): Unknown command; $temp()"
          }
        }
      }
      return $temp(return_number)
    }
  }
}


## More Tools quick procs.
## -- http://mc.purehype.net/script_info.tcl?script=moretools

# badargs <args> <min_llength> <max_llength|end> <argNames>
#     version:
#       v1.0
proc mc:po:badargs {{args ""}} {
  if {[llength $args] < 4} {
    error {
   wrong # args: should be "mc:po:badargs args min_llength max_llength argNames"
    }
  }

  set index 0
  foreach varName [list args min max names] {
    set check_$varName [lindex $args $index]
    incr index
  }

  if {[regexp -- {([^0-9])} $check_min -> bad]} {
    error "bad number \"$bad\" in: $check_min"
  }
  if {[regexp -- {([^0-9])} $check_max -> bad] && ($check_max != "end")} {
    error "bad number \"$bad\" in: $check_max"
  }

  # Make sure $check_args is in list format, if not then make it so.
  # Were not going to use 2list here, don't want to evoke a 'too many nested
  # calls to Tcl_EvalObj' error since '2list' uses on this proc.
  if {[catch {llength $check_args} llength]} {
    set check_args [split $check_args]
    set llength $check_args
  }

  if {($llength < $check_min) || (($llength != "end") &&
      ($llength > $check_max))} {
    if {[info level] == "1"} {return 1}
    error "wrong # args: should be \"[lindex [info level -1] 0] $check_names\""
  }; return 0
}

# 2list <text>
#     version:
#       v1.0+no_unlist
proc mc:po:2list {{args ""}} {
  mc:po:badargs $args 1 1 "text"
  foreach text $args break

  return [expr {([catch {llength $text}])?[split $text]:$text}]
}

# replace [switches] <text> <substitutions>
#     version:
#       v1.3
proc mc:po:replace {{args ""}} {
  mc:po:badargs $args 2 4 "?switches? text substitutions"
  set switches ""
  for {set i 0} {[string match -* [set arg [lindex $args $i]]]} {incr i} {
    if {![regexp -- {^-(nocase|-)$} $arg -> switch]} {
      error "bad switch \"$arg\": must be -nocase, or --"
    }
    if {$switch == "-"} {
      incr i
      break
    }; lappend switches $switch
  }
  set nocase [expr {([lsearch -exact $switches "nocase"] >= "0") ? 1 : 0}]
  set text [lindex $args $i]
  set substitutions [lindex $args [expr $i+1]]
  mc:po:badargs [lrange $args $i end] 2 2 "?switches? text substitutions"

  # Check to see if $substitutions is in list format, if not make it so.
  set substitutions [mc:po:2list $substitutions]

  if {[info tclversion] >= "8.1"} {
    return [expr {($nocase)?
      [string map -nocase $substitutions $text]:
      [string map $substitutions $text]}]
  }

  set re_syntax {([][\\\*\+\?\{\}\,\(\)\:\.\^\$\=\!\|])}
  foreach {a b} $substitutions {
    regsub -all -- $re_syntax $a {\\\1} a
    if {$nocase} {regsub -all -nocase -- $a $text $b text} \
    else {regsub -all -- $a $text $b text}
  }; return $text
}

# maskhostbytype <nick!ident@host.domain> [type]
#     version:
#       v2.1+no_unlist
proc mc:po:maskhostbytype {{args ""}} {
  mc:po:badargs $args 1 2 "nick!ident@host.domain ?type?"
  set type ""
  foreach {nuhost type} $args break

  set type [expr {($type == "")?5:$type}]
  if {![regexp -- {^1?[0-9]$} $type]} {
    set valid "0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 {or 19}"
    error "bad type \"$type\": must be [join $valid ", "]"
  }

  # Define the maximum length the ircd allows for an ident.  Standard is 9,
  # however I made it to a variable incase someone wants to change it up.
  set ident_max-length 9

  # Define the maximum length the ircd allows for a hostname/ ip.  Standard is
  # 63, however I made it to a variable incase someone wants to change it up.
  set host_max-length 63

  if {![regexp -- {^(.*[^!])!((.*)@(.*))$} $nuhost -> nick uhost ident host]} {
    error "invalid nick!ident@host.domain: $nuhost"
  }

  set maskhost 1
  if {[string length $type] == "2"} {
    # Type must be 10-19.
    if {[info tclversion] < "8.1"} {
      set re_syntax_1 {([12][0-9][0-9]|[1-9][0-9]|[1-9])}
      set re_syntax_2 {([12][0-9][0-9]|[1-9][0-9]|[0-9])}
    } else {
      set re_syntax_1 {([12]\d{2}|[1-9][0-9]|[1-9])}
      set re_syntax_2 {([12]\d{2}|[1-9][0-9]|[0-9])}
    }
    set re_syntax ^$re_syntax_1\\.$re_syntax_2\\.$re_syntax_2\\.$re_syntax_2\$

    if {![regexp -- $re_syntax $host]} {
      regsub -all -- {[0-9]} $host ? host
      set maskhost 0
    }; set type [string index $type 1]
  }

  # Previous version used regexp instead of these string matches.  String match
  # in this case is ~3 microseconds faster.
  if {[string match {[0-4]} $type]} {set nick *}
  if {[string match {[2479]} $type]} {set ident *}
  if {[string match {[1368]} $type]} {regsub -- {^~?(.*)$} $ident *\\1 ident}
  if {[string match {[3489]} $type] && $maskhost} {
    set host [lindex [split [maskhost $host] @] end]
  }

  if {[set length [string length $ident]] > ${ident_max-length}} {
    set ident *[string range $ident [expr $length-${ident_max-length}] end]
  }
  if {[set length [string length $host]] > ${host_max-length}} {
    set host *[string range $host [expr $length-${host_max-length}] end]
  }

  return $nick!$ident@$host
}

## End of More Tools quick procs.

## SVS insert (post code)
if {![info exists mc_po(:config:svs:enable)] ||
    ![string match {[01]} $mc_po(:config:svs:enable)]} {
  set mc_po(:config:svs:enable) 0
}

bind time - "00 00 *" mc:po:do_svs
proc mc:po:do_svs {{args ""}} {
  global mc_po
  set query $mc_po(svs:query)
  if {$args == ""} {append query "&log=0"}
  if {[catch {connect $mc_po(svs:server) $mc_po(svs:port)} ind]} {
    set temp(1) "SVS problem connecting to $mc_po(svs:server)"
    set temp(2) "on port $mc_po(svs:port)"
    putloglev d * "$mc_po(script): $temp(1) $temp(2):  $ind"
    return 0
  }
  putdcc $ind "GET $mc_po(svs:get)?$query HTTP/1.0\n"
  putdcc $ind "Host: $mc_po(svs:server):$mc_po(svs:port)\n\n"
  control $ind mc:po:svs_talk
}

proc mc:po:svs_memory {action} {
  global mc_po
  switch -- $action {
    
    "setup" {
      upvar index index
      foreach _item [list header memory rfc_memory] {
        upvar $_item $_item
        set $_item [list svs $_item $index]
      }
    }
    
    "remove" {
      upvar index index
      mc:po:svs_memory setup
      catch {unset mc_po($header)}
      catch {unset mc_po($memory)}
      foreach _item [array names mc_po $rfc_memory:*] {unset mc_po($_item)}
    }

  }
}

proc mc:po:svs_talk {index text} {
  global mc_po
  mc:po:svs_memory setup
  if {$text == ""} {
    mc:po:svs_memory remove
    return 1
  }
  set text [split $text]
  set rfc [lindex $text 0]
  set text [join [lrange $text 1 end]]
  if {![info exists mc_po($header)]} {
    if {$rfc == "002"} {set mc_po($header) 1}
    return 0
  }
  switch -- $rfc {

    001 {return 0}
    002 {return 0}
    003 {return 0}

    010 {
      if {$text != $mc_po(svs:script)} {
        set temp(1) "wanted $mc_po(svs:script), got $text"
        putloglev d * "$mc_po(script): SVS Error: $temp(1)"
        mc:po:svs_memory remove
        return 1
      }
      if {$mc_po(:config:svs:enable)} {return 0}
      set mc_po($rfc_memory:[string index $rfc end]) $text
      return 0
    }

    011 {
      if {$mc_po(:config:svs:enable)} {return 0}
      set mc_po($rfc_memory:[string index $rfc end]) $text
      return 0
    }
      
    012 {
      if {$mc_po(:config:svs:enable)} {return 0}
      set mc_po($rfc_memory:[string index $rfc end]) $text
      return 0
    }
    
    013 {
      if {$mc_po(:config:svs:enable)} {return 0}
      set mc_po($rfc_memory:[string index $rfc end]) $text
      return 0
    }
    
    014 {
      if {$mc_po(:config:svs:enable)} {return 0}
      set mc_po($rfc_memory:[string index $rfc end]) $text
      return 0
    }
    
    017 {
      if {$mc_po(:config:svs:enable)} {return 0}
      if {$text == ""} {
        set text "Newer version of this script exists."
      }
      foreach number [list 0 1 2 3 4] {
        if {![info exists mc_po($rfc_memory:$number)]} {continue}
        regsub -all -- %$number $text $mc_po($rfc_memory:$number) text
      }
      putloglev o * "SVS, $mc_po(script): $text"
      mc:po:svs_memory remove
      return 1
    }

    004 {
      # Quit.
      if {!$mc_po(:config:svs:enable)} {
        mc:po:svs_memory remove
        return 1
      }
        
      if {[info exists mc_po($memory)]} {
        set file $mc_po(info:loc)~new
        set temp(vars) $mc_po(info:vars)
        set io [open $file w]
        for {set i 0} {$i <= [llength $mc_po($memory)]} {incr i} {
          set line [lindex $mc_po($memory) $i]
          set regexp {^[; ]*set mc_po\((:config:[^)]*)\) *(.?)}
          if {[regexp -- $regexp $line -> name type]} {
            set continue 0
            foreach item $temp(vars) {
              set item_name [lindex $item 0]
              set item_value [lindex $item 1]
              if {$name != $item_name} {continue}
              set lsearch_index [lsearch -exact $temp(vars) $item]
              set temp(vars) \
                [lreplace $temp(vars) $lsearch_index $lsearch_index]
              puts $io [list set mc_po($name) $item_value]
              if {$type == "\{"} {
                while {1} {
                  if {[regexp -- {\}(?:[; ][; ]*(.*))?} $line -> extra]} {
                    if {$extra != ""} {
                      puts $io $extra
                    }
                    break
                  }
                  incr i
                  set line [lindex $mc_po($memory) $i]
                }
                puts $io ""
              } elseif {$type == "\""} {
                regsub -- {"} $line "" line
                while {1} {
                  if {[regexp -- {[^\\]"(?:[; ][; ]*(.*))?} $line -> extra] ||
                      [regexp -- {^"(?:[; ][; ]*(.*))?} $line -> extra]} {
                    if {$extra != ""} {
                      puts $io $extra
                    }
                    break
                  }
                  incr i
                  set line [lindex $mc_po($memory) $i]
                }
                puts $io ""
              }
              set continue 1
              break
            }
            if {$continue} {continue}
          }
          puts $io $line
        }
        close $io
        set file $mc_po(info:loc)
        putloglev o * "$mc_po(script): Auto update testing new script..."
        if {[catch {uplevel "source $file~new"}]} {
          file delete -force -- $file~new
          putloglev o * "$mc_po(script): Auto update failed:"
          putloglev o * $::errorInfo
          putloglev o * \
            "$mc_po(script): Loading previous script version..."
          uplevel "source $file"
        } else {
          upvar #0 temp upvar_temp
          if {[info exists upvar_temp(svs_return)]} {
            set temp(return_code) [lindex $upvar_temp(svs_return) 0]
            set temp(return_arg) [lindex $upvar_temp(svs_return) 1]
            
            if {!$temp(return_code)} {
              file delete -force -- $file~new
              set temp() "message from new version: $temp(return_arg)"
              putloglev o * "$mc_po(script): Auto update failed, $temp()"
              putloglev o * \
                "$mc_po(script): Loading previous script version..."
              uplevel "source $file"
            } else {
              file rename -force -- $file~new $file
              set temp() "good, message from new version: $temp(return_arg)"
              putloglev o * "$mc_po(script): Auto update test $temp()"
              putloglev o * \
                "$mc_po(script): Moving and reloading new version..."
              uplevel "source $file"
            }
          } else {
            file rename -force -- $file~new $file
            putloglev o * "$mc_po(script): Auto update test good."
            putloglev o * \
              "$mc_po(script): Moving and reloading new version..."
            uplevel "source $file"
          }
        }
      }

      mc:po:svs_memory remove
      return 1
    }

    200 {
      set temp(host) [lindex $text 1]
      set temp(port) [lindex $text 2]
      set temp(get)  [lindex $text 3]
      set temp(cache) "$temp(host) at $temp(port)"
      putloglev d * \
        "$mc_po(script): SVS is being redirected to $temp(cache)."
      utimer 6 [list mc:po:do_svs_ $temp(host) $temp(port) $temp(get)]
      mc:po:svs_memory remove
      return 1
    }

    300 {
      if {$mc_po(:config:svs:enable)} {
        lappend mc_po($memory) $text
      }; return 0
    }

  }
}
catch {unset index}
if {![info exists mc_loaded]} {set mc_loaded(scripts) [list]}
if {![array exists mc_loaded]} {unset mc_loaded; set mc_loaded(scripts) [list]}
set index [lsearch -exact $mc_loaded(scripts) mc_po]
set mc_loaded(scripts) [lreplace $mc_loaded(scripts) $index $index mc_po]
## ^

putloglev o * "$mc_po(script) $mc_po(version) by MC_8 loaded."

#
##

##
# History  ( <Fixed by> - [Found by] - <Info> )
##
# v2.0.6 (10.09.03)
#  MC_8 - ECS - Fixed 'can't read "ident": no such variable'.  Happens when a
#               person is kicked by someone that isn't on the channel, such as
#               chanserv that can be set to not join the channel but still kick
#               users.
#
# v2.0.5 (10.07.03)
#  MC_8 -            - Upgraded ECS.  v3.0 -> v4.1
#  MC_8 -            - Upgraded SVS Client.  v4.0.1 -> v4.1.2
#  MC_8 -            - Removed `chanflag` and using `channel get` instead.
#                      Increases function's speed by ~2%.
#  MC_8 -            - Removed `unlist` and using a `foreach` format that I
#                      think slennox told me about.  Increases function's speed
#                      by ~41%.
#  MC_8 - Deathangel - Fixed 'can't read "time": no such variable'.
#                      Bugzilla Bug 324 
#
# v2.0.4 (07.17.03)
#  MC_8 - blood_x - Bot will no longer take action upon users doing things to
#                   themselves (such as someone deopping self).
#                   Bugzilla Bug 305
#
# v2.0.3 (07.02.03)
#  MC_8 - Casper - Fixed 'invalid nick!ident@host.domain: ...'.
#                  Bugzilla Bug 291
#
# v2.0.2
#  MC_8 - - Upgraded SVS client.  v4.0 -> v4.0.1
#           Bugzilla Bug 274
#
# v2.0.1 (02.25.03)
#  MC_8 - - Fixed 'Nickname not on channel; /deop #channel' upon server actions.
#           Bugzilla Bug 265
#
# v2.0 (02.21.03)
#  MC_8 -     - Upgraded SVS client.  v2.0 -> v4.0
#  MC_8 - Tux - Fixed 'missing "'.
#               Bugzilla Bug 240
#  MC_8 -     - Wasn't ignoring it's own actions as it should.
#  MC_8 -     - Wasn't stopping after first match for ban protection.
#  MC_8 -     - Upgraded ECS.  old -> v3.0
#  MC_8 -     - Added `unlist` tcl command.  none -> v1.0
#  MC_8 -     - Added `badargs` tcl command.  none -> v1.0
#  MC_8 -     - Added `2list` tcl command.  none -> v1.0
#  MC_8 -     - Upgraded `chanflag` tcl command.  v2.0 -> v3.1
#  MC_8 -     - Upgraded `masktype` tcl command, name changed to
#               `maskhostbytype`.  v1.0 -> v2.1
#  MC_8 -     - Removed `findnick` tcl command.  v1.0 -> none
#  MC_8 -     - Upgraded `replace` tcl command.  v1.1 -> v1.3
#  MC_8 -     - Removed `*:adduser`.
#  MC_8 -     - Removed `*:msg`, `*:msg:method`, `*:deop`, `*:kick`, `*:ban`,
#               `*:flgchg`, `note:flg`, `note:msg`, and `*:reverse`
#               configuration variables then added `*:do` configuration to do it
#               all.
#  MC_8 -     - Rewrote all procs and recreated the IAL.
#
# v1.6 (02.18.02)
#  MC_8 -        - Upgraded chanflag procedure from v1.0 to v2.0, more
#                  efficient.
#  MC_8 -        - Upgraded replace procedure from v1.0 to v1.1, more
#                  efficient.
#  MC_8 -        - Added a better error output system, for debugging
#                  purposes.
#  MC_8 - Pr|muS - Added a 10 second buffer database for kicks.  If a
#                  user is kicked he will be stored in this buffer zone
#                  ... if a ban is established the buffer will be
#                  evaluated too.  Here is why I did this, I would get
#                  kicked, then banned.  But since I was kicked (not in
#                  the channel) when the +b was set... it didn't know
#                  who the ban was for... there for couldn't reverse
#                  the ban (if enabled).
#  MC_8 -        - Added vhand as a replacement variable.
#  MC_8 -        - Rewrote all procs, this is pretty much a totally
#                  rewritten script.
#  MC_8 -        - Removed comment setting.
#  MC_8 -        - Rewrote all configs settings.
#  MC_8 -        - Upgraded SVS from v1.2 to v2.0.
#  MC_8 -        - Added ability to set 'exempt' to "" to exempt no
#                  one.
#
# v1.5.1 (08.30.01)
#  MC_8 -      - Changed *_protect's value for protecting all op'd
#                users.  Was "", now "-|-".
#  MC_8 - Kitt - Bans were protecting all op'd users regardless of
#                ban_protect's setting.
#
# v1.5 (02.07.01)
#  MC_8 -        - Specified the note to send to users based on flags,
#                  instead of a list of handles.  This will make it
#                  easier to specify who get's notes... on the fly.
#  MC_8 -        - Replacement variable %victim for ban's was returning
#                  %to rather than the victim.
#  MC_8 -        - Added SVS.
#  MC_8 - AZ0R0S - Fixed `Tcl error [mc:po:mode]: can't read
#                  "mc_po(deop_protet)": no such variable'.
#  MC_8 - Ariesv - "It works properly against deop, but it does not work
#                  against kicking, or banning protected users."
#
# v1.4.1 (11.15.00)
#  MC_8 - JaMeZ - Fixed, "The channel list, in whichs script will work,
#                 also doesn't work. The only workable option is "",
#                 aka all channs"
#  MC_8 -       - Fixed, Tcl error [mc:po:mode]: list element in braces
#                 followed by "bla" instead of space.
#
# v1.4 (05.28.00)
#  MC_8 -           - Fixed problem with exempt users.
#  MC_8 -           - Added mc_po(comment) variable.
#  MC_8 -           - Fixed bug in %reason for the notes.
#  MC_8 -           - Fixed a minor bug in the exempt flag users.
#  MC_8 -           - Fixed `invalid command name "findip"'
#  MC_8 - Dreamwave - When an op deops a non-registered op the script
#                     deops the op and ops the non-registered op.
#  MC_8 - Dreamwave - Added a third option to the ban_reverse and
#                     deop_reverse.
#  MC_8 - Dreamwave - Added the `mc_po(<type>_protect)' variable.
#
# v1.3.1 (04.14.00)
#  MC_8 -           - Removed it's dependency on moretools.
#  MC_8 - Dreamwave - Fixed `Tcl error [mc:po:mode]: can't read
#                     "knick": no such variable'.
#  MC_8 - Dreamwave - Fixed `when you choose create user entry the
#                     script creates like 10 user entry's'.
#  MC_8 - Dreamwave - Fixed `Tcl error [mc:po:kick]: can't read
#                     "type_flagchange": no such variable'.
#
# v1.3 (03.28.00)
#  MC_8 - Dreamwave - Fixed `Tcl error [mc:po:mode]: can't read
#                     "type_notice": no such variable'.
#  MC_8 - Dreamwave - added new variable, mc_po(also_protect).
#
# v1.2 (02-07-00)
#  MC_8 - CrAs|-| - The script wasn't changing flags nor, fix
#
# v1.1 (01-20-00)
#  MC_8 - - Added more reaction options.
#
# v1.0 (01-16-00)
#  MC_8 - CrAs|-| - Initial release.
##

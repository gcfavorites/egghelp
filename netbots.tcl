# netbots.tcl v1.16 (25 April 1999) by slennox <slenny@ozemail.com.au>
# Latest versions can be found at www.ozemail.com.au/~slenny/eggdrop/
#
# Botnet script for eggdrop 1.3.x with encrypted communication
#
# This script was inspired by an insecure botnet commands script called
# nettools.tcl. This script uses a netbot list and encryption to ensure
# other users with bots on the botnet cannot gain control of your bots, or
# see any unencrypted passwords sent between your bots.
#
# If you'd like your bots to op one another securely over the botnet, you
# can use botnetop.tcl alongside this script.
#
# Commands: .nethelp, .netbots, .netinfo, .netshell, .netserv, .netpass,
# .netsave, .nethash, .netsay, .netact, .netnotice, .netjoin, .netpart,
# .netchanset, .netcycle
#
# Use .nethelp <command> in dcc for more detailed information.
# 
# v1.00 - Initial release
# v1.01 - The encryption mechanism was a little flawed (it's now more
# secure), added an additional option to nb_flag, added a feature that
# randomly changes the botnet password once a day, replaced several \'s
# that had magically disappeared causing 'invalid command name' errors
# in .nethelp
# v1.02 - Improved encryption mechanism, added .netnotice and .netchanset
# commands, other changes/additions
# v1.03 - Added .netshell command
# v1.10 - Putlog entries now show which user and bot a netbot command came
# from, command usage is now logged, added .netcycle command (suggested by
# Viper187), .netpart will no longer make bots part a channel that isn't
# dynamic, other minor changes
# v1.11 - Fixed bug in nb_tautopass proc
# v1.12 - Added support for additional arguments to .netchanset command,
# .netserv now includes time connected (1.3.25+ only), botnick should have
# been botnet-nick in a few procs
# v1.14 - Fixed nb_netchanset error, fixed []{}\ character handling
# problems, fixed time connected display in .netserv (also now works on all
# versions), improved .netchanset command, added nb_owner option, netinfo/
# netshell/netserv replies are now encrypted
# v1.15 - Fixed potential security problem with .netchanset command
# v1.16 - Added nb_hub option, .netbots command (without argument) now
# lists any netbots that are offline or not linked
#
# Credits: many thanks to dw and guppy for their helpful suggestions.

# Set the netbot flag - there are three ways you can set this:
# 1) Set a custom netbot flag such as "N". This must be an upper-case
# alphabet letter. netbot commands will only be sent to and accepted from
# other netbots. This is the most secure setting. You can easily add/remove
# netbots using the .netbots command.
# 2) Set the flag to "b", eggdrop's bot flag. Commands will be sent to and
# accepted from bots recognised as +b on your bot's userfile.
# 3) Set this to "all". Commands will be sent to and accepted from all bots
# on the botnet. This is most efficient for using netbots.tcl to control a
# large number of bots, but is the least secure setting.
set nb_flag N

# Set the encryption key - MAKE SURE YOU CHANGE THIS SETTING - netbot 
# commands will only be accepted from bots with matching keys.
set nb_key "m1io3wza"

# Set this to 1 to only allow permanent owners (as defined in the config
# file) to use netbots commands.
set nb_owner 0

# Set this to 1 to only accept netbot commands from the hub bot (all netbot
# commands must be issued via the hub). This setting should be the same on
# all netbots. It is an extra security feature mainly for people who use
# eggdrop's private-user option on the hub.
set nb_hub 0

# Auto botnet password change - this will invoke a netbot password change
# once a day. Password is a random alpha-numeric string. Note that you
# should only enable this on one netbot (if you set nb_hub to 1, you should
# only set this to 1 on the hub bot). This feature cannot be enabled if you
# set nb_flag to "b" or "all".
set nb_autopass 0

# The following settings are used when adding a channel to the botnet with
# the .netjoin command, and when you reset a channel's settings with the
# .netchanset command. You can change these to your preferred settings if
# desired.

# Channel mode
set nb_chanmode "+nt"

# Idle kick
set nb_idlekick 0

# Flud protection
set nb_fludchan 10:40
set nb_fluddeop 3:10
set nb_fludkick 3:10
set nb_fludjoin 5:60
set nb_fludctcp 3:60

# Channel settings
set nb_chansets "-clearbans +enforcebans +dynamicbans +userbans -autoop -bitch -greet +protectops -statuslog -stopnethack -revenge -autovoice +secret +shared +cycle"


# Don't edit anything below unless you know what you're doing

proc nb_dccnethelp {hand idx arg} {
  global nb_owner nb_ver owner
  regsub -all -- "," $owner "" olist
  if {$nb_owner && [lsearch -exact [string tolower [split $olist]] [string tolower $hand]] == -1} {
    putidx $idx "What?  You need '.help'"
    return 0
  }
  putcmdlog "#$hand# nethelp $arg"
  set command [lindex [split $arg] 0]
  if {[string index $command 0] == "."} {
    set command [string range $command 1 end]
  }
  switch -exact [string tolower $command] {
    "" {
      putidx $idx "netbots.tcl $nb_ver commands:"
      putidx $idx "   .netbots \[add/remove <handle>\]"
      putidx $idx "   .netinfo"
      putidx $idx "   .netshell"
      putidx $idx "   .netserv"
      putidx $idx "   .netpass \[password \[handle\]\]"
      putidx $idx "   .netsave"
      putidx $idx "   .nethash"
      putidx $idx "   .netsay <#channel/nick> <message>"
      putidx $idx "   .netact <#channel/nick> <action>"
      putidx $idx "   .netnotice <#channel/nick> <notice>"
      putidx $idx "   .netjoin <#channel>"
      putidx $idx "   .netpart <#channel>"
      putidx $idx "   .netchanset <#channel> \[settings\]"
      putidx $idx "   .netcycle <#channel>"
      putidx $idx "For more information about a particular command, type"
      putidx $idx ".nethelp <command>"
      return 0
    }
    "nethelp" {
      putidx $idx "# .nethelp \[command\]"
      putidx $idx "   Displays information about the specified command. If"
      putidx $idx "   no command is specified, this will display a list of"
      putidx $idx "   all the available netbots commands."
      return 0
    }
    "netbots" {
      putidx $idx "# .netbots \[add/remove <handle>\]"
      putidx $idx "   This command lets you add a bot to or remove a bot"
      putidx $idx "   from the netbots list. It automatically gives the"
      putidx $idx "   specified bot the netbot flag. The bot will only"
      putidx $idx "   send commands to and receive commands from other"
      putidx $idx "   netbots. If no options are specified, this command"
      putidx $idx "   lists all the current netbots."
      putidx $idx "   Note: this command is not used if nb_flag is set to"
      putidx $idx "   'b' or 'all' in the script's options."
      return 0
    }
    "netinfo" {
      putidx $idx "# .netinfo"
      putidx $idx "   Displays infromation about the version of"
      putidx $idx "   netbots.tcl each netbot is running."
      return 0
    }
    "netshell" {
      putidx $idx "# .netshell"
      putidx $idx "   Displays brief infromation about the shell each"
      putidx $idx "   netbot is running on, including uptime and load"
      putidx $idx "   averages."
      return 0
    }
    "netserv" {
      putidx $idx "# .netserv"
      putidx $idx "   Displays information about the server each netbot is"
      putidx $idx "   using."
      return 0
    }
    "netpass" {
      putidx $idx "# .netpass \[password \[handle\]\]"
      putidx $idx "   This command works in different ways depending on"
      putidx $idx "   which options are specified. If both a password and"
      putidx $idx "   handle are specified, this will change the password"
      putidx $idx "   for that particular user accross the botnet. If only"
      putidx $idx "   a password is specified, this changes the 'netbot"
      putidx $idx "   password' (the password each netbot has for all"
      putidx $idx "   other netbots) to the specified password. If no"
      putidx $idx "   options are specified, this changes the netbot"
      putidx $idx "   password to a random alpha-numeric string."
      putidx $idx "   Note: if you set nb_flag to 'b' or 'all' in the"
      putidx $idx "   script's options, this command is only partially"
      putidx $idx "   enabled. You can change the password for a"
      putidx $idx "   particular user, but cannot change the netbot"
      putidx $idx "   password."
      return 0
    }
    "netsave" {
      putidx $idx "# .netsave"
      putidx $idx "   Makes all netbots perform a userfile/channel file"
      putidx $idx "   save."
      return 0
    }
    "nethash" {
      putidx $idx "# .nethash"
      putidx $idx "   Makes all netbots perform a rehash."
      return 0
    }
    "netsay" {
      putidx $idx "# .netsay <#channel/nick> <message>"
      putidx $idx "   Makes all netbots say the specified message to the"
      putidx $idx "   specified channel or nick."
      return 0
    }
    "netact" {
      putidx $idx "# .netact <#channel/nick> <message>"
      putidx $idx "   Makes all netbots perform the specified action to"
      putidx $idx "   the specified channel or nick."
      return 0
    }
    "netnotice" {
      putidx $idx "# .netnotice <#channel/nick> <notice>"
      putidx $idx "   Makes all netbots send the specified notice to the"
      putidx $idx "   specified channel or nick."
      return 0
    }
    "netjoin" {
      putidx $idx "# .netjoin <#channel>"
      putidx $idx "   Adds the specified channel to all netbots."
      return 0
    }
    "netpart" {
      putidx $idx "# .netpart <#channel>"
      putidx $idx "   Removes the specified channel from all netbots."
      return 0
    }
    "netchanset" {
      putidx $idx "# .netchanset <#channel> \[settings\]"
      putidx $idx "   Allows you to change a channel's settings on all"
      putidx $idx "   netbots. This command works in basically the same"
      putidx $idx "   way as eggdrop's .chanset command. If no settings"
      putidx $idx "   are specified, the channel's settings are changed"
      putidx $idx "   to the defaults set in the script's options."
      return 0
    }
    "netcycle" {
      putidx $idx "# .netcycle <#channel>"
      putidx $idx "   Makes all netbots temporarily part the specified"
      putidx $idx "   channel."
      return 0
    }
  }
  putidx $idx "$command is not a valid netbot command."
}

proc nb_dccnetbots {hand idx arg} {
  global botnet-nick nb_flag nb_owner owner
  regsub -all -- "," $owner "" olist
  if {$nb_owner && [lsearch -exact [string tolower [split $olist]] [string tolower $hand]] == -1} {
    putidx $idx "What?  You need '.help'"
    return 0
  }
  putcmdlog "#$hand# netbots $arg"
  if {$nb_flag == "b" || $nb_flag == "all"} {
    putidx $idx "This command is not used if nb_flag is set to 'b' or 'all'."
    return 0
  }
  set command [lindex [split $arg] 0]
  set bothand [lindex [split $arg] 1]
  if {$command == "add"} {
    if {$bothand == ""} {
      putidx $idx "You must specify a handle."
      return 0
    }
    if {![validuser $bothand]} {
      putidx $idx "$bothand is not a valid user."
      return 0
    }
    if {![matchattr $bothand b]} {
      putidx $idx "$bothand is not a valid bot."
      return 0
    }
    chattr $bothand +$nb_flag
    nb_sendcmd "nb_netbots $hand add $bothand"
    putidx $idx "Added $bothand to netbot list."
    return 0
  }
  if {$command == "remove"} {
    if {$bothand == ""} {
      putidx $idx "You must specify a handle."
      return 0
    }
    if {![validuser $bothand]} {
      putidx $idx "$bothand is not a valid user."
      return 0
    }
    if {![matchattr $bothand b]} {
      putidx $idx "$bothand is not a valid bot."
      return 0
    }
    nb_sendcmd "nb_netbots $hand remove $bothand"
    chattr $bothand -$nb_flag
    putidx $idx "Removed $bothand from netbot list."
    return 0
  }
  if {$command == ""} {
    set botlist ""
    set offline ""
    foreach netbot [userlist $nb_flag] {
      lappend botlist $netbot
      if {[lsearch -exact [bots] $netbot] == -1 && $netbot != ${botnet-nick}} {
        lappend offline $netbot
      }
    }
    if {$botlist == ""} {
      putidx $idx "There are no netbots."
      return 0
    }
    regsub -all " " [join $botlist] ", " botlist
    regsub -all " " [join $offline] ", " offline
    if {$offline != ""} {
      putidx $idx "Current netbots: $botlist (offline or not linked: $offline)."
    } else {
      putidx $idx "Current netbots: $botlist (all netbots are online and linked)."
    }
    return 0
  } else {
    putidx $idx "Usage: .netbots \[add/remove <handle>\]"
  }
}

proc nb_netbots {frombot cmd arg} {
  global nb_flag
  if {[set arg [nb_checkbot $frombot netbots $arg]] == 0} {return 0}
  set command [lindex [split $arg] 1]
  set bothand [lindex [split $arg] 2]
  if {![validuser $bothand] || ![matchattr $bothand b]} {return 0}
  if {$command == "add"} {
    chattr $bothand +$nb_flag
    putlog "netbots \[[lindex [split $arg] 0]@$frombot\]: added $bothand to netbot list."
  } elseif {$command == "remove"} {
    chattr $bothand -$nb_flag
    putlog "netbots: removed $bothand from netbot list."
  }
}

proc nb_dccnetserv {hand idx arg} {
  global botnet-nick nb_owner numversion owner server server-online
  regsub -all -- "," $owner "" olist
  if {$nb_owner && [lsearch -exact [string tolower [split $olist]] [string tolower $hand]] == -1} {
    putidx $idx "What?  You need '.help'"
    return 0
  }
  putcmdlog "#$hand# netserv $arg"
  if {$server != ""} {
    putidx $idx "${botnet-nick} is connected to $server (connected for [nb_duration [expr [unixtime] - ${server-online}]])"
  } else {
    putidx $idx "${botnet-nick} is not connected to a server."
  }
  nb_sendcmd "nb_netserv $hand $idx"
}

proc nb_netserv {frombot cmd arg} {
  global server server-online
  if {[set arg [nb_checkbot $frombot netserv $arg]] == 0} {return 0}
  nb_putbot $frombot "nb_rnetserv [lindex [split $arg] 1] $server [expr [unixtime] - ${server-online}]"
}

proc nb_rnetserv {frombot cmd arg} {
  global numversion
  if {[set arg [nb_checkbot $frombot "netserv (reply)" $arg]] == 0} {return 0}
  set idx [lindex [split $arg] 0]
  set server [lindex [split $arg] 1]
  set connected [lindex [split $arg] 2]
  if {$server != ""} {
    putidx $idx "$frombot is connected to $server (connected for [nb_duration $connected])"
  } else {
    putidx $idx "$frombot is not connected to a server."
  }
}

proc nb_dccnetinfo {hand idx arg} {
  global botnet-nick nb_owner nb_ver owner
  regsub -all -- "," $owner "" olist
  if {$nb_owner && [lsearch -exact [string tolower [split $olist]] [string tolower $hand]] == -1} {
    putidx $idx "What?  You need '.help'"
    return 0
  }
  putcmdlog "#$hand# netinfo $arg"
  putidx $idx "${botnet-nick} is running netbots.tcl $nb_ver"
  nb_sendcmd "nb_netinfo $hand $idx"
}

proc nb_netinfo {frombot cmd arg} {
  global nb_ver
  if {[set arg [nb_checkbot $frombot netinfo $arg]] == 0} {return 0}
  nb_putbot $frombot "nb_rnetinfo [lindex [split $arg] 1] $nb_ver"
}

proc nb_rnetinfo {frombot cmd arg} {
  if {[set arg [nb_checkbot $frombot "netinfo (reply)" $arg]] == 0} {return 0}
  putidx [lindex [split $arg] 0] "$frombot is running netbots.tcl [lindex [split [string trim $arg " "]] 1]"
}

proc nb_dccnetshell {hand idx arg} {
  global botnet-nick nb_owner owner
  regsub -all -- "," $owner "" olist
  if {$nb_owner && [lsearch -exact [string tolower [split $olist]] [string tolower $hand]] == -1} {
    putidx $idx "What?  You need '.help'"
    return 0
  }
  putcmdlog "#$hand# netshell $arg"
  putidx $idx "${botnet-nick} is on [info hostname] - [string trim [exec uptime]]"
  nb_sendcmd "nb_netshell $hand $idx"
}

proc nb_netshell {frombot cmd arg} {
  if {[set arg [nb_checkbot $frombot netshell $arg]] == 0} {return 0}
  nb_putbot $frombot "nb_rnetshell [lindex [split $arg] 1] [info hostname] [string trim [exec uptime]]"
}

proc nb_rnetshell {frombot cmd arg} {
  if {[set arg [nb_checkbot $frombot "netshell (reply)" $arg]] == 0} {return 0}
  putidx [lindex [split $arg] 0] "$frombot is on [lindex [split $arg] 1] - [join [lrange [split $arg] 2 end]]"
}

proc nb_dccnetpass {hand idx arg} {
  global botnet-nick nb_flag nb_key nb_owner owner
  regsub -all -- "," $owner "" olist
  if {$nb_owner && [lsearch -exact [string tolower [split $olist]] [string tolower $hand]] == -1} {
    putidx $idx "What?  You need '.help'"
    return 0
  }
  putcmdlog "#$hand# netpass"
  set thepass [lindex [split $arg] 0]
  set forhand [lindex [split $arg] 1]
  if {$forhand == ""} {
    if {$nb_flag == "b" || $nb_flag == "all"} {
      putidx $idx "You cannot change the netbot password if nb_flag is set to 'b' or 'all'."
      return 0
    }
    if {$thepass == ""} {
      set thepass [nb_randpass]
    }
    set botlist ""
    foreach bot [userlist $nb_flag] {
      if {$bot == ${botnet-nick}} {continue}
      if {[lsearch -exact [bots] $bot] == -1} {
        lappend botlist $bot
      }
    }
    if {$botlist != ""} {
      set botlist [join $botlist ", "]
      putidx $idx "Cannot change netbot password unless all netbots are linked (currently missing: $botlist)."
      return 0
    }
    foreach bot [userlist $nb_flag] {
      setuser $bot PASS $thepass
    }
    nb_sendcmd "nb_netpass $hand [encrypt $nb_key $thepass]"
    putidx $idx "Changed netbot password to '$thepass'."
    return 0
  }
  if {$thepass != "" && $forhand != ""} {
    if {![validuser $forhand]} {
      putidx $idx "$forhand is not a valid user."
      return 0
    }
    setuser $forhand PASS $thepass
    nb_sendcmd "nb_netpass $hand [encrypt $nb_key $thepass] $forhand"
    putidx $idx "Changed password for $forhand to '$thepass'."
  }
}

proc nb_netpass {frombot cmd arg} {
  global nb_flag nb_key
  if {[set arg [nb_checkbot $frombot netpass $arg]] == 0} {return 0}
  set thepass [decrypt $nb_key [lindex [split $arg] 1]]
  set forhand [lindex [split $arg] 2]
  if {$forhand == ""} {
    foreach bot [userlist $nb_flag] {
      setuser $bot PASS $thepass
    }
    putlog "netbots \[[lindex [split $arg] 0]@$frombot\]: changed netbot password."
    return 0
  }
  setuser $forhand PASS $thepass
  putlog "netbots \[[lindex [split $arg] 0]@$frombot\]: changed password for $forhand."
}

proc nb_dccnetsave {hand idx arg} {
  global nb_owner owner
  regsub -all -- "," $owner "" olist
  if {$nb_owner && [lsearch -exact [string tolower [split $olist]] [string tolower $hand]] == -1} {
    putidx $idx "What?  You need '.help'"
    return 0
  }
  putcmdlog "#$hand# netsave $arg"
  putidx $idx "Performing netbot userfile/chanfile save."
  save
  nb_sendcmd "nb_netsave $hand"
}

proc nb_netsave {frombot cmd arg} {
  if {[set arg [nb_checkbot $frombot netsave $arg]] == 0} {return 0}
  putlog "netbots \[[lindex [split $arg] 0]@$frombot\]: performing netbot userfile/chanfile save."
  save
}

proc nb_dccnethash {hand idx arg} {
  global nb_owner owner
  regsub -all -- "," $owner "" olist
  if {$nb_owner && [lsearch -exact [string tolower [split $olist]] [string tolower $hand]] == -1} {
    putidx $idx "What?  You need '.help'"
    return 0
  }
  putcmdlog "#$hand# nethash $arg"
  putidx $idx "Rehashing netbots."
  uplevel {rehash}
  nb_sendcmd "nb_nethash $hand"
}

proc nb_nethash {frombot cmd arg} {
  if {[set arg [nb_checkbot $frombot nethash $arg]] == 0} {return 0}
  putlog "netbots \[[lindex [split $arg] 0]@$frombot\]: rehashing."
  uplevel {rehash}
}

proc nb_dccnetsay {hand idx arg} {
  global nb_owner owner
  regsub -all -- "," $owner "" olist
  if {$nb_owner && [lsearch -exact [string tolower [split $olist]] [string tolower $hand]] == -1} {
    putidx $idx "What?  You need '.help'"
    return 0
  }
  putcmdlog "#$hand# netsay $arg"
  set sayto [lindex [split $arg] 0]
  set themsg [join [lrange [split $arg] 1 end]]
  if {$sayto == "" || $themsg == ""} {
    putidx $idx "Usage: .netsay <#channel/nick> <message>"
    return 0
  }
  nb_sendcmd "nb_netsay $hand $sayto $themsg"
  putserv "PRIVMSG $sayto :$themsg"
}

proc nb_netsay {frombot cmd arg} {
  if {[set arg [nb_checkbot $frombot netsay $arg]] == 0} {return 0}
  set sayto [lindex [split $arg] 1]
  putlog "netbots \[[lindex [split $arg] 0]@$frombot\]: sending message to $sayto"
  putserv "PRIVMSG $sayto :[join [lrange [split $arg] 2 end]]"
}

proc nb_dccnetact {hand idx arg} {
  global nb_owner owner
  regsub -all -- "," $owner "" olist
  if {$nb_owner && [lsearch -exact [string tolower [split $olist]] [string tolower $hand]] == -1} {
    putidx $idx "What?  You need '.help'"
    return 0
  }
  putcmdlog "#$hand# netact $arg"
  set actto [lindex [split $arg] 0]
  set theact [join [lrange [split $arg] 1 end]]
  if {$actto == "" || $theact == ""} {
    putidx $idx "Usage: .netact <#channel/nick> <action>"
    return 0
  }
  nb_sendcmd "nb_netact $hand $actto $theact"
  putserv "PRIVMSG $actto :\001ACTION $theact\001"
}

proc nb_netact {frombot cmd arg} {
  if {[set arg [nb_checkbot $frombot netact $arg]] == 0} {return 0}
  set actto [lindex [split $arg] 1]
  putlog "netbots \[[lindex [split $arg] 0]@$frombot\]: sending action to $actto"
  putserv "PRIVMSG $actto :\001ACTION [join [lrange [split $arg] 2 end]]\001"
}

proc nb_dccnetnotc {hand idx arg} {
  global nb_owner owner
  regsub -all -- "," $owner "" olist
  if {$nb_owner && [lsearch -exact [string tolower [split $olist]] [string tolower $hand]] == -1} {
    putidx $idx "What?  You need '.help'"
    return 0
  }
  putcmdlog "#$hand# netnotice $arg"
  set notcto [lindex [split $arg] 0]
  set thenotc [join [lrange [split $arg] 1 end]]
  if {$notcto == "" || $thenotc == ""} {
    putidx $idx "Usage: .netnotice <#channel/nick> <notice>"
    return 0
  }
  nb_sendcmd "nb_netnotc $hand $notcto $thenotc"
  putserv "NOTICE $notcto :$thenotc"
}

proc nb_netnotc {frombot cmd arg} {
  if {[set arg [nb_checkbot $frombot netnotice $arg]] == 0} {return 0}
  set notcto [lindex [split $arg] 1]
  putlog "netbots \[[lindex [split $arg] 0]@$frombot\]: sending notice to $notcto"
  putserv "NOTICE $notcto :[join [lrange [split $arg] 2 end]]"
}

proc nb_dccnetjoin {hand idx arg} {
  global nb_owner owner
  regsub -all -- "," $owner "" olist
  if {$nb_owner && [lsearch -exact [string tolower [split $olist]] [string tolower $hand]] == -1} {
    putidx $idx "What?  You need '.help'"
    return 0
  }
  putcmdlog "#$hand# netjoin $arg"
  global nb_chanmode nb_chansets nb_fludchan nb_fluddeop nb_fludkick nb_fludjoin nb_fludctcp nb_idlekick
  set chan [lindex [split $arg] 0]
  if {[string index $chan 0] != "#"} {
    putidx $idx "Usage: .netjoin <#channel>"
    return 0
  }
  putidx $idx "Adding channel $chan to netbots."
  nb_sendcmd "nb_netjoin $hand $chan"
  if {![validchan $chan]} {
    channel add $chan
  }
  channel set $chan chanmode $nb_chanmode
  channel set $chan idle-kick $nb_idlekick
  channel set $chan flood-chan $nb_fludchan
  channel set $chan flood-deop $nb_fluddeop
  channel set $chan flood-kick $nb_fludkick
  channel set $chan flood-join $nb_fludjoin
  channel set $chan flood-ctcp $nb_fludctcp
  foreach chanset $nb_chansets {
    channel set $chan $chanset
  }
}

proc nb_netjoin {frombot cmd arg} {
  global nb_chanmode nb_chansets nb_fludchan nb_fluddeop nb_fludkick nb_fludjoin nb_fludctcp nb_idlekick
  if {[set arg [nb_checkbot $frombot netjoin $arg]] == 0} {return 0}
  set chan [lindex [split $arg] 1]
  putlog "netbots \[[lindex [split $arg] 0]@$frombot\]: adding channel $chan"
  if {![validchan $chan]} {
    channel add $chan
  }
  channel set $chan chanmode $nb_chanmode
  channel set $chan idle-kick $nb_idlekick
  channel set $chan flood-chan $nb_fludchan
  channel set $chan flood-deop $nb_fluddeop
  channel set $chan flood-kick $nb_fludkick
  channel set $chan flood-join $nb_fludjoin
  channel set $chan flood-ctcp $nb_fludctcp
  foreach chanset $nb_chansets {
    channel set $chan $chanset
  }
}

proc nb_dccnetpart {hand idx arg} {
  global nb_owner owner
  regsub -all -- "," $owner "" olist
  if {$nb_owner && [lsearch -exact [string tolower [split $olist]] [string tolower $hand]] == -1} {
    putidx $idx "What?  You need '.help'"
    return 0
  }
  putcmdlog "#$hand# netpart $arg"
  set chan [lindex [split $arg] 0]
  if {[string index $chan 0] != "#"} {
    putidx $idx "Usage: .netpart <#channel>"
    return 0
  }
  putidx $idx "Removing channel $chan from netbots."
  nb_sendcmd "nb_netpart $hand $chan"
  if {![validchan $chan] || ![isdynamic $chan]} {return 0}
  channel remove $chan
}

proc nb_netpart {frombot idx arg} {
  if {[set arg [nb_checkbot $frombot netpart $arg]] == 0} {return 0}
  set chan [lindex [split $arg] 1]
  putlog "netbots \[[lindex [split $arg] 0]@$frombot\]: removing channel $chan"
  if {![validchan $chan] || ![isdynamic $chan]} {return 0}
  channel remove $chan
}

proc nb_dccnetchanset {hand idx arg} {
  global nb_chanmode nb_chansets nb_fludchan nb_fluddeop nb_fludkick nb_fludjoin nb_fludctcp nb_idlekick nb_owner owner
  regsub -all -- "," $owner "" olist
  if {$nb_owner && [lsearch -exact [string tolower [split $olist]] [string tolower $hand]] == -1} {
    putidx $idx "What?  You need '.help'"
    return 0
  }
  putcmdlog "#$hand# netchanset $arg"
  set chan [string tolower [lindex [split $arg] 0]]
  set settings [lrange [split $arg] 1 end]
  if {[string index $chan 0] != "#"} {
    putidx $idx "Usage: .netchanset <#channel> \[settings\]"
    return 0
  }
  if {$settings == ""} {
    putidx $idx "Setting channel settings for $chan to netbots default settings."
    nb_sendcmd "nb_netchanset $hand $chan"
    if {[validchan $chan]} {
      channel set $chan chanmode $nb_chanmode
      channel set $chan idle-kick $nb_idlekick
      channel set $chan flood-chan $nb_fludchan
      channel set $chan flood-deop $nb_fluddeop
      channel set $chan flood-kick $nb_fludkick
      channel set $chan flood-join $nb_fludjoin
      channel set $chan flood-ctcp $nb_fludctcp
      foreach chanset $nb_chansets {
        channel set $chan $chanset
      }
    }
  } else {
    if {[string match "need-*" [lindex $settings 0]]} {
      putidx $idx "You cannot change need-op/invite/key/limit/unban settings."
      return 0
    }
    putidx $idx "Setting channel settings for $chan to '[lrange $settings 0 end]' on netbots."
    nb_sendcmd "nb_netchanset $hand $chan $settings"
    if {[validchan $chan]} {
      if {[string index [lindex $settings 0] 0] == "+" || [string index [lindex $settings 0] 0] == "-"} {
        foreach chanset $settings {
          channel set $chan $chanset
        }
      } else {
        channel set $chan [lindex $settings 0] [lindex $settings 1]
      }
    }
  }
}

proc nb_netchanset {frombot cmd arg} {
  global nb_chanmode nb_chansets nb_fludchan nb_fluddeop nb_fludkick nb_fludjoin nb_fludctcp nb_idlekick
  if {[set arg [nb_checkbot $frombot netchanset $arg]] == 0} {return 0}
  set chan [lindex [split $arg] 1]
  set settings [lrange [split $arg] 2 end]
  if {$settings == ""} {
    putlog "netbots \[[lindex [split $arg] 0]@$frombot\]: setting channel settings for $chan to netbots default settings."
    if {[validchan $chan]} {
      channel set $chan chanmode $nb_chanmode
      channel set $chan idle-kick $nb_idlekick
      channel set $chan flood-chan $nb_fludchan
      channel set $chan flood-deop $nb_fluddeop
      channel set $chan flood-kick $nb_fludkick
      channel set $chan flood-join $nb_fludjoin
      channel set $chan flood-ctcp $nb_fludctcp
      foreach chanset $nb_chansets {
        channel set $chan $chanset
      }
    }
  } else {
    if {[string match "need-*" [lindex $settings 0]]} {return 0}
    putlog "netbots \[[lindex [split $arg] 0]@$frombot\]: setting channel settings for $chan to '[lrange $settings 0 end]'."
    if {[validchan $chan]} {
      if {[string index [lindex $settings 0] 0] == "+" || [string index [lindex $settings 0] 0] == "-"} {
        foreach chanset $settings {
          channel set $chan $chanset
        }
      } else {
        channel set $chan [lindex $settings 0] [lindex $settings 1]
      }
    }
  }
}

proc nb_dccnetcycle {hand idx arg} {
  global nb_owner owner
  regsub -all -- "," $owner "" olist
  if {$nb_owner && [lsearch -exact [string tolower [split $olist]] [string tolower $hand]] == -1} {
    putidx $idx "What?  You need '.help'"
    return 0
  }
  putcmdlog "#$hand# netcycle $arg"
  set chan [lindex [split $arg] 0]
  if {[string index $chan 0] != "#"} {
    putidx $idx "Usage: .netcycle <#channel>"
    return 0
  }
  putidx $idx "Making netbots cycle $chan."
  nb_sendcmd "nb_netcycle $hand $chan"
  if {![validchan $chan]} {return 0}
  putserv "PART $chan"
}

proc nb_netcycle {frombot idx arg} {
  if {[set arg [nb_checkbot $frombot netcycle $arg]] == 0} {return 0}
  set chan [lindex [split $arg] 1]
  putlog "netbots \[[lindex [split $arg] 0]@$frombot\]: cycling $chan"
  if {![validchan $chan]} {return 0}
  putserv "PART $chan"
}

proc nb_tautopass {min hour day month year} {
  global botnet-nick nb_flag nb_key
  putlog "netbots: initiating botnet password change..."
  set thepass [nb_randpass]
  set botlist ""
  foreach bot [userlist $nb_flag] {
    if {$bot == ${botnet-nick}} {continue}
    if {[lsearch -exact [bots] $bot] == -1} {
      lappend botlist $bot
    }
  }
  if {$botlist != ""} {
    set botlist [join $botlist ", "]
    putlog "netbots: cannot change netbot password because not all netbots are linked (currently missing: $botlist)."
    return 0
  }
  foreach bot [userlist $nb_flag] {
    setuser $bot PASS $thepass
  }
  save
  nb_sendcmd "nb_autopass ${botnet-nick} [encrypt $nb_key $thepass]"
  putlog "netbots: changed netbot password."
  return 0
}

proc nb_autopass {frombot cmd arg} {
  global nb_flag nb_key
  if {[set arg [nb_checkbot $frombot netpass $arg]] == 0} {return 0}
  set thepass [decrypt $nb_key [lindex [split $arg] 1]]
  foreach bot [userlist $nb_flag] {
    setuser $bot PASS $thepass
  }
  save
  putlog "netbots \[$frombot\]: changed netbot password."
}

proc nb_sendcmd {cmd} {
  global botnet-nick nb_flag nb_key
  set command [lindex [split $cmd] 0]
  set key [encrypt $nb_key "${botnet-nick} [join [lrange [split $cmd] 1 end]]"]
  if {$nb_flag == "all"} {
    putallbots "$command $key"
  } else {
    foreach bot [userlist $nb_flag] {
      if {[lsearch -exact [bots] $bot] == -1} {continue}
      putbot $bot "$command $key"
    }
  }
}

proc nb_putbot {bot cmd} {
  global botnet-nick nb_key
  set command [lindex [split $cmd] 0]
  set key [encrypt $nb_key "${botnet-nick} [join [lrange [split $cmd] 1 end]]"]
  if {[lsearch -exact [bots] $bot] != -1} {
    putbot $bot "$command $key"
  }
}

proc nb_checkbot {frombot cmd arg} {
  global nb_flag nb_hub nb_key
  if {$nb_flag != "all" && ![matchattr $frombot $nb_flag]} {
    putlog "netbots: rejected '$cmd' command from $frombot (not a valid netbot)."
    return 0
  }
  set arg [decrypt $nb_key $arg]
  if {[lindex [split $arg] 0] != $frombot} {
    putlog "netbots: rejected '$cmd' command from $frombot (incorrect key)."
    return 0
  }
  if {$nb_hub && ![matchattr $frombot ||h] && [lindex [split $cmd] 1] != "(reply)"} {
    putlog "netbots: rejected '$cmd' command from $frombot (not a hub bot)."
    return 0
  }
  return [join [lrange [split $arg] 1 end]]
}

proc nb_randpass {} {
  for {set x 0} {$x < 9} {incr x} {
    append randpass [string index "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890" [rand 61]]
  }
  return $randpass
}

proc nb_duration {connected} {
  # This proc is based on that used in Bass's Seen script (http://bseen.tclslave.net)
  set years 0
  set days 0
  set hours 0
  set mins 0
  set time $connected
  if {$time < 60} {
    return "< 1 min"
  }
  if {$time >= 31536000} {
    set years [expr int([expr $time/31536000])]
    set time [expr $time - [expr 31536000*$years]]
  }
  if {$time >= 86400} {
    set days [expr int([expr $time/86400])]
    set time [expr $time - [expr 86400*$days]]
  }
  if {$time >= 3600} {
    set hours [expr int([expr $time/3600])]
    set time [expr $time - [expr 3600*$hours]]
  }
  if {$time >= 60} {
    set mins [expr int([expr $time/60])]
  }
  if {$years == 0} {
    set output ""
  } elseif {$years == 1} {
    set output "1 yr,"
  } else {
    set output "$years yrs,"
  }
  if {$days == 1} {
    lappend output "1 day,"
  } elseif {$days > 1} {
    lappend output "$days days,"
  }
  if {$hours == 1} {
    lappend output "1 hr,"
  } elseif {$hours > 1} {
    lappend output "$hours hrs,"
  }
  if {$mins == 1} {
    lappend output "1 min"
  } elseif {$mins > 1} {
    lappend output "$mins mins"
  }
  return [string trimright [join $output] ", "]
}

set nb_ver "v1.16"

bind time - "07 04 * * *" nb_tautopass
if {!$nb_autopass || $nb_flag == "b" || $nb_flag == "all"} {
  unbind time - "07 04 * * *" nb_tautopass
}
bind bot - nb_netbots nb_netbots
bind bot - nb_netinfo nb_netinfo
bind bot - nb_rnetinfo nb_rnetinfo
bind bot - nb_netshell nb_netshell
bind bot - nb_rnetshell nb_rnetshell
bind bot - nb_netserv nb_netserv
bind bot - nb_rnetserv nb_rnetserv
bind bot - nb_netpass nb_netpass
bind bot - nb_netsave nb_netsave
bind bot - nb_nethash nb_nethash
bind bot - nb_netsay nb_netsay
bind bot - nb_netact nb_netact
bind bot - nb_netnotc nb_netnotc
bind bot - nb_netjoin nb_netjoin
bind bot - nb_netpart nb_netpart
bind bot - nb_netchanset nb_netchanset
bind bot - nb_netcycle nb_netcycle
bind bot - nb_autopass nb_autopass

bind dcc n nethelp nb_dccnethelp
bind dcc n netbots nb_dccnetbots
bind dcc n netinfo nb_dccnetinfo
bind dcc n netshell nb_dccnetshell
bind dcc n netserv nb_dccnetserv
bind dcc n netpass nb_dccnetpass
bind dcc n netsave nb_dccnetsave
bind dcc n nethash nb_dccnethash
bind dcc n netsay nb_dccnetsay
bind dcc n netact nb_dccnetact
bind dcc n netnotice nb_dccnetnotc
bind dcc n netjoin nb_dccnetjoin
bind dcc n netpart nb_dccnetpart
bind dcc n netchanset nb_dccnetchanset
bind dcc n netcycle nb_dccnetcycle

putlog "Loaded netbots.tcl $nb_ver by slennox"

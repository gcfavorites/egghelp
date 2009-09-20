# uptimerecord.tcl v1.0 - by FireEgl@EFNet <FireEgl@LinuxFan.com> - July 16, 2000

### Description:
# Remembers the bots best uptimes, and announces when it breaks it's own record.
# It keeps up with 4 different types of "uptimes"... The bots uptime, the time
# it's been connected to an IRC server, how long the system it's running on has
# been up, and how long it's been connected to it's hub bot.  Any others it should do? ;P

### Reasons:
# Like all my scripts, I thought it was a neat idea and it hasn't been done before.  =)

### Notes:
# It checks once an hour to see if it's beat it's best "uptimes".
# It stores the records into *.$botnet-nick.txt files.

### Public (channel) Commands:
## Note: These are limited to +m|+n users, because of the bots "flooding" the
## channel with the info.  (They should be redone to be less annoying somehow.)
# !uptime [type] - Shows the bots current uptime(s).
# !record [type] - Shows the bots best (record) uptime(s).
# $botnet-nick uptime [type] - Asks only that bot for it's uptime(s).
# $botnet-nick record [type] - Asks only that bot for it's best uptime(s).

### DCC (telnet) Commands:
# .uptime [type] - Shows the current uptime(s). (Enhanced from Eggdrop's built-in .uptime command.)
# .record [type] - Shows the best uptime(s).

### Requirements:
# At least TCL v8.0.x, but not v8.3b*, 8.3.0, or 8.3.1 (there's a bug in "clock scan")
# Any Eggdrop supporting "bind time".
# For the bot to get/store/announce system uptime records,
# your shell must have the uptime utility. (most do)
# Or for Windrops:
# I have an uptime.exe (a Windows native util) available at
# http://Registry.LinuxAve.Net/download/misc/uptime.exe
# Also, you may want uname.exe for Cygwin related info to be
# added to the system uptime announcements/messages.  =)
# It comes with Cygwin - http://SourceWare.Cygnus.com/cygwin/
# I have it available also, at
# http://Registry.LinuxAve.Net/download/misc/uname.exe

### Questions?  Comments?  Suggestions?
# Email me at FireEgl@LinuxFan.com

### Options:
## Which channels should we announce the
## new records in?  Or set to "" for none.
set uptime_announce(channels) "#EggHeads #Windrop #TCLHelp"

## Who should we send a note to when a new record is set?:
# (This can be a list of handles, or set to "" for none)
set uptime_announce(note) "FireEgl Moonsoul"

## Say 1 here if you want everybody logged in on your
## botnet to see the new record, or 0 to disable.
set uptime_announce(dccbroadcast) 1

## Which .chat channel should we announce the record in?:
# (-1 to disable, 0 = partyline, 1 or higher for private channels.)
set uptime_announce(chatchan) 411

## These are the uptimes that this script tracks..
# If you don't want it to track all of these, just comment out the ones you don't want.
set uptime_track(uptime) "Bot (Eggdrop v[lindex $version 0], TCL v[info patchlevel]) Uptime"
set uptime_track(server-online) "Connected to IRC"
set uptime_track(hub-linked) "Linked to Hub Bot"
# Note: Leave %os% alone to have it automatically stick in your OS and OS version.
set uptime_track(system-uptime) "System Uptime (%os%)"

### What directory to store the *.$botnet-nick.txt files in?
## Note: Defaults to the same directory as this script; if you change it try to use an absolute path name.
set uptime_saveto "[file join [pwd] [string trimright [file dirname [info script]] ./]]"


### Begin Script:
## If you make any improvements to this script
# please email me a copy to FireEgl@LinuxFan.com

# I think Eggdrop will do this for us, but just in case...
if {![info exists botnet-nick]} { set botnet-nick "$nick" }

if {![array exists uptime_track]} { return [putlog "uptimerecord.tcl: You must specify at least one type of \"uptime\" before this script can do anything!"] }

# The 59 here is the minute of the hour in which it checks to see if it broke it's record, change it if you wish.
bind time - "59 * * * *" check:uptime
proc check:uptime {args} { global uptime_track botnet-nick uptime_saveto
   foreach t "[array names uptime_track]" { global $t $t-best $t-beat
      if {(([set $t] > 0) && ([set current [expr [unixtime] - [set $t]]] > [set $t-best]))} { set $t-best "$current"
         if {[catch { puts [set out [open "[file join $uptime_saveto $t.${botnet-nick}.txt]" w]] "[set $t-best]" }]} {
            set message "Can't write to [file join $uptime_saveto $t.${botnet-nick}.txt] - Check the permissions."
            putlog "$message"
            foreach h "[split $uptime_announce(note)]" { if {[validuser $h]} { catch { sendnote UptimeRecord $h "$message" } } }
         } else {
            close "$out"
         }
         uptime:announce "$t"
         # We use *-beat so it'll only announce once per session (since the bot started).
         set $t-beat 1
      }
   }
   return 1
}

# Announces when the bot breaks a record, if we haven't already beat it already this session:
proc uptime:announce {which} { global uptime_track $which-beat $which $which-best uptime_announce server
   if {((![set $which-beat]) && ([set current [expr [unixtime] - [set $which]]] >= [set $which-best]))} {
      putlog [set message "New $uptime_track($which) Record!  [duration $current]."]
      if {"$server" != ""} { foreach c "$uptime_announce(channels)" { catch { puthelp "PRIVMSG $c :$message" } } }
      foreach h "[split $uptime_announce(note)]" { if {[validuser $h]} { catch { sendnote UptimeRecord $h "$message" } } }
      if {$uptime_announce(dccbroadcast)} { catch { dccbroadcast "$message" } }
      if {$uptime_announce(chatchan) != -1} { catch { dccputchan $uptime_announce(chatchan) "$message" } }
   }
}

# This public command that shows all the current uptimes:
# (Needs rewriting..)
bind pub m|n !uptime pub:uptimes
bind pubm m|n "*${botnet-nick}*uptime*" pub:uptimes
bind pubm m|n "*uptime*${botnet-nick}*" pub:uptimes
proc pub:uptimes {nick host hand chan arg} { check:uptime
   if {![matchattr $hand b]} { global uptime_track
      if {([llength $arg] < 3) || ([lsearch "[array names uptime_track]" "[set showrecs [lindex [string trim [string tolower [split $arg]] ?] end]]"] == -1)} { set showrecs "[array names uptime_track]" }
      foreach t "$showrecs" { global $t $t-best $t-beat
         if {([info exists $t]) && ([set $t] > 0)} {
            if {[set current [expr [unixtime] - [set $t]]] >= [set $t-best]} {
               puthelp "PRIVMSG $chan :$uptime_track($t) is currently [duration $current] and is the New Record!"
            } else {
               puthelp "PRIVMSG $chan :$uptime_track($t) is currently [duration $current]."
            }
         }
      }
   }
}

# This public command shows all the record (best) uptimes:
# (Needs rewriting..)
bind pub m|n !record pub:records
bind pubm m|n "*${botnet-nick}*record*" pub:records
bind pubm m|n "*record*${botnet-nick}*" pub:records
proc pub:records {nick host hand chan arg} { check:uptime
   if {![matchattr $hand b]} { global uptime_track
      if {([llength $arg] < 3) || ([lsearch "[array names uptime_track]" "[set showrecs [lindex [string trim [string tolower [split $arg]] ?] end]]"] == -1)} { set showrecs "[array names uptime_track]" }
      foreach t "$showrecs" { global $t $t-best $t-beat
         if {([info exists $t-best]) && ([set $t-best] > 0)} {
            if {([set current [expr [unixtime] - [set $t]]] >= [set $t-best]) && ([set $t] > 0)} {
               puthelp "PRIVMSG $chan :$uptime_track($t) is currently [duration $current] and is the New Record!"
            } else {
               puthelp "PRIVMSG $chan :Record for $uptime_track($t) is [duration [set $t-best]]."
            }
         }
      }
   }
}

if {[info exists uptime_track(system-uptime)]} {
   # I feel like adding lots more info to the tcl_platform array...  =)
   foreach {a b} "machine m nodename n release r sysname s processor p" { if {![info exists tcl_platform($a)]} { if {[catch { set tcl_platform($a) "[exec uname -$b]" }]} { set tcl_platform($a) "" } } }
   unset a b
   if {"$tcl_platform(machine)" == "intel"} { catch {set tcl_platform(machine) "[exec uname -m]"} }
   if {![info exists tcl_platform(dist)]} { set tcl_platform(dist) ""
      if {"$tcl_platform(os)" == "Linux"} {
         if {[file readable "/etc/redhat-release"]} {
            set tcl_platform(dist) "[gets [set fid [open /etc/redhat-release r]]]"
            close $fid
         } elseif {[file readable "/etc/slackware-version"]} {
            set tcl_platform(dist) "Slackware [gets [set fid [open /etc/slackware-version r]]]"
            close $fid
         } elseif {[file readable "/etc/debian_version"]} {
            set tcl_platform(dist) "Debian [gets [set fid [open /etc/debian_version r]]]"
            close $fid
         }
         if {[info exists fid]} { unset fid }
      # Windows 95?? I hate that.. I'm running Windows Millennium Edition!
      # So we change it to what "ver" says (if possible):
      } elseif {"$tcl_platform(os)" == "Windows 95"} {
         if {(![catch { set tcl_platform(os) "[concat [exec command.com /c ver]]" }]) || (![catch { set tcl_platform(os) "[concat [exec cmd.exe /c ver]]" }])} {
            set tcl_platform(osVersion) "[join [lindex [lindex [split $tcl_platform(os) \[\]] 1] 1]]"
            set tcl_platform(os) "[join [lindex [split $tcl_platform(os) \[\]] 0]]"
         } else {
            set tcl_platform(os) "Windows 9x"
         }
         if {[catch { set tcl_platform(dist) "[exec uname -sr]" }]} { set tcl_platform(dist) "Cygwin" }
      }
   }
   regsub -- "%os%" "$uptime_track(system-uptime)" [join "{$tcl_platform(os) v$tcl_platform(osVersion) ($tcl_platform(machine))} {$tcl_platform(dist)}" ", "] uptime_track(system-uptime)
}

### Here's where we add special stuff that sets the [unixtime] to stuff that Eggdrop doesn't set for us:
## This one sets the [unixtime] when we connected to the hub bot:
# (Hopefully you only connect to one hub at a time.  =P)
if {[info exists uptime_track(hub-linked)]} {
   bind link b * link:uptime:hublinked
   proc link:uptime:hublinked {bot via} {
      if {(([matchattr $bot b]) && ([string match "*h*" "[getuser $bot BOTFL]"]))} {
         global hub-linked
         set hub-linked "[unixtime]"
      }
   }
   bind disc b * disc:uptime:hublinked
   proc disc:uptime:hublinked {bot} {
      if {(([matchattr $bot b]) && ([string match "*h*" "[getuser $bot BOTFL]"]))} { check:uptime
         global hub-linked
         set hub-linked "0"
      }
   }
}

## This one gets the uptime of the system we're running on and converts it to "unixtime":
# (Requires the uptime util found on most shells, or uptime.exe if you're using a Windows Eggdrop.)
# This is an awful hack. =)  Although I don't believe it can be done a whole lot better considering.
if {[info exists uptime_track(system-uptime)]} {
   catch {
      set pos "[expr [lsearch -glob [set tmp_uptime [lrange [exec uptime] 2 end]] user*] - 2]"
      set tmp_uptime "[string trim [lrange $tmp_uptime 0 $pos] ,]"
      set system-uptime [clock scan [set blah "[join [lindex [split [string trim $tmp_uptime ,] ,] 0]] [lindex [split [lindex $tmp_uptime end] :] 0] hours [lindex [split [lindex $tmp_uptime end] :] 1] minutes ago"]]
      if {"[lrange $blah 1 3]" == "min min hours"} { set system-uptime [clock scan "[lrange $blah 0 1] ago"] }
   }
}
catch { unset tmp_uptime }
catch { unset pos }

# Set stuff to the last known, or initial values (if they're missing):
# This is a proc because it has to be ran after the bot loads the userfile. (The proc will be deleted after it runs)
timer 1 loadrecorduptimes
proc loadrecorduptimes {} { global uptime_track botnet-nick uptime_announce uptime_saveto
   foreach t "[array names uptime_track]" { global $t $t-best $t-beat
      if {![info exists $t]} { set $t 0 }
      if {![info exists $t-best]} {
         if {[file readable "[file join $uptime_saveto $t.${botnet-nick}.txt]"]} {
            if {![llength [set $t-best [gets [set in [open "[file join $uptime_saveto $t.${botnet-nick}.txt]" r]]]]]} {
               set message "WARNING: $t.${botnet-nick}.txt was empty!  (Record for $t has been reset)"
               putlog "$message"
               foreach h "[split $uptime_announce(note)]" { if {[validuser $h]} { catch { sendnote UptimeRecord $h "$message" } } }
            }
            close $in
         } else {
            set $t-best 1
            set message "NOTICE: $t.${botnet-nick}.txt was not found.. (Probably because you just installed this script?)"
            putlog "$message"
            foreach h "[split $uptime_announce(note)]" { if {[validuser $h]} { catch { sendnote UptimeRecord $h "$message" } } }
         }
      }
      if {![info exists $t-beat]} { set $t-beat 0 }
   }
   rename loadrecorduptimes ""
}

putlog "uptimerecord.tcl v1.0 - by FireEgl@EFNet <FireEgl@LinuxFan.com> - Loaded."

timer 2 check:uptime

# There's a number of other binds in which it'd be good to do the uptime record check:
catch {
 bind dcc m checkuptime check:uptime
 bind dcc m uptimecheck check:uptime
 bind chjn n * check:uptime
 bind evnt - sigterm check:uptime
 bind evnt - sigquit check:uptime
 bind evnt - sigill check:uptime
 bind evnt - sighup check:uptime
 bind evnt - prerehash check:uptime
 bind evnt - disconnect-server check:uptime
 bind evnt - save check:uptime
 bind evnt - init-server check:uptime
 bind evnt - logfile check:uptime
 bind filt n ".die*" filt:checkuptime
 bind filt n ".backup*" filt:checkuptime
 bind filt n ".status*" filt:checkuptime
 bind filt n ".restart*" filt:checkuptime
 proc filt:checkuptime {idx text} { check:uptime ; set text }
}

# My intention here was to add to and not replace the original .uptime command:
catch {
 bind filt m ".uptime*" filt:uptime:uptime
 proc filt:uptime:uptime {idx arg} { utimer 1 [list dcc:filt:uptime $idx $arg] }
 # (Needs rewriting to be more modular with the other uptime/record pub/dcc commands.)
 proc dcc:filt:uptime {idx arg} { check:uptime
    global uptime_track
    if {([llength $arg] < 1) || ([lsearch "[array names uptime_track]" "[set showrecs [lindex [string trim [string tolower [split $arg]] ?] end]]"] == -1)} { set showrecs "[array names uptime_track]" }
    foreach t "$showrecs" { global $t $t-best $t-beat
       if {(([info exists $t]) && ([set $t] > 0) && ("$t" != "uptime"))} {
          if {[set current [expr [unixtime] - [set $t]]] >= [set $t-best]} {
             putdcc $idx "$uptime_track($t) for [duration $current] and is the New Record!"
          } else {
             putdcc $idx "$uptime_track($t) for [duration $current]."
          }
       }
    }
    set arg
 }
}

# The dcc .record command:
# (Needs rewriting to be more modular with the other uptime/record pub/dcc commands.)
bind dcc m record dcc:record
proc dcc:record {hand idx arg} { global uptime_track
   if {([llength $arg] < 1) || ([lsearch "[array names uptime_track]" "[set showrecs [lindex [string trim [string tolower [split $arg]] ?] end]]"] == -1)} { set showrecs "[array names uptime_track]" }
   foreach t "$showrecs" { global $t $t-best $t-beat
      if {([info exists $t-best]) && ([set $t-best] > 0)} {
         if {([set current [expr [unixtime] - [set $t]]] >= [set $t-best]) && ([set $t] > 0)} {
            putdcc $idx "$uptime_track($t) is currently [duration $current] and is the New Record!"
         } else {
            putdcc $idx "Record for $uptime_track($t) is [duration [set $t-best]]."
         }
      }
   }
   set arg 1
}

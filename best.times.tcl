#----------------------------------------------------------------------------------
#- best times 1.4.3 - by wreck (EFnet/GCnet)
#
#  Переписано для работы с pub by tvrsh (IrcNet.ru/RusNet)
#  DCC команда удалена. Подсчет ведется только в днях, убраны недели, месяцы и года.
#  Подкрашено и исправлено несколько ошибок. Переведены дни недели и месяцы.
#
#-   Keeps track of your bots' best ontime (how long it's been connected to it's
#-   server) and uptime (how long it's been running), and saves them to a file.
#
#- Has been beta tested on every major eggdrop version to date (that's 1.6.2)
#----------------------------------------------------------------------------------
#- Pub Command (for o|o only)
#
#- uptime
#-   Will echo the bot's best on and uptime messages to channel.
#----------------------------------------------------------------------------------
#- Below are some variables you need to customize before installing:

# Leave the following line of code here. Don't delete/edit it, or may get errors.
if {[info exists bt-datafile]} {unset bt-datafile}

# File to store your bots' best on/uptime data to, needs FULL path and filename.
# Set each file's index as the bot's botnet-nick (even if this is for only one bot).
# 
# Example: 
#    set bt-datafile(botname) "/home/wreck/eggdrop/scripts/best"
#       
# 'botname' being the index; 
#    This file would only be used for the bot that has the botnet-nick 'botname'.
#
# You can specify a file for each bot that will be using this script.
#

set bt-datafile(quiz) "/hosting/extigy/eggdrop/scripts/best"
#set bt-datafile(bawt2) "/home/wreck/eggdrop/scripts/best.2"

# Interval, in minutes, to check and (if necessary) update my bt-datafile.
set bt-interval 5

# Announce (in partyline) everytime I update my bt-datafile? (1 = yes, 0 = no)
set bt-log 0

# Announce (in partyline) everytime I break an on/uptime record? (1 = yes, 0 = no)
# Note:  That this will only notify if needed, once every restart
#        for uptime and only once every new server for ontime.
set bt-announce 0

# Messages to be used in the .besttimes command
# You can insert these tokens in your message to be interpreted as..
#
# %! = bold character
# %_ = underline character
# %A = best uptime (ie: 3w 4d 4h 52m 9s)
# %B = full date on which best uptime was set (ie: Friday, October 13, 2000)
# %C = short date on which best uptime was set (ie: 10/13/2000)
# %D = time best uptime was set at (ie: 08:04:38)
# %E = best ontime
# %F = full date on which best ontime was set
# %G = short date on which best ontime was set
# %H = time best ontime was set at
# %I = server on which best ontime was set
# %J = bot's nickname
# %K = current uptime
# %L = current ontime
# %M = eggdrop version
# %N = operating system

# Best uptime message:
set bt-upmsg "\00304%J\00312 (\00305EggDrop v.%M \00314работает на \00305%N\00312) \00314аптайм: \00307%K \00314, \00314лучший: \00307%A\00312 (\00306%B, %D\00312)\00314."

# Best ontime message:
set bt-onmsg "\00314К \00304%I\00314 подключен \00307%L\00314. Лучший онтайм: \00307%E\00312 (\00306%F, %H\00312)\00312."

#----------------------------------------------------------------------------------
# code begins here..
# please don't edit anything below, unless you know what you're doing.
#----------------------------------------------------------------------------------

if {![info exists inform-otime]} {set inform-otime 0}
if {![info exists inform-utime]} {set inform-utime 0}

#----------------------------------------------------------------------------------
# common procedures

proc lcase {str} {return [string tolower $str]}
proc ucase {str} {return [string toupper $str]}
proc putchan {chan text} {puthelp "PRIVMSG $chan :$text"}
proc strlen {str} {return [string length $str]}
proc strcomp {one two} {if {[expr [strlen $one] + 1] == [expr [strlen $two] + 1]} {if {[string match [ucase $one] [ucase $two]]} {return 1} else {return 0}} else {return 0}}
proc strfind {find str} {if {[string match *$find* $str]} {return 1} else {return 0}}
proc strplc {str find new} {regsub -all -- $find $str $new string ; return $string}

proc bt_fdate {utime} {
  set ntime "[strftime %A $utime],"
  lappend ntime [strftime %d $utime]
  lappend ntime "[strftime %B $utime],"
  lappend ntime [strftime %Y $utime]
  return $ntime
}

proc bt_ndate {utime} {
  set ndate [strftime %m $utime]
  lappend ndate [strftime %d $utime]
  lappend ndate [strftime %Y $utime]
  return [join $ndate /]
}

# - bt_duration is based upon on the original created by Bass

proc bt_dif {now then} {return [expr $now - $then]}
proc bt_duration {now then} {
  set dif [bt_dif $now $then]
  if {$dif < 60} {
    return "$dif\002s\002"
  } elseif {$dif == 60} {
    return "1\002m\002"
  } elseif {$dif >= 31536000} {
    set dif [expr int([expr $dif - [expr 31536000 * [set years [expr $dif / 31536000]]]])]
    if {!$years} {set dur ""} else {set dur "$years\002y\002"}
  }
  if {$dif >= 86400} {
    if {[set days [expr $dif / 86400]] > 0} {
      set dif [expr int([expr $dif - [expr 86400 * $days]])]
      
        lappend dur "$days\002d\002"
      
    }
  }
  if {$dif >= 3600} {
    set dif [expr int([expr $dif - [expr 3600 * [set hours [expr $dif / 3600]]]])]
    if {$hours > 0} {lappend dur "$hours\002h\002"}
  }
  if {$dif >= 60} {
    set dif [expr int([expr $dif - [expr 60 * [set mins [expr $dif / 60]]]])]
    if {$mins > 0} {lappend dur "$mins\002m\002"}
  }
  if {$dif >= 1} {lappend dur "$dif\002s\002"}
  return [join $dur]
}

proc bt_file {bot} {
  global bt-datafile botnet-nick
  set temp [array get bt-datafile]
  set idx 0
  foreach tmp $temp {
    if {[strcomp $tmp ${botnet-nick}]} {return [lindex $temp [expr $idx + 1]]}
    incr idx
  }
  return 0
}

proc bt_write {data} {
  global bt-datafile botnet-nick
  set file [open [bt_file ${botnet-nick}] w]
  puts $file $data
  close $file
}

proc bt_read {} {
  global bt-datafile botnet-nick
  if {![file exists [set file [bt_file ${botnet-nick}]]]} {bt_write "" ; return ""}
  set file [open $file r]
  set data [gets $file]
  close $file
  return $data
}

proc bt_fix {msg} {
  global botnick version uptime server-online
  if {[llength [set data [bt_read]]] < 5} {return 0}
  set best-uptime [lindex $data 0]
  set best-uptime-at [lindex $data 1] 
  set best-ontime [lindex $data 2] 
  set best-ontime-at [lindex $data 3] 
  set best-server [lindex $data 4]
  if {[strfind %A $msg]} {set msg [strplc $msg %A [bt_duration ${best-uptime-at} ${best-uptime}]]}
  if {[strfind %B $msg]} {set msg [strplc $msg %B [bt_fdate ${best-uptime-at}]]}
  if {[strfind %C $msg]} {set msg [strplc $msg %C [bt_ndate ${best-uptime-at}]]}
  if {[strfind %D $msg]} {set msg [strplc $msg %D [lindex [ctime ${best-uptime-at}] 3]]}
  if {[strfind %E $msg]} {set msg [strplc $msg %E [bt_duration ${best-ontime-at} ${best-ontime}]]}
  if {[strfind %F $msg]} {set msg [strplc $msg %F [bt_fdate ${best-ontime-at}]]}
  if {[strfind %G $msg]} {set msg [strplc $msg %G [bt_ndate ${best-ontime-at}]]}
  if {[strfind %H $msg]} {set msg [strplc $msg %H [lindex [ctime ${best-ontime-at}] 3]]}
  if {[strfind %I $msg]} {set msg [strplc $msg %I ${best-server}]}
  if {[strfind %J $msg]} {set msg [strplc $msg %J $botnick]}
  if {[strfind %K $msg]} {set msg [strplc $msg %K [bt_duration [unixtime] $uptime]]}
  if {[strfind %L $msg]} {set msg [strplc $msg %L [bt_duration [unixtime] ${server-online}]]}
  if {[strfind %M $msg]} {set msg [strplc $msg %M [lindex $version 0]]}
  if {[strfind %N $msg]} {set msg [strplc $msg %N [unames]]}
  if {[strfind %! $msg]} {set msg [strplc $msg %! "\002"]}
  if {[strfind %_ $msg]} {set msg [strplc $msg %_ "\037"]}
  return $msg
}

#----------------------------------------------------------------------------------
# actual functionality

proc bt_timer {} {
  global bt-interval
  if {[strfind bt_update [timers]]} {foreach timr [timers] {if {[strfind bt_update $timr]} {killtimer [lindex $timr 2]}}}
  timer ${bt-interval} bt_update
}

proc bt_announce {which oldut oldbt} {
  global inform-utime inform-otime bt-announce
  if {!${bt-announce}} {return 0}
  if {$which == "u" && !${inform-utime}} {
    putlog "I just broke my best-uptime of [bt_duration $oldut $oldbt]."
    set inform-utime 1
  } elseif {$which == "o" && !${inform-otime}} {
    putlog "I just broke my best-ontime of [bt_duration $oldut $oldbt]."
    set inform-otime 1
  }
}

proc bt_update {} {
  global uptime server server-online bt-log
  set data [bt_read]
  set newdata ""
  if {[llength $data] < 5} {
    bt_write [join "$uptime [unixtime] ${server-online} [unixtime] [lindex [split $server :] 0]"]
    if {${bt-log}} {putlog "I just created my bt-datafile."}
  } else {
    set best-uptime [lindex $data 0] ; set best-uptime-at [lindex $data 1] ; set best-ontime [lindex $data 2] ; set best-ontime-at [lindex $data 3] ; set best-server [lindex $data 4] ; set updifnow [bt_dif [unixtime] $uptime] ; set ondifnow [bt_dif [unixtime] ${server-online}] ; set updifthen [bt_dif ${best-uptime-at} ${best-uptime}] ; set ondifthen [bt_dif ${best-ontime-at} ${best-ontime}]
    if {[expr $updifnow + 1] > [expr $updifthen + 1]} {
      lappend newdata $uptime
      lappend newdata [unixtime]
      bt_announce u ${best-uptime-at} ${best-uptime}
    } else {
      lappend newdata ${best-uptime}
      lappend newdata ${best-uptime-at}
    }
    if {![strlen $server] || !${server-online}} {
      lappend newdata ${best-ontime}
      lappend newdata ${best-ontime-at}
      lappend newdata ${best-server}
    } else {
      if {[expr $ondifnow + 1] > [expr $ondifthen + 1]} {
        lappend newdata ${server-online}
        lappend newdata [unixtime]
        lappend newdata [lindex [split $server :] 0]
        bt_announce o ${best-ontime-at} ${best-ontime}
      } else {
        lappend newdata ${best-ontime}
        lappend newdata ${best-ontime-at}
        lappend newdata ${best-server}
      }
    }
    bt_write [join $newdata]
    if {${bt-log}} {putlog "I just updated my bt-datafile."}
  }
  bt_timer
}

proc bt_besttimes {nick uhost hand chan arg} {
  global bt-upmsg bt-onmsg
  putcmdlog "#$hand# besttimes $arg"
  set data [bt_read]
  if {[llength $data] < 5} {putserv "PRIVMSG $chan :\00314No data has been collected yet.\003" ; return 0}
    set umsg [bt_fix ${bt-upmsg}]
    set omsg [bt_fix ${bt-onmsg}]

    putchan $chan [bt_rus $umsg]
    putchan $chan [bt_rus $omsg]

  return 0
}

bind pub o|o !uptime bt_besttimes

if {${bt-announce}} {
  proc bt_reset {} {global inform-otime ; set inform-otime 0}
  set init-server ${init-server}\n"bt_reset"
} else {
  if {[strfind bt_reset ${init-server}]} {set init-server [join [strplc ${init-server} bt_reset ""]]}
}

proc bt_rus {data} {
# Заменяем английские названия дней недели на русские.
regsub -all -- {Monday} $data {Понедельник} data
regsub -all -- {Tuesday} $data {Вторник} data
regsub -all -- {Wednesday} $data {Среда} data
regsub -all -- {Thursday} $data {Четверг} data
regsub -all -- {Friday} $data {Пятница} data
regsub -all -- {Saturday} $data {Суббота} data
regsub -all -- {Sunday} $data {Воскресенье} data

# Заменяем английские месяцы на русские.
regsub -all -- {January} $data {Января} data
regsub -all -- {February} $data {Февраля} data
regsub -all -- {March} $data {Марта} data
regsub -all -- {April} $data {Апреля} data
regsub -all -- {May} $data {Мая} data
regsub -all -- {June} $data {Июня} data
regsub -all -- {July} $data {Июля} data
regsub -all -- {August} $data {Августа} data
regsub -all -- {September} $data {Сентября} data
regsub -all -- {October} $data {Октября} data
regsub -all -- {November} $data {Ноября} data
regsub -all -- {December} $data {Декабря} data
return $data
}

putlog "best.times \0021.4.3\002 :Loaded."

bt_timer

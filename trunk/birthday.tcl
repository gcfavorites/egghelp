####################################################################################################
#
#                              <<< ::: [ StarCom2k.zelek.ru ] ::: >>>
#      ______           _____           ___  __       _____                           _ __      
#     / __/ /____ _____/ ___/__  __ _  |_  |/ /__    / ___/__  __ _  __ _  __ _____  (_) /___ __
#    _\ \/ __/ _ `/ __/ /__/ _ \/  ' \/ __//  '_/   / /__/ _ \/  ' \/  ' \/ // / _ \/ / __/ // /
#   /___/\__/\_,_/_/  \___/\___/_/_/_/____/_/\_\    \___/\___/_/_/_/_/_/_/\_,_/_//_/_/\__/\_, / 
#                                                                                        /___/  
# 
#################################################################################################### 
# 
# Birthday.tcl v1.6
#
# Original author: BoBaH <vovan@enforce.ru>
# Author: Kreon <starcom2k@gmail.com>
# Download: http://irc.case.net.ru
#
#####################################################################################################


# Файл базы
set birthday(base) "scripts/birthday.txt"
# Цвет 1
set birthday(color1) "4"
# Цвет 2
set birthday(color2) "12"
# Число символов на одной строке
set birthday(maxlen) "400"

# Запрет вывода на канале (.chanset #канал +nobirthday (в dcc бота!))
setudef flag nobirthday

# Бинды
bind pub n !birthday pub:birthday
bind pub n !др pub:birthday
bind msg n !birthday msg:birthday
bind msg n !др msg:birthday
bind join - * join:birthday

# Дальше ничего не трогайте, если не знаете что делаете!

if {![file exists $birthday(base)]} {
     set birthday(db) ""
} else {
     set fileio [open $birthday(base) r]
     set lines ""
     while {![eof $fileio]} {
         set line [string range [set t [gets $fileio]] 0 [expr [string length $t] - 4]]
         if {$line != ""} { set lines [linsert $lines end $line] }
     }
     close $fileio
     set birthday(db) $lines
 }

proc str {number} { switch -glob -- "$number" { *11 {return 3} *12 {return 3} *13 {return 3} *14 {return 3} *1 {return 1} *2 {return 2} *3 {return 2} *4 {return 2} default {return 3} } }

proc pub:birthday {nick uhost hand chan text} {
global lastbind
   if {[channel get $chan nobirthday]} {return 0}
   if {([lindex $text 0]=="") || ([lindex $text 0]=="help")} {
       birthday:help $nick "notice" $lastbind
   }
   if {[lindex $text 0]=="add"} {
   	if {[llength $text] < 5} { birthday:syntax $nick "notice"; return }
       birthday:add $nick "notice" [lindex $text 1] [lindex $text 2] [lindex $text 3] [lrange $text 4 end]
   }
   if {[lindex $text 0]=="list"} {
       birthday:list $nick "notice"
   }
   if {[lindex $text 0]=="del"} {
       birthday:del $nick "notice" [lindex $text 1]
   }
}

proc msg:birthday {nick uhost hand text} {
global lastbind
   if {([lindex $text 0]=="") || ([lindex $text 0]=="help")} {
       birthday:help $nick "privmsg" $lastbind; return
   }
   if {[lindex $text 0]=="add"} {
   	if {[llength $text] < 5} { birthday:syntax $nick "privmsg"; return }
       birthday:add $nick "privmsg" [lindex $text 1] [lindex $text 2] [lindex $text 3] [lrange $text 4 end]
   }
   if {[lindex $text 0]=="list"} {
       birthday:list $nick "privmsg"
   }
   if {[lindex $text 0]=="del"} {
       birthday:del $nick "privmsg" [lindex $text 1]
   }
}

proc birthday:syntax {nick type} {
   putserv "$type $nick :Синтаксис: \002!др\002 add 'число' 'месяц' 'год' 'ник'"
}

proc birthday:help {nick type bind} {
global birthday
   putserv "$type $nick :\003$birthday(color1)Помощь по birthday.tcl:\003"
   putserv "$type $nick :\003$birthday(color2)${bind} add <число (01-31)> <месяц (01-12)> <год (2005)/no> <имя>\003 \003$birthday(color1)(добавление в базу)\003"
   putserv "$type $nick :\003$birthday(color2)${bind} list\003 \003$birthday(color1)(просмотр базы)\003"
   putserv "$type $nick :\003$birthday(color2)${bind} del <номер>\003 \003$birthday(color1)(удаление из базы)\003"
}

proc birthday:add {nick type day month year birthman} {
global birthday

regexp {0(\d{1})} $day garb day
regexp {0(\d{1})} $month garb month
if {![string is integer $day] || ![string is integer $month] || ![string is integer $year]} { putserv "$type $nick :\003$birthday(color1)День, месяц и год должны быть выражены в числах"; return }
if {$day<1 || $day>31 || $month<1 || $month>12 || ![regexp {\d{4}} $year] || [string length $year] != 4} { putserv "$type $nick :\003$birthday(color1)День, месяц либо год не совпадают с временными рамками"; return }
if {[string length $day] == 1} {set day "0$day"}
if {[string length $month] == 1} {set month "0$month"}
lappend birthday(db) "$day $month $year $birthman"
putserv "$type $nick :\003$birthday(color1)$birthman - $day $month $year - \003$birthday(color2)занесён в базу!"
writedata $birthday(db)
}

proc birthday:list {nick type} {
global birthday
   set i 0
   if {[llength $birthday(db)] == 0} {putserv "$type $nick :\003$birthday(color1)База данных пуста\003"; return}
   putserv "$type $nick :\003$birthday(color1)База данных:\003"
   foreach line $birthday(db) {
       incr i
       lappend out "\003$birthday(color1)(${i})\003 \003$birthday(color2)${line}\003"
   }
   out $nick $type [join $out ", "]
}

proc birthday:del {nick type number} {
global birthday
if {[llength $birthday(db)] < $number} {putserv "$type $nick :\003$birthday(color1)Запись с номером \002${number}\002 не существует!\003"; return}
putserv "$type $nick :\003$birthday(color1)Удалена запись с номером \002${number}\002 - [lindex $birthday(db) [set number [expr $number -1]]]"
set birthday(db) [lreplace $birthday(db) $number $number]
writedata $birthday(db)
}

proc writedata {data} {
	global birthday
    set fileio [open $birthday(base) w]
    foreach line $data {
         puts $fileio "$line fs"
    }
    flush $fileio
    close $fileio
}

proc out {nick type text} {
 global birthday
  set cmd "$type $nick :"
 while {[string length $text] > 0} {
  if {[string length $text] <= $birthday(maxlen) || [llength [split $text]] == 1} {putserv "$cmd$text"; break}
  set msg ""
  set newtext ""
  set str "0"
  set txt [split $text " "]
 foreach word $txt {
   if {[expr [string length $msg] + [string length $word]] <= $birthday(maxlen)} { 
   if {$str != "1"} {
    set msg [concat $msg $word]
  } else {set newtext [concat $newtext $word]}
  } else { 
   set str "1"
   set newtext [concat $newtext $word]
  }
  }
 if {$msg != ""} { putserv "$cmd[join $msg]" }
  set text $newtext
 }
}  


proc join:birthday {nick uhost hand chan} {
global birthday
	if {[channel get $chan nobirthday]} {return 0}
	array set bday ""
	set utime [ctime [unixtime]]
	set year [lindex $utime 4]
	foreach line $birthday(db) {
       if {[clock format [unixtime] -format "%d %m"] == [lrange $line 0 1]} {
           if {[lindex $line 2]!="no"} {set vozr " ([set t [expr $year - [lindex $line 2]]] [lindex {. год года лет} [str $t]])"} else {set vozr ""}
           lappend bday(today) "[lrange $line 3 end]$vozr"
			} elseif {[clock format [clock scan tomorrow] -format "%d %m"] == [lrange $line 0 1]} {
						if {[lindex $line 2]!="no"} {set vozr " ([set t [expr $year - [lindex $line 2]]] [lindex {. год года лет} [str $t]])"} else {set vozr ""}
						lappend bday(tomorrow) "[lrange $line 3 end]$vozr"
			} elseif {[clock format [clock scan "2 days"] -format "%d %m"] == [lrange $line 0 1]} {
						if {[lindex $line 2]!="no"} {set vozr " ([set t [expr $year - [lindex $line 2]]] [lindex {. год года лет} [str $t]])"} else {set vozr ""}
						lappend bday(ttomorrow) "[lrange $line 3 end]$vozr"
			} elseif {[clock format [clock scan yesterday] -format "%d %m"] == [lrange $line 0 1]} {
						if {[lindex $line 2]!="no"} {set vozr " ([set t [expr $year - [lindex $line 2]]] [lindex {. год года лет} [str $t]])"} else {set vozr ""}
						lappend bday(prev) "[lrange $line 3 end]$vozr"
			}
   }
   if {[info exists bday(today)]} { putserv "notice $nick :\003$birthday(color1)Сегодня от всей души поздравляем с Днём Рождения \003$birthday(color2)[join $bday(today) ", "]" }
   set out ""
   if {[info exists bday(tomorrow)]} { append out "\003$birthday(color1)Завтра день рождения у \003$birthday(color2)[join $bday(tomorrow) ", "]" }
   if {[info exists bday(ttomorrow)]} { if {$out == ""} { append out "\003$birthday(color1)Послезавтра день рождения у " } else { append out "\003$birthday(color1), послезавтра - " }
   	append out "\003$birthday(color2)[join $bday(ttomorrow) ", "]" }
   if {[info exists bday(prev)]} { if {$out == ""} { append out "\003$birthday(color1)Вчера был день рождения у " } else { append out "\003$birthday(color1), а вчера день рождения был у " }
   	append out "\003$birthday(color2)[join $bday(prev) ", "]" }
   out $nick "notice" $out
  }

putlog "Birthday.tcl v1.6 loaded"
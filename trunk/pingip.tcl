#####################################################################################
# Версия 2.0 by Vertigo@RusNet
# pingip.tcl - скрипт, позволяющий пинговать IP или хосты.
#
# Установка:
# 1. Скопировать скрипт в папку scripts
# 2. Прописать в конфигурационный файл бота строку source scripts/pingip.tcl
# 3. Указать верный путь к исполняемому файлу ping на шелле. (Узнать можно, набрав 'whereis ping' в последнем)
# 4. Сделать боту .rehash
# 5. Включить скрипт на канале командой .chanset #канал +pip
#
# ------------------------------------------------------------------------------
#
# Использование: 
# !pingip <IP/host> <count>
# где IP/host - IP-адрес или хост, count - число отправляемых пакетов.
#
#####################################################################################

namespace eval pingip {}
bind pub - !pingip pingip::pub_ping
bind pub - !пингип pingip::pub_ping
bind pub - !зштпшз pingip::pub_ping
bind pub - !gbyubg pingip::pub_ping
bind pub - !pip pingip::pub_ping
bind pub - !пип pingip::pub_ping
bind pub - !зшз pingip::pub_ping
bind pub - !gbg pingip::pub_ping

setudef flag pip
# Защита от повторного использования команды. Иначе раз в сколько секунд разрешить использование команды.
set pingip::check(delay) "45"
# ВАЖНО !!! Указать верный путь к ping на шелле  !!! (Узнать можно, набрав 'whereis ping')
set pingip::pingexecute "/sbin/ping"


proc pingip::pub_ping {nick uhost hand channel text} {
global botnick pingip

if {![channel get $channel pip]} {return}
if {[info exists pingip::check(lasttime,$uhost)] && [expr $pingip::check(lasttime,$uhost) + $pingip::check(delay)] > [clock seconds]} {
     putserv "NOTICE $nick :Команда !pingip станет для Вас доступна через [pingip::duration [expr $pingip::check(delay) - [expr [clock seconds] - $pingip::check(lasttime,$uhost)]]]."
     return
}
regsub -all -- {[\[\]\{\}\$\^\&\*\(\)\@\#\~\`\"\?\\\;\'\|]} $text "" text
if {$text == ""} { putserv "privmsg $channel :$nick: Синтаксис: \00305!pingip \<IP/Host\> \<count\>\003"; return 0 }
if {[validchan $channel]} {
if {[onchan $text $channel]} {
set nik $text	
set text [lindex [split [getchanhost $text $channel] "@"] 1]
} else {
set nik 0	
set text $text
}
} else {
set nik 0	
set text $text
}	
set err2_ ""
if {([string match "192.168.?*" $text] && [isnumber [regsub -all -- {\.} $text ""]]) || ([string match "127.?*" $text] && [isnumber [regsub -all -- {\.} $text ""]]) || ([string match "224.?*" $text] && [isnumber [regsub -all -- {\.} $text ""]]) || ([string match "10.?*" $text] && [isnumber [regsub -all -- {\.} $text ""]]) || ([string match "*localhost*" $text])} { putserv "privmsg $channel :$nick: Локальные адреса пинговать нельзя."; return 0 }
set address [lindex [join $text] 0]
set count_ [lindex [join $text] 1]
if {$count_ ne "" && [isnumber $count_] && [expr $count_ <= 10]} {set count $count_} else {set count "4"}
if {[catch {exec $pingip::pingexecute -c $count $address } ping]} { set err_ $ping; set ping 0 } 
if {[info exists err_] && [string match "*100% packet*child process exited abnormally" $err_]} {
set err2_ "\00310 Дополнительно:\00303 $count\00310 [lindex {. {пакет отправлен} {пакета отправлено} {пакетов отправлено}} [numgrp111 $count]]\00303 0\00310 пакетов принято.\00304 100% \00310потерь."
if {[channel get $channel usecolors]} {putquick "PRIVMSG $channel :\00310Среднее время ответа от\00303 [lindex $text 0]\00310:\00304\002\002 N/A\00310.$err2_\003"} {putquick "PRIVMSG $channel :Среднее время ответа от [lindex $text 0]: N/A.[stripcodes c $err2_]"}
return}
if {[lindex $ping 0] == "0"} { putquick "PRIVMSG $channel :$nick: При обработке запроса \"\002[lindex $text 0]\002\" произошла ошибка: [regsub -all -- {ping\: | child process exited abnormally} [join [split $err_]] ""]."; return 0 }
if {[lindex $ping 0] != "0"} {
set pingip::check(lasttime,$uhost) [clock seconds]
set msgp ""
set p1 ""
set p2 ""
set ping1 [regsub -all \n $ping ""]
regexp -all -nocase -- {(\d+)\ packets\ received\,\ (.*?)%\ packet\ loss.*dev \=(.*?)\ ms} $ping1 -> p1 p2 p3
if {$p1 ne "" && $p2 ne ""} {append msgp "\00310 Дополнительно:\00303 $count\00310 [lindex {. {пакет отправлен} {пакета отправлено} {пакетов отправлено}} [numgrp111 $count]],\00303 $p1\00310 [lindex {. {пакет принят} {пакета принято} {пакетов принято}} [numgrp111 $p1]].\00304 $p2% \00310потерь."}
set ping [format "%.4f" [expr [lindex [split $p3 /] 1] / 100]]

if {[channel get $channel usecolors]} {putquick "PRIVMSG $channel :\00310Среднее время ответа от\00303 [lindex $text 0]\00310:\00304\002\002 $ping\00310 сек.$msgp\003"} {putquick "PRIVMSG $channel :Среднее время ответа от [lindex $text 0]: $ping сек.[stripcodes c $msgp]"}
return 0
 }
}

proc pingip::duration {seconds} {
global pingip
	set years [expr {$seconds / 31449600}]
	set seconds [expr {$seconds % 31449600}]
	set weeks [expr {$seconds / 604800}]
	set seconds [expr {$seconds % 604800}]
	set days [expr {$seconds / 86400}]
	set seconds [expr {$seconds % 86400}]
	set hours [expr {$seconds / 3600}]
	set seconds [expr {$seconds % 3600}]
	set minutes [expr {$seconds / 60}]
	set seconds [expr {$seconds % 60}]
	set res ""
	if {$years != 0} {lappend res [pingip::numgrp $years "лет" "год" "года"]}
	if {$weeks != 0} {lappend res [pingip::numgrp $weeks "недель" "неделю" "недели"]}
	if {$days != 0} {lappend res [pingip::numgrp $days "дней" "день" "дня"]}
	if {$hours != 0} {lappend res [pingip::numgrp $hours "часов" "час" "часа"]}
	if {$minutes != 0} {lappend res [pingip::numgrp $minutes "минут" "минуту" "минуты"]}
	if {$seconds != 0} {lappend res [pingip::numgrp $seconds "секунд" "секунду" "секунды"]}
	return [join $res ", "]
}

proc pingip::isnumber {string} {
  if {([string compare "" $string]) && \
      (![regexp \[^0-9\] $string])} then {
    return 1
  }
  return 0
}

proc pingip::numgrp {val str1 str2 str3} {
global dv
	set d1 [expr $val % 10]
	set d2 [expr $val % 100]
	if {$d2 < 10 || $d2 > 19} {
		if {$d1 == 1} {return "$val $str2"}
		if {$d1 >= 2 && $d1 <= 4} {return "$val $str3"}
	}
	return "$val $str1"
}

proc pingip::numgrp111 {number} { switch -glob -- "$number" { *11 {return 3} *12 {return 3} *13 {return 3} *14 {return 3} *1 {return 1} *2 {return 2} *3 {return 2} *4 {return 2} default {return 3} } }


putlog "ping IP/host v2.0 made by Vertigo@RusNet successfully loaded."

#############################################################################
# ___  __.                                             __                   #
#|   |/ _|______   ____  ____   ____      ____   _____/  |_  _______ __ __  #
#|     < \_  __ \_/ __ \/  _ \ /    \    /    \_/ __ \   __\ \_  __ \  |  \ #
#|   |  \ |  | \/\  ___(  <_> )   |  \  |   |  \  ___/|  |    |  | \/  |  / #
#|___|__ \|__|    \___  >____/|___|  / /\___|  /\___  >__|   /\__|  |____/  #
#       \/            \/           \/  \/    \/     \/       \/             #
#                              D i g i t a l   S i d e   o f   L i f e      #
#############################################################################
#
# bash.org.ru v (x)0.2
#
# Описание:
#    Скрипт для отображения цитат с bash.org.ru, команды:
#      !bash - выбор произвольной цитаты
#      !bash <номер> - просмотр цитаты с заданным номером
#      !bash <слова> - поиск номеров цитат с заданными словами
#    Предполагается корректная работа с использованием патча Suzi.
#	Настройки втыкаем ниже.
#
# Автор: Kreon
#
# Поддержка: http://kreon.net.ru
# 
##############################################################################

if {![info exists egglib(ver)]} {
	putlog "************************************************"
	putlog "             egglib_pub NOT FOUND !"
	putlog "   Download last version of egglib_pub here:"
	putlog "  http://eggdrop.org.ru/scripts/egglib_pub.zip"
	putlog "************************************************"	
	return
}

if {[expr {$egglib(ver) < 1.4}]} {
	putlog "************************************************"
	putlog "    YOUR VERSION OF egglib_pub IS TOO OLD !"
	putlog "   Download last version of egglib_pub here:"
	putlog "  http://eggdrop.org.ru/scripts/egglib_pub.zip"
	putlog "************************************************"
	putlog " version installed: $egglib(ver)"
	putlog " version required: 1.4"
	return
}

# binds
bind pub - !bash	::bor::pub_bor
bind pub - !баш	::bor::pub_bor
bind msg - !bash	::bor::msg_bor
bind msg - !баш	::bor::msg_bor

# flag to allow using on channel (by command)
setudef flag pubbor

namespace eval bor {
	array unset bor
	
	# autopublishing quotes in pub
	# format "#chan seconds"
	# empty the list to not autopublish quotes
	set bor(achans) {
		"#zxcv 20"
		"#test2 90"
	}
	
	# debug
	set bor(debug) 0
	
	# delay between quotes in seconds for each channel
	set bor(delay) 30

	# max quotes in search
	set bor(scount) 15
	
	# max lines in quote for pub
	set bor(lcount) 10
	
	# min ratio for quote to appear in random requests (CAREFULLY!)
	set bor(minratio) -1

	# are we using proxy? [1/0]
	set bor(use_proxy) 	0
	set bor(proxy_host) "10.0.0.29"
	set bor(proxy_port) 32537
	
	# design
	# prefix before num
	set bor(dispre) "<--- "
	# postfix after num
	set bor(dispost) " --->"
	# formatting for quote (i.e., colour, reversed, ...)
	set bor(disform) ""
	# line after the quote (can be blank)
	set bor(disaline) "---"

	# misc
	set bor(timeout) 20
	set bor(regexp) "<div>(.*?)</div>(.*</html>)"
	set bor(nlregexp) "<br>|<br />|</div>|</html>"
	set bor(nuregexp) "\[0-9\]+\">(\[0-9\]+)</a>(.*)"
	set bor(qrregexp) "/quote/\[0-9\]+/rulez\" onclick=\".*?\">\\+</a> <span id=\".*?\">(.*?)</span> \<a href=(.*)"
	set bor(numuri) "http://bash.org.ru/quote/"
	set bor(ranuri) "http://bash.org.ru/random/index.php"
	set bor(seruri) "http://bash.org.ru/search?text="
	set bor(ver) 	"(x)0.2"
	set bor(authors)	"Kreon"

}

#################################################

proc ::bor::pub_bor {nick uhost hand chan args} {
	variable bor
	if {![channel get $chan pubbor]} {return}
  if {[info exists bor(lastqtime,$chan)] && [expr $bor(lastqtime,$chan) + $bor(delay)] > [clock seconds]} {
  	out $nick $chan "Команда на этом канале была запрошена [expr [clock seconds] - $bor(lastqtime,$chan)] [lindex {. секунду секунды секунд} [numgrp [expr [clock seconds] - $bor(lastqtime,$chan)]]] назад; лимит между запросами $bor(delay) [lindex {. секунду секунды секунд} [numgrp $bor(delay)]]"
  	if {$bor(debug)} {
  		putlog "bash_decide: лимит времени"
  	}
  	return
  }
	regsub -all -nocase -- {[\\\{\}\[\]]} [string trim [join $args]] "" args
	::bor::decide $nick $uhost $hand $chan [string trim $args]
}

proc ::bor::msg_bor {nick uhost hand args} {
	regsub -all -nocase -- {[\\\{\}\[\]]} [string trim [join $args]] "" args
	::bor::decide $nick $uhost $hand $nick [string trim $args]
}

#################################################

proc ::bor::numgrp {number} { switch -glob -- "$number" { *11 {return 3} *12 {return 3} *13 {return 3} *14 {return 3} *1 {return 1} *2 {return 2} *3 {return 2} *4 {return 2} default {return 3} } }

#################################################

proc ::bor::out {nick chan text} {
	if {$nick == $chan} {putout "PRIVMSG" $nick $text
	} else {putout "PRIVMSG" $chan $text}
}
proc ::bor::putout {cmd dest msg} { global botnick
	set maxlen [expr 510 - [string length "$botnick![getchanhost $botnick] $cmd $dest :"]]
	while {$msg != ""} {
		set text [expr {[string length $msg] > $maxlen ? [string range $msg 0 [string last \x20 [string range $msg 0 $maxlen]]] : $msg}]
		putserv "$cmd $dest :$text"
		set msg [string trim [string range $msg [string length $text] end]]
	}
}

#################################################

proc ::bor::decide {nick uhost hand chan text} {
  variable bor
  if {$bor(debug)} {
		putlog "bash_decide $nick $chan $text"
	}
	if {[llength $text] > 0} {
		if {[isnumber $text]} {
			number $nick $uhost $hand $chan $text
		} else {
			search $nick $uhost $hand $chan $text
		}
	} else {
		random $nick $uhost $hand $chan $text
	}
}
proc ::bor::output {nick chan num ratio data {arg 0}} {
	variable bor
  if {$bor(debug)} {
		putlog "bash_output $nick $chan $data"
	}
	regsub -all -- {\ +} $data { } data
	regsub -all -- {> +<} $data {><} data
	regsub -all "(\r)|(\n)" "$data " "" data
	regsub -all $bor(nlregexp) $data "\n" data
	set data [string map {&gt; > &lt; < &quot; \' &nbsp; { } amp; {}} $data]
	regsub -all -- {\n$} $data "" data
	
	if {[llength [split $data "\n"]] > $bor(lcount) && $arg} {set chan $nick} 
	if {$nick != $chan} {
		set bor(lastqtime,$chan) [clock seconds]
	}
	if {[isnumber $ratio]} {set ratio "[expr {$ratio > 0 ? "+" : ""}]$ratio"}
	set line "$bor(dispre)$num$bor(dispost)"
	if {$ratio} {append line " ($ratio)"}
	out $nick $chan $line
	regsub -all -- "  " $data " " data
	foreach line [split $data "\n"] {
		if {$line != "" && $line != " "} {out $nick $chan "$bor(disform)$line"}
	}
	if {$bor(disaline) ne ""} {out $nick $chan $bor(disaline)}
}
proc ::bor::random {nick uhost hand chan text {u 0}} {
	variable bor; global bor_cache
	if {![info exists bor_cache] || ![llength $bor_cache]} {
		putlog "bash_cache is empty - refilling ..."
    getrandom [list $nick $chan] 1 $u
    return
	}
	output $nick $chan [lindex [lindex $bor_cache 0] 0] [lindex [lindex $bor_cache 0] 1] [lindex [lindex $bor_cache 0] 2]
	set bor_cache [lreplace $bor_cache 0 0]
	if {![llength $bor_cache]} {getrandom}
}
proc ::bor::getrandom {{target ""} {output 0} {u 0}} {
	variable bor
	set id [::egglib::http_init "::bor::getrandom_"]
	if {$bor(use_proxy)} {::egglib::http_set_proxy $id $bor(proxy_host) $bor(proxy_port)}
  if {$bor(debug)} {
		putlog "bash_get_random -- $target $output"
	}
	::egglib::http_set_timeout $id $bor(timeout)
	::egglib::http_get $id $bor(ranuri) [list $target $output $u]
}
proc ::bor::getrandom_on_data {id html target output u} {
	variable bor; global sp_version; global bor_cache
	if {[info exists sp_version]} {set html [encoding convertfrom cp1251 $html]}
	for {set i 0} {$i < 100 && [regexp $bor(regexp) $html tmp data rest]} {incr i} {
		if {[string match "*bash.org.ru/b/ad*" $data] || [string match "*lol.bash.org.ru*" $data] || [regexp {<a href=.*?>.*?</a>} $data] || [regexp {<iframe src=.*?></iframe>} $data]} {set html $rest; continue}
		if {![regexp $bor(nuregexp) $html tmp num]} {set num -1}
		if {![regexp $bor(qrregexp) $html tmp num1]} {set num1 0}
		if {$num1 < $bor(minratio)} {set html $rest; if {$bor(debug)} {putlog "skipped -- low ratio ($num1)"}; continue}
		if {[regexp "(.*$bor(nlregexp).*){$bor(lcount)}" $data]} {set html $rest; if {$bor(debug)} {putlog "skipped: too long"}; continue}
		if {$output} {
			output [lindex $target 0] [lindex $target 1] $num $num1 $data
			set output 0
			set html $rest
			continue
		}
		lappend bor_cache [list $num $num1 $data]
		set html $rest
	}
	if {!$u && $output && ![llength $bor_cache]} {out [lindex $target 0] [lindex $target 1] "Ошибка при обработке данных с сайта."}
}
proc ::bor::number {nick uhost hand chan text} {
	variable bor
	set url "$bor(numuri)$text"
	set id [::egglib::http_init "::bor::number_"]
	if {$bor(use_proxy)} {::egglib::http_set_proxy $id $bor(proxy_host) $bor(proxy_port)}
  if {$bor(debug)} {
		putlog "bash_number $nick $chan -- $text -- $url"
	}
	::egglib::http_set_timeout $id $bor(timeout)
	::egglib::http_get $id $url [list $nick $chan $uhost $text]
}
proc ::bor::number_on_data {id html nick chan uhost text} {
	variable bor; global sp_version
  if {$bor(debug)} {
		putlog "bash_number_on_data $nick $chan"
	}
	if {[info exists sp_version]} {set html [encoding convertfrom cp1251 $html]}

	if {[regexp $bor(regexp) $html tmp data] && ![string match "*http://bash.org.ru/b/ad*" $data]} {
		if {![regexp $bor(qrregexp) $html tmp ratio]} {set ratio 0}
		output $nick $chan $text $ratio $data 1
	} else {
		out $nick $chan "Не найдена цитата с номером $text"
	}
}
proc ::bor::search {nick uhost hand chan text} {
	variable bor; global sp_version
	if {[info exists sp_version]} {
		set url "$bor(seruri)[::egglib::urlencode [encoding convertto cp1251 $text]]"
	} else {
		set url "$bor(seruri)[::egglib::urlencode $text]"
	}
	set id [::egglib::http_init "::bor::search_"]
	if {$bor(use_proxy)} {::egglib::http_set_proxy $id $bor(proxy_host) $bor(proxy_port)}
  if {$bor(debug)} {
		putlog "bash_search $nick $chan -- $text -- $url"
	}
	::egglib::http_set_timeout $id $bor(timeout)
	::egglib::http_get $id $url [list $nick $chan $uhost $text]
}
proc ::bor::search_on_data {id html nick chan uhost text} {
	variable bor; global sp_version
	if {[info exists sp_version]} {set html [encoding convertfrom cp1251 $html]}
	for {set i 0} {$i < $bor(scount) && [regexp $bor(nuregexp) $html tmp data rest]} {incr i} {
		if {[string match "*http://bash.org.ru/b/ad*" $data]} {set html $rest; continue}
		lappend result $data
		set html $rest
	}
	if {[info exists result]} {
		out $nick $chan "Найденные цитаты: [join $result ", "]"
	} else {
		out $nick $chan "Не найдено цитат, совпадающих с запросом \"$text\""
	} 
}
proc ::bor::apub {chan secs} {
	variable bor
  if {$bor(debug)} {
		putlog "bash_autopublish -- executing for channel $chan, next in $secs seconds"
	}
	if {![validchan $chan] || ![botonchan $chan]} {
		if {$bor(debug)} {
			putlog "bash_autopublish -- channel $chan does not exist, or can not join. cancelling"
		}
		return
	}
	::bor::random "" "" "" $chan "" 1
	utimer $secs [list ::bor::apub $chan $secs]
}
	
namespace eval bor {
	foreach t [utimers] {
		if {[string match "::bor::apub*" [lindex $t 1]]} {killutimer [lindex $t 2]}
	}
	foreach {chan secs} [join $bor(achans)] {
		utimer $secs [list ::bor::apub $chan $secs]
	}
	putlog "bash.org.ru.tcl v$bor(ver) by $bor(authors) loaded"
}
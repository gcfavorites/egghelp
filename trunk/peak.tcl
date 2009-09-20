################################################################################
#                                                                              #
#      :::[  T h e   R u s s i a n   E g g d r o p  R e s o u r c e  ]:::      #
#    ____                __                                                    #
#   / __/___ _ ___ _ ___/ /____ ___   ___      ___   ____ ___ _     ____ __ __ #
#  / _/ / _ `// _ `// _  // __// _ \ / _ \    / _ \ / __// _ `/    / __// // / #
# /___/ \_, / \_, / \_,_//_/   \___// .__/ __ \___//_/   \_, / __ /_/   \___/  #
#      /___/ /___/                 /_/    /_/           /___/ /_/              #
#                                                                              #
################################################################################
#                                                                              #
# peak.tcl 1.2                                                                 #
#                                                                              #
# Author: Stream@Rusnet <stream@eggdrop.org.ru>                                #
#                                                                              #
# Official support: irc.eggdrop.org.ru @ #eggdrop                              #
#                                                                              #
################################################################################

namespace eval peak {}

setudef flag nopubpeak
setudef flag announcepeak

#################################################

bind pub - !peak	::peak::pub_peak
bind pub - !пик		::peak::pub_peak
bind msg - !peak	::peak::msg_peak
bind msg - !пик		::peak::msg_peak

bind join - *		::peak::onjoin

#################################################

catch {unset peak}

# show nicks of users (not recommended on large chans)
set peak(nicks)		1
# maximum length of a message
set peak(maxlen)	400
# announce delay to prevent flooding on massjoins (seconds)
set peak(delay)		10
# filename to store peak values
set peak(file)		"peak.data"

#################################################
##### DON'T CHANGE ANYTHING BELOW THIS LINE #####
#################################################

set peak(data)		""

set peak(ver)		"1.2"
set peak(authors)	"Stream@RusNet <stream@eggdrop.org.ru>"

#################################################

proc ::peak::readdata {} {
	global peak
	set peak(data) ""
	if {![catch {set fid [open $peak(file) "r"]}]} {
		while {![eof $fid]} {
			set data [split [string trim [gets $fid]] " "]
			if {[llength $data] > 3} {lappend peak(data) [list [lindex $data 0] [lindex $data 1] [lindex $data 2] [lrange $data 3 end]]}
		}
		close $fid
		putlog "\[peak\] loaded [llength $peak(data)] channel peaks"
	} else {putlog "\[peak\] can't open file '$peak(file)'!"}
}

proc ::peak::writedata {} {
	global peak
	set fid [open "$peak(file)" "w+"]
	foreach data $peak(data) {
		puts $fid "[join [lrange $data 0 2]] [join [lindex $data 3]]"
	}
	close $fid
}

proc ::peak::tolower {text} {
	return [string map {А а Б б В в Г г Д д Е е Ё ё Ж ж З з И и Й й К к Л л М м Н н О о П п Р р С с Т т У у Ф ф Х х Ц ц Ч ч Ш ш Щ щ Ъ ъ Ы ы Ь ь Э э Ю ю Я я} [string tolower $text]]
}

proc ::peak::out {nick chan text} {
	global peak
	if {[validchan $chan]} {set cmd "PRIVMSG $chan :"
	} elseif {$nick == $chan} {set cmd "PRIVMSG $nick :"
	} else {set cmd "NOTICE $nick :"}
	while {[string length $text] > 0} {
		if {[string length $text] <= $peak(maxlen) || [llength [split $text]] == 1} {putserv "$cmd$text"; break}
		set msg ""
		set newtext ""
		foreach word [split $text] {
			if {[expr [string length $msg] + [string length $word]] <= $peak(maxlen)} {lappend msg $word
			} elseif {$msg == "" && [string length $word] > $peak(maxlen)} {lappend msg $word
			} else {lappend newtext $word}
		}
		if {$msg != ""} {putserv "$cmd[join $msg]"}
		set text $newtext
	}
}

proc ::peak::announce {chan text} {
	global botnick
	::peak::out $botnick $chan $text
}

proc ::peak::delayedannounce {chan text} {
	global peak
	foreach tmr [utimers] {
		set cmd [split [join [lindex $tmr 1]] " "]
		if {[string equal [lindex $cmd 0] "::peak::announce"] && [string equal [lindex $cmd 1] $chan]} {
			killutimer [lindex $tmr 2]
		}
	}
	utimer $peak(delay) "::peak::announce $chan \"$text\""
}

proc ::peak::init {} {
	::peak::readdata
}

#################################################

proc ::peak::pub_peak {nick uhost hand chan args} {
	if {[channel get $chan nopubpeak]} {return}
	set pchan [string trim [lindex $args 0]]
	if {[string length $pchan] != 0} {
		if {[string range $pchan 0 0] != "#"} {::peak::out $nick $chan "Используй !peak \[#канал\]"; return}
		if {![validchan $pchan]} {::peak::out $nick $chan "Я не слежу за каналом $pchan"; return}
		::peak::peak $nick $chan $pchan
	} else {::peak::peak $nick $chan $chan}
}

proc ::peak::msg_peak {nick uhost hand args} {
	set pchan [string trim [lindex $args 0]]
	if {[string range $pchan 0 0] != "#"} {::peak::out $nick $nick "Используй !peak <#канал>."; return}
	if {![validchan $pchan]} {::peak::out $nick $nick "Я не слежу за каналом $pchan"; return}
	::peak::peak $nick $nick $pchan
}

#################################################

proc ::peak::peak {nick chan pchan} {
	global peak
	foreach data $peak(data) {
		if {[string equal [::peak::tolower $pchan] [lindex $data 0]]} {
			set str [::peak::numstr [lindex $data 1] "посетителей" "посетитель" "посетителя"]
			::peak::out $nick $chan "Рекорд канала $pchan: $str ([::peak::duration [expr {[unixtime] - [lindex $data 2]}]] назад)"
			if {$peak(nicks) == 1} {::peak::out $nick "" "На канале были: [lindex $data 3]"}
			return
		}
	}
	::peak::out $nick $chan "Рекорд канала $pchan не записан."
}

proc ::peak::onjoin {nick uhost hand chan} {
	global peak
	set res ""
	set oldpeak 0
	set users [chanlist $chan]
	set ucount [llength $users]
	foreach data $peak(data) {
		if {[string equal [::peak::tolower $chan] [lindex $data 0]]} {
			set oldpeak [lindex $data 1]
		} else {
			lappend res $data
		}
	}
	if {$oldpeak < $ucount} {
		lappend res [list [::peak::tolower $chan] $ucount [unixtime] $users]
		if {[channel get $chan announcepeak]} {
			set str [::peak::numstr $ucount "посетителей" "посетитель" "посетителя"]
			::peak::delayedannounce $chan "Новый рекорд канала $chan: $str."
		}
		set peak(data) $res
		::peak::writedata
	}
}

proc ::peak::duration {seconds} {
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
	if {$years != 0} {lappend res [::peak::numstr $years "лет" "год" "года"]}
	if {$weeks != 0} {lappend res [::peak::numstr $weeks "недель" "неделю" "недели"]}
	if {$days != 0} {lappend res [::peak::numstr $days "дней" "день" "дня"]}
	if {$hours != 0} {lappend res [::peak::numstr $hours "часов" "час" "часа"]}
	if {$minutes != 0} {lappend res [::peak::numstr $minutes "минут" "минуту" "минуты"]}
	if {$seconds != 0} {lappend res [::peak::numstr $seconds "секунд" "секунду" "секунды"]}
	return [join $res ", "]
}

proc ::peak::numstr {val str1 str2 str3} {
	set d1 [expr $val % 10]
	set d2 [expr $val % 100]
	if {$d2 < 10 || $d2 > 19} {
		if {$d1 == 1} {return "$val $str2"}
		if {$d1 >= 2 && $d1 <= 4} {return "$val $str3"}
	}
	return "$val $str1"
}

::peak::init
putlog "peak.tcl v$peak(ver) by $peak(authors) loaded"

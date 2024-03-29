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
# quote.tcl 1.1                                                                #
#                                                                              #
# Author: Stream@Rusnet <stream@eggdrop.org.ru>                                #
#                                                                              #
# Official support: irc.eggdrop.org.ru @ #eggdrop                              #
#                                                                              #
################################################################################

namespace eval quote {}

setudef flag nopubquote
setudef flag announcequote

#################################################

bind pub	-	!quote		::quote::pub_quote
bind msg	-	!quote		::quote::msg_quote
bind pub	-	!q		::quote::pub_quote
bind msg	-	!q		::quote::msg_quote
bind pub	-	!addquote	::quote::pub_addquote
bind pub	-	!aq		::quote::pub_addquote
bind pub	o|o	!delquote	::quote::pub_delquote
bind pub	o|o	!dq		::quote::pub_delquote

#################################################

foreach p [array names quote *] {catch {unset quote($p)}}

#################################################

# interval between quote announcements (minutes)
set quote(announcetime)	30
# filename to store quotes
set quote(datafile)	"quote.data"

#################################################
##### DON'T CHANGE ANYTHING BELOW THIS LINE #####
#################################################

set quote(data)		""

set quote(ver)		"1.1"
set quote(authors)	"Stream@RusNet <stream@eggdrop.org.ru>"

#################################################

proc ::quote::readdata {} {
	global quote
	set quote(data) ""
	if {![catch {set fid [open $quote(datafile) "r"]}]} {
		while {![eof $fid]} {
			set data [split [string trim [gets $fid]] "|"]
			if {[llength $data] == 3} {lappend quote(data) $data}
		}
		close $fid
		putlog "\[quote\] loaded [llength $quote(data)] quotes"
	} else {putlog "\[quote\] can't open file '$quote(datafile)'!"}
}

proc ::quote::writedata {} {
	global quote
	set fid [open "$quote(datafile)" "w+"]
	foreach data $quote(data) {
		set sdata [join $data "|"]
		puts $fid "$sdata  "
	}
	close $fid
}

proc ::quote::init {} {
	global quote
	foreach tmr [timers] {if {[lindex $tmr 1] == "::quote::announce"} {killtimer [lindex $tmr 2]}}
	::quote::readdata
	timer $quote(announcetime) ::quote::announce
}

proc ::quote::tolower {text} {
	return [string map {� � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �} [string tolower $text]]
}

proc ::quote::out {nick chan text} {
	global botnick
	if {$nick != $botnick} {
		if {[validchan $chan]} {putserv "PRIVMSG $chan :$nick, $text"
		} elseif {$nick == $chan} {putserv "PRIVMSG $nick :$text"
		} else {putserv "NOTICE $nick :$text"}
	} else {putserv "PRIVMSG $chan :$text"}
}

#################################################

proc ::quote::pub_quote {nick uhost hand chan args} {
	if {![validchan $chan]} {return}
	if {[channel get $chan nopubquote]} {return}
	regsub -all -- {\\} [join $args] "" args
	::quote::quote $nick $uhost $hand $chan $chan [string trim $args]
}

proc ::quote::msg_quote {nick uhost hand args} {
	regsub -all -- {\\} [join $args] "" args
	if {[llength $args] < 1} {
		::quote::out $nick $nick "���������: !quote <#�����> \[�����/������_������\]";
		return;
	}
	set chan [lindex $args 0]
	if {![validchan $chan]} {
		::quote::out $nick $nick "� �� ����� �� ������� '$chan'...";
		return;
	}
	if {[channel get $chan nopubquote]} {
		::quote::out $nick $nick "������ �� ������ '$chan' ���������...";
		return;
	}
	set mask [lrange $args 1 end]
	::quote::quote $nick $uhost $hand $chan $nick [string trim $mask]
}

proc ::quote::pub_addquote {nick uhost hand chan args} {
	if {![validchan $chan]} {return}
	if {[channel get $chan nopubquote]} {return}
	regsub -all -- {\\} [join $args] "" args
	::quote::addquote $nick $uhost $hand $chan [string trim $args]
}

proc ::quote::pub_delquote {nick uhost hand chan args} {
	if {![validchan $chan]} {return}
	if {[channel get $chan nopubquote]} {return}
	regsub -all -- {\\} [join $args] "" args
	::quote::delquote $nick $uhost $hand $chan [string trim $args]
}

#################################################

proc ::quote::total {chan} {
	global quote
	set total 0
	foreach q $quote(data) {
      if {![validchan $chan] || [string match -nocase [lindex $q 0] $chan]} {incr total}}
	return $total
}

proc ::quote::addquote {nick uhost hand chan args} {
	global quote
	set args [join $args]
	if {[string length $args] < 1} {::quote::out $nick $chan "���������: !addquote <������>"; return}
	putlog "\[quote\] addquote $nick/$chan $args"
	set largs [::quote::tolower $args]
	set num 0
	foreach q $quote(data) {
		if {![string match -nocase [lindex $q 0] $chan]} {continue}
		incr num
		if {[string match -nocase [::quote::tolower [lindex $q 2]] $largs]} {
			::quote::out $nick $chan "����� ������ ��� ��������� (����� $num)."
			return
		}
	}
	lappend quote(data) [list $chan $nick $args]
	incr num
	::quote::out $nick $chan "������ ��������� (����� $num)."
	::quote::writedata
}

proc ::quote::delquote {nick uhost hand chan args} {
	global quote
	set args [join $args]
	if {[string length $args] < 1} {::quote::out $nick $chan "���������: !delquote <�����>"; return}
	if {[::quote::total $chan] == 0} {::quote::out $nick $chan "� ���� ��� �� ����� ������..."; return}
	if {![regexp -nocase -- {[0-9]+} $args]} {::quote::out $nick $chan "������������ ����� ������."; return}
	putlog "\[quote\] delquote $nick/$chan $args"
	set num 0
	set res ""
	foreach q $quote(data) {
		if {![string match -nocase [lindex $q 0] $chan]} {lappend res $q; continue}
		incr num
		if {$num != $args} {lappend res $q} else {::quote::out $nick $chan "������� ������ ����� $num."}
	}
	if {[llength $res] < [llength $quote(data)]} {
		set quote(data) $res
		::quote::writedata
	} else {::quote::out $nick $chan "������ ��� ������� $args �� �������."}
}

proc ::quote::randomquote {nick chan dchan} {
	global quote botnick
	set total [::quote::total $chan]
	if {$total == 0} {return}
	set rnum [rand $total]
	set num 0
	set res ""
	foreach q $quote(data) {
		if {[validchan $chan] && ![string match -nocase [lindex $q 0] $chan]} {continue}
		if {$num == $rnum} {set res $q}
		incr num
	}
	if {$res != ""} {
		if {[validchan $chan]} {::quote::out $botnick $dchan "\[[expr {$rnum + 1}]/$num\] [lindex $res 2] \[[lindex $res 1]\]"
		} else {::quote::out $nick $dchan "\[[expr {$rnum + 1}]/$num\] [lindex $res 2] \[[lindex $res 1]\]"}
	} else {putlog "\[quote\] can't get random quote!"}
	
}

proc ::quote::quotebynum {nick chan dchan args} {
	global quote botnick
	set args [join $args]
	set num 0
	set res ""
	foreach q $quote(data) {
		if {[validchan $chan] && ![string match -nocase [lindex $q 0] $chan]} {continue}
		incr num
		if {$num == $args} {set res $q}
	}
	if {$res != ""} {
		if {[validchan $chan]} {::quote::out $botnick $dchan "\[$args/$num\] [lindex $res 2] \[[lindex $res 1]\]"
		} else {::quote::out $nick $dchan "\[$args/$num\] [lindex $res 2] \[[lindex $res 1]\]"}
	} else {::quote::out $nick $dchan "������ ��� ������� $args �� �������."}
}

proc ::quote::quotebycontent {nick chan dchan args} {
	global quote botnick
	set args [join $args]
	set num 0
	set res ""
	set rnum 0
	foreach q $quote(data) {
		if {[validchan $chan] && ![string match -nocase [lindex $q 0] $chan]} {continue}
		incr num
		if {$res == ""} {
			if {[string match "*$args*" "[lindex $q 2] \[[lindex $q 1]\]"]} {
				set res $q
				set rnum $num
			}
		}
	}
	if {$res != ""} {
		if {[validchan $chan]} {::quote::out $botnick $dchan "\[$rnum/$num\] [lindex $res 2] \[[lindex $res 1]\]"
		} else {::quote::out $nick $dchan "\[$rnum/$num\] [lindex $res 2] \[[lindex $res 1]\]"}
	} else {::quote::out $nick $dchan "������ �� �������."}
}

proc ::quote::quote {nick uhost hand chan dchan args} {
	global quote
	if {[::quote::total $chan] == 0} {::quote::out $nick $dchan "� ���� ��� �� ����� ������..."; return}
	set args [join $args]
	putlog "\[quote\] quote $nick/$dchan $chan $args"
	if {[string length $args] == 0} {::quote::randomquote $nick $chan $dchan
	} elseif {[regexp -nocase -- {[0-9]+} $args]} {::quote::quotebynum $nick $chan $dchan $args
	} else {::quote::quotebycontent $nick $chan $dchan $args}
}

proc ::quote::announce {} {
	global quote botnick
	if {[llength $quote(data)] == 0} {return}
	foreach chan [channels] {
		if {[channel get $chan announcequote]} {::quote::randomquote $botnick $chan $chan}
	}
	timer $quote(announcetime) ::quote::announce
}

#################################################

::quote::init
putlog "quote.tcl v$quote(ver) by $quote(authors) loaded"


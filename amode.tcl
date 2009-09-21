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
# amode.tcl 1.1                                                                #
#                                                                              #
# Author: Stream@Rusnet <stream@eggdrop.org.ru>                                #
#                                                                              #
# Official support: irc.eggdrop.org.ru @ #eggdrop                              #
#                                                                              #
################################################################################

namespace eval amode {}

setudef flag automode

#################################################

bind pub m|m !avoiceadd		::amode::pub_avoiceadd
bind pub m|m !avoicedel		::amode::pub_avoicedel
bind pub m|m !avoicelist	::amode::pub_avoicelist
bind pub m|m !aopadd		::amode::pub_aopadd
bind pub m|m !aopdel		::amode::pub_aopdel
bind pub m|m !aoplist		::amode::pub_aoplist

bind join - *			::amode::onjoin
bind nick - *			::amode::onnick
bind mode - *			::amode::onmode

#################################################

foreach p [array names amode *] {catch {unset amode($p)}}

#################################################

# maximum length of a message
set amode(maxlen)		400
# users with such flags don't automatically get +v or +o
set amode(exemptflags)		"E"
# filename to store masks
set amode(datafile)		"amode.data"

#################################################
##### DON'T CHANGE ANYTHING BELOW THIS LINE #####
#################################################

set amode(ver)			"1.1"
set amode(authors)		"Stream@RusNet <stream@eggdrop.org.ru>"

#################################################

proc ::amode::readdata {} {
	global amode
	if {![catch {set fid [open $amode(datafile) "r"]}]} {
		while {![eof $fid]} {
			set data [split [string trim [gets $fid]] " "]
			if {[llength $data] >= 2} {
				if {![info exists amode([lindex $data 0])]} {set amode([lindex $data 0]) [list [lindex $data 1]]
				} else {lappend amode([lindex $data 0]) [lindex $data 1]}
			}
		}
		close $fid
		putlog "\[amode\] loaded [llength [array names amode data,*]] automode masks"
	} else {putlog "\[amode\] can't open file '$amode(datafile)'!"}
}

proc ::amode::writedata {} {
	global amode
	set fid [open "$amode(datafile)" "w+"]
	foreach name [array names amode data,*] {
		foreach data $amode($name) {
			puts $fid "$name $data"
		}
	}
	close $fid
}

proc ::amode::init {} {
	foreach tmr [utimers] {if {[lindex $tmr 1] == "::amode::mode"} {killutimer [lindex $tmr 2]}}
	::amode::readdata
}

proc ::amode::tolower {text} {
	return [string map {� � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �} [string tolower $text]]
}

proc ::amode::out {nick chan text} {
	if {$nick == $chan} {putserv "PRIVMSG $nick :$text"
	} else {putserv "NOTICE $nick :$text"}
}

#################################################

proc ::amode::pub_avoiceadd {nick uhost hand chan args} {
	if {![validchan $chan]} {return}
	if {![channel get $chan automode]} {return}
	::amode::amodeadd $nick $uhost $hand $chan "v" [join $args]
}

proc ::amode::pub_aopadd {nick uhost hand chan args} {
	if {![validchan $chan]} {return}
	if {![channel get $chan automode]} {return}
	::amode::amodeadd $nick $uhost $hand $chan "o" [join $args]
}

proc ::amode::pub_avoicedel {nick uhost hand chan args} {
	if {![validchan $chan]} {return}
	if {![channel get $chan automode]} {return}
	::amode::amodedel $nick $uhost $hand $chan "v" [join $args]
}

proc ::amode::pub_aopdel {nick uhost hand chan args} {
	if {![validchan $chan]} {return}
	if {![channel get $chan automode]} {return}
	::amode::amodedel $nick $uhost $hand $chan "o" [join $args]
}

proc ::amode::pub_avoicelist {nick uhost hand chan args} {
	if {![validchan $chan]} {return}
	if {![channel get $chan automode]} {return}
	::amode::amodelist $nick $uhost $hand $chan "v" [join $args]
}

proc ::amode::pub_aoplist {nick uhost hand chan args} {
	if {![validchan $chan]} {return}
	if {![channel get $chan automode]} {return}
	::amode::amodelist $nick $uhost $hand $chan "o" [join $args]
}

proc ::amode::onjoin {nick uhost hand chan} {
	global amode botnick
	if {![channel get $chan automode]} {return}

	if {![string equal $nick $botnick]} {::amode::check $nick $uhost $hand $chan
	} else {::amode::checkchan $chan}
}

proc ::amode::onnick {nick uhost hand chan newnick} {
	global amode botnick
	if {![channel get $chan automode]} {return}

	if {![string equal $newnick $botnick]} {::amode::check $newnick $uhost $hand $chan}
}

proc ::amode::onmode {nick uhost hand chan mode victim} {
	global amode botnick
	if {![channel get $chan automode]} {return}

	if {[string equal $victim $botnick] && $mode == "+o"} {::amode::checkchan $chan}
}

#################################################

proc ::amode::amodeadd {nick uhost hand chan mode args} {
	global amode lastbind
	set mask [string trim [join $args]]
	if {[string length $mask] < 1} {::amode::out $nick $chan "��������� $lastbind <�����>"; return}
	
	set pos1 [string first "!" $mask]
	set pos2 [string first "@" $mask]
	if {$pos1 != -1} {
		if {$pos2 < $pos1} {set mask "$mask@*"
		} elseif {$pos2 == [string length $mask]} {set mask "$mask*"}
	} elseif {$pos2 != -1} {set mask "*!*$mask"
	} elseif {[string first "." $mask] != -1} {set mask "*!*@$mask"
	} else {set mask "$mask!*@*"}
	
	putlog "\[amode\] $nick/$chan add +$mode $mask"
	if {[info exists amode(data,$chan,$mode)]} {
		foreach data $amode(data,$chan,$mode) {
			if {[string equal $mask $data]} {
				::amode::out $nick $chan "����� '$mask' ��� ������������ � [::amode::strmode $mode] ������ ������ $chan."
				return
			}
		}
		lappend amode(data,$chan,$mode) $mask
	} else {set amode(data,$chan,$mode) [list $mask]}
	foreach user [chanlist $chan] {
		if {[string match $mask "$user![getchanhost $user $chan]"]} {
			::amode::delayedmode $user $chan $mode
		}
	}
	::amode::writedata
	::amode::out $nick $chan "�������� ����� [::amode::strmode $mode] '$mask' �� ������ $chan."
}

proc ::amode::amodedel {nick uhost hand chan mode args} {
	global amode lastbind
	set mask [string trim [join $args]]
	if {[string length $mask] < 1} {::amode::out $nick $chan "��������� $lastbind <�����>"; return}
	
	if {![info exists amode(data,$chan,$mode)]} {
		::amode::out $nick $chan "������ [::amode::strmode $mode]�� �� ������ $chan ����."
		return
	}

	set pos1 [string first "!" $mask]
	set pos2 [string first "@" $mask]
	if {$pos1 != -1} {
		if {$pos2 < $pos1} {set mask "$mask@*"
		} elseif {$pos2 == [string length $mask]} {set mask "$mask*"}
	} elseif {$pos2 != -1} {set mask "*!*$mask"
	} elseif {[string first "." $mask] != -1} {set mask "*!*@$mask"
	} else {set mask "$mask!*@*"}
	
	set res ""
	foreach data $amode(data,$chan,$mode) {
		if {![string equal $mask $data]} {lappend res $data}
	}
	if {[llength $res] < [llength $amode(data,$chan,$mode)]} {
		putlog "\[amode\] $nick/$chan del +$mode $mask"
		::amode::out $nick $chan "������� [::amode::strmode $mode] ����� '$mask' �� ������ $chan."
		set amode(data,$chan,$mode) $res
		::amode::writedata
	} else {::amode::out $nick $chan "����� '$mask' ����������� � [::amode::strmode $mode] ������ ������ $chan."}
}

proc ::amode::amodelist {nick uhost hand chan mode args} {
	global amode lastbind
	set mask [string trim [join $args]]
	if {[string length $mask] < 1} {set mask "*"}
	
	if {![info exists amode(data,$chan,$mode)]} {
		::amode::out $nick $chan "������ [::amode::strmode $mode]�� �� ������ $chan ����."
		return
	}

	putlog "\[amode\] $nick/$chan list"
	set res ""
	foreach data $amode(data,$chan,$mode) {
		if {[string match $mask $data]} {lappend res $data}
	}
	if {[llength $res] < 1} {::amode::out $nick $chan "��������������� [::amode::strmode $mode] ����� �����������."; return}
	while {[llength $res] > 0} {
		if {[string length [join $res "; "]] <= $amode(maxlen) || [llength $res] == 1} {::amode::out $nick $chan [join $res "; "]; break}
		set msg ""
		set newtext ""
		foreach word $res {
			if {[expr {[string length $msg] + [string length $word] + 2}] <= $amode(maxlen)} {lappend msg $word
			} elseif {$msg == "" && [string length $word] > $amode(maxlen)} {lappend msg $word
			} else {lappend newtext $word}
		}
		if {$msg != ""} {::amode::out $nick $chan [join $msg "; "]}
		set res $newtext
	}
}

proc ::amode::check {nick uhost hand chan} {
	global amode
	#putlog "CHECK: $nick!$uhost $chan"
	if {$hand != "" && $hand != "*" && [validuser $hand]} {
		if {[matchattr $hand "$amode(exemptflags)|$amode(exemptflags)" $chan]} {return}
	}
	foreach name [array names amode data,$chan,*] {
		foreach mask $amode($name) {
			if {[string match $mask "$nick!$uhost"]} {::amode::delayedmode $nick $chan [lindex [split $name ","] 2]}
		}
	}
}

proc ::amode::checkchan {chan} {
	global botnick
	if {![botisop $chan]} {return}
	foreach user [chanlist $chan] {
		if {![string equal $user $botnick]} {
			::amode::check $user [getchanhost $user $chan] [nick2hand $user $chan] $chan
		}
	}
}

proc ::amode::delayedmode {nick chan mode} {
	global amode
	foreach tmr [utimers] {
		set cmd [lindex $tmr 1]
		if {[string equal [lindex $cmd 0] "::amode::mode"] && [string equal [lindex $cmd 1] $chan]} {
			lappend amode(modes,$chan) [list $nick $mode]
			return
		}
	}
	set amode(modes,$chan) [list [list $nick $mode]]
	set delays [split [channel get $chan aop-delay] " "]
	if {[llength $delays] < 1} {set delays [list 5 10]}
	set seconds [expr {[lindex $delays 0] + int(rand()*([lindex $delays 1] - [lindex $delays 0]))}]
	utimer $seconds "::amode::mode $chan"
}

proc ::amode::mode {chan} {
	global amode
	foreach mode $amode(modes,$chan) {
		set nick [lindex $mode 0]
		set mode [lindex $mode 1]
		if {[onchan $nick $chan]} {
			if {[string equal $mode "v"] && ![isvoice $nick $chan]} {pushmode $chan +v $nick
			} elseif {[string equal $mode "o"] && ![isop $nick $chan]} {pushmode $chan +o $nick}
		}
	}
	unset amode(modes,$chan)
}

proc ::amode::strmode {mode} {
	if {[string equal $mode "v"]} {return "��������"
	} elseif {[string equal $mode "o"]} {return "������"
	} elseif {[string equal $mode "*"]} {return "�������"}
	return ""
}

::amode::init
putlog "amode.tcl v$amode(ver) by $amode(authors) loaded"

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
# idle.tcl 1.0                                                                 #
#                                                                              #
# Author: Stream@Rusnet <stream@eggdrop.org.ru>                                #
#                                                                              #
# Official support: irc.eggdrop.org.ru @ #eggdrop                              #
#                                                                              #
################################################################################

namespace eval idle {}

setudef flag nopubidle
setudef flag idlekickban

#################################################

bind pub - !idle	::idle::pub_idle
bind pub - !���		::idle::pub_idle

#################################################

catch {unset idle}
foreach p [array names idle *] {catch {unset idle($p)}}

# users get kicked after .. minutes idle(0 - disabled)
set idle(kickidle)	0
# users get banned after .. minutes idle (0 - disabled)
set idle(banidle)	0
# 0 - *!*user@*.domain, 1 - *!*@host.domain
set idle(bantype)	0
# ban time (minutes)
set idle(bantime)	30
# don't kick/ban users with such flags
set idle(aflags)	"nmoafb"
# check idle every .. minutes
set idle(checktime)	5

#################################################
##### DON'T CHANGE ANYTHING BELOW THIS LINE #####
#################################################

set idle(ver)		"1.0"
set idle(authors)	"Stream@RusNet <stream@eggdrop.org.ru>"

#################################################

proc ::idle::out {nick chan text} {
	if {[validchan $chan]} {putserv "PRIVMSG $chan :\002$nick\002, $text"
	} elseif {$nick == $chan} {putserv "PRIVMSG $nick :$text"
	} else {putserv "NOTICE $nick :$text"}
}

proc ::idle::tolower {text} {
	return [string map {� � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �} [string tolower $text]]
}

proc ::idle::init {} {
	global idle
	foreach tmr [timers] {if {[lindex $tmr 1] == "::idle::check"} {killtimer [lindex $tmr 2]}}
	if {$idle(banidle) != 0 || $idle(kickidle) != 0} {timer $idle(checktime) ::idle::check}
}

#################################################

proc ::idle::pub_idle {nick uhost hand chan args} {
	global idle botnick
	if {[channel get $chan nopubidle]} {return}
	set args [string trim [join $args]]
	putlog "\[idle\] $nick/$chan $args"
	if {[string length $args] > 0} {
		if {![onchan $args $chan]} {::idle::out $nick $chan "� �� ���� $args �� $chan..."; return}
		if {[string equal [::idle::tolower $args] [::idle::tolower $botnick]]} {::idle::out $nick $chan "���� �, ����... ��������� - � �� �������"; return}
		if {[string equal [::idle::tolower $args] [::idle::tolower $nick]]} {::idle::out $nick $chan "�������?"; return}
		set idletime [getchanidle $args $chan]
		if {$idletime < 1} {::idle::out $nick $chan "$args ������ ��� �������."
		} else {::idle::out $nick $chan "$args ������ ��� [::idle::duration $idletime]."}
	} else {
		set maxidle 0
		set maxidlenick ""
		foreach user [chanlist $chan] {
			if {[string equal $user $botnick]} {continue}
			set idletime [getchanidle $user $chan]
			if {$idletime > $maxidle} {
				set maxidle $idletime
				set maxidlenick $user
			}
		}
		if {$maxidle != 0} {
			if {[string equal $maxidlenick $nick]} {
				::idle::out $nick $chan "������ ���� ������� ��, �� ����� ��� [::idle::duration $maxidle]."
			} else {
				::idle::out $nick $chan "������ ���� ������ $maxidlenick, �� ����� ��� [::idle::duration $maxidle]."
			}
		} else {::idle::out $nick $chan "������������� �� ���... ����� �� ������."}
	}
}

#################################################

proc ::idle::check {} {
	global idle botnick
	foreach chan [channels] {
		if {![botisop $chan] || ![channel get $chan idlekickban]} {continue}
		foreach nick [chanlist $chan] {
			if {[string equal $nick $botnick]} {continue}
			set idletime [getchanidle $nick $chan]
			set hand [nick2hand $nick $chan]
			if {$hand != "" && $hand != "*" && [matchattr $hand "$idle(aflags)|$idle(aflags)" $chan]} {continue}
			if {$idle(banidle) != 0 && $idletime >= $idle(banidle)} {
				if {!$idle(bantype)} {
					set ipmask [lindex [split [maskhost $nick![getchanhost $nick $chan]] "@"] 1]
					set usermask [lindex [split [getchanhost $nick $chan] "@"] 0]		
					set banmask "*!*$usermask@$ipmask"
				} else { 
					set banmask [getchanhost $nick $chan]
		     	      		set banmask "*!*[string range $banmask [string first @ $banmask] end]" 
				}
				putlog "banmask = $banmask"
				putlog "\[idle\] $nick has been idle $idletime minutes on $chan, banning..."
				newchanban $chan $banmask $botnick "�������� - ������, �� �� � IRC... (��� �� [::idle::duration $idle(bantime)])" $idle(bantime)
				putserv "KICK $chan $nick :�������� - ������, �� �� � IRC..."
			} elseif {$idle(kickidle) != 0 && $idletime >= $idle(kickidle)} {
				putlog "\[idle\] $nick has been idle $idletime minutes on $chan, kicking..."
				putserv "KICK $chan $nick :�������� - ������, �� �� � IRC..."
			}
		}
	}
	timer $idle(checktime) ::idle::check
}

proc ::idle::duration {minutes} {
	set years [expr {$minutes / 524160}]
	set minutes [expr {$minutes % 524160}]
	set weeks [expr {$minutes / 10080}]
	set minutes [expr {$minutes % 10080}]
	set days [expr {$minutes / 1440}]
	set minutes [expr {$minutes % 1440}]
	set hours [expr {$minutes / 60}]
	set minutes [expr {$minutes % 60}]
	set res ""
	if {$years != 0} {lappend res [::idle::numstr $years "���" "���" "����"]}
	if {$weeks != 0} {lappend res [::idle::numstr $weeks "������" "������" "������"]}
	if {$days != 0} {lappend res [::idle::numstr $days "����" "����" "���"]}
	if {$hours != 0} {lappend res [::idle::numstr $hours "�����" "���" "����"]}
	if {$minutes != 0} {lappend res [::idle::numstr $minutes "�����" "������" "������"]}
	return [join $res ", "]
}

proc ::idle::numstr {val str1 str2 str3} {
	set d1 [expr $val % 10]
	set d2 [expr $val % 100]
	if {$d2 < 10 || $d2 > 19} {
		if {$d1 == 1} {return "$val $str2"}
		if {$d1 >= 2 && $d1 <= 4} {return "$val $str3"}
	}
	return "$val $str1"
}

::idle::init
putlog "idle.tcl v$idle(ver) by $idle(authors) loaded"


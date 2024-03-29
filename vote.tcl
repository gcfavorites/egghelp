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
# vote.tcl 1.0                                                                 #
#                                                                              #
# Author: Stream@Rusnet <stream@eggdrop.org.ru>                                #
#                                                                              #
# Official support: irc.eggdrop.org.ru @ #eggdrop                              #
#                                                                              #
################################################################################

namespace eval vote {}

setudef flag nopubvote

#################################################

bind pub o|o !vote		::vote::pub_vote
bind pub o|o !�����������	::vote::pub_vote
bind pub o|o !votehelp		::vote::pub_votehelp
bind pub o|o !helpvote		::vote::pub_votehelp
bind pub o|o !voteend		::vote::pub_voteend
bind pub o|o !endvote		::vote::pub_voteend

bind msg  -  vote		::vote::msg_vote

#################################################

catch {unset vote}
foreach p [array names vote *] {catch {unset vote($p)}}

# default vote time
set vote(deftime)	1
# default vote answers
set vote(defans)	"��:���"

#################################################
##### DON'T CHANGE ANYTHING BELOW THIS LINE #####
#################################################

set vote(ver)		"1.0"
set vote(authors)	"Stream@RusNet <stream@eggdrop.org.ru>"

#################################################

proc ::vote::out {nick chan text} {
	if {[validchan $chan]} {putserv "PRIVMSG $chan :$text"
	} elseif {$nick == $chan} {putserv "PRIVMSG $nick :$text"
	} else {putserv "NOTICE $nick :$text"}
}

proc ::vote::tolower {text} {
	return [string map {� � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �} [string tolower $text]]
}

proc ::vote::init {} {
	global vote
	foreach tmr [utimers] {if {[string first "::vote::endpoll" [lindex $tmr 1]] != -1} {killutimer [lindex $tmr 2]}}
}

#################################################

proc ::vote::pub_votehelp {nick uhost hand chan args} {
	::vote::out $nick "" "����������� �� ������ ���������� �������� \002!vote \[����\[|�����\[|��������_�������\]\]\]\002."
	::vote::out $nick "" "����� ����������� � ������� �����<h|�|m|�>. �������� ������� ����������� �������� ':'."
	::vote::out $nick "" "��������������� ���������� ����������� ����� ������ �������� \002!vote\002. ���������� ����������� �������� - �������� \002!voteend\002."
}

proc ::vote::pub_vote {nick uhost hand chan args} {
	global vote
	if {[channel get $chan nopubvote]} {return}
	set args [split [string trim [join $args]] "|"]
	if {[llength $args] < 1} {::vote::showvote $nick $chan; return}
	if {[info exists vote(started,$chan)]} {::vote::out $nick $chan "����������� ��� ��������. ������ ������������� ���������� ����� �������� !vote ��� ����������."; return}
	set vtopic [lindex $args 0]
	if {[llength $args] > 1} {
		set vt [::vote::tolower [string trim [lindex $args 1]]]
		if {![regexp -nocase -- {^([0-9]+)([hm��])$} $vt garb vtime vunit]} {
			::vote::out $nick $chan "������������ ������ �������. ��������� ��������: '�����<h|�|m|�>'."
			return
		}
		if {$vunit == "h" || $vunit == "�"} {set vtime [expr {$vtime * 60}]}
	} else {set vtime $vote(deftime)}
	if {[llength $args] > 2} {
		set vvar [split [::vote::tolower [string trim [lindex $args 2]]] ":"]
		if {[llength $vvar] < 2} {
			::vote::out $nick $chan "������� ��� ������� 2 ��������, �������� �� �������� ':'."
			return
		}
	} else {set vvar [split $vote(defans) ":"]}
	::vote::startpoll $nick $chan $vtopic $vtime $vvar
}

proc ::vote::pub_voteend {nick uhost hand chan args} {
	global vote
	if {[channel get $chan nopubvote]} {return}
	if {![info exists vote(started,$chan)]} {::vote::out $nick $chan "����������� �� ��������."; return}
	putlog "\[vote\] $nick/$chan end"
	::vote::endpoll $chan
}

proc ::vote::msg_vote {nick uhost hand args} {
	global vote
	set args [split [string trim [join $args]] " "]
	if {[llength $args] < 2} {::vote::out $nick $nick "��������� \002vote <#�����> <�������>\002."; return}
	set chan [lindex $args 0]
	if {![validchan $chan]} {::vote::out $nick $nick "� �� ����� �� ������� $chan."; return}
	if {![info exists vote(started,$chan)]} {::vote::out $nick $nick "����������� �� ������ $chan �� ��������."; return}

	set ans [::vote::tolower [string trim [join [lrange $args 1 end]]]]
	set validans 0
	foreach var $vote(var,$chan) {
		if {[string equal [::vote::tolower [string trim $var]] $ans]} {set validans 1; break}
	}
	if {$validans == 0} {
		set vvar [join $vote(var,$chan) "; "]
		::vote::out $nick $nick "�������� �������, �������� ���� �� ���������: $vvar"
		return
	}
	
	if {[info exists vote(hosts,$chan)]} {set vhosts $vote(hosts,$chan)} else {set vhosts ""}
	set pos [lsearch -exact $vhosts $uhost]
	if {$pos != -1} {
		set vnick [lindex $vote(nicks,$chan) $pos]
		if {![string equal $vnick $nick]} {
			::vote::out $nick $nick "�� ��� ������������� ��� ����� \002$vnick\002."
			return
		}
		set vote(ans,$chan) [lreplace $vote(ans,$chan) $pos $pos $ans]
	} else {
		lappend vote(hosts,$chan) $uhost
		lappend vote(nicks,$chan) $nick
		lappend vote(ans,$chan) $ans
	}
	::vote::out $nick $nick "��� ����� ����� (\002$ans\002). �� ������ �������� ��� �� ��������� �����������."
}

#################################################

proc ::vote::startpoll {nick chan vtopic vtime vvar} {
	global vote botnick
	set vote(started,$chan) 1
	set vote(nick,$chan) $nick
	set vote(topic,$chan) $vtopic
	set vote(time,$chan) $vtime
	set vote(var,$chan) $vvar
	set vote(hosts,$chan) ""
	set vote(nicks,$chan) ""
	set vote(ans,$chan) ""
	::vote::out "" $chan "�������� �����������, ����: $vtopic"
	set vvar [join $vvar "; "]
	::vote::out "" $chan "�������� �������: $vvar. ������ ����������� �������� /msg $botnick vote $chan <�������>"
	utimer [expr {$vtime * 60}] "::vote::endpoll $chan"
	putlog "\[vote\] $nick/$chan $vtopic $vtime $vvar"
}

proc ::vote::showvote {nick chan} {
	global vote
	if {![info exists vote(started,$chan)]} {::vote::out $nick "" "����������� �� ������ $chan �� ��������."; return}
	putlog "\[vote\] $nick/$chan"
	set vres ""
	foreach ans $vote(ans,$chan) {
		set found 0
		for {set i 0} {$i < [llength $vres]} {incr i} {
			set res [lindex $vres $i]
			if {[string equal [lindex $res 0] $ans]} {
				set vres [lreplace $vres $i $i [list $ans [expr {[lindex $res 1] + 1}]]]
				set found 1
				break
			}
		}
		if {$found == 0} {lappend vres [list $ans 1]}
	}
	foreach res $vres {
		::vote::out $nick "" "[lindex $res 0] - [lindex $res 1] [::vote::numstr [lindex $res 1] "�������" "�����" "������"]"
	}
	set voted [llength $vote(nicks,$chan)]
	if {$voted < 1} {::vote::out $nick "" "��� ������������."
	} else {::vote::out $nick "" "[::vote::numstr $voted "�������������" "������������" "�������������"] $voted [::vote::numstr $voted "�������" "�������" "��������"]."}
}
proc ::vote::endpoll {chan} {
	global vote
	if {![info exists vote(started,$chan)]} {putlog "\[vote\] endpoll executed for $chan, but poll isn't started"; return}
	putlog "\[vote\] finished on $chan"
	::vote::out "" $chan "����������� �� ���� \"$vote(topic,$chan)\" ��������, ����������:"
	set vres ""
	foreach ans $vote(ans,$chan) {
		set found 0
		for {set i 0} {$i < [llength $vres]} {incr i} {
			set res [lindex $vres $i]
			if {[string equal [lindex $res 0] $ans]} {
				set vres [lreplace $vres $i $i [list $ans [expr {[lindex $res 1] + 1}]]]
				set found 1
				break
			}
		}
		if {$found == 0} {lappend vres [list $ans 1]}
	}
	foreach res $vres {
		::vote::out "" $chan "[lindex $res 0] - [lindex $res 1] [::vote::numstr [lindex $res 1] "�������" "�����" "������"]"
	}
	set voted [llength $vote(nicks,$chan)]
	if {$voted < 1} {::vote::out "" $chan "��� ������������."
	} else {::vote::out "" $chan "[::vote::numstr $voted "�������������" "������������" "�������������"] $voted [::vote::numstr $voted "�������" "�������" "��������"]."}
	unset vote(started,$chan)
}

proc ::vote::numstr {val str1 str2 str3} {
	set d1 [expr $val % 10]
	set d2 [expr $val % 100]
	if {$d2 < 10 || $d2 > 19} {
		if {$d1 == 1} {return $str2}
		if {$d1 >= 2 && $d1 <= 4} {return $str3}
	}
	return $str1
}

#################################################

::vote::init
putlog "vote.tcl v$vote(ver) by $vote(authors) loaded"


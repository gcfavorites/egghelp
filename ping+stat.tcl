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
# ping.tcl 1.0                                                                 #
#                                                                              #
# Author: Stream@Rusnet <stream@eggdrop.org.ru>                                #
#                                                                              #
# Official support: irc.eggdrop.org.ru @ #eggdrop                              #
#                                                                              #
################################################################################

namespace eval ping {}

setudef flag nopubping

#################################################

bind pub - !ping	::ping::pub_ping
bind pub - !����	::ping::pub_ping
bind msg - !ping	::ping::msg_ping
bind msg - !����	::ping::msg_ping

bind ctcr - PING	::ping::reply

#################################################

# show ping time in milliseconds
set ping(ms)		1

# ��������� ���� ���� ����� ���������� ���� � ���������� ��������
set ping(datafile) "ping.dat"

#################################################
##### DON'T CHANGE ANYTHING BELOW THIS LINE #####
#################################################

set ping(ver)		"1.0"
set ping(authors)	"Stream@RusNet <stream@eggdrop.org.ru>"

#################################################

proc ::ping::init {} {
	global ping
	if {$ping(ms) && [info tclversion] < 8.3} {
		putlog "\[ping\] TCL 8.3 or higher required to calculate pings in milliseconds!"
		set ping(ms) 0
	}
}

#################################################

proc ::ping::pub_ping {nick uhost hand chan args} {
	if {[channel get $chan nopubping]} {return}
	::ping::ping $nick $chan
}

proc ::ping::msg_ping {nick uhost hand args} {
	::ping::ping $nick $nick
}

#################################################

proc ::ping::ping {nick chan} {
	global ping
	putlog "\[ping\] $nick/$chan"
	if {$ping(ms) == 1} {putquick "PRIVMSG $nick :\001PING [expr {abs([clock clicks -milliseconds])}]\001"
	} else {putquick "PRIVMSG $nick :\001PING [unixtime]\001"}
}

proc ::ping::reply {nick uhost hand dest key args} {
	global ping botnick
	set reply [lindex $args 0]
	if {![regexp -nocase -- {^-?[0-9]+$} $reply]} {
		putlog "\[ping\] incorrect ping reply from $nick"
		return
	}

      #������ ������ ��� ������ � ����
      set data [::egglib::readdata "$ping(datafile)"]
      
      #���������� ���������� ������
      set result [lindex [split $data "|"] 1] 

      #���������� � ��� ���� ���������
      set newresult [expr $result + [expr {abs([expr [expr {abs([clock clicks -milliseconds])} - $reply] / 1000.000])}]]
      
      #������������� ������� ���������� ������ �� ������� ������
      set counter [expr [lindex [split $data "|"] 0] + 1]

      #���������� ��� ��� � ����������
      set data $counter|$newresult

      #���������� ���������� � ���� ping(datafile)
      ::egglib::writedata "$ping(datafile)" $data

	if {$ping(ms) == 1} {
		puthelp "NOTICE $nick :\00310���� �� \00307$botnick \00310� \00307$nick:\0034 [expr {abs([expr [expr {abs([clock clicks -milliseconds])} - $reply] / 1000.000])}] \00310������. ����� \00305$counter \00310[lindex {. �������� �������� ��������} [::ping::numgrp $counter]] �����, ������� ���������: \00305[string range [expr $newresult/$counter] 0 9] \00310[lindex {. ������������ ������������ �����������} [::ping::numgrp [string range [expr $newresult/$counter] 0 5]]].\003"
	} else {puthelp "NOTICE $nick :\00310���� �� \00307$botnick \00310� \00307$nick: \00304[expr [unixtime] - $reply] \00310������.\003"}
}

### ���������� �������������� ������ ����� (c) s7ream
proc ::ping::numgrp {number} { switch -glob -- "$number" { *11 {return 3} *12 {return 3} *13 {return 3} *14 {return 3} *1 {return 1} *2 {return 2} *3 {return 2} *4 {return 2} default {return 3} } }

::ping::init
putlog "ping.tcl v$ping(ver) by $ping(authors) loaded"
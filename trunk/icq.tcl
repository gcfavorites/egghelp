#####################################################################################
#
#	:::[  T h e   R u s s i a n   E g g d r o p  R e s o u r c e  ]:::
#				 ___                 _
#				| __| __ _  __ _  __| | _ _  ___  _ __
#				| _| / _` |/ _` |/ _` || '_|/ _ \| '_ \
#				|___|\__, |\__, |\__,_||_|  \___/| .__/
#				     |___/ |___/                 |_|
#
#####################################################################################
#
# icq.tcl v1.1
#
# ������ ������� ������ ���������� ICQ-������.
#
#####################################################################################
# 
# ���������: 1) �������� ������ � ����� scripts
#			 2) � eggdrop.conf ��������� source scripts/icq.tcl
#
# .chanset #����� [+|-]icq - ��������|��������� ������ �� ������������ ������
#####################################################################################
#
# �������: !icq <����� ��� ��������>
#
#####################################################################################
#	13.09.2008
#	v1.2 Edit by adium
#	- ���������� ������ �� ���� ��� �������� (������� kns@RusNet);
#	- ����������� ����������� � ����� �������;
#	- �������� ������� �������� - ������ �� ���. ���� �������� �� ������������ (��� ����),
#	  � ������ �������� �� uin+chan, ����� �� ��������� ���� � �� �� ������� ������
#	  ��������� ���;
#	- ������ ��������� �� ����;
####
#	02.09.2008
#	v1.1 Edit by adium
#	- ��������� ������� � ����� � ����������� ����� (������� skai @ RusNet �� ������);
####
#	07.08.2008
#	v1.0 Edit by adium
#	- ������ ��������� ������ �������.
#####################################################################################

package require http 2.5
namespace eval icq {
	variable author			"adium@RusNet"
	variable version		1.2
	variable date			"13-Sep-2008"
	variable unamespace		[namespace tail [namespace current]]
	variable chflag			$unamespace
	variable pause			15
	setudef flag			$chflag
	if {![info exists egglib(ver)]} {
		setudef flag		usecolors
	}
	variable prefix			"!"
	variable flags			"-|-"
	variable binds			[list "icq" "uin"]
	foreach b $binds {
		bind pub ${flags} "${prefix}${b}" [namespace current]::main
	}
	variable msgspeed		2
	proc main {nick uhost hand chan text} {
		variable chflag
		if {![channel get $chan $chflag]} { return 0 }
		variable prefix; variable pause; variable msgspeed
		set text [lindex [split [string range $text 0 end]] 0]
		regsub -all -- "-" $text "" uin
		if {[string is space $text]} {
			output $chan "\00314�����������:\00304 ${prefix}icq \00314<\00304����� ICQ\00314>\003"  -speed $msgspeed -type msg
			return 0
		}
		if {![regexp -- {^\d+$} $text] && [regexp -nocase -- {[a-z�-��]} $text]} {
			output $chan "\00304������:\00314 �������� ������ UIN\'a\003"  -speed $msgspeed -type msg
			return 0
		}
		if {[expr [string length $uin] > 9]} {
			output $chan "\00304������:\00314 ����� UIN\'a �� ����� ���� ������ 9-�� ��������.\003"  -speed $msgspeed -type msg
			return 0
		}
		if {[expr [string length $uin] < 5]} {
			output $chan "\00304������:\00314 ����� UIN\'a �� ����� ���� ������ 5-�� ��������.\003"  -speed $msgspeed -type msg
			return 0
		}
		if {[checkflood $nick $uhost [namespace tail [lindex [info lev 0] 0]]]} {
			output $nick "\00314������� ������ ������������� ������� \00306${prefix}icq\00314. ��������� \00306[timewait $nick $uhost [namespace tail [lindex [info lev 0] 0]]] ���.\00314 � ��������� �������...\003"  -speed $msgspeed -type ntc
			return 0
		}
		if {[uinflood $chan [namespace tail [lindex [info lev 0] 0]]]} {
			output $chan "\00314������ ����� ������ ������� ������������ �� ���� ������...\003"  -speed $msgspeed -type msg
			return 0
		}
		set icq(agent) [::http::config -useragent "Mozilla/5.0 (X11; U; Linux i686; ru-RU; rv:1.8.1) Gecko/2006101023 Firefox/2.0"]
		set icq(url) [::http::geturl "http://webtools.xakepok.org/invisible/invis.php?uin=$uin" -timeout 150000]
		set st [::http::data $icq(url)]
		::http::cleanup $icq(url)
		if {$st eq ""} {
			output $chan "\00304������ ��������...\003"  -speed $msgspeed -type msg
			return 0
		} elseif {$st ne ""} {
				set st [string map [list "offline" "�� � ����" "online" "� ����" \
					"occupied" "�����" "na" "����������" "dnd" "�����" \
					"away" "������" "free4chat" "����� ���������" "invisible" "�������"] $st]
				output $chan [subst {\00314������ \00305$uin\00312::\00306 $st\003}]  -speed $msgspeed -type msg
				return 0
		}
	}
	
	proc output {c s args} {
		importvars [list] $args [list speed 2 type msg]
		if {[string index $c 0] eq "#"} {
			if {![channel get $c usecolors]} { set s [stripcodes cbur $s] }
		}
		if {[string tolower $type] eq "msg"} {
			set t "PRIVMSG"
		} elseif {[string tolower $type] eq "ntc"} {
			set t "NOTICE"
		} else {
			return -code error "wrong args: should be \"[namespace current]::output chan string -speed NUM -type NAME\""
		}
		if {[regexp -- {\d+} $speed]} {
			if {$speed == "0"} {
				set msg [string range $s 0 end]
				append msg "\n"
				putdccraw 0 [string length $msg] $msg
			} elseif {$speed == "1"} {
				putquick "$t $c :$s"
			} elseif {$speed == "2"} {
				putserv "$t $c :$s"
			} elseif {$speed == "3"} {
				puthelp "$t $c :$s"
			} else { return -code error "wrong args: should be \"[namespace current]::output chan string -speed NUM -type NAME\"" }
		}
	}
	
	proc checkflood {nick uhost comm} {
		variable pause; variable lastcall; variable prefix
		if {[matchattr $nick n] || [matchattr $nick m] || [matchattr $nick o]} { return 0 } else {
			if {[info exists lastcall($comm,$uhost)]} {
				if {[expr [expr [unixtime] - $lastcall($comm,$uhost)] < $pause]} {
					set det [expr [unixtime] - $lastcall($comm,$uhost)]
					set wtime [expr $pause - $det]
					return 1
				}
			}
		}
		set lastcall($comm,$uhost) [unixtime]
		return 0
	}
	variable uin_pause 25
	proc uinflood {chan comm} {
		variable uin_pause; variable lastuincall; variable prefix
		if {[info exists lastuincall($chan,$comm)]} {
			if {[expr [expr [unixtime] - $lastuincall($chan,$comm)] < $uin_pause]} {
				set det [expr [unixtime] - $lastuincall($chan,$comm)]
				set wtime [expr $uin_pause - $det]
				return 1
			}
		}
		set lastuincall($chan,$comm) [unixtime]
		return 0
	}
	
	proc timewait {nick uhost comm} {
		variable pause; variable lastcall; return [expr { $lastcall($comm,$uhost) + $pause - [unixtime] }]
	}
	
	proc importvars {lo {la {}} {ln {}}} {
		set lvars [list]
		foreach {var value} $ln {uplevel [list set $var $value]; lappend lvars $var}
		foreach {flag value} $la {
			if {[string index $flag 0] == "-"} {
				set var [string range $flag 1 end]
				uplevel [list set $var $value]
				lappend lvars $var
			}
		}
		foreach var $lo {
			if {[lsearch $lvars $var] < 0} {
				set value [uplevel 2 "if {\[info exists $var\]} {set $var} else {set $var \"\"}"]
				uplevel [list set $var $value]
			}
		}
	}
	
	putlog "[namespace current]:: v$version \[$date\] by $author loaded."
}
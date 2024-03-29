#################################################################################
# ��������:
#	������ ������� ���������� ������. ������ ������� ���������� ������, �������
#	� ������ ������ �� ������, ����� ���������� ������� �� ��� ����, ������ �
#	��������������.
#
#
# �������:
#	!chanstat
#
# ���������:
#	http://www.hackersforce.com
#	http://forum.hackersforce.com
#	irc.hackersforce.com:6667 - #hackers
#
# ������:
#	���� - <mpak@nordlines.ru>
#	asdaf @ EFnet - <xio@netlimit.com>
#	p.s. ��������� ����
#
# ����� ������:
#	.chanset #chan +nopubchanstat - �������� ������� !chanstat �� ������ #chan
#	.chanset #chan -nopubchanstat - ������� ������� !chanstat �� ������ #chan
#	������� �������� � partyline (DCC CHAT) � ����.
#
# ������:
#	2.0
#################################################################################
# ������� ������:
#	������ 2.0
#	+ �������� ����� ���������� �������������� �� ������
#	+ ����������� ������� ������������� ������� !chanstat �� ������������
#	�������.
#	+ ����������� �� ������� ����� ��������� �������������� �������.
#
#	������ 1.0.0
#	ChanStat v1.0.0 by asdaf @ EFnet
#	You may change anything in here as you wish, as long as
#	you keep the author information in the top of the file.
#	I would like to recieve comments and suggestions to my
#	email at xio@netlimit.com.
#################################################################################
setudef flag nopubchanstat

# ������� ����� �������������� �������.
set chanstat(prefix) "!"

# ����� ����� ��������� �������������� �������.
set chanstat(time) 15

set chanstat(version) 2.0
set chanstat(autors) "asdaf @ EFnet <xio@netlimit.com> & MPAK <mpak@nordlines.ru>"

bind pub -|- $chanstat(prefix)chanstat pub:chanstat

proc pub:chanstat {nick uhost hand chan args} {
 global chanstat

 if {[channel get $chan nopubchanstat]} {
  putserv "NOTICE $nick :\00304�\00305� ������ \00304$chan\00305 ������� \00304$chanstat(prefix)chanstat\00305 ���������\00304.\017"
 return
 }

 set chanstatline [utimers]
 foreach line $chanstatline {
 if {"chanstat:reset $uhost" == [lindex $line 1]} { set chanstattime [lindex $line 0] }
 }
 if { [info exists chanstat(host,$uhost)] } { 
	set temp [duration $chanstattime] 
        	regsub -all -- {hours} $temp {5���(��)} temp 
	        regsub -all -- {hour} $temp {5���} temp 
		regsub -all -- {minutes} $temp {5�����(�)} temp
        	regsub -all -- {minute} $temp {5������} temp
		regsub -all -- {seconds} $temp {5������(�)} temp
		regsub -all -- {second} $temp {5�������} temp
 if {$chanstat(time) > 0} { putserv "NOTICE $nick :\00304�\00305� ������� ������������ ������� \00304$chanstat(prefix)chanstat\00305 ����� \00304$temp\017" }
 return
 }

 set chanstat(host,$uhost) 1
 set chanstat(timer,$uhost) [utimer $chanstat(time) [list chanstat:reset $uhost ] ]

 set chanstat(ops) 0
 set chanstat(halfops) 0
 set chanstat(voices) 0
 set chanstat(users) [chanlist $chan]
 for { set chanstat(total) 0 } { $chanstat(total) < [llength $chanstat(users)] } { incr chanstat(total) } {
  if {[isop [lindex $chanstat(users) $chanstat(total)] $chan]} { incr chanstat(ops) } elseif {[isvoice [lindex $chanstat(users) $chanstat(total)] $chan]} { incr chanstat(voices) } elseif {[ishalfop [lindex $chanstat(users) $chanstat(total)] $chan]} { incr chanstat(halfops) }
 }
   putserv "NOTICE $nick :\00304T\00305otal users\00304: $chanstat(total)\00305. \00304@\00305Ops\00304: $chanstat(ops)\00305, \00304+\00305Voices\00304: $chanstat(voices)\017"
}


proc chanstat:reset { uhost } {
 global chanstat
 catch {killutimer $chanstat(timer,$uhost)}
 catch {unset chanstat(timer,$uhost)}
 catch {unset chanstat(host,$uhost)}
}


putlog "chanstat.tcl v$chanstat(version) by $chanstat(autors) - loaded"
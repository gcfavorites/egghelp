#####################################################################################
#
#		:::[  T h e   R u s s i a n   E g g d r o p  R e s o u r c e  ]::: 
#      ____                __                                                      
#     / __/___ _ ___ _ ___/ /____ ___   ___      ___   ____ ___ _     ____ __ __   
#    / _/ / _ `// _ `// _  // __// _ \ / _ \    / _ \ / __// _ `/    / __// // /   
#   /___/ \_, / \_, / \_,_//_/   \___// .__/ __ \___//_/   \_, / __ /_/   \___/    
#        /___/ /___/                 /_/    /_/           /___/ /_/                
#
#
#####################################################################################
#
# How to instal:
#	Copy vopall.tcl to 'scripts' directory and add string 'source scripts/vopall.tcl'
#	in your eggdrop.conf file.
# Author: Handbrake <ss666@mail.ru>
# Official support: RUSNET #eggdrop
# 
# == ������ ������� ��� ������������� �� ������������ �������. ������ ����� ���� 
# == �������� �� ����� �������� ����� � ���������� ��������� ������ +q +d +k .
# == ����� ����������� ������� �������� ����� ����� �������� ����� �� 
# == �������� ����� ��� + �������
#####################################################################################
## ������ ��� ����� VOPALL
set vopchans {
	"#freebot"
	"#milicia"
	"sfdfssd"
}
#����� �������� ����� ������ ����� �� ����� � ���������� ����� 
set publol(voptime) 10
#####################################################################################
#####################################################################################
proc vopchancheck {chan} { global vopchans;
foreach ch $vopchans { if {[string equal -nocase $ch $chan] } {return 1}; }; return 0 }
bind join - * publol:joinch
proc publol:joinch {nick uhost hand chan} { global publol;
if { ![vopchancheck $chan] } { return 1 }
if { [info exists publol(vophost,$uhost)] } { return 1 }
set publol(vophost,$uhost) 1
set publol(voptimer,$uhost) [utimer $publol(voptime) [list publol:joincheck $nick $uhost $hand $chan]]
}
proc publol:joincheck {nick uhost hand chan} { global botnick publol;
catch {killutimer $publol(voptimer,$uhost)}
catch {unset publol(voptimer,$uhost)}
catch {unset publol(vophost,$uhost)}
if { !([isop $botnick $chan] || [ishalfop $botnick $chan]) } { return 1 }
if { $nick == $botnick } {
	foreach nik [chanlist $chan] {
	 if { ![isvoice $nik $chan] && ![isop $nik $chan] && ![ishalfop $nik $chan] && $nik != $botnick } {
		set handcheck [nick2hand $nik]
		if { ($handcheck == "*") || ($handcheck == "") } { putserv "MODE $chan +v $nik" } else {
    if { ![matchattr $handcheck "|q" $chan] && ![matchattr $handcheck "|d" $chan] && ![matchattr $handcheck "|k" $chan] && ![matchattr $handcheck "b"] } { putserv "MODE $chan +v $nik" }
    };};}
	return 1
	} else {
 	if { [isvoice $nick $chan] || [isop $nick $chan] || [ishalfop $nick $chan] } { return 1 }
	if { $hand == "*" } { putserv "MODE $chan +v $nick"; return 1 }
	if { [matchattr $hand "|q" $chan] || [matchattr $hand "|d" $chan] || [matchattr $hand "|k" $chan] } { return 1 }
	if { [matchattr $hand "q"] || [matchattr $hand "d"] || [matchattr $hand "k"] || [matchattr $hand "b"] } { return 1 }
  putserv "MODE $chan +v $nick"; return 1
 }
}
putlog "vopall-script by Handbrake loaded.."
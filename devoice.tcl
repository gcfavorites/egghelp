# Devoice tools
# (c) 2007 Handbrake. http://proff.boom.ru
# �� ������� Latinus-� :)
#
# ������������ ���: 
# !�� <nick> [host]
# !dv <nick> [host]
# !-v <nick> [host]
#
# ���� ����� ���� ���� �� ������, ��: 
#   ���� ���� �� ����� �� ������� ��� �������   
#   ���� ���� ����� �� ������������� ��������
# ���� ����� �� ������ ��� �� ���� ������ �����������.
#
# ���������, ���� ����, ������ �����, �(���) ������ ����� +dq (������)
# ������ ����� ��� ���������� � tcs.tcl � ��� ���� �������� �� �����.
# ������� ������ � ������ ������� ������� �� tcs.
#################################################################################

# ���������:
# M����. <tcs(dvtmask) 1> = *!*ident@*.host... <tcs(dvtmask) 2> = *!*@full.host ... <tcs(dvtmask) 3> = *nick*!*ident@*
# <tcs(dvtmask) 4> = *!*ident*@full.host.com

set tcs(dvtmask) 1

# BINDs
bind pub m|m ${cmdpfix}dv tcs:nahui
bind pub m|m ${cmdpfix}�� tcs:nahui
bind pub m|m ${cmdpfix}-v tcs:nahui


#################################################################################
proc tcs:dvmask {nick host} { global tcs;
set userhost [MakeIdent $host]
if {([string index $userhost 0] == "~") || ([string index $userhost 0] == "^")} { set userhost [string range [join $userhost] 1 end] } { set userhost [join $userhost] }
 set userhost [transhost $userhost]
	if { ($tcs(dvtmask) != 2) && ($tcs(dvtmask) != 3) && ($tcs(dvtmask) != 4) } { return "*!*[lindex [split $userhost "@"] 0]*@[lindex [split [maskhost $userhost] "@"] 1]" }
  if { $tcs(dvtmask) == 2 } { return "*!*@[lindex [split $userhost "@"] 1]"}
  if { $tcs(dvtmask) == 3 } { return "*$nick*!*[lindex [split $userhost "@"] 0]*@*"}
  if { $tcs(dvtmask) == 4 } { return "*!*[lindex [split $userhost "@"] 0]*@[lindex [split $userhost "@"] 1]" }
}

proc tcs:nahui {nick uhost hand chan args} { global botnick tcs cmdpfix;
if { ($hand == "*") || ($nick == $botnick) } { return 0 }
if {![tcs:authcheck $nick $nick $uhost $hand 2]} {return 0}
if { [info exists tcs(sleep_p)] } { notice $nick "������� ������� ����� ���� ������."; return 0 }
if {[getting-users]} { notice $nick "������� ������� ����� ���� ������. Sorry, iam too busy now,, try again in few seconds"; return 0 }
if {!([matchattr $hand "|m" $chan] || [matchattr $hand "m"])} { notice $nick "� ���� ��� ���� ������ ���. You have not access to this command"; return 0 }
	set args [split [lindex $args 0]]
	set who_orig [transc [lindex $args 0]]
if { $who_orig == "" } {notice $nick "������������ ���: ${cmdpfix}dv <nick> \[host\] ��� ${cmdpfix}�� <nick> \[host\]"; return 0 }
if { [tolow $who_orig] == [tolow $botnick] } { putserv "KICK $chan $nick :��� ������ ������������"; return 0 }
  set who [CutLongName [transnick $who_orig]]
	set rhost [transhost [lindex $args 1]]
if { ($rhost == "") && (![onchan $who_orig $chan]) } { notice $nick "���� ����� $who_orig ��� �� ������ �� ����� ������ ���������� ��������� ���� ������� ����� �������� �����"; return 0 }
if { $rhost == "" } { set tmask [tcs:dvmask $who [getchanhost $who_orig]] } { set tmask $rhost }
if { (![checkmask $tmask]) || ($tmask == "*!*@*") } { SendErr $nick 2 3; return 0 }
 set checkh [tcs:findusers $tmask]
if { $checkh != "" } {
 if { [llength $checkh] > 1 } { notice $nick "�� ���� ��������� ����� $tmask... ��� ��� �������� ��������� ������: \002$checkh\002 ... �������� \002����������\002 ����� � ������ ������� � ���������"; return 0 }
}
if { [onchan $who_orig] } {
	set tchk [nick2hand $who_orig]
 if { ($tchk != "") && ($tchk != "*") } {
	if { ![tcs:CompUO $hand $tchk $chan] } { SendErr $nick 2 2; return 0 }
	notice $nick "���� ���� ��� ��������. � ��������� �� ������� ��� $tchk .. �������� ����� +dq .."
  tcs:auserset $tchk $hand $chan "dq" "DeVoice"
  } else {
   if { [validuser $who] } {
     if { ([llength $checkh] == 1) && ([lindex $checkh 0] != $who) } { notice $nick "����� $tmask ����������� ����� \002[lindex $checkh 0]\002 ... �������� \002����������\002 �����"; return 0 }
  	 if { ![tcs:CompUO $hand $who $chan] } { SendErr $nick 2 2; return 0 }
  	 notice $nick "���� $who ��� �������, �������� ����, �������� ����� +dq..."
  	 setuser $who HOSTS $tmask
     tcs:auserset $who $hand $chan "dq" "DeVoice"
  	} else {
      if { [llength $checkh] == 1 } { notice $nick "����� $tmask ����������� ����� \002[lindex $checkh 0]\002 ... �������� \002����������\002 �����"; return 0 }
  		notice $nick "�������� ����� ���� $who � ������� +dq �� ������ $chan � � ������ $tmask..."
  		adduser $who $tmask
      tcs:auserset $who $hand $chan "dq" "DeVoice"
  	}; }
 } else {
   if { [validuser $who] } {
  	 if { ![tcs:CompUO $hand $who $chan] } { SendErr $nick 2 2; return 0 }
     if { ([llength $checkh] == 1) && ([lindex $checkh 0] != $who) } { notice $nick "����� $tmask ����������� ����� \002[lindex $checkh 0]\002 ... ������������ �������� ${cmdpfix}match <host>"; return 0 }
  	 notice $nick "���� $who ��� �������, �������� ����, �������� ����� +dq..."
  	 setuser $who HOSTS $tmask
     tcs:auserset $who $hand $chan "dq" "DeVoice"
  	} else {
      if { [llength $checkh] == 1 } { notice $nick "����� $tmask ����������� ����� \002[lindex $checkh 0]\002 ... �������� \002����������\002 �����. ������������ �������� ${cmdpfix}match <host>"; return 0 }
  		notice $nick "�������� ����� ���� $who � ������� +dq �� ������ $chan � � ������ $tmask..."
  		adduser $who $tmask
  		tcs:auserset $who $hand $chan "dq" "DeVoice"
    }; }
}
putlog "\002Delvoice tools\002 by Handbrake loaded"









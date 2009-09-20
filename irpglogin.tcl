###
#
#  ��������: irpglogin.tcl
#  ������: 1.1
#  �����: username 
#
###
#
# ��������: ������ ��������� ������ ���� ���������������� � ����������� � idleRPG,
# �� ������ �������� �������� ��������� ������ ���� ����� ��������� �������
# ������� �� ���� ���������� � ���� ��������� �������.   
#   ��������� �������������� ����������� �������� ����� �������, ��� ���� �� �������
# ����� ������� ���� ��� ���, ���� ��� ������� ����� ����, �� ���������� ����� ����������
# ����������� �������. ����� ��������� �������������� ����������� ����������� ���������
# ���� nopubirpg.
#   ��� ������� �������� ������ � ������� ����.  
#
###
#
# ���������: 
#   1. ���������� ������ irpglogin.tcl � ����� scripts ������ ���� 
#   2. � ����� eggdrop.conf ������� ������ source scripts/irpglogin.tcl 
#   3. �������� .rehash ����
#
###
#
# ������� �������:
#  1.1(22.11.2006) 
#  + ������ �������� �������
#  + ����������� � �������
#  + ���� ��� ���������� ������� nopubirpg
#  + ��������� �������������� ����������� ��� ����� �� ����� 
#  + ����������� ��������� ��������� ���������
#
#  1.0(02.11.2006)
#    ������ ������ ��� ����� ���� �������� � ��������� 
#
###

#��������� ������������ ����
namespace eval irpg {}
catch {unset irpg}
foreach p [array names irpg *] { catch {unset irpg($p) } }

#��������� ��������� ����(.chanset #chan +nopubirpg ��� ���������� �������������� �����������)
setudef flag nopubirpg

###                            ###
# ���� �������� ���� ���� �����: #
# ______________________________ #
###                            ###

#����� �� ������� ������ ����
set irpg(chan) "#idlerpg"

#��� ���� �������� ����
set irpg(nick) "idlerpg"

#��� �������� ������ ����(�� ����� 16 ��������)
set irpg(acct) "Robotronic"

#������ ������ ���������(�� ����� 8 ��������)
set irpg(pass) "accpass"

#����� ������ ���������(�� ����� 30 ��������)
set irpg(char) "Eggdrop 1.6.18"

#������� ��� ����������� ������ ���������
set irpg(regcmd) !irpgreg 

#������� ��� "������" ����������� � �������� ����
set irpg(logcmd) "!irpglogin"

#������� ��������� ��������� �� GOOD
set irpg(galigncmd) "!galign"

#������� ��������� ��������� �� NEUTRAL
set irpg(naligncmd) "!nalign"

#������� ��������� ��������� �� EVIL
set irpg(ealigncmd) "!ealign"

###                                                                  ###
# ���� ���� ����� ���������� ���, �� ��������� ��� ���� �� ������ TCL: #
# ____________________________________________________________________ #
###                                                                  ###

#������ �������
set irpg(version) "irpg.tcl version 1.1"

#����� �������
set irpg(author) "username"

#��������� �������������� �����������
bind join - "$irpg(chan) *" irpg:login
proc irpg:login {nick uhost hand chan} {
  global botnick irpg
  if {[channel get $chan nopubirpg]} {return}
  if {($nick == "$botnick") || ($nick == "$irpg(nick)")} {
    putserv "PRIVMSG $irpg(nick) :login $irpg(acct) $irpg(pass)"
    putlog "IRPG Auto Login Initiated.. Request is Being Processed."
  }
}

#��������� "������" �����������
bind msg n $irpg(logcmd) irpg:manual:login
proc irpg:manual:login {nick uhost hand arg} {
 global botnick irpg
 putserv "NOTICE $nick :Login Request sent to $irpg(nick)" 
 putserv "PRIVMSG $irpg(nick) :login $irpg(acct) $irpg(pass)"
}

#��������� ����������� ���������
bind msg n $irpg(regcmd) irpg:reg
proc irpg:reg {nick uhost hand arg} {
 global botnick irpg
 putserv "NOTICE $nick :Register Request sent to $irpg(nick)" 
 putserv "PRIVMSG $irpg(nick) :register $irpg(acct) $irpg(pass) $irpg(char)"
}

#�������� ��������� ��������� �� GOOD
bind msg n $irpg(galigncmd) align:good
proc align:good {nick uhost hand arg} {
 global botnick irpg
 putserv "NOTICE $nick :Align Request GOOD sent to $irpg(nick)" 
 putserv "PRIVMSG $irpg(nick) :align good"
}

#��������� ��������� ��������� �� NEUTRAL
bind msg n $irpg(naligncmd) align:neutral
proc align:neutral {nick uhost hand arg} {
 global botnick irpg
 putserv "NOTICE $nick :Align Request NEUTRAL sent to $irpg(nick)" 
 putserv "PRIVMSG $irpg(nick) :align neutral"
}

#��������� ��������� ��������� �� EVIL
bind msg n $irpg(ealigncmd) align:evil
proc align:evil {nick uhost hand arg} {
 global botnick irpg
 putserv "NOTICE $nick :Align Request EVIL sent to $irpg(nick)" 
 putserv "PRIVMSG $irpg(nick) :align evil"
}

#������� ��������� � ���, ��� ������ ������ ��������
putlog "\[irpglogin\] $irpg(version) by $irpg(author) loaded"

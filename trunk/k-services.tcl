###############################
# k-services.tcl LITE version #
####################################
# Current version: 1.2             #
# Author: Kein (kein-of@yandex.ru) #
#######################################
# Description:                        #
# -> ������ ������������ ��� �����    #
#    ����������� ���� ����, � ������: #
#    ������������� �� �������� �      #
#    ��������� � ���������� �����     #
#    ������ �� ��������, �������      #
#    ������������ ������� ����������� #
#    ��������� ����� ������           #
###############################################
# ������������:                               #
# 1. ��� �� �������� ��������� ���������      #
#    �����, ������������ �������������        #
#    �������� ���� �������� �� ����������,    #
#    � ��� ��, �������� need-key ���������� � #
#    putserv "PRIVMSG ChanServ :getkey #chan" #
# 2. �������� ���� �������� �� ���������� ��� #
#    ���� ������������� � �������� :P         #
###############################################
# ��������� ������:                           #
# -> ����������������� ghost'���, �������� �� #
#    ��, �������� �� ghost'����� �������      #
###############################################

# Namespace evaluation
namespace eval kservices {}

# Reset of variables
foreach k [array names kservices *] { catch {unset kservices($k) } }

# Settings (��������� #

# �����, ������
set kservices(author) "Kein"
set kservices(version) "1.2"
set kservices(amail) "kein-of@yandex.ru"

# ������ ��������
## ��������: ������, �� ������� ����� �������.
## ����������� ������ ���������� � "@"! ������
## ������ ����� ��������� /WHOIS NickServ NickServ
## ���� �� ������, ������ �������� ���� ������.
#### ��� InspIRCD ������ 1.1.15 � �����, ���������
#### ���� ������!!! � ������, ��� IRCD, �������
#### �� ������������ ������ ��������� ����:
#### PRIVMSG nick@server �������� �� ������!
set kservices(server) "@services.dalnet.ru"

# ��������� ������� OP|HALFOP|VOICE
## ���������� � "yes" ���� ������� ����� ����
## ��������� ������������ ������� OP|HALFOP|VOICE
## ��� �����-���� ���������� ��� ��������� �������
## �� ���� �������, ��� �� (������) ��������.
## � ��������� ������, ������� �������� � "no".
set kservices(opall) "yes"

# ���������� �������
## �������, ����� ������� ������ ������������ ���
## ����� �� ����� ������������� �� ��������.
## �������� ��������:
## -> OP - ��� ��������� ������� ���
## -> HALFOP - ��� ��������� ������� ����
## -> VOICE - ��� ��������� ������� �����
set kservices(cscmd) "OP"

# ������ ��������
## ��������� ������ � ������������ ������
## ������ �������� �� ������ � ���� ��������.
## ���������������� ���� �� ����� ����, �
## � ����������� �� ������ ��������.
## (������ �� ����� �� /version NickServ)
# ---------------------------------
# ��� Anope ������ 1.6.5 � ����:
# set kservices(version) "anopeold"
# ��� Anope ������ 1.7.x:
set kservices(version) "anopenew"
# ��� Atheme services:
#set kservices(version) "atheme"

# ������ ���� �� ��������
set kservices(nspasswd) "krutoi_pass"

# ��� � ��������� ��������
set kservices(nsnick) "NickServ"
set kservices(nshost) "services@services.dalnet.ru"
set kservices(csnick) "ChanServ"
set kservices(cshost) "services@services.dalnet.ru"

# ������� �������������
set kservices(nsidcmd) "PRIVMSG $kservices(nsnick)$kservices(server) :IDENTIFY"

# ������� ��� ������� identify
set kservices(prefix) "!"

# Binds (�����)
## ��������: ������ �� �����, �� �������
### ����� ����������� ���.

# anopenew
## english
bind notc - "*Key*for*channel*#*is*" kservices:usekey
## russian
bind notc - "*���*���*������*#*-*" kservices:usekey
# atheme
bind notc - "*Channel*#*key*is:*" kservices:usekey
# anopeold
bind notc - "*KEY*#*" kservices:usekey

# id-request
bind notc - "*$kservices(nsnick)*IDENTIFY*" kservices:aid

bind pub m|m ${kservices(prefix)}identify kservices:mid

# Code (���)
## Don't change anything below this line!
## ���� ���� ���. ���������� �� �������, ���� ��
## �����, ��� � ����...

# �������� �� ���������� ������ � ����� ��������
## ������ ����� �� TCS
proc kservices:vldcheck {nick host} {
global kservices
set nick [string tolower [join $nick]]
set host [string tolower [join $host]]
if {(($nick == [string tolower $kservices(nsnick)]) && ($host == [string tolower $kservices(nshost)])) || (($nick == [string tolower $kservices(csnick)]) && ($host == [string tolower $kservices(cshost)]))} { return 1 }
return 0
}

# ������ ������������� �� identify
## �������� �� ������������� �������� �� ����� +Q,
## ������� ������������ � ����������� �������� ��
## ���������� ��������. ������������� � CCS �� Buster.
proc kservices:mid {nick host hand chan text} {
global kservices
if {![matchattr $hand Q]} {
 putserv "NOTICE $nick :�� �� ����������������!"
 putcmdlog "::k-services.tcl:: Fake authorization request from $nick!$host on $chan * Ignoring..."
 return 0
}
putserv "$kservices(nsidcmd) $kservices(nspasswd)"
putcmdlog "::k-services.tcl:: Received authorization request from $nick!$host on $chan * Identifying..."
if {$kservices(opall) == "no"} {
 foreach c [channels] {
 putserv "PRIVMSG $kservices(csnick) :$kservices(cscmd) $c"
}
} else {
 putserv "PRIVMSG $kservices(csnick) :$kservices(cscmd)"
}
}

# ����������������� �� ��������
proc kservices:aid {nick host hand chan text {dest ""}} {
global botnick kservices
if {![kservices:vldcheck $nick $host]} {putcmdlog "::k-services.tcl:: Fake login request from $nick!$host * Ignoring..."; return 0}
putserv "$kservices(nsidcmd) $kservices(nspasswd)"
putcmdlog "::k-services.tcl:: Received authorization request from $host * Identifying..."
if {$kservices(opall) == "no"} {
 foreach c [channels] {
 putserv "PRIVMSG $kservices(csnick) :$kservices(cscmd) $c"
}
} else {
 putserv "PRIVMSG $kservices(csnick) :$kservices(cscmd)"
}
}

# ��������� ����������� �����
proc kservices:usekey { nick uhost hand text dest } {
global botnick kservices
# anope NEW
if {$kservices(version) == "anopenew"} {
 set jchan [lindex $text 3]
 if {![string match "#*" $jchan]} {putcmdlog "::k-services.tcl:: I've got a strange channel name... Are you sure that's is your network used an Anope version 1.7.x?"; return 0}
 set jkey [stripcodes b [lindex $text 5]]
 set jkey [string range $jkey 0 [expr [string length $jkey]-2]]
}
# anope OLD
if {$kservices(version) == "anopeold"} {
 set jchan [lindex $text 1]
 if {![string match "#*" $jchan]} {putcmdlog "::k-services.tcl:: I've got a strange channel name... Are you sure that's is your network used an Anope version 1.6.x?"; return 0}
 set jkey [lindex $text 2]
}
# Atheme
if {$kservices(version) == "atheme"} {
 set jchan [stripcodes b [lindex $text 1]]
 if {![string match "#*" $jchan]} {putcmdlog "::k-services.tcl:: I've got a strange channel name... Are you sure that's is your network used an Atheme?"; return 0}
 set jkey [lindex $text 4]
}
# �������� �� ���������� ������ � �����
if {[kservices:vldcheck $nick $uhost]} {
 if {[validchan $jchan] && ![botonchan $jchan] && ![channel get $jchan inactive]} {
  putcmdlog "::k-services.tcl:: Received key $jkey from $nick!$uhost for channel $jchan * Now trying to join..."
  putserv "JOIN $jchan :$jkey"
  return
 } else {
  putcmdlog "::k-services.tcl:: Received key $jkey from $nick!$uhost for channel $jchan, but not needed yet..."
  return
 }
} else {
 putcmdlog "::k-services.tcl:: Fake key-response from $nick!$uhost"
 return 0
}
}

putlog "K-services.tcl LITE by $kservices(author) ($kservices(amail)) version $kservices(version) successfully loaded!"
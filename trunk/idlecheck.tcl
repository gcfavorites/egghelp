###
#
#  ��������: idlecheck.tcl
#  ������: 1.0
#  �����: username 
#
###
#
# ��������: ������ ������ �� idle-time � ������ �� ��������� ������� � ���� �� 
#           ��������� ������������� ����� �� ������� � ��� ����.
#          
#
###
#
# ���������: 
#         1. ���������� ������ � ����� scripts ������ ����.
#         2. � ����� eggdrop.conf ������� ������ source scripts/
#         4. �������� .rehash ����.
#
###
#
# ������� �������:
#
#              1.0(03.06.07) ������ ������ ������. 
#
###

# ��������� ������������ ����.
namespace eval idlecheck {}

# ���������� �������� ���� ����������.
foreach p [array names idlecheck *] { catch {unset idlecheck($p) } }

# ��������� ��������� ����.
setudef flag nopubidlecheck

###                            ###
# ���� �������� ���� ���� �����: #
# ______________________________ #
###                            ###

# ������ �� ������� ����� �������� ���� ������.
set idlecheck(channels) "#3hauka"

# �����(���) ����� ������� ��� ����� ��������� idle-time.
set idlecheck(scan) "3"

# �����(���) �� ������� ����� ��������� ����.
set idlecheck(time) "30"

# ����� ������������� �� ������� �� ��������� ������.
set idlecheck(flags) "mnofb"

###                                                                  ###
# ���� ���� ����� ���������� ���, �� ��������� ��� ���� �� ������ TCL: #
# ____________________________________________________________________ #
###                                                                  ###

# ������ �������.
set idlecheck(version) "idlecheck.tcl version 1.0"

# ����� �������.
set idlecheck(author) "username"

#��������� ������
timer $idlecheck(scan) ::idlecheck::scan

proc ::idlecheck::scan { } {
global idlecheck botnick
 
foreach chan $idlecheck(channels) {

  if {[channel get $chan nopubidlecheck]} { 
    return 
  }

  if {![botisop $chan]} { 
    return
  } 

  foreach nick [chanlist $chan] { 
    set hand [nick2hand $nick $chan]
      if {![matchattr $hand $idlecheck(flags)]} {
        if {($nick != $botnick) && [isvoice $nick $chan] && ([getchanidle $nick $chan] >= $idlecheck(time))} {
          putserv "MODE $chan -v $nick"
        } 
      } 
    }
}
timer $idlecheck(scan) ::idlecheck::scan

}

# ������� ��������� � ���, ��� ������ ������ ��������.
putlog "\[idlecheck\] $idlecheck(version) by $idlecheck(author) loaded"
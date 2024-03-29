###
#
#  ��������: uantiidle.tcl
#  ������: 1.0
#  �����: username 
#
###
#
# ��������: ������ ����� ��������� ���������� ������� ����� � ����� ��������� 
#          � ������������� � ���� ������, ��� �������� ���� idle-time.
#          
#
###
#
# ���������: 
#         1. ���������� ������ uantiidle.tcl � ����� scripts ������ ����.
#         2. � ����� eggdrop.conf ������� ������ source scripts/uantiidle.tcl 
#         4. �������� .rehash ����.
#
###
#
# ������� �������:
#
#              1.0(27.05.2007) ������ ������ ������. 
#
###

# ��������� ������������ ����.
namespace eval uantiidle {}

# ���������� �������� ���� ����������.
foreach p [array names uantiidle *] { catch {unset uantiidle($p) } }

###                            ###
# ���� �������� ���� ���� �����: #
# ______________________________ #
###                            ###

# ��� ���� ��������� � ����� ����� ������������ �����, ������� �������������� 
# ����� �������:
#   � ������� �������� $uantiidle(min) ������������ ��������� ����� ������ �� ���� ��
#   �������� ��������� $uantiidle(max)
# ��������� ��� ��������� �������� �� ��� ���������.
   
# ������ �������� �������(������).
set uantiidle(min) "180"
   
# ������� �������� �������(������).
set uantiidle(max) "30"

# ����� �� ������� ����� �������� ���� ������, ����� ������� ���������, �������� 
# �� ���������, �� ������� ��� �������.
set uantiidle(channels) "#testchan #testchan2"

# ������ ��������� ������� ��� ����� �������� � �����.
set uantiidle(msgs) {
"np PF Project & Evan McGregor - Choose Life (MP3@128kbps, 7.17mb)"
"np ���� - ������� ��� (MP3@128kbps, 3.63mb)"
"np U-96 - Das Boot (MP3@192kbps, 9.09mb)"
"np ����������� ������� - ���, ���������! (MP3@112kbps, 2.53mb)"
}

###                                                                  ###
# ���� ���� ����� ���������� ���, �� ��������� ��� ���� �� ������ TCL: #
# ____________________________________________________________________ #
###                                                                  ###

# ������ �������.
set uantiidle(version) "uantiidle.tcl version 1.0"

# ����� �������.
set uantiidle(author) "username"

# ��������� ������ ������ ���������.
utimer [expr $uantiidle(min) + [rand $uantiidle(max)]] uantiidleproc

# ������ ���������.
proc uantiidleproc { } {

# ��������� ���������� � ���.
variable uantiidle

# ������������ ������ �������.
foreach channel $uantiidle(channels) {

# ������� ��������� � ������ �� �������.
putserv "PRIVMSG $channel :\001ACTION [lindex $uantiidle(msgs) [rand [llength $uantiidle(msgs)]]]" 

# ��������.
}

# ����� ��������� ������, ����� ��������� ��������� ������, � �� ������������� �����. 
utimer [expr $uantiidle(min) + [rand $uantiidle(max)]] uantiidleproc

# ��������.
}

# ������� ��������� � ���, ��� ������ ������ ��������.
putlog "\[uantiidle\] $uantiidle(version) by $uantiidle(author) loaded"
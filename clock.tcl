###
#
#  ��������: clock.tcl
#  ������: 1.0
#  �����: username 
#
###
#
# ��������: ������ �� ������� ����� ����������� ���� � �����, ����� ���, ������, ....
#           ������ ������ �� �� ������ � �� ������ ������������� [clock].
#          
#
###
#
# ���������: 
#         1. ���������� ������ � ����� scripts ������ ����.
#         2. � ����� eggdrop.conf ������� ������ source scripts/clock.tcl
#         4. �������� .rehash ����.
#
###
#
# ������� �������:
#
#              1.0(30.04.2007) ������ ������ ������. 
#
###
#
# ����� ��������� ��������� � ���������(?) �������:
#
#  1. ��������� ����� ���������� � ����������� �������.
#
###

# ��������� ������������ ����.
namespace eval clock {}

# ���������� �������� ���� ����������.
foreach p [array names clock *] { catch {unset clock($p) } }

# ��������� ��������� ����.
setudef flag nopubclock

###                            ###
# ���� �������� ���� ���� �����: #
# ______________________________ #
###                            ###

# ������� ������.
set clock(pref) "!"

# ������ ������ �� ������� ����� ���������� ������.
set clock(binds) "clock ����"

###
# ��������� ������.

# �������� ���� ������.
set clock(color1) "\00314"

# ���� �������, ������, ����, ... .
set clock(color2) "\00303"
###

###                                                                  ###
# ���� ���� ����� ���������� ���, �� ��������� ��� ���� �� ������ TCL: #
# ____________________________________________________________________ #
###                                                                  ###

# ������ �������.
set clock(version) "clock.tcl version 1.0"

# ����� �������.
set clock(author) "username"

# ��������� ������.
foreach bind [split $clock(binds) " "] {
bind pub -|- "$clock(pref)$bind" clock_pub
}

# ��������� ���������, ��������� � ������ ������� � �����.
proc clock_pub {nick uhost hand chan text} {
global clock

  # ��������� ������� ����� �� ������.
  if {[channel get $chan nopubclock]} {
  return
  }

# ������ �������� ��� ������.
set weekday [clock format [unixtime] -format "%A"]

# ������ �������� ������.
set month [clock format [unixtime] -format "%B"]

# ����� ������.
set monthday [clock format [unixtime] -format "%d"]

# ����� ��� ���� (001-365).
set yearday [clock format [unixtime] -format "%j"]

# ����� ������ (01-12).
set monthnr [clock format [unixtime] -format "%m"]

# ��������� ����� � ������ ��:��:�� AM/PM.
set time [clock format [unixtime] -format "%I:%M:%S %p"]

# ���������� ����� � ������ ��:��:�� AM/PM.
set mostime [clock format [unixtime] -format "%I:%M:%S %p" -gmt +3]

# ����� ������ (01-52).
set weeknr [clock format [unixtime] -format "%W"]

# ������� ����.
set poyas [clock format [unixtime] -format "%Z"]

# ��� � �������������� �������.
set year [clock format [unixtime] -format "%Y"]

# ���������� ����� ��� ������ � �����.
set data "$clock(color1)������� $clock(color2)$weekday $clock(color2)$monthday $clock(color2)$month$clock(color1), $clock(color2)$yearday$clock(color1)-� ���� $clock(color2)$year$clock(color1)-�� ����, $clock(color2)$weeknr$clock(color1)-� ������ $clock(color2)$monthnr$clock(color1)-�� ������. ��������� �����: $clock(color2)$time$clock(color1), ������� ����: $clock(color2)$poyas$clock(color1). ���������� �����: $clock(color2)$mostime$clock(color1)."

# �������� ���������� �������� ���� ������ �� �������.
regsub -all -- {Monday} $data {�����������} data
regsub -all -- {Tuesday} $data {�������} data
regsub -all -- {Wednesday} $data {�����} data
regsub -all -- {Thursday} $data {�������} data
regsub -all -- {Friday} $data {�������} data
regsub -all -- {Saturday} $data {�������} data
regsub -all -- {Sunday} $data {�����������} data

# �������� ���������� ������ �� �������.
regsub -all -- {January} $data {������} data
regsub -all -- {February} $data {�������} data
regsub -all -- {March} $data {�����} data
regsub -all -- {April} $data {������} data
regsub -all -- {May} $data {���} data
regsub -all -- {June} $data {����} data
regsub -all -- {July} $data {����} data
regsub -all -- {August} $data {�������} data
regsub -all -- {September} $data {��������} data
regsub -all -- {October} $data {�������} data
regsub -all -- {November} $data {������} data
regsub -all -- {December} $data {�������} data

# ������� ����� � �����.
putserv "PRIVMSG $chan :$data"

# ��������� ��������.
}

# ������� ��������� � ���, ��� ������ ������ ��������.
putlog "\[clock\] $clock(version) by $clock(author) loaded"
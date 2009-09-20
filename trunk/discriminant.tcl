###
#
#  ��������: discriminant.tcl
#  ������: 1.0
#  �����: username 
#  ����: CappY :) @ http://forums.egghelp-bg.com
#
###
#
# ��������: ������ ������ ���������� ���������.
#
###
#
# ���������: 
#         1. ���������� ������ discriminant.tcl � ����� scripts ������ ����.
#         2. � ����� eggdrop.conf ������� ������ source scripts/discriminant.tcl 
#         3. �������� .rehash ����.
#
###
#
# ������� �������:
#
#              1.0(23.03.2008) ������ ������.
#
###

# ��������� ������������ ����.
namespace eval discriminant {

# ��������� ��������� ����(.chanset #chan +nopubdiscriminant ��� ���������� �������).
setudef flag nopubdiscriminant

###                            ###
# ���� �������� ���� ���� �����: #
# ______________________________ #
###                            ###

# ������� ������.
variable pref "!"

# ������ ������ �� ������� ����� ���������� ������.
variable binds "����� discriminant"

# ��������� ������ �� �������� � ������� � ����? (��-1/���-0)
variable msg 1

###
# ��������� ������.

# ���� ������.
variable color1 "\00314"

# ���� ������������� � ���������� ���������� �� ���������.
variable color2 "\00303"

# ���� ������ ���������.
variable color3 "\00312"
###

###                                                                  ###
# ���� ���� ����� ���������� ���, �� ��������� ��� ���� �� ������ TCL: #
# ____________________________________________________________________ #
###                                                                  ###

# ������ �������.
variable version "discriminant.tcl version 1.0"

# ����� �������.
variable author "username"

# ��������� ������.
foreach bind [split $binds " "] {
bind pub -|- "$pref$bind" ::discriminant::pubproc
if {$msg >= 1} {
bind msg -|- "$pref$bind" ::discriminant::msgproc
  }
}

# ��������� ��������� ��������� ������.
proc msgproc {nick uhost hand text} {
variable discriminant
::discriminant::mainproc $nick $uhost $hand $nick $text
}

# ��������� ��������� ������ ������.
proc pubproc {nick uhost hand chan text} {
variable udefflag

# ��������� ������� �����.
if {[channel get $chan $udefflag]} { 
return 
}
::discriminant::mainproc $nick $uhost $hand $chan $text
}

# ��������� ��������� �������.
proc mainproc {nick uhost hand chan text} {
variable color1
variable color2
variable color3

if {[regexp -nocase -- {(.*?)xx(.*?)x(.*?)=0} $text garb a b c]} {
set d [expr $b*$b-4*$a*$c]
if {$d<0} {
putserv "PRIVMSG $chan :$color2\002D=$d\002$color1. ������������ < 0, �������������, ��������� �� ����� �������������� ������."
return
}
set x1 [expr (-$b + sqrt($d)) / (2*$a)]
set x2 [expr (-$b - sqrt($d)) / (2*$a)]
set vid "$a\(x-$x1\)\(x-$x2\)"
set vid [string map {"--" "+" "-+" "-"} $vid]
set msg "$color2\002D=$d\002$color1\."
if {$d==0} {
lappend msg "������������ = 0, �������������, ��������� ����� ������������ ������. $color3\002X=$x1\002"
lappend msg "$color1\��� ���������� �� ��������� ���������� �������� ������ ���: $color2\002$vid"
} elseif {$d>0} {
lappend msg "������������ > 0, �������������, ��������� ����� ��� �������������� �����. $color3\002X1=$x1\002 � \002X2=$x2\002"
lappend msg "$color1\��� ���������� �� ��������� ���������� �������� ������ ���: $color2\002$vid"
}
putserv "PRIVMSG $chan :[join $msg]"
return
} else { 
putserv "PRIVMSG $chan :$color1\��������� ���� ��������� �� �������� ���������� ��� ����� ������ �� �����. ������ ����� ������: $color2\002axx+/-bx+/-c=0\002$color1\, ��� a, b � c - �������� �����."
return
}
}

# ������� ��������� � ���, ��� ������ ������ ��������.
putlog "\[discriminant\] $version by $author loaded"

}
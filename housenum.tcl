#####################################################################################################
## housenum.tcl
##
## ��������: ������� �������, ��� ����� �������� �� ������ ������������ �������, ������� ���
## ��������. ��� ����� ��������, ��� � ���� ��������, ���������� ���� � ����� �������...
## � ������� ����������, ��� ����� ���� ��� ������� � �� ����, �������� ���������� ��� � ��������,
## ��� �� �����.
##
## ���������: ����������� ������ � ����� scripts ������ ����. ��������� � eggdrop.conf �������
## source scripts/housenum.tcl
## * ������� egglib_pub.tcl
##
## ���������� ����� �� ������ �������.
##---------------------------------------------------------------------------------------------------
## �����: xamyt <xamyt@aviel.ru>
## WeNet @ #eggdrop
#####################################################################################################

# �� ����� ������ ��������.
set housenum_chans "#chan"

# ����� ������. (notice\chan\msg)
set housenum_mode "chan"

# ����������� ���������� ���������� �������� � ������.
set housenum_maxstr 450

bind pub - !��� housenum:dom
bind pub - !dom housenum:dom

proc housenum:bigstr {housenum_chan housenum_tell housenum_nick} {
global housenum_maxstr housenum_mode
if {$housenum_mode == "msg"} {set housenum_out "privmsg $housenum_nick"}
if {$housenum_mode == "chan"} {set housenum_out "privmsg $housenum_chan"}
if {$housenum_mode == "notice"} {set housenum_out "notice $housenum_nick"}
if {!($housenum_mode == "msg") && !($housenum_mode == "chan") && !($housenum_mode == "notice")} {return}
while {[string length $housenum_tell] > 0} {
if {[string length $housenum_tell] <= $housenum_maxstr || [llength [split $housenum_tell]] == 1} {putserv "$housenum_out :\00310$housenum_tell" ; break}
set msg ""
set newtext ""
set str "0"
set txt [split $housenum_tell " "]
foreach word $txt {
if {[expr [string length $msg] + [string length $word]] <= $housenum_maxstr} {
if {$str != "1"} {
set msg [concat $msg $word]
} else {set newtext [concat $newtext $word]}
} else {
set str "1"
set newtext [concat $newtext $word]
}
}
if {$msg != ""} {putserv "$housenum_out :\00310$msg"}
set housenum_tell $newtext
}
}

proc housenum:dom {nick host hand chan text} {
global housenum_chan housenum_chans housenum_tell housenum_nick
if {![string match *$chan* $housenum_chans]} {putquick "notice $nick :�� ���� ������ ���������." ; return}
if {($text == "") || !([string match "*;*" $text])} {putquick "notice $nick :\00310������� ����� ������ ����, ��������, ����� �����\00302 ��� 27, ����. 2, ��. 348 \00310���� ����� ������ ���\00304 !��� 27;2;348" ; return}
if {([string index $text 0]==";") || ([string index $text end]==";") || ([string match "*;;*" $text])} {putquick "notice $nick :\00310�� ����� \00304��������\00310 ������." ; return}
set text [::egglib::tolower $text]
set allow "1234567890�����������������;"
set kol [string length $text]
set i 0
while {$i<$kol} {
if {![string match *[string index $text $i]* $allow]} {putquick "notice $nick :\00310�� ����� \00304��������\00310 ������." ; return}
incr i
}
regsub -nocase -all {�} $text {1} text
regsub -nocase -all {�} $text {1} text
regsub -nocase -all {�} $text {2} text
regsub -nocase -all {�} $text {2} text
regsub -nocase -all {�} $text {3} text
regsub -nocase -all {�} $text {3} text
regsub -nocase -all {�} $text {4} text
regsub -nocase -all {�} $text {4} text
regsub -nocase -all {�} $text {5} text
regsub -nocase -all {�} $text {5} text
regsub -nocase -all {�} $text {6} text
regsub -nocase -all {�} $text {6} text
regsub -nocase -all {�} $text {7} text
regsub -nocase -all {�} $text {8} text
regsub -nocase -all {�} $text {8} text
regsub -nocase -all {�} $text {9} text
regsub -nocase -all {�} $text {9} text
set text [split $text ";"]
set kol [llength $text]
set i 0
set z 0
while {$i<$kol} {
set z [expr $z+[lindex $text $i]]
incr i
}
if {[string length $z]==1} {set z1 $z}
while {[string length $z]>1} {
set z [split $z ""]
set kol [llength $z]
set i 0
set z1 0
while {$i<$kol} {
set z1 [expr $z1+[lindex $z $i]]
incr i
}
set z $z1
}
switch $z1 {
1 {set housenum_chan $chan ; set housenum_nick $nick ; set housenum_tell "\002\00304$nick\,\00310\002 ���� �����\002\00302 �������.\00310\002 ����� ����� �������� ��� ��������, ������� ����� ������� ������� �����������. ������� � \"���� �������\" ������ ������ �� ����� �����, � �� �� ����� ������. �� ������ �������� ��� ���, ��� ����� ���� � ������������ �� ������ �������������, ���������� �� ����. � ���� ����� �������� ������ �����. ���� ���� ������ ������� � ������� � ������ ��� �� ��������� ������ ����� � ����� (��������, ����� �����), �� ��� ���� ���� � \"���� �������\". � ��� �� ������ ����������� ���� ��������. �� �� �� �������� � �����, �������� � �����������." ; housenum:bigstr $housenum_chan $housenum_tell $housenum_nick}
2 {set housenum_chan $chan ; set housenum_nick $nick ; set housenum_tell "\002\00304$nick\,\00310\002 ���� �����\002\00302 ������.\00310\002 ��� ��������� ��� �������� ������ �����. ����� ��� ������, �����������, ������������. ������ ������� ������ ���� �������� ���������� �����, ��� ��� ������������ �������� �������������. �� ���� ��� ���� ������ �� ������������� ��������� ������������� � ������� �����." ; housenum:bigstr $housenum_chan $housenum_tell $housenum_nick}
3 {set housenum_chan $chan ; set housenum_nick $nick ; set housenum_tell "\002\00304$nick\,\00310\002 ���� �����\002\00302 ������.\00310\002 � ���� \"����\" ������ ����. ������ �������� ��� ��������� � �����������. � ��� �������� � ����������� ������� ����� �������������. �� �������� ������ ���, ��� ������ ������ ��������." ; housenum:bigstr $housenum_chan $housenum_tell $housenum_nick}
4 {set housenum_chan $chan ; set housenum_nick $nick ; set housenum_tell "\002\00304$nick\,\00310\002 ���� �����\002\00302 ��������.\00310\002 ��� ����� �������� �������� � ���������� ��������. ���� \"���\" - ������� ����� ��� ����������� � �����, ���������� �����. �������� ������� ����� ����� ��������� ��������, ������� ������������, ������������. ��� ������ ��� ������ �����, ������� �������� ��� ����������� ������ ����. ���� \"���\" ������ �������� ���������, ������ ��� ����� \"4\" ���������� ��� ������ - �����, ������, ����, �����. �� �������� �������� ������ ��� ������������, ��� ��� ��� ����� �������� ��� ������." ; housenum:bigstr $housenum_chan $housenum_tell $housenum_nick}
5 {set housenum_chan $chan ; set housenum_nick $nick ; set housenum_tell "\002\00304$nick\,\00310\002 ���� �����\002\00302 �������.\00310\002 � ���� \"����\" ��� �������� �������. ����� � ��� - ����������� ������ �������, ������, ���������, ������� �� �����. \"���\" ����� ��� ������, �����������, ������ ��� �� ����������� ���������� ����� �������. � \"���� �������\" ���������� ����������� �����������������. �������������� �����, �������� � ���������, ����������� �����, �������� �� ��������� �������." ; housenum:bigstr $housenum_chan $housenum_tell $housenum_nick}
6 {set housenum_chan $chan ; set housenum_nick $nick ; set housenum_tell "\002\00304$nick\,\00310\002 ���� �����\002\00302 ��������.\00310\002 \"���\" �������� � ����������. ����� ��� ����� � ������ � ��� �������� ��������� ���� ������������� �����������, ���������. �������� ���������� ��������� � �������� �������. � ��� ����� ������� ������ ������� ����, ������� ����� ����� ������." ; housenum:bigstr $housenum_chan $housenum_tell $housenum_nick}
7 {set housenum_chan $chan ; set housenum_nick $nick ; set housenum_tell "\002\00304$nick\,\00310\002 ���� �����\002\00302 �������.\00310\002 \"����\" ��������� � ����������, ��� ����� ���������������� ������� ���� � ��������� ��������. ����� ������ ���, ��� ����� ���� ����, ���������� ����������, ����������. � ��� ������ ������� ���, ��� ���������� ��������� ��������� � ����, ��� �������� ����� ��������� ����. �� �������� ���, ��� ����� �������� ������������� ������, ���������� �� �����������. ������� ������� ��������� ��������������� �� �������� ���������." ; housenum:bigstr $housenum_chan $housenum_tell $housenum_nick}
8 {set housenum_chan $chan ; set housenum_nick $nick ; set housenum_tell "\002\00304$nick\,\00310\002 ���� �����\002\00302 ���������.\00310\002 ������� �����, ������� �������� �� ���� ������ �����, � ����� ��������� �������� ���������� ������, ������������ � ����� � ��������. ���� ������ �������� ������������ ���������, ��� ������ ���������� ���� ��� ������ ������. �������� ��� � ��� ���, ���� ����� ������� ���������, �������, �������, ��������� � ��������. ����� \"������\" �������� �����������, ������� ����� ������ �� � �����, � �� ������ ��������. ��� �� ��������� � � �������� ������. �� ���� ��� �� �������� �����, �� ������� ������� � ����������� ������������� ����������� ����������." ; housenum:bigstr $housenum_chan $housenum_tell $housenum_nick}
9 {set housenum_chan $chan ; set housenum_nick $nick ; set housenum_tell "\002\00304$nick\,\00310\002 ���� �����\002\00302 �������.\00310\002 ��� �������� ����� ������� ������. � ��� ������ ������������ ������ � ����������� � �����. ��, ��� � ��� �����, ����� ������ ��� ������. � \"���� �������\" ����� ������� ������� ��������. ������� �� ������ �������� ��� ���������� ����� ���������� ����. �� \"��� �������\" �������������� �����������, ��� ��� � ��� ��� ����� ������ � ���� ���������� ������, ������� � ����� ������, ��� ����� ������� ����." ; housenum:bigstr $housenum_chan $housenum_tell $housenum_nick}
}
}

putlog "housenum.tcl by xamyt loaded."
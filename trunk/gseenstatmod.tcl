# gseenstatmod.tcl
#
# ������ ����������� ������ ������ ������ ���������� ������� gseen � stats
#
# ���������:
# 1. ����������� ������ � ����� scripts.
# 2. �������� � eggdrop.conf:
# source scripts/gseenstatmod.tcl
#
# �������:
#  �� ������ :
# !seenmode <notice|channel|none>
# !statmode <notice|channel|none>
#
#  � �������:
# !seenmode <�����> <notice|channel|none>
# !statmode <�����> <notice|channel|none>

bind pub m|m "!seenmode" pub:seenmode
bind pub m|m "!statmode" pub:statmode

bind msg -|- "!seenmode" msg:seenmode
bind msg -|- "!statmode" msg:statmode

### �� ������� ������ ����, ���� �� ������ ��� �������. ��� ����� �������� �� ����������������� �������. ###

proc pub:seenmode { nick mask hand chan text } {

putlog "pub:seenmode \[$nick\] $text"

if { ![lsearch -glob [channel info $chan] *pubseen*] } {
putquick "PRIVMSG $chan :\002$nick:\002 � �� ��������� ������ gseen."
return
}

set arg [string tolower [lindex $text 0]]

if { [llength $text] == 0 } {
putquick "PRIVMSG $chan :\002$nick:\002 ��������� \002!seenmode <notice|channel|none>\002"
set mode [getseenmode $chan]
putquick "PRIVMSG $chan :\002$nick:\002 ������� �����: \002$mode\002"
return
}

if { ![string match $arg "notice"] &&
![string match $arg "channel"] && 
![string match $arg "none"] } {
putquick "PRIVMSG $chan :\002$nick:\002 �������� �����. ��������� \002!seenmode <notice|channel|none>\002"
return
}

if { $arg == "none" } { channel set $chan +nopubseens }

if { $arg == "channel" } {
channel set $chan -nopubseens
channel set $chan -quietseens
channel set $chan -quietaiseens
}

if { $arg == "notice" } {
channel set $chan -nopubseens
channel set $chan +quietseens
channel set $chan +quietaiseens
}

savechannels

putquick "PRIVMSG $chan :\002$nick:\002 seen ����������� � �����: \002$arg\002"

}

proc msg:seenmode { nick mask hand text } {

set chan [lindex $text 0]

putlog "msg:seenmode \[$nick\] $text"

if {![matchattr $hand m|m $chan]} {
return 0
} else {
if {[llength $text] < 1} {
putquick "PRIVMSG $nick :��������� \002!seenmode <�����> <notice|channel|none>\002"
return 0
}
}

if {![validchan $chan]} {
putquick "PRIVMSG $nick :������, �� � �� ���������� ����� \002$chan\002..."
return 0
} else {
if {[channel get $chan inactive]} {
putquick "PRIVMSG $nick :������, �� ����� \002$chan\002 ��������� � ������ \002inactive\002..."
return 0
}
}

set arg [string tolower [lindex $text 1]]

if { [llength $arg] == 0 } {
putquick "PRIVMSG $nick :��������� \002!seenmode <�����> <notice|channel|none>\002"
set mode [getseenmode $chan]
putquick "PRIVMSG $nick :������� �����: \002$mode\002"
return
}

if { ![string match $arg "notice"] &&
![string match $arg "channel"] && 
![string match $arg "none"] } {
putquick "PRIVMSG $nick :�������� �����. ��������� \002!seenmode <notice|channel|none>\002"
return
}

if { $arg == "none" } { channel set $chan +nopubseens }

if { $arg == "channel" } {
channel set $chan -nopubseens
channel set $chan -quietseens
channel set $chan -quietaiseens
}

if { $arg == "notice" } {
channel set $chan -nopubseens
channel set $chan +quietseens
channel set $chan +quietaiseens
}

savechannels

putquick "PRIVMSG $nick :seen ����������� � �����: \002$arg\002"

}

proc pub:statmode { nick mask hand chan text } {

putlog "pub:statmode \[$nick\] $text"

if { ![lsearch -glob [channel info $chan] *pubstat*] } {
putquick "PRIVMSG $chan :\002$nick:\002 � �� ��������� ������ stats."
return
}

set arg [string tolower [lindex $text 0]]

if { [llength $text] == 0 } {
putquick "PRIVMSG $chan :\002$nick:\002 ��������� \002!statmode <notice|channel|none>\002"
set mode [getstatmode $chan]
putquick "PRIVMSG $chan :\002$nick:\002 ������� �����: \002$mode\002"
return
}

if { ![string match $arg "notice"] &&
![string match $arg "channel"] && 
![string match $arg "none"] } {
putquick "PRIVMSG $chan :\002$nick:\002 �������� �����. ��������� \002!statmode <notice|channel|none>\002"
return
}

if { $arg == "none" } { channel set $chan +nopubstats }

if { $arg == "channel" } {
channel set $chan -nopubstats
channel set $chan -quietstats
}

if { $arg == "notice" } {
channel set $chan -nopubstats
channel set $chan +quietstats
}

savechannels

putquick "PRIVMSG $chan :\002$nick:\002 stat ����������� � �����: \002$arg\002"

}

proc msg:statmode { nick mask hand text } {

set chan [lindex $text 0]

putlog "msg:statmode \[$nick\] $text"

if {![matchattr $hand m|m $chan]} {
return 0
} else {
if {[llength $text] < 1} {
putquick "PRIVMSG $nick :��������� \002!statmode <�����> <notice|channel|none>\002"
return 0
}
}

if {![validchan $chan]} {
putquick "PRIVMSG $nick :������, �� � �� ���������� ����� \002$chan\002..."
return 0
} else {
if {[channel get $chan inactive]} {
putquick "PRIVMSG $nick :������, �� ����� \002$chan\002 ��������� � ������ \002inactive\002..."
return 0
}
}

set arg [string tolower [lindex $text 1]]

if { [llength $arg] == 0 } {
putquick "PRIVMSG $nick :��������� \002!statmode <�����> <notice|channel|none>\002"
set mode [getstatmode $chan]
putquick "PRIVMSG $nick :������� �����: \002$mode\002"
return
}

if { ![string match $arg "notice"] &&
![string match $arg "channel"] && 
![string match $arg "none"] } {
putquick "PRIVMSG $nick :�������� �����. ��������� \002!statmode <notice|channel|none>\002"
return
}

if { $arg == "none" } { channel set $chan +nopubstats }

if { $arg == "channel" } {
channel set $chan -nopubstats
channel set $chan -quietstats
}

if { $arg == "notice" } {
channel set $chan -nopubstats
channel set $chan +quietstats
}

savechannels

putquick "PRIVMSG $nick :stat ����������� � �����: \002$arg\002"

}

proc getseenmode { sechan } {

if { [channel get $sechan nopubseens] } {
return none
} else {
if { [channel get $sechan quietseens] || [channel get $sechan quietaiseens]} {
return notice
} else {
return channel
}
}

}

proc getstatmode { sechan } {

if { [channel get $sechan nopubstats] } {
return none
} else {
if { [channel get $sechan quietstats] } {
return notice
} else {
return channel
}
}

}

putlog "seenstatmod.tcl 1.0 by mrBuG <mrbug@eggdrop.org.ru> loaded"

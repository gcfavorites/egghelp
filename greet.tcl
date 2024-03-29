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
# greet.tcl 2.1
#
# Author: Shrike <shrike@eggdrop.org.ru> and mrBuG <mrbug@eggdrop.org.ru>
#
# Special thank ����� <sunbeampro@mail.ru> [bugs report and fixed]
#
# official support channel : irc.eggdrop.org.ru @ #eggdrop
#
#####################################################################################
#
# ������ �������� �����������, ��� ������ ������������ �� �����;)
#
# ���������:
# 1. ����������� ������ � ����� scripts.
# 2. �������� � eggdrop.conf:
# source scripts/greet.tcl
#
# �������:
#  �� ������ : 
# !greet <�����������>
# !greetmode <notice|channel|none>
# !greetnow
#
#  � �������:
# !greet <�����> <�����������>
# !greetmode <�����> <notice|channel|none>
#
#####################################################################################
# Version History:
#	
#  		SHR - Shrike
#		BUG - mrBuG
# v2.1			
#   	SHR		040711	Fixed damn error:
#							[07:18] Tcl error [::changreet::greet_pub_mode]: 
#							invalid command name "::changreet::greet_pub_mode"
#							It was a trouble with namespace.
#						Fixed error when greet-mode not setted by default to none.
# v2.0			
#   	BUG		040705	Added this header ;)
#						Refacored for namespace usage
#						Added additional command !greetnow
#
#####################################################################################
# Last version of egglib_pub can be grabbed here:
# http://eggdrop.org.ru/scripts/egglib.zip

if { ![info exists egglib(ver)] } {
	putlog "***********************************************"
	putlog "             egglib_pub NOT FOUND !"
	putlog "   Download last version of egglib_pub here:"
	putlog "  http://eggdrop.org.ru/scripts/egglib_pub.zip"
	putlog "***********************************************"	
	die
}

if { [expr {$egglib(ver) < 1.4}] } {
	putlog "***********************************************"
	putlog " YOUR VERSION OF egglib_pub IS TOO OLD !"
	putlog "   Download last version of egglib_pub here:"
	putlog "  http://eggdrop.org.ru/scripts/egglib_pub.zip"
	putlog "***********************************************"
	putlog " version installed : $egglib(ver)"
	putlog " version required: 1.4"
	die
}

namespace eval changreet {}

setudef str greet-mode
setudef str changreet

bind join - * ::changreet::greet_pub_join  

bind pub m|m 	!greet 				::changreet::greet_pub_add
bind pub m|m 	!greetmode 			::changreet::greet_pub_mode
bind pub m|m 	!greetnow 			::changreet::greet_pub_now

bind msg -|- 	!greet 				::changreet::greet_msg_add
bind msg -|- 	!greetmode 			::changreet::greet_msg_mode

bind dcc n|-	+chan				::changreet::greet_add_chan

foreach p [array names greet *] { catch {unset greet($p) } }

set greet(ver) 		"2.1"
set greet(authors) 	"mrBuG <mrbug@eggdrop.org.ru> and Shrike <shrike@eggdrop.org.ru>"

### �� ������� ������ ����, ���� �� ������ ��� �������. ��� ����� �������� �� ����������������� �������. ###

proc ::changreet::check_chans { } {

	foreach greetchan [channels] {
		set mode [channel get $greetchan greet-mode]
		if { ![string match "notice" $mode] &&
			 ![string match "channel" $mode] &&
			 ![string match "none" $mode] } {
			channel set $greetchan greet-mode none
			putlog "\[changreet\] Setting default greet-mode for channel $greetchan to none"
			return
		}
	}
}

utimer 2 ::changreet::check_chans

#####################################################################################

proc ::changreet::greet_pub_add { nick mask hand chan text } {

	if { ! [::changreet::greet_active $chan] } return
	::egglib::publog $nick $chan "greet" "$text"

	if { [llength $text] < 1 } {
		::egglib::outhc $nick $chan "!greet" "<�����������>"
		::changreet::greet_outr $chan "NOTICE" $nick
		return
	}

	channel set $chan changreet [::egglib::colors_to_meta $text]
	::egglib::outc $nick $chan "\0032����������� ��� ������ \0036$chan\0032 ��������.\003"
	savechannels
}

proc ::changreet::greet_msg_add { nick mask hand arg } {

	set chan [lindex $arg 0]

	::egglib::msglog $nick "greet" "$arg"

	if { ![matchattr $hand m|m $chan] } {
		return
	} else {

		if { [llength $arg] < 1 } {
			::egglib::outhm $nick "!greet" "<�����> <�����������>"
			return
		}

		if { ![validchan $chan] } {
			::egglib::outm $nick "\0032������, �� � �� ���������� ����� \0036$chan\0032...\003"
			return
		} else {
			if { [channel get $chan inactive] } {
				::egglib::outm $nick "\0032������, �� ����� \0036$chan\0032 ��������� � ������ \00312inactive\0032...\003"
				return
			}
		}

		if { ! [::changreet::greet_active $chan] } {
			::egglib::outm $nick "\0032������, �� ����������� �� ������ \0036$chan\0032 ��������� � ������ \00312none\0032...\003"
			::egglib::outhm $nick "!greet" "<�����> <notice|channel|none>"
			return
		}

	}

	set text [lrange $arg 1 end]

	if { $text == "" } {
		::egglib::outhm $nick "!greet" "<�����> <�����������>"
		::changreet::greet_outr $chan "PRIVMSG" $nick
		return
	}

	channel set $chan changreet [::egglib::colors_to_meta $text]
	::egglib::outm $nick "\0032����������� ��� ������ \0036$chan\0032 ��������.\003"
	savechannels
}

proc ::changreet::greet_pub_mode { nick mask hand chan text } {

	::egglib::publog $nick $chan "greetmode" "$text"

	set arg [::egglib::tolower [lindex $text 0]] 

	if { [llength $text] == 0 } {
		::egglib::outhc $nick $chan "!greetmode" "<notice|channel|none>"
		set mode [channel get $chan greet-mode]
			::egglib::outc $nick $chan "������� �����:\0035 $mode\003."
			return
	}

	if { ![string match "notice" $arg] &&
		 ![string match "channel" $arg] &&
		 ![string match "none" $arg] } {
		::egglib::outc $nick $chan "�������� �����. ��������� \0034!greetmode\0035 <notice|channel|none>\003"
		return
	}

	channel set $chan greet-mode $arg
	savechannels
	
	::egglib::outc $nick $chan "\0032����������� ����������� � �����: \00312$arg\003."

}

proc ::changreet::greet_msg_mode {nick mask hand text} {

	set chan [lindex $text 0]

	::egglib::msglog $nick "greetmode" "$text"

	if { ![matchattr $hand m|m $chan] } {
		return
	} else {
		if { [llength $text] < 1 } {
			::egglib::outhm $nick "!greetmode" "<�����> <notice|channel|none>"
			return
		}
	}

	if { ![validchan $chan] } {
		::egglib::outm $nick "\0032������, �� � �� ���������� ����� \0036$chan\0032...\003"
		return
	} else {
		if { [channel get $chan inactive] } {
			::egglib::outm $nick "\0032������, �� ����� \0036$chan\0032 ��������� � ������ \00312inactive\0032...\003"
			return
		}
	}

	set arg [egglib::tolower [lindex $text 1]] 

	if { [llength $arg] == 0 } {
		::egglib::outhm $nick "!greetmode" "<�����> <notice|channel|none>"
		set mode [channel get $chan greet-mode]
		::egglib::outm $nick "������� �����:\0035 $mode\003."
		return
	}

	if { ![string match "notice" $arg] &&
		 ![string match "channel" $arg] &&
		 ![string match "none" $arg] } {
		::egglib::outm $nick "�������� �����. ��������� \0034!greetmode\0035 <notice|channel|none>\003"
		return
	}

	channel set $chan greet-mode $arg
	savechannels

	::egglib::outm $nick "\0032����������� ����������� � �����: \00312$arg\003."

}

proc ::changreet::greet_pub_now { nick uhost hand chan text } {
	if { ![::changreet::greet_active $chan] } { return }

	::egglib::outn $nick "[channel get $chan changreet]"

	::egglib::outn $nick "====="

	set chgreet [channel get $chan changreet]

	if { [string match *~* $chgreet] } {
		set chgreet [split $chgreet ~]
		foreach cgreet $chgreet {
			::egglib::outn $nick "[::changreet::greet_rep $cgreet $nick $uhost $hand $chan]"
		}
	} else {	
		::egglib::outn $nick "[::changreet::greet_rep $chgreet $nick $uhost $hand $chan]"
	}


}

proc ::changreet::greet_pub_join { nick uhost hand chan } {

	if { ![::changreet::greet_active $chan] || [matchattr [nick2hand $nick $chan] b] || [matchattr [nick2hand $nick $chan] N] } { return }
	set chgreet [channel get $chan changreet]

	if { $hand != "" && $hand != "*" } {
		set laston [getuser $hand laston $chan]
		if { $laston != 0 && [unixtime] - $laston < 1200 } { return } 
		set flags [chattr $hand |- $chan]
	}

	if { ![::changreet::greet_notice $chan] } {
		set greetout "PRIVMSG"
		set choutput $chan
	} else {
		set greetout "NOTICE"
		set choutput $nick
	}

	if { [string match *~* $chgreet] } {
		set chgreet [split $chgreet ~]
		foreach cgreet $chgreet {
			putserv "$greetout $choutput :[::changreet::greet_rep $cgreet $nick $uhost $hand $chan]"
		}
	} else {	
		putserv "$greetout $choutput :[::changreet::greet_rep $chgreet $nick $uhost $hand $chan]"
	}

}

proc ::changreet::greet_add_chan { hand idx args } {
	*dcc:+chan $hand $idx $args
	catch {channel set $args greet-mode none}
}

#####################################################################################

proc ::changreet::greet_rep { data nick uhost hand chan } {
	global botnick

	regsub -all -- %nick $data $nick data 
	regsub -all -- %uhost $data $uhost data
	regsub -all -- %botnick $data $botnick data
	regsub -all -- %hand $data $hand data
	regsub -all -- %chan $data $chan data

	set data [::egglib::meta_to_colors $data]

	return $data
}

proc ::changreet::greet_active { chan } {
  	set mode [channel get $chan greet-mode]
  	if { ![string match $mode "none"] } {
  		if { [string match $mode "notice"] || [string match $mode "channel"] } { return 1}
 	}
 	return 0
}

proc ::changreet::greet_notice { chan } {
	set mode [channel get $chan greet-mode]
	if { [string match $mode "notice"] } { return 1 }
	return 0
}

proc ::changreet::greet_outr { chan output outfrom } {

	putserv "$output $outfrom :� ����������� ��������� ��������� ������:"
	putserv "$output $outfrom :    \002%nick\002     - ����� �������� �� ��� ���������"
	putserv "$output $outfrom :    \002%uhost\002    - ����� �������� �� ���� ���������"
	putserv "$output $outfrom :    \002%botnick\002  - ����� �������� �� ��� ����"
	putserv "$output $outfrom :    \002%hand\002     - ����� �������� �� handle ���������"
	putserv "$output $outfrom :    \002%chan\002     - ����� �������� �� �������� ������"
	putserv "$output $outfrom :    \002%c\002        - ����"
	putserv "$output $outfrom :    \002%b\002        - ������"
	putserv "$output $outfrom :    \002%u\002        - �������������"
	putserv "$output $outfrom :    \002%i\002        - ��������"
	putserv "$output $outfrom :    \002%k\002        - ����� �����"
	putserv "$output $outfrom :    \002~\002         - ����� ������"

	set chgreet [channel get $chan changreet]
	set chgreet [::egglib::colors_to_meta $chgreet]

	if { $chgreet != "" } {
		putserv "$output $outfrom :\002������� �����������:\002 $chgreet"
	}
}

putlog "greet.tcl v$greet(ver) by $greet(authors) loaded"
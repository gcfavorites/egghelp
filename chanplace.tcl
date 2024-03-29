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
# chanplace 2.3
#
# Description:
#	Displays channel place based on /LIST
#
# Authors: Shrike <shrike@eggdrop.org.ru>
#
# Special Thanks to:
#	CoolCold <coolcold@coolcold.org> for describing how to use namespaces.
#
# Official support: irc.eggdrop.org.ru @ #eggdrop
# 
#####################################################################################
#
# Version History:
#	
#  		SHR - Shrike
#	
#		Who		DATE	Changes
#   	---     ------  -------------------------------------------------------------
# v2.3
#   	SHR		050116	Fixed regexps. Channel '#' not matched.
#						Added .chanplace in partyline
#
# v2.2
#   	SHR		040615	Added this header ;)
#						Added case-insensitive channel matching (thanks to sunbeam)
#						Fixed output of !chanplace number where color eated numbers
#						Remover 'required egglib_pub' which crashed bot after .rehash
#
#####################################################################################
# Last version of egglib_pub can be grabbed here:
# http://eggdrop.org.ru/scripts/egglib.zip

if { ![info exists egglib(ver)] || [expr {$egglib(ver) < 1.2}] } {
	putlog "***********************************************"
	putlog "   egglib_pub NOT FOUND OR VERSION IS TOO OLD!"
	putlog "   Download last version of egglib_pub here:"
	putlog "  http://eggdrop.org.ru/scripts/egglib_pub.zip"
	putlog "***********************************************"
}

foreach bind [binds "::chanplace::*"] { catch {unbind [lindex $bind 0] [lindex $bind 1] [lindex $bind 2] [lindex $bind 4]} }

namespace eval chanplace {}

bind pub - !chanplace ::chanplace::pub
bind msg - !chanplace ::chanplace::msg
bind dcc - chanplace 	::chanplace::dcc

bind raw - "322" ::chanplace::addlist
bind raw - "323" ::chanplace::endlist

set chanplace(getlist) 0
set chanplace(cmd) "LIST"
set chanplace(alt_cmd) "LIST *"
set chanplace(ver) "2.3"
set chanplace(authors) "Shrike <shrike@eggdrop.org.ru>"

catch { unset chanplace(channels) }
catch { unset chanplace(queue) }

setudef flag nopubchanplace


proc ::chanplace::dcc {hand idx args} {
	global chanplace
	set nick "dcc:$idx"
	::egglib::log $hand $idx "chanplace" $args
	if { [string trim [lindex $args 0]] == "" } {
		::egglib::outh $nick $nick ".chanplace" "<#�����>"
		return
	}
	
	lappend chanplace(queue) [list $nick $nick [string trim [lindex $args 0]]]

	if { $chanplace(getlist) == 1 } { return }
	
	set chanplace(getlist) 1
	
	putquick "$chanplace(cmd)"
}

proc ::chanplace::msg { nick uhost hand args } {
	global chanplace
	
	::egglib::log $nick $nick "chanplace" $args
	
	if { [string trim [lindex $args 0]] == "" } {
		::egglib::outh $nick $nick "!chanplace" "<#�����>"
		return
	}
	
	lappend chanplace(queue) [list $nick $nick [string trim [lindex $args 0]]]

	if { $chanplace(getlist) == 1 } { return }
	
	set chanplace(getlist) 1
	
	putquick "$chanplace(cmd)"
}

proc ::chanplace::pub { nick uhost hand chan args } {
	global chanplace
	
	if {[channel get $chan nopubchanplace]} return
	::egglib::log $chan $nick "chanplace" $args
	
	lappend chanplace(queue) [list $chan $nick [string trim [lindex $args 0]]]

	if { $chanplace(getlist) == 1 } { return }
	
	set chanplace(getlist) 1
	
	putquick "$chanplace(cmd)"
}

proc ::chanplace::addlist {from key text} {
	global chanplace
	
	if { $chanplace(getlist) != 1 } { return }
	
	if { [regexp -nocase -- {[^\ ]+\ \#[^\ ]*\ [^\ ]+\ :\[.+\].*} $text] } {
		if { [regexp -nocase -- {[^\ ]+\ (\#[^\ ]*)\ ([^\ ]+)\ :\[(.+)\].*} $text trash chan users mode] } {
			set chan [string trim $chan]
			set users [string trim $users]
			if { $chan != "" } {
				lappend chanplace(channels) [list $users $chan]
			}
		}
	} else {
		if { [regexp -nocase -- {[^\ ]+\ (\#[^\ ]*)\ ([^\ ]+)\ :.*} $text trash chan users] } {
			set chan [string trim $chan]
			set users [string trim $users]
			if { $chan != "" } {
				lappend chanplace(channels) [list $users $chan]
			}
		}
	}
}

proc ::chanplace::endlist {from key text} {
	global chanplace
	
	if { ! [info exists chanplace(channels)] } {
		if { [string equal $chanplace(cmd) $chanplace(alt_cmd)] } {
			putlog "\[chanplace\] Failed to get LIST of channles."
			putlog "\[chanplace\] Try to modify chanplace(cmd)"
			catch { unset chanplace(channels) }
			catch { unset chanplace(queue) }
			return
		}
		set chanplace(cmd) $chanplace(alt_cmd)
		putquick "$chanplace(cmd)"
		return
	}
	
	set chanplace(getlist) 0
	set chanplace(channels) [lsort -command ::chanplace::sort $chanplace(channels)]
	
	set total [llength $chanplace(channels)]
	
	foreach q $chanplace(queue) {
		set chan [lindex $q 0]
		set nick [lindex $q 1]
		set req  [lindex $q 2]

		if { $req == "" } { set req $chan }
		
		set num 1
		set found 0
		foreach ch $chanplace(channels) {
			if { [string equal [::egglib::tolower $req] [lindex [::egglib::tolower $ch] 1]] } {
				set found 1
				set users [lindex $ch 0]
				::egglib::out $nick $chan "\0032����� \0036\002\002$req\0032 �������� \0034\002\002$num\0032/\0035\002\002$total\0032 �����, �� ��� ������ \00312\002\002$users\0032 �������(�)...\003"
				break
			}
			set num [expr $num + 1]
		}
		
		if { !$found } {
			::egglib::out $nick $chan "\0032������ \0036\002\002$req\0032 � ������ ������� ���...\003"
		}
	}
	unset chanplace(channels)
	unset chanplace(queue)
}

proc ::chanplace::sort { a b } {
	if { [lindex $a 0] > [lindex $b 0] } {return -1}
	if { [lindex $a 0] < [lindex $b 0] } {return 1}
	
	return [string compare [lindex $a 1] [lindex $b 1]]
}

putlog "chanplace.tcl $chanplace(ver) by $chanplace(authors) loaded"


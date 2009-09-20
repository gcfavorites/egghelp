# channel rules managment script 
# $Id:	rules.tcl v 1.0b6 02.07.2004 02.56AM CoolCold Exp $

# This script features such abilities:
# * each channel has it's own set of rules
# * bot owner can enable/disable use of this script for certain channels with
#   .chanset #chan +rules or .chanset #chan -rules from partyline
# * U may enable/disable displaying rules on join
# * U may set who mustn't see rules on join ( +o/+m recommended )
# * Customizable access rights for add/del/move commands
# * Features are documentated!!!
# * And much more - it's free for use!

# General info:
# version:1.0b6
# Author: CoolCold <coolcold at coolcold.org>
# #rea@irc.coolcold.org:6667
#
#
#  __    __  __    _           _    
# \  \  /  /|  \  | |         | |   
#  \  \/  / |   \ | |  ____  _| |_  
#   \    /  | |\ \| | /  _ \|_   _| 
#   /    \  | | \   | | /_\/  | |   
#  /  /\  \ | |  \  | | \__   | |__ 
# /__/  \__\|_|   \_| \____/  \___/ 
#
# http://xnet.net.ru irc://xnet.net.ru
#
#
# with help of
#
#		:::[  T h e   R u s s i a n   E g g d r o p  R e s o u r c e  ]::: 
#      ____                __                                                      
#     / __/___ _ ___ _ ___/ /____ ___   ___      ___   ____ ___ _     ____ __ __   
#    / _/ / _ `// _ `// _  // __// _ \ / _ \    / _ \ / __// _ `/    / __// // /   
#   /___/ \_, / \_, / \_,_//_/   \___// .__/ __ \___//_/   \_, / __ /_/   \___/    
#        /___/ /___/                 /_/    /_/           /___/ /_/                
#
#
# Created with FAR ( http://www.farmanager.com )
# and colorer ( http://colorer.sf.net )
#
#
# Requirements:
# eggdrop (windrop) 1.6.15,tcl 8.4.5 (8.3.4),alltools.tcl

# Arrays unsetting idea by Shrike < shrike at eggdrop.org.ru >
# #eggdrop@RusNet (irc.mv.ru irc.rinet.ru)
# #eggdrop@XNet(rus) (irc.xnet.net.ru irc.coolcold.org)

# Using:
# First of all,take a look on settings such as flags and triggers,
# change them to meet your needs ( default values should be ok )
# Pay attention to setting usefast - if ur bot is exempted from 
# flood limits on ircd ( ircop or other way ) u may found this setting useful
#
# To enable script to work on certain channel do .chanset #chan +rules
# Commands' syntax help is available through public "!rules" command on channel
# Brief characteristics of commands:
#
# !addrule <text> - adds rule to channel rules list
# !delrule <index> - deletes <index> from rules list
# !moverule <from_index> <to_index> - moves rule from <from_index> to <to_index>
# !listrules [#chan/nick] - lists rules for current channel or for #chan,
# if you have access to #chan,or for nick if nick is on current channel
# !showrules <on/off> - enables or disables printing rules for joining users
# !rules [params] - lists rules for those who hasn't access to script commands
# or shows help for available commands to person who has some access flags


###########################
#       Changelog         
# === version 1.0b5 ===
# [+]added changelog
# [+]added force read of rules for some person
# [+]added "!rules version" command - prints version
# [+]added setting for disabling eggdrop selfflood protection
# [+]added metachars for colors:
# %b=bold,%c<num>=color<num>,%u=underlined,%i=inversed,$k=color reset
# [!]changed file name from rules.txt to rules.${bot-nick}.txt
###########################

# declaring namespace chanrule for storing global variables
namespace eval chanrule {
##############################
#   Configuration section    #
##############################

	#not display to flag defines what users shouldn't see channel 
	#rules on join (it's assumed they know them already)
	#set this to not used flag to disable
	set ndt_flag "-|+o"
	
	#who can delete rules flags
	set del_flags "+n|+m"
	
	#who can add rules flags
	set add_flags "+n|+m"
	
	#who can enable/disable display of channel rules on join
	set show_flags "+n|+m"
	
	#who can list rules on other channels ( remote view )
	set listother_flags "+m|+m"
	
	#filename to store rules
	set fname "rules.${botnet-nick}.txt"
	
	#add rule command
	set trigadd "!addrule"
	
	#del rule command
	set trigdel "!delrule"
	
	#move up rule command
	set trigmove "!moverule"
	
	#list rules command
	set triglist "!listrules"
	
	#show rules on join on/off command
	set trigshow "!showrules"
	
	#general rules info/help command
	set triginfo "!rules"
	
	#disable eggdrop's built-in selfflood control?
	#set value to 0 to disable
	set usefast "0"

##############################
# do not edit anything below #
##############################


	set chans(names) ""
	set rules(names) ""
#	unsetting rules array - thanks to Shrike < shrike at eggdrop.org.ru > for this code
	foreach b [array names rules *] {
    		catch {unset rules($b)}
  	}

#	version info
	set ver "1.0b6"
	set info "Channel rules script by CoolCold <coolcold at coolcold.org>"
	set infoline "$info version $ver"

    #"speeding up" eggdrop
    proc putfast {text} {
    #thanks to Takeda <takeda at eggheads.w.pl> for pointing to putdccraw
    	
    	#normally strings shouldn't end with \n,so appending \n is ok
    	append text "\n"
    	putdccraw 0 [string length $text] $text
    }

    #let's create our own putserv ;)
	proc putserv { text } {
	variable usefast		
		if {$usefast=="1"} {
			putfast $text
		} else {
			#using :: to refer to root namespace
			#u can see power of namespaces here \m/
			::putserv $text
		}
	}
}

proc ::chanrule::init { } {
setudef flag rules
setudef flag showrules
::chanrule::loadrules
return 0
}

proc ::chanrule::loadrules { } {
variable fname;variable delimiter;variable chans;variable rules
        if {[file exists $fname]} {
            	set fid [open $fname r ]
                set c "0"
                while {![eof $fid]} {
                    gets $fid l; if {$l == ""} {continue}
		     		set chname "[lindex [split $l ] 0]"
		     		set chrules [string range $l [expr [string length $chname] + 1] end]
		     		lappend chans(names) $chname
		     		set rules($chname) $chrules
                    incr c
        		}
        	close $fid
        	putlog "Channel Rules:Total $c channels loaded"
	} else {
		putlog "Channel Rules:Cannot find rules file \"$fname\",starting with new one"
	}
return 0
}

proc ::chanrule::save { } {
variable fname;variable delimiter;variable chans;variable rules
    if {![file exists $fname]} {set fid [open $fname w];puts $fid "";close $fid}
	if {[llength chans(names)]>0} {
		set fid [open $fname "TRUNC RDWR"]
		foreach {i} $chans(names) {
			puts $fid "$i $rules($i)"
		}
		flush $fid
		close $fid
	}
return 0
}

proc ::chanrule::listrules { nick uhost hand chan rest } {
variable chans;variable rules;variable listother_flags
variable show_flags
global botnick
	set chan [string tolower $chan]
	set rest [string tolower $rest]
	if {![info exists chans(names)]} {return 0}
	if {$rest==""} {
        	set i [lsearch -exact $chans(names) $chan]
        	if {$i=="-1"} {
        		if {[matchattr $hand $show_flags $chan]} {
        			putserv "NOTICE $nick :There are no rules set for $chan"
        		}
        	} else {
        		set c 0
        		putserv "NOTICE $nick :Rules for channel $chan"
        		foreach j $rules($chan) {
        			incr c
        			set j [meta_to_colors $j]
        			putserv "NOTICE $nick :$c) $j"
        		}
        	}
	} else	{
		set displayed "0"
		switch -exact -- [string tolower [string range $rest 0 0]]\
			"&" -\
			"#" {
				#normal and local channels
				#see RFC 1459 for channels definition
        		if {[matchattr $hand $listother_flags $rest]} {
                	if {[lsearch -exact $chans(names) $rest]!="-1"} {
                		set c 0
                		putserv "NOTICE $nick :Rules for channel $rest"
                		foreach j $rules($rest) {
                			incr c
                			set j [meta_to_colors $j]
                			putserv "NOTICE $nick :$c) $j"
                		}
        			} else {putserv "NOTICE $nick :There are no rules set for $rest"}
        		}

			}\
			default {
				#assuming rest is nickname
        		if {[matchattr $hand $show_flags $chan]} {
        			#displaying rules to some person
        			#need check if nick exists on some channel the bot is on,to prevent
        			#messaging to users who are not on our channel
        			set bnick [string tolower $botnick]
        			set rest [lindex [split $rest ] 0]
        			set rest [string tolower $rest]
        			if {([onchan $rest $chan]) && ($rest!=$bnick)} {
        				#person found
                		if {[lsearch -exact $chans(names) $chan]!="-1"} {
                			set c 0
                			putserv "NOTICE $rest :You were forced to read rules for channel $chan"
                			foreach j $rules($chan) {
                				incr c
                				set j [meta_to_colors $j]
                				putserv "NOTICE $rest :$c) $j"
                			}
        				} else { putserv "NOTICE $nick :There are no rules set for $chan,forced reading of rules for \"$rest\" failed"}
        				
        			} else {
        				putserv "NOTICE $nick :Forced reading of rules of channel $chan for \"$rest\" failed due to \"$rest\" is not on $chan or isn't valid nickname"
        			}
        		}

			}
	}
return 0
}


proc ::chanrule::addrule { nick uhost hand chan rest } {
variable chans;variable rules;variable add_flags
	set chan [string tolower $chan]
#let's check access rights & is this channel +rules enabled
	if {![matchattr $hand $add_flags $chan]} {return 0}
	if {![channel get $chan rules]} {
		putserv "NOTICE $nick :channel $chan hasn't got +rules flag"
		return 0
	}
	
	if {$rest==""} {putserv "NOTICE $nick :Empty rule,discarding";return 0}
	set i [lsearch -exact $chans(names) $chan]
	if {$i=="-1"} {
		lappend chans(names) $chan
	}
	#replacing colors with tokens
	set rest [colors_to_meta $rest]
	lappend rules($chan) "$rest"
	putserv "NOTICE $nick :Rule \"$rest\" for channel $chan added"
::chanrule::save
return 0
}

proc ::chanrule::delrule { nick uhost hand chan rest } {
variable chans;variable rules;variable del_flags
	set chan [string tolower $chan]
#let's check access rights & is this channel has +rules enabled

	if {![matchattr $hand $del_flags $chan]} {return 0}
	if {![channel get $chan rules]} {
		putserv "NOTICE $nick :Channel $chan hasn't got +rules flag";return 0
	}
	set i [lsearch -exact $chans(names) $chan]
	if {$i=="-1"} {
		putserv "NOTICE $nick :There are no record for channel $chan ,can't delete, try add some rules first"
	} else {
		if {[lindex $rules($chan) [expr $rest - 1]]==""} {
			putserv "NOTICE $nick :no such index $rest"
		} else {
			set tmprule [lindex $rules($chan) [expr $rest - 1]]
			set rules($chan) [lreplace $rules($chan) [expr $rest - 1] [expr $rest - 1]]
			putserv "NOTICE $nick :Removed rule #$rest for channel $chan ( $tmprule )"
			if {[llength $rules($chan)]=="0"} {
				set chans(names) [lreplace $chans(names) $i $i]
				unset rules($chan)
				channel set $chan -showrules
				putserv "NOTICE $nick :channel $chan removed from rules list cuz it has no rules left"
			}
			::chanrule::save
		}
	}

return 0

}

proc ::chanrule::showrules { nick uhost hand chan rest } {
variable chans;variable rules;variable show_flags
        set chan [string tolower $chan]
        if {![matchattr $hand $show_flags $chan]} {return 0}
        if {![info exists chans(names)] || ![channel get $chan rules] || ![info exists rules($chan)]} {
        	putserv "NOTICE $nick :Channel $chan has no rules set or channel hasn't +rules"
        	return 0
        }
        if {$rest=="on"} {
        	channel set $chan +showrules
        	putserv "PRIVMSG $chan :Displaying of channel rules now is: on"
        } elseif {$rest=="off"} {
        	channel set $chan -showrules
        	putserv "PRIVMSG $chan :Displaying of channel rules now is: off"
        } else {
        	if {[channel get $chan showrules]} {set bla "on"} else {set bla "off"}
        	putserv "PRIVMSG $chan :Displaying of channel rules is:$bla"
        }

return 0
}

proc ::chanrule::rulemove { nick uhost hand chan rest } {
global lastbind
variable chans;variable rules;variable del_flags;variable add_flags
	set chan [string tolower $chan]
	#let's check access rights & is this channel has +rules enabled

	if {!([matchattr $hand $del_flags $chan] || [matchattr $hand $add_flags $chan])} {return 0}
	if {![channel get $chan rules]} {
		putserv "NOTICE $nick :Channel $chan hasn't got +rules flag";return 0
	}
	set i [lsearch -exact $chans(names) $chan]
	if {$i=="-1"} {
		putserv "NOTICE $nick :There are no record for channel $chan ,can't move any rule, try add some rules first"
	} else {
		set ruleindx [lindex [split $rest " "] 0];set mvtoindx [lindex [split $rest " "] 1]
		if {![isnumber $ruleindx] || ![isnumber $mvtoindx]} {putserv "NOTICE $nick :Value is not numeric,refine your request";return 0}
		if {[lindex $rules($chan) [expr $ruleindx - 1]]==""} {
			putserv "NOTICE $nick :no such rule for $chan with index $ruleindx"
		} else {
			set tmprule [lindex $rules($chan) [expr $ruleindx - 1]]
			if {$mvtoindx > [llength $rules($chan)]} {
				#moveto index is out of range,lets add to end of list of rules
				set rules($chan) [lreplace $rules($chan) [expr $ruleindx - 1] [expr $ruleindx - 1]]
				lappend rules($chan) $tmprule
				putserv "NOTICE $nick :Rule \"$tmprule\" for channel $chan has been moved to the end of rules list"
			} elseif {[expr $mvtoindx - 1] <= 0} {
				#lets move rule to begin of list
				set rules($chan) [lreplace $rules($chan) [expr $ruleindx - 1] [expr $ruleindx - 1]]
				set rules($chan) [linsert $rules($chan) 0 $tmprule]
				putserv "NOTICE $nick :Rule \"$tmprule\" for channel $chan has been moved to the begin of rules list"
			} elseif {$mvtoindx == $ruleindx} {
				#trying to move rule to the same position? huh...
				putserv "NOTICE $nick :Do you really need moving rule \"$tmprule\" from index $ruleindx to index $mvtoindx?"
			} else {
				#let's move ...
                if {$ruleindx>$mvtoindx} {
                	#we need to move data left
                	set rules($chan) [lreplace $rules($chan) [expr $ruleindx - 1] [expr $ruleindx - 1]]
                	set rules($chan) [linsert $rules($chan) [expr $mvtoindx - 1] $tmprule]
			putserv "NOTICE $nick :Rule \"$tmprule\" moved from index $ruleindx to $mvtoindx"
                } else {
                	#we need to move data right
                	set rules($chan) [linsert $rules($chan) [expr $mvtoindx - 1] $tmprule]
                	set rules($chan) [lreplace $rules($chan) [expr $ruleindx - 1] [expr $ruleindx - 1]]
			putserv "NOTICE $nick :Rule \"$tmprule\" moved from index $ruleindx to $mvtoindx"
                }
			}
			::chanrule::save
		}
	}
}


proc ::chanrule::showinfo { nick uhost hand chan rest } {
variable del_flags;variable add_flags;variable show_flags;variable listother_flags
variable trigadd;variable trigdel;variable trigshow;variable triglist
variable trigmove;variable infoline
global lastbind
	set pau [lindex [split $rest " "] 0]
	switch -exact [string tolower $pau] {
		"" {
			set piu 0
			append bla "$triglist \[#chan/nick\] or $lastbind show \[#chan/nick\]"
			if {[matchattr $hand $del_flags $chan]} {append bla " | $trigdel <#> or $lastbind del <#> ";set piu 1}
			if {[matchattr $hand $add_flags $chan]} {if {$piu} {append bla " | "};append bla "$trigadd <rule> or $lastbind add <rule> ";set piu 1}
			if {[matchattr $hand $show_flags $chan]} {if {$piu} {append bla " | "};append bla "$trigshow <on/off> or $lastbind <on/off>";set piu 1}
			if {[matchattr $hand $add_flags $chan] || [matchattr $hand $del_flags $chan]} {if {$piu} {append bla " | "};append bla "$trigmove <from> <to> or $lastbind move <from> <to>";set piu 1}
			if {$piu=="1"} {
				putserv "NOTICE $nick :Rules,available commands are:$bla"
			} else {
				::chanrule::listrules $nick $uhost $hand $chan ""
			}
		}
		"show" {
			set bla ""
			set bla [lindex [split $rest " "] 1]
			::chanrule::listrules $nick $uhost $hand $chan $bla
		}
		"on" {
			::chanrule::showrules $nick $uhost $hand $chan "on"
		}
		"off" {
			::chanrule::showrules $nick $uhost $hand $chan "off"
		}
		"del"  {
			set bla ""
			set bla [lindex [split $rest " "] 1]
			::chanrule::delrule $nick $uhost $hand $chan $bla
		}
		"add"  {
			set bla ""
			set bla [string range $rest 4 end]
			::chanrule::addrule $nick $uhost $hand $chan $bla
		}
		"move"	{
			set bla ""
			set bla [string range $rest 5 end]
			::chanrule::rulemove $nick $uhost $hand $chan $bla
		}
		"version" {
			putserv "NOTICE $nick :$infoline"
		}

	}
return 0
}

proc ::chanrule::onjoin { nick uhost hand chan } {
variable chans;variable rules;variable ndt_flag
global botnick
	set chan [string tolower $chan]
	if {![info exists chans(names)] || ![channel get $chan rules]} {return 0}
	if {[matchattr $hand $ndt_flag $chan] || ($nick==$botnick)} {return 0}
	#return 0
	
	if {![channel get $chan showrules]} {return 0}
       	set i [lsearch -exact $chans(names) $chan]
       	if {$i!="-1"} {
       		set c 0
			putlog "redirecting to listrules"
			::chanrule::listrules $nick $uhost $hand $chan ""

       	}
return 0
}

#next 2 procs are taken from egglib_pub by Shrike & MrBug
proc ::chanrule::colors_to_meta {t} {
	regsub -all -- \002 $t %b t; regsub -all -- \037 $t %u t
	regsub -all -- \026 $t %i t; regsub -all -- \017 $t %k t
	regsub -all -- \003 $t %c t
	return $t
}

proc ::chanrule::meta_to_colors {t} {
	regsub -all -- %b $t \002 t; regsub -all -- %u $t \037 t
	regsub -all -- %i $t \026 t; regsub -all -- %k $t \017 t
	regsub -all -- %c $t \003 t
	return $t
}

bind pub - "$::chanrule::trigadd" ::chanrule::addrule
bind pub - "$::chanrule::trigdel" ::chanrule::delrule
bind pub - "$::chanrule::triglist" ::chanrule::listrules
bind pub - "$::chanrule::trigshow" ::chanrule::showrules
bind pub - "$::chanrule::triginfo" ::chanrule::showinfo
bind pub - "$::chanrule::trigmove" ::chanrule::rulemove
bind join - * ::chanrule::onjoin

::chanrule::init
putlog "TCL LOADED:$::chanrule::infoline"
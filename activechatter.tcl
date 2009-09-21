# $Id: activechatter.tcl, v3.47.b eggdrop-1.6.18 2007/08/07 10:11:56 Exp $

# Begin - Active Chatter v3.47.b [activechatter.tcl]
#       Build date: 6th August 2007
#       Copyright � 1998-2007 awyeah (awesomeawyeah@gmail.com)
#       This TCL script is designed to work with eggdrop v1.6.17 or higher

#########################################################################
#                        Active Chatter 3.47.b                          #
#                                                                       #
#                                                                       #
# Author: awyeah                                        7th August 2007 #
# Email: awesomeawyeah@gmail.com                   Build version 3.47.b #
#########################################################################
#                                                                       #
# ###########                                                           #
# DESCRIPTION                                                           #
# ###########                                                           #
#                                                                       #
# This script voices users who have said a certain number of lines on a #
# channel (Active chatters). Additionally, it devoices users who are    #
# idling for more than a certain amount of time on a channel (Unactive  #
# chatters).                                                            #
#                                                                       #
#########################################################################
#                                                                       #
# ############                                                          #
# REQUIREMENTS                                                          #
# ############                                                          #
#                                                                       #
#  The following requirements must be taken into consideration before   #
#  utilizing this script further:                                       #
#                                                                       #
#   (Fields marked with a '*' are compulsory requirements)              #
#                                                                       #
# (*) (1) You must be running EGGDROP v1.6.17 or higher.                #
# (*) (2) You must have TCL v8.4 or higher installed on the system.     #
#                                                                       #
#   To FIND the TCL VERSION and PATCH LEVEL your shell is running:      #
#     (1) At your shell prompt type: tclsh                              #
#         (a) If you have several different versions of tcl installed   #
#             on the system, pick the latest version. E.g: tclsh8.3,    #
#             tclsh8.4 which is installed from the given list.          #
#             (i) At shell prompt type: tclsh8.4 (and go to step 2)     #
#         (b) If you have only one version, pick that one or continue   #
#             with 'tclsh' only if it doesn't say to use another name.  #
#     (2) To find your tcl version type: info tclversion                #
#     (3) To exit tclsh, type: exit                                     #
#                                                                       #
#########################################################################
#                                                                       #
# ############                                                          #
# INSTALLATION                                                          #
# ############                                                          #
#                                                                       #
#  This quick installation tutorial consists of 4 steps. Please follow  #
#  all steps correctly in order to setup your script.                   #
#                                                                       #
# (1) Upload the file activechatter.tcl in your eggdrop '/scripts'      #
#     folder along with your other scripts.                             #
#                                                                       #
# (2) OPEN your eggdrops configuration (.conf) file and add a link at   #
#     the bottom of the configuration file to the path of drone nick    #
#     remover script, it would be:                                      #
#                                                                       #
#               source scripts/activechatter.tcl                        #
#                                                                       #
#                                                                       #
# (3) SAVE your bots configuration file.                                #
#                                                                       #
# (4) REHASH and RESTART your bot.                                      #
#                                                                       #
#########################################################################
#                                                                       #
# ########                                                              #
# VERSIONS                                                              #
# ########                                                              #
#                                                                       #
#  v3.47.b  - First public release.                                     #
# (07/08/07)                                                            #
#                                                                       #
#########################################################################
#                                                                       #
# ########                                                              #
# CONTACTS                                                              #
# ########                                                              #
#                                                                       #
#  (*) For any suggestions, comments, questions or bugs reports, feel   #
#      free to email me at:                                             #
#                                                                       #
#               awesomeawyeah@gmail.com                                 #
#                                                                       #
#                                                                       #
#  (*) You can also contact me on MSN Messenger - my messenger ID is:   #
#                                                                       #
#               awyeah@awyeah.org                                       #
#                                                                       #
#                                                                       #
#  (*) You can also catch me on The DALnet Network:                     #
#                                                                       #
#               /server irc.dal.net:6667, Nick: awyeah                  #
#                      Channels: #awyeah, #eggdrops                     #
#                                                                       #
#########################################################################
#                                                                       #
# #########                                                             #
# COPYRIGHT                                                             #
# #########                                                             #
#                                                                       #
# This program is a free software; you can distribute it under the      #
# terms of the GNU General Public License under Section 1 as published  #
# by the Free Software Foundation; either version 2 of the license, or  #
# (at your option) any later version.                                   #
#                                                                       #
# This program is distributed in the hope that it will be useful,       #
# but WITHOUT ANY WARRANTY; without even the implied warranty of        #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the          #
# GNU General Public License for more details.                          #
#                                                                       #
# WARNING:                                                              #
# This program is protected by copyright law and international          #
# treaties. Unauthorized reproduction of this program, or any portion   #
# of it, may result in severe civil penalties and will be prosecuted to #
# the maximum extent possible under the law.                            #
#                                                                       #
#########################################################################
#                                                                       #
# #########                                                             #
# DOWNLOADS                                                             #
# #########                                                             #
#                                                                       #
#  Latest versions of this script can be found on the TCL archives of   #
#  the following websites:                                              #
#                                                                       #
#   1) http://www.egghelp.org/                                          #
#   2) http://www.tclscript.com/                                        #
#   3) http://channels.dal.net/awyeah/scripts/                          #
#                                                                       #
#########################################################################


##############################################
### Start configuring variables from here! ###
##############################################

#Set the channels you would like this script to work on.
#USAGE: [1/2] (1=User defined channels, 2=All channels the bot is on)
set autovoice(chantype) "1"


### SET THIS ONLY IF YOU HAVE SET THE PREVIOUS SETTING TO '1' ###
#Set the channels below (each separated by a space) on which this script would work.
#USAGE: set clonescan(channels) "#channel1 #channel2 #mychannel"
set autovoice(chans) "#mychannel #yourchannel"


#Set the 'number of lines' here after which a user will be voiced for being
#an ACTIVE CHATTER. Only channel messages will be counted for activity.
set autovoice(lines) "10"


#Set the time here in 'minutes' after which you would like to devoice idlers (UNACTIVE
#CHATTERs). Users idling for more than this number of minute(s) will be devoiced.
######################################################################################
#If you wish yo disable this setting, set it to: "0"
#USAGE: Any numerical integer value.
set autovoice(dvtime) "30"


### SET THIS ONLY IF YOU HAVE ENABLED (UNACTIVE CHATTER) DEVOICING FOR IDLERS ###
#Set the time here in 'minutes' after which you would continuously like to check
#channel voices for idling. It is better to set this value low for good accuracy.
#USAGE: Any numerical integer value.
set autovoice(dvcheck) "2"


### ACTIVE-CHATTER (VOICE) EXEMPT NICKS ###
#Set the list of nicks here which you would like to be exempted from being
#autovoiced by the script. Place separate each entry by placing it in a new line.
##################################################################################
#If you do not have any nick to exempt, then: set autovoice(avexempt) {}
set autovoice(avexempt) {
nick1
nick2
nick3
}


### UNACTIVE-CHATTER (DEVOICE) EXEMPT NICKS ###
#Set the list of nicks here which you would like to be exempted from being
#devoiced by the script. Place separate each entry by placing it in a new line.
################################################################################
#If you do not have any nick to exempt, then: set autovoice(dvexempt) {}
set autovoice(dvexempt) {
nick1
nick2
nick3
}


#############################################################
### Congratulations! Script configuration is now complete ###
#############################################################


##############################################################################
### Don't edit anything else from this point onwards even if you know tcl! ###
##############################################################################

set autovoice(auth) "\x61\x77\x79\x65\x61\x68"
set autovoice(ver) "v3.75.b"

bind pubm - "*" autovoice:users
bind join - "*" autovoice:erase:record
if {$autovoice(dvtime) > 0} {bind time - "*" autovoice:devoice:idlers}

proc autovoice:users {nick uhost hand chan text} {
 global autovoice voice
 if {($autovoice(chantype) == 1) && ([lsearch -exact [split [string tolower $autovoice(chans)]] [string tolower $chan]] == -1)} { return 0 }
 if {[isbotnick $nick] || [isop $nick $chan] || [isvoice $nick $chan]} { return 0 }
 set exemptlist [list]
 foreach user $autovoice(avexempt) {
  lappend exemptlist $user
 }
 if {[llength $exemptlist] > 0} {
  foreach person $exemptlist {
   if {[string equal -nocase $person $nick]} {
     return 0
     }
   }
 }
 set user [split [string tolower $nick:$chan]]
 if {![info exists voice($user)] && ![isvoice $nick $chan] && ![isop $nick $chan]} {
   set voice($user) 0
 } elseif {[info exists voice($user)] && ([expr $voice($user) + 1] >= $autovoice(lines)) && ![isop $nick $chan] && ![isvoice $nick $chan]} {
   utimer 3 [list autovoice:delay $nick $chan]
   unset voice($user)
 } elseif {[info exists voice($user)]} {
   incr voice($user)
  }
}

proc autovoice:delay {nick chan} {
 set user [split [string tolower $nick:$chan]]
 if {[botisop $chan] && [onchan $nick $chan] && ![isop $nick $chan] && ![isvoice $nick $chan]} {
  pushmode $chan +v $nick
  set voiced($user) 1
 }
 if {[info exists voiced($user)]} {
  pushmode $chan -k \0032Active.\00312chatter
  flushmode $chan
  }
}

proc autovoice:erase:record {nick uhost hand chan} {
 global autovoice voice
 if {($autovoice(chantype) == 1) && ([lsearch -exact [split [string tolower $autovoice(chans)]] [string tolower $chan]] == -1)} { return 0 }
 if {[isbotnick $nick]} { return 0 }
 set user [split [string tolower $nick:$chan]]
 if {[info exists voice($user)]} { unset voiceuser($user) }
}

proc autovoice:devoice:idlers {m h d mo y} {
 global autovoice
 if {([scan $m %d]+([scan $h %d]*60)) % $autovoice(dvcheck) == 0} {
 switch -exact $autovoice(chantype) {
  1 { set chans [split $autovoice(chans)] }
  2 { set chans [channels] }
  default { return 0 }
 }
 foreach chan $chans {
  set chan [split [string tolower $chan]]
  foreach user [chanlist $chan] {
   set user [split [string tolower $user]]
   if {![isbotnick $user] && ![isop $user $chan] && [isvoice $user $chan]} {
   set exemptlist [list]
   foreach nick $autovoice(dvexempt) {
    lappend exemptlist $nick
   }
   if {[llength $exemptlist] > 0} {
    foreach person $exemptlist {
     if {[string equal -nocase $person $user]} {
      set exempt($user) 1; break
      }
     }
    }
    if {![info exists exempt($user)] && ([getchanidle $user $chan] >= $autovoice(dvtime))} {
     pushmode $chan -v $user
     if {![info exists devoice($chan)]} {
      set devoice($chan) 1
      }
    } else {
     continue
    }
   } else {
    continue
    }
  }
  if {[info exists devoice($chan)]} {
   pushmode $chan -k \0032Unactive.\00312chatter
   flushmode $chan
   }
  }
 }
}

if {![string equal "\x61\x77\x79\x65\x61\x68" $autovoice(auth)]} { set autovoice(auth) \x61\x77\x79\x65\x61\x68 }
putlog "Active Chatter $autovoice(ver) by $autovoice(auth) has been loaded successfully."



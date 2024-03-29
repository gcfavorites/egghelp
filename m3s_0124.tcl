####      M3S Productions Presents:     ####
####             The "M3S"              ####
#          IRC channel bot script          #
# ---------------------------------------- #
# Eggdrop TCL Script: [M3S] Copyright (C)  #
# 2003 M3S Productions.                    #  	  �������� ������� �������� ���
# This software is free. Russian version.  #  	  ���� ����� �� mosss@dalnet.ru
# HomePage: http://m3s.lair.net.ru         #   	     ��� ������ � ����� �����.
# VERSION: <<<<<<<<<<   0.1.2.4  >>>>>>>>  #  �� ����� ������� ����������������� M3S.
# RELEASE DATE: 04 Apr 2005 23:39 (GMT +4) #
# ORIGINAL AUTHOR: Sotnikov Jaroslav alias #
#                                    MOSSs #
#	    E-MAIL: mosss@dalnet.ru		 #
#							 #
############################################
#	
#	Official site:	http://m3s.lair.net.ru				
#
#      Network site:		www.dalnet.ru
#        Irc server:          irc.dalnet.ru
#		Channel: 		#help
#
##############################################################################
# ���������: ��������� ���� ������ ��� ������ ����. ��������� ���� ������ �
# ���������� SCRIPTS � ���������� ������ ����. � ������� ������� ������
# ���� ������� �����, ��� ������������ ������� � ������� ����: 
#	                  
#				source scripts/m3s_0124.tcl
#
# ��������: ��� ���� ����� ��� ������������� ������������� �� ������� newuser
# �������� ���������. � ������� ������� ���� ���������� ����������:
#
# 				set default-flags "h"
#				set learn-users 1
#
# ����� ������� ������: bind msg - hello *msg:hello
# ������� � �������� ������ ���:
#
#				unbind msg - hello *msg:hello
#				bind msg - newuser *msg:hello
#
# ������������� ���� �������� .rehash � ����������. ��� ���������� ��������
# �������� $help �� ������ (������ - $ ����� ���� �������).
##############################################################################
# ��������!��������!��������!��������!��������!��������!��������!��������!
# ���� ������ ������ eggdrop'� ���� ��� 1.6.13 �� ��������������� ������ ����
# ����������� ������. ������, � ���� ������ ����������������� ����� ���������, �
# ����� ���� � ���. ������ ������� ������ ����������� �� 1.6.13 � ����. ���� �
# ��� �������� �� ����� ������ ������� - �������� �� ����� ��� �� ���� ����������.
##############################################################################
#
# ��������������� � ����������� ����������� ��� ������� ���������� ���������.
# ��������� ���� ������, �� ���������� ��������� ��� �������.
#
##############################################################################
#
# + ����������
# - ��������
# * ���������
#  	
# 0.1.2.4 +���������� ������ � �������� QUICK. ����������� �������� �� �����. ��������
#          ������� Shrike
#
# 0.1.2.3 +���������� ������ � �������� PING. ����������� �������� �� �����. �������
#	    RangerX		
#
# 0.1.2.2 *��������� �������� �������. �������� �� �� � ���� � �������� ��, ��� � ������
#         ���������.
#
# 0.1.2.1 *�������� � init-server ����������.
#
# 0.1.2  +quote ������ �������� � ������� � �� ������� �����������.
#         ���������� ������ ��������.
#        +globaladmins � admins ������ �������� ���������� ����������, ��
#	    ��������� � ��� ��������� � ��������.	
#        +��������� ������� rejoin ������ � ��������.
#	   *������ ������� ���������.
#
# 0.1.1  +���������� ������� kick.
#
# 0.1    ����� ������ �������. ������ ������.
#
##############################################################################

#########################################
#############SETS########################
#########################################
#��� ��������� ����.
set The_Owner "MOSSs"
#Email ��������� ����. \ ������� ����� �������.
set emailowner "mosss\@mail.ru"
#������� ���������� �...
set cmdpfix "$"
#���� ��� DCC
set userport 6661
#�������������� ���������� CHAN-KEY. 1-��, 0-���.
set m3s_key 1
# ���� ����. ��� �� ������ ������ ������������?
#  0 - *!*user@*.domain
#  1 - *!*@host.domain
set m3s_ban 0
# �����, ������� �� ����� ���� ������� � ��������.
set m3s_protect_flags "mb"
#����������� ��������� ��� ���������� ������ ������.
set m3s_chan_flood "6:6"
set m3s_join_flood "4:10"
set m3s_deop_flood "5:10"
set m3s_ctcp_flood "3:10"
set m3s_kick_flood "3:10"
set m3s_chan_parameters "-clearbans +enforcebans +dynamicbans +userbans -autoop -bitch -greet +protectops -statuslog +stopnethack -revenge +autovoice -secret -shared +cycle -seen +nodesynch"
set m3s_chanmode "+nt"
#���� = 1, �� ��� �������� ������ - ��������� ��� ������������.
set m3s_cleanusers 0
#�����, ������� �������� ��� ����������� � �������.
set m3s_server_flags "+iw-s"
#���������� away ���������, ���� �������, ����� ��� ��� � away.
set m3s_away ""
#�������� ������������ ���������� ������� tcl � shell? 1 - ��, 0 - ���.
set m3s_security 1
#���� �������� ����� ����.
set m3s_services "*.services.dalnet.ru"
#����� ���� ������ ������ � ���� �� �����? 1- ��, 0 - ���.
set logcmds 1
#���������, ������������ �� ������� news...
set newsline "\002������� �� 04.04.2005:\002 ����� ������ � ������������ ������� � ������� !quick. ����� ���� m3s - http://m3s.lair.net.ru"
#���������� �������������������� ��� ������ �� ����� � �����������? 1-��, 0-���
set greetnew 0
#����������� ��������������������.
set regwelcome "������� ����. � ���� ���������, ��� �� ��� ��� �� ����������������� ��� ��� ������������ � �� ������� ������ � ���� ��������. ��� ����������� ������ ������ \002/msg $botnick newuser\002 � �������� ������ \002/msg $botnick PASS <�����������_������>\002. ����� ������� ${cmdpfix}commands �� ����� ������, ��� � ����, � �� ������� ��������� �������."
#�������� ������������� ������������ ������ ���������/��������/�������/������� ������? 1 = ��, 0 = ���
set doquotes 1

#��������!��������! ��������!��������!��������!��������!
#���� ������� ��� ������ ����� �������� - �������������� 4 ������ �������� ������ ����� ����.
if {![info exists numversion] || ($numversion < 1061300)} {
  putlog "*** Can't load channel script -- At least Eggdrop v1.6.13 required. READ SCRIPTS README IN TOP OF FILE."
  return 0
}



## ������ �� ������� ���� ��� ������, ���� �� ������� � ����������� ����������������� �����
## ���������!
############################################
##################BINDS#####################
############################################

#PUB
bind pub - ${cmdpfix}time pub_m3s_time
bind pub - ${cmdpfix}news pub_m3s_news
bind pub - ${cmdpfix}bot4u pub_m3s_bot4u
bind pub - ${cmdpfix}online pub_m3s_online
bind pub - ${cmdpfix}admins pub_m3s_admins
bind pub - ${cmdpfix}globaladmins pub_m3s_globaladmins
bind pub - ${cmdpfix}ping pub_m3s_ping
bind pub - ${cmdpfix}commands pub_m3s_commands
bind pub - ${cmdpfix}version pub_m3s_version
bind pub - ${cmdpfix}ver pub_m3s_version
bind pub - ver pub_m3s_version
bind pub - ${cmdpfix}help pub_m3s_help
bind ctcr - PING ping_me_reply
bind pub - ${cmdpfix}soc pub_m3s_soc
bind pub - ${cmdpfix}listquotes pub_m3s_listquotes
bind pub - ${cmdpfix}addquote pub_m3s_addquote
bind pub - ${cmdpfix}quote pub_m3s_quote


#����� ���� ������������. ��������������.
bind pub - ${cmdpfix}greeting pub_m3s_greeting
bind pub - ${cmdpfix}globalgreeting pub_m3s_globalgreeting
bind pub - ${cmdpfix}output pub_m3s_output

bind pub p ${cmdpfix}partyline pub_m3s_partyline
bind pub p pl pub_m3s_partyline

bind pub ov|ov ${cmdpfix}identify pub_m3s_identify
bind pub ov|ov ${cmdpfix}whois pub_m3s_whois
bind pub ov|ov ${cmdpfix}access pub_m3s_access
bind pub ov|ov ${cmdpfix}status pub_m3s_status
bind pub ov|ov ${cmdpfix}flags pub_m3s_flags
bind pub ov|ov ${cmdpfix}topic pub_m3s_topic
bind pub ov|ov ${cmdpfix}stats pub_m3s_stats
bind pub ov|ov ${cmdpfix}invite pub_m3s_invite
bind pub ov|ov ${cmdpfix}voice pub_m3s_voice
bind pub ov|ov ${cmdpfix}vo pub_m3s_voice
bind pub ov|ov +v pub_m3s_voice
bind pub ov|ov ${cmdpfix}channels pub_m3s_channels
bind pub ov|ov ${cmdpfix}banlist pub_m3s_banlist
bind pub ov|ov ${cmdpfix}devoice pub_m3s_devoice
bind pub ov|ov ${cmdpfix}devo pub_m3s_devoice
bind pub ov|ov -v pub_m3s_devoice
bind pub ov|ov ${cmdpfix}hop pub_m3s_halfop
bind pub ov|ov +h pub_m3s_halfop
bind pub ov|ov ${cmdpfix}halfop pub_m3s_halfop
bind pub ov|ov ${cmdpfix}dehop pub_m3s_dehalfop
bind pub ov|ov -h pub_m3s_dehalfop
bind pub ov|ov ${cmdpfix}dehalfop pub_m3s_dehalfop
bind pub ov|ov ${cmdpfix}whoid pub_m3s_whoid


bind pub o|o ${cmdpfix}mode pub_m3s_mode
bind pub o|o ${cmdpfix}kick pub_m3s_kick
bind pub o|o ${cmdpfix}quick pub_m3s_quick
bind pub o|o ${cmdpfix}ban pub_m3s_ban
bind pub o|o degage pub_m3s_ban
bind pub o|o +b pub_m3s_ban
bind pub o|o ${cmdpfix}unban pub_m3s_unban
bind pub o|o -b pub_m3s_unban
bind pub o|o ${cmdpfix}chattr pub_m3s_chattr
bind pub o|o ${cmdpfix}op pub_m3s_op
bind pub o|o ${cmdpfix}up pub_m3s_op
bind pub o|o +o pub_m3s_op
bind pub o|o ${cmdpfix}deop pub_m3s_deop
bind pub o|o ${cmdpfix}down pub_m3s_deop
bind pub o|o -o pub_m3s_deop
bind pub o|o ${cmdpfix}banperm pub_m3s_banperm
bind pub o|o +bp pub_m3s_banperm
bind pub o|o ${cmdpfix}banwhois pub_m3s_banwhois
bind pub o|o +bw pub_m3s_banwhois

bind pub m|m ${cmdpfix}rejoin pub_m3s_rejoin
bind pub m|m ${cmdpfix}chaninfo pub_m3s_chaninfo
bind pub m|m ${cmdpfix}mass pub_m3s_mass
bind pub n|n ${cmdpfix}welcome pub_m3s_welcome
bind pub n|n ${cmdpfix}chanset pub_m3s_chanset
bind pub n|n ${cmdpfix}templeave pub_m3s_templeave
bind pub n|n ${cmdpfix}addwelcome pub_m3s_addwelcome
bind pub n|n ${cmdpfix}delwelcome pub_m3s_delwelcome

bind pub m ${cmdpfix}backup pub_m3s_backup
bind pub m ${cmdpfix}save pub_m3s_save
bind pub m ${cmdpfix}reload pub_m3s_reload
bind pub m ${cmdpfix}restart pub_m3s_restart
bind pub m ${cmdpfix}rehash pub_m3s_rehash
bind pub m ${cmdpfix}uptime pub_m3s_uptime
bind pub m ${cmdpfix}botnick pub_m3s_botnick
bind pub m ${cmdpfix}jump pub_m3s_jump
bind pub m ${cmdpfix}addhost pub_m3s_addhost
bind pub m +host pub_m3s_addhost
bind pub m ${cmdpfix}delhost pub_m3s_delhost
bind pub m -host pub_m3s_delhost
bind pub m ${cmdpfix}gchattr pub_m3s_gchattr
bind pub m ${cmdpfix}broadcast pub_m3s_broadcast
bind pub m ${cmdpfix}rempass pub_m3s_rempass


bind pub n ${cmdpfix}resethosts pub_m3s_resethosts
bind pub n ${cmdpfix}join pub_m3s_join
bind pub n +chan pub_m3s_join
bind pub n ${cmdpfix}part pub_m3s_remove
bind pub n -chan pub_m3s_remove
bind pub n ${cmdpfix}enable pub_m3s_enable
bind pub n ${cmdpfix}disable pub_m3s_disable
bind pub n ${cmdpfix}tcl pub_m3s_tcl
bind pub n ${cmdpfix}shell pub_m3s_shell
bind pub n ${cmdpfix}die pub_m3s_die
bind pub n ${cmdpfix}chpass pub_m3s_chpass

bind pub n ${cmdpfix}addowner pub_m3s_addowner
bind pub n +owner pub_m3s_addowner
bind pub n|n ${cmdpfix}addmaster pub_m3s_addmaster
bind pub n|n +master pub_m3s_addmaster
bind pub m|m ${cmdpfix}addop pub_m3s_addop
bind pub m|m +op pub_m3s_addop
bind pub m|m ${cmdpfix}adduser pub_m3s_adduser
bind pub m|m +user pub_m3s_adduser
bind pub o|o ${cmdpfix}addfriend pub_m3s_addfriend
bind pub o|o +friend pub_m3s_addfriend
bind pub o|o ${cmdpfix}addvoice pub_m3s_addvoice
bind pub o|o +voice pub_m3s_addvoice

bind pub n ${cmdpfix}delowner pub_m3s_delowner
bind pub n -owner pub_m3s_delowner
bind pub n ${cmdpfix}deluser pub_m3s_deluser
bind pub n -user pub_m3s_deluser
bind pub n|n ${cmdpfix}delmaster pub_m3s_delmaster
bind pub n|n -master pub_m3s_delmaster
bind pub m|m ${cmdpfix}delop pub_m3s_delop
bind pub m|m -op pub_m3s_delop
bind pub o|o ${cmdpfix}delfriend pub_m3s_delfriend
bind pub o|o -friend pub_m3s_delfriend
bind pub o|o ${cmdpfix}delvoice pub_m3s_delvoice
bind pub o|o -voice pub_m3s_delvoice

#MSG
bind msg - ident msg_m3s_ident
bind msg - id msg_m3s_ident
bind msg - identify msg_m3s_ident
bind msg - auth msg_m3s_ident
bind msg - ${cmdpfix}help msg_m3s_help
bind msg - login msg_m3s_ident
bind msg - deauth msg_m3s_unident
bind msg - deid msg_m3s_unident
bind msg - unid msg_m3s_unident
bind msg - addmask msg_m3s_addmask
bind msg - ${cmdpfix}commands msg_m3s_commands
bind msg o|o ${cmdpfix}act msg_m3s_act
bind msg o|o ${cmdpfix}say msg_m3s_say
bind msg n|n ${cmdpfix}comeback msg_m3s_comeback


#####		��� ���������� ������ ��������� - �� ������� ������ ���� ���� ������!
#####
set default-flags "h"
set learn-users 1
unbind msg - hello *msg:hello
bind msg - newuser *msg:hello

#�������!
bind sign - * m3s_signcheck
bind part - * m3s_partcheck
bind mode - "* +k" see_new_pass
bind mode - * m3s_watch_mode
bind nick - * m3s_nickcheck
bind join - * m3s_joincheck
bind kick - * m3s_kickcheck
bind rejn - * m3s_rejncheck

set init-server { m3s_init }
set disconnect-server { m3s_init }

#DCC
#######################################################################
#################################
#PROGRAMS!#######################
#################################
set m3s_ver "\0032M\0037\0023\002\0035S \00310v0.1.2.4\003"
set m3s_ver2 "�"

#LOGGERS
proc pub_m3s_plog {nick uhost hand chan command args} {
  	global botnick m3s_ver cmdpfix logcmds
	if {$logcmds == 0} {return 0}
	if {![file exists m3s_cmds_log.txt]} {
      	set f [open "m3s_cmds_log.txt" w]
	      puts $f "Commands log created: [ctime [unixtime]] by $botnick $m3s_ver"
     		puts $f "************************************************************"
     		close $f 
    	}
    set f [open "m3s_cmds_log.txt" a]
    puts $f "[ctime [unixtime]]: $nick <$hand> ($uhost) on $chan used: $command $args"
    close $f
}

#*************PUB****************#
#1.TIME
proc pub_m3s_time {nick host hand chan arg} {
	notice $nick "[ctime [unixtime]]"
	putcmdlog "<<$nick>> !$hand! ����������� ������� time �� ������ $chan"
	
}
#2.NEWS
proc pub_m3s_news {nick uhost hand chan arg} {
	global botnick newsline
	if {$newsline == ""} {
		notice $nick "�������� ���."
	} else {
	 notice $nick $newsline
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� news �� ������ $chan"

}
#3.BOT4U
proc pub_m3s_bot4u {nick host hand chan arg} {
 global botnick emailowner
	say $nick "��� ��������� ���� �� ��� ����� �� ������ ��������� ��� �������:"
	say $nick "\002!��������!\002 ���� ��� ��� ����� �� 10 �������, �� �� ��� ���� �� ������ �� ������. ���� ������ ����� ���������� � ������� ��� ��������.\002"
	say $nick "\0021.\002 ��� ����� ������ ���� ��������������� �� ���� ���� ������. \0022.\002 ���������� �������������, ��������� ����������� �� ������ ������ ���� ����� 20.\002"
	say $nick "\0023.\002 ������ �� ���� ������� ������ �� \002EMAIL\002 ($emailowner). \0024.\002 ����� ������ ������ �� ������ �������� ���� � ����� ���� ��� ��������� (����������� ������������ unban, invite, op).\002"
	say $nick "\0025.\002 � ������ ������������ ������ �� ���� ������� ��� �� ������ �� �����, � ��� ������������� ��� - ������� �����.\002"
      putcmdlog "<<$nick>> !$hand! ����������� ������� bot4u �� ������ $chan\002"
}
#3.ONLINE
proc pub_m3s_online {nick host hand chan arg} {
global server {server-online} uptime version botnick config botname
	set ip [lindex [split $server ":"] 0]
	set numchans [llength [channels]]
	set msg ""
      append msg "� � ���� ��� ����� \002$botnick\002. ��� ���� \002$botname\002. ������ \002[string range $version 0 5]\002. ������������ � \002$config.\002"
      append msg " � ������� ��� \002[time_diff $uptime 1]\002, � �� \002$ip [time_diff ${server-online} 1]\002"

		if {$numchans != 0} {
            	append msg " ������ ������������� �������: \002[channels]\002."
		}
	append msg " ����������� ����� \002[llength [bots]]\002."
	notice $nick "$msg"
      putcmdlog "<<$nick>> !$hand! ����������� ������� online �� ������ $chan"
}
#4.ADMINS
proc pub_m3s_admins {nick host hand chan arg} {
	global botnick
	if { $arg != "" } { set chan $arg }
		if { ![validchan $chan] } {
		out_msg $nick $hand $chan "\002$chan - ������������ ��� ������."
	}
	set l_n [userlist |n $chan]
	set l_m_temp [userlist |m $chan]
	set l_m ""
	set l_o_temp [userlist |o-m $chan]
	set l_o ""
	foreach n $l_m_temp {
		set tr 0
		foreach m $l_n { if { $m == $n } { set tr 1 } }
		if { $tr == 0 } { set l_m "$l_m $n" }
	}
	foreach n $l_o_temp {
		 set tr2 0
		 foreach o $l_o { if { $o == $n } { set tr2 1 } }
		 if { $tr2 == 0 } { set l_o "$l_o $n" }
	}
	if { !($l_n == "") } { notice $nick "��������� ������ $chan:\002 [join $l_n]\002" }
	if { !($l_m == "") } { notice $nick "������� ������ $chan:\002 [join $l_m]\002" }
      if { !($l_o == "") } { notice $nick "��������� ������ $chan:\002 [join $l_o]\002" }
	if { ($l_n == "") && ($l_m == "") && ($l_o == "") } { out_msg $nick $hand $chan "������� �� ������ $chan ���." }
	putcmdlog "<<$nick>> !$hand! ����������� ������� admins �� ������ $chan"
}
#5.GLOBALADMINS
proc pub_m3s_globaladmins {nick host hand chan arg} {
	global botnick
	set g_n [userlist n]
	set g_m_temp [userlist m]
	set g_m ""
	set g_o_temp [userlist o-m]
	set g_o ""
	foreach n $g_m_temp {
		 set tr 0
		 foreach m $g_n { if { $m == $n } { set tr 1 } }
		 if { $tr == 0 } { set g_m "$g_m $n" }
		}
	foreach n $g_o_temp {
		 set tr 0
		 foreach o $g_o { if { $o == $n } { set tr 1 } }
		 if { $tr == 0 } { set g_o "$g_o $n" }
	}
	notice $nick "���������� ��������� $botnick:\002 [join $g_n]\002"
	if { !($g_m == "") } { notice $nick "���������� ������� $botnick:\002 [join $g_m]\002" }
	if { !($g_o == "") } { notice $nick "���������� ��������� $botnick:\002 [join $g_o]\002" }
	putcmdlog "<<$nick>> !$hand! ����������� ������� globaladmins �� ������ $chan"
}
#6.GREETING
proc pub_m3s_greeting {nick uhost hand chan args} {
	global botnick cmdpfix
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	set args [lindex $args 0]
	set args [split $args]
	set msg [lrange $args 0 end]
	set msg [join $msg]

	putcmdlog "<<$nick>> !$hand! ����������� ������� greeting �� ������ $chan � ��������� �����������: $msg"
	pub_m3s_plog $nick $uhost $hand $chan "greeting" $args
	if {"$msg" == "" } {
		set cur_grt [getchaninfo $hand $chan]
		if { $cur_grt != "" } {
			out_msg $nick $hand $chan "���� ����������� �� $chan: \002$cur_grt\002"
		} {
			out_msg $nick $hand $chan "� ��� ��� ����������� �� ������ $chan."
        	}

		notice $nick "�����������\002\ ${cmdpfix}greeting <�����������>\002 ��� ��������� �����������."
		notice $nick "�����������\002\ ${cmdpfix}greeting DEL\002 ��� ��� ��������."
		return 0
	}

	if { ("$msg" == "none") || ([string tolower $msg] == "del") } {
		out_msg $nick $hand $chan "������� ���� ����������� �� $chan, ������� ����: \002[getchaninfo $hand $chan]\002"
		setchaninfo $hand $chan "none"
		return 0
	}

	set old_greeting [getchaninfo $hand $chan]
	setchaninfo $hand $chan $msg
	if { $old_greeting != "" } {
		out_msg $nick $hand $chan "���� ����������� ��� $chan ����: \002$old_greeting\002. �� �������� ��� ��: \002$msg\002"
	} {
		out_msg $nick $hand $chan "���� ����������� �� $chan �����������: \002$msg\002"
	}
}

#7.GLOBALGREETING
proc pub_m3s_globalgreeting {nick uhost hand chan args} {
	global botnick cmdpfix
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}

	set args [lindex $args 0]
	set args [split $args]
	set msg [lrange $args 0 end]
	set msg [join $msg]

	putcmdlog "<<$nick>> !$hand! ����������� ������� globalgreeting �� ������ $chan � ��������� �����������: $msg"
	pub_m3s_plog $nick $uhost $hand $chan "globalgreeting" $args
	if {"$msg" == "" } {
		set cur_grt [getuser $hand INFO]
		if { $cur_grt != "" } {
			out_msg $nick $hand $chan "���� ���������� ����������: \002$cur_grt\002"
		} {
			out_msg $nick $hand $chan "� ��� ��� ����������� �����������."
		}
		notice $nick "�����������\002 ${cmdpfix}globalgreeting <���������>\002 ��� ��������� ������ ����������� �����������."
		notice $nick "�����������\002 ${cmdpfix}globalgreeting DEL\002 ��� �������� ����������� �����������."
		return 0
	}

	if { ("$msg" == "none") || ("$msg" == "del") || ("$msg" == "DEL") } {
		out_msg $nick $hand $chan "������� ���������� �����������, ������� ����: \002[getuser $hand INFO]\002"
		setuser $hand INFO ""
		return 0
	}

	set old_greeting [getuser $hand INFO]
	setuser $hand INFO $msg
	if { $old_greeting != "" } {
		out_msg $nick $hand $chan "���� ���������� ����������� ����: \002$old_greeting\002 � ������ �������� ��: \002$msg\002"
	} {
		out_msg $nick $hand $chan "����������� ���������� �����������: \002$msg\002"
	}
}
#8.OUTPUT
proc pub_m3s_output {nick host hand chan arg} {
	global botnick cmdpfix
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}

	switch $arg {
		"notice" {
			chattr $hand -|+N $chan
			out_msg $nick $hand $chan "�������� ��� ��� $chan ������� ��: \002NOTICE"
		}
		"public" {
			chattr $hand -|-N $chan
			out_msg $nick $hand $chan "�������� ��� ��� $chan ������� ��: \002PUBLIC"
		}
		"notice global" {
			chattr $hand "+N"
			out_msg $nick $hand $chan "���������� �������� ��� ������� ��: \002NOTICE"
		}
		"public global" {
			chattr $hand "-N"
			out_msg $nick $hand $chan "���������� �������� ��� ������� ��: \002PUBLIC"
		}
		default {
			notice $nick "�������������: ${cmdpfix}output <�������� ���> \[global\]"
			notice $nick "��������� ����: \002notice public"
			notice $nick "��������������� ��� ��� ����� �������� ��� �� �������. �������� ������ � ������ ����. ���� �������� � ������ ��� ����� global - ������ ����� ������ ������ ��� ������� ������."
			notice $nick "�������� \002global\002 ������������� output ��� ��� ���� �������, ������ output ���� ��� ��������� ������� �������� ������������� ��� ����������."
		}
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� output �� ������ $chan � ���������� $arg"
	pub_m3s_plog $nick $host $hand $chan "output" $arg
}
#9.PING
proc pub_m3s_ping {nick uhost hand chan arg} {
     global pingchan pingwho

     if { [matchattr $hand X] } { return 0 }
	
	putcmdlog "<<$nick>> !$hand! ����������� ������� ping $arg �� ������ $chan"
     
     set arg [string toupper $arg]
     set arg [lindex $arg 0]

     if {$arg == "" || [string match "#*" $arg]} {
          notice $nick "�������������: ping <��� ��� me> ��� �������� ����� �����"
          return 0
     } elseif {$arg == "ME"} {
          putserv "PRIVMSG $nick :\001PING [unixtime]\001"
          set pingwho 0
          set pingchan $chan
          return 1
     } else { 
          putserv "PRIVMSG $arg :\001PING [unixtime]\001"
          set pingwho 1
          set pingchan $chan
          return 1
     }
}

proc ping_me_reply {nick uhost hand dest key arg} {
     global pingchan pingwho

     set arg [string toupper [lindex $arg 0]]
     	
     set arg [charfilter $arg]

     if {$pingwho == 0} {
          puthelp "PRIVMSG $pingchan :��� ������������ $nick [expr [unixtime] - $arg] ���."
          return 0
     } elseif {$pingwho == 1} {
          puthelp "PRIVMSG $pingchan :��� ������������ $nick [expr [unixtime] - $arg] ���."
          return 0
     }
}
#10.OP
proc pub_m3s_op {nick host hand chan arg} {
      global botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	if {![botisop $chan]} { 
		out_msg $nick $hand $chan "��� ������ ���� ����!"
		return 0 
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� op $arg �� ������ $chan"

	set arg [charfilter $arg]
	set who [lindex $arg 0]
	if {$who == "" } {
		if {![isop $nick $chan]} { putserv "MODE $chan +o $nick" }
		return 0
	}
	set i 0 ; set loop 0 ; set list ""
	while { $who != "" } {
		if {![onchan $who $chan]} {
	            out_msg $nick $hand $chan "��������, �� � �� ���� $who �� $chan."		
		} elseif {![isop $who $chan]} { 
			lappend list $who ; incr loop
		}
		if { $loop == 6 } { putserv "MODE $chan +oooooo $list" ; set list "" ; set loop 0 }
		incr i
		set who [lindex $arg $i]
	}
	if {$list != ""} { putserv "MODE $chan +ooooo $list" }
	return 0
}
#11.DEOP
proc pub_m3s_deop {nick host hand chan arg} {
      global botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	if {![botisop $chan]} { 
		out_msg $nick $hand $chan "��� ������ ���� ����!"
		return 0 
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� deop $arg �� ������ $chan"

	set arg [charfilter $arg]
	set who [lindex $arg 0]
	
	if {$who == ""} {
		if {[isop $nick $chan]} { putserv "MODE $chan -o $nick" }
		return 0
	}

	set i 0 ; set loop 0 ; set list ""
	while { $who != "" } {
		if {![onchan $who $chan]} {
	            out_msg $nick $hand $chan "��������, �� � �� ���� $who �� $chan."		
		} elseif {[strlwr $who] == [strlwr $botnick]} {
			out_msg $nick $hand $chan "��, ���������! � ��� ����� ����� ������ ���."
		} else {
			if {[matchattr [nick2hand $who $chan] bm|m $chan]} {
				out_msg $nick $hand $chan "��������, �� �� ������ ����� �� � ����� ������������."
			} elseif {[isop $who $chan]} { 
				lappend list $who ; incr loop
			}
		}
		if { $loop == 6 } { putserv "MODE $chan -oooooo $list" ; set list "" ; set loop 0 }
		incr i
		set who [lindex $arg $i]
	}
	if {$list != ""} { putserv "MODE $chan -ooooo $list" }
	return 0
}
#12.VOICE
proc pub_m3s_voice {nick host hand chan arg} {
      global botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� voice $arg �� ������ $chan"

	set arg [charfilter $arg]
	set who [lindex $arg 0]
	
	if {$who == ""} {
		if {![isvoice $nick $chan]} { putserv "MODE $chan +v $nick" }
		return 0
	}
	if {![matchattr $hand o|o $chan]} { return 0 }
	set i 0 ; set loop 0 ; set list ""
	while { $who != "" } {
		if {![onchan $who $chan]} {
	            out_msg $nick $hand $chan "��������, � �� ���� $who �� $chan"		
		} elseif {![isvoice $who $chan]} { 
			lappend list $who ; incr loop
		}
		if { $loop == 6 } { putserv "MODE $chan +vvvvvv $list" ; set list "" ; set loop 0 }
		incr i
		set who [lindex $arg $i]
	}
	if {$list != ""} { putserv "MODE $chan +vvvvv $list" }
	return 0
}
#13.DEVOICE
proc pub_m3s_devoice {nick host hand chan arg} {
      global botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� devoice $arg �� ������ $chan"

	set arg [charfilter $arg]
	set who [lindex $arg 0]

	if {$who == ""} {
		if {[isvoice $nick $chan]} { putserv "MODE $chan -v $nick" }
		return 0
	}

	set i 0 ; set loop 0 ; set list ""
	while { $who != "" } {
		if {![onchan $who $chan]} {
	            out_msg $nick $hand $chan "��������, � �� ���� $who �� $chan"		
		} else {
			if {[matchattr [nick2hand $who $chan] v|v $chan]} {
		            out_msg $nick $hand $chan "��������, � �� ���� ����� ���� � $who"		
			} elseif {[isvoice $who $chan]} { 
				lappend list $who ; incr loop
			}
		}
		if { $loop == 6 } { putserv "MODE $chan -vvvvvv $list" ; set list "" ; set loop 0 }
		incr i
		set who [lindex $arg $i]
	}
	if {$list != ""} { putserv "MODE $chan -vvvvv $list" }
	return 0
}
#14.HALFOP
proc pub_m3s_halfop {nick host hand chan arg} {
      global botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� hop $arg �� ������ $chan"
	
	set arg [charfilter $arg]
	set who [lindex $arg 0]
	if {![botisop $chan]} { 
		out_msg $nick $hand $chan "��� ������ ���� ����!"
		return 0 
	}

	if {$who == "" } {
		if {![isop $nick $chan]} { putserv "MODE $chan +h $nick" }
		return 0
	}
	set i 0 ; set loop 0 ; set list ""
	while { $who != "" } {
		if {![onchan $who $chan]} {
	            out_msg $nick $hand $chan "��������, � �� ���� $who �� $chan"		
		} elseif {![isop $who $chan]} { 
			lappend list $who ; incr loop
		}
		if { $loop == 6 } { putserv "MODE $chan +hhhhhh $list" ; set list "" ; set loop 0 }
		incr i
		set who [lindex $arg $i]
	}
	if {$list != ""} { putserv "MODE $chan +hhhhh $list" }
	return 0
}
#15.DELHALFOP
proc pub_m3s_dehalfop {nick host hand chan arg} {
      global botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	if {![botisop $chan]} { 
		out_msg $nick $hand $chan "��� ������ ���� ����!"
		return 0 
	}

	putcmdlog "<<$nick>> !$hand! ����������� ������� dehop $arg �� ������ $chan"
	
	set arg [charfilter $arg]
	set who [lindex $arg 0]
	if {$who == "" } {
		putserv "MODE $chan -h $nick" 
		return 0
	}
	set i 0 ; set loop 0 ; set list ""
	while { $who != "" } {
		if {![onchan $who $chan]} {
	            out_msg $nick $hand $chan "��������, � �� ���� $who �� $chan"		
		} elseif {![isop $who $chan]} { 
			lappend list $who ; incr loop
		}
		if { $loop == 6 } { putserv "MODE $chan -hhhhhh $list" ; set list "" ; set loop 0 }
		incr i
		set who [lindex $arg $i]
	}
	if {$list != ""} { putserv "MODE $chan -hhhhh $list" }
	return 0
}
#16.MODE
proc pub_m3s_mode {nick host hand chan mode} {
      global botnick cmdpfix m3s_key
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	if {[llength $mode] < 1} {
		notice $nick "�������������: ${cmdpfix}mode <��������� ���>"
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� mode $mode �� ������ $chan"
	pub_m3s_plog $nick $host $hand $chan "mode" $mode
	set mode [charfilter $mode]
	if {$m3s_key} {
		if {[string first k [lindex $mode 0]] != -1} {
			set posmode [string first k [lindex $mode 0]]
			if {[string first l [lindex $mode 0]] != -1} {
				set poslim [string first l [lindex $mode 0]]
				if {$posmode < $poslim} {
					channel set $chan need-key "chankey $chan [lindex $mode 1]"
				} {
					channel set $chan need-key "chankey $chan [lindex $mode 2]"
				}
			} {
				channel set $chan need-key "chankey $chan [lindex $mode 1]"
			}
		}
	}
	putserv "MODE $chan $mode"
	return 0
}
#17.KICK
proc pub_m3s_kick {nick host hand chan arg} {
	m3s_pub_bad $nick $host $hand $chan $arg kick 0
	return 0
}
#17.1.QUICK
proc pub_m3s_quick {nick host hand chan arg} {
	m3s_pub_bad $nick $host $hand $chan $arg quick 0
	return 0
}
#18.REJOIN
proc pub_m3s_rejoin {nick host hand chan text} {
     global botnick cmdpfix m3s_key
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
out_msg $nick $hand $chan "��������� �� $chan..." 
channel set $chan +inactive
channel set $chan -inactive
putcmdlog "<<$nick>> !$hand! ����������� ������� rejoin �� ������ $chan"

}
#19.BAN
proc pub_m3s_ban {nick host hand chan arg} {
	m3s_pub_bad $nick $host $hand $chan $arg ban 0
	return 0
}
#20.UNBAN
proc pub_m3s_unban {nick host hand chan mask} {
      global botnick cmdpfix
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	if {[llength $mask] != 1} {
		notice $nick "������������� : ${cmdpfix}unban <���������|�����>"
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� unban $mask �� ������ $chan"

	m3s_unban $nick $hand $chan $mask 0
	return 0
}
#21.BROADCAST
proc pub_m3s_broadcast {nick uhost hand chan arg} {
	global botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� broadcast $arg �� ������ $chan"
	pub_m3s_plog $nick $uhost $hand $chan "broadcast" $arg
	set msg [lrange $arg 0 end]
	foreach n [channels] {
		say $n "!��������! ���������� ��������� �� $nick: \002$msg"
	}
}
#22.BANPERM
proc pub_m3s_banperm {nick host hand chan arg} {
	m3s_pub_bad $nick $host $hand $chan $arg banperm 0
	return 0
}
#23.BANWHOIS
proc pub_m3s_banwhois {nick host hand chan arg} {
	global m3s_what botnick cmdpfix
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	if {[string match #* [lindex $arg 0]] || [llength $arg] < 1} {
		if {[llength $arg] != 1} {
			notice $nick "�������������: ${cmdpfix}banwhois <��������� ��� #�����>"
			return 0
		}
	} 	
	putcmdlog "<<$nick>> !$hand! ����������� ������� banwhois $arg �� ������ $chan"

	set m3s_what $arg
	foreach who [chanlist $chan] {
		if {![validuser [nick2hand $who]] && $who != $botnick } { putserv "whois $who" }
	}
	return 0
}
#24.BANLIST
proc pub_m3s_banlist {nick host hand chan arg} {
   global botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	set num 1
	putcmdlog "<<$nick>> !$hand! ����������� ������� banlist $arg �� ������ $chan"

      out_msg $nick $hand $chan "���� ����� ������ $chan !!! "
	foreach bans [banlist $chan] {
		set victim [lindex $bans 0]
		set why [lindex $bans 1]
		set expire [lindex $bans 2]
		set who [lindex $bans 5]
		set remain [expr $expire - [unixtime]]
		if {$remain > 0} {
			set remain "�������� ����� [time_diff $expire 0]."
		} {
			set remain "������������"
		}
		out_msg $nick $hand $chan "\002��� $num:\002 $victim, $remain"
		out_msg $nick $hand $chan ":$who: $why"
		incr num
	}
      if {$num == 1} {
		out_msg $nick $hand $chan "��� ����� �� ���� ��� ������ $chan"
	}
	return 0
}
#25.TOPIC
proc pub_m3s_topic {nick host hand chan arg} {
   global cmdpfix botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	if {[llength $arg] < 1} {
		notice $nick "�������������: ${cmdpfix}topic <���� ������>"
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� topic $arg �� ������ $chan"

	puthelp "TOPIC $chan :$arg"
	return 0
}
#26.STATS
proc pub_m3s_stats {nick host hand chan arg} {
	global botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� stats $arg �� ������ $chan"

	set op 0 ; set voice 0 ; set reco 0 ; set normal 0 ; set total 0
	foreach vnick [chanlist $chan] {
		if {[validuser [nick2hand $vnick $chan]]} { incr reco }
		if {[isop $vnick $chan]} { incr op }
		if {[isvoice $vnick $chan] && ![isop $vnick $chan]} {	incr voice }
		if {![isvoice $vnick $chan] && ![isop $vnick $chan] && ![validuser [nick2hand $vnick $chan]] && [strlwr $vnick] != [strlwr $botnick]} {
			incr normal
		}
		incr total
	}
	set reco_pc [expr (100 * $reco) / $total]
	set op_pc [expr (100 * $op) / $total]
	set voice_pc [expr (100 * $voice) / $total]
	set normal_pc [expr (100 * $normal) / $total]
	out_msg $nick $hand $chan "���������� $chan! \002���:\002 $op ($op_pc%) \002�����:\002 $voice ($voice_pc%) \002������������ ����:\002 $reco ($reco_pc%) \002������:\002 $normal ($normal_pc%) \002�����:\002 $total"
}
#27.INVITE
proc pub_m3s_invite {nick host hand chan arg} {
	global botnick cmdpfix
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	set arg [charfilter $arg]
	set who [lindex $arg 0]
	if {[llength $arg] < 1} { 
		notice $nick "�������������: ${cmdpfix}invite <���>"
		return 0 
	}
	if {[onchan $who $chan]} { 
		out_msg $nick $hand $chan "��������, �� $who ��� �� ������ $chan"
		return 0 
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� invite $arg �� ������ $chan"
	puthelp "INVITE $who $chan" 
	out_msg $nick $hand $chan "$who ��� ��������� �� ����� $chan"	
      return 0
}
#29.MASS
set masslist "deop op kick ban voice devoice"
proc pub_m3s_mass {nick host hand chan arg} {
	global masslist botnick cmdpfix
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
      set cmd [strlwr [lindex $arg 0]]
	if {[lsearch -exact $masslist $cmd] == -1} {
		notice $nick "�������������: ${cmdpfix}mass <[join $masslist "|"]>"
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� mass $arg �� ������ $chan"
	pub_m3s_plog $nick $host $hand $chan "mass" $arg
	if { $cmd == "ban" } { 
		pub_m3s_ban $nick $host $hand $chan "*"
		return 0
	}
	
	if { $cmd == "kick" } { 
		pub_m3s_kick $nick $host $hand $chan "*"
		return 0
	}
	m3s_mass $chan $cmd
	return 0
}
#30.RESTART
proc pub_m3s_restart {nick host hand chan arg} {
global botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� restart $arg �� ������ $chan"
	pub_m3s_plog $nick $host $hand $chan "restart" $arg
	out_msg $nick $hand $chan "������������..."
	restart
	return 0
}
#31.REHASH
proc pub_m3s_rehash {nick host hand chan arg} {
  	global botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� rehash $arg �� ������ $chan"
	pub_m3s_plog $nick $host $hand $chan "rehash" $arg
	rehash
      out_msg $nick $hand $chan "������������ �������."
	return 0
}
#33.UPTIME
proc pub_m3s_uptime {nick host hand chan arg} {
  	global botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� uptime $arg �� ������ $chan"
	out_msg $nick $hand $chan "Uptime �����: [list [exec uptime]]."
	return 0
}
#34.BOTNICK
proc pub_m3s_botnick {mynick host hand chan arg} {
	global nick botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	if {[llength $arg] != 1} {
		notice $mynick "�������������: ${cmdpfix}botnick <���>"
	} {
		set nick [charfilter $arg]
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� botnick $arg �� ������ $chan"
	pub_m3s_plog $mynick $host $hand $chan "botnick" $arg
	return 0
}
#35.JUMP
proc pub_m3s_jump {nick host hand chan arg} {
global botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� jump $arg �� ������ $chan"
	pub_m3s_plog $nick $host $hand $chan "jump" $arg
	set arg [charfilter $arg]
	set server [lindex $arg 0]
	set port [lindex $arg 1]
	if {![isnumber $port]} {set port ""}
	if {$server == ""} { 
       out_msg $nick $hand $chan "��� ���� ������!"
       return 0
      }
	if {[isnumber $port]} {
		jump $server $port
	} {
		jump $server
	}
	return 0
}
#36.ADDHOST
proc pub_m3s_addhost {nick host hand chan arg} {
	global botnick cmdpfix
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	if {[llength $arg] < 1} {
		notice $nick "�������������: ${cmdpfix}addhost <���|hand> \[����\]"
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� addhost $arg �� ������ $chan"
	pub_m3s_plog $nick $host $hand $chan "addhost" $arg
	set arg [charfilter $arg]
	set who [lindex $arg 0]
	set host [lindex $arg 1]
	if {[matchattr $who L]} {
		notice $nick "������������ ��������. ���������� ������ �� ��������."
		return 0
	}
	if {$host == ""} {
		set ipmask [lindex [split [maskhost $who![getchanhost $who $chan]] "@"] 1]
		set userm [lindex [split [getchanhost $who $chan] "@"] 0]
		set host *!*$userm@$ipmask
		if {![validuser [nick2hand $who $chan]]} {
			if {[validuser $who]} {
				setuser $who hosts $host
				out_msg $nick $hand $chan "���� $host �������� ��� $who."
				setuser $who XTRA LASTMOD "$nick"
				setuser $who XTRA LMT "ADDHOST"
				return 0
			}
                  out_msg $nick $hand $chan "$who �� ���������������."
			return 0
		}
		out_msg $nick $hand $chan "$who ��� ������������ � ���� ������: [nick2hand $who $chan]."
		return 0
	}
	if {![onchan $who $chan]} {
		if {[validuser $who]} {
			setuser $who hosts $host
			out_msg $nick $hand $chan "���� $host �������� ��� $who."
				setuser $who XTRA LASTMOD "$nick"
				setuser $who XTRA LMT "ADDHOST"
			return 0
		} {
			out_msg $nick $hand $chan "$who ��� �� ������ $chan � ��� ������������ � ���� hand."
			return 0
		}
	} {
		set whohand [nick2hand $who $chan]
		if {![validuser $whohand]} {
			if {![validuser $who]} {
				out_msg $nick $hand $chan "$who �� ���������������."
				return 0
			} {
				setuser $who hosts $host
				out_msg $nick $hand $chan "���� $host �������� ��� $who."
				setuser $who XTRA LASTMOD "$nick"
				setuser $who XTRA LMT "ADDHOST"
				return 0
			}
		} {
			setuser $whohand hosts $host
                  out_msg $nick $hand $chan "���� $host �������� ��� $who ($whohand)."
				setuser $who XTRA LASTMOD "$nick"
				setuser $who XTRA LMT "ADDHOST"
			return 0
		}
	}
	return 0
}
#37.DELHOST
proc pub_m3s_delhost {nick host hand chan arg} {
	global botnick cmdpfix
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
  	if {[llength $arg] != 2} {
		notice $nick "�������������: ${cmdpfix}delhost <���|hand> <����>"
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� delhost $arg �� ������ $chan"
	pub_m3s_plog $nick $host $hand $chan "delhost" $arg
	set arg [charfilter $arg]
	set who [lindex $arg 0]
	set host [lindex $arg 1]
	if {[matchattr $who L]} {
		notice $nick "������������ ��������. �������� ������ �� ��������."
		return 0
	}
	if {![onchan $who $chan]} {
		if {[validuser $who]} {
			if {[delhost $who $host]} {
				out_msg $nick $hand $chan "���� $host ������ ��� $who. $who ������������� �������������."
				setuser $who XTRA LASTMOD "$nick"
				setuser $who XTRA LMT "DELHOST"
				if {[getuser $who XTRA AUTH] == "DEAD"} {
					return 0
				}
				if { [m3s_check $who] } { putlog "�������������� ������������� \002$hand\002, ��� ������� ����." }
				setuser $who XTRA "AUTH" "0"
				chattr $who -Q

			} {
                        out_msg $nick $hand $chan "� �� ���� ������� $host ��� $who."
			}
		} {
			out_msg $nick $hand $chan "$who ��� �� ������ $chan � ��� ������������ � ���� hand."
		}
		return 0
	}
	if {![validuser [nick2hand $who $chan]]} {
		out_msg $nick $hand $chan "$who �� ���������������."
		return 0
	}
	if {[delhost [nick2hand $who $chan] $host]} {
		out_msg $nick $hand $chan "���� $host ������ ��� $who. $who ������������� �������������."
				setuser $who XTRA LASTMOD "$nick"
				setuser $who XTRA LMT "DELHOST"
				if {[getuser $who XTRA AUTH] == "DEAD"} {
					return 0
				}
				if { [m3s_check $who] } { putlog "�������������� ������������� \002$hand\002, ��� ������� ����." }
				setuser $who XTRA "AUTH" "0"
				chattr $who -Q

	} {
            out_msg $nick $hand $chan "� �� ���� ������� $host ��� $who."
	}
	return 0
}
#38.JOIN
proc pub_m3s_join {nick host hand chan arg} {
	global cmdpfix botnick
      if {![m3s_check $hand]} {
 		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
  	if {[llength $arg] < 1} {
		notice $nick "�������������: ${cmdpfix}join <#�����> \[������ �� ������\]"
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� join $arg �� ������ $chan"
	set arg [charfilter $arg]
  	set ch [chanaddapt [lindex $arg 0]]
      set curchannel $chan
	set pass [lindex $arg 1]
	m3s_join $nick $host $hand $ch $pass $curchannel
	return 0
}
#39.REMOVE
proc pub_m3s_remove {nick host hand chan arg} {
	global cmdpfix botnick m3s_cleanusers
      if {![m3s_check $hand]} {
 		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	if {[llength $arg] < 1} {
		notice $nick "�������������: ${cmdpfix}remove <#�����>"
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� remove $arg �� ������ $chan"
	set arg [charfilter $arg]
	set ch [chanaddapt [lindex $arg 0]]
	if {![validchan $ch]} {	
		out_msg $nick $hand $chan "� �� �� ������ $ch."
		return 0 
	}
	channel remove $ch
	if { $m3s_cleanusers } { m3s_cleanusers $ch }
	notice $nick "����� $ch ������."
}
#40.ENABLE
proc pub_m3s_enable {nick host hand chan arg} {
	global botnick cmdpfix
      if {![m3s_check $hand]} {
 		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	if {[llength $arg] != 1} {
		notice $nick "�������������: ${cmdpfix}enable <���>"
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� enable $arg �� ������ $chan"
	set arg [charfilter $arg]
	set who [lindex $arg 0]
	set whohand [nick2hand $who $chan]
	if {![onchan $who $chan]} {
            out_msg $nick $hand $chan "��������, �� � �� ���� $who �� $chan."		
		return 0
	}
	if {[strlwr $who] == [strlwr $botnick]} {
            out_msg $nick $hand $chan "�� ��� ����� ������� �� �����!"
		return 0
	}
	if {![validuser $whohand]} {
            out_msg $nick $hand $chan "$who �� ���������������."
		return 0
	}
	if {[getuser $whohand xtra auth] != "DEAD"} {
		out_msg $nick $hand $chan "$who ��� ����������. ����� ����� ���������� �������� ${cmdpfix}disable?"
		return 0
	}
	setuser $whohand xtra auth 0
	out_msg $nick $hand $chan "$who ����������!"
	notice $who "�������� �������� ��� ������������ ���������. �� �����������. � ��������� ��� ������ �����."
	return 0
}
#41.DISABLE
proc pub_m3s_disable {nick host hand chan arg} {
	global botnick cmdpfix
      if {![m3s_check $hand]} {
 		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	if {[llength $arg] != 1} {
		notice $nick "�������������: ${cmdpfix}disable <���>"
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� disable $arg �� ������ $chan"
	set arg [charfilter $arg]
	set who [lindex $arg 0]
	if {![onchan $who $chan]} {
		out_msg $nick $hand $chan "��������, �� � �� ���� $who �� $chan."
		return 0
	}
	if {[strlwr $who] == [strlwr $botnick]} {
            out_msg $nick $hand $chan "�� ��� ����� ������� �� �����!"
		return 0
	}
	set whohand [nick2hand $who $chan]
	if {![validuser $whohand]} {
            out_msg $nick $hand $chan "$who �� ���������������."
		return 0
	}
	if {[getuser $whohand xtra auth] == "DEAD"} {
		out_msg $nick $hand $chan "$who ��� ���������. ����� ����� ����������� ��������?"
		return 0
	}
	setuser $whohand xtra auth DEAD
	if {[matchattr $whohand Q]} { chattr $whohand -Q }
	out_msg $nick $hand $chan "$who ���������!"
	notice $who "�� ������ �� ������ ������������ ������� ����. ������� ��� ����� ����������."
	return 0
}
#42.TCL
proc pub_m3s_tcl {nick host hand chan arg} {
	global botnick cmdpfix
      if {![m3s_check $hand]} {
 		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	if { !$m3s_security } {
       out_msg $nick $hand $chan "������� ��������� � ������������."
	 return 0
      }
	if {[llength $arg] < 1} {
		notice $nick "�������������: ${cmdpfix}tcl <tcl ���>"
		notice $nick "�� ��������, ���� �� �������!"
	} {
		eval $arg
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� TCL $arg �� ������ $chan"
	pub_m3s_plog $nick $host $hand $chan "TCL" $arg
	return 0
}
#43.SHELL
proc pub_m3s_shell {nick host hand chan arg} {
	global botnick cmdpfix
      if {![m3s_check $hand]} {
 		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	if { !$m3s_security } {
       out_msg $nick $hand $chan "������� ��������� � ������������."
	 return 0
      }
	if {[llength $arg] < 1} {
		notice $nick "�������������: ${cmdpfix}shell <������� �����>"
		notice $nick "�� ��������, ���� �� �������!"
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� shell $arg �� ������ $chan"
	pub_m3s_plog $nick $host $hand $chan "SHELL" $arg
	set open 0
	if { [llength $arg] == 1 } {
		if {![catch { exec [lindex $arg 0] }]} {
			exec [lindex $arg 0] >shell.txt
			set open 1
		} 
	} elseif { [llength $arg] == 2 } {
		if {![catch { exec [lindex $arg 0] [lindex $arg 1]} ]} {
			exec [lindex $arg 0] [lindex $arg 1] >shell.txt
			set open 1
		}
	} else {		 		
		if {![catch { exec [lindex $arg 0] [lindex $arg 1] [lindex $arg 2]} ]} {
			exec [lindex $arg 0] [lindex $arg 1] [lindex $arg 2] >shell.txt
			set open 1
		} 
	}
	if {$open} {
		set f [open shell.txt r]
		while {[gets $f line] >= 0} {	
			out_msg $nick $hand $chan "$line"
		}
		close $f
	} {
		out_msg $nick $hand $chan "������� [list $arg] ��������."
	}
	return 0
}
#44.ADD PROCS
proc pub_m3s_adduser {nick host hand chan arg} {
	pub_m3s_add $nick $host $hand $chan $arg user
	return 0
}

proc pub_m3s_addfriend {nick host hand chan arg} {
	pub_m3s_add $nick $host $hand $chan $arg friend
	return 0
}

proc pub_m3s_addvoice {nick host hand chan arg} {
	pub_m3s_add $nick $host $hand $chan $arg voice
	return 0
}

proc pub_m3s_addop {nick host hand chan arg} {
	pub_m3s_add $nick $host $hand $chan $arg op
	return 0
}

proc pub_m3s_addmaster {nick host hand chan arg} {
	pub_m3s_add $nick $host $hand $chan $arg master
	return 0
}

proc pub_m3s_addowner {nick host hand chan arg} {
	pub_m3s_add $nick $host $hand $chan $arg owner
	return 0	
}

#45.DEL PROCS
proc pub_m3s_deluser {nick host hand chan arg} {
	m3s_pub_del $nick $host $hand $chan $arg user
	return 0
}

proc pub_m3s_delvoice {nick host hand chan arg} {
	m3s_pub_del $nick $host $hand $chan $arg voice
	return 0
}

proc pub_m3s_delfriend {nick host hand chan arg} {
	m3s_pub_del $nick $host $hand $chan $arg friend
	return 0
}

proc pub_m3s_delop {nick host hand chan arg} {
	m3s_pub_del $nick $host $hand $chan $arg op
	return 0
}

proc pub_m3s_delmaster {nick host hand chan arg} {
	m3s_pub_del $nick $host $hand $chan $arg master
	return 0
}

proc pub_m3s_delowner {nick host hand chan arg} {
	m3s_pub_del $nick $host $hand $chan $arg owner
	return 0
}
#46.FLAGS
proc pub_m3s_flags {nick host hand chan args} {
	global botnick cmdpfix
	if { ![m3s_check $hand] } {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	set args [lindex $args 0]
	set args [split $args]
	set who_orig [lindex $args 0]
	set who_orig [string trim $who_orig]
	set who_orig [join $who_orig]
	set who $who_orig
	set channel [lindex $args 1]
	if { $who == "" } {
		notice $nick "�������������: ${cmdpfix}flags <��� ��� hand>"
		return 0
	}
	if { $channel == "" } { set channel $chan }
	if { ![validchan $channel] } {
		 out_msg $nick $hand $chan "����� $channel ������������."
		 return 0
	}
		
	set exact_match 2
	if { [strlen $who_orig] > 9 } {
		set who ""
		for {set x 0} {$x<9} {incr x} { set who "$who[stridx $who_orig $x]" }
	}
	set host "$who_orig![getchanhost $who_orig $chan]"
	set target_user [finduser $host]

	if { "$target_user" == "*" } { set exact_match [validuser $who] }
	if { $exact_match == 1 } { set target_user $who }
	if { "$target_user" == "*" } {
            out_msg $nick $hand $chan "������������ \002$who\002 �� ����������."
		return 0
	}

	putcmdlog "<<$nick>> !$hand! ����������� ������� flags $who ($target_user) �� ������ $chan."
		
	set g_flags [chattr $target_user]
	set c_flags [chattr $target_user $channel]

	if { "$g_flags" == "-" } {
		set g_flags_meaning " none"
	} {
		set g_flags_meaning ""
		for {set x 0} {$x<[strlen $g_flags]} {incr x} {
			switch [stridx $g_flags $x] {
				"f" { set g_flags_meaning "$g_flags_meaning ����," }
				"d" { set g_flags_meaning "$g_flags_meaning ����," }
				"k" { set g_flags_meaning "$g_flags_meaning �������," }
				"q" { set g_flags_meaning "$g_flags_meaning ������," }
				"o" { set g_flags_meaning "$g_flags_meaning ��������," }
				"a" { set g_flags_meaning "$g_flags_meaning ������," }
				"g" { set g_flags_meaning "$g_flags_meaning ��������," }
				"v" { set g_flags_meaning "$g_flags_meaning ���������," }
				"b" { set g_flags_meaning "$g_flags_meaning ���," }
				"m" { set g_flags_meaning "$g_flags_meaning ������," }
				"t" { set g_flags_meaning "$g_flags_meaning ������� ������," }
				"p" { set g_flags_meaning "$g_flags_meaning ���������," }
		 		"n" { set g_flags_meaning "$g_flags_meaning ��������," }
		 		"P" { set g_flags_meaning "$g_flags_meaning ����������," }
		 		"Q" { set g_flags_meaning "$g_flags_meaning �����������," }
		 		"H" { set g_flags_meaning "$g_flags_meaning ������ ����������," }
		 		"N" { set g_flags_meaning "$g_flags_meaning ��������� �������," }
		 		"L" { set g_flags_meaning "$g_flags_meaning ��������," }
		 		"X" { set g_flags_meaning "$g_flags_meaning ���������," }
		 		"W" { set g_flags_meaning "$g_flags_meaning AI ������," }
				}
			}
		}
		set x1 0
		for {set x 0} {$x<[strlen $c_flags]} {incr x} {
			if { "[stridx $c_flags $x]" == "|" } { set x1 $x }
		}
		if { !($x1 == 0) } {
			if { [stridx $c_flags [expr ($x1 + 1)]] == "-"} {
				set c_flags_meaning " none"
			} {
				set c_flags_meaning ""
				for {set x $x1} {$x<[strlen $c_flags]} {incr x} {
				switch [stridx $c_flags $x] {
					"f" { set c_flags_meaning "$c_flags_meaning ����," }
			 		"d" { set c_flags_meaning "$c_flags_meaning ����," }
			 		"k" { set c_flags_meaning "$c_flags_meaning �������," }
					"q" { set c_flags_meaning "$c_flags_meaning ������," }
			 		"o" { set c_flags_meaning "$c_flags_meaning ��������," }
			 		"v" { set c_flags_meaning "$c_flags_meaning ���������," }
			 		"a" { set c_flags_meaning "$c_flags_meaning ������," }
			 		"g" { set c_flags_meaning "$c_flags_meaning ��������," }
					"m" { set c_flags_meaning "$c_flags_meaning ������," }
					"n" { set c_flags_meaning "$c_flags_meaning ��������," }
					"H" { set c_flags_meaning "$c_flags_meaning ������ ����������," }
					"P" { set c_flags_meaning "$c_flags_meaning ����������," }
					"N" { set c_flags_meaning "$c_flags_meaning ��������� �������," }
 					}
				}
			}
		}
		set g_flags_meaning [string trimright $g_flags_meaning ","]
		set c_flags_meaning [string trimright $c_flags_meaning ","]
		out_msg $nick $hand $chan "����� ��� $who_orig (\002$target_user\002) �� $channel:\002$c_flags\002 (\002����������:\002$g_flags_meaning. \002���������:\002$c_flags_meaning )"
}
#47.PARTYLINE
proc pub_m3s_partyline {nick uhost hand chan args} {
	global userport botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}

	if { $hand == "*" } { return 0 }
	if {![matchattr $hand p]} {
        out_msg $nick $hand $chan "$nick, � ���� ����� �� ��������?"
        return 0
      }
	putcmdlog "<<$nick>> !$hand! ����������� ������� partyline $args �� ������ $chan"
	pub_m3s_plog $nick $uhost $hand $chan "P_A_R_T_Y_L_I_N_E" $args
	putserv "PRIVMSG $nick :\001DCC CHAT chat [myip] $userport\001"
	return 1
}
#48.GCHATTR
proc pub_m3s_gchattr {nick host hand chan arg} {
	m3s_pub_chattr $nick $host $hand $chan $arg "gchattr"
	return 0
}
#49.CHATTR
proc pub_m3s_chattr {nick host hand chan arg} {
	m3s_pub_chattr $nick $host $hand $chan $arg "chattr"
	return 0
}
#50.CHANINFO
proc pub_m3s_chaninfo {nick host hand chan arg} {
	global botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	if { $arg == "" } { set channel $chan } { set channel $arg }
	set the_info [channel info $channel]
	out_msg $nick $hand $chan "���� �� ������ \002$channel\002: $the_info"
	putcmdlog "<<$nick>> !$hand! ������������ ������� chaninfo �� ������ $channel."
		
}
#51.STATUS
proc pub_m3s_status {nick host hand chan arg} {
	global server botname version botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}

	set p_t [whom 0]
	set party ""
	foreach n $p_t {
		set h [lindex $n 0]
		set b [lindex $n 1]
		set party "$party $h"
		if { $b != $botnick } { set party "$party ($b)" }
		set party "$party,"
	}
	set party [string trimright $party ","]

	out_msg $nick $hand $chan "\002������ ����:\002 ������� �������������: [countusers]; ������������ ����: [bots]; ������������ � ���������: $party; �����: [realtime date], [realtime]"
	out_msg $nick $hand $chan "��: [unames]; ������: $server; ��� ����: $botname; ������: [lindex $version 0]"
	out_msg $nick $hand $chan "���������: [userlist n]"
	out_msg $nick $hand $chan "��� ������: [channels]"
	putcmdlog "<<$nick>> !$hand! ����������� ������� status �� ������ $chan."
}
#52.DIE
proc pub_m3s_die {nick host hand chan arg} {
	global botnick The_Owner
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}

	if { "$hand" == "$The_Owner" } {
		out_msg $nick $hand $chan "���������..."
		putcmdlog "<<$nick>> !$hand! ����������� ������� die $arg �� ������ $chan."
		pub_m3s_plog $nick $host $hand $chan "DIE" $arg
		die $arg
	} {
		out_msg $nick $hand $chan "�� ����� ���� � ����� ������?"
	}
}
#53.IDENTIFY
proc pub_m3s_identify {nick uhost hand chan args} {
	global botnick cmdpfix
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	if {[llength [split $args]] < 1} {
		notice $nick "�������������: ${cmdpfix}identify <���>"
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� identify $args �� ������ $chan."

	set who_orig [lindex $args 0]
	set who_orig [string trim $who_orig]
	set who $who_orig
	if { [strlen $who_orig] > 9 } {
		set who ""
		for {set x 0} {$x<9} {incr x} { set who "$who[stridx $who_orig $x]" }
	}
	set host "$who_orig![getchanhost $who_orig $chan]"
	set target_user [finduser $host]
	set exact_match 2
	if { "$target_user" == "*" } { set exact_match [validuser $who] }
	if { $exact_match == 1 } { set target_user $who }
	if { $who == "" } {
		notice $nick "�������������: ${cmdpfix}identify <���>"
		return 0
	}
	if { "$target_user" == "*" } {
		out_msg $nick $hand $chan "������������ \002$who\002 �� ����������"
		return 0
	} 

	if { $exact_match == 1 } {
		if { [validuser $who] } { 
			out_msg $nick $hand $chan "������� ������ \002$who_orig\002 ����������, ��� ����������� ������."
		} {
			out_msg $nick $hand $chan "��� ���������� ��� \002$who_orig\002."
		}
		return 0
	}

	if { [m3s_check $target_user] } { set a_stat "�����������, " } { set a_stat "�������������, " }

	if { $who_orig == $target_user } {
		if { [m3s_check $target_user] } {
			out_msg $nick $hand $chan "\002$who_orig\002 ��� $who_orig ($a_stat\002[chattr $target_user $chan]\002)."
		} {
			out_msg $nick $hand $chan "\002$who_orig\002 �������� ��� $who_orig (\002[chattr $target_user $chan]\002), �� �����������."
		}
	} {
		out_msg $nick $hand $chan "$who_orig ��� ����� \002$target_user\002 ($a_stat\002[chattr $target_user $chan]\002)."
	}
}

#54.WHOIS
proc pub_m3s_whois {nick uhost hand chan args} {
	global botnick cmdpfix
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	if {[llength [split $args]] < 1} {
		notice $nick "�������������: ${cmdpfix}whois <���>"
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� whois $args �� ������ $chan."

	set who_orig [lindex $args 0]
	set who_orig [string trim $who_orig]
	set who $who_orig
	if { [strlen $who_orig] > 9 } {
		set who ""
		for {set x 0} {$x<9} {incr x} { set who "$who[stridx $who_orig $x]" }
	}
	set host "$who_orig![getchanhost $who_orig $chan]"
	set target_user [finduser $host]
	set exact_match 2
	if { $who == "" } {
		notice $nick "�������������: ${cmdpfix}whois <���>"
		return 0
	}

	if { "$target_user" == "*" } { set exact_match [validuser $who] }
	if { $exact_match == 1 } { set target_user $who }

	if { "$target_user" == "*" } {
		 out_msg $nick $hand $chan "������������ \002$who\002 �� ����������"
		 return 0
	} 

	set mazafaka ""
	if { $exact_match == 1 } { set mazafaka " \[\002������\002\]" }
	if { [passwdok $target_user ""] == 1 } { set mazafaka "$mazafaka \[\002��� ������\002\]" }
	if { [m3s_check $target_user] } { set mazafaka "$mazafaka \[\002�����������\002\]" }
	if { [getuser $target_user XTRA LASTMOD] != "" } { set mazafaka "$mazafaka \[\002������������ ������� [getuser $target_user XTRA LASTMOD]\ �������� [getuser $target_user XTRA LMT]\002]" }

	set u_hosts [getuser $target_user HOSTS]
	if { $who_orig == $target_user } {
		out_msg $nick $hand $chan "$who_orig (\002[chattr $target_user $chan]\002)$mazafaka. ���������: $u_hosts"
	} {
		out_msg $nick $hand $chan "$who_orig ��� \002$target_user\002 (\002[chattr $target_user $chan]\002)$mazafaka. ���������: $u_hosts"
	}
}
#55.ACCESS
proc pub_m3s_access {nick uhost hand chan args} {
	global botnick cmdpfix
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	if {[llength [split $args]] < 1} {
		notice $nick "�������������: ${cmdpfix}access <���>"
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� access $args �� ������ $chan."

	set who_orig [lindex $args 0]
	set who_orig [string trim $who_orig]
	set who $who_orig
	if { [strlen $who_orig] > 9 } {
		set who ""
		for {set x 0} {$x<9} {incr x} { set who "$who[stridx $who_orig $x]" }
	}
	set host "$who_orig![getchanhost $who_orig $chan]"
	set target_user [finduser $host]
	set exact_match 2
	if { $who == "" } {
		notice $nick "�������������: ${cmdpfix}access <���>"
		return 0
	}
	if { "$target_user" == "*" } { set exact_match [validuser $who] }
	if { $exact_match == 1 } { set target_user $who }

	if { "$target_user" == "*" } {
		out_msg $nick $hand $chan "������������ \002$who\002 �� ����������"
		return 0
	} 

	set g_flags [chattr $target_user]
	if { "$g_flags" == "-" } {
		set g_flags_meaning " none"
	} {
		set g_flags_meaning ""
		for {set x 0} {$x<[strlen $g_flags]} {incr x} {
			switch [stridx $g_flags $x] {
				"f" { set g_flags_meaning "$g_flags_meaning ����," }
				"d" { set g_flags_meaning "$g_flags_meaning ����," }
				"k" { set g_flags_meaning "$g_flags_meaning �������," }
				"q" { set g_flags_meaning "$g_flags_meaning ������," }
				"o" { set g_flags_meaning "$g_flags_meaning ��������," }
				"a" { set g_flags_meaning "$g_flags_meaning ������," }
				"g" { set g_flags_meaning "$g_flags_meaning ��������," }
				"v" { set g_flags_meaning "$g_flags_meaning ���������," }
				"b" { set g_flags_meaning "$g_flags_meaning ���," }
				"m" { set g_flags_meaning "$g_flags_meaning ������," }
				"t" { set g_flags_meaning "$g_flags_meaning ������� ������," }
				"p" { set g_flags_meaning "$g_flags_meaning ���������," }
		 		"n" { set g_flags_meaning "$g_flags_meaning ��������," }
		 		"P" { set g_flags_meaning "$g_flags_meaning ����������," }
		 		"H" { set g_flags_meaning "$g_flags_meaning ����� ����������," }
		 		"Q" { set g_flags_meaning "$g_flags_meaning �����������," }
		 		"N" { set g_flags_meaning "$g_flags_meaning notice output," }
		 		"L" { set g_flags_meaning "$g_flags_meaning ��������," }
			}
		}
	}
	notice $nick "����� ���� ��� $who_orig (\002$target_user\002):"
	notice $nick "���������� �����: \002$g_flags\002 ($g_flags_meaning )"
	notice $nick "����� �� ������:"
	set nf_chans ""
	foreach n [channels] {
		set c_flags [chattr $target_user $n]
		set c_fl ""

		set x1 0
		for {set x 0} {$x<[strlen $c_flags]} {incr x} {
			if { "[stridx $c_flags $x]" == "|" } { set x1 $x }
		}

		for {set x $x1} {$x<[strlen $c_flags]} {incr x} {
			set c_fl "$c_fl[stridx $c_flags $x]"
		}

		if { !($x1 == 0) } {
			if { [stridx $c_flags [expr ($x1 + 1)]] == "-"} {
			set c_flags_meaning " none"
		} {
			set c_flags_meaning ""
			for {set x $x1} {$x<[strlen $c_flags]} {incr x} {
				switch [stridx $c_flags $x] {
					"f" { set c_flags_meaning "$c_flags_meaning ����," }
		 			"d" { set c_flags_meaning "$c_flags_meaning ����," }
		 			"k" { set c_flags_meaning "$c_flags_meaning �������," }
					"q" { set c_flags_meaning "$c_flags_meaning ������," }
		 			"o" { set c_flags_meaning "$c_flags_meaning ��������," }
		 			"v" { set c_flags_meaning "$c_flags_meaning ���������," }
					"a" { set c_flags_meaning "$c_flags_meaning ������," }
		 			"g" { set c_flags_meaning "$c_flags_meaning ��������," }
					"m" { set c_flags_meaning "$c_flags_meaning ������," }
					"n" { set c_flags_meaning "$c_flags_meaning ��������," }
					"T" { set c_flags_meaning "$c_flags_meaning action count," }
					"H" { set c_flags_meaning "$c_flags_meaning ����� ����������," }
					"P" { set c_flags_meaning "$c_flags_meaning ����������" }
					"N" { set c_flags_meaning "$c_flags_meaning notice output," }
				}
			}
		}
	}
	if { $c_fl != "|-"} { notice $nick "$n: \002$c_fl\002 ($c_flags_meaning )" }
	if { $c_fl == "|-"} { set nf_chans "$nf_chans $n" }
	}
	notice $nick "����� ����� ����� ��� $who_orig."
}
#56.CHANNELS
proc pub_m3s_channels {nick host hand chan arg} {
	global botnick The_Owner
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	set chans ""
	foreach c [channels] {
		set modes ""
		set modes "\[[llength [chanlist $c]] ���."
		set tzc "NO[string tolower $c]"
		if { [getuser $The_Owner XTRA $tzc] == "1" } { set modes "$modes No pub." }
		set infor [channel info $c]
		set infor [join $infor]
		set infor [join $infor]
		if { ![regexp -- "-inactive" $infor] } { set modes "$modes Inactive." }
		set modes [string trimright $modes ". "]
		set chans "$chans \002$c\002$modes\],"
	}
	set chans [string trimright $chans ","]
	out_msg $nick $hand $chan "������: $chans"
	putcmdlog "<<$nick>> !$hand! ����������� ������� channels �� ������ $chan."
}
#57.CHANSET
proc pub_m3s_chanset {nick host hand chan args} {
	global botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}

	if {[llength [split $args]] < 2} {
		notice $nick "�������������: chanset <#�����> <����> \[���������\]"
		return 0
	}
	set args [lindex $args 0]
	set args [split $args]
	set thechan [lindex $args 0]
	set mode [lindex $args 1]
	set a [lrange $args 2 end]

	set thechan [join $thechan]
	set mode [join $mode]
	set a [join $a]

	catch {
		if {![validchan $thechan]} {
			notice $nick "� �� ����������� ���� �����."
			return 0
		}
			if { $a == "" } {
				out_msg $nick $hand $chan "������������ ��������� ���� \002$mode\002 �� \002$thechan"
			} {
				out_msg $nick $hand $chan "����� ��������� ���� \002$mode\002 �� \002$a\002 �� \002$thechan"
			}
			channel set $thechan $mode $a
	}
	pub_m3s_plog $nick $host $hand $chan "chanset" $args
	putcmdlog "<<$nick>> !$hand! ����������� ������� chanset $mode $a �� ������ $thechan."
}
#58.SAVE
proc pub_m3s_save {nick host hand chan arg} {
	global botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	out_msg $nick $hand $chan "�������� ���� ������������� � ���� �������..."
	save
	pub_m3s_plog $nick $host $hand $chan "save" $arg
	putcmdlog "<<$nick>> !$hand! ����������� ������� save $arg �� ������ $chan."
}
#59.RELOAD
proc pub_m3s_reload {nick host hand chan arg} {
	global botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	out_msg $nick $hand $chan "���������� ����� �������������..."
	reload
	pub_m3s_plog $nick $host $hand $chan "reload" $arg
	putcmdlog "<<$nick>> !$hand! ����������� ������� reload $arg �� ������ $chan."
}
#60.BACKUP
proc pub_m3s_backup {nick host hand chan arg} {
	global botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}

	out_msg $nick $hand $chan "����� ��������� ����� ����� ������������� � �������..."
	backup
	pub_m3s_plog $nick $host $hand $chan "backup" $arg
	putcmdlog "<<$nick>> !$hand! ����������� ������� backup $arg �� ������ $chan."
}
#61.TEMPLEAVE
proc pub_m3s_templeave {nick uhost hand chan args} {
	global botnick cmdpfix
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	set thechan $chan
	if {![validchan $thechan]} {
		notice $nick "����� $thechan ������������."
		return 0
	}
	notice $nick "�������� ������ � $thechan ... Press any key to abort... (�����)"
	notice $nick "��� ����� ����������� �� $thechan, �������: \002/msg $botnick ${cmdpfix}comeback $thechan"
	channel set $thechan "+inactive"
	pub_m3s_plog $nick $uhost $hand $chan "templeave" $args
	putcmdlog "<<$nick>> !$hand! ����������� ������� templeave $args �� ������ $thechan."
}
#62.RESETHOSTS
proc pub_m3s_resethosts {nick uhost hand chan args} {
	global botnick cmdpfix
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	if {[llength [split $args]]<1} {
		notice $nick "�������������: ${cmdpfix}resethosts <���>"
		return 0
	}
	if {[getting-users]} {
            out_msg $nick $hand $chan "��������, ���� �������� � ������ �������������. ���������� �����."
		return 0
	}
	set args [lindex $args 0]
	set args [split $args]
	set who_orig [lindex $args 0]
	set who_orig [join $who_orig]
	set who $who_orig
	if { [strlen $who_orig] > 9 } {
		set who ""
		for {set x 0} {$x<9} {incr x} { set who "$who[stridx $who_orig $x]" }
	}
	set host "$who_orig![getchanhost $who_orig $chan]"
	set target_user [finduser $host]
	set exact_match 2
	if { "$target_user" == "*" } { set exact_match [validuser $who] }
	if { $exact_match == 1 } { set target_user $who }
	if { $who_orig == "" } {
		notice $nick "�������������: ${cmdpfix}resethosts <���>"
		return 0
	}
	if { "$target_user" == "*" } {
		out_msg $nick $hand $chan "������������ \002$who_orig\002 �� ����������."
		return 0
	} 
	if {![onchan $who_orig $chan]} {
		out_msg $nick $hand $chan "\002$who_orig\002 �� �� ������."
		return 0
	}

	set host [maskhost [getchanhost $who_orig $chan]]

	setuser $target_user HOSTS "*!*@*"
	delhost $target_user "*!*@*"
	setuser $target_user HOSTS $host

	setuser $target_user XTRA LASTMOD "$nick"
	setuser $target_user XTRA LMT "RESET"

	set u_hosts [getuser $target_user HOSTS]
	if { $u_hosts == "" } { set u_hosts "������."}
	if { $u_hosts == " " } { set u_hosts "������."}
	pub_m3s_plog $nick $host $hand $chan "RESETHOST" $args
	putlog "RESETHOSTS: $nick reset hosts for user $target_user (orig: $who_orig). new hostmask: \002$host\002.	ARGS: $args"
	out_msg $nick $hand $chan "��������� �������� ��� $who_orig (\002$target_user\002). ����� ���������: $u_hosts"
}
#63.ADDWELCOME
proc pub_m3s_addwelcome {nick uhost hand chan args} {
	global TabWelcome cmdpfix botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	if {[llength [split $args]]<1} {
		notice $nick "�������������: ${cmdpfix}addwelcome <��������� ��� ����� �� �����>"
		return 0
	}
	if {![matchattr $hand n|n $chan]} {
		out_msg $nick $hand $chan "��������, �� �� �� �������� ������ $chan."
		return 0 
	}
      set TabWelcome($chan) $args
	putcmdlog "<<$nick>> !$hand! ����������� ������� addwelcome $args �� ������ $chan."
	SaveWelcome
	pub_m3s_plog $nick $uhost $hand $chan "addwelcome" $args
	out_msg $nick $hand $chan "����������� �� $chan �����������: $args"
	return 0
}
#64.DELWELCOME
proc pub_m3s_delwelcome {nick uhost hand chan args} {
	global TabWelcome cmdpfix botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	if {![matchattr $hand n|n $chan]} {
		out_msg $nick $hand $chan "��������, �� �� �� �������� ������ $chan."
		return 0 
	}
      if {![info exists TabWelcome($chan)]} { 
		out_msg $nick $hand $chan "�� ������ $chan ��������� ����������� ���."
		return 0
	}
	catch {unset TabWelcome($chan)}
	SaveWelcome
	putcmdlog "<<$nick>> !$hand! ����������� ������� delwelcome $args �� ������ $chan."
	pub_m3s_plog $nick $uhost $hand $chan "delwelcome" $args
	out_msg $nick $hand $chan "����������� �� $chan �������."
	return 0
}
#65.WELCOME
proc pub_m3s_welcome {nick uhost hand chan args} {
	global TabWelcome cmdpfix botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� welcome $args �� ������ $chan."
	notice $nick "�������������: ${cmdpfix}addwelcome <#�����> <���������> ��� ${cmdpfix}delwelcome <#�����>"
	out_msg $nick $hand $chan "��������� �����������:"
	foreach a [array name TabWelcome] {
		out_msg $nick $hand $chan "����� : $a  ��������� : $TabWelcome($a)" 
	}
}
#66.HELP!
proc pub_m3s_help {nick uhost hand chan args} {
 global botnick cmdpfix m3s_ver emailowner

 set args [lindex $args 0]
 set args [join $args]
 putcmdlog "<<$nick>> !$hand! ������� ������� �� $args �� ������ $chan."
	switch [lindex $args 0] {
      "time" {
		notice $nick "\002-----time-----\002"
		notice $nick "�������������: ${cmdpfix}time"
		notice $nick "����������� �����: \002-|-\002"
		notice $nick "�����������: ���"
		notice $nick "  ������� ����� �� ������� ����."
        }
      "news" {
		notice $nick "\002-----news-----\002"
		notice $nick "�������������: ${cmdpfix}news"
		notice $nick "����������� �����: \002-|-\002"
		notice $nick "�����������: ���"
		notice $nick "  ������� ��������� ������� � ����."
        }
     	"bot4u" {
		notice $nick "\002-----bot4u-----\002"
		notice $nick "�������������: ${cmdpfix}bot4u"
		notice $nick "����������� �����: \002-|-\002"
		notice $nick "�����������: ���"
		notice $nick "  �� ������ ��������� ���� �� ���� �����? ����������� ��� �������, ����� ������ ��� �������,"
		notice $nick "  �� �������, ��� � �� ���� ��������� ������������ ����� ��� �� 10 �������. ��� ���, ��������,"
		notice $nick "  ���� ������ ����� ���������, ���� ��� ����������� ����������� �����."
      }
	"online" {
		notice $nick "\002-----online-----\002"
		notice $nick "�������������: ${cmdpfix}online"
		notice $nick "����������� �����: \002-|-\002"
		notice $nick "�����������: ���"
		notice $nick "  ������� �������������� ���������� � ����."
	}
	"admins" {
		notice $nick "\002-----admins-----\002"
		notice $nick "�������������: ${cmdpfix}admins"
		notice $nick "����������� �����: \002-|-\002"
		notice $nick "�����������: ���"
		notice $nick "  ���������� ������� ������."
	}
	"globaladmins" {
		notice $nick "\002-----globaladmins-----\002"
		notice $nick "�������������: ${cmdpfix}globaladmins"
		notice $nick "����������� �����: \002-|-\002"
		notice $nick "�����������: ���"
		notice $nick "  ������� ������ ���������� ������� ����."
	}
	"ping" {
		notice $nick "\002-----ping-----\002"
		notice $nick "�������������: ${cmdpfix}ping <��� ��� me>"
		notice $nick "����������� �����: \002-|-\002"
		notice $nick "�����������: ���"
		notice $nick "  �������� ����� � \002�����\002. ����� �������� ������� �������� ����� ����� ����� � �����."
		notice $nick "  ���� \002me\002 ������ ������ \002����\002, �� ��� ������� ���."
      }
	"soc" {
		notice $nick "\002-----soc-----\002"
		notice $nick "�������������: ${cmdpfix}soc <���> <������+�/�>"
		notice $nick "����������� �����: \002-|-\002"
		notice $nick "�����������: ���"
		notice $nick "  ��� ������ � ����� ������� ������. \002���\002 - ��� ���� ������ ������������. \002������\002 - �������� �������. ����� �������� ������� �� ������ ������� ���� ��� ������� � ��� �. ��������� ������� ����� ���������� �������� ${cmdpfix}soc"
		notice $nick "  ������: ${cmdpfix}soc $botnick ����"
		notice $nick "  � ���� ������ ��� ����� ������ � ������� ���� �� ��������� � $botnick."
      }
	"listquotes" {
		notice $nick "\002-----listquotes-----\002"
		notice $nick "�������������: ${cmdpfix}listquotes"
		notice $nick "����������� �����: \002-|-\002"
		notice $nick "�����������: ��"
		notice $nick "  ��� ������� ���������� ����� � ��� ����."
      }
	"addquote" {
		notice $nick "\002-----addquote-----\002"
		notice $nick "�������������: ${cmdpfix}addquote <������>"
		notice $nick "����������� �����: \002-|-\002"
		notice $nick "�����������: ��"
		notice $nick "  ������� ���� ������ � ���� ����� ����. ������� �� ����� ��� ����������. ������������ ���������� ���-������ ����� :). �������� ��� ���������� ������������ � ���. �� �������."
      }
	"quote" {
		notice $nick "\002-----quote-----\002"
		notice $nick "�������������: ${cmdpfix}quote <�����>"
		notice $nick "����������� �����: \002-|-\002"
		notice $nick "�����������: ���"
		notice $nick "  ������� ��������� ������ �� ����������� � ����. ���� ������ �����, �� ������� ������ ��� �������� �������."
      }
      "commands" {
		notice $nick "\002-----commands-----\002"
		notice $nick "�������������: ${cmdpfix}commands"
		notice $nick "����������� �����: \002-|-\002"
		notice $nick "�����������: ���"
       	notice $nick "������� � ������ ��������� ��� ������� �� ������, ��� �� ����� ��� �������."
	      notice $nick "����� �������� ������ /msg $botnick ${cmdpfix}commands #�����."
      }
      "version" {
		notice $nick "\002-----version-----\002"
		notice $nick "�������������: ${cmdpfix}version"
		notice $nick "����������� �����: \002-|-\002"
		notice $nick "�����������: ���"
		notice $nick "������� ���������� � ������ ����, ��������� � ����������� �����."
	}
	"help" {
		notice $nick "��� ����� ������ �� �������? :) ׸����� �������! � ������ �� �������! ��������! ����!"
	}
	"greeting" {
		notice $nick "\002-----greeting-----\002"
		notice $nick "�������������: ${cmdpfix}greeting \[�����������\]"
		notice $nick "����������� �����: \002-|-\002"
		notice $nick "�����������: ��"
		notice $nick "  ������������� ����������� �� ������. ��������, �� ��������� �����, ��� ������������, ��� �������, ����� ����, ��� ������� ��� ����� 3-� �����."
		notice $nick "  ������������� \002${cmdpfix}greeting\002 ��� ���������� ������� ������ �����������."
		notice $nick "  ������������� \002${cmdpfix}greeting del\002 ������ ������� �����������."
		notice $nick "  ������������� \002${cmdpfix}globalgreeting\002 ��������� ���������� ����������� (��� ���� �������)."
	}
	"globalgreeting" {
		notice $nick "\002-----globalgreeting-----\002"
		notice $nick "�������������: ${cmdpfix}globalgreeting \[�����������\]"
		notice $nick "����������� �����: \002-|-\002"
		notice $nick "�����������: ��"
		notice $nick "  ������������� ����������(�� ���� �������) �����������. ��������, �� ��������� �����, ��� ������������, ��� �������, ����� ����, ��� ������� ��� ����� 3-� �����."
		notice $nick "  ������������� \002${cmdpfix}globalgreeting\002 ��� ���������� ������� ������ ���������� �����������."
		notice $nick "  ������������� \002${cmdpfix}globalgreeting del\002 ������ ������� ���������� �����������."
		notice $nick "  ������������� \002${cmdpfix}greeting\002 ��������� ���������� ����������� (��� ���� �������)."
	}
      "output" {
		notice $nick "\002-----output-----\002"
		notice $nick "�������������: ${cmdpfix}output <notice/public> \[<global>\]"
		notice $nick "����������� �����: \002-|-\002"
		notice $nick "�����������: ��"
       	notice $nick "������������� ��� ��� ����� �������� ��� �� �������. �������� ������ � ������������������ �������������. ���� �������� � ������ ��� ����� global - ������ ����� ������ ������ ��� ������� ������."
	      notice $nick "������� \002global\002 ������������� output ��� ��� ���� �������, ������ ���� output ���� ��� ��������� ������� �������� �������������."
        }	
	"partyline" {
		notice $nick "\002-----partyline-----\002"
		notice $nick "�������������: ${cmdpfix}partyline"
		notice $nick "����������� �����: \002p|-\002"
		notice $nick "�����������: ��"
		notice $nick "  ���������� � ��������� (��� ���� dcc ������)."
	}
	"identify" {
		notice $nick "\002-----identify-----\002"
		notice $nick "�������������: ${cmdpfix}identify <���>"
		notice $nick "����������� �����: \002-|ov\002"
		notice $nick "�����������: ��"
		notice $nick "  ���� ���� \002����\002 � ���� ������ ������ ���� � ������� ����������� �����."
		notice $nick "  ������������ ��� �������� ����, �������� �� \002���\002 � ���������������� ���, �� ���� ���� ������."
	}
	"whois" {
		notice $nick "\002-----whois-----\002"
		notice $nick "�������������: ${cmdpfix}whois <���>"
		notice $nick "����������� �����: \002-|ov\002"
		notice $nick "�����������: ��"
		notice $nick "  ���������� ����� � �������� \002����\002."
		notice $nick "  ����������:"
		notice $nick "        \[\002������\002\] - ����� �� ������� �� �����."
		notice $nick "        \[\002��� ������\002\] - �� ����� ������."
		notice $nick "        \[\002�����������\002\] - \002���\002 ����������� (���� ��� � ���������� \002Q\002 ����)."
		notice $nick "        \[������������ �������] - ��� ��������� ������� ����� ������������ � ����� ��������."
		notice $nick "     ����������� �����:"
		notice $nick "        \002I\002 - SHUDUP ����, ���� �� � ��� �����, ��� �� �������� �� ���� ������� (���������)."
		notice $nick "            ������� ��������."
		notice $nick "        \002P\002 - ������, ����� ������������ ������ ��� �������, ��� ���������� ��������."
		notice $nick "        \002H\002 - ������ ������, ���� ��� � P, ������ � ���� ����������� ���. �� �������� ��� P."
		notice $nick "        \002L\002 - ���������� ������������, ������ ���������� �������� ����� ������ ��� ����� ��� �������."
		notice $nick "        \002Q\002 - �����������. �������� ���������."
		notice $nick "        \002N\002 - ��������� ��������� NOTICE, �������� � ��������� �������� \002$output\002"
	}	
	"access" {
		notice $nick "\002-----access-----\002"
		notice $nick "�������������: ${cmdpfix}access <���>"
		notice $nick "����������� �����: \002-|ov\002"
		notice $nick "�����������: ��"
		notice $nick "  ���������� ���������� ������ ������ ��� \002����\002, � ����� ����� �� ���� ������� ����."
	}
	"status" {
		notice $nick "\002-----status-----\002"
		notice $nick "�������������: ${cmdpfix}status"
		notice $nick "����������� �����: \002-|ov\002"
		notice $nick "�����������: ��"
		notice $nick "  ������� ���������� ����."
	}
	"flags" {
		notice $nick "\002-----flags-----\002"
		notice $nick "�������������: ${cmdpfix}flags <���/hand> \[#�����\]"
		notice $nick "����������� �����: \002-|ov\002"
		notice $nick "�����������: ��"
		notice $nick "  ���������� ���������� � ��������� ����� ������������ �� ������������� ������."
	}
       "topic" {
		notice $nick "\002-----topic-----\002"
		notice $nick "�������������: ${cmdpfix}topic <���� ������>"
		notice $nick "����������� �����: \002-|ov\002"
		notice $nick "�����������: ��"
		notice $nick "     ��� ������ \002����\002 �� ������."
        }
	"stats" {
		notice $nick "\002-----stats-----\002"
		notice $nick "�������������: ${cmdpfix}stats"
		notice $nick "����������� �����: \002-|ov\002"
		notice $nick "�����������: ��"
		notice $nick "  ������� ���������� ������."
	}
	"invite" {
		notice $nick "\002-----invite-----\002"
		notice $nick "�������������: ${cmdpfix}invite <���>"
		notice $nick "����������� �����: \002-|ov\002"
		notice $nick "�����������: ��"
		notice $nick "  ��� ���������� \002���\002 ����� �� �����."
	}
	"voice" {
		notice $nick "\002-----voice-----\002"
		notice $nick "�������������: ${cmdpfix}voice <���>"
		notice $nick "����������� �����: \002-|ov\002"
		notice $nick "�����������: ��"
		notice $nick "  ���� ���� \002����\002 �� ������� ������."
	}
	"channels" {
		notice $nick "\002-----channels-----\002"
		notice $nick "�������������: ${cmdpfix}channels"
		notice $nick "����������� �����: \002-|ov\002"
		notice $nick "�����������: ��"
		notice $nick "  ������� ��� ������, �������������� �����."
	}
	"banlist" {
		notice $nick "\002-----banlist-----\002"
		notice $nick "�������������: ${cmdpfix}banlist"
		notice $nick "����������� �����: \002-|ov\002"
		notice $nick "�����������: ��"
		notice $nick "  ������� ������ �����."
	}
	"devoice" {
		notice $nick "\002-----devoice-----\002"
		notice $nick "�������������: ${cmdpfix}devoice <���>"
		notice $nick "����������� �����: \002-|ov\002"
		notice $nick "�����������: ��"
		notice $nick "  ������� ���� � \002����\002."
	}
	"hop" {
		notice $nick "\002-----hop-----\002"
		notice $nick "�������������: ${cmdpfix}hop <���>"
		notice $nick "����������� �����: \002-|ov\002"
		notice $nick "�����������: ��"
		notice $nick "  ���� ������ \002����\002."
	}
	"dehop" {
		notice $nick "\002-----dehop-----\002"
		notice $nick "�������������: ${cmdpfix}dehop <���>"
		notice $nick "����������� �����: \002-|ov\002"
		notice $nick "�����������: ��"
		notice $nick "  ������� ������ � \002����\002."
	}
	"whoid" {
		notice $nick "\002-----whoid-----\002"
		notice $nick "�������������: ${cmdpfix}whoid <�����>"
		notice $nick "����������� �����: \002-|ov\002"
		notice $nick "�����������: ��"
		notice $nick "  ���������� ������������������ ������������� �������� ������. ���� ������ \002����\002, �� ������� ������������������ �������������, ������� ��������� ����."
	}
	"mode" {
		notice $nick "\002-----mode-----\002"
		notice $nick "�������������: ${cmdpfix}mode <����>"
		notice $nick "����������� �����: \002-|o\002"
		notice $nick "�����������: ��"
		notice $nick "  ������ ���� ������ �� \002����\002."
		notice $nick "  ������: ${cmdpfix}mode +m"
	}
      "kick" {
		notice $nick "\002-----kick-----\002"
		notice $nick "�������������: ${cmdpfix}kick <���> <�������>"
            notice $nick "����������� �����: \002-|o\002"
		notice $nick "�����������: ��"
		notice $nick "  ������ ������������ \002���\002 � ������ � �������� ���� ��������."
        }
	"quick" {
		notice $nick "\002-----quick-----\002"
		notice $nick "�������������: ${cmdpfix}quick <���> <�������>"
            notice $nick "����������� �����: \002-|o\002"
		notice $nick "�����������: ��"
		notice $nick "  ������ � ������� ������������ \002���\002 � ������ � �������� ���� �������� �� 7 ������, ����� ��� �� ���� ����� �� ������������� ���������."
        }	
	"ban" {
		notice $nick "\002-----ban-----\002"
		notice $nick "�������������: ${cmdpfix}ban <���/����> <�����> <�������>"
		notice $nick "����������� �����: \002-|o\002"
		notice $nick "�����������: ��"
		notice $nick "  ���� \002���\002 �� ������, ��� ������� ��� ����"
		notice $nick "  ������� ���. ���� ���, �� ������� ���� � �������"
		notice $nick "  �� ���������� ���� �����. \002�����\002 - ����������"
		notice $nick "  � �������, ����� ������� �������� ��� (�� 1 �� 3000 �����)."
		notice $nick "  \002�������\002 ��� ������� ������ �� ��������."
	}
	"unban" {
		notice $nick "\002-----unban-----\002"
		notice $nick "�������������: ${cmdpfix}unban <����>"
		notice $nick "����������� �����: \002-|o\002"
		notice $nick "�����������: ��"
		notice $nick "  ����������� \002����\002 �� ������. ����� ��������� ������� �����"
		notice $nick "  ������: ${cmdpfix}unban *!*BILL*@*.gates.loh"
	}
	"chattr" {
		notice $nick "\002-----chattr-----\002"
		notice $nick "�������������: ${cmdpfix}chattr <���> \[<�����>\]"
		notice $nick "����������� �����: \002-|o\002"
		notice $nick "�����������: ��"
		notice $nick "  �������� (\002�����\002) ������������."
		notice $nick "  �����: +v ���������; +o ��������; +m ������; +n; ��������; +a ������; +k �������; +d -��������.."
		notice $nick "  ������ �����:"
		notice $nick "   \002I\002 - SHUDUP ����, ���� �� � ��� ����, ��� ����� ������������ ���� ��������� �������."
		notice $nick "  	   �� ������� ������� �� ����������������."
		notice $nick "   \002P\002 - ������. ��� �������� ������������, ����� ���������"
		notice $nick "   \002H\002 - ������� ������, ���� ��� � P, �� ������ ��� ��� � ����� ���������. ��� P �� ��������. "
		notice $nick "   \002L\002 - ���������� ������������. ����� ����� ��������� ���� �� ����� ������� � �������� ��� �����."
		notice $nick "   \002Q\002 - �����������. �������� ����."
		notice $nick "   \002N\002 - ����� NOTICE ��������� �� ����. ����������� \002\$output\002 ��������."
		notice $nick "   ��������� ����� ����� ���������� �������� \002${cmdpfix}help uflags\002 � \002${cmdpfix}help levels"
	}
	"op" {
		notice $nick "\002-----op-----\002"
		notice $nick "�������������: ${cmdpfix}op <���>"
		notice $nick "����������� �����: \002-|o\002"
		notice $nick "�����������: ��"
		notice $nick "  ���� ������ ��������� \002����\002 �� ������� ������. ���� ��� �� ������, �� �� ������� ���������."
	}
	"say" {
		notice $nick "\002-----say-----\002"
		notice $nick "�������������: /msg $botnick ${cmdpfix}say <�����> <�����>"
		notice $nick "����������� �����: \002-|o\002"
		notice $nick "�����������: ��"
		notice $nick "  ������ \002�����\002 �� \002������\002."
	}
	"act" {
		notice $nick "\002-----act-----\002"
		notice $nick "�������������: /msg $botnick ${cmdpfix}act <�����> <�����>"
		notice $nick "����������� �����: \002-|o\002"
		notice $nick "�����������: ��"
		notice $nick "  ������� �������� \002�����\002 �� \002������\002."
	}
	"banperm" {
		notice $nick "\002-----banperm-----\002"
		notice $nick "�������������: ${cmdpfix}banperm <���/����> <�������>"
		notice $nick "����������� �����: \002-|o\002"
		notice $nick "�����������: ��"
		notice $nick "  ���� \002���\002 �� ������, ��� ������� ��� ����"
		notice $nick "  ������� ���. ���� ���, �� ������� ���� � �������"
		notice $nick "  �� ���������� ���� �����. �������� ���������� ���."
	}
	"deop" {
		notice $nick "\002-----deop-----\002"
		notice $nick "�������������: ${cmdpfix}deop \[<���>\]"
		notice $nick "����������� �����: \002-|o\002"
		notice $nick "�����������: ��"
		notice $nick "  ������� �� � \002����\002 �� ������� ������. ���� ��� �� ������, �� ������� ����� ���������."
	}
	"rejoin" {
		notice $nick "\002-----rejoin-----\002"
		notice $nick "�������������: ${cmdpfix}rejoin"
		notice $nick "����������� �����: \002-|m\002"
		notice $nick "�����������: ��"
		notice $nick "  ���������� ���� ��������� �� �����."
	}
      "chaninfo" {
		notice $nick "\002-----chaninfo-----\002"
		notice $nick "�������������: ${cmdpfix}chaninfo <�����>"
		notice $nick "����������� �����: \002-|m\002"
		notice $nick "�����������: ��"
		notice $nick "  ������� ������� ��������� ������. ��. ${cmdpfix}help chanset"
       }
 	"mass" {
		notice $nick "\002-----mass-----\002"
		notice $nick "�������������: ${cmdpfix}mass deop/op/kick/ban/voice/devoice"
		notice $nick "����������� �����: \002-|m\002"
		notice $nick "�����������: ��"
		notice $nick "  �������, �����, ������, �������, ���� ��� ������ ���� �� ���� ������������� ������."
       }
 	"welcome" {
		notice $nick "\002-----welcome-----\002"
		notice $nick "�������������: ${cmdpfix}welcome"
		notice $nick "����������� �����: \002-|n\002"
		notice $nick "�����������: ��"
		notice $nick "  ������� ������� ����������� ������."
       }
	"chanset" {
		notice $nick "\002-----chanset-----\002"
		notice $nick "�������������: ${cmdpfix}chanset <�����> <���> \[���������\]"
		notice $nick "����������� �����: \002-|n\002"
		notice $nick "�����������: ��"
		notice $nick "  ��������� �������� ��������� ������."
		notice $nick "  �������� ����� ������ ����� ��������� ���: \002http://www.egghelp.org/commands/channels.shtml#chaninfo"
	}
	"templeave" {
		notice $nick "\002-----templeave-----\002"
		notice $nick "�������������: ${cmdpfix}templeave"
		notice $nick "����������� �����: \002-|n\002"
		notice $nick "�����������: ��"
		notice $nick "  ��� �������� �������� ����� ��� �������� ����� ����� � ������ ������."
		notice $nick "  ��� ����������� ����, �������: \002/msg $botnick ${cmdpfix}comeback #�����"
	}
      "comeback" {
		notice $nick "\002-----comeback-----\002"
		notice $nick "�������������: /msg $botnick ${cmdpfix}comeback #�����"
		notice $nick "����������� �����: \002-|n\002"
		notice $nick "�����������: ��"
		notice $nick "  ��� �������� �� ����� ����� ���������� ������. ��. ${cmdpfix}help templeave"
	}
	"addwelcome" {
		notice $nick "\002-----addwelcome-----\002"
		notice $nick "�������������: ${cmdpfix}addwelcome <�����������>"
		notice $nick "����������� �����: \002-|n\002"
		notice $nick "�����������: ��"
		notice $nick "  ������� ����������� �� �����, ������� ����� ���������� ������� ���������."
       }
	"delwelcome" {
		notice $nick "\002-----delwelcome-----\002"
		notice $nick "�������������: ${cmdpfix}delwelcome <�����������>"
		notice $nick "����������� �����: \002-|n\002"
		notice $nick "�����������: ��"
		notice $nick "  ������ ����������� ������������� �����."
       }
	"backup" {
		notice $nick "\002-----backup-----\002"
		notice $nick "�������������: ${cmdpfix}backup"
		notice $nick "����������� �����: \002m|-\002"
		notice $nick "�����������: ��"
		notice $nick "  ������ ��������� ����� ����� ������������� � �������."
	}
	"save" {
		notice $nick "\002-----save-----\002"
		notice $nick "�������������: ${cmdpfix}save"
		notice $nick "����������� �����: \002m|-\002"
		notice $nick "�����������: ��"
		notice $nick "  ��������� ����� ������� � ������������� �� ����."
	}
	"reload" {
		notice $nick "\002-----reload-----\002"
		notice $nick "�������������: ${cmdpfix}reload"
		notice $nick "����������� �����: \002m|-\002"
		notice $nick "�����������: ��"
		notice $nick "  ����������� ���� �������������."
	}
	"restart" {
		notice $nick "\002-----restart-----\002"
		notice $nick "�������������: ${cmdpfix}restart"
		notice $nick "����������� �����: \002m|-\002"
		notice $nick "�����������: ��"
		notice $nick "  ����������� ����."
	}

	"rehash" {
		notice $nick "\002-----rehash-----\002"
		notice $nick "�������������: ${cmdpfix}rehash"
		notice $nick "����������� �����: \002m|-\002"
		notice $nick "�����������: ��"
		notice $nick "  ������� ����. ����������� ��� ������� �� ������ �� ����."
	}
	"uptime" {
		notice $nick "\002-----uptime-----\002"
		notice $nick "�������������: ${cmdpfix}uptime"
		notice $nick "����������� �����: \002m|-\002"
		notice $nick "�����������: ��"
		notice $nick "  ���������� uptime."
	}
	"botnick" {
		notice $nick "\002-----botnick-----\002"
		notice $nick "�������������: ${cmdpfix}botnick <���>"
		notice $nick "����������� �����: \002m|-\002"
		notice $nick "�����������: ��"
		notice $nick "  ������ ��� ����."
	}
	"jump" {
		notice $nick "\002-----jump-----\002"
		notice $nick "�������������: ${cmdpfix}jump <������>\[:����\] \[������\]"
		notice $nick "����������� �����: \002m|-\002"
		notice $nick "�����������: ��"
		notice $nick "  ������ ������ � ���� ����."
	}
	"addhost" {
		notice $nick "\002-----addhost-----\002"
		notice $nick "�������������: ${cmdpfix}addhost <���/hand> <����>"
		notice $nick "����������� �����: \002m|-\002"
		notice $nick "�����������: ��"
		notice $nick "  ��������� \002����\002 � ������� ������ \002hand\002 (��� ����)."
	}
      "delhost" {
		notice $nick "\002-----delhost-----\002"
		notice $nick "�������������: ${cmdpfix}delhost <���/hand> <����>"
		notice $nick "����������� �����: \002m|-\002"
		notice $nick "�����������: ��"
		notice $nick "  ������� \002����\002 � \002hand\002 (��� ����)."
	}
	"gchattr" {
		notice $nick "\002-----gchattr-----\002"
		notice $nick "�������������: ${cmdpfix}gchattr <���/hand> <�����>"
		notice $nick "����������� �����: \002m|-\002"
		notice $nick "�����������: ��"
		notice $nick "  ������������� � �������� ���������� ����� ��� ����. �� ${cmdpfix}help chattr"
	}
      "broadcast" {
		notice $nick "\002-----broadcast-----\002"
		notice $nick "�������������: ${cmdpfix}broadcast <���������>"
		notice $nick "����������� �����: \002m|-\002"
		notice $nick "�����������: ��"
		notice $nick "  ������ ��������� ���� \002���������\002 �� ���� ������� ����. ������������ ��� ���������� ��������."
	}
      "rempass" {
		notice $nick "\002-----rempass-----\002"
		notice $nick "�������������: ${cmdpfix}rempass <���>"
		notice $nick "����������� �����: \002m|-\002"
		notice $nick "�����������: ��"
		notice $nick "  ������� ������ ��� ������������ \002���\002. � ���� ������ �� ������ ����� ���������� �����. ������������ \002������\002 ��� ����� ��� ��������� ������ ������������� � \002������ �� ��� �������\002."
	}
	"resethosts" {
		notice $nick "\002-----resethosts-----\002"
		notice $nick "�������������: ${cmdpfix}resethosts <���>"
		notice $nick "����������� �����: \002n|-\002"
		notice $nick "�����������: ��"
		notice $nick "  ������� ��� ����� � \002����\002."
		notice $nick "  ���� \002���\002 �� ������, ��������� ������� ����� ����."
		notice $nick "  �����, ��������� �������� ������."
	}
	"join" {
		notice $nick "\002-----join-----\002"
		notice $nick "�������������: ${cmdpfix}join <#�����>"
		notice $nick "����������� �����: \002n|-\002"
		notice $nick "�����������: ��"
		notice $nick "  ��������� � ���� ����� �����. �� �������� ���������� ���������."
	}
	"part" {
		notice $nick "\002-----part-----\002"
		notice $nick "�������������: ${cmdpfix}part <#�����>"
		notice $nick "����������� �����: \002n|-\002"
		notice $nick "�����������: ��"
		notice $nick "  ��� ������� ����� ������, ���� ��� ������ � �������� �����. (����������!)"
	}
	"enable" {
		notice $nick "\002-----enable-----\002"
		notice $nick "�������������: ${cmdpfix}enable <���>"
		notice $nick "����������� �����: \002n|-\002"
		notice $nick "�����������: ��"
		notice $nick "  ��������� \002����\002 ������������ ��������� �������."
		notice $nick "  ��������: ������������, ���� �� ������������ ��� ��������� \002${cmdpfix}disable\002."
	}
	"disable" {
		notice $nick "\002-----disable-----\002"
		notice $nick "�������������: ${cmdpfix}disable <���>"
		notice $nick "����������� �����: \002n|-\002"
		notice $nick "�����������: ��"
		notice $nick "  ��������� \002����\002 ������������ ��������� ������� � �����������."
	}
	"tcl" {
		notice $nick "\002-----tcl-----\002"
		notice $nick "�������������: ${cmdpfix}tcl <���>"
		notice $nick "����������� �����: \002n|-\002"
		notice $nick "�����������: ��"
		notice $nick "  �������� Tcl �������. ����� ���� ���������."
	}
	"shell" {
		notice $nick "\002-----shell-----\002"
		notice $nick "�������������: ${cmdpfix}shell <���>"
		notice $nick "����������� �����: \002n|-\002"
		notice $nick "�����������: ��"
		notice $nick "  �������� Shell �������. ����� ���� ���������."
	}
	"die" {
		notice $nick "\002-----die-----\002"
		notice $nick "�������������: ${cmdpfix}die \[�������\]"
		notice $nick "����������� �����: \002n|-\002"
		notice $nick "�����������: ��"
		notice $nick "  �������� ����."
	}
	"chpass" {
		notice $nick "\002-----chpass-----\002"
		notice $nick "�������������: ${cmdpfix}chpass <���> <����� ������>"
		notice $nick "����������� �����: \002n|-\002"
		notice $nick "�����������: ��"
		notice $nick "  �������� ������ ��� ������������ \002���\002. ������������ \002������\002 ��� ����� ��� ��������� ������ ������������� � \002������ �� ��� �������\002. ��������� ������������ ������� ������ ����� ��, ������ ��� �� ������� ������� � ������ � ������ ���������� ����� ������ ����������������� ������."
	}
	"addvoice" {
		notice $nick "\002-----addvoice-----\002"
		notice $nick "�������������: ${cmdpfix}addvoice <���> \[����\]"
		notice $nick "����������� �����: \002-|o\002"
		notice $nick "�����������: ��"
		notice $nick "  ��������� ����� ��� ���������� �������� ������ ��� ������ \002���\002."
		notice $nick "  ���� �� �� ������ � \002����\002 �� ������"
		notice $nick "  ��� ������� ���� ��� � ������� ���. ���� ������������ �� ������ ���, �������� ������� ����."
	}
	"addfriend" {
		notice $nick "\002-----addfriend-----\002"
		notice $nick "�������������: ${cmdpfix}addfriend <���> \[����\]"
		notice $nick "����������� �����: \002-|o\002"
		notice $nick "�����������: ��"
		notice $nick "  ��������� ����� ��� ����� ���� ��� ������ \002���\002 �� ������� ������."
		notice $nick "  ���� �� �� ������ � \002����\002 �� ������"
		notice $nick "  ��� ������� ���� ��� � ������� ���. ���� ������������ �� ������ ���, �������� ������� ����."
	}	
	"addop" {
		notice $nick "\002-----addop-----\002"
		notice $nick "�������������: ${cmdpfix}addop <���> \[����\]"
		notice $nick "����������� �����: \002-|m\002"
		notice $nick "�����������: ��"
		notice $nick "  ��������� ����� ��� ��������� �������� ������ ��� ������ \002���\002."
		notice $nick "  ���� �� �� ������ � \002����\002 �� ������"
		notice $nick "  ��� ������� ���� ��� � ������� ���. ���� ������������ �� ������ ���, �������� ������� ����."
	}
	"adduser" {
		notice $nick "\002-----adduser-----\002"
		notice $nick "�������������: ${cmdpfix}adduser <���> \[����\]"
		notice $nick "����������� �����: \002-|m\002"
		notice $nick "�����������: ��"
		notice $nick "  ��������� � ���� ���� ������ ������������ ��� ������ \002���\002."
		notice $nick "  ���� �� �� ������ � \002����\002 �� ������"
		notice $nick "  ��� ������� ���� ��� � ������� ���. ���� ������������ �� ������ ���, �������� ������� ����."
	}
	"addmaster" {
		notice $nick "\002-----addmaster-----\002"
		notice $nick "�������������: ${cmdpfix}addmaster <���> \[����\]"
		notice $nick "����������� �����: \002-|n\002"
		notice $nick "�����������: ��"
		notice $nick "  ��������� ����� ��� ������� �������� ������ ��� ������ \002���\002."
		notice $nick "  ���� �� �� ������ � \002����\002 �� ������"
		notice $nick "  ��� ������� ���� ��� � ������� ���. ���� ������������ �� ������ ���, �������� ������� ����."
	}
	"addowner" {
		notice $nick "\002-----addowner-----\002"
		notice $nick "�������������: ${cmdpfix}addowner <���> \[����\]"
		notice $nick "����������� �����: \002n|-\002"
		notice $nick "�����������: ��"
		notice $nick "  ��������� ����� ��� ��������� �������� ������ ��� ������ \002���\002."
		notice $nick "  ���� �� �� ������ � \002����\002 �� ������"
		notice $nick "  ��� ������� ���� ��� � ������� ���. ���� ������������ �� ������ ���, �������� ������� ����."
	}
	"delvoice" {
		notice $nick "\002-----delvoice-----\002"
		notice $nick "�������������: ${cmdpfix}delvoice <���>"
		notice $nick "����������� �����: \002-|o\002"
		notice $nick "�����������: ��"
		notice $nick "  ������ ���������� �������� ������ ��� ������ \002���\002."
	}
	"delfriend" {
		notice $nick "\002-----delfriend-----\002"
		notice $nick "�������������: ${cmdpfix}delfriend <���>"
		notice $nick "����������� �����: \002-|o\002"
		notice $nick "�����������: ��"
		notice $nick "  ������ ����� ���� �� ������� ������ ��� ������ \002���\002."
	}
	"delop" {
		notice $nick "\002-----delop-----\002"
		notice $nick "�������������: ${cmdpfix}delop <���>"
		notice $nick "����������� �����: \002-|m\002"
		notice $nick "�����������: ��"
		notice $nick "  ������ ��������� �������� ������ ��� ������ \002���\002."
	}
	"delmaster" {
		notice $nick "\002-----delmaster-----\002"
		notice $nick "�������������: ${cmdpfix}delmaster <���>"
		notice $nick "����������� �����: \002-|n\002"
		notice $nick "�����������: ��"
		notice $nick "  ������ ������� �������� ������ ��� ������ \002���\002."
	}
	"deluser" {
		notice $nick "\002-----deluser-----\002"
		notice $nick "�������������: ${cmdpfix}deluser <���>"
		notice $nick "����������� �����: \002n|-\002"
		notice $nick "�����������: ��"
		notice $nick "  ������ ������������ ��� ������ \002���\002."
	}
	"delowner" {
		notice $nick "\002-----delowner-----\002"
		notice $nick "�������������: ${cmdpfix}delowner <���>"
		notice $nick "����������� �����: \002n|-\002"
		notice $nick "�����������: ��"
		notice $nick "  ������ ��������� �������� ������ ��� ������ \002���\002."
	}
	"sex" {
		notice $nick "�������� � ����������!"
	}
	"me" {
		notice $nick "� ���� ������� ���!"
		notice $nick "�������� �������� \002${cmdpfix}help\002 ��� ������ �� ��������."
	}
	"him" {
		notice $nick "������, ��� ��� �� ������ :)"
	 }
      "levels" {
       notice $nick "\002-----levels-----\002"
       notice $nick "���������� 2 ���� ��������: \002���������\002 � \002����������\002. ��������� - ����� ���� �� ����� ������, �� ������� �� ����, � ���������� ����� ���� �� ����� ������ ����."
       notice $nick "��� ������ ����������� � ���� ������. ��� ������ � ������������� �����, ��� ������ � ��� �������� � ����. ����� ������� ���: \002���������|����������\002"
       notice $nick "�������� \002of|a\002 ��������, ��� � ��� ��������(�� ��� ������, �� ������� �� ������� ������� ��������� �������) ���� ����� \002of\002, ���������� �������� � ����, � ���������� ���� ����������� \002a\002, ���������� ������."
     }
      "uflags" {
		notice $nick "\002-----uflags-----\002"
		notice $nick "�������� ����� ������������, ��������� ��� ���������:"
		notice $nick "���������� �����(����� ���� �������� ����������� �����������, ��������� � �����������):"
		notice $nick "     \002+v\002 - ���������� ���������"
		notice $nick "     \002+o\002 - ���������� ��������"
		notice $nick "     \002+m\002 - ���������� ������"
		notice $nick "     \002+n\002 - ���������� ��������"
		notice $nick "     \002+t\002 - ���������� ������� ������(���� �����)"
		notice $nick "     \002+x\002 - ����� ������ � ������ ����"
            notice $nick "     \002+j\002 - ����� ������ ������� � ������ ����"
            notice $nick "     \002+p\002 - ����� ������ � DCC ���������"
            notice $nick "     \002+b\002 - ��� ���"
            notice $nick "     \002+d\002 - ������������� ����� ���������"
            notice $nick "     \002+a\002 - ������������� ����� ������� ��� ����� �� �����"
            notice $nick "     \002+k\002 - ������������� ����� �������� ��� ����� �� �����"
            notice $nick "     \002+f\002 - ����(��� �� ������ � �� ������ ���)"
            notice $nick "     \002+h\002 - ��� ����� ���, �������� ����� �� �����"
            notice $nick "     \002+g\002 - ���� ���� ���� ��� ����� �� �����"
            notice $nick "     \002+P\002 - �������� ������������, ����� ��������"
            notice $nick "     \002+H\002 - ��������� +P �����, ��� +P �� ��������"
            notice $nick "     \002+L\002 - �������� � ������������� ����� ��������� ������ ���������� ������"
            notice $nick "     \002+I\002 - ��� �� ����� ����������� �� ��������� ������� ����� ��������"
            notice $nick "     \002+N\002 - ���� ���� �����, �� ��� ����� ������� ������������ �������. �� �� �����, ��� � ${cmdpfix}output."
            notice $nick "��������� ����� ����� �� ��, ������ ����� �������� �� �����(�� ������������) ������."
       }
	 "" {
		notice $nick "\002-----$botnick help system\002 $m3s_ver\002-----\002"
		notice $nick "��� ������ ������ ��������� ��� ������ �������\002 ${cmdpfix}commands\002 �� ������ ��� � ������� � ����."
		notice $nick "��� ������� � ���������� ������� �������\002 ${cmdpfix}help <�������>\002"
		notice $nick "���� �� �� ��������� ������ ����, �� ���� ��� �� �������� ���, �� �������� ����, ������ ��� � ������ \002newuser\002"
		notice $nick "��� ������� ��� � ���� ���� � �� �������� ������ � ���� ��� ������. ����� ��� ����� ���������� ��������� ������,"
		notice $nick "����� ����� �� ���� ��������� ����� �� ������ �����, � ����� ����� ���������������� �� ������� ���� � ����� �������:"
		notice $nick "��� ��������� ������ �������: \002/msg\002 $botnick \002pass\002 <��� ������>"
		notice $nick "��� ����� ������� ������ �������: \002/msg\002 $botnick \002pass\002 <��� ������ ������> <��� ����� ������>"
		notice $nick "���������� �� �������� ��������� ���� �� ����� �������� �������� \002${cmdpfix}bot4u"
            notice $nick "     ��� ������� ��������� �� \002$emailowner\002"
      }
	default { notice $nick "�������� $nick. ������� �� [lindex $args 0] �����������! ���� ��� ������������� �����, ���������� � ���������� $botnick ��� ����������."	}
	}
}
#67.COMMANDS
proc pub_m3s_commands {nick uhost hand chan args} { 
	global botnick cmdpfix
	say $nick "��������� ��� ������� ��� $botnick:"
	say $nick "\002��������:\002 ��� ������� ���������� � ������� \002${cmdpfix}\002"
	say $nick "��������: \002help time bot4u online admins globaladmins ping commands quote"
 	if {![validuser [nick2hand $nick]]} {
		say $nick "��������� ������� ����� �������� ���, ����� �����������. ��� ������� � ����������� ���������� ${cmdpfix}help"
		return 0
	}
	say $nick "����������������: \002greeting globalgreeting output auth deauth listquotes addquote"
	if { $chan != "MSG" } {
		if {([matchattr $hand -|vomn $chan]) || ([matchattr $hand vomn])} {
			say $nick "\002���� ��������� ������� �� $chan:\002"
		     	say $nick "����������: \002voice devoice identify whois access status flags topic stats invite voice channels banlist devoice halfop dehalfop whoid\002"
		}
		if {([matchattr $hand -|omn $chan]) || ([matchattr $hand omn])} {
		     	say $nick "���������: \002chattr op deop banperm banwhois addvoice addfriend delvoice delfriend say act mode kick quick ban unban\002"
		}
		if {([matchattr $hand -|mn $chan]) || ([matchattr $hand mn])} {
		     	say $nick "�������: \002chaninfo rejoin mass adduser addop delop\002"
		}
		if {([matchattr $hand -|n $chan]) || ([matchattr $hand n])} {
		     	say $nick "���������: \002chanset templeave welcome addwelcome delwelcome addmaster delmaster comeback\002"
		}
	}
		if {[matchattr $hand mn]} {
			say $nick "\002���� ������������ ���������� �������:\002"
		     	say $nick "�������: \002backup save reload restart rehash uptime botnick addhost delhost gchattr broadcast jump rempass\002"
		}
		if {[matchattr $hand n]} {
		     	say $nick "���������: \002resethosts join part enable disable tcl shell die addowner delowner deluser chpass\002"
		}
		if {[matchattr $hand p]} {
		     	say $nick "\0034� ��� ���� ������ � partyline!\003 \002partyline"
		}
	if { "$chan" == "MSG" } {
		say $nick "\002��������:\002 ����� ������� ��� ������� ��������� ���, ������� ����������,� ����� �������, ��������� ��� �� ������������ ������,"
		say $nick "������� \002${cmdpfix}commands\002 � ���� ������, ��� \002/msg $botnick ${cmdpfix}commands #�����"
	}
	say $nick "��� ��������� �������������� ���������� � ������� ������: \002${cmdpfix}help \002\[\002�������\002\]"
	if {([matchattr $hand -|v $chan]) || ([matchattr $hand v])} { say $nick "�������������� �������:\002${cmdpfix}help level\002, \002${cmdpfix}help umode\002" }
	say $nick "����������� ������ ������� �����������: \002/msg $botnick auth \002<\002������\002>\002"
	say $nick "����� ������ ������."
	putcmdlog "<<$nick>> !$hand! ����� ���� commands $args."
}
#68.VERSION
proc pub_m3s_version {nick host hand chan arg} {
 global botnick m3s_ver
      putserv "PRIVMSG $nick : � $botnick."
      putserv "PRIVMSG $nick : ������ �������: $m3s_ver"
      putserv "PRIVMSG $nick : ����������� ����: http://camapa.net.ru/m3s"
      putserv "PRIVMSG $nick : ���������: Sotnikov Jaroslav aka MOSSs"
      putserv "PRIVMSG $nick : Email: mosss@dalnet.ru"
      putcmdlog "<<$nick>> !$hand! ����������� ������� version �� ������ $chan"
}
#69.WHOID
proc pub_m3s_whoid {nick host hand chan arg} {
	global botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	set ch $chan
	set whoflags ""
	if {[llength $arg] > 0 } { set whoflags [lindex $arg 0] } 
	m3s_whoid $nick $host $hand $ch $whoflags
	return 0
}
#70.REMPASS
proc pub_m3s_rempass {nick host hand chan arg} {
	global botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	
	set arg [charfilter $arg]
	set who [lindex $arg 0]
	if {![onchan $who $chan]} {
	     	set whohand $who
	}
	set whohand [nick2hand $who $chan]	
	if {[strlwr $who] == [strlwr $botnick]} {
            out_msg $nick $hand $chan "�� ��� ����� ������� �� �����!"
		return 0
	}
	if {![validuser $whohand]} {
            out_msg $nick $hand $chan "$who �� ���������������."
		return 0
	}
		setuser $whohand pass
	out_msg $nick $hand $chan "������ ��� ������������ $whohand �������. �� �������� ��������� ��� �� ��������� ������."
	pub_m3s_plog $nick $host $hand $chan "R_E_M_P_A_S_S" $arg
	putcmdlog "<<$nick>> !$hand! ����������� ������� REMPASS $arg �� ������ $chan."
}
#71.CHPASS
proc pub_m3s_chpass {nick host hand chan arg} {
	global botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	
	set arg [charfilter $arg]
	set who [lindex $arg 0]
	set newpass [lindex $arg 1]
	set whohand [nick2hand $who $chan]	
	if {![onchan $who $chan]} {
	     	set whohand $who
	}
	if {[strlwr $who] == [strlwr $botnick]} {
            out_msg $nick $hand $chan "�� ��� ����� ������� �� �����!"
		return 0
	}
	if {![validuser $whohand]} {
            out_msg $nick $hand $chan "$who �� ���������������."
		return 0
	}
		setuser $whohand pass $newpass
	out_msg $nick $hand $chan "���������� ����� ������ ��� ������������ $whohand. �� �������� ��������� ��� ����� ������."
	pub_m3s_plog $nick $host $hand $chan "C_H_P_A_S_S" $arg
	putcmdlog "<<$nick>> !$hand! ����������� ������� CHPASS �� ������ $chan."
}
#72.SOC
proc pub_m3s_soc {nick host hand chan arg} {
 global botnick cmdpfix m3s_ver emailowner
 set arg [charfilter $arg]
 set soc [lindex $arg 1]
 set who [lindex $arg 0]
	 if {[llength $arg] != 2} {
		notice $nick "�������������: ${cmdpfix}soc <���> <����� �������><��� ���: � ��� �>"
		notice $nick "�������: �����, ���, ����, ���, ����, ���, �����, �����, ����, ���, ����, ���, �����, ����, ����, ����, �����, �����, ������, ����, ���, ���, ���, �����, ���, ����, �����, ������, �����, �����, �����, ����, ����, ���, �����, ����, �����, ������, ���"
		return 0
	 }
	if {![onchan $who $chan]} {
            notice $nick "��������, �� � �� ���� $who �� $chan."
		return 0		
	}
	 putcmdlog "<<$nick>> !$hand! ����������� ������� soc $arg �� ������ $chan."
	switch $soc {
		"������" {
			soc $chan "$nick �������� � ����� ��������� $who."
		}
		"������" {
			soc $chan "$nick �������� � ����� ���������� $who."
		}

		"����" {
			soc $chan "$nick �� �������� ����� $who � ���� ���������� �� ���� '� �����'."
		}
		"����" {
			soc $chan "$nick �� �������� ������ $who � ���� ����������� �� ���� '� �����'."
		}

		"�����" {
			soc $chan "$nick ����� ��-�� ����� ������� ������� ���� � � ���������� � �������� ������� ������ �� $who. '�����, ���������!'"
		}
		"�����" {
			soc $chan "$nick �������� ������ ��-�� ����� ������� ������� ���� � ���� �������� ������� �� $who. '�����!'"
		}

		"����" {
			soc $chan "$nick ���� ������: '$who �������! ������!!!'"
		}
		"����" {
			soc $chan "$nick ���� ���������: '$who �������! ������!!!'"
		}

		"�����" {
			soc $chan "$nick ������ ������� ������� � ���� $who."
		}
		"�����" {
			soc $chan "$nick ������ ������� ������� � ���� $who. '�����!'"
		}

		"����" {
			soc $chan "$nick ������ � ���� $who �������� �����."
		}
		"����" {
			soc $chan "$nick ������� � ���� $who ���������."
		}

		"������" {
			soc $chan "$nick ������� �� ���� $who '������� ���!'"
		}
		"������" {
			soc $chan "$nick ���� ���� �� ���� $who '������� ���!'"
		}

		"������" {
			soc $chan "$nick ��������� $who ����� �����."
		}
		"������" {
			soc $chan "$nick ���������� $who ����� �����."
		}

		"�����" {
			soc $chan "$nick ��������� ���� $who � ������: '�����, �������!'"
		}
		"�����" {
			soc $chan "$nick ���������� ���� $who � �������: '�����, �������!'"
		}

		"����" {
			soc $chan "$nick � ����� ����� ������ $who. ������!"
		}
		"����" {
			soc $chan "$nick � ����� ����� ��������� ���������� $who. �� ������!"
		}

		"�����" {
			soc $chan "$nick ��������� �������� � $who."
		}
		"�����" {
			soc $chan "$nick ��������� �������� � $who."
		}

		"����" {
			soc $chan "$nick ��������� �� ������ �, ������� ������, ������: '� ���� ��� ������, $who!'"
		}
		"����" {
			soc $chan "$nick ���������� �� ������ �, ������� ������, ������: '� ���� ���� ������, $who!'"
		}

		"������" {
			soc $chan "$nick ������ � ����� � ������ '���, �����! $who � ���� �����!'"
		}
		"������" {
			soc $chan "$nick ����� ���������� � ������ '$who � ���� �����!'"
		}

		"�����" {
			soc $chan "$nick �������� $who ����� ��������� �����-������ �����."
		}
		"�����" {
			soc $chan "$nick ������������ $who ������� � ����."
		}

		"�����" {
			soc $chan "$nick ���������� $who � ��������. ������ �� ���!"
		}
		"�����" {
			soc $chan "$nick �����, ����� $who ������ �� � ��������."
		}

		"�����" {
			soc $chan "$nick ������ $who ������ ��� ����!"
		}
		"�����" {
			soc $chan "$nick ������ $who ������ �� ����."
		}

		"������" {
			soc $chan "$nick ����������� $who � ������ �������!"
		}
		"������" {
			soc $chan "$nick ����������� $who � ������ �������!"	soc $chan "$nick �����������: '$who! ����� �� ���-���� ����!'"
		}
		"������" {
			soc $chan "$nick ���������� ��� $who."
		}

		"�������" {
			soc $chan "$nick �������� � �������� �������� $who."
		}
		"�������" {
			soc $chan "$nick ������� ������ ������� $who."
		}

		"�����" {
			soc $chan "$nick ������ �� ������ ��� ���� ������ $who."
		}
		"�����" {
			soc $chan "$nick ���� $who: '����� ������ ��� �� ����� ��������!'"
		}

		"����" {
			soc $chan "$nick �������� ��� $who."
		}
		"����" {
			soc $chan "$nick �������� �������� ��� $who."
		}

		"����" {
			soc $chan "$nick ���� �� ���, �������� �� ����� � ���� ������� � $who."
		}
		"����" {
			soc $chan "$nick ��������� �� ��� �� ����� ��� $who."
		}		

		"����" {
			soc $chan "$nick ������ $who, ��� �� ����� ��� ������."
		}
		"����" {
			soc $chan "$nick ������� $who, ��� �� ����� ��� ������."
		}		

		"������" {
			soc $chan "$nick ������������ ������� ������ ����� �� ���� $who."
		}
		"������" {
			soc $chan "$nick ������ �������� � ������� ������� � ��� $who. ����, ����� ����!"
		}		

		"����" {
			soc $chan "$nick ����� ������� � $who. ������������!"
		}
		"����" {
			soc $chan "$nick ����� ������� � ������ $who. ��������!!!"
		}		

		"�����" {
			soc $chan "$nick ����� ������� � $who."
		}
		"�����" {
			soc $chan "$nick ����� ������� � $who."
		}		

		"������" {
			soc $chan "$nick ������ ������ � ����������� � �������: '$who, ���� ���� �����!'"
		}
		"������" {
			soc $chan "$nick �������� �� ������� � $who."
		}		

		"�������" {
			soc $chan "$nick ������� � �������: '$who, ���, ���! ������!'"
		}
		"�������" {
			soc $chan "$nick ����� � ��� ���������� � $who."
		}		

		"������" {
			soc $chan "$nick ����� ����� ����: '������ �� ����, $who!'"
		}
		"������" {
			soc $chan "$nick ������ ����� �����: '$who, �� ���� ������! ������!'"
		}		

		"������" {
			soc $chan "$nick ������ ����� � ������� '$who, � ��������� ������?'"
		}
		"������" {
			soc $chan "$nick ����� ��������� � ��������� $who ������������."
		}		

		"������" {
			soc $chan "$nick ���� ����� � ��� $who �� ��������."
		}
		"������" {
			soc $chan "$nick ����� � $who ����� � �������, ��� ���� ���� ������."
		}		
		
		"�����" {
			soc $chan "$nick ����������: '$who, ����� ����!'"
		}
		"�����" {
			soc $chan "$nick �����������: '$who, ����� ����!'"
		}		
		
		"�����" {
			soc $chan "$nick �������� ���� ��� ��� ���-�� ��� $who."
		}
		"�����" {
			soc $chan "$nick �������� ���� ��� ��� ���-�� ��� $who."
		}	

		"����" {
			soc $chan "$nick ��������� �� $who � �������� �������."
		}
		"����" {
			soc $chan "$nick ��������� �� $who � �������� ��������."
		}	

		"������" {
			soc $chan "$nick ��������� �� $who � �������: '�����?'."
		}
		"������" {
			soc $chan "$nick ���������� �� $who � ��������: '�����?'"
		}	

		"�����" {
			soc $chan "$nick �������� ������: '$who, ��� ��� ����!'."
		}
		"�����" {
			soc $chan "$nick ���������� $who � �������: '����!'"
		}	

		"������" {
			soc $chan "$nick ��������� $who, ��� �����."
		}
		"������" {
			soc $chan "$nick ��������� $who, ��� ��� ������."
		}	

		"�����" {
			soc $chan "$nick ���� �� ���� � $who � ������: '������!'"
		}
		"�����" {
			soc $chan "$nick ��������� $who � �������: '������!'"
		}	

		"����" {
			soc $chan "$nick �������� �� ����� $who � �������: '���������������!'"
		}
		"����" {
			soc $chan "$nick ���������� ��� $who ��������: '���������������������!'"
		}	
		default {
			notice $nick "��������� ������������ ��������� �������. ����� � � � ������ ���� � ������� ��������."
		}
	}
}
#73.LISTQUOTES
proc pub_m3s_listquotes {nick host hand chan args} {
	global doquotes botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	if {!$doquotes} {
	   out_msg $nick $hand $chan "�������� � �������� ���������." 	   
	   return 0
	}
	if {![file exists m3s_quotes.txt]} {
      	notice $nick "����� ����� �� ����������. �������� ������ - ��� ������� ����."
		return 0
    	}
  set file [open "m3s_quotes.txt" "r"]
  set thing 0
  while {![eof $file]} {
   set whatsit [gets $file]
   if {$whatsit != ""} { incr thing +1 }   
  }
  putcmdlog "<<$nick>> !$hand! ����������� ������� listquotes �� ������ $chan."
  if {$thing==1} {
	out_msg $nick $hand $chan "����� 1 ������ � ���� �����."
  } else {
  	out_msg $nick $hand $chan "� ��������� ������ $thing ������� � ���� �����."
  }
}
#74.ADDQUOTE
proc pub_m3s_addquote {nick host hand chan arg} {
	global doquotes botnick
	if {![file exists m3s_quotes.txt]} {
      	set f [open "m3s_quotes.txt" w]
		puts $f "��� ����� ������!"
		close $f 
    	}
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}

  set text [split [cleanarg $arg]]
	  if {!$doquotes} {
   		out_msg $nick $hand $chan "�������� � �������� ���������." 	   
		return 0
	  }
  set thing [lrange $text 0 end]
  if {$thing == ""} {
   out_msg $nick $hand $chan "�� ������ ������ ������."
   return 0
  }
  set file [open "m3s_quotes.txt" "a"]
  puts $file $thing
  close $file
  out_msg $nick $hand $chan "\"$thing\" ��������� � ���� �����."
  pub_m3s_plog $nick $host $hand $chan "addquote" $thing
  putcmdlog "<<$nick>> !$hand! ����������� ������� addquote $thing �� ������ $chan."
}
#75.QUOTE
proc pub_m3s_quote {nick host hand chan args} {
	global doquotes botnick
  if {!$doquotes} {
   out_msg $nick $hand $chan "�������� � �������� ���������." 	   
   return 0  
  }
	if {![file exists m3s_quotes.txt]} {
      	notice $nick "����� ����� �� ����������. �������� ������ - ��� ������� ����."
		return 0
    	}
  if {[findnumquotes] == 0} {
   out_msg $nick $hand $chan "� ���� ���� ����������� �����."
   return 0
  }
  set file [open "m3s_quotes.txt" "r"]
  set thing 0

  set number [lindex $args 0]

  if {$number != ""} {
   set rnum $args
  } else {
   set rnum [rand [findnumquotes]]
  }
  set moo [gets $file]
  set thing2 0
  while {![eof $file]} {
   set moo [gets $file]
   if {$moo != ""} { incr thing +1 }
   if {$moo != ""} { incr thing2 +1 }   
   if {$thing == $rnum} {
    putserv "privmsg $chan :\002������ #$thing2\002: $moo" 
    break
   }
  }
  putcmdlog "<<$nick>> !$hand! ����������� ������� quote �� ������ $chan."
  close $file
}
#*************MSG****************#
proc msg_m3s_comeback {nick uhost hand args} {
	global botnick
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	set thechan "$args"
	if {![validchan $thechan]} {
		notice $nick "����� $thechan ������������."
		return 0
	}
	notice $nick "����������� �� \002$thechan\002 ..."
	channel set $thechan "-inactive"
	pub_m3s_plog $nick $uhost $hand "" "comeback" $args
	putcmdlog "<<$nick>> !$hand! ����������� ������� comeback $args �� ������ $thechan."
}

proc msg_m3s_act {nick uhost hand arg} {
	global botnick cmdpfix
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}

	set arg [charfilter $arg]
	set chan [lindex $arg 0]
	set usage "������������: ${cmdpfix}act <#�����> <�������>"
	if {![m3s_msg_test $nick $hand $chan $arg "< 2" $usage "o" ""]} { return 0 }
	putserv "PRIVMSG $chan :\001ACTION [lrange $arg 1 end]\001"
	notice $nick "�������� �� $chan: [lrange $arg 1 end]"
	putcmdlog "<<$nick>> !$hand! ����������� ������� act [lrange $arg 1 end] �� ������ $chan."
}

proc msg_m3s_say {nick uhost hand arg} {
	global botnick cmdpfix
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}

	set arg [charfilter $arg]
	set chan [lindex $arg 0]
	set usage "������������: ${cmdpfix}say <#�����> <�����>"
	if {![m3s_msg_test $nick $hand $chan $arg "< 2" $usage "o" ""]} { return 0 }
	puthelp "PRIVMSG $chan :[lrange $arg 1 end]"
	notice $nick "������ �� $chan: [lrange $arg 1 end]"
	putcmdlog "<<$nick>> !$hand! ����������� ������� say [lrange $arg 1 end] �� ������ $chan."
}

proc msg_m3s_addmask {nick uhost hand args} {

	global cmdpfix
	set pass_chk [passwdok $nick $args]
	if {[llength [split $args]] < 1} {
		notice $nick "�������������: ${cmdpfix}addmask <������ �� $nick �� ����>"
		return 0
	}
	putcmdlog "<<$nick>> ([maskhost $uhost]) !$hand! ����������� ������� addmask ... ������=$pass_chk. 1 - ������, 0 - ���."
	if { $pass_chk == 1} {
		setuser $nick hosts [maskhost $uhost]
		notice $nick "��������� \002[maskhost $uhost]\002 ��������� � ������ ����. ������ �� ������ ����������������."
	} {
		notice $nick "�������� ������. ��������� �� ���������."
	}
	pub_m3s_plog $nick $uhost $hand "" "ADDMASK" $args
}
proc msg_m3s_help {nick uhost hand args} {
	pub_m3s_help $nick $uhost $hand "MSG" $args
}
proc msg_m3s_commands {nick uhost hand args} {
	if { "$args" == "\{\}" } {
		pub_m3s_commands $nick $uhost $hand "MSG" $args
	} {
		pub_m3s_commands $nick $uhost $hand $args "MSG"
	}
}

#1.AUTH
proc msg_m3s_ident {nick uhost hand arg} {
	global botnick cmdpfix
	if {[llength $arg] < 1} {
		notice $nick "�������������: /msg $botnick auth <������>"
		return 0
	}
      set found 0
	foreach n [channels] {
		if {[onchan $nick $n]} {
			set found 1
		}
	}
      if {$found == 0} {
         notice $nick "������� �� �����, ������� �������������� ���� � ���������� ��� ���."
         return 0
      }
	set pass [lindex $arg 0]
	if {$hand == "*"} {
		notice $nick "��� ��������� ������������ ��� ������� ��� ��� ��� � ���� ������������� ��� ���� ��������� �� ��������� � ���������� ��� ������ ���� � ���� ����� �������������. ���������� ������."
		return 0
	}
	if {[getuser $hand XTRA AUTH] == "DEAD"} {
		notice $nick "��������, �� ���������� � �� ������ ������������ ��� �������."
		return 0
	}
	if {[passwdok $hand $pass]} {
		setuser $hand XTRA "AUTH" "1"
		putcmdlog "<<$nick>> ($uhost) !$hand! ���������������."
		notice $nick "����������� - ������!. ������� ���������� � \002${cmdpfix}\002. ��� ������ ��������� ������ ������� \002${cmdpfix}help\002"
		chattr $hand +Q
		return 0
	} else {
		notice $nick "�������� ������."
	}
}

proc m3s_signcheck {nick uhost hand chan reason} {
	if {$hand == "*"} {return 0}
	if {[getuser $hand XTRA AUTH] == "DEAD"} {
		return 0
	}
	if { [m3s_check $hand] } { putlog "�������������� ������������� \002$hand\002, ����� �� ����." }	
	setuser $hand XTRA "AUTH" "0"
	chattr $hand -Q
}

proc m3s_partcheck {nick uhost hand chan msg} {
	if {$hand == "*"} {return 0}
	if {[getuser $hand XTRA AUTH] == "DEAD"} {
		return 0
	}
		foreach ch [channels] {
		if { ($ch != $chan) && ([onchan $nick $ch]) } { return 0 }
	}
	if { [m3s_check $hand] } { putlog "�������������� ������������� \002$hand\002, ������� ��� ������." } 
	setuser $hand XTRA "AUTH" "0"
	chattr $hand -Q	
}
proc m3s_kickcheck {nick uhost hand chan victim reason} {
	global botnick
	set v_host "$victim![getchanhost $victim $chan]"
	set target_hand [finduser $v_host]
	set target_flag [chattr $target_hand $chan]
	set my_flag [chattr $hand $chan]
	if { [regexp "n" $my_flag] || [regexp "m" $my_flag] || [regexp "b" $my_flag] } { return 0 }
	if { $nick == $botnick } { return 0 }
	if { $nick == $victim } { return 0 }
	if { ($uhost == "service@services.dalnet.ru") || ($uhost == "cservice@undernet.org") } { return 0 }
	if { [regexp "P" $target_flag] } {
		set prot_type "���������� ������������"
		if { [regexp "H" $target_flag] } {
			set prot_type "������ ���������� ������������"
			putserv "MODE $chan -o $nick"
			putserv "MODE $chan +b [maskhost $uhost]"
			putlog "\002������\002 ���������� ������������ $victim ������ $nick ($uhost), �� ������ $chan."
		} { putlog "���������� ������������ $victim ������ $nick ($uhost) �� ������ $chan." }n $nick :\002������� �� ������ $victim\002) ($prot_type"
	}
	if {$hand == "*"} {return 0}
	if {[getuser $hand XTRA AUTH] == "DEAD"} {
		return 0
	}
		foreach ch [channels] {
		if { ($ch != $chan) && ([onchan $nick $ch]) } { return 0 }
	}
	if { [m3s_check $hand] } { putlog "�������������� ������������� \002$hand\002, ������� � ������ ������." }
	setuser $hand XTRA "AUTH" "0"
	chattr $hand -Q
}

proc m3s_rejncheck {nick host hand chan} {
	if {$hand == "*"} {return 0}
	if {[getuser $hand XTRA AUTH] == "DEAD"} {
		return 0
	}
		foreach ch [channels] {
		if { ($ch != $chan) && ([onchan $nick $ch]) } { return 0 }
	}
	if { [m3s_check $hand] } { putlog "�������������� ������������� \002$hand\002, ������ rejoin, ���� �� ����� ������." }
	setuser $hand XTRA "AUTH" "0"
	chattr $hand -Q
}

proc m3s_joincheck {nick host hand chan} {
	global botnick TabWelcome greetnew cmdpfix regwelcome
		if {[info exists TabWelcome($chan)] && $nick != $botnick } { notice $nick "$TabWelcome($chan)" }
	if { [strlen $nick] > 9 } {
		set who ""
		for {set x 0} {$x<9} {incr x} { set who "$who[stridx $nick $x]" }
	} { set who $nick }
	if {$hand == "*"} {
		if { ([validuser $who]) && ([passwdok $who ""] != 1) } {
			if {[matchattr $hand Q]} { chattr $hand -Q }
			notice $nick "���� ��������� �� ��������� � ���������� � ���� ��������� ��� ������ ����."
			notice $nick "��� ���������� ����� ����� � ���� �������, \002/msg $botnick addmask <������>"
			notice $nick "� ��������� ������ � �� ��������� ��� � �� ���� ����������� �� ���� �������."
		} elseif {![validuser $who] && $greetnew > 0} {
		 notice $nick $regwelcome
		 putlog "<<$nick>> ������� ����������� � �����������."
		}
	}
	if {[passwdok $hand ""] && ![matchattr $hand b]} {
		notice $nick "� ��� �� ��� ��� �� ���������� ������ �� ����. ������ �������� ��� �������������� � ��������� ���� � ����������� �� ������ ������."
		notice $nick "���������� ���������� ������ ��������: \002/msg $botnick pass \002<\002������\002>"
	}
}

proc m3s_nickcheck {nick host hand chan newnick} {
	global botnick
	if {![validuser $nick]} {return 0}
	if {[getuser $hand XTRA AUTH] == "DEAD"} {
		return 0
	}
	setuser $hand XTRA "AUTH" "0"
	chattr $hand -Q
	notice $nick "�� ������� ��� � ������������� ������������������."
}


proc m3s_check {hand} {
	set auth [getuser $hand XTRA "AUTH"]
	if {($auth == "") || ($auth == "0") || ($auth == "DEAD")} {
		return 0
	} else {
		return 1
	}
}

proc msg_m3s_unident {nick uhost hand arg} {
	if {[getuser $hand XTRA AUTH] == "DEAD"} {
		notice $nick "��������, �� ���������� � �� ������ ������������ ��� �������."
		return 0
	}
	if {$hand == "*"} {
		notice $nick "��� ��������� ������������ ��� ������� ��� ��� ��� � ���� �������������. ���������� ������."
		return 0
	}
		setuser $hand XTRA "AUTH" "0"
		chattr $hand -Q
		putcmdlog "<<$nick>> ($uhost) !$hand! �����������������."
		notice $nick "����������� - �����."	
}
#*************DCC****************#


#########################################
#############HELP PROGS##################
#########################################
proc say {who what} {
      global m3s_ver2
	puthelp "PRIVMSG $who :$what $m3s_ver2"
}
proc soc {who what} {
      global m3s_ver
	putserv "PRIVMSG $who :\001ACTION \002SOC:\002 $what"
}
proc notice {who what} {
      global m3s_ver2
	puthelp "NOTICE $who :$what $m3s_ver2"
}

proc out_msg {nick hand chan arg} {
	global The_Owner m3s_ver
	set sec_chk [chattr $hand $chan]
	set arg [string trim $arg "\}"]
	set arg [string trim $arg "\{"]
	set tzc "NO[string tolower $chan]"
	if { ([regexp "N" "$sec_chk"]) || ([getuser $The_Owner XTRA $tzc] == "1") } { notice $nick "$arg" } { say $chan "$nick: $arg" }
}

 proc charfilter {x {y ""} } {
	for {set i 0} {$i < [string length $x]} {incr i} {
		switch -- [string index $x $i] {
			"\"" {append y "\\\""}
			"\\" {append y "\\\\"}
			"\[" {append y "\\\["}
			"\]" {append y "\\\]"}
			"\} " {append y "\\\} "}
			"\{" {append y "\\\{"}
			":" {append y "\\\_"}	
			default {append y [string index $x $i]}
		}
	}
	return $y
}

proc m3s_pub_bad { nick host hand chan arg command byX } {
	set arg [charfilter $arg]
	global botnick cmdpfix
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	if {[llength $arg] < 1} {
		if { $command == "ban" } { 		
			notice $nick "�������������: ${cmdpfix}$command <���|���������> \[�����\] \[�������\]"
		} else {
			notice $nick "�������������: ${cmdpfix}$command <���|���������> \[�������\]"
		}
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� $command $arg �� ������ $chan"
	set who [lindex $arg 0]
	set ti [lindex $arg 1]
	if {[isnumber $ti]} {
		set reason [lrange $arg 2 end]
	} {
		if { $command == "banperm" } { 
			set ti 0 
		} else {
			set ti ""
		}
		set reason [lrange $arg 1 end]
	}
	if { ($command == "ban") && ($ti != "") && ($ti < 1 || $ti > 3000 )} {
       out_msg $nick $hand $chan "�������� ${cmdpfix}ban ����� �������� �� ����� �� 1 ������ �� 3000 �����. ����� �������� ������������ ��� ����������� ������� ${cmdpfix}banperm."
	 return 0
	} 
	m3s_do_bad $nick $hand $chan $who $ti $reason $command $byX
}
proc m3s_do_bad { nick hand chan who time reason command byX } {
	global botnick m3s_ban m3s_protect_flags cmdpfix
	if {[strlwr $who] == [strlwr $botnick]} {
		out_msg $nick $hand $chan "��, ���������! � ��� ����� ����� ������ ���."
		return 0
	}
	if {$reason == ""} { set reason "��������!" }
	set KickList ""
	
	if {[onchan $who $chan]} {
		if {$m3s_ban} {
			set ipmask [lindex [split [maskhost $who![getchanhost $who $chan]] "@"] 1]
			set usermask [lindex [split [getchanhost $who $chan] "@"] 0]		
			set banmask *!*$usermask@$ipmask
		} else { 
			set banmask [getchanhost $who $chan]
     	      	set banmask "*!*[string range $banmask [string first @ $banmask] e]" 
		}	
	} else {	
		set banmask $who
		if {[string first "!" $banmask] == -1 && [string first "@" $banmask] == -1} {
			if {[isnumber [string index $banmask 0]]} { 
				set banmask *!*@$banmask
			} else {
				 set banmask $banmask!*@* 
			}
		}
		if {[string first "!" $banmask] == -1} { set banmask *!*$banmask }
		if {[string first "@" $banmask] == -1} { set banmask $banmask*@* }
	}
	
  	foreach chanuser [chanlist $chan] {
      	if {[string match [strlwr $banmask] [strlwr "$chanuser![getchanhost $chanuser $chan]"]] && $chanuser != $botnick } { 
			if {[matchattr [nick2hand $chanuser $chan] $m3s_protect_flags|$m3s_protect_flags $chan]} {
		       	out_msg $nick $hand $chan "��������, �� �� ������ ������� ��� �������� ����������� ������������."
				return 0	
			} 
		    	lappend KickList $chanuser
		}
      }

	if {$byX } {
		if {[channel get $chan xlogin] && [channel get $chan protectX] && [isop X $chan] } {
			if { $command == "ban" && ![ischanban $banmask $chan]} { 
				putserv "PRIVMSG X :ban $chan $banmask 1 75 $reason" 
			}
			if { $command == "kick" } {
				putserv "PRIVMSG X :kick $chan $reason" 
			}
		}
	}

	if { $command == "kick" && ![onchan $who $chan]} {
		notice $nick "��������, � �� ���� $who �� ������."
		return 0
	}
	if { $command != "kick" && ![ischanban $banmask $chan]} { putserv "MODE $chan +b $banmask" }
	if { $KickList != "" } { putkick $chan [join $KickList ","] $reason }
	if { $command == "quick" } { utimer 7 [list m3s_deban $chan $banmask] }
	if { $command != "ban" && $command != "banperm" } { return 0 }

	switch $time {
		"" {
			out_msg $nick $hand $chan "����� ��� ��������: $banmask"
		}
		0 {
			if {![ispermban $banmask $chan]} { 
				newchanban $chan $banmask $nick $reason $time
				out_msg $nick $hand $chan "����� ������������ ��� �� $chan ��������: $banmask"
			}
		}
		default {
			if {![isban $banmask $chan]} { 
				newchanban $chan $banmask $nick $reason $time
				out_msg $nick $hand $chan "����� ��� $banmask �������� �� $time ���."
			}
		}
	}
	return 0
}

proc m3s_deban {chan hostmask} {
	putserv "MODE $chan -b $hostmask"
}

proc m3s_unban { nick hand chan mask byX } {
      global cmdpfix
	if {[isnumber $mask]} {
		set find 0
		foreach bans [banlist $chan] {
			incr find
			if {$find == $mask} { set mask [lindex $bans 0] ; break }
		}
		if {[isnumber $mask]} {
			out_msg $nick $hand $chan "�� ������ ��� ���� � ������� $mask. ������� ${cmdpfix}banlist"
			return 0
		} 
	} else {	
		if {[string first "!" $mask] == -1 && [string first "@" $mask] == -1} {
			if {[isnumber [string index $mask 0]]} { 
				set mask *!*@$mask 
			} else { 
				set mask $mask*!*@* 
			}
		}
		if {[string first "!" $mask] == -1} {set mask *!*$mask}
		if {[string first "@" $mask] == -1} {set mask $mask*@*}
	}
	if {$byX } {
		if {[channel get $chan xlogin] && [channel get $chan protectX] && [isop X $chan]} {
			putserv "PRIVMSG X :unban $chan $mask" 
		     	out_msg $nick $hand $chan "��� $mask ������� ����� � ������ $chan"
			return 0
		}
	}

	if {[isban $mask $chan]} { 
		if {![killchanban $chan $mask]} { killban $mask }
		     	out_msg $nick $hand $chan "��� $mask ������� ����� � ������ $chan"
		return 0
	} 
	if {[ischanban $mask $chan]} {
		putserv "MODE $chan -b $mask"
		     	out_msg $nick $hand $chan "��� $mask ������� ����� � ������ $chan"
		return 0
	} 
	out_msg $nick $hand $chan "��� ������ ���� �� ������ $chan"
	return 0
}
proc m3s_mass { chan cmd } {
	global botnick
	set liste ""
	foreach user [chanlist $chan] {
		if { $user != $botnick } {
			set whohand [nick2hand $user $chan]
			if { $cmd == "op" && ![isop $user $chan]} { 
				lappend liste $user
				if {[llength $liste] == 6} {
					putserv "MODE $chan +oooooo $liste"
					set liste ""
				} 
			}
			if { $cmd == "deop" && [isop $user $chan] && ![matchattr $whohand o|o $chan]} {
				lappend liste $user
				if {[llength $liste] == 6} {
					putserv "MODE $chan -oooooo $liste"
					set liste ""
				}
			}
			if { $cmd == "voice" && ![isvoice $user $chan]} { 
				lappend liste $user
				if {[llength $liste] == 6} {
					putserv "MODE $chan +vvvvvv $liste"
					set liste ""
				}
			}
			if { $cmd == "devoice" && [isvoice $user $chan] && ![matchattr $whohand v|v $chan]} {
				lappend liste $user
				if {[llength $liste] == 6} {
					putserv "MODE $chan -vvvvvv $liste"
					set liste ""
				}
			}
		}
	}
	if { $liste != ""} {
		if { $cmd == "op" } { putserv "MODE $chan +ooooo $liste" }
		if { $cmd == "deop" } { putserv "MODE $chan -ooooo $liste" }
		if { $cmd == "voice" } { putserv "MODE $chan +vvvvv $liste" }
		if { $cmd == "devoice" } { putserv "MODE $chan -vvvvv $liste" }
	}	
	return 0
}
proc m3s_join { nick host hand chan pass curchannel} {
	global botnick m3s_key m3s_chanmode m3s_deop_flood m3s_kick_flood m3s_join_flood m3s_ctcp_flood m3s_chan_parameters m3s_chan_flood
	if {[validchan $chan]} {
		out_msg $nick $hand $curchannel "� ��� ���������� $chan."
		if {$pass != ""} {
			if {$m3s_key} {
				out_msg $nick $hand $curchannel "����� ���� ���������� ��� ������ $chan: $pass."
				channel set $chan need-key "chankey $chan $pass"
			} {
				out_msg $nick $hand $curchannel "� �� ���� ��������� ����, ��� ��� ����� � ������� ���������."
			}
		}
		if {![onchan [strlwr $botnick] $chan]} {
			out_msg $nick $hand $curchannel "������� ����� �� ����� $chan ..."
			putserv "JOIN $chan $pass"
		} {
			out_msg $nick $hand $chan "� ��� �� ������ $chan."
		}
		return 0
	
}
	out_msg $nick $hand $curchannel "����� ������������� �����: $chan"
	channel add $chan
	channel set $chan chanmode $m3s_chanmode
	channel set $chan flood-chan $m3s_chan_flood
	channel set $chan flood-deop $m3s_deop_flood
	channel set $chan flood-kick $m3s_kick_flood
	channel set $chan flood-join $m3s_join_flood
	channel set $chan flood-ctcp $m3s_ctcp_flood
	foreach param $m3s_chan_parameters { channel set $chan $param }
	if {$pass != ""} {
		if {$m3s_key} {
			out_msg $nick $hand $curchannel "����� ���� ���������� ��� ������ $chan : $pass. "
			channel set $chan need-key "chankey $chan $pass"
		} {
			out_msg $nick $hand $curchannel "� �� ���� ��������� ����, ��� ��� ����� � ������� ���������."
 		}
	}
	out_msg $nick $hand $curchannel "������� ����� �� ����� $chan ..."
	out_msg $nick $hand $curchannel "����� ������������� �����: $chan"
	putserv "JOIN $chan $pass"
	out_msg $nick $hand $curchannel "����� $chan ������� ��������. �� �������� ���������� ��������� ������."
 }
proc chanaddapt {chan} {
	if {[string index $chan 0] != "#" && [string index $chan 0] != "&"} { set chan #$chan }
	return $chan
}
proc m3s_cleanusers { channel } {
	set remlist ""
	foreach hand [userlist] {
		set cleanacces 1
	      foreach chan [channels] { 
			if {[matchattr $hand bfovadkg|fovakg $chan]} { set cleanacces 0 } 
	      	if { $cleanacces == 0 } { break }
      	}
      	if { $cleanacces == 1 } { lappend remlist $hand }
      }
	foreach hand $remlist { 
		deluser $hand
	}
	if {$remlist != ""} {
    		putcmdlog "����� [list $channel] ������. ������������� ��������� ��� ������������: [join $remlist ", "]."
	}
	return 0
}
proc chankey {chan pass} {
	putserv "JOIN $chan $pass"
}
proc see_new_pass {a b c d e f} {
     global m3s_key
	if {$m3s_key} {return 0}
	set k [lindex $e 0]
	set pass [lindex $f 0]
	channel set $d need-key "chankey $d $pass"
}
proc time_diff { time inverse} {
	if {$inverse} {
		set ltime [expr [unixtime] - $time]
	} {
		set ltime [expr $time - [unixtime]]
	}
	set seconds [expr $ltime % 60]
	set ltime [expr ($ltime - $seconds) / 60]
	set minutes [expr $ltime % 60]
	set ltime [expr ($ltime - $minutes) / 60]
	set hours [expr $ltime % 24]
	set days [expr ($ltime - $hours) / 24]
	set result ""
	if {$days} {
		append result "$days "
		if {$days == 1} {
			append result "��. "
		} {
			append result "��. "
		}
	}
	if {$hours} {
		append result "$hours "
		if {$hours == 1} {
			append result "���. "
		} {
			append result "���. "
		}
	}
	if {$minutes} {
		append result "$minutes "
		if {$minutes == 1} {
			append result "���. "
		} {
			append result "���. "
		}
	}
	if {$seconds} {
		append result "$seconds "
		if {$seconds == 1} {
			append result "���."
		} {
			append result "���."
		}
	}
	return $result
}
proc m3s_watch_mode {nick host hand chan mode who} {
	global botnick botname m3s_maxbans
	set v_host "$who![getchanhost $who $chan]"
	set target_hand [finduser $v_host]
	set target_flag [chattr $target_hand $chan]
	set my_flag [chattr $hand $chan]
	if { [regexp "n" $my_flag] || [regexp "m" $my_flag] || [regexp "b" $my_flag] } { return 0 }
	if { $nick == $botnick } { return 0 }
	if { $nick == $who } { return 0 }
	if { $host == "service@services.dalnet.ru"} { return 0 }
	if { [regexp "P" $target_flag] } {
		if { [regexp -- "-o" $mode] } {
			set prot_type "���������� �����������"
			if { [regexp "H" $target_flag] } {
				set prot_type "������ ���������� ������������"
				putserv "MODE $chan -o $nick"
				putserv "MODE $chan +b [maskhost $host]"
				putlog "���������� ������������ $who ������� $nick ($host) �� ������ $chan."
			} { putlog "\002������\002 ���������� ������������ $who ������� $nick ($host) �� ������ $chan." }
			putserv "KICK $chan $nick :\002������� �� ����� $who\002) ($prot_type"
			if { $host != "service@services.dalnet.ru"} { putserv "MODE $chan +o $who" }
		}
	}
	if {$mode != "+b"} {return 0}
      if {[llength [chanbans $chan]] > 27 } {
            set banhost ""
	   	set b_count 0
		for {set loop 0} {$loop < 6} {incr loop} {
	   		set banhost "$banhost [lindex [lindex [chanbans $chan] $loop] 0]"
	   		incr b_count
			if {$loop == 5 } {	
				putserv "MODE $chan -bbbbbb $banhost"  
	                  set banhost "" ; set b_count 0 
			}
	   	}
      }
	if {[string match [strlwr $who] [strlwr $botname]]} {
		putserv "MODE $chan -bo $who $nick"
		out_msg $nick $hand $chan "�� ������� ���� �� ����!"
		return 0
	}

	foreach user [chanlist $chan] {
		set userhand [nick2hand $user $chan]
		if {[validuser $userhand] && $hand != $userhand } {
			if {[string match [strlwr $who] [strlwr "$user![getchanhost $user $chan]"]]} {
				if {[matchattr $userhand ov|ov $chan]} {
					if {[m3s_ban_test $nick $hand $who $chan $userhand]} { return 0 }
				}
			}
		}
	}
	foreach user [userlist] {
		if {$user != $hand} {
			foreach userhost [getuser $user HOSTS] {
				if {[string match [strlwr $who] [strlwr $userhost]] && [matchattr $user ov|ov $chan]} {
					if {[m3s_ban_test $nick $hand $who $chan $user]} { return 0 }
				}
			}
		}
	}
	return 0
}
proc m3s_ban_test {nick hand ban chan victim} {
	global botnick
	set remove 0
	if {![validuser $hand] && [channel get $chan userbans]} { set remove 1 }
	if {[matchattr $victim mb|m $chan] && ![matchattr $hand m|m $chan]} { set remove 1 }
	if {[matchattr $victim o|o $chan] && ![matchattr $hand o|o $chan]} { set remove 1 }
	if {$remove} {
		putserv "MODE $chan -b $ban"
		if {$nick != $botnick} { putserv "MODE $chan -o $nick" } 
		out_msg $nick $hand $chan "��� ��� $ban �� ������ $chan ����� ������ �� ���� ���������� ������������� $victim."
		return 1
	}
	return 0
}
proc m3s_init {} {
	global botnick m3s_whois m3s_what m3s_server_flags m3s_away
	puthelp "MODE $botnick $m3s_server_flags"
	foreach user [userlist] {
		if {[getuser $user xtra auth] != "DEAD"} { setuser $user xtra auth 0 }
		if {[matchattr $user Q]} { chattr $user -Q }
	}

	if { $m3s_away != ""} {
		utimer 20 {	puthelp "AWAY :$m3s_away" }
	}
	set m3s_whois ""
	set m3s_what ""
}
proc m3s_test_rights { command witch } { 
	switch -exact -- $command {
		"owner" {
			set param "n" ; set needflag "n|-" 
		}
		"master" {
			set param "m" ; set needflag "n|n" 
		}
		"op" {
			set param "o" ; set needflag "m|m"  ; 
		}
		"halfop" {
			set param "l" ; set needflag "o|o"  ; 
		}
		"friend" {
			set param "f" ; set needflag "o|o" 
		}
		"voice" {
			set param "v" ; set needflag "o|o" 
		}
		"bot" {
			set param "-" ; set needflag "m|m"
		}
		default {
			set param "-" ; set needflag "n|-"
		}
	}
	if { $witch == "flag" } {
		return $needflag
	} {
		return $param
	}
}
proc pub_m3s_add { nick host hand chan arg command } {
	global botnick cmdpfix	
      set arg [charfilter $arg]
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	set usage "�������������: ${cmdpfix}add$command <���> \[hand\]"
	if {[llength $arg] < 1} {
		notice $nick "$usage"
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� $command $arg �� ������ $chan"
	pub_m3s_plog $nick $host $hand $chan $command $arg
	set who [lindex $arg 0]
	set alternate [lindex $arg 1]
	m3s_add $nick $hand $chan $who $alternate $command $usage
}
proc m3s_add { nick hand chan who alternate cmd usage } {
	global botnick m3s_services
	set hostmask "$who![getchanhost $who $chan]"
	set host [lindex [split [getchanhost $who $chan] "@"] 1]
	set param [m3s_test_rights $cmd parameter]

	if {![matchattr $hand [m3s_test_rights $cmd flag] $chan]} {
            out_msg $nick $hand $chan "� ��� ��� ����������� ���� ��� ������������� ���� �������."
		return 0
	}
	if {[matchattr $who L]} {
		notice $nick "������������ ��������. ��������� ������ �� ��������."
		return 0
	}
	if {[strlwr $who] == [strlwr $botnick]} {
            out_msg $nick $hand $chan "�� ���� �������� ����."
		return 0
	}

	if {[getting-users]} {
            out_msg $nick $hand $chan "��������, ���� �������� � ������ �������������. ���������� �����."
		return 0
	}

	set whohand [nick2hand $who $chan]
	if {![onchan $who $chan]} {
		set whohand $who
	}
	if {[validuser $whohand]} {
		if {$cmd == "user" || $cmd == "bot" } {
       		out_msg $nick $hand $chan "$who ��� ������������ � ���� ������: $whohand."
			return 0 
		}
		if {[matchattr $whohand -|+$param $chan]} {
            	out_msg $nick $hand $chan "$who ��� $cmd �� ������ $chan � hand: $whohand."
		} {
			chattr $whohand -|+$param $chan
	            out_msg $nick $hand $chan "$who �������� ��� ${cmd} ������ $chan � hand: $whohand."
      	      notice $who "$nick ������� ��� ��� ${cmd} ������ $chan."
			setuser $who XTRA LASTMOD "$nick"
			setuser $who XTRA LMT "ADD-${cmd}"

		}
		return 0 
	} 

	if {[string match $m3s_services [strlwr $host]]} {
      	set whohost *!*@$host
      } else {
      	set whohost [maskhost $hostmask]
      }

	if {$alternate != ""} {
		if {[validuser $alternate]} {
			out_msg $nick $hand $chan "Hand $alternate ��� ����������."
			return 0
		}
		if { $cmd == "bot" } {
			addbot $alternate $host
			setuser $alternate hosts $hostmask
			setuser $who XTRA LASTMOD "$nick"
			setuser $who XTRA LMT "ADD-A(b)"
		} else {
			adduser $alternate $whohost
	            notice $who "$nick ������� ��� ��� ${cmd} ������ $chan � hand: $alternate."
			setuser $who XTRA LASTMOD "$nick"
			setuser $who XTRA LMT "ADD-${cmd}"
			notice $who "�� ������ ���������� ������. ����������� /msg $botnick PASS <����� ������>"
		}
		out_msg $nick $hand $chan "����� ������������ $alternate ($whohost)."
	      out_msg $nick $hand $chan "$who �������� ��� ${cmd} ������ $chan � hand: $alternate."
		chattr $alternate -|+$param $chan
		return 0
	}

	if {[validuser $who]} {
		out_msg $nick $hand $chan "Hand $who ��� ����������."
	} else {
		if { $cmd == "bot" } {
			addbot $who $host
			setuser $who hosts $hostmask
			setuser $who XTRA LASTMOD "$nick"
			setuser $who XTRA LMT "ADD-b"
		} else {
 			adduser $who $whohost
		   notice $who "$nick ������� ��� ��� ${cmd} ������ $chan � hand: $who."
        	   notice $who "�� ������ ���������� ������. ����������� /msg $botnick PASS <����� ������>]"
		}
            out_msg $nick $hand $chan "����� ������������ $who ($whohost)."
	      out_msg $nick $hand $chan "$who �������� ��� ${cmd} ������ $chan � hand: $who."
		chattr $who -|+$param $chan
		setuser $who XTRA LASTMOD "$nick"
		setuser $who XTRA LMT "ADD-${cmd}"

	}
	return 0
}

proc m3s_pub_del { nick host hand chan arg command } {
	global botnick cmdpfix	
      set arg [charfilter $arg]
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	if {[llength $arg] != 1} {
		notice $nick "�������������: ${cmdpfix}del$command <��� ��� hand>"
		return 0
	}
	set who [lindex $arg 0]
	m3s_del $nick $host $hand $chan $who $command
}

proc m3s_del { nick host hand chan who command } {
	global botnick
	if {[onchan $who]} {
		set whohand [nick2hand $who]
	} {
		if {![validuser $who]} {
			out_msg $nick $hand $chan "$who �� ���������������."
			return 0
		} {
			set whohand $who
		}
	}
	if {[matchattr $who L]} {
		notice $nick "������������ ��������. ��������� ������ �� ��������."
		return 0
	}
	if {[strlwr $nick] == [strlwr $botnick]} {
		out_msg $nick $hand $chan "��, ���������! � ��� ����� ����� ������ ���."
		return 0
	}

	if {[getting-users]} {
         out_msg $nick $hand $chan "��������, ���� �������� � ������ �������������. ���������� �����."
      	return 0
	}
	
	set param [m3s_test_rights $command parameter]

	if {![matchattr $hand [m3s_test_rights $command flag] $chan]} {
            out_msg $nick $hand $chan "� ��� ��� ����������� ���� ��� ������������� ���� �������."
		return 0
	}

	if {$command == "user" } {
		if {[matchattr $whohand n]} {
			out_msg $nick $hand $chan "�� �� ������ ������� ��������� ����."
			return 0
		}
		deluser $whohand
		boot $whohand "�� ���� ������� �� ����� ������������� ����."
		out_msg $nick $hand $chan "$who ������ �� $command �����."
	      notice $who "$nick ������ ��� �� ����� $command."
		return 0
	}
	if {![matchattr $whohand -|+$param $chan]} {
            out_msg $nick $hand $chan "$who �� $command �� ������ $chan."
	} {
		chattr $whohand -|-$param $chan
            out_msg $nick $hand $chan "$who ��� ������ �� ����� $command ������ $chan."
     	      notice $who "$nick ������ ��� �� ����� $command ������ $chan."
	}
	return 0
}
proc m3s_pub_chattr { nick host hand chan arg command } {
	global botnick cmdpfix
	if {![m3s_check $hand]} {
		notice $nick "����������� ���������� ��� ������������� ��������� ������. ����������� ����: /msg $botnick auth <��� ������>"
		return 0
	}
	if {[llength $arg] != 2} {
		notice $nick "�������������: ${cmdpfix}chattr|gchattr <���> <�����>"
		return 0
	}
	set arg [charfilter $arg]
	set who [lindex $arg 0]
	set flags [lindex $arg 1]
	set ch $chan
	set whohand [nick2hand $who $chan]
	if {![onchan $who $chan]} {
		set whohand $who
	}
	if {![validuser $whohand]} {
		notice $nick "$who �� ���������������."
		return 0
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� $command $arg �� ������ $chan"
	pub_m3s_plog $nick $host $hand $chan $command $arg
		if {[matchattr $who L]} {
			notice $nick "������������ ��������. ��������� ������ �� ��������."
			return 0
		}
		if { ([regexp "a" "$flags"]) || ([regexp "p" "$flags"]) || ([regexp "L" "$flags"])} {
			notice $nick "������������� ����� ����� ��������� ���� ����� ���������."
			return 0
		}

	if { $command == "chattr" } {
		m3s_chattr $nick $host $hand $chan $whohand $flags ""
	} { 
		m3s_chattr $nick $host $hand "" $whohand $flags $ch
	}
	return 0
}
proc m3s_chattr { nick host hand chan who flags ch} {
	if {$chan != ""} {
		if {[m3s_do_chattr $nick $hand $chan $who $flags n|n ""]} { return 0 }
		regsub -all -- "n" $flags "" flags
		regsub -all -- "m" $flags "" flags
		if {[m3s_do_chattr $nick $hand $chan $who $flags m|m ""]} { return 0 }
		regsub -all -- "o" $flags "" flags
		regsub -all -- "l" $flags "" flags
		if {[m3s_do_chattr $nick $hand $chan $who $flags o|o ""]} { return 0 }
            out_msg $nick $hand $chan "� ��� ��� ����������� ���� ��� ������������� ���� �������."
	} {
		if {[m3s_do_chattr $nick $hand $chan $who $flags n $ch]} { return 0 }
		regsub -all -- "n" $flags "" flags
		regsub -all -- "m" $flags "" flags
		if {[m3s_do_chattr $nick $hand $chan $who $flags m $ch]} { return 0 }
		regsub -all -- "o" $flags "" flags
		regsub -all -- "l" $flags "" flags
		if {[m3s_do_chattr $nick $hand $chan $who $flags o $ch]} { return 0 }
            out_msg $nick $hand $chan "� ��� ��� ����������� ���� ��� ������������� ���� �������."
	}
	return 0
}

proc m3s_do_chattr { nick hand chan who flags needflags ch} { 
	if { $chan == ""} {
		if {[matchattr $hand $needflags]} {
			set change [chattr $who $flags]
			if {$change != ""} {
	      	     	out_msg $nick $hand $ch "���������� ����� $who ������: $change."
				setuser $who XTRA LASTMOD "$nick"
				setuser $who XTRA LMT "GCHATTR"
			} {
				out_msg $nick $hand $ch "����� $who �� ����������."
			}
			return 1
		}
	} else { 
		if {[matchattr $hand $needflags $chan]} {
			set change [chattr $who -|$flags $chan]
			if {$change != ""} {
				set change [lindex [split $change "|"] 1]
                        out_msg $nick $hand $chan "��������� ����� $who �� ������ $chan ������: $change."
				setuser $who XTRA LASTMOD "$nick"
				setuser $who XTRA LMT "CHATTR"

			} {
				out_msg $nick $hand $chan "��������� ����� $who �� ����������."
			}
			return 1
		}
	}
	return 0
}
if {[file exists "welcome.txt"]} {
	set f [open welcome.txt r]
	while {[gets $f line] >= 0} {	
		set TabWelcome([lindex $line 0]) [join [lrange $line 1 end]]
	} 
	close $f
}
proc SaveWelcome {} {
	global TabWelcome
	set f [open welcome.txt w]
	foreach c [array name TabWelcome] { puts $f "$c $TabWelcome($c)" } 
	close $f
}

proc m3s_msg_test { nick hand chan arg test usage flag testop } {
	global botnick
	if {![validuser $hand]} { return 0 }
		if {[expr [llength $arg] $test]} {
		notice $nick "$usage"
		return 0
	}
	if { $chan != ""} {
		set chan [chanaddapt $chan]
		if {![validchan $chan]} { 
			notice $nick "����� $chan ������������." 
			return 0
		}		
	}
	if {$testop != "" && ![botisop $chan]} {
           notice $nick "��������, � �� �� �� ������ $chan."
		return 0
	}
	if { $flag != "" && ![matchattr $hand $flag|$flag $chan]} {
           notice $nick "��������, � ��� ��� ����������� ������ �� ������ $chan."
		return 0
	}
	return 1
}

proc m3s_whoid { nick host hand whochan whoflags } {
	if {$whochan != "" && ![matchattr $hand ov|ov $whochan]} { 
		notice $nick "��������, � ��� ��� ����������� ������ �� ������ $whochan."
		return 0 
	}	
	set identlist ""
	foreach user [userlist] {
		if {[getuser $user xtra auth] == 1} { 
			if {[matchattr $user $whoflags|$whoflags $whochan]} {
				lappend identlist $user
			}
		}
	}
	if {$whoflags == "" } { 
		out_msg $nick $hand $whochan "������������������ ������������: [list [join $identlist ", "]]"
	} { 
		out_msg $nick $hand $whochan "������������������ ������������ � ������� [list $whoflags $whochan]: [join $identlist ", "]]"
	}
	putcmdlog "<<$nick>> !$hand! ����������� ������� whoid [list $whoflags $whochan] �� ������ $whochan"
	return 0
}

proc strlwr {string} {
  string tolower $string
}

proc strupr {string} {
  string toupper $string
}

proc strcmp {string1 string2} {
  string compare $string1 $string2
}

proc stricmp {string1 string2} {
  string compare [string tolower $string1] [string tolower $string2]
}

proc strlen {string} {
  string length $string
}

proc stridx {string index} {
  string index $string $index
}

proc cleanarg {thething} {
 set temp ""
	for {set i 0} {$i < [string length $thething]} {incr i} {
  set char [string index $thething $i]
  if {($char != "\12") && ($char != "\15")} {
   append temp $char
  }
 }
 set temp [string trimright $temp "\}"]
 set temp [string trimleft $temp "\{"]
	return $temp
}


proc findnumquotes {} {
  set file [open "m3s_quotes.txt" "r"]
  set thing 0  
  while {![eof $file]} {
   set whatsit [gets $file]
   if {$whatsit != ""} { incr thing +1 }
  }
  return $thing
}

proc isnumber {string} {
  if {([string compare "" $string]) && \
      (![regexp \[^0-9\] $string])} then {
    return 1
  }
  return 0
}
putlog "$m3s_ver Loaded."


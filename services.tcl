###############################################################################
#																			  #
# ������ ��� ������ � ���������												  #
#																			  #
# �������� ��� ������ � RusNet � ForestNet. 								  #
# ��� ������ ����� ������ ��� ������� �����������������.					  #
#																			  #
# ���������:																  #
#	1. ����������� ������ � ����� scripts.									  #
#	2. �������� � eggdrop.conf:												  #
#																		      #
#set nickserv(regged_nick)	 "LameBot"  # ��� ����	#
#set nickserv(regged_altnick) "LameBot_" # �������������� ��� ���� #
#set nickserv(regged_pass)	 "Pa55W0Rd"  # ������ ��� ���� #
#set nickserv(regged_mail)	 "some@some.com"  # email, ���� ����� #
#						  # ���������� Memos  #
#			source scripts/services.tcl										  #
#																			  #
# �������:																	  #
#  �� ������:																  # 																  
#		!identify - ��� ������� identify � NickServ, ������� �� ������� ����� #
#                    ��� ��������. �� ������ ������ ���������				  #
#                           												  #
#   partyline:																  #
#		.ns <params> - ��������� ������ NickServ							  #
#		.cs <params> - ��������� ������ ChanServ							  #
#		.nsregister  - ������������ Nick � ChanServ						      #
#		.nssetup     - ��������� ��������� ��� ����(������� ������ ���        #
#					   ����� ip ������									      #
#																			  #
#   ������ ��� �������: 													  #
#       .chanset #chan +servaop 	- ����� �������� ������ ���� ����� 		  #
#									  ChanServ �� ������ #chan				  #
#																			  #
#		.chanset #chan +servunban 	- ����� �������� ��������� ���� �� #chan  #
#									  ����� ChanServ						  #
#																			  #
#		.chanset #chan +servinvite 	- ����� �������� ���������� ���� �� #chan #
#									  ����� ChanServ						  #
#																			  #
# Note: ��� ����, ���� ��� ��� ���� ��������� � ������ ����� ChanServ �����   #
#       ���� �� ��� �������� ��� SOP �� ChanServ							  #
#																			  #
###############################################################################
#  ���������:																  #
#  																			  #
# v2.2.3																	  #
#  051013 ��������� �������� �� ������������� ������ � bind need.
#        																  #
#        																  #
#  050407 ���������� ������ ��� ������ � ������������� ����� ����.            #
#  050129 ���� ��� ������� � -m �� ����� ������� ������������������.		  #
#																		      #
#         ������� ����� ��� ���������� ����� � chanserv/nickserv/operserv.	  #
#																		      #
# v2.2.1																	  #
#  041215 ��������� ������ ������� � ::svs::unlock							  #
#																		      #
# v2.2																		  #
#  041214 ��������� �������� ��������� ������ ������, �� ����� �� ���� ��.	  #
#		  NEED ������ ������ ����� �� ��������������.						  #
#																			  #
#		  �������� ��� � unlock. �� ���������� unban/op/invite. 			  #		
#																			  #	
#		  �������� Version History (��, ��� �� ������ �������) ;)		      #								
#																			  #
# v2.1																		  #
#  		  ��������� ����� ����������� ���� ����. (10x to #helpers @ RusNet)	  #
#																			  #
#		  �������� �������������� ������ � ���������, ������ �� ������������� #
#		  � ��������.														  #
#																			  #
#		  ���� ��� �� ����������������� � �������� need op/unban/invite ����� #
#		  ��������������.													  #
#		  																	  #
#		  ������ services.tcl ������ ������� ��� ��� ������.				  #
#		  ��� ������ ������ � ���. ������ ���������� �� ******				  #
#																			  #
#		  ��� ���������� ������� ���������� �������� �� ���� nickserv(...),   #
#		  chanserv(...), operserv(...) ����� ����������� ����� � eggdrop.conf #
#		  �� ������� ��� ������. ��������� ������� overrides.  				  #
#																			  #
###############################################################################
# ������������� (�� ������, ����������� � �������� :)			      #
#   zl0y @ RusNet, Ashka @ RusNet, CoolCold @ XNet, keeper_c @ RusNet, 	      #
#   mrBuG @ RusNet, Ghhost @ RusNet, Stream @ RusNet, isot @ RusNet, 	      #
#	ArmageddonNsk @ RusNet, DROOPY @ Rusnet			      	      #
#									      #
###############################################################################
# ����� ���� ��������� - �� ����� ������ ;)				      #
# ���-�� ����� ��� ��������� ���������� � ���� � ������ ���� � ���������.     #
# �������� � �������� ����� ��������� ����� ����� � ������ ������.            #
###############################################################################

namespace eval svs { }

foreach p [array names chanserv *] { catch {set chanserv_overrides($p) $chanserv($p) } }
foreach p [array names nickserv *] { catch {set nickserv_overrides($p) $nickserv($p) } }

# ������ ��������� �� NickServ ��� ������� ��� ������ ������������������ 
######### NickServ ##########
set nickserv(need_ident)		{
	{*nick*owned*}
	{*Password*authentication*}
	{*NickServ*IDENTIFY*}
	{*nickname*registered*protected*}
	{*Permission*denied*}
}

# ������ ��������� �� NickServ � ������ ������� ������������
set nickserv(ok) {
	{*Password*accepted*}	
}

# ������ ��������� �� NickServ � ������ ��������� ������������
# ���������� ��� ����, ���� �������� � �������...
# ��� �������� ����� ���� ���� ���������, ����� n �������
# ��������� �������������
set nickserv(failed) {
	{*Password*incorrect*}	
}

# ��� NickServ'�
set nickserv(service) 		"NickServ"

# ������� ���������� ������� ��� ����� � NickServ'��
# ������ ������� /nickserv �� ��������. ����� ����� �������� �
# �� : set nickserv(msg_command) "PRIVMSG NickServ :"
set nickserv(msg_command)	"NICKSERV"

# ������� ���������� NickServ
set nickserv(com_ident) 	"IDENTIFY"
set nickserv(com_recover) 	"RECOVER"
set nickserv(com_release) 	"RELEASE"
set nickserv(com_register) 	"REGISTER"
set nickserv(com_ghost) 	"GHOST"

# ������� ���������� NickServ �� ������� .nssetup
set nickserv(com_set_acc)	"ACCESS CURRENT"
set nickserv(com_set_enf)	"SET ENFORCE ON"
set nickserv(com_set_sec)	"SET SECURE OFF"
set nickserv(com_set_priv)	"SET PRIVATE OFF"
set nickserv(com_set_mail)	"SET EMAIL"
set nickserv(com_set_memo)	"SET MEMOMAIL ON"

# ����� NickServ'� �� ����
set nickserv(flags)			"+fNe"
set nickserv(handle)		"NickServ"
set nickserv(host) 			"NickServ!Service@RusNet"

######### ChanServ ##########
# ��� ChanServ'�
set chanserv(handle)		"ChanServ"

# ���� ����� ChanServ'�

set chanserv(host) 			"ChanServ!Service@RusNet"

# ������ ��������� �� ChanServ ��� ������� ��� ������ ������������������ 
set chanserv(need_ident)			{
	{*Access*denied*}
}
# ������� ���������� ������� ��� ����� � ChanServ'��
set chanserv(msg_command)	"CHANSERV"

# ����� ChanServ'� �� ����
set chanserv(flags)			"+aofNe"

# ������� ���������� ChanServ
set chanserv(com_op) 		"OP"
set chanserv(com_unban) 	"UNBAN"
set chanserv(com_invite) 	"INVITE"

######### OperServ ##########
# ��� OperServ'�
set operserv(handle)		"OperServ"
# ���� ����� OperServ'�
set operserv(host) 			"OperServ!Service@RusNet"
# ����� OperServ'� �� ����
set operserv(flags)			"+fNe"

set operserv(flood_trig) {
	{*flood*}
}

foreach p [array names chanserv_overrides *] { catch {set chanserv($p) $chanserv_overrides($p) } }
foreach p [array names nickserv_overrides *] { catch {set nickserv($p) $nickserv_overrides($p) } }

###############################################################################
# �Ѩ ��� ���� ����� - ����� �������, �� ���� ����, ��� �������				  #
###############################################################################

foreach bind [binds "::svs::*"] {
    catch {unbind [lindex $bind 0] [lindex $bind 1] [lindex $bind 2] [lindex $bind 4]}
}
foreach p [array names svs *] { catch {unset svs($p) } }

set svs(off) 		  0
set svs(ident_timer)  0
set svs(ident_sent)   0
set svs(regain_timer) 0
set svs(turnon_timer) 0
set svs(setup)   	  0
set svs(set_timer)    0
set svs(busy_fails)   0
set svs(identified)   0
set svs(fails)		  0

set svs(ver) "2.2.3"
set svs(authors) "Shrike <shrike@eggdrop.org.ru>"


bind pub 	n 		!identify 			::svs::bind_identify_pub
bind dcc 	n 		identify 			::svs::bind_identify_dcc
bind dcc 	n		nickserv 			::svs::bind_nickserv_dcc
bind dcc 	n 		ns 					::svs::bind_nickserv_dcc
bind dcc 	n 		chanserv 			::svs::bind_chanserv_dcc
bind dcc 	n 		cs 					::svs::bind_chanserv_dcc
bind dcc 	n 		nsregister			::svs::bind_register_dcc
bind dcc 	n 		nssetup				::svs::bind_nssetup_dcc
bind time 	- 		"*0 * * * *" 		::svs::bind_time_check
bind time 	- 		"* * * * *" 		::svs::bind_time_need_check

if { [info exists nickserv(need_ident)] } {
	foreach nsbind $nickserv(need_ident) {
		bind notc 	N 	$nsbind 		::svs::bind_need_identify_notc
		bind msg  	N 	$nsbind 		::svs::bind_need_identify_msg
	}
}
	
if { [info exists nickserv(failed)] } {
	foreach nsbind $nickserv(failed) {
		bind notc 	N 	$nsbind 		::svs::bind_identify_fail_notc
		bind msg  	N 	$nsbind 		::svs::bind_identify_fail_msg
	}
}
	
if { [info exists nickserv(ok)] } {
	foreach nsbind $nickserv(ok) {
		bind notc 	N 	$nsbind 		::svs::bind_identified_notc
		bind msg  	N 	$nsbind 		::svs::bind_identified_msg
	}
}
	
if { [info exists chanserv(need_ident)] } {
	foreach csbind $chanserv(need_ident) {
		bind notc 	N 	$csbind 		::svs::bind_need_identify_notc
		bind msg  	N 	$csbind 		::svs::bind_need_identify_msg
	}
}
	
if { [info exists operserv(flood_trig)] } {
	foreach osbind $operserv(flood_trig) {
		bind notc 	N 	$osbind 		::svs::bind_flooded_notc
		bind msg  	N 	$osbind 		::svs::bind_flooded_msg
	}
}

bind raw  - 433 		::svs::bind_nick_busy
bind evnt - init-server ::svs::bind_init_server

proc ::svs::islocked { what {chan ""}} {
	global svs
	if { $chan != "" } { set what "$what$chan" }
	if { [info exists svs(lock,$what)] && $svs(lock,$what) == 1 } { return 1 }
	return 0
}

proc ::svs::lock { what time {chan ""}} {
	global svs
	if { $chan == "" } {
		putlog "\[services\] command '$what' is locked for $time mins..."
		set svs(lock,$what) 1
		set svs(lock_timers,$what) [timer $time [list ::svs::unlock $what]]
	} {
		putlog "\[services\] command '$what' for channel '$chan' is locked for $time mins..."
		set w "$what$chan"
		set svs(lock,$w) 1
		set svs(lock_timers,$w) [timer $time [list ::svs::unlock $what $chan]]
	}
}

proc ::svs::unlock { what {chan ""}} {
	global svs
	if { $chan == "" } {
		if { [info exists svs(lock,$what)] && $svs(lock,$what) == 1 } {
			putlog "\[services\] command '$what' unlocked..."
		}
		catch { unset svs(lock,$what) }
		catch {	killtimer $svs(lock_timers,$what) }
	} {
		set w "$what$chan"
		if { [info exists svs(lock,$w)] && $svs(lock,$w) == 1 } { 
			putlog "\[services\] command '$what' unlocked for channel '$chan'..."
		}
		catch { unset svs(lock,$w) }
		catch {	killtimer $svs(lock_timers,$w) }
	}
}

# ������ ������� �������
proc ::svs::putcomm { command } {
	global svs nickserv
	if { $svs(off) } return
	regsub $nickserv(regged_pass) $command {********} log
	putlog "\[services\] SENDING: $log"
	putserv $command
}

proc ::svs::on_flood {} {
	global svs
	putlog "\[services\] \002\0034Services was flooded...\003 whoops... sleeping on 10 min... ;/\002"
	
	set svs(turnon_timer) [timer 10 ::svs::turn_on]
	set svs(off) 1	
}

proc ::svs::turn_on {} {
	global svs
	set svs(off) 0
	catch {	killtimer $svs(turnon_timer) }
	::svs::check_nick
}

proc ::svs::on_identified {} {
	global svs
	set svs(identified) 1
	set svs(busy_fails) 0
	set svs(fails) 0
	putlog "\[services\] Succesfully identified..."
}

proc ::svs::nssetup {} {
	global svs
	if { $svs(setup) } return
	
	putlog "\[services\] Setting up nick parameters..."
	
	set svs(setup) 1
	set svs(set_timer) [utimer 10 ::svs::nssetup_set_acc]
}

proc ::svs::nssetup_set_acc {} {
	global svs nickserv	
	catch {	killutimer $svs(set_timer) }
	if { [info exists nickserv(com_set_acc)]} {
		::svs::putcomm "$nickserv(msg_command) $nickserv(com_set_acc)"
	}
	set svs(set_timer) [utimer 10 ::svs::nssetup_set_enf]
}

proc ::svs::nssetup_set_enf {} {
	global svs nickserv	
	catch {	killutimer $svs(set_timer) }
	if { [info exists nickserv(com_set_enf)]} {
		::svs::putcomm "$nickserv(msg_command) $nickserv(com_set_enf)"
	}
	set svs(set_timer) [utimer 10 ::svs::nssetup_set_sec]
}

proc ::svs::nssetup_set_sec {} {
	global svs nickserv	
	catch {	killutimer $svs(set_timer) }
	if { [info exists nickserv(com_set_sec)]} {
		::svs::putcomm "$nickserv(msg_command) $nickserv(com_set_sec)"
	}
	set svs(set_timer) [utimer 10 ::svs::nssetup_set_priv]
}

proc ::svs::nssetup_set_priv {} {
	global svs nickserv	
	catch {	killutimer $svs(set_timer) }
	if { [info exists nickserv(com_set_priv)]} {
		::svs::putcomm "$nickserv(msg_command) $nickserv(com_set_priv)"
	}
	set svs(set_timer) [utimer 10 ::svs::nssetup_set_mail]
}

proc ::svs::nssetup_set_mail {} {
	global svs nickserv	
	catch {	killutimer $svs(set_timer) }
	if { [info exists nickserv(com_set_mail)] && [info exists nickserv(regged_mail)]} {
		::svs::putcomm "$nickserv(msg_command) $nickserv(com_set_mail) $nickserv(regged_mail)"
	}
	set svs(set_timer) [utimer 10 ::svs::nssetup_set_memo]
}

proc ::svs::nssetup_set_memo {} {
	global svs nickserv	
	catch {	killutimer $svs(set_timer) }
	if { [info exists nickserv(com_set_memo)]} {
		::svs::putcomm "$nickserv(msg_command) $nickserv(com_set_memo)"
	}
	set svs(set_timer) [utimer 60 ::svs::nssetup_end]
}

proc ::svs::nssetup_end {} {
	global svs nickserv	
	catch {	killutimer $svs(set_timer) }
	set svs(setup) 0
}

proc ::svs::on_identify_fail {} {
	global svs
	putlog "\[services\] \002Nick Identification failed... permanently disabling services control.\002"
	putlog "\[services\] \002Check your settings.\002"
	set svs(off) 1
}

proc ::svs::bind_nick_busy { from keyword text } {
	global svs nickserv

	set busy_nick [lindex $text 1]

	set altnick $nickserv(regged_altnick)

	if { [string equal -nocase $busy_nick $nickserv(regged_altnick)] } {
		# ���� �������� ��� �����. � �������������� ����... ������ ��� �� ���������.
		set altnick "$nickserv(regged_altnick)[rand 99999]"
	}

	if { $svs(busy_fails) == 0 } {
		# ���������� ����� ��� �� ��������. � RELEASE ������� �� ��������, ��� ���
		# ������ ��� �� ��������������� � �������.
		putlog "\[services\] Nick \002$busy_nick\002 is in use, switching to \002$altnick\002"
		::svs::putcomm "NICK $nickserv(regged_altnick)"
		set svs(regain_timer) [utimer 10 ::svs::check_nick]
	}
	
	if { $svs(busy_fails) == 1 } {
		# ������ ��� ���������������, ��� �����... ������ ��� ������� - RECOVER
		putlog "\[services\] Nick \002$busy_nick\002 is in use, trying to \002RECOVER\002 and \002RELEASE\002 the enforcer."
		::svs::putcomm "$nickserv(msg_command) $nickserv(com_recover) $nickserv(regged_nick) $nickserv(regged_pass)"
		::svs::putcomm "$nickserv(msg_command) $nickserv(com_release) $nickserv(regged_nick) $nickserv(regged_pass)"
	}
	
	if { $svs(busy_fails) == 2 } {
		# ���� RECOVER �� �������... ������ GHOST.
		putlog "\[services\] Nick \002$busy_nick\002 is in use, trying to \002GHOST\002 and \002RELEASE\002 the enforcer."
		::svs::putcomm "$nickserv(msg_command) $nickserv(com_ghost) $nickserv(regged_nick) $nickserv(regged_pass)"
		::svs::putcomm "$nickserv(msg_command) $nickserv(com_release) $nickserv(regged_nick) $nickserv(regged_pass)"
		set svs(busy_fails) 0
	}

	incr svs(busy_fails)
	
	return 1
}

proc ::svs::register {} {
	global nickserv
	putlog "\[services\] Nick \002Registering Nick...\002"
	
	::svs::putcomm "$nickserv(msg_command) $nickserv(com_register) $nickserv(regged_pass) $nickserv(regged_mail)"
}

proc ::svs::bind_time_check {mi ho da mo ye} {
	global botnick svs nickserv
	if { [string equal -nocase $botnick $nickserv(regged_nick)] && $svs(identified) } { return }	
	::svs::check_nick
}

proc ::svs::bind_time_need_check {mi ho da mo ye} {
	global svs
	if { !$svs(identified) } { return }	
	foreach svs_chan [channels] {
		if { ![botisop $svs_chan] && [botonchan $svs_chan] && [channel get $svs_chan servaop] } {
			::svs::bind_need_op $svs_chan op]
		}
	}
}

proc ::svs::check_nick {} {
	global botnick svs nickserv
	if { $svs(off) } { return }
	
	if { ![string equal -nocase $botnick $nickserv(regged_nick)] } {
		putlog "\[services\] Trying to regain botnick (attempt: $svs(fails) )"
		::svs::putcomm "NICK $nickserv(regged_nick)"
		
		incr svs(fails)
		
		if { $svs(fails) < 4 } {
			set svs(regain_timer) [utimer 5 ::svs::check_nick]
		} elseif { $svs(fails) > 6 } {
			set svs(regain_timer) [timer 5 ::svs::check_nick]
		} elseif { $svs(fails) > 15 } {
			putlog "\[services\] \002Max allowed ($svs(fails)) attepts reached.\002"
			putlog "\[services\] \002Nick is not recoverable. Services control turned disbled.\002"
			set svs(off) 1
		} else {
			set svs(regain_timer) [timer 1 ::svs::check_nick]
		} 
	} else {
		# �� ��������� - ��� ���, ��� �����
		set svs(fails) 0
		catch {	killtimer $svs(regain_timer) }
		::svs::unlock identify
		::svs::on_need_identify
	}
}

proc ::svs::on_need_identify {} {
	global svs nickserv
	if { [::svs::islocked identify] } return
	
	set svs(identified) 0
	::svs::lock identify 5
	::svs::putcomm "$nickserv(msg_command) $nickserv(com_ident) $nickserv(regged_pass)"
}

proc ::svs::bind_nickserv_dcc {hand idx text} {
	global nickserv
	::svs::putcomm "$nickserv(msg_command) $text" 
}

proc ::svs::bind_chanserv_dcc {hand idx text} { 
	global chanserv
	::svs::putcomm "$chanserv(msg_command) $text" 
}

proc ::svs::bind_identified_notc { nick uhost handle text dest } { ::svs::on_identified }
proc ::svs::bind_identified_msg {nick uhost hand params} { ::svs::on_identified }

proc ::svs::bind_identify_fail_notc { nick uhost handle text dest } { ::svs::on_identify_fail }
proc ::svs::bind_identify_fail_msg {nick uhost hand params} { ::svs::on_identify_fail }

proc ::svs::bind_need_identify_notc { nick uhost handle text dest } { ::svs::on_need_identify }
proc ::svs::bind_need_identify_msg {nick uhost hand params} { ::svs::on_need_identify }

proc ::svs::bind_register_dcc {hand idx text} { ::svs::register }
proc ::svs::bind_nssetup_dcc  {hand idx text} { ::svs::nssetup }

proc ::svs::bind_init_server {type} { ::svs::on_need_identify }

proc ::svs::bind_flooded_notc { nick uhost handle text dest } { ::svs::on_flood }
proc ::svs::bind_flooded_msg {nick uhost hand params} { ::svs::on_flood }

proc ::svs::bind_identify_pub {nick uhost hand chan params} { ::svs::on_need_identify }
proc ::svs::bind_identify_dcc {hand idx text} { ::svs::on_need_identify }


############################################################################
# chanserv operations
############################################################################
setudef flag servaop
setudef flag servunban
setudef flag servinvite

bind need - "% op" ::svs::bind_need_op
proc ::svs::bind_need_op {chan type} {
	global svs botnick chanserv
	if {! [validchan $chan]} return
	if {! [channel get $chan servaop]} return
	if { [::svs::islocked op $chan] } return

	if { ! $svs(identified) } {
		putlog "\[services\] Skipping NEED OP request, we need to IDENTIFY before..."
		::svs::on_need_identify
		return
	}
	
	putlog "\[services\] \002Trying to get OP on $chan\002"

	::svs::lock op 2 $chan
	::svs::putcomm "$chanserv(msg_command) $chanserv(com_op) $chan"
	return
}

bind need - "% unban" ::svs::bind_need_unban
proc ::svs::bind_need_unban {chan type} {
	global svs botnick chanserv
	if {! [validchan $chan]} return
	if {! [channel get $chan servunban]} return
	if { [::svs::islocked unban $chan] } return
	
	if { ! $svs(identified) } {
		putlog "\[services\] Skipping NEED UNBAN request, we need to IDENTIFY before..."
		::svs::on_need_identify
		return
	}
	
	putlog "\[services\] \002Trying to UNBAN on $chan\002"
	
	::svs::lock ban 2 $chan
	::svs::putcomm "$chanserv(msg_command) $chanserv(com_unban) $chan"
	return
}

bind need - "% invite" ::svs::bind_need_invite
proc ::svs::bind_need_invite {chan type} {
	global svs botnick chanserv
	if {! [validchan $chan]} return
	if {! [channel get $chan servinvite]} return
	if { [::svs::islocked invite $chan] } return
	
	if { ! $svs(identified) } {
		putlog "\[services\] Skipping NEED INVITE request, we need to IDENTIFY before..."
		::svs::on_need_identify
		return
	}
	
	putlog "\[services\] \002Trying to INVITE on $chan\002"
	
	::svs::lock invite 2 $chan
	::svs::putcomm "$chanserv(msg_command) $chanserv(com_invite) $chan"	
}

utimer 5 ::svs::init

proc ::svs::init {} {
	global nickserv chanserv operserv svs
	if { [string trim [join [userlist n]]] != "" } {
		putlog "\[services\] Adding NickServ,ChanServ,OperServ to userfile..."
		if { [validuser $nickserv(handle)] } { deluser $nickserv(handle) } 
		if { [validuser $chanserv(handle)] } { deluser $chanserv(handle) }
		if { [validuser $operserv(handle)] } { deluser $operserv(handle) }
		
		adduser $nickserv(handle) 	$nickserv(host)
		chattr 	$nickserv(handle)	$nickserv(flags)
		adduser $chanserv(handle) 	$chanserv(host)
		chattr 	$chanserv(handle) 	$chanserv(flags)
		adduser $operserv(handle) 	$operserv(host)
		chattr 	$operserv(handle)	$operserv(flags)
		
		foreach svs_chan [channels] {
			channel set $svs_chan need-op ""
			channel set $svs_chan need-unban ""
			channel set $svs_chan need-invite ""
			::svs::unlock op $svs_chan
			::svs::unlock unban $svs_chan
			::svs::unlock invite $svs_chan
		}
	} else {
		putlog "\[services\] Bot is running in userfile creation mode, skipping adding services..."
		set svs(off) 1
	}
}

set keep-nick 0

##################################################

putlog "services.tcl v$svs(ver) by $svs(authors) loaded."

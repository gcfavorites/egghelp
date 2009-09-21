########################################################################################
#          : : : S   e   c   u   r   i   t   y    P   o   r   t   a   l : : :
#                                      __               __
#   _      ___      ___      __  _  __/ /_  ____ ______/ /_____  __________  _______  __
#  | | /| / / | /| / / | /| / / | |/_/ __ \/ __ `/ ___/ //_/ _ \/ ___/ ___/ / ___/ / / /
#  | |/ |/ /| |/ |/ /| |/ |/ / _>  </ / / / /_/ / /__/ ,< /  __/ /  (__  ) / /  / /_/ /
#  |__/|__/ |__/|__/ |__/|__(_)_/|_/_/ /_/\__,_/\___/_/|_|\___/_/  /____(_)_/   \__,_/
#
########################################################################################
#                    [ - R u s s i a n   I R C   N e t W o r k - ]
#               __  __          __      _   __         __
#              / / / / __  __  / /_    / | / / ___    / /_      _____  __  __
#             / /_/ / / / / / / __ \  /  |/ / / _ \  / __/     / ___/ / / / /
#            / __  / / /_/ / / /_/ / / /|  / /  __/ / /_  _   / /    / /_/ /
#           /_/ /_/  \__,_/ /_.___/ /_/ |_/  \___/  \__/ (_) /_/     \__,_/
#                  [ irc.xakepy.ru | irc.xhackers.ru | irc.comwb.ru ]
########################################################################################
# ������:
#	passgen.tcl v2.2 by MPAK (gL00M, M)
#	Copyright � 2005-2006 'Xhackers Team', www.xhackers.ru
#
# ��������: 
#	��������� ������� �� ������� !passgen. 5 ����� ��������� �������. �������� �����
#	������������� ������, ����� ����� ������ � ����� ���������� ������������ ������� 
#	�� ���� ���. ������ ������������� ������� !passgen �� ����������� ������.
#	����������� �� ������� ����� ��������� �������������� �������.
#
#		���� �������������:
#			f - ������. ��������� � ���� ��� ���� ���������. [bsnz]
#			b - ������� ����� ���������� ��������. [A-Z]
#			s - ��������� ����� ���������� ��������. [a-z]
#			n - �������� �����. [0-9]
#			z - �������. [`~!@\]
# 
# �������������:
#	���� �� ������ ������� ��� ������ ��������, ��� �������� ������ � ����� �����,
#	��� ������ ������ ���-�� ������ ��� � ��� �������� ��, ��� �� ������. ����� ���
#	������ ����� ��������� � ������� WebMoney (www.webmoney.ru)
#	 Z675372326967
#	 R469153188527
#	 E455023833924
#
# ��������:
#	E-mail:    - mpak@xhackers.ru
#	Home Page: - www.xhackers.ru
#	IRC:       - MPAK (irc.xhackers.ru:6667@#xhackers)
#
# ���������:
#	http://www.xhackers.ru/
#	Forum: http://forum.xhackers.ru/
#	#xhackers@HubNet(Ru)
#	#xhackers@IRCNet(Ru)
#	#xhackers@DalNet(Ru)
#
# �������:
#	���:     F �������         F �������         F �������         F �������
#	-------- - --------------- - --------------- - --------------- - ---------------
#	�����:   - !passgen        - !pgen           - !pgsys
#	������:  - !passgen        - !pgen           - !pgsys
#	DCC:     - N/A
#
# ����� ������:
#	����                  �������� �����
#	--------------------- ----------------------------------------------------------
#	+nopubpassgen         �������� ������� !passgen �� ������
#	-nopubpassgen         ������� ������� !passgen �� ������
#
#	* ��� ��������� ����� �� ����� �����������: .chanset #chan +flag
#	������� �������� � partyline (DCC CHAT) � ����.
#
########################################################################################
# ������� ������:
#	(04/04/2006) - v2.2
#		* �������� ����� ��� ��������� ������� - �������.
#		* ��������� ����������� ��������� ���������� ������� �� ���� ���.
#		* ����������� ������ ������ �����. ������ ��� �����������. ������ ������
#		�������� ��� �����, ������� "�������".
#	(29/03/2006) - v2.1
#		* ��������� ������ �������. ��� ����� ����� �����.
#	(08/10/2005) - v2.0
#		* ����������� ������� ������������� ������� �� ������������ ������.
#		* ����� ����� ��������� �������������� ������� �� ������.
#		* �������� help �� ������� !passgen help
#		* ������ ����� �������� ���������� �������� � ������ � ��� ��������� ������
#	(unknown)    - v1.8
#		* ��������� ������� �� ������� !passgen. ��� ��������� ������������� � 
#		����� �������, ��������� �����, ��� ���������� �������� � ��������������� 
#		������ � ��� ���.
########################################################################################
namespace eval passgen {}; setudef flag nopubpassgen

# ������� ����� �������� passgen
set passgen(prefix) "!"

# ��� ������ �����, �������� "�������" ���� ��� "�����������". "�������" ��������
# ��� �����, ������� �������� ������� ���������� ����� �� ��������� ������. (�������
# ��������� �� IRC �������, � ������� �� �� ����� ����������� �� ����) (big/small)
set passgen(helptype) "big"

# ����������� ���������� ����� ��� ��������� ������.
set passgen(pass_minlength) "3"

# ������������ ���������� ����� ��� ��������� ������.
set passgen(pass_maxlength) "50"

# ������������ ���������� ������������ ������� �� ���� ���.
set passgen(gen_maxlength) "10"

# ����� ����� ��������� �������������� ������� passgen �� ������. (� ��������)
set passgen(time) "5"

########################################################################################

bind pub - $passgen(prefix)passgen   ::passgen::pub_passgen
bind msg - $passgen(prefix)passgen   ::passgen::msg_passgen
bind pub - $passgen(prefix)pgen      ::passgen::pub_passgen
bind msg - $passgen(prefix)pgen      ::passgen::msg_passgen
bind pub - $passgen(prefix)pg        ::passgen::pub_passgen
bind msg - $passgen(prefix)pg        ::passgen::msg_passgen

########################################################################################

set passgen(symbols) {chr33 chr34 chr35 chr36 chr37 chr38 chr39 chr40 chr41 chr42 chr43 chr44 chr45 chr46 chr47 chr58 chr59 chr60 chr61 chr62 chr63 chr64 chr91 chr92 chr93 chr94 chr95 chr96 chr123 chr124 chr125 chr126}
set passgen(small) {a b c d e f g h i j k l m n o p q r s t u v w x y z}
set passgen(big) {A B C D E F G H I J K L M N O P Q R S T U V W X Y Z}
set passgen(numbers) {0 1 2 3 4 5 6 7 8 9}

set passgen(version) "2.2"
set passgen(authors) "MPAK <mpak@xhackers.ru>"
set passgen(www) "www.xhackers.ru"

########################################################################################

proc ::passgen::out {nick chan text} {
	global botnick
	if {$nick != $botnick} {
		if {[validchan $chan]} {putserv "NOTICE $nick :$text"
		} elseif {$nick == $chan} {putserv "PRIVMSG $nick :$text"
		} else {putserv "NOTICE $nick :$text"}
	} else {putserv "PRIVMSG $chan :$text"}
}

########################################################################################

proc ::passgen::pub_passgen {nick uhost hand chan args} {
 global passgen lastbind
	if {![validchan $chan]} {return}
	if {[channel get $chan nopubpassgen]} {::passgen::out $nick $chan "�� ������ \002$chan\002 ������� \002$lastbind\002 ���������. ����������� �������� ����."; return}
	set passgen_timers [utimers]
	foreach line $passgen_timers { if {"::passgen::timers_reset $uhost" == [lindex $line 1]} { set passgen_timers_time [lindex $line 0] } }
		if { [info exists passgen(host,$uhost)] } { set temp [::passgen::duration $passgen_timers_time]
		if {$passgen(time) > 0} { ::passgen::out $nick $chan "������� \002$lastbind\002 ����� �������� ����� $temp. ����������� �������� ����." }; return }
	set passgen(host,$uhost) 1; set passgen(timer,$uhost) [utimer $passgen(time) [list ::passgen::timers_reset $uhost ] ]
	regsub -all -- {\\} [join $args] "" args

	::passgen::passgen $nick $uhost $hand $chan [string trim $args]
}

proc ::passgen::msg_passgen {nick uhost hand args} {
 global passgen
	regsub -all -- {\\} [join $args] "" args

	::passgen::passgen $nick $uhost $hand $nick [string trim $args]
}

########################################################################################

proc ::passgen::passgen {nick uhost hand chan args} {
 global passgen lastbind
	set args [lindex $args 0]; set args [encoding convertto cp1251 [encoding convertfrom cp1251 $args]]

	if {$args == "" || $args == "help" || $args == "hel" || $args == "����"} {
		if {$passgen(helptype) == "big"} {
		::passgen::out $nick $chan "���������: \002$lastbind \037<��� ���������>\037 \037<����� ������>\037 \037<���������� �������>\037\002."
		::passgen::out $nick $chan "����� ������ ����� ���� �� \002$passgen(pass_minlength)\002 �� \002$passgen(pass_maxlength)\002 ��������. �������� \002<���������� �������>\002 ��������� �������������. ������������ ���������� ������������ �������, ��� �������� ����� ���������: \002$passgen(gen_maxlength)\002"
		::passgen::out $nick $chan "\037���� ��������� �������:\037"
		::passgen::out $nick $chan "\002f\002 - ������. ��������� � ���� ��� ����. \[bsnz\]"
		::passgen::out $nick $chan "\002b\002 - ������� �����. \[A-Z\]"
		::passgen::out $nick $chan "\002s\002 - ��������� �����. \[a-z\]"
		::passgen::out $nick $chan "\002n\002 - �����. \[0-9\]"
		::passgen::out $nick $chan "\002z\002 - �������. \[~@%$\]"
		::passgen::out $nick $chan "���� ��������� ����� ���������. ��������: \002$lastbind \037nz\037 \0375\037\002 - ����������� ������ �� ���� � ��������. \002$lastbind \037bsn\037 \03710\037 \0375\037\002 - ����������� 5 ������� �� ����, ������� � ��������� ����, ������� 10 ��������. \[Script Version: \002$lastbind \037ver\037\002\]"
		 return
		}
		::passgen::out $nick $chan "���������: \002$lastbind \037<��� ���������>\037 \037<����� ������>\037 \037<���������� �������>\037\002. ����� ������ ����� ���� �� \002$passgen(pass_minlength)\002 �� \002$passgen(pass_maxlength)\002 ��������. �������� \002<���������� �������>\002 ��������� �������������. ������������ ���������� ������������ �������, ��� �������� ����� ���������: \002$passgen(gen_maxlength)\002"
		::passgen::out $nick $chan "���� ��������� �������: \002f\002 - ������. ��������� � ���� ��� ����. \[bsnz\]\; \002b\002 - ������� �����. \[A-Z\]\; \002s\002 - ��������� �����. \[a-z\]\; \002n\002 - �����. \[0-9\]\; \002z\002 - �������. \[~@%$\]"
		::passgen::out $nick $chan "���� ��������� ����� ���������. ��������: \002$lastbind \037nz\037 \0375\037\002 - ����������� ������ �� ���� � ��������. \002$lastbind \037bsn\037 \03710\037 \0375\037\002 - ����������� 5 ������� �� ����, ������� � ��������� ����, ������� 10 ��������. \[Script Version: \002$lastbind \037ver\037\002\]"
	return
	}

	if {$args == "author" || $args == "autho" || $args == "auth" || $args == "version" || $args == "vers" || $args == "ver" || $args == "�����" || $args == "���" || $args == "������" || $args == "����" || $args == "���" } {
		::passgen::out $nick $chan "passgen.tcl v$passgen(version)"
		::passgen::out $nick $chan "Authors: $passgen(authors) \[$passgen(www)\]"
	return
	}

	set passgen(gentype) "[lindex $args 0]"; set passgen(gensymbols) "[lindex $args 1]"; set passgen(passcount) "[lindex $args 2]"

	if {[regexp \[^A-Za-z\] $passgen(gentype)] || [regexp -nocase -- {[acdeghijklmopqrtuvwxy]} $passgen(gentype)]} {::passgen::out $nick $chan "������������ ��� ���������. ������: \002$passgen(prefix)passgen \037help\037\002"; return}
	if {[regexp \[^0-9\] $passgen(gensymbols)] || $passgen(gensymbols) == ""} {::passgen::out $nick $chan "������ ����� ���� ������ �� ����. ������: \002$passgen(prefix)passgen \037help\037\002"; return}
	if {$passgen(gensymbols) < $passgen(pass_minlength) || $passgen(gensymbols) > $passgen(pass_maxlength) } {::passgen::out $nick $chan "����� ������ ����� ���� �� \002$passgen(pass_minlength)\002 �� \002$passgen(pass_maxlength)\002 ��������. ������: \002$lastbind \037help\037\002 ������ �������: \002$lastbind \037ver\037\002"; return }
	if {$passgen(passcount) > $passgen(gen_maxlength)} {::passgen::out $nick $chan "���������� ������������ ������� �� ���� ��� ����� ���� �� ����� \002$passgen(gen_maxlength)\002 ����. ������: \002$lastbind \037help\037\002 ������ �������: \002$lastbind \037ver\037\002"; return }
	if {$passgen(gentype) == "f"} { set passgen(gentype) "bsnz" }
	if {[regexp -nocase -- {[bsnz]} $passgen(gentype)] && ![regexp -nocase -- {[acdefghijklmopqrtuvwxy]} $passgen(gentype)]} {

		if {$passgen(passcount) != ""} {
			set countr 0
			while {$countr < $passgen(passcount)} {incr countr; ::passgen::out $nick $chan "\002$countr\002/\002$passgen(passcount)\002 \037PassGen\037 \[symbols: \002$passgen(gensymbols)\002\]: [::passgen::generate_pass $passgen(gentype) [lindex $args 1]]" }
		   return
		}
	::passgen::out $nick $chan "\037PassGen\037 \[symbols: \002$passgen(gensymbols)\002\]: [::passgen::generate_pass $passgen(gentype) $passgen(gensymbols)]"
	return
	}
 ::passgen::out $nick $chan "������: \002$lastbind \037help\037\002 ������ �������: \002$lastbind \037ver\037\002"
}

proc ::passgen::generate_pass {gentype length} {
 global passgen
	set passgen(counter) "0"; set passgen(password) ""

	while {$passgen(counter) < $length } {
		set passgen(gentype_b) ""; set passgen(gentype_s) ""; set passgen(gentype_n) ""; set passgen(gentype_z) ""

		if {[regexp -nocase -- {[b]} $gentype]} { set passgen(gentype_b) "[lindex $passgen(big) [rand [llength $passgen(big)]]]" }
		if {[regexp -nocase -- {[s]} $gentype]} { set passgen(gentype_s) "[lindex $passgen(small) [rand [llength $passgen(small)]]]" }
		if {[regexp -nocase -- {[n]} $gentype]} { set passgen(gentype_n) "[lindex $passgen(numbers) [rand [llength $passgen(numbers)]]]" }
		if {[regexp -nocase -- {[z]} $gentype]} { set passgen(gentype_z) "[lindex $passgen(symbols) [rand [llength $passgen(symbols)]]]" }

		set passgen(ggentype) "$passgen(gentype_b) $passgen(gentype_s) $passgen(gentype_n) $passgen(gentype_z)"
		set passgen(gentype_type) "[lindex $passgen(ggentype) [rand [llength $passgen(ggentype)]]]"

			regsub -all -- {chr33} $passgen(gentype_type) {\!} passgen(gentype_type); regsub -all -- {chr34} $passgen(gentype_type) {\"} passgen(gentype_type); regsub -all -- {chr35} $passgen(gentype_type) {\#} passgen(gentype_type)
			regsub -all -- {chr36} $passgen(gentype_type) {\$} passgen(gentype_type); regsub -all -- {chr37} $passgen(gentype_type) {\%} passgen(gentype_type); regsub -all -- {chr38} $passgen(gentype_type) {\&} passgen(gentype_type)
			regsub -all -- {chr39} $passgen(gentype_type) {\'} passgen(gentype_type); regsub -all -- {chr40} $passgen(gentype_type) {\(} passgen(gentype_type); regsub -all -- {chr41} $passgen(gentype_type) {\)} passgen(gentype_type)
			regsub -all -- {chr42} $passgen(gentype_type) {\*} passgen(gentype_type); regsub -all -- {chr43} $passgen(gentype_type) {\+} passgen(gentype_type); regsub -all -- {chr44} $passgen(gentype_type) {\,} passgen(gentype_type)
			regsub -all -- {chr45} $passgen(gentype_type) {\-} passgen(gentype_type); regsub -all -- {chr46} $passgen(gentype_type) {\.} passgen(gentype_type); regsub -all -- {chr47} $passgen(gentype_type) {\/} passgen(gentype_type)
			regsub -all -- {chr58} $passgen(gentype_type) {\:} passgen(gentype_type); regsub -all -- {chr59} $passgen(gentype_type) {\;} passgen(gentype_type); regsub -all -- {chr60} $passgen(gentype_type) {\<} passgen(gentype_type)
			regsub -all -- {chr61} $passgen(gentype_type) {\=} passgen(gentype_type); regsub -all -- {chr62} $passgen(gentype_type) {\>} passgen(gentype_type); regsub -all -- {chr63} $passgen(gentype_type) {\?} passgen(gentype_type)
			regsub -all -- {chr64} $passgen(gentype_type) {\@} passgen(gentype_type); regsub -all -- {chr91} $passgen(gentype_type) {\[} passgen(gentype_type); regsub -all -- {chr92} $passgen(gentype_type) {\\} passgen(gentype_type)
			regsub -all -- {chr93} $passgen(gentype_type) {\]} passgen(gentype_type); regsub -all -- {chr94} $passgen(gentype_type) {\^} passgen(gentype_type); regsub -all -- {chr95} $passgen(gentype_type) {\_} passgen(gentype_type)
			regsub -all -- {chr96} $passgen(gentype_type) {\`} passgen(gentype_type); regsub -all -- {chr123} $passgen(gentype_type) {\{} passgen(gentype_type); regsub -all -- {chr124} $passgen(gentype_type) {\|} passgen(gentype_type)
			regsub -all -- {chr125} $passgen(gentype_type) {\}} passgen(gentype_type); regsub -all -- {chr126} $passgen(gentype_type) {\~} passgen(gentype_type); regsub -all -- {\\} $passgen(gentype_type) {} passgen(gentype_type)

		set passgen(password) "$passgen(password)$passgen(gentype_type)"
	incr passgen(counter)
	}
  return $passgen(password)
}

proc ::passgen::duration {seconds} {
   set years [expr {$seconds / 31449600}]; set seconds [expr {$seconds % 31449600}]
   set weeks [expr {$seconds / 604800}]; set seconds [expr {$seconds % 604800}]
   set days [expr {$seconds / 86400}]; set seconds [expr {$seconds % 86400}]
   set hours [expr {$seconds / 3600}]; set seconds [expr {$seconds % 3600}]
   set minutes [expr {$seconds / 60}]; set seconds [expr {$seconds % 60}]
   set res ""
   if {$years != 0} { lappend res [::passgen::numstr $years "���" "���" "����"] }
   if {$weeks != 0} { lappend res [::passgen::numstr $weeks "������" "������" "������"] }
   if {$days != 0} { lappend res [::passgen::numstr $days "����" "����" "���"] }
   if {$hours != 0} { lappend res [::passgen::numstr $hours "�����" "���" "����"] }
   if {$minutes != 0} { lappend res [::passgen::numstr $minutes "�����" "������" "������"] }
   if {$seconds != 0} { lappend res [::passgen::numstr $seconds "������" "�������" "�������"] }
  return [join $res ", "]
}

proc ::passgen::numstr {val str1 str2 str3} {
   set duration1 [expr $val % 10]; set duration2 [expr $val % 100]
   if {$duration2 < 10 || $duration2 > 19} {
	if {$duration1 == 1} { return "$val $str2" }
	if {$duration1 >= 2 && $duration1 <= 4} { return "$val $str3" }
   }
  return "$val $str1"
}

proc ::passgen::timers_reset {uhost} {
 global passgen
	catch {killutimer $passgen(timer,$uhost)}
	catch {unset passgen(timer,$uhost)}
	catch {unset passgen(host,$uhost)}
}


putlog "passgen.tcl v$passgen(version) by $passgen(authors) - loaded. \[\002$passgen(www)\002\]"
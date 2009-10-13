#----------------------------------------------------------------------------
# ncalc			-�����������-���������
# ���������:	.chanset #chan +ncalc
# ������:		! <�����> - ����� �����������
#				!!  <���������> - ����������� Google
#				!!! <���������> - ����������� Nigma
# ���� Google:	http://www.google.ru/intl/ru/help/features.html
# ���� Nigma: 	http://www.nigma.ru/index_menu.php?action=click_menu&menu_element=math_task_list
# �������:		anaesthesia #eggdrop@Rusnet
# �������:		http://weird.42-club.ru/
#----------------------------------------------------------------------------
# ������ ����������� ��� ����� � ������ suzi
# v.01.1	+ �������� nigma.ru
# v.01.2	+ �������� google define
# v.01.3    + �������� wolfram alpha

package require Tcl 	8.5
package require http	2.5

namespace eval ncalc {
#----------------------------------------------------------------------------
# ��������� ��������� ������������
#----------------------------------------------------------------------------
	# �������� � ������������ �������, ������, ���� ��������� �����������
	variable author			"anaesthesia"
	variable version		"01.3"
	variable date			"16-May-2009"
	variable unamespace		[namespace tail [namespace current]]

	# ������� ��� ��������� ������ (����� ���� ������ �������)
	variable pubprefix 		{}
	variable pubflag		{-|-}

	# ������� ������ (�����)
	# ������� � � ��������� ��������, ������ � ������� �������� ��������� ��������
	# Nigma
	variable nbind			{!!! !mc+}
	# Google
	variable gbind			{!! !mc}
	# Define
	variable dbind			{! \? !cm}
	# Wolfram
	variable wbind			{!!!! \?\? !cm+}

	# pubcmd:���_����������� "�������1 �������2 ..."
	variable pub:ncalc		"$nbind $gbind $dbind $wbind"

	# ���� ��� � ����, ��� ��������� ������
	variable msgprefix		$pubprefix
	variable msgflag		{-|-}

	# ����� �� ������� ��� ��� ��������� �������
	variable msg:ncalc		${pub:ncalc}

	#* ����� ��������� ��������� ��� ��������� �������, ������ � �������� ������� ������ ������
	#* ��� ��������������� ����������  variable [pub|msg]:handler "string ..."

	# ����� �������������� ������������ ��� ���������� ��������
	# �������� $unick, $uhost, $uchan
	# ������� tcl ���������, ����������� ������������ ���������� id ��� ������������� �������.
	variable requserid		{$uhost}
	
	# ������������ ����� ��������� ���������� �������� ��� ������ id
	variable maxreqperuser	1

	# ������������ ����� ��������� ���������� ��������
	variable maxrequests	5

	# ����� ����� ���������, � ������� ������� ������ ���������� ��� �������������, ������ 
	variable pause			5
	
	# ����� ������-�������
	# ������ ���� "proxyhost.dom:proxyport" ��� ������ ������, ���� ������-������ �� ������������
	variable proxy 			{}

	# ��������� ���������� �����, ���� �������� "" -- ����� �����������
	# ��������, �� ���� ���� ���� ���� ���������� �� ������ -- ������ ��������
	# ���� "no" �������� ���� ���������� ��������� ��� ���� ����� �����������
	# �������� � ������ ���������� �� ������ ��������� ������ �������
	# (��� ���� ������ �������� �� ���� �������, ��� �� ����������� ���� ����)
	variable flagactas		""
	
	# ��� ���������� �����, ��������� ��� ���������/���������� ������� �� ������
	# �� ��������� ����������� �� ������ ������ ����� � ����� ����������
	# � ������ ������ ����� ������ �����������  
	# ��� ��������� �� ������ ��������� ������

	variable chflag			"$flagactas$unamespace"
	setudef  flag 			$chflag

#----------------------------------------------------------------------------
# ��������� ��������� ������������
#----------------------------------------------------------------------------
	# ����� ��� �������� -- ������ ������ ��� �� ������, ����� ��������������� ����� � ���
	variable logrequests	{'$unick', '$uhost', '$handle', '$uchan', '$str'}
	
	# ������� ������ ��� ���������� �������, �� ��������� -- �� �����
	# �������� $uchan & $unick
	variable pubsend		{PRIVMSG $uchan :}

	# ������� ������ ��� ���������� �������, �� ��������� -- ��������� ���������
	# �������� ������ $unick ($uchan == $unick)
	variable msgsend		{PRIVMSG $unick :}
	
	# ������� ������ ��� ������/������������� �������
	# �������� $unick
	variable errsend		{NOTICE $unick :}

	# ������������ ����� ���������� � ����������� ��������
	variable maxredir		3
	
	# ������� ������� � �������������, �� ���� 30 ������
	variable timeout		40000

	# ��������� � �������� �������
	variable err_ok			{}

	# ��������� � ������������� �������� ������, ������� � ������� �� ��������
	# ������ ���������� � ������������� �� �������� 
	variable err_fail		{� ��������� ��� ������ �� ��������. �������� �� ������� ��������� � ��������-��������.}

	# ��������� � ������������� ������� ��������
	variable err_queue_full	{� ������ ����� ������� ������� ��������� � �� ����� ��������� ��� ������. ��������� ������� �����.}
	
	# ��������� � ������������� ������� ��� ����������� id
	variable err_queue_id	{���������� ��������� ��������� ���������� ��������.}
	
	# ��������� � ��� ��� ����� ����� ��������������� ������� �� �������
	# �������� ���������� $timewait -- ���������� �����, �� ��������� �������� ������ ����� ��������
	variable err_queue_time {���������� ��������� ������� �����. ������ ����� �������� ��� ������������� ����� $timewait ���.}
	
#----------------------------------------------------------------------------
#  ���������� ���������� � ���
#----------------------------------------------------------------------------
	# ������� ��������
	variable 		reqqueue
	array unset 	reqqueue

	# ��������� ����������
	variable 		laststamp
	array unset		laststamp 

#---body---

	proc msg:ncalc {unick uhost handle str} {pub:ncalc $unick $uhost $handle $unick $str ; return}

	proc pub:ncalc {unick uhost handle uchan str} {
		variable requserid ; variable unamespace
		variable chflag ; variable flagactas ; variable logrequests
		variable pubprefix ; variable pubsend ; variable msgsend ; variable errsend
		variable wbind ; variable nbind ; variable gbind ; variable dbind ; variable type ; variable gtype

		set id [subst -noc $requserid]
		set prefix [subst -noc $errsend]
		if {$unick ne $uchan} {if {![channel get $uchan $chflag] ^ $flagactas eq "no" } {return}}
		set why [queue_isfreefor $id]
		if {$why != ""} {lput puthelp $why $prefix ; return}

		set ustr [uenc $str]
			if {[string is space $ustr]} {return}
			if {$ustr eq {?}} {
				if {$uchan eq $unick} {set prefix [subst -noc $msgsend]} {set prefix [subst -noc $pubsend]}
				lput puthelp "\002������\002: \002${pubprefix}[lindex $nbind 0]\002 <���������> \037���\037 \002${pubprefix}[lindex $gbind 0]\002 <���������> \037���\037 \002${pubprefix}[lindex $dbind 0]\002 <������> :: �����������-���������-����������." $prefix		
				lput puthelp "\002������\002: ${pubprefix}[lindex $nbind 0] x2-3x+2=0 :: ${pubprefix}[lindex $gbind 0] 3 GBP + 1 ���� � �������� :: ${pubprefix}[lindex $dbind 0] ����" $prefix		
			return
			} elseif {[string trimleft $::lastbind $pubprefix] in $nbind} {
				::http::config -urlencoding utf-8 -useragent "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; 240x320)"	
				#set fetchurl "http://www.nigma.ru/index.php?t=web&gl=0&yh=0&ms=0&yn=0&rm=0&av=0&ap=0&nm=1&lang=all&s="
				set fetchurl "http://www.nigma.ru/index.php?t=web&s="
				set type 1 ; set gtype 0
			} elseif {[string trimleft $::lastbind $pubprefix] in $dbind} {
				::http::config -urlencoding utf-8 -useragent "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)"	
				set fetchurl "http://www.google.ru/search?lr=&hl=ru&btnG=Search&safe=off&q=define:"
				set type 0 ; set gtype 0
			} elseif {[string trimleft $::lastbind $pubprefix] in $wbind} {
				::http::config -urlencoding utf-8 -useragent "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; 240x320)"	
				set fetchurl "http://www.wolframalpha.com/input/?i="
				set type 2 ; set gtype 0
			} {			
				::http::config -urlencoding utf-8 -useragent "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)"	
				set fetchurl "http://www.google.ru/search?lr=&btnG=Search&safe=off&q="
				set type 0 ; set gtype 1
			}
#putlog "$fetchurl$ustr"
		if {$logrequests ne ""} {set logstr [subst -noc $logrequests] ; lput putlog $logstr "$unamespace: "}
		if {[queue_add "$fetchurl${ustr}" $id "[namespace current]::ncalc:parser" [list $unick $uhost $uchan $str]]} {
			variable err_ok ; if {$err_ok ne ""} {lput puthelp "$err_ok." $prefix}
		} {
			variable err_fail ; if {$err_fail ne ""} {lput puthelp "$err_fail" $prefix}
		}

	return
	}

#---parser
	proc ncalc:parser {errid errstr body extra} {
		upvar $errid lerrid $errstr lerrstr $body lbody $extra lextra
		variable err_fail ; variable pubsend ; variable msgsend ; variable errsend
		variable type ; variable gtype

		foreach {unick uhost uchan ustr} $lextra {break}
		if {$lerrid ne {ok}} {lput putserv [subst -noc $err_fail] [subst -noc $errsend] ; return}
		if {$uchan eq $unick} {set prefix [subst -noc $msgsend]} {set prefix [subst -noc $pubsend]}
		if {[info exists ::sp_version]} {regsub -all -- {(?x)[\xCC][\x81]} $lbody "" lbody ; set str [encoding convertfrom utf-8 $lbody]} {set str [encoding convertto cp1251 [encoding convertfrom utf-8 $lbody]]}
#----------------------------------------------------------------------------
##---parser-specific------
#----------------------------------------------------------------------------

	if {$type == 2} {
		set wr [list]
		if {[string match -nocase "*Alpha isn't sure what to do*" $str]} {lput putserv "\037������\037." $prefix ; return}
		if {![regexp -- {<div id="knownerror".*?>(.*?)<hr class="bot"/></div>} $str -> werr]} {set werr ""} {regsub -all -- "<.*?>" $werr "" werr ; if {![string is space $werr]} {lappend wr [sconv $werr]}}
		if {![regexp -- {javascript:showmathpop\((.*?)\);} $str -> winp]} {set winp ""} {if {![string is space $winp]} {lappend wr [sconv $winp]}}
		if {![regexp -- {id="i_0100_1" alt="(.*?)" } $str -> winp_]} {set winp_ ""} {if {![string is space $winp_]} {lappend wr [sconv $winp_]}}
		if {![regexp -- {id="i_0200_1" alt="(.*?)" } $str -> wres]} {set wres ""} {if {![string is space $wres]} {lappend wr [sconv $wres]}}
		if {![regexp -- {id="i_0300_1" alt="(.*?)" } $str -> wres_]} {set wres_ ""} {if {![string is space $wres_]} {lappend wr [sconv $wres_]}}
		if {[llength $wr]} {regsub -all -- {\\:} $wr {\\u} wr; lput putserv "[sspace [join [subst -noc -nov $wr] " \002 -> \002 "]]" $prefix} {lput putserv "\037������\037." $prefix} ; return
	} elseif {$type == 1} {
		if {![regexp -nocase -- {<title>NIGMA :(.*?)</title>} $str -> nq]} {set nq "error"}
		if {[regexp -nocase -- {<div class="resh" id="math_board">(.+?)<div class="bottom">} $str -> nr]} {
			set res [list]
			foreach {- r} [regexp -all -inline -- {<img.*?src="http://lsd.nigma.ru:80/maxima/Render.app.php/execute.*?alt=\'(.*?)\'.*?/>} $nr] {lappend res $r}
			if {[llength $res]} {
				lput putserv [sspace "[string trim $nq] \002 >> \002 [string map {"\\," "*" "\\left" "" "\\right" "" "\\over" "/" "\{" "" "\}" "" "\\approx" "" "\\;" " " "\\ " " ; " "\$" "" "&lt;" "<" "&gt;" ">" "&" "" "\\begin" "" "\\end" "" "aligned" "" "times" "*" "\\" ""} [join $res " \002 -> \002 "]]"] $prefix
			} {lput putserv "[string trim $nq] \002 >> \002 �� ������� ������. ��������� ������������ ���������." $prefix}
		} {lput putserv "\037������\037." $prefix}
	} {
		if {$gtype} {
			if {[regexp -nocase -- {<img src=/images/calc_img.*?<h2 class=r.*?>(.*?)</h2>} $str -> gr]} {
				regsub -all -nocase -- {<sup>(.*?)</sup>} $gr "^\\1" gr
				regsub -all -- "<.*?>" $gr "" gr
				regsub -all -- {&#215;} $gr {*} gr
				set res $gr
			} elseif {[regexp -nocase -- {<div id=res class=med><p><font color="#cc0000" class=p>(.*?)</a>} $str -> gr]} {
				regsub -all -nocase -- "<b>|</b>" $gr "\002" gr
				regsub -all -- "<.*?>" $gr "" gr
				set res $gr
			} {set res "\037������\037."}
		} {
			if {[regexp -nocase -- {<ul type="disc" class=std>(.*?)</ul>} $str -> gd]} {
				regsub -all -- "\n|\r|\t" $gd "" gd
				regsub -all -- {&#769;|\\u769} $gd {'} gd
				regsub -all -- "<li>" $gd "\n" gd
				set res "" ; set cnt 1
				foreach gl [split $gd \n] {if {[regexp -- {^(.*?)<br>.*?<font color=.*?>(.*?)</font>} $gl -> gdef gurl]} {incr cnt ; append res ":: $gdef @ \037\00312http://$gurl\003\037 " ; if {$cnt > 3} {break}}}
			} elseif {[regexp -nocase -- {<p><span style="color:#cc0000" class=spell>(.*?)</a>} $str -> gr]} {
				regsub -all -nocase -- "<b>|</b>" $gr "\002" gr
				regsub -all -- "<.*?>" $gr "" gr
				set res [string map {"define:" ""} $gr]
			} {set res "\037������\037."}
		}
	lput putserv [sconv [sspace $res]] $prefix	
	}

	return
	}		
#----------------------------------------------------------------------------
##---end-parser------
#----------------------------------------------------------------------------

	proc sspace {strr} {return [string trim [regsub -all {[\t\s]+} $strr { }]]}

	proc uenc {strr} {
		set str "" ; foreach byte [split [encoding convertto utf-8 $strr] ""] {scan $byte %c i ; if {[string match {[%<>"]} $byte] || $i < 65 || $i > 122} {append str [format %%%02X $i]} {append str $byte}}
	return [string map {%3A : %2D - %2E . %30 0 %31 1 %32 2 %33 3 %34 4 %35 5 %36 6 %37 7 %38 8 %39 9 \[ %5B \\ %5C \] %5D \^ %5E \_ %5F \` %60} $str]
    }

	proc sconv {strr} {
	set escapes {
        &nbsp; \x20 &quot; \x22 &amp; \x26 &apos; \x27 &ndash; \x2D
        &lt; \x3C &gt; \x3E &tilde; \x7E &euro; \x80 &iexcl; \xA1
        &cent; \xA2 &pound; \xA3 &curren; \xA4 &yen; \xA5 &brvbar; \xA6
        &sect; \xA7 &uml; \xA8 &copy; \xA9 &ordf; \xAA &laquo; \xAB
        &not; \xAC &shy; \xAD &reg; \xAE &hibar; \xAF &deg; \xB0
        &plusmn; \xB1 &sup2; \xB2 &sup3; \xB3 &acute; \xB4 &micro; \xB5
        &para; \xB6 &middot; \xB7 &cedil; \xB8 &sup1; \xB9 &ordm; \xBA
        &raquo; \xBB &frac14; \xBC &frac12; \xBD &frac34; \xBE &iquest; \xBF
        &Agrave; \xC0 &Aacute; \xC1 &Acirc; \xC2 &Atilde; \xC3 &Auml; \xC4
        &Aring; \xC5 &AElig; \xC6 &Ccedil; \xC7 &Egrave; \xC8 &Eacute; \xC9
        &Ecirc; \xCA &Euml; \xCB &Igrave; \xCC &Iacute; \xCD &Icirc; \xCE
        &Iuml; \xCF &ETH; \xD0 &Ntilde; \xD1 &Ograve; \xD2 &Oacute; \xD3
        &Ocirc; \xD4 &Otilde; \xD5 &Ouml; \xD6 &times; \xD7 &Oslash; \xD8
        &Ugrave; \xD9 &Uacute; \xDA &Ucirc; \xDB &Uuml; \xDC &Yacute; \xDD
        &THORN; \xDE &szlig; \xDF &agrave; \xE0 &aacute; \xE1 &acirc; \xE2
        &atilde; \xE3 &auml; \xE4 &aring; \xE5 &aelig; \xE6 &ccedil; \xE7
        &egrave; \xE8 &eacute; \xE9 &ecirc; \xEA &euml; \xEB &igrave; \xEC
        &iacute; \xED &icirc; \xEE &iuml; \xEF &eth; \xF0 &ntilde; \xF1
        &ograve; \xF2 &oacute; \xF3 &ocirc; \xF4 &otilde; \xF5 &ouml; \xF6
        &divide; \xF7 &oslash; \xF8 &ugrave; \xF9 &uacute; \xFA &ucirc; \xFB
        &uuml; \xFC &yacute; \xFD &thorn; \xFE &yuml; \xFF
	}
	set strr [string map {"\[" "\\\[" "\]" "\\\]"} [string map $escapes [join [lrange [split $strr] 0 end]]]]
  	regsub -all -- {&#([[:digit:]]{1,5});} $strr {[format %c [string trimleft "\1" "0"]]} strr
 	regsub -all -- {&#x([[:xdigit:]]{1,4});} $strr {[format %c [scan "\1" %x]]} strr
 	regsub -all -- {&#?[[:alnum:]]{2,7};} $strr "" strr
	return [subst -nov $strr]
	}

	proc lput {cmd str {prefix {}} {maxchunk 420}} {
		set buf1 ""; set buf2 [list]
		foreach word [split $str] {append buf1 " " $word ; if {[string length $buf1]-1 >= $maxchunk} {lappend buf2 [string range $buf1 1 end]; set buf1 ""}}
		if {$buf1 != ""} {lappend buf2 [string range $buf1 1 end]}
		foreach line $buf2 {$cmd $prefix$line}
	return
	}

	proc queue_isfreefor {{ id {}}} {
		variable reqqueue ; variable maxreqperuser ; variable maxrequests ; variable laststamp
		variable pause ; variable err_queue_full ; variable err_queue_id ; variable err_queue_time 

		if {[info exists laststamp(stamp,$id)]} {set timewait [expr {$laststamp(stamp,$id) + $pause - [unixtime]}] ; if {$timewait > 0} {return [subst -noc $err_queue_time]}}
		if {[llength [array names reqqueue -glob "*,$id"]] >= $maxreqperuser} {return $err_queue_id}
		if {[llength [array names reqqueue]] >= $maxrequests} {return $err_queue_full}		
	return
	}

	proc queue_add {newurl id parser extra {redir 0}} {
		variable reqqueue ; variable proxy ; variable timeout ; variable laststamp

		::http::config -proxyfilter "[namespace current]::queue_proxy"

			if {![catch {set token [::http::geturl $newurl -command [namespace current]::queue_done -binary true -timeout $timeout]} errid]} {					
			set reqqueue($token,$id) [list $parser $extra $redir] ; set laststamp(stamp,$id) [unixtime]
			} {return false}
	return true
	}

	proc queue_proxy {url} {
		variable proxy
		if {$proxy ne {}} {return [split $proxy {:}]}		
	return [list]
	}
	
	proc queue_done {token} {
		upvar #0 $token state
		variable reqqueue ; variable maxredir ; variable fetchurl

		set errid  	[::http::status $token]
		set errstr 	[::http::error  $token]		
		set	id  	[array  names reqqueue "$token,*"]
		foreach {parser extra redir} $reqqueue($id) {break}
		regsub -- "^$token," $id {} id
	
		while (1) {
			if {$errid == "ok" && [::http::ncode $token] == 302} {
				if {$redir < $maxredir} {			
					array set meta $state(meta)
					if {[info exists meta(Location)]} {queue_add "$meta(Location)" $id $parser $extra [incr redir]; break}
				} {set errid "error" ; set errstr "Max. redir."}
			} 
			
			if {[catch {$parser {errid} {errstr} {state(body)} {extra}} errid]} {lput putlog $errid "[namespace current] "}
		break
		}			
		array unset reqqueue "$token,*"
		::http::cleanup $token
	return
	}

	proc queue_clear_stamps {} {
		variable laststamp ; variable timeout ; variable timerID

		set curr [expr {[unixtime] - 2 * $timeout / 1000}];
		foreach {id} [array names laststamp] {if {$laststamp($id) < $curr} {array unset laststamp $id}}		
		set timerID [timer 10 "[info level 0]"]
	}

	proc cmdaliases {{ action {bind}}} {
		foreach {bindtype} {pub msg dcc} {
			foreach {bindproc} [info vars "[namespace current]::${bindtype}:*"] {
				variable "${bindtype}prefix" ; variable "${bindtype}flag"			
				foreach {alias} [set $bindproc] {catch {$action $bindtype [set ${bindtype}flag] [set ${bindtype}prefix]$alias $bindproc}}				
			}
		}	
	return
	}

#---init
	if {[info exists timerID]} {catch {killtimer $timerID} ; catch {unset timerID}}	
	[namespace current]::queue_clear_stamps
	foreach bind [binds "[namespace current]::*"] {catch {unbind [lindex $bind 0] [lindex $bind 1] [lindex $bind 2] [lindex $bind 4]}}
	[namespace current]::cmdaliases
  	variable sfil [lindex [split [info script] "/"] end]
  	variable modf [clock format [file mtime [info script]] -format "%d-%b-%Y : %H:%M:%S"]
	if {[info exists ::sp_version]} {putlog "[namespace current] v$version (suzi_$sp_version) :: file:$sfil / rel:\[$date\] / mod:\[$modf\] :: by $author :: loaded."} {putlog "[namespace current] v$version :: file:$sfil / rel:\[$date\] / mod:\[$modf\] :: by $author :: loaded."}

} ;#end









#----------------------------------------------------------------------------
# mmnt 			- ����� �� mmnt.ru
# ���������:	.chanset #chan +mmnt
# ������:		!mwww [-�����] <������> - www-�����
# ������:		!mftp [-�����] <������> - ftp-�����
# ������:		!mmnt !ftp
# �������:		anaesthesia #eggdrop@Rusnet
# �������:		http://egghelp.ru
#----------------------------------------------------------------------------

package require Tcl 	8.5
package require http	2.5

namespace eval mmnt {
#----------------------------------------------------------------------------
# ��������� ��������� ������������
#----------------------------------------------------------------------------
	# �������� � ������������ �������, ������, ���� ��������� �����������
	variable author			"anaesthesia"
	variable version		"01.01"
	variable date			"17-Sep-2008"
	variable unamespace		[namespace tail [namespace current]]

	# ������� ��� ��������� ������ (����� ���� ������ �������)
	variable pubprefix 		{!}
	variable pubflag		{-|-}

	# ������� ������ (�����)
	# www-�����
	variable mwww			{mwww mmnt}
	# ftp-�����
	variable mftp			{mftp ftp}

	# pubcmd:���_����������� "�������1 �������2 ..."
	# ������� � � ��������� ��������, ������ � ������� �������� ��������� ��������
	variable pub:mmnt		"$mwww $mftp"

	# ���� ��� � ����, ��� ��������� ������
	variable msgprefix		{!}
	variable msgflag		{-|-}

	# ����� �� ������� ��� ��� ��������� �������
	variable msg:mmnt		${pub:mmnt}

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
	variable pause			10
	
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
	# ����� ��� �������� -- ������ ������ ��� �� ������
	# ����� ��������������� ����� � ���
	variable logrequests	{'$unick', '$uhost', '$handle', '$uchan', '$ustr'}
	
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
	variable timeout		30000

	# ��������� � �������� �������
	variable err_ok			{��� ������ ������}

	# ��������� � ������������� �������� ������, ������� � ������� �� ��������
	# ������ ���������� � ������������� �� �������� 
	variable err_fail		{� ��������� ��� ������ �� ��������. �������� �� ������� ��������� � ��������-��������.}

	# ��������� � ������������� ������� ��������
	variable err_queue_full	{� ������ ����� ������� ������� ��������� � �� ����� ��������� ��� ������. ��������� ������� �����.}
	
	# ��������� � ������������� ������� ��� ����������� id
	variable err_queue_id	{���������� ��������� ��������� ���������� ��������.}
	
	# ��������� � ��� ��� ����� ����� ��������������� ������� �� �������
	# �������� ���������� $timewait -- ���������� �����, �� ��������� ��������
	# ������ ����� ��������
	variable err_queue_time {���������� ��������� ������� �����. ������ ����� �������� ��� ������������� ����� $timewait ���.}
	
#----------------------------------------------------------------------------
#  ���������� ���������� � ���
#----------------------------------------------------------------------------

	# �����, � �������� ���������� ��������� ����������
	variable 		fetchurl		"http://www.mmnt.ru/"

	# ������� ��������
	variable 		reqqueue
	array unset 	reqqueue

	# ��������� ����������
	variable 		laststamp
	array unset		laststamp 
	variable		updinprogress	0
	variable		updatetimeout	60000

#---body---

	proc msg:mmnt {unick uhost handle str} {pub:mmnt $unick $uhost $handle $unick $str ; return}

	proc pub:mmnt {unick uhost handle uchan str} {
		variable requserid ; variable unamespace
		variable chflag ; variable flagactas ; variable logrequests
		variable pubprefix ; variable pubsend ; variable msgsend ; variable errsend
		variable type ; variable mpage
		variable query ; variable fetchurl ; variable mwww ; variable mftp

		set id [subst -noc $requserid]
		set prefix [subst -noc $errsend]
		if {$unick ne $uchan} {if {![channel get $uchan $chflag] ^ $flagactas eq "no" } {return}}
		set why  [queue_isfreefor $id]
		if {$why != ""} {lput puthelp $why $prefix ; return}
		set query ""

#---���������
		set ustr $str
		if {[regexp -nocase -- {^-(\d+)} $ustr -> mpage]} {regsub -- {-\d+\s+} $ustr "" ustr} {set mpage 1}
		::http::config -urlencoding utf-8 -useragent "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; 240x320)"	
			if {[string is space $ustr]} {
				if {$uchan eq $unick} {set prefix [subst -noc $msgsend]} {set prefix [subst -noc $pubsend]}
				lput puthelp "\002������\002: $pubprefix[lindex $mwww 0] \[-�����\] <������> - www-�����." $prefix		
				lput puthelp "\002������\002: $pubprefix[lindex $mftp 0] \[-�����\] <������> - ftp-�����." $prefix		
				return
			}
		if {[string trimleft $::lastbind ${pubprefix}] in $mftp} {
			set parm "get?st=[uenc $ustr]&in=f&cn=&ot=$mpage" ; set type 1
		} {
			set parm "get?st=[uenc $ustr]&in=w&ln=0&ot=$mpage" ; set type 0
		}

		if {$logrequests ne ""} {set logstr [subst -noc $logrequests] ; lput putlog $logstr "$unamespace: "}
		if {[queue_add "$fetchurl$parm" $id "[namespace current]::mmnt:parser" [list $unick $uhost $uchan $str]]} {
			variable err_ok ; if {$err_ok ne ""} {lput puthelp "$err_ok." $prefix}
		} {
			variable err_fail ; if {$err_fail ne ""} {lput puthelp "$err_fail" $prefix}
		}

	return
	}

#---parser
	proc mmnt:parser {errid errstr body extra} {
		upvar $errid lerrid $errstr lerrstr $body lbody $extra lextra
		variable err_fail ; variable pubsend ; variable msgsend ; variable errsend
		variable mpage ; variable type

		foreach {unick uhost uchan ustr} $lextra {break}
		if {$lerrid ne {ok}} {lput putserv [subst -noc $err_fail] [subst -noc $errsend] ; return}
		if {$uchan eq $unick} {set prefix [subst -noc $msgsend]} {set prefix [subst -noc $pubsend]}
		if {[info exists ::sp_version]} {set str [encoding convertfrom cp1251 $lbody]} {set str $lbody}

#----------------------------------------------------------------------------
##---parser-specific------
#----------------------------------------------------------------------------
	regsub -all -- "\n|\r|\t" $str "" str
	if {$type} {
		if {[regexp -- {<p style="font: 14px arial, sans-serif;">.*?<b>(.+?)</b></p>} $str -> fnum] && 
			[regexp -nocase -- {<p><table border=0.*?width=1>(.+?)\.</td><td><a href="(.+?)" target=_blank>.*?</font></td></tr><tr><td><tt>(.+?)</td></tr></table>} $str -> nr nl nd]} {
				regsub -all "<nobr>" $nd "/" nd ; regsub -all "&nbsp;" $nd "" nd ; regsub -all "<.*?>" $nd "" nd
				set nd [split $nd "/"] ; set nout "\00314\002[lindex $nd 0]\002 / ��������: [lindex $nd 1] / �������: [lindex $nd 2] / \002[lindex $nd 3]\002\003"
				lput putserv [sspace "\[$nr/[string map {" ���. " "" " ���. " ""} $fnum]\] :: \037\00312$nl\003\037 :: $nout"] $prefix
		} {lput putserv "\037������ �� �������\037." $prefix}
	} {
		if {[regexp -- {<p style="font: 14px arial, sans-serif;">.*?<b>(.+?)</b></p>} $str -> wnum] && 
			[regexp -nocase -- {<p><table border=0.*?width=1>(.+?)\.</td>.*?<a href="(.+?)".*?<font style=.*?>(.+?)</font></a>.*?<td class=d>(.+?)</td>.*?<tt><font color=#000000>(.+?)</font>.*?<font color=#008000>(.+?)\-(.+?)</font></td>} $str -> wr wl wh wd wdate wlink wsize]} {
				regsub -all -nocase -- "<b>|</b>" $wd "\002" wd ; regsub -all -nocase -- "<b>|</b>" $wh "\002" wh
				 regsub -all -- {<a href="(.+?)".*?>(.+?)</a>} $wd "\00312\037\\1\003\037 - \\2 ;" wd
				lput putserv [sconv [sspace "\[$wr/[string map {" ���. " "" " ���. " ""} $wnum]\] :: \037\00312$wl\003\037 :: \00305$wh\003 :: $wd :: \00314$wsize - ($wdate)\003"]] $prefix
		} {lput putserv "\037������ �� �������\037." $prefix}

	}

	return
	}		
#----------------------------------------------------------------------------
##---end-parser------
#----------------------------------------------------------------------------

	proc sspace {strr} {return [string trim [regsub -all {[\t\s]+} $strr { }]]}
	proc tolow  {strr} {return [string tolower [string map {� � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �} $strr]]}

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
	set strr [string map $escapes [join [lrange [split $strr] 0 end]]] 
    regsub -all -- {\[} $strr "\\\[" strr ; regsub -all -- {\]} $strr "\\\]" strr
    regsub -all -- {\(} $strr "\\\(" strr ; regsub -all -- {\)} $strr "\\\)" strr
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
		variable reqqueue ; variable proxy ; variable timeout ; variable laststamp ; variable query ; variable type

		::http::config -proxyfilter "[namespace current]::queue_proxy"

		if {$query eq ""} {
			if {![catch {set token [::http::geturl $newurl -command [namespace current]::queue_done -binary true -timeout $timeout]} errid]} {					
			set reqqueue($token,$id) [list $parser $extra $redir] ; set laststamp(stamp,$id) [unixtime]
			} {return false}
		} {
			if {![catch {set token [::http::geturl $newurl -command [namespace current]::queue_done -binary true -timeout $timeout -query $query]} errid]} {					
			set reqqueue($token,$id) [list $parser $extra $redir] ; set laststamp(stamp,$id) [unixtime]
			} {return false}
		}
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
					if {[info exists meta(Location)]} {queue_add "$fetchurl$meta(Location)" $id $parser $extra [incr redir]; break}
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











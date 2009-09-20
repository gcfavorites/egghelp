#----------------------------------------------------------------------------
# bred 			-��������������
# ���������:	.chanset #chan +bred
# ������:		!bred <?|����|�����|����|����|����|�����|������|�����|���|�����|����|�����|���|���|���|����|���|����1|����2|����3|����4|����5>				
# ������:		!����, !���	
# �������:		anaesthesia #eggdrop@Rusnet
# �������:		http://egghelp.ru
#----------------------------------------------------------------------------

package require Tcl 	8.4
package require http	2.5

namespace eval bred {
foreach p [array names bred *] {catch {unset bred ($p)}}

#----------------------------------------------------------------------------
# ��������� ��������� ������������ (Suzi / http.tcl)
#----------------------------------------------------------------------------
	# �������� � ������������ �������, ������, ���� ��������� �����������
	variable author			"anaesthesia"
	variable version		"01.2"
	variable date			"15-May-2008"
	variable unamespace		[namespace tail [namespace current]]

	# ������� ��� ��������� ������ (����� ���� ������ �������)
	variable pubprefix 		{!}
	variable pubflag		{-|-}

	# pubcmd:���_����������� "�������1 �������2 ..."
	# ������� � � ��������� ��������, ������ � ������� �������� ��������� ��������
	variable pub:bred		"$unamespace gon ��� ����"

	# ���� ��� � ����, ��� ��������� ������
	variable msgprefix		{!}
	variable msgflag		{-|-}
	# ����� �� ������� ��� ��� ��������� �������
	variable msg:bred		${pub:bred}

	# ����� ��������� ��������� ��� ��������� �������, ������ � �������� ������� ������ ������
	# ��� ��������������� ����������  variable [pub|msg]:handler "string ..."

	# ����� �������������� ������������ ��� ���������� ��������
	# �������� $unick, $uhost, $uchan
	# ������� tcl ���������, ����������� ������������ ���������� id ��� ������������� �������.
	variable requserid		{$uhost}
	
	# ������������ ����� ��������� ���������� �������� ��� ������ id
	variable maxreqperuser	1

	# ������������ ����� ��������� ���������� ��������
	variable maxrequests	5

	# ����� ����� ���������, � ������� ������� ������ ���������� ��� �������������, ������ 
	variable pause			35
	
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
	variable maxredir		1
	
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
	# ������, � ������� ���������� ��������� ����������
	variable 		fetchurl		"http://vesna.yandex.ru/"
	variable		fetchurls		"http://aigenerators.net/"
	variable		fetchurlg		"http://genn.org/stuff/stixs/"
	variable		fetchurlp		"http://referats.yandex.ru/pushkin/?write="
	variable		fetchurlf		"http://flexx.kiev.ua/generator.html"

	# ���������� ��������� �����������
	variable maxres		1

	# ������� ��������
	variable 		reqqueue
	array unset 	reqqueue

	# ��������� ����������
	variable 		laststamp
	array unset		laststamp 

	variable		updinprogress	0
	variable		updatetimeout	60000

#---body---

	proc msg:bred {unick uhost handle str} {
		pub:bred $unick $uhost $handle $unick $str
	return
	}

	proc pub:bred {unick uhost handle uchan str} {

		variable requserid
		variable fetchurl
		variable fetchurls
		variable fetchurlg
		variable fetchurlp
		variable fetchurlf
		variable brf
		variable stix
		variable chflag
		variable flagactas
		variable errsend
		variable maxres
		variable pubprefix
		variable pubsend
		variable msgsend
		variable unamespace
		variable logrequests

		set id [subst -nocommands $requserid]
		set prefix [subst -nocommands $errsend]

		if {$unick ne $uchan} {if {![channel get $uchan $chflag] ^ $flagactas eq "no"} {return}}
		set why [queue_isfreefor $id]
		if {$why != ""} {lput puthelp $why $prefix ; return}

#---���������
	set ustr [tolow $str]
	set brd "astronomy geology gyroskopy literature marketing mathematics music polit agrobiologia law psychology geograpgy physics philosophy chemistry estetica"
	set furl $fetchurl ; set stix 0; set brf 0

		if {$ustr == "?"} {
			if {$uchan eq $unick} {set prefix [subst -nocommands $msgsend]} {set prefix [subst -nocommands $pubsend]}
			lput puthelp "\002������\002: $pubprefix\���� <?|����|�����|����|����|����|�����|������|�����|���|�����|����|�����|���|���|���|����|���|����1|����2|����3|����4|����5> " $prefix		
			lput puthelp "��������������. ����� ��� ���������� ���������� ���� �� ���� ��������� ���." $prefix
			return
		} elseif {[string match "*����*" $str]}  {set burl "" ; set furl $fetchurlf ; set brf 1
		} elseif {[string match "*����1*" $str]} {set burl "" ; set furl $fetchurlg ; set stix 2
		} elseif {[string match "*����2*" $str]} {set burl "bad_love.php" ; set furl $fetchurls ; set stix 1
		} elseif {[string match "*����3*" $str]} {set burl "bad_love1.php" ; set furl $fetchurls ; set stix 1
		} elseif {[string match "*����4*" $str]} {set burl "pain.php" ; set furl $fetchurls ; set stix 1
		} elseif {[string match "*����5*" $str]} {set burl "sonnet" ; set furl $fetchurlp ; set stix 3
		} elseif {[string match "*�����*" $str]} {set burl "astronomy.xml" 
		} elseif {[string match "*����*" $str]}  {set burl "geology.xml" 
		} elseif {[string match "*����*" $str]}  {set burl "gyroskopy.xml" 
		} elseif {[string match "*�����*" $str]} {set burl "literature.xml" 
		} elseif {[string match "*����*" $str]}  {set burl "marketing.xml" 
		} elseif {[string match "*���*" $str]}   {set burl "mathematics.xml" 
		} elseif {[string match "*���*" $str]}   {set burl "music.xml" 
		} elseif {[string match "*�����*" $str]} {set burl "polit.xml" 
		} elseif {[string match "*����*" $str]}  {set burl "agrobiologia.xml" 
		} elseif {[string match "*����*" $str]}  {set burl "law.xml" 
		} elseif {[string match "*���*" $str]}   {set burl "psychology.xml" 
		} elseif {[string match "*����*" $str]}  {set burl "geography.xml" 
		} elseif {[string match "*���*" $str]}   {set burl "physics.xml" 
		} elseif {[string match "*���*" $str]}   {set burl "philosophy.xml" 
		} elseif {[string match "*���*" $str]}   {set burl "chemistry.xml" 
		} elseif {[string match "*���*" $str]}   {set burl "estetica.xml" 
		} else {set burl "all.xml?mix=[lindex $brd [expr {round(rand() * [llength $brd])}]]%2C[lindex $brd [expr {round(rand() * [llength $brd])}]]%2C[lindex $brd [expr {round(rand() * [llength $brd])}]]%2C"}

		if {$logrequests ne ""} {set logstr [subst -nocommands $logrequests] ; lput putlog $logstr "$unamespace: "}

		::http::config -useragent "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; 240x320)"		

		if {[queue_add "$furl$burl" $id "[namespace current]::bred:parser" [list $unick $uhost $uchan {}]]} {
			variable err_ok ; if {$err_ok ne ""} {lput puthelp "$err_ok." $prefix}
		} {
			variable err_fail ; if {$err_fail ne ""} {lput puthelp $err_fail $prefix}
		}

	return
	}

#---parser
	proc bred:parser {errid errstr body extra} {
		upvar $errid lerrid $errstr lerrstr $body lbody $extra lextra

		variable err_fail
		variable pubsend
		variable msgsend
		variable errsend
		variable useurl
		variable maxres
		variable stix
		variable brf

		foreach {unick uhost uchan ustr} $lextra {break}
		if {$lerrid ne {ok}} {lput putserv [subst -nocommands $err_fail] [subst -nocommands $errsend] ; return}
		if {$uchan eq $unick} {set prefix [subst -nocommands $msgsend]} {set prefix [subst -nocommands $pubsend]}
#--suzi-patch
		if {[info exists ::sp_version]} {set str [encoding convertfrom cp1251 $lbody]} {set str $lbody}

#----------------------------------------------------------------------------
##---parser-specific------
#----------------------------------------------------------------------------

	if {$brf} {
		regexp -- {<ol>(.*?)</ol>} $str -> res
		regsub -all -- "<li>|\n" $res {} res
		regsub -all -- "</li>" $res {|} res
		lput putserv [sspace "[string trim [lindex [split $res |] [rand [llength [split $res |]]]]] | [string trim [lindex [split $res |] [rand [llength [split $res |]]]]] | [string trim [lindex [split $res |] [rand [llength [split $res |]]]]]"] $prefix
	return
	}

	if {$stix == 1} {
		set dstr [lrange [split $str "\n"] 5 14]
			foreach dout $dstr {lput putserv "$dout" $prefix}
	} elseif {$stix == 2} {
		regsub -all -- "\n" [sspace $str] {} str
		if {[regexp -nocase -- {<tr><td align=center><img src=i.gif height=30 width=1><br>(.*?)</td></tr></table>} $str -> info]} {
			regsub -all -nocase -- "<br>" $info "\n" info
			regsub -all -nocase -- "<.*?>" $info {} info
			regsub -all -nocase -- {&laquo;} $info {"} info
			regsub -all -nocase -- {&raquo;} $info {"} info
			foreach dstr [split $info "\n"] {if {[llength $dstr]} {lput putserv "[string trim $dstr]" $prefix}}
		}
	} elseif {$stix == 3} {
   		if {[regexp -- {<p>(.*?)</p>} $str -> str]} {
			regsub -all -- "<br>" $str "" str
			foreach dstr [split $str "\n"] {lput putserv "[string trim $dstr]" $prefix}
		}
	} else {
		if {[regexp {<h2>(.*?)</h2>} $str -> bname]} {lput putserv "[sconv $bname]" $prefix}
		if {[regexp {<h1 style.*?>(.*?)</h1>} $str -> bhead]} {lput putserv "[sconv $bhead]" $prefix}
		if {[regexp {<p>(.*?)</p>} $str -> btext]} {lput putserv "[sconv [sspace $btext]]" $prefix}
	}

	return
	}		
#----------------------------------------------------------------------------
##---ok------
#----------------------------------------------------------------------------
	proc tolow  {strr} {return [string tolower [string map {� � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �} $strr]]}
	proc sspace {strr} {return [string trim [regsub -all {[\t\s]+} $strr { }]]}

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
	};
	set strr [string map $escapes [join [lrange [split $strr] 0 end]]]; 
    regsub -all -- {\[} $strr "\\\[" strr
    regsub -all -- {\]} $strr "\\\]" strr
    regsub -all -- {\(} $strr "\\\(" strr
    regsub -all -- {\)} $strr "\\\)" strr
  	regsub -all -- {&#([[:digit:]]{1,5});} $strr {[format %c [string trimleft "\1" "0"]]} strr
 	regsub -all -- {&#x([[:xdigit:]]{1,4});} $strr {[format %c [scan "\1" %x]]} strr
 	regsub -all -- {&#?[[:alnum:]]{2,7};} $strr "" strr
	return [subst -novariables $strr]
	}

	proc lput {cmd str {prefix {}} {maxchunk 420}} {
	set buf1 ""; set buf2 [list]
		foreach word [split $str] {append buf1 " " $word ; if {[string length $buf1]-1 >= $maxchunk} {lappend buf2 [string range $buf1 1 end]; set buf1 ""}}
		if {$buf1 != ""} {lappend buf2 [string range $buf1 1 end]}
	foreach line $buf2 {$cmd $prefix$line}
	return
	}

	proc queue_isfreefor {{ id {}}} {

		variable reqqueue
		variable maxreqperuser
		variable maxrequests
		variable laststamp
		variable pause
		variable err_queue_full	
		variable err_queue_id
		variable err_queue_time 

		if {[info exists laststamp(stamp,$id)]} {
			set timewait [expr {$laststamp(stamp,$id) + $pause - [unixtime]}]
			if {$timewait > 0} {return [subst -nocommands $err_queue_time]}			
		}
		if {[llength [array names reqqueue -glob "*,$id"]] >= $maxreqperuser} {return $err_queue_id}
		if {[llength [array names reqqueue]] >= $maxrequests} {return $err_queue_full}		
	return
	}


#---add-to-queue
	proc queue_add {newurl id parser extra {redir 0}} {
		variable reqqueue
		variable proxy
		variable timeout
		variable laststamp

		::http::config -proxyfilter "[namespace current]::queue_proxy"
		
		if {![catch {set token [::http::geturl $newurl -command "[namespace current]::queue_done" -binary true -timeout $timeout]} errid]} {
			set reqqueue($token,$id) [list $parser $extra $redir]		
			set laststamp(stamp,$id) [unixtime]
		} {return false}
	return true
	}

#---proxy
	proc queue_proxy {url} {
		variable proxy
		if {$proxy ne {}} {return [split $proxy {:}]}		
	return [list]
	}
	
#---callback
	proc queue_done {token} {
		upvar #0 $token state
		variable reqqueue
		variable maxredir
		variable fetchurl

		set errid  [::http::status $token]
		set errstr [::http::error  $token]
		set	id [array  names reqqueue "$token,*"]
		foreach {parser extra redir} $reqqueue($id) {break}
		regsub -- "^$token," $id {} id
	
		while (1) {
			if {$errid == "ok" && [::http::ncode $token] == 302} {
				if {$redir < $maxredir} {			
					array set meta $state(meta)
					if {[info exists meta(Location)]} {queue_add "$fetchurl$meta(Location)" $id $parser $extra [incr redir] ; break}
				} {set errid "error" ; set errstr  "Maximum redirects reached"}
			} 
			if {[catch {$parser {errid} {errstr} {state(body)} {extra}} errid]} {lput putlog $errid "[namespace current] "}
		break
		}
			
		array unset reqqueue "$token,*"
		::http::cleanup $token

	return
	}

#---clear
	proc queue_clear_stamps {} {

		variable laststamp
		variable timeout
		variable timerID

		set curr [expr { [unixtime] - 2 * $timeout / 1000 }];
		foreach {id} [array names laststamp] {if {$laststamp($id) < $curr} {array unset laststamp $id}}
		set timerID [timer 10 "[info level 0]"]
	}

#---command aliases & bnd
	proc cmdaliases {{action {bind}}} {
		foreach {bindtype} {pub msg dcc} {
			foreach {bindproc} [info vars "[namespace current]::${bindtype}:*"] {
				variable "${bindtype}prefix"
				variable "${bindtype}flag"			
				foreach {alias} [set $bindproc] {catch {$action $bindtype [set ${bindtype}flag] [set ${bindtype}prefix]$alias $bindproc}}				
			}
		}		
	return
	}

#---init
	if {[info exists timerID]} {catch {killtimer $timerID} ; catch {unset timerID}}	
	[namespace current]::queue_clear_stamps
	[namespace current]::cmdaliases
#---log
  	variable sfil [lindex [split [info script] "/"] end]
  	variable modf [clock format [file mtime [info script]] -format "%d-%b-%Y : %H:%M:%S"]
	if {[info exists ::sp_version]} {putlog "[namespace current] v$version (suzi_$sp_version) :: file:$sfil / rel:\[$date\] / mod:\[$modf\] :: by $author :: loaded."} {putlog "[namespace current] v$version :: file:$sfil / rel:\[$date\] / mod:\[$modf\] :: by $author :: loaded."}
} ;#weird











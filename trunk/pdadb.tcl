#----------------------------------------------------------------------------
# pdadb - ���������� � ���
#----------------------------------------------------------------------------

package require Tcl 	8.4
package require http	2.5

namespace eval pdadb {

#----------------------------------------------------------------------------
# ��������� ��������� ������������ (Suzi / http.tcl)
#----------------------------------------------------------------------------
	# �������� � ������������ �������, ������, ���� ��������� �����������
	variable author			"anaesthesia"
	variable version		"01.02"
	variable date			"27-Nov-2008"

	# ��� ���������� ��� ������� ���������
	variable unamespace		[string range [namespace current] 2 end]

	# ������� ��� ��������� ������ (����� ���� ������ �������)
	variable pubprefix 		{!}
	variable pubflag		{-|-}

	# pubcmd:���_����������� "�������1 �������2 ..."
	# ������� � � ��������� ��������, ������ � ������� �������� ��������� ��������
	variable pub:pdadb		"$unamespace pda ���"

	# ���� ��� � ����, ��� ��������� ������
	variable msgprefix		{!}
	variable msgflag		{-|-}
	# ����� �� ������� ��� ��� ��������� �������
	variable msg:pdadb		${pub:pdadb}

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
	variable pause			15
	
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
	# ���������� ��������� �����������
	variable maxres		25

	# �����, � �������� ���������� ��������� ����������
	variable 		fetchurl		"http://pdadb.net/index.php?m=search"

	# ������� ��������
	variable 		reqqueue
	array unset 	reqqueue

	# ��������� ����������
	variable 		laststamp
	array unset		laststamp 

#---body---

	proc tolow {strr} {return [string tolower [string map {� � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �} $strr]]}
	proc sspace {strr} {return [string trim [regsub -all {[\t\s]+} $strr { }]]}

	proc msg:pdadb {unick uhost handle str} {pub:pdadb $unick $uhost $handle $unick $str ; return}

	proc pub:pdadb {unick uhost handle uchan str} {

		variable requserid ; variable fetchurl ; variable chflag ; variable flagactas
		variable maxres ; variable pubprefix ; variable pubsend ; variable msgsend ; variable errsend ; variable unamespace
		variable mpage ; variable query ; variable logrequests

		set id [subst -noc $requserid]
		set prefix [subst -noc $errsend]

		if {$unick ne $uchan} {if {![channel get $uchan $chflag] ^ $flagactas eq "no"} {return}}
		set why  [queue_isfreefor $id]
		if {$why != ""} {lput puthelp $why $prefix ; return}

#---���������

	if {[regexp -nocase -- {^-(\d+)} $str -> mpg]} {set mpage $mpg ; regsub -- {-\d+\s+} $str "" str} {set mpage 1}
	set ustr [tolow $str]

		if {$ustr == ""} {
			if { $uchan eq $unick} {set prefix [subst -noc $errsend]} {set prefix [subst -noc $pubsend]}
			lput puthelp "\002������\002: !pdadb \[-����� ����������\] <�����>" $prefix		
			lput puthelp "����� ���������� � �������������� ��� ���������� (����� ������ - $maxres �����������). \002������:\002 !pdadb -2 htc tytn" $prefix		
			if {[namespace exist ::price]} { lput puthelp "!price <�����> - ���������� � �����." $prefix }
		return
		}

		if {$logrequests ne ""} {set logstr [subst -noc $logrequests] ; lput putlog $logstr "$unamespace: "}

		set query [::http::formatQuery exp $ustr posted 1 search_scope all search_mode 0 allow_sec_query 1 allow_cmp 0 target 0 excluded "" order_field_offset 3 order_mode DESC Search Search]
		::http::config -useragent "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; 240x320)"	

		if {[queue_add "$fetchurl" $id "[namespace current]::pdadb:parser" [list $unick $uhost $uchan {}]]} {
			variable err_ok ; if {$err_ok ne ""} {lput puthelp "$err_ok." $prefix}
		}  {
			variable err_fail ; if {$err_fail ne ""} {lput puthelp $err_fail $prefix}
		}

	return
	}

#---parser
	proc pdadb:parser {errid errstr body extra} {
		upvar $errid lerrid $errstr lerrstr $body lbody $extra lextra

		variable err_fail
		variable pubsend ; variable msgsend ; variable errsend
		variable useurl ; variable maxres ; variable mpage

		foreach {unick uhost uchan ustr} $lextra {break}

		if {$lerrid ne {ok}} {lput putserv [subst -noc $err_fail] [subst -noc $errsend] ; return}
		if {$uchan eq $unick} {set prefix [subst -noc $msgsend]} {set prefix [subst -noc $pubsend]}
		if {[info exists ::sp_version]} {set dstr [encoding convertfrom cp1251 $lbody]} {set dstr $lbody}

#----------------------------------------------------------------------------
##---parser-specific------
#----------------------------------------------------------------------------

	regexp -nocase -- {</div>\n</form>(.*?)<!-- end of central table -->} $dstr -> str

	if {[string match "*No matching results found*" $str]} {
		lput putserv "\037������ �� �������\037." $prefix
		return
	}

		regsub -all -- "\n|\r" $str {} str
		regsub -all -- "</table>" $str "\n" str

		set count 0
		foreach line [split $str \n] {

			if {[regexp {<h1>(.*?)<div align="justify">(.*?)\|\s<a.*?>} $line -> pname pspec]} {
				regsub -all -- "<.*?>" $pname {} pname
				regsub -all -- "<br>" $pspec { :: } pspec
				regsub -all -- "&quot;" $pspec {"} pspec
				regsub -all -- "<.*?>" $pspec { } pspec

			incr count
				if {$count == $mpage} {set pn $pname ; set ps $pspec ;}
			}
		if {$count > $maxres} {break}
		}
	if {$count != 0 && $count >= $mpage} {
		lput putserv "\($mpage\/$count\) \[$pn\] :: [sspace $ps]" $prefix
	} {
		lput putserv "\037������ �� �������\037." $prefix
	}

	return
	}		
#----------------------------------------------------------------------------
##---ok------
#----------------------------------------------------------------------------

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
		variable reqqueue ; variable proxy ; variable timeout ; variable laststamp ; variable query

		::http::config -proxyfilter "[namespace current]::queue_proxy"
		
		if {![catch {set token [::http::geturl $newurl -command "[namespace current]::queue_done" -binary true -timeout $timeout -query $query]} errid]} {
			set reqqueue($token,$id) [list $parser $extra $redir]		
			set laststamp(stamp,$id) [unixtime]
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
}











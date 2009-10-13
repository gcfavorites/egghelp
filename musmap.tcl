#----------------------------------------------------------------------------
# musmap		-����� ������� ������� ��� ������
# ���������:	.chanset #chan +musmap
# ������:		!musmap <name>
#				!movmap	<name>
# ������:		!musicmap !moviemap
# �������:		anaesthesia #eggdrop@Rusnet
# �������:		http://egghelp.ru
#----------------------------------------------------------------------------

package require Tcl 	8.5
package require http	2.5

namespace eval musmap {

#----------------------------------------------------------------------------
# ��������� ��������� ������������ (Suzi / http.tcl)
#----------------------------------------------------------------------------
	# �������� � ������������ �������, ������, ���� ��������� �����������
	variable author			"anaesthesia"
	variable version		"01.02"
	variable date			"29-Dec-2007"

	# ��� ���������� ��� ������� ���������
	variable unamespace		[namespace tail [namespace current]]

	# ������� ��� ��������� ������ (����� ���� ������ �������)
	variable pubprefix 		{!}
	variable pubflag		{-|-}

	# ������� ������
	variable musbnd 		{musmap musicmap}
	variable movbnd			{movmap moviemap}

	# pubcmd:���_����������� "�������1 �������2 ..."
	# ������� � � ��������� ��������, ������ � ������� �������� ��������� ��������
	variable pub:musmap		"$musbnd $movbnd"

	# ���� ��� � ����, ��� ��������� ������
	variable msgprefix		$pubprefix
	variable msgflag		{-|-}
	# ����� �� ������� ��� ��� ��������� �������
	variable msg:musmap		${pub:musmap}

	# ����� ��������� ��������� ��� ��������� �������, ������ � �������� ������� ������ ������
	# ��� ��������������� ����������  variable [pub|msg]:handler "string ..."

	# ����� �������������� ������������ ��� ���������� ��������
	# �������� $unick, $uhost, $uchan
	# ������� tcl ���������, ����������� ������������ ���������� id ���
	# ������������� �������.
	variable requserid		{$uhost}
	
	# ������������ ����� ��������� ���������� �������� ��� ������ id
	variable maxreqperuser	1

	# ������������ ����� ��������� ���������� ��������
	variable maxrequests	5

	# ����� ����� ���������, � ������� ������� ������ ���������� ��� �������������, ������ 
	variable pause			30
	
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
	variable maxredir		2
	
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
	# �������� ���������� $timewait -- ���������� �����, �� ��������� �������� ������ ����� ��������
	variable err_queue_time {���������� ��������� ������� �����. ������ ����� �������� ��� ������������� ����� $timewait ���.}
	
#----------------------------------------------------------------------------
#  ���������� ���������� � ���
#----------------------------------------------------------------------------
	# �����, � �������� ���������� ��������� ����������
	variable 		furlmus		"http://www.music-map.com"
	variable		furlmov		"http://www.movie-map.com"

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

	proc tolow {strr} {return [string tolower [string map {� � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �} $strr]]}
	proc sspace {strr} {return [string trim [regsub -all {[\t\s]+} $strr { }]]}
	proc chkrusl {symb} {if {[lsearch -exact {� � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �} $symb] > -1} {return 1} {return 0}}

	proc chkrus {strr} {
  		set len [string length $strr]
  		set cnt 0 ; while {$cnt < $len} {if {[chkrusl [string index $strr $cnt]]} {return 1} ; incr cnt}
  	return 0
	}

	proc msg:musmap {unick uhost handle str} {
		pub:musmap $unick $uhost $handle $unick $str
		return
	}

	proc pub:musmap {unick uhost handle uchan str} {
		variable requserid ; variable chflag ; variable flagactas ; variable errsend
		variable maxres ; variable pubprefix ; variable pubsend ; variable msgsend ; variable unamespace ; variable logrequests
		variable musbnd ; variable movbnd ; variable fetchurl ; variable furlmov ; variable furlmus

		set id 	 [subst -noc $requserid]
		set prefix [subst -noc $errsend]
		if {$unick ne $uchan} {if {![channel get $uchan $chflag] ^ $flagactas eq "no"} {return}}
		set why [queue_isfreefor $id]
		if {$why != ""} {lput puthelp $why $prefix ; return}

#---���������
	set ustr [string map { " " "+" } [tolow $str]]

		if {$ustr == "" || [chkrus $ustr]} {
			if {$uchan eq $unick} {set prefix [subst -noc $msgsend]} {set prefix [subst -noc $pubsend]}
		lput puthelp "\002������\002: \002${pubprefix}[lindex $musbnd 0]\002 <name> ��� \002${pubprefix}[lindex $movbnd 0]\002 <name> \(��� ������ \037���������\037\)" $prefix		
		lput puthelp "����� ������� ����������� ����� ��� �������. \002������:\002 ${pubprefix}[lindex $musbnd 0] nine inch nails" $prefix		
		return
		}
		if {[string trimleft $::lastbind $pubprefix] in $musbnd} {set fetchurl $furlmus} {set fetchurl $furlmov}

		if {$logrequests ne ""} {set logstr [subst -noc $logrequests] ; lput putlog $logstr "$unamespace: "}
		::http::config -useragent "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; 240x320)"	

		if {[queue_add "${fetchurl}/map-search.php?f=${ustr}" $id "[namespace current]::musmap:parser" [list $unick $uhost $uchan {}]]} {
			variable err_ok ; if {$err_ok ne ""} {lput puthelp "$err_ok." $prefix}
		} {
			variable err_fail ; if {$err_fail ne ""} {lput puthelp $err_fail $prefix}
		}

	return
	}

#---parser
	proc musmap:parser {errid errstr body extra} {
		upvar $errid lerrid $errstr lerrstr $body lbody $extra lextra
		variable err_fail ; variable pubsend ; variable msgsend ; variable errsend ; variable useurl ; variable maxres

		foreach {unick uhost uchan ustr} $lextra {break}
		if {$lerrid ne {ok}} {lput putserv [subst -noc $err_fail] [subst -noc $errsend] ; return}
		if {$uchan eq $unick} {set prefix [subst -noc $msgsend]} {set prefix [subst -noc $pubsend]}
#--suzi-patch
	if {[info exists ::sp_version]} {set str $lbody} {set str $lbody}

#----------------------------------------------------------------------------
##---parser-specific------
#----------------------------------------------------------------------------
		regsub -all -- "\n|\r" $str {} str

	if {[regexp {gnodMapSettings.*?</script>(.*?)<script>} $str -> res]} {
		regsub -all -- "<a href.*?>" $res " \002*\002 " res
		regsub -all -- "<.*?>" $res {} res
		lput putserv "[sspace $res]" $prefix
	} {
		lput putserv "MusicMap: \037������ �� �������\037." $prefix
		return
	}

	return
	}		
#----------------------------------------------------------------------------
##---ok------
#----------------------------------------------------------------------------

	proc lput {cmd str {prefix {}} {maxchunk 420}} {
	set buf1 "" ; set buf2 [list]
		foreach word [split $str] {append buf1 " " $word ; if {[string length $buf1]-1 >= $maxchunk} {lappend buf2 [string range $buf1 1 end] ; set buf1 ""}}
		if {$buf1 != ""} {lappend buf2 [string range $buf1 1 end]}
		foreach line $buf2 {$cmd $prefix$line}
	return
	}

#---queue
	proc queue_isfreefor {{id {}}} {

		variable reqqueue ; variable maxreqperuser ; variable maxrequests ; variable laststamp ; variable pause
		variable err_queue_full	; variable err_queue_id ; variable err_queue_time 

		if {[info exists laststamp(stamp,$id)]} {
			set timewait [expr {$laststamp(stamp,$id) + $pause - [unixtime]}]
			if {$timewait > 0} {return [subst -noc $err_queue_time]}			
		}
		if {[llength [array names reqqueue -glob "*,$id"]] >= $maxreqperuser} {return $err_queue_id}
		if {[llength [array names reqqueue]] >= $maxrequests} {return $err_queue_full}
		
	return
	}

#---add-to-queue
	proc queue_add {newurl id parser extra {redir 0}} {
		variable reqqueue ; variable proxy ; variable timeout ; variable laststamp

		::http::config -proxyfilter "[namespace current]::queue_proxy"
		
		if {![catch {
			set token [::http::geturl $newurl -command "[namespace current]::queue_done" -binary true -timeout $timeout]} errid]} {
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
		variable reqqueue ; variable maxredir 
		
		set errid  	[::http::status $token]
		set errstr 	[::http::error  $token]
		set	id  	[array  names reqqueue "$token,*"]
		foreach {parser extra redir} $reqqueue($id) {break}
		regsub -- "^$token," $id {} id
	
		while (1) {
			if {$errid == "ok" && [::http::ncode $token] == 302} {
				if {$redir < $maxredir} {			
					array set meta $state(meta)
					if {[info exists meta(Location)]} {variable fetchurl ; queue_add "$fetchurl$meta(Location)" $id $parser $extra [incr redir] ; break}
				} {set errid   "error" ; set errstr  "Maximum redirects reached"}
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
		variable laststamp ; variable timeout ; variable timerID

		set curr [expr { [unixtime] - 2 * $timeout / 1000 }]
		foreach {id} [array names laststamp] {if {$laststamp($id) < $curr} {array unset laststamp $id}}		
		set timerID [timer 10 "[info level 0]"]
	}

#---command aliases & bnd
	proc cmdaliases {{action {bind}}} {
		foreach {bindtype} {pub msg dcc} {
			foreach {bindproc} [info vars "[namespace current]::${bindtype}:*"] {
				variable "${bindtype}prefix"
				variable "${bindtype}flag"			
				foreach {alias} [set $bindproc] {
					catch {$action $bindtype [set ${bindtype}flag] [set ${bindtype}prefix]$alias $bindproc}
				}				
			}
		}
		
	return
	}
#---killtimers	
	if {[info exists timerID]} {catch {killtimer $timerID} ; catch {unset timerID}}
#---rest	
	[namespace current]::queue_clear_stamps
	[namespace current]::cmdaliases
  	variable sfil [lindex [split [info script] "/"] end]
  	variable modf [clock format [file mtime [info script]] -format "%d-%b-%Y : %H:%M:%S"]
	if {[info exists ::sp_version]} {putlog "[namespace current] v$version (suzi_$sp_version) :: file:$sfil / rel:\[$date\] / mod:\[$modf\] :: by $author :: loaded."} {putlog "[namespace current] v$version :: file:$sfil / rel:\[$date\] / mod:\[$modf\] :: by $author :: loaded."}

}











# �������� - ��������� ��������������� �������
# v.1.5 - �������� ����� ���� � ����� ���� ����������
# ��������� �������: 			.chanset #chan +horoscope
# ����� ����� (����� � ������):	.chanset #chan +horoscopeq

package require Tcl 	8.4
package require http	2.5

namespace eval horoscope {

# ---------------------------------------------------------------------------
# ��������� ������������
# ---------------------------------------------------------------------------

	variable author			"Suzi /mod anaesthesia"
	variable version		"01.5"
	variable date			"18-may-2008"

	# ��� ���������� ��� ������� ���������
	variable unamespace		[namespace tail [namespace current]]

	# ������� ��� ��������� ������ (����� ���� ������ �������)
	variable pubprefix 		{!}

	# pubcmd:���_����������� "�����1 �����2 ..."
	# ������� � � ��������� ������, ������ � ������� ������ ��������� ��������
	variable pub:horoscope	"$unamespace �������� horo ����"

	# ���� ��� � ����, ��� ��������� ������
	variable msgprefix		{!}
	# ����� �� ������� ��� ��� ��������� �������, �� ��������� ������� �������� ��� ��������
	# (������� -- ������ ������)
	variable msg:horoscope	${pub:horoscope}

	# ����� ��������� ��������� ��� ��������� �������, ������ � �������� ������� ������ ������
	# ��� ��������������� ����������  variable [pub|msg]:handler "string ..."

	# ����� �������������� ������������ ��� ���������� ��������
	# ��������� $unick, $uhost, $uchan
	# ������� tcl ���������, ����������� ������������ ���������� id ���
	# ������������� �������.
	variable requserid		{$unick}
	
	# ������������ ����� ��������� ���������� �������� ��� ������ id
	variable maxreqperuser	1

	# ������������ ����� ��������� ���������� ��������
	variable maxrequests	10

	# ����� ����� ���������, � ������� ������� ������ ���������� ��� �������������, 
	# ������ 
	variable pause			15
	
	# ����� ������-�������
	# ������ ���� "proxyhost.dom:proxyport" ��� ������ ������, ���� ������-������
	# �� ������������
	variable proxy 			{}

	# ��������� ���������� �����, ���� �������� "" -- ����� �����������
	# ��������, �� ���� ���� ���� ���� ���������� �� ������ -- ������ ��������
	# ���� "no" �������� ���� ���������� ��������� ��� ���� ����� �����������
	# �������� � ������ ���������� �� ������ ��������� ������ �������
	# (��� ���� ������ �������� �� ���� �������, ��� �� ����������� ���� ����)
	variable flagactas		""
	
	# ��� ���������� �����, ��������� ��� ���������/���������� ������� �� ������
	# �� ��������� ����������� �� ������ ������ ����� � ����� ����������

	variable chflag			"$flagactas$unamespace"

	setudef  flag 			$chflag
	setudef	 flag			$chflag\q
# ---------------------------------------------------------------------------
# ����� ���������� ��������� ������������
# ---------------------------------------------------------------------------
	# ����� ��� �������� -- ������ ������ ��� �� ������
	# ����� ��������������� ����� � ���
	variable logrequests	{'$unick', '$uhost', '$handle', '$uchan', '$ustr'}
	
	# ������� ������ ��� ���������� �������, �� ��������� -- �����
	# �������� $uchan & $unick
	variable pubsend		{PRIVMSG $uchan :}

	# ������� ������ ��� ���������� �������, �� ��������� --��������� ���������
	# �������� ������ $unick ($uchan == $unick)
	variable msgsend		{PRIVMSG $unick :}
	
	# ������� ������ ��� ������/������������� �������
	# �������� $unick
	variable errsend		{NOTICE $unick :$unick, }

	# ������������ ����� ���������� � ����������� ��������
	variable maxredir		1
	
	# ������� ������� � �������������, �� ���� 20 ������
	variable timeout		30000

	# ��������� � �������� �������
	variable err_ok			{}

	# ��������� � ������������� �������� ������, ������� � ������� �� ��������
	# ������ ���������� � ������������� �� �������� 
	variable err_fail		{� ��������� ��� ������ �� ��������. ��������� ������. �������� �� ������� ��������� � ��������-��������.}

	# ��������� � ������������� ������� ��������
	variable err_queue_full	{� ������ ����� ������� ������� ��������� � �� ����� ��������� ��� ������. ��������� ������� �����.}
	
	# ��������� � ������������� ������� ��� ����������� id
	variable err_queue_id	{���������� ��������� ��������� ���������� ��������.}
	
	# ��������� � ��� ��� ����� ����� ��������������� ������� �� �������
	# �������� ���������� $timewait -- ���������� �����, �� ��������� ��������
	# ������ ����� ��������
	variable err_queue_time {���������� ��������� ������� �����. ������ ����� �������� ��� ������������� ����� $timewait ���.}
	
# ---------------------------------------------------------------------------
# ������ �����������, ���������� ���������� � ���
# ---------------------------------------------------------------------------
	# �����, � �������� ���������� ��������� ����������
	variable 		fetchurl		"http://horo.ru/lov"
	variable		fetchurlp		"http://horo.ukr.net/horoscope/astro"

	variable 		reqqueue
	array unset 	reqqueue
	variable 		laststamp
	array unset		laststamp 

	proc tolow {strr} {
    	return [string tolower [string map {� � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �} $strr]]
	}

	proc sspace {strr} {
  		return [string trim [regsub -all {[\t\s]+} $strr { }]]
	}

	proc msg:horoscope { unick uhost handle str } {
		pub:horoscope $unick $uhost $handle $unick $str
		return
	}

	proc pub:horoscope { unick uhost handle uchan str } {

		variable requserid
		variable fetchurl
		variable fetchurlp
		variable chflag
		variable flagactas
		variable errsend
		variable pubsend
		variable msgsend
		variable htype

		set id 	 [regsub -all -- {[][${}\\]} [subst -nocommands $requserid] {}]

		if { $uchan eq $unick || [channel get $uchan $chflag\q]} {
			set prefix [subst -nocommands $msgsend]
		} else {
			set prefix [subst -nocommands $pubsend]
		}

		if { $unick ne $uchan } {
			if { ![channel get $uchan $chflag] ^ $flagactas eq "no" } {
				return
			}
		}

		set why  [queue_isfreefor $id]
		
		if { $why != "" } {
			lput puthelp $why $prefix
			return
		}

		array set daysyn { 
			������		{tom}
			tomorrow 	{tom}
			�������		{tod}
			today		{tod}
			�����		{yes}
			yesterday	{yes}
		}

		array set daysynp {
			������		{tomorrow}
			�������		{today}
			�����		{yesterday}
			������		{week}
			�����		{month}
			���			{year}
		}

		array set hvid {
			�����		flirt
			��������	family
			���������	career
			��������	health
			���������	teen
			������		amigos
			��������	love
		}

		array set lovesyn {
			��������    1
			love        1
			���         1
		}

		array set signsyn {
			����		aries
			aries		aries
			�����		taurus
			taurus		taurus
			��������    gemini
			gemini		gemini
			���			cancer
			cancer		cancer
			���			leo
			leo			leo
			����		virgo
			virgo		virgo
			����		libra
			libra		libra
			��������	scorpio
			scorpio		scorpio
			�������		sagittarius
			sagittarius	sagittarius
			�������		capricorn
			capricorn	capricorn
			�������		aquarius
			aquarius	aquarius
			����		pisces
			pisces		pisces
		}

	if {[regexp -- {\+} $str]} {
		regsub -- {\+} $str {} str
		set ustr [string trim [tolow $str]]
		set wtype		{more}
		set wday        {today}
		set wlove 		{0}
		set wsign		{}
		set valid		{1}
		set htype		{0}

		foreach { wrd } [split $ustr] {

			if { [string length $wrd] >= 3 } {
				set wrd [string tolower "$wrd*"];
				set lvals [array names signsyn -glob $wrd];
				if { [llength $lvals] == 1 } {
					set wsign $signsyn($lvals)
					continue
				}

				set lvals [array names daysynp -glob $wrd];
				if { [llength $lvals] == 1 } {
					set wday $daysynp($lvals)
					set wdayname $wrd
					continue
				} else { set wdayname "�������" }

				set lvals [array names hvid -glob $wrd];
				if { [llength $lvals] == 1 } {
					set wtype $hvid($lvals)
					continue
				}
			}

			set valid {0}
			break;
		}

	} else {
		set ustr [string trim [tolow $str]]

		set wlove 		{0}
		set wday        {tod}
		set wsign		{}
		set valid		{1}
		set htype		{1}

		foreach { wrd } [split $ustr] {

			if { [string length $wrd] >= 3 } {
				set wrd [string tolower "$wrd*"];
				set lvals [array names signsyn -glob $wrd];
				if { [llength $lvals] == 1 } {
					set wsign $signsyn($lvals)
					continue
				}

				set lvals [array names daysyn -glob $wrd];
				if { [llength $lvals] == 1 } {
					set wday $daysyn($lvals)
					set wdayname $wrd
					continue
				} else { set wdayname "�������" }

				set lvals [array names lovesyn -glob $wrd];
				if { [llength $lvals] == 1 } {
					set wlove $lovesyn($lvals)
					continue
				}
			}
			
			set valid {0}
			break;
		}
	} ;#type

		if { !$valid || $wsign eq "" } {
			lput putserv "\037������ ��������\037: \002!�������� +\002 \[�����|��������|���������|��������|���������|������|��������\] <����|�����|��������|���|���|����|����|��������|�������|�������|�������|����> \[������|�����|������|�����|���\]" $prefix
			lput putserv "\002������\002: !�������� + ������� ����� ������" $prefix
			lput putserv "\037������� ��������\037: \002!��������\002 \[��������\] <����|�����|��������|���|���|����|����|��������|�������|�������|�������|����> \[������|�������|�����\]" $prefix
			lput putserv "\002������\002: !�������� ���� ��� !�������� �������� ���� ������" $prefix
			return;
		}

		if { $wday eq {yes} } { set wdayname {�����} }
		if { $wday eq {tod} || $wday eq {today} } { set wdayname {�������} }
		if { $wday eq {tom} } { set wdayname {������} }

	if {$htype == 1} {
		set furl "$fetchurl/$wday/$wsign.html"
	} else {
		if {$wday eq ""} {set wday "today"}
		if {$wtype eq "" && ($wday eq "today" || $wday eq "tomorrow" || $wday eq "yesterday")} {set wtype "more"} 
		if {$wtype eq "" && ($wday eq "week" || $wday eq "month" || $wday eq "year")} {set wtype "general"} 
		set furl "$fetchurlp/$wtype/$wday/$wsign.html"
	}
		variable logrequests

		if { $logrequests ne "" } {
			set logstr [subst -nocommands $logrequests]
			variable unamespace
			lput putlog $logstr "$unamespace: $furl : "
		}

		if { [queue_add "$furl" $id "[namespace current]::horoscope:parser" [list $unick $uhost $wdayname $uchan $wlove]] } {
			variable err_ok
			if { $err_ok ne "" } {
				lput puthelp $err_ok $prefix
			}
		} else {
			variable err_fail
			if { $err_fail ne "" } {
				lput puthelp $err_fail $prefix
			}
		}

		return
	}

	proc horoscope:parser { errid errstr body extra } {
		upvar $errid lerrid $errstr lerrstr $body lbody $extra lextra

		variable err_fail
		variable chflag
		variable pubsend
		variable msgsend
		variable errsend
		variable htype

		foreach { unick uhost uhandle uchan ustr } $lextra { break }

		if { $lerrid ne {ok} } {
			lput putserv [subst -nocommands $err_fail] [subst -nocommands $errsend]
			return
		}

	global sp_version
	if {[info exists sp_version]} {	
		set str [encoding convertfrom cp1251 $lbody] 
		} else {
		set str $lbody
		}

		if { $uchan eq $unick || [channel get $uchan $chflag\q]} {
			set prefix [subst -nocommands $msgsend]
		} else {
			set prefix [subst -nocommands $pubsend]
		}

	if {$htype == 1} {

		if { [regexp -nocase -- {<h2>(.+?)</h2>.*?<!--text begin-->(.+?)<!--text end-->.*?<h2>(.+?)</h2>.*?<!--r.daily.tom._file_.text-->(.+?)</div>} $str -> lovesign lovehoro gensign genhoro] } {
			
			if { $ustr eq "1" } {
				lput putserv "\00305$lovesign\003 \002::\002 [sspace $lovehoro]" $prefix
			} else {
				lput putserv "\00305$gensign\003  \002::\002 [sspace $genhoro]" $prefix
			}
		} else {
			lput putserv "\037������ ��������\037." [subst -nocommands $errsend]
		}

	} else {

	set data $str
		regsub -all -- \n $data {} data
		regsub -all -- {>\ +<} $data {><} data
		regsub -all -- {^\ +} $data "" data
		regsub -all -- {\ +} $data { } data
		regsub -all -- {</([^<]+)> +<} $data {</\1><} data
		regsub -all -- {<br />} $data "" data
   			foreach item [split $data \n] {
   				if { [regexp -- {<div\ class=.*?\ id=.*?><h2\ class=.*?\ id=\"inl\">(.*?)</h2><h2 class=\"inl\">(.*?)</h2><h3 class=\"cat\" id=.*?>(.*?)</h3>} $item g chislo horolove2 horoobsh]} {
   					lput putserv "\00310 [sspace $chislo] $horolove2 \003:: \00303 ������: $horoobsh\003" $prefix
				}
   				if { [regexp -- {<h4>(.*?)<span class=.*?>(.*?)</span></h4></div><p>(.*?)</p>} $item g q w e]} {
   					lput putserv "\00303 $q $w\003 :: $e" $prefix
					return
   				}
			lput putserv "\037������ ��������\037." [subst -nocommands $errsend]
			}
	}	
	return
}
# ---------------------------------------------------------------------------
	proc lput { cmd str { prefix {} } {maxchunk 420} } {

	set buf1 ""; set buf2 [list];

		foreach word [split $str] {
		append buf1 " " $word;
			if {[string length $buf1]-1 >= $maxchunk} {
			lappend buf2 [string range $buf1 1 end];
			set buf1 "";
			}
		}
		if {$buf1 != ""} {
		lappend buf2 [string range $buf1 1 end];
		}
	foreach line $buf2 {		
		$cmd $prefix$line 
	}
		return
	}

	proc queue_isfreefor { { id {} } } {

		variable reqqueue
		variable maxreqperuser
		variable maxrequests
		variable laststamp
		variable pause

		variable err_queue_full	
		variable err_queue_id
		variable err_queue_time 

		if { [info exists laststamp(stamp,$id)] } {
			set timewait [expr { $laststamp(stamp,$id) + $pause - [unixtime]}]

			if { $timewait > 0 } {
				return [subst -nocommands $err_queue_time]
			}			
		}

		if { [llength [array names reqqueue -glob "*,$id"]] >= $maxreqperuser } {
			return $err_queue_id
		}

		if { [llength [array names reqqueue]] >= $maxrequests } { 
			return $err_queue_full
		}
		
		return
	}

	proc queue_add { newurl id parser extra {redir 0} } {
		variable reqqueue
		variable proxy
		variable timeout
		variable laststamp

		::http::config -proxyfilter "[namespace current]::queue_proxy"

		if { ![catch {
			set token [::http::geturl $newurl -command "[namespace current]::queue_done" -binary true -timeout $timeout]
			} errid] } {
					
			set reqqueue($token,$id) [list $parser $extra $redir]		
			set laststamp(stamp,$id) [unixtime]

		} else {
			return false
		}

		return true
	}

	proc queue_proxy { url } {
		variable proxy
		if { $proxy ne {} } { return [split $proxy {:}] }		
		return [list]
	}
	
	proc queue_done { token } {
		upvar #0 $token state
		variable reqqueue
		variable maxredir
		
		set errid  		[::http::status $token]
		set errstr 		[::http::error  $token]
		
		set	id  	[array  names reqqueue "$token,*"]
		foreach { parser extra redir } $reqqueue($id) { break }
		regsub -- "^$token," $id {} id
	
		while (1) {
			if { $errid == "ok" && [::http::ncode $token] == 302 } {
				if { $redir < $maxredir } {			
					array set meta $state(meta)
					if { [info exists meta(Location)] } {
						variable fetchurl
						queue_add "$fetchurl$meta(Location)" $id $parser $extra [incr redir]
						break
					}
				} else {
					set errid   "error"
					set errstr  "Maximum redirects reached"
				}
			} 
			
			if { [catch { $parser {errid} {errstr} {state(body)} {extra} } errid ] } {
				lput putlog $errid "[namespace current] "
			}

			break
		}
			
		array unset reqqueue "$token,*"
		::http::cleanup $token

		return
	}

	proc queue_clear_stamps {} {

		variable laststamp
		variable timeout
		variable timerID

		set curr [expr { [unixtime] - 2 * $timeout / 1000 }];
		foreach { id } [array names laststamp] {
			if { $laststamp($id) < $curr } {
				array unset laststamp $id;
			}
		}		

		set timerID [timer 10 "[info level 0]"]
	}

	proc cmdaliases { { action {bind} } } {
		foreach { bindtype } {pub msg dcc} {
			foreach { bindproc } [info vars "[namespace current]::${bindtype}:*"] {
				variable "${bindtype}prefix"
				foreach { alias } [set $bindproc] {
					catch { $action $bindtype -|- [set ${bindtype}prefix]$alias $bindproc }
				}				
			}
		}
		
		return
	}
	
	if {[info exists timerID]} {
		catch {killtimer $timerID}; 
		catch {unset timerID}
	}
	
	[namespace current]::queue_clear_stamps
	cmdaliases
	global sp_version
	if {[info exists sp_version]} {
	putlog "[namespace current] v$version suzi_$sp_version \[$date\] by $author loaded."
	} else {
	putlog "[namespace current] v$version \[$date\] by $author loaded."
	}}

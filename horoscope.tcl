#######################################################################################
# Suzi Project script
# ��� ������� �� ������ �������� ��� ��������� �� �� ��������� �� ������ ��������� ��:
# �����: suzi@ircworld.ru
# �����: http://xirc.ru/plugins/forum/forum_viewforum.php?15
# -
# ����� �������: http://www.IRCWorld.ru & http://www.xIRC.ru
#######################################################################################

package require Tcl 	8.4
package require http	2.5

namespace eval horoscope {

# ---------------------------------------------------------------------------
# ��������� ������������
# ---------------------------------------------------------------------------
	# �������� � ������������ �������, ������, ���� ��������� �����������

	variable author			"Suzi <Suzi@ircworld.ru>"
	variable version		"01.03"
	variable date			"24-MAY-2006"

	# ��� ���������� ��� ������� ���������
	variable unamespace		[string range [namespace current] 2 end]

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
	variable requserid		{$uhost}
	
	# ������������ ����� ��������� ���������� �������� ��� ������ id
	variable maxreqperuser	1

	# ������������ ����� ��������� ���������� ��������
	variable maxrequests	10

	# ����� ����� ���������, � ������� ������� ������ ���������� ��� �������������, 
	# ������ 
	variable pause			30
	
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
	variable 		fetchurl		"http://www.horo.ru"

	# ������� ��������
	variable 		reqqueue
	array unset 	reqqueue

	# ��������� ����������
	variable 		laststamp
	array unset		laststamp 

#
	proc msg:horoscope { unick uhost handle str } {
		pub:horoscope $unick $uhost $handle $unick $str
		return
	}

	proc pub:horoscope { unick uhost handle uchan str } {
#		putlog "horo"
		variable requserid
		variable fetchurl
		variable chflag
		variable flagactas
		variable errsend
		
		set id 	 [subst -nocommands $requserid]
		set prefix [subst -nocommands $errsend]

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

		set ustr $str

		array set daysyn { 
			������		{tom}
			tomorrow 	{tom}
			�������		{tod}
			today		{tod}
			�����		{yes}
			yesterday	{yes}
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

		set wlove 		{0}

		set wday        {tod}

		set wsign		{}

		set valid		{1}
		
		foreach { wrd } [lrange [split $str] 0 2] {


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
				}

				set lvals [array names lovesyn -glob $wrd];
				if { [llength $lvals] == 1 } {
					set wlove $lovesyn($lvals)
					continue
				}
			}
			
			set valid {0}
			break;
		}

		if { !$valid || $wsign eq "" } {
			
			lput puthelp {��������� ������. �����������: '+�������� [��������] [������|�������|�����] ����'. ��������: '+�������� ����' ��� '+�������� ������ ����'} $prefix
			return;
		}


		variable logrequests

		if { $logrequests ne "" } {
			set logstr [subst -nocommands $logrequests]
			variable unamespace
			lput putlog $logstr "$unamespace: "
		}

#		putlog "$fetchurl/lov/$wday/$wsign.html"

		if { $wday eq {yes} } { set wdayname {�����} }
		if { $wday eq {tod} } { set wdayname {�������} }
		if { $wday eq {tom} } { set wdayname {������} }

		if { [queue_add "$fetchurl/lov/$wday/$wsign.html" $id "[namespace current]::horoscope:parser" [list $unick $uhost $wdayname $uchan $wlove]] } {
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

		variable pubsend
		variable msgsend
		variable errsend

		foreach { unick uhost uhandle uchan ustr } $lextra { break }

		if { $lerrid ne {ok} } {
#			lput putlog $lerrid $lerrstr
			lput putserv [subst -nocommands $err_fail] [subst -nocommands $errsend]
			return
		}

		set str [encoding convertfrom cp1251 $lbody]

		if { [regexp -nocase -- {\<h2\>(.+?)\</h2\>.*?\<p\>(.+?)\</p\>.*?\<h2\>(.+?)\</h2\>.*?\<p\>(.+?)\</p\>} $str -> lovesign lovehoro gensign genhoro] } {
			
			if { $uchan eq $unick } {
				set prefix [subst -nocommands $msgsend]
			} else {
				set prefix [subst -nocommands $pubsend]
			}
			
			set lovesign [string range $lovesign 0 40]
			set gensign [string range $gensign 0 40]
		
			set lovehoro [string range $lovehoro 0 2000]
			set genhoro [string range $genhoro 0 2000]


			if { $ustr eq "1" } {
				lput putserv "\00305$lovesign ($uhandle). \00302$lovehoro" $prefix
			} else {
				lput putserv "\00305$gensign ($uhandle). \00302$genhoro" $prefix
			}

		} else {
			lput putserv [subst -nocommands $err_fail] [subst -nocommands $errsend]
		}
		
		return
	}

# ---------------------------------------------------------------------------
#
# ---------------------------------------------------------------------------

	proc lput { cmd str { prefix {} } {maxchunk 400} } {
		set plen 	[string length $prefix]
		set	slen    [string length $str]
		set sidx	0

		while { $slen != 0 } {
			set nsl [expr { [expr { $slen + $plen }] < $maxchunk ? $slen : [ expr { $maxchunk - $plen } ] } ]

			$cmd $prefix[string range $str $sidx [expr { $sidx + $nsl - 1} ] ]
		
			incr slen -$nsl
			incr sidx  $nsl
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
		
		if { ! [catch {
			set token [::http::geturl $newurl -command "[namespace current]::queue_done" -binary true -timeout $timeout]
			} errid] } {
					
			set reqqueue($token,$id) [list $parser $extra $redir]		
#			lput putlog "$token,$id"
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

#		lput putlog "$token"
		
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

		set curr [expr { [unixtime] - 2 * $timeout / 1000 }];
#		putlog "stamps: $curr"		

		foreach { id } [array names laststamp] {
			if { $laststamp($id) < $curr } {
				array unset laststamp $id;
			}
		}		

#		putlog "stamps: [array get laststamp]"

		timer 10 "[info level 0]"
	}

	proc cmdaliases { { action {bind} } } {
		foreach { bindtype } {pub msg dcc} {
			foreach { bindproc } [info vars "[namespace current]::${bindtype}:*"] {
				variable "${bindtype}prefix"
				foreach { alias } [set $bindproc] {
#					putlog "$action $bindtype -|- [set ${bindtype}prefix]$alias $bindproc"
					catch { $action $bindtype -|- [set ${bindtype}prefix]$alias $bindproc }
				}				
			}
		}
		
		return
	}
	
	[namespace current]::queue_clear_stamps
	cmdaliases

	putlog "[namespace current] v$version \[$date\] by $author loaded."
}

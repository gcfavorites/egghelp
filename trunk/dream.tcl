# ��� ��������� ������� �� ������ ���������� � ��������� ���� ��������� �������:
#   .chanset #����� +dream
# ������� �������:
#   !dream, !������
#######################################################################################

package require Tcl 	8.4
package require http	2.5

namespace eval dream {

# ---------------------------------------------------------------------------
# ��������� ������������
# ---------------------------------------------------------------------------
	# �������� � ������������ �������, ������, ���� ��������� �����������

	variable author			"Suzi /mod anaesthesia"
	variable version		"01.05"
	variable date			"21-may-2008"

	# ��� ���������� ��� ������� ���������
	variable unamespace		[namespace tail [namespace current]]

	# ������� ��� ��������� ������ (����� ���� ������ �������)
	variable pubprefix 		{!}

	# pubcmd:���_����������� "�����1 �����2 ..."
	# ������� � � ��������� ������, ������ � ������� ������ ��������� ��������
	# � ������ ������ ����� �������� ��������� ������� "+dream" � "+������"
	variable pub:dream		"$unamespace ������"

	# ���� ��� � ����, ��� ��������� ������
	variable msgprefix		{!}
	# ����� �� ������� ��� ��� ��������� �������, �� ��������� ������� �������� ��� ��������
	# (������� -- ������ ������)
	variable msg:dream		${pub:dream}

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
	# � ������ ������ ����� ������ ����������� � ��� ����� -- "nodream"
	# ��� ��������� �� ������ ��������� ������

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
	variable pubsend		{PRIVMSG $unick :}

	# ������� ������ ��� ���������� �������, �� ��������� --��������� ���������
	# �������� ������ $unick ($uchan == $unick)
	variable msgsend		{PRIVMSG $unick :}
	
	# ������� ������ ��� ������/������������� �������
	# �������� $unick
	variable errsend		{NOTICE $unick :$unick, }

	# ������������ ����� ���������� � ����������� ��������
	variable maxredir		1
	
	# ������� ������� � �������������, �� ���� 20 ������
	variable timeout		60000

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
	variable 		fetchurl		"http://www.sonnik.ru"

	# ������� ��������
	variable 		reqqueue
	array unset 	reqqueue

	# ��������� ����������
	variable 		laststamp
	array unset		laststamp 

	proc msg:dream { unick uhost handle str } {
		pub:dream $unick $uhost $handle $unick $str
		return
	}

	proc pub:dream { unick uhost handle uchan str } {

		variable requserid
		variable fetchurl
		variable chflag
		variable flagactas
		variable errsend
		variable msgprefix
		
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
		if { $ustr eq "" } {
			lput puthelp "��������� ������. �����������: '${msgprefix}������ �����'." $prefix
			return;
		}
					
		variable logrequests

		if { $logrequests ne "" } {
			set logstr [subst -nocommands $logrequests]
			variable unamespace
			lput putlog $logstr "$unamespace: "
		}

		::http::config -useragent "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; 240x320)" -urlencoding cp1251

		set query [::http::formatQuery key $ustr]
		variable fetchurl		

		if { [queue_add "$fetchurl/search.php?$query" $id "[namespace current]::dream:parser" [list $unick $uhost {} $uchan {}]] } {
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

	proc dream:parser { errid errstr body extra } {
		upvar $errid lerrid $errstr lerrstr $body lbody $extra lextra

		variable err_fail

		variable pubsend
		variable msgsend
		variable errsend

		foreach { unick uhost handle uchan str } $lextra { break }

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

		if { [regexp -nocase -- {<h2 title="(.*?)">.*?<p id="main3">(.*?)</p><br><p class="smalltxt">(.*?)</p>} $str -> info1 info2 info3] } {

			proc striphtmltags { str } {
				
				regsub -all -nocase -- {<strong>} $str "\00310\037" str
				regsub -all -nocase -- {</strong>} $str "\037\003" str
				regsub -all -nocase -- {<.*?>} $str "" str
				regsub -all -nocase -- {&nbsp;} $str " " str
			return [string trim $str]
			}
			
			if { $uchan eq $unick } {
				set prefix [subst -nocommands $msgsend]
			} else {
				set prefix [subst -nocommands $pubsend]
			}

			lput putserv "\00310$info1" $prefix
			lput putserv "$info2" $prefix
			lput putserv "\00310[striphtmltags $info3]" $prefix
		} else {
			lput putserv "\00302[subst -nocommands $err_fail]" [subst -nocommands $errsend]
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
		
		if { ! [catch {
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
	}
}

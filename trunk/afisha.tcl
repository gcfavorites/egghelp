#
# Yandex Afisha 
# 
# ��������� �������: .chanset #chan +afisha
# �������: !afisha

package require Tcl 	8.4
package require http	2

namespace eval afisha {
foreach p [array names afisha *] { catch {unset afisha ($p) } }

# ---------------------------------------------------------------------------
# ��������� ��������� ������������ (Suzi / http.tcl)
# ---------------------------------------------------------------------------
	# �������� � ������������ �������, ������, ���� ��������� �����������
	variable author			"anaesthesia"
	variable version		"01.5"
	variable date			"20-sep-2007"

	# ��� ���������� ��� ������� ���������
	variable unamespace		[string range [namespace current] 2 end]

	# ������� ��� ��������� ������ (����� ���� ������ �������)
	variable pubprefix 		{!}
	variable pubflag		{-|-}

	# pubcmd:���_����������� "�����1 �����2 ..."
	# ������� � � ��������� ������, ������ � ������� ������ ��������� ��������
	variable pub:afisha		"$unamespace afisha �����"

	# ���� ��� � ����, ��� ��������� ������
	variable msgprefix		{!}
	variable msgflag		{-|-}
	# ����� �� ������� ��� ��� ��������� �������
	variable msg:afisha		${pub:afisha}

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
	# � ������ ������ ����� ������ ����������� � ��� ����� -- "nodream"
	# ��� ��������� �� ������ ��������� ������

	variable chflag			"$flagactas$unamespace"

	setudef  flag 			$chflag

# ---------------------------------------------------------------------------
# ��������� ��������� ������������
# ---------------------------------------------------------------------------
	# ����� ��� �������� -- ������ ������ ��� �� ������
	# ����� ��������������� ����� � ���
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
	
# ---------------------------------------------------------------------------
#  ���������� ���������� � ���
# ---------------------------------------------------------------------------

	# ���������� ��������� �����������
	variable maxres		5

	# �����, � �������� ���������� ��������� ����������
	variable 		fetchurl	""

	# ������� ��������
	variable 		reqqueue
	array unset 	reqqueue

	# ��������� ����������
	variable 		laststamp
	array unset		laststamp 

	variable 		cityid
	array unset		cityid 

	variable		updinprogress	0

	variable		updatetimeout	60000

#---body---

proc tolow {strr} {
    return [string tolower [string map {� � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �} $strr]]
}

proc fdate {strr} {
	return [string map {"Sunday" "�����������" "Monday" "�����������" "Tuesday" "�������"  "Wednesday" "�����" "Thursday" "�������" "Friday" "�������" "Saturday" "�������" 
 "January" "������" "February" "�������" "March" "�����" "April" "������" "May" "���" "June" "����" "July" "����" "August" "�������" "September" "��������" "October" "�������" "November" "������" "December" "�������" } [clock format [clock scan $strr] -format "%e %B (%A)"]] 
}

	proc msg:afisha { unick uhost handle str } {
		pub:afisha $unick $uhost $handle $unick $str
		return
	}

	proc pub:afisha { unick uhost handle uchan str } {

		variable requserid
		variable fetchurl
		variable chflag
		variable flagactas
		variable errsend
		variable cityid		
		variable pubprefix
		variable unamespace
		variable maxres
		variable logrequests
		
		global afdate
		global aftype
		global afpage
		global afcity
		global afs

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
#---������ ����������----------
	set str [tolow $str]
#---������ ������-s-(������������ ����)
		set afs 0
	if { [regexp -nocase -- {\+(.+)} $str tr afsearch] } {
		set afsearch [string map { " " "+" } $afsearch]
		set fetchurl "http://www.afisha.yandex.ru/search/?&text=$afsearch"
		set afs 1 } else {
		set fetchurl "http://www.afisha.yandex.ru/chooser.xml?"
	} 
#---����� ��������-p
	if { [regexp -nocase -- {-p(\d+)} $str tr afpage] } {
		set afpage $afpage } else {
		set afpage 1
	}
#---����-d
	if { [regexp -nocase -- {-d(\d+)} $str tr afdatep] } {
		set afdate [clock format [expr {[clock seconds] + $afdatep * 86400 }] -format "%Y-%m-%d"] } else {
		set afdate [clock format [clock seconds] -format "%Y-%m-%d"]
	}
#--�����
	if 	{ [string match "*���������*" $str] || [string match "*���*" $str] } { 
		set afcity "&city=SPB" 
				} elseif {
		  [string match "*����*" $str] } { 
		set afcity "&city=ATA" 
				} elseif { 
		  [string match "*���������*" $str] } { 
		set afcity "&city=VLG" 
				} elseif {  
		  [string match "*������������*" $str] || [string match "*�����*" $str] } { 
		set afcity "&city=EKT" 
				} elseif {  
		  [string match "*�������*" $str] } { 
		set afcity "&city=IRK" 
				} elseif {
		  [string match "*������*" $str] } { 
		set afcity "&city=KZN" 
				} elseif {
		  [string match "*����*" $str] } { 
		set afcity "&city=KYV" 
				} elseif {
		  [string match "*���������*" $str] } { 
		set afcity "&city=KRD" 
				} elseif {
		  [string match "*��������*" $str] } { 
		set afcity "&city=MRM" 
				} elseif {
		  [string match "*��������*" $str] } { 
		set afcity "&city=NNV" 
				} elseif {
		  [string match "*�����������*" $str] || [string match "*���*" $str]} { 
		set afcity "&city=NVS" 
				} elseif {
		  [string match "*������*" $str] } { 
		set afcity "&city=ODS" 
				} elseif {
		  [string match "*������������*" $str] } { 
		set afcity "&city=PTR" 
				} elseif {
		  [string match "*������*" $str] } { 
		set afcity "&city=RND" 
				} elseif {
		  [string match "*����������*" $str] } { 
		set afcity "&city=STV" 
				} elseif {
		  [string match "*���*" $str] } { 
		set afcity "&city=UFA" 
				} elseif {
		  [string match "*���������*" $str] } { 
		set afcity "&city=CHL" 
				} elseif {
		  [string match "*���������*" $str] } { 
		set afcity "&city=YRS" 
				} else {
		set afcity "&city=MSK" 
				}
#---��� ������
	if 	{ [string match "*�������*" $str] || [string match "*������*" $str] } { 
		set aftype "concert" 
				} elseif {
	 	 [string match "*����*" $str] } { 
		set aftype "cinema" 
				} elseif {
	 	 [string match "*�����*" $str] } { 
		set aftype "sport" 
				} elseif {
	 	 [string match "*�����*" $str] } { 
		set aftype "theatre" 
				} elseif {
	 	 [string match "*���*" $str] } { 
		set aftype "art" 
				} elseif {
	 	 [string match "*����*" $str] } { 
		set aftype "club" 
				} elseif {
	 	 [string match "*+*" $str] } { 
		set aftype "search" 
				} else {
			lput puthelp "\002�������:\002 $pubprefix$unamespace \<����\|��������\|�����\|���\|������\|�����\> \[�����\] \[-d����\] \[-p��������\]. \002��������:\002 $pubprefix$unamespace ���� ����������� -d3 -p2" $prefix
			lput puthelp "\002���������:\002 '-d����' - ����� ���, ������ �� ��������, '-p��������' - ����� �������� (�� ��������� ��������� ���� �����������, �.� �������� '-p3' ������� ���������� � 10-�� �� 15-�)" $prefix 
			lput puthelp "\002�����:\002 $pubprefix$unamespace +������ ������" $prefix 
			lput puthelp "\002������:\002 �.-��������� (���) ����-���, ���������, ������������, �������, ������, ����, ���������, ��������, ��������, �����������, ������, ������������, ������, ����������, ���, ���������, ��������� (�� ��������� - ������)" $prefix
			return
			}

		if { $logrequests ne "" } {
			set logstr [subst -nocommands $logrequests]
			lput putlog $logstr "$unamespace: "
		}

		::http::config -urlencoding cp1251
		
		if { $afs == 1 } { 
			set fetchurl "$fetchurl$afcity&p=[expr {$afpage - 1}]" 
		} else {
			set fetchurl "$fetchurl&type=$aftype&date=$afdate$afcity&limit=$maxres&page=$afpage&"
		}
		
		if { [queue_add "$fetchurl" $id "[namespace current]::dream:parser" [list $unick $uhost $uchan {}]] } {
			variable err_ok
			if { $err_ok ne "" } {
				lput puthelp "$err_ok. " $prefix
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
		variable maxres

		global afdate
		global aftype
		global afpage
		global afcity
		global afs

		foreach { unick uhost uchan str } $lextra { break }

		if { $lerrid ne {ok} } {
			lput putserv [subst -nocommands $err_fail] [subst -nocommands $errsend]
			return
		}

		if { $uchan eq $unick } {
			set prefix [subst -nocommands $msgsend]
		} else {
			set prefix [subst -nocommands $pubsend]
		}

	global sp_version
	if {[info exists sp_version]} {	
		set str [encoding convertfrom cp1251 $lbody] 
		} else {
		set str $lbody
		}

# ---------------------------------------------------------------------------
##---parser-specific---afisha---
# ---------------------------------------------------------------------------

regsub -all -nocase -- "&city=" $afcity {} afcity 
		regsub -all -- "\n|\r|\t" $str {} str
		regsub -all -- "&amp;" $str {\&} str

		if { [string match -nocase "*��������� ������� ������ ����*" $str] || [string match -nocase "*���������� ���� ����� �� �����������*" $str] } {
		lput putserv "\037������ �� �������.\017" $prefix 
		return
			}
#---���� �����
		if { $afs == 1 } {

	regexp {<title>(.*?)</title>} $str match stotal 
	lput putserv "$stotal" $prefix
	
	regexp {<ol.*?>(.*?)</ol>} $str match str

	regsub -all -- <li> $str </li>\n str

		set count 0
		foreach line [split $str \n] {

	if { [regexp {<a href=.*?>(.*?)</a><div>(.*?)</div>} $line match sname sdesc] } {

		if { [regexp {date=(.*?)\&} $line match sdate] } {
			set sdate [string map {"Sunday" "��." "Monday" "���." "Tuesday" "��."  "Wednesday" "��." "Thursday" "��" "Friday" "��" "Saturday" "��" 
 "January" "���." "February" "���." "March" "�����" "April" "���." "May" "���" "June" "����" 
 "July" "����" "August" "���." "September" "����." 
 "October" "���." "November" "���." "December" "���." } [clock format [clock scan $sdate] -format "%e %B (%A)"]] 
			} else { set sdate "" }

	regsub -all -nocase -- "<b>" $sname "\002" sname
	regsub -all -nocase -- "</b>" $sname "\017" sname
	regsub -all -nocase -- "<a href=.*?>" $sdesc " - " sdesc
	regsub -all -nocase -- "</a>" $sdesc "" sdesc

	lput putserv "\002\037����.:\017 $sname - $sdesc - $sdate" $prefix 
	}
		incr count
		if {$count == $maxres} {break}
		}
		} else {
#---���� �� �����
		regexp {<tr id="f">(.*?)</body>} $str match str
	regsub -all -nocase -- </tr> $str </tr>\n str

#---TODO:������� ����� � ����������
#---��������-�����
	if { $aftype == "concert" || $aftype == "club"} {
	lput putserv "\002\037�����\017  �� \002[fdate $afdate]\002 ($aftype) ($afcity) ���. $afpage" $prefix 
	
		set count 0
		foreach line [split $str \n] {

		if { [regexp {<a href=.*?>(.*?)</a>(.*?)<a class=.*?>(.*?)</a>(.*?)</tr>} $line match aname astyle aplace atime] } {
		set dconcert "1"
		regsub -all -- "<.*?>" $astyle "" astyle
		regsub -all -- "<.*?>" $atime "" atime
			} else {
				set dconcert "0"
					}
if { $dconcert != "0" } {
lput putserv "\002\037����.:\017 $aname ([string trim $astyle]) - \002\037���:\017 $aplace ([string trim $atime] )" $prefix 
		incr count
		if {$count == $maxres} {break}
		}
								}
if { $count == 0 } {
lput putserv "\037������ �� �������.\017" $prefix 
					}
	}
#---��������
	if { $aftype == "art" } {
	lput putserv "\002\037�����\017  �� \002[fdate $afdate]\002 ($aftype) ($afcity) ���. $afpage" $prefix 
	
		set count 0
		foreach line [split $str \n] {

		if { [regexp {<a href=.*?>(.*?)</a>(.*?)<a class=.*?>(.*?)</a>} $line match ename estyle eplace] } {
		set dconcert "1"
		regsub -all -- "<.*?>" $estyle "" estyle
			} else {
				set dconcert "0"
					}

if { $dconcert != "0" } {
lput putserv "\002\037����.:\017 $ename ([string trim $estyle]) - \002\037���:\017 $eplace " $prefix
		incr count
		if {$count == $maxres} {break}
		}
								}
if { $count == 0 } {
lput putserv "\037������ �� �������.\017" $prefix 
					}
	}
#---������-�����
	if { $aftype == "theatre" || $aftype == "sport" } {
	lput putserv "\002\037�����\017  �� \002[fdate $afdate]\002 ($aftype) ($afcity) ���. $afpage" $prefix 
	
		set count 0
		foreach line [split $str \n] {

		if { [regexp {<a href=.*?>(.*?)</a>(.*?)<a class=.*?>(.*?)</a>.*?<li>(.*?)</li>} $line match tname tstyle tplace ttime] } {
		set dtheatre "1"
		regsub -all -- "</div>" $tstyle " - " tstyle
		regsub -all -- "<.*?>" $tstyle "" tstyle
		regsub -all -- "<span.*?>" $ttime "" ttime
		regsub -all -- "</span>" $ttime "" ttime
			} else {
				set dtheatre "0"
					}

if { $dtheatre != "0" } {
lput putserv "\002\037����:\017 $tname ([string trim $tstyle]) - \002\037���:\017 $tplace ( $ttime )" $prefix
		incr count
		if {$count == $maxres} {break}
		}
								}
if { $count == 0 } {
lput putserv "\037������ �� �������.\017" $prefix 
					}
	}
#---����
	if { $aftype == "cinema" } {
	lput putserv "\002\037�����\017  �� \002[fdate $afdate]\002 ($aftype) ($afcity) ���. $afpage" $prefix 
	
		set count 0
		foreach line [split $str \n] {

		if { [regexp {<a href=.*?>(.*?)</a>.*?<div class="comment">(.*?)</div>(.*?)<a class=.*?>(.*?)</a>(.*?)</tr>} $line match cname ccomm ctype cplace ctime] } {
		set dcinema "1"
		regsub -all -- "<.*?>" $ctype "" ctype
		regsub -all -- "<li>" $ctime "  " ctime
		regsub -all -- "<.*?>" $ctime "" ctime
			} elseif { [regexp {<a href=.*?>(.*?)</a>.*?<div class="comment">(.*?)</div>.*?<td.*?>(.*?)<td.*?>(.*?)</tr>} $line match cname ccomm ctype cplace] } {
		set dcinema "1"
		regsub -all -- "<.*?>" $ctype "" ctype
		regsub -all -- "<.*?>" $cplace "" cplace
		set ctime ""
			} else {
				set dcinema "0"
					}

if { $dcinema != "0" } {
lput putserv "\002\037����.:\017 $cname ($ccomm - [string trim $ctype]) - \002\037���:\017 $cplace - $ctime " $prefix
		incr count
		if {$count == $maxres} {break}
		}
								}
if { $count == 0 } {
lput putserv "\037������ �� �������.\017" $prefix 
					}
	}
#putlog "parser done"
#--end-�����
	}
		return
}		
# ---------------------------------------------------------------------------
##---ok---
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

#---clear
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

#---command aliases & bnd
	proc cmdaliases { { action {bind} } } {
		foreach { bindtype } {pub msg dcc} {
			foreach { bindproc } [info vars "[namespace current]::${bindtype}:*"] {
				variable "${bindtype}prefix"
				variable "${bindtype}flag"			
				foreach { alias } [set $bindproc] {
					catch { $action $bindtype [set ${bindtype}flag] [set ${bindtype}prefix]$alias $bindproc }
				}				
			}
		}
		
		return
	}
#---killtimers	
	if {[info exists timerID]} {
		catch {killtimer $timerID}; 
		catch {unset timerID}
	}
#---rest	
	[namespace current]::queue_clear_stamps
	cmdaliases
	global sp_version
	if {[info exists sp_version]} {
	putlog "[namespace current] v$version suzi_$sp_version \[$date\] by $author loaded."
	} else {
	putlog "[namespace current] v$version \[$date\] by $author loaded."
	}
}











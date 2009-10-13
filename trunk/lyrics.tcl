#----------------------------------------------------------------------------
# lyrics - �����, �����������, mp3.
# ������: !lyrics [?][+][-�����] <�����������> [��������]
# ������: !lyrics nirvana smells like teen - ����� ������ �����
#		  !lyrics ?nirvana - �����������
#		  !lyrics +nirvana smells like teen - ����� mp3
#		  !lyrics -���� - �������� ����
# �����:  .chanset #chan +lyrics  - ��������� ������� �� ������ #chan (�� ��������� ��������)
#		  .chanset #chan +lyricsq - ����� ����� (���������� ������ �������� � ������)
#	--
#		  ������ ������������ �� eggdrop 1.6.18/Suzi, tcl 8.5.2, freeBSD 7
#		  ������� � ���������: anaesthesia #eggdrop@Rusnet
#----------------------------------------------------------------------------
package require Tcl 	8.4
package require http	2.5

namespace eval lyrics {
foreach p [array names lyrics *] { catch {unset lyrics ($p) } }
#----------------------------------------------------------------------------
# ��������� ��������� ������������ (Suzi / http.tcl)
#----------------------------------------------------------------------------
	variable unamespace		[namespace tail [namespace current]]
	variable author			"anaesthesia"
	variable version		"01.06"
	variable date			"13-jun-2008"

	# ������� ��� ��������� ������ (����� ���� ������ �������)
	variable pubprefix 		{!}
	variable pubflag		{-|-}

	# pubcmd:���_����������� "�������1 �������2 ..."
	# ������� � � ��������� ��������, ������ � ������� �������� ��������� ��������
	variable pub:lyrics		"$unamespace song �����"

	# ���� ��� � ����, ��� ��������� ������
	variable msgprefix		{!}
	variable msgflag		{-|-}
	# ����� �� ������� ��� ��� ��������� �������
	variable msg:lyrics		${pub:lyrics}

	# ����� ��������� ��������� ��� ��������� �������, ������ � �������� ������� ������ ������
	# ��� ��������������� ����������  variable [pub|msg]:handler "string ..."

	# ����� �������������� ������������ ��� ���������� ��������
	# �������� $unick, $uhost, $uchan
	# ������� tcl ���������, ����������� ������������ ���������� id ���
	# ������������� �������.
	variable requserid		{$uhost}
	
	# ������������ ����� ��������� ���������� �������� ��� ������ id
	variable maxreqperuser	2

	# ������������ ����� ��������� ���������� ��������
	variable maxrequests	5

	# ����� ����� ���������, � ������� ������� ������ ���������� ��� �������������, 
	# ������ 
	variable pause			35
	
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
	# � ������ ������ ����� ������ �����������  
	# ��� ��������� �� ������ ��������� ������

	variable chflag			"$flagactas$unamespace"

	setudef  flag 			$chflag
	setudef  flag 			$chflag\q

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

	# ���������� ��������� �����������
	variable maxres		10

#----------------------------------------------------------------------------
#  ���������� ����������
#----------------------------------------------------------------------------
	# �����, � �������� ���������� ��������� ����������
	variable 		furll		"http://lyrics.mp3s.ru/perl/search_lyrics.pl?log=true&query="
	variable		furla		"http://artists.mp3s.ru/view/artist/"	
	variable		furld		"http://news.mp3s.ru/view/onday/"
	variable		furls		"http://search.mp3s.ru/perl/search_mp3s.pl?log=true&query="

	# ������� ��������
	variable 		reqqueue
	array unset 	reqqueue

	# ��������� ����������
	variable 		laststamp
	array unset		laststamp 
	variable		updinprogress	0
	variable		updatetimeout	60000

#---body--- ����� ����������� ---

	proc tolow {strr} {
    	return [string tolower [string map {� � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �} $strr]]
	}

	proc sspace {strr} {
  		return [string trim [regsub -all {[\t\s]+} $strr { }]]
	}

	proc msg:lyrics { unick uhost handle str } {
		pub:lyrics $unick $uhost $handle $unick $str
		return
	}

	proc pub:lyrics { unick uhost handle uchan str } {
		variable pubprefix 
		variable requserid
		variable furll
		variable furla
		variable furld
		variable furls
		variable ltype
		variable chflag
		variable flagactas
		variable errsend
		variable maxres
		variable pubsend
		variable msgsend
		variable unamespace
		variable mpage

		set id [subst -nocommands $requserid]
		set prefix [subst -nocommands $errsend]

		if {$unick ne $uchan} {
			if {![channel get $uchan $chflag] ^ $flagactas eq "no"} {return}
		}

		set why [queue_isfreefor $id]		
		if {$why != ""} {lput puthelp $why $prefix ; return}

#---���������

	if {[regexp -nocase -- {^-(\d+)} $str -> mpg]} {set mpage $mpg ; regsub -- {-\d+\s+} $str "" str} {set mpage 1}

	set ustr [string map {" " "%20"} [tolow $str]]

		if {$ustr == ""} {
			if {$uchan eq $unick} {set prefix [subst -nocommands $errsend]} {set prefix [subst -nocommands $pubsend]}
			lput puthelp "\002������\002: $pubprefix$unamespace \[?\]\[+\]\[-�����\] <�����������> \[��������\] - ����� ������� �����, ����������� � mp3. \002������:\002 $pubprefix$unamespace nirvana smells like teen" $prefix		
			lput puthelp "\002��������\002: \002?\002 - �����������. \002������:\002 $pubprefix$unamespace ?nirvana" $prefix
			lput puthelp "\002��������\002: \002+\002 - ����� mp3. \002������:\002 $pubprefix$unamespace +nirvana smells like teen" $prefix				
			lput puthelp "\002��������\002: \002-day\002 - �������� ����. \002������:\002 $pubprefix$unamespace -����" $prefix				
			return
		} else {
			if {$uchan eq $unick} {set prefix [subst -nocommands $errsend]} {set prefix [subst -nocommands $pubsend]}
				if {[regexp -nocase -- {\?} $ustr]} {
					regsub -- {\?} $ustr "" ustr
					set fetchurl "$furla[string trim $ustr]/?all_disc"
					set ltype "art"
				} elseif {[regexp -nocase -- {-day|-����} $ustr]} {
					set fetchurl $furld
					set ltype "day"
				} elseif {[regexp -nocase -- {\+} $ustr]} {
					regsub -- {\+} $ustr "" ustr
					set fetchurl "$furls[string trim $ustr]"
					set ltype "mp3"
				} else {
					set fetchurl $furll$ustr
					set ltype "lyr"
				}
		}

		variable logrequests

		if {$logrequests ne ""} {
			set logstr [subst -nocommands $logrequests]
			variable unamespace
			lput putlog $logstr "$unamespace: "
		}

		::http::config -useragent "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; 240x320)"	

		if {[queue_add "$fetchurl" $id "[namespace current]::dream:parser" [list $unick $uhost $uchan {}]]} {
			variable err_ok
			if {$err_ok ne ""} {
				lput puthelp "$err_ok." $prefix
			}
		} else {
			variable err_fail
			if {$err_fail ne ""} {
				lput puthelp $err_fail $prefix
			}
		}
		return
	}
#---parser
	proc dream:parser { errid errstr body extra } {
		upvar $errid lerrid $errstr lerrstr $body lbody $extra lextra

		variable err_ok
		variable err_fail
		variable pubsend
		variable msgsend
		variable errsend
		variable useurl
		variable maxres
		variable mpage
		variable ltype
		variable chflag
		variable flagactas

		foreach { unick uhost uchan ustr } $lextra { break }

		if {$lerrid ne {ok}} {
			lput putserv [subst -nocommands $err_fail] [subst -nocommands $errsend]
			return
		}

		if {$uchan eq $unick} {
			set prefix [subst -nocommands $msgsend]
		} else {
			if {![channel get $uchan $chflag\q] ^ $flagactas eq "no"} {
				set prefix [subst -nocommands $pubsend]
			} else {
				set prefix [subst -nocommands $msgsend]
			}
		}
#--suzi-patch
	global sp_version
	if {[info exists sp_version]} {	
		set str [encoding convertfrom cp1251 $lbody] 
		} else {
		set str $lbody
		}
#----------------------------------------------------------------------------
##--parser-specific------
#----------------------------------------------------------------------------

	if {[string match "*���������� ���� ����� �� �����������*" $str]} {
		lput putserv "\037������ �� �������\037." $prefix
		return
	}

	if {$ltype eq "lyr"} {
		if {[regexp -- {<td class=pad7>.*?<b>(\d+)</b>} $str -> snum]} {
			if {$snum == 1} {
				regexp -- {<td width=95% class=row1><p><a href=\"(.*?)\" class=lar-blu>(.*?)</a>} $str -> lurl linf
				regsub -all -- "<b>" $linf "\002" linf
				regsub -all -- "</b>" $linf "\002" linf
				lput putserv "\037�������\037: $snum - $linf" $prefix
				queue_add "http://lyrics.mp3s.ru$lurl" $snum "[namespace current]::lyrics:parser" [list $unick $uhost $uchan {}]
			} else {
				regexp -- {<td width=95% class=row1><p><a href=\"(.*?)\" class=lar-blu>(.*?)</a>} $str -> lurl linf
				regsub -all -- "<b>" $linf "\002" linf
				regsub -all -- "</b>" $linf "\002" linf
				lput putserv "\037�������\037: $snum - �������� ������. :: \037������ ��������\037: $linf" $prefix
					if {[regexp -- {<table width=100% border=0 cellspacing=0 cellpadding=0>(.*?)</p></td></tr></table>} $str -> lmany]} {
						set lmn ""
						regsub -all -- "\n|\r" $lmany "" lmany
						regsub -all -- "</tr>" $lmany "</tr>\n" lmany
						regsub -all -- "<b>" $lmany "\002" lmany
						regsub -all -- "</b>" $lmany "\002" lmany
							foreach amany [split $lmany \n] {
								if {[regexp -- {<a href=.*?class=lar-blu>(.*?)</a><br>} $amany -> amn]} {
								append lmn "$amn : "
								}
							}
						lput putserv "\037��������� ������� ����������\037: $lmn" $prefix
						queue_add "http://lyrics.mp3s.ru$lurl" $snum "[namespace current]::lyrics:parser" [list $unick $uhost $uchan {}]

					}
					return
			}
		} else {
			lput putserv "\037������ ��������\037." $prefix
			return
		}
	} ;#lyr

	if {$ltype eq "art"} {
		if {[regexp -- {<td class=pad6><h1>(.*?)</h1></td></tr>} $str -> aname]} {
			set ainfo ""
			if {[regexp -- {<br>������ �����:(.*?)<br>} $str -> acity]} {append ainfo ":: \037�����\037: $acity "}
			if {[regexp -- {<br>�������� �����(.*?)<br>} $str -> astyle]} {regsub -all -- "<.*?>" $astyle "" astyle ; append ainfo ":: \037�����\037: $astyle "}
			if {[regexp -- {<td>����������� ������� �� �����:(.*?)</td>} $str -> asim]} {regsub -all -- "<.*?>" $asim "" asim ; append ainfo ":: \037�������\037: $asim "}
			lput putserv "[sspace $ainfo]" $prefix

			if {[regexp -- {<td class=bg-blu><span class=lar-wht>(.*?)<table border=0 cellspacing=0 cellpadding=1 width=100% bgcolor=cccccc><tr><td>} $str -> adisc]} {
				set adsc ""
				regsub -all -- "\n|\r" $adisc "" adisc
				regsub -all -- "</tr>" $adisc "</tr>\n" adisc
					foreach aline [split $adisc \n] {
						if {[regexp -- {<font color=CC0000>(.*?)</font></a> <br>(.*?)<br></td>} $aline -> aalb ayear]} {
							append adsc "$aalb (\002$ayear\002) \002:\002 "
						}
					}
				lput putserv "\037�����������\037: $adsc" $prefix
			} else {lput putserv "\037������ �� ������� ��� ����������� ������� ������\037." $prefix}
		} else {
		lput putserv "\037������ �� �������\037." $prefix
		}
	} ;#art

	if {$ltype eq "day"} {
		if {[regexp -- {<td class=bg-blu><span class=lar-wht>(.*?)<table cellspacing=1 cellpadding=0 border=0 width=100%>} $str -> aday]} {
				set ady ""
				regsub -all -- "\n|\r" $aday "" aday
				regsub -all -- "</tr>" $aday "</tr>\n" aday
				regsub -all -- "<b>" $aday "\002" aday
				regsub -all -- "</b>" $aday "\002" aday
				regsub -all -- "&nbsp;�&nbsp;" $aday "" aday
					foreach aline [split $aday \n] {
						if {[regexp -- {<td nowrap valign=top class=row2>(.*?)</td><td class=row2><u>(.*?)</u>} $aline -> ad aw]} {
							append ady "$ad - $aw : "
						}
					}
				lput putserv "$ady" $prefix
		} else {
		lput putserv "\037������ �� �������\037." $prefix
		}
	} ;#day

	if {$ltype eq "mp3"} {
			regexp -- {<td class=pad7>.*?<b>(\d+)</b>} $str -> snum
				set amp3 $str
				set am3 ""
				regsub -all -- "\n|\r" $amp3 "" amp3
				regsub -all -- "</p></td></tr>" $amp3 "</p></td></tr>\n" amp3
				regsub -all -- "<b>" $amp3 "\002" amp3
				regsub -all -- "</b>" $amp3 "\002" amp3
				regsub -all -- "&nbsp;" $amp3 " " amp3
					set cnt 0
					foreach aline [split $amp3 \n] {
						if {[regexp -- {<tr><td valign=top><a href=\"(.*?)\".*?class=lar-blu>(.*?)</a>.*?MP3:.*?</a>(.*?)</span></a><br><span class=lil-bla>(.*?)</span></p><p>.*?�������:(.*?)</a>} $aline -> mplink mpname mpinfo mpstat mpsize]} {
							incr cnt		
							if {$cnt == $mpage} {append am3 "$mpname @ \037\00312http://search.mp3s.ru$mplink\003\037 ($mpsize) :: \00305[string trimleft $mpinfo ","]\003 :: $mpstat"}
						}
					}
		if {$cnt > 0} {
			regsub -all -- "<.*?>" $am3 "" am3
			lput putserv "\[$mpage/$cnt/�����:$snum\] [sspace $am3]" $prefix
		} else {
			lput putserv "\037������ �� �������\037." $prefix
		}
	} ;#mp3

	return
	}		
#----------------------------------------------------------------------------
##--ok------
#----------------------------------------------------------------------------
	proc lyrics:parser { errid errstr body extra } {
		upvar $errid lerrid $errstr lerrstr $body lbody $extra lextra

		variable err_fail
		variable pubsend
		variable msgsend
		variable errsend
		variable maxres
		variable mpage

		foreach { unick uhost uchan ustr } $lextra { break }
		if { $lerrid ne {ok} } {lput putserv [subst -nocommands $err_fail] [subst -nocommands $errsend]; return}
		set prefix [subst -nocommands $msgsend]
		global sp_version
		if {[info exists sp_version]} {set str [encoding convertfrom cp1251 $lbody]} {set str $lbody}

#--lyrics-parser
		if {[regexp -- {<span class=lar-wht>(.*?)</span></td>} $str -> lhead]} {
			regsub -all -- "&laquo;" $lhead {"} lhead
			regsub -all -- "&raquo;" $lhead {"} lhead
			lput putserv "$lhead" $prefix

			regexp -- {<table width=100% border=0 cellspacing=0 cellpadding=10>(.*?)</table>} $str -> ltext
			regsub -all -- "<br>" $ltext "\n" ltext
			regsub -all -- "<.*?>" $ltext "" ltext
				foreach lline [split $ltext \n] {
					lput putserv "$lline" $prefix
				}
		} else {
		putlog "parse error"
		}
	return
	}	

#---output
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

#---queue
	proc queue_isfreefor { { id {} } } {

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

			if {$timewait > 0} {
				return [subst -nocommands $err_queue_time]
			}			
		}

		if {[llength [array names reqqueue -glob "*,$id"]] >= $maxreqperuser} {
			return $err_queue_id
		}

		if {[llength [array names reqqueue]] >= $maxrequests} { 
			return $err_queue_full
		}
		
		return
	}

#---add-to-queue
	proc queue_add { newurl id parser extra {redir 0} } {
		variable reqqueue
		variable proxy
		variable timeout
		variable laststamp

		::http::config -proxyfilter "[namespace current]::queue_proxy"
		
		if {![catch {set token [::http::geturl $newurl -command "[namespace current]::queue_done" -binary true -timeout $timeout]} errid]} {		
			set reqqueue($token,$id) [list $parser $extra $redir]		
			set laststamp(stamp,$id) [unixtime]
		} else {
			return false
		}
		return true
	}

#---proxy
	proc queue_proxy { url } {
		variable proxy
		if {$proxy ne {}} {return [split $proxy {:}]}		
		return [list]
	}
	
#---callback
	proc queue_done { token } {
		upvar #0 $token state
		variable reqqueue
		variable maxredir
		
		set errid  		[::http::status $token]
		set errstr 		[::http::error  $token]
		
		set	id  	[array  names reqqueue "$token,*"]
		foreach { parser extra redir } $reqqueue($id) {break}
		regsub -- "^$token," $id {} id
	
		while (1) {
			if {$errid == "ok" && [::http::ncode $token] == 302} {
				if {$redir < $maxredir} {			
					array set meta $state(meta)
					if {[info exists meta(Location)]} {
						variable fetchurl
						queue_add "$fetchurl$meta(Location)" $id $parser $extra [incr redir]
						break
					}
				} else {
					set errid   "error"
					set errstr  "Maximum redirects reached."
				}
			} 
			if {[catch {$parser {errid} {errstr} {state(body)} {extra}} errid]} {
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

		set curr [expr {[unixtime] - 2 * $timeout / 1000 }];

		foreach {id} [array names laststamp] {
			if {$laststamp($id) < $curr} {
				array unset laststamp $id;
			}
		}		

		set timerID [timer 10 "[info level 0]"]
	}

#---command aliases & bnd
	proc cmdaliases { { action {bind} } } {
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











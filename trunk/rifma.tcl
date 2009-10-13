#----------------------------------------------------------------------------
# Rifma 		- ������ ����
# ���������:	.chanset #chan +rifma
# ������:		!rifma [-�����] [-q0-5] <�����>
# ������:		!�����
# �������:		anaesthesia #eggdrop@Rusnet
# �������:		http://egghelp.ru
#----------------------------------------------------------------------------

package require Tcl 	8.4
package require http	2.5

namespace eval rifma {
foreach p [array names rifma *] { catch {unset rifma ($p) } }

#----------------------------------------------------------------------------
# ��������� ��������� ������������
#----------------------------------------------------------------------------
	# �������� � ������������ �������, ������, ���� ��������� �����������
	variable author			"anaesthesia"
	variable version		"01.01"
	variable date			"11-Aug-2008"
	variable unamespace		[namespace tail [namespace current]]

	# ������� ��� ��������� ������ (����� ���� ������ �������)
	variable pubprefix 		{!}
	variable pubflag		{-|-}

	# ������� ������ (�����)
	# pubcmd:���_����������� "�������1 �������2 ..."
	# ������� � � ��������� ��������, ������ � ������� �������� ��������� ��������
	variable pub:rifma		"$unamespace �����"

	# ���� ��� � ����, ��� ��������� ������
	variable msgprefix		{!}
	variable msgflag		{-|-}

	# ����� �� ������� ��� ��� ��������� �������
	variable msg:rifma		${pub:rifma}

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
	variable pause			15

	# ���������� ��������� �����������
	variable maxres		25
	
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
	variable err_fail		{� ��������� ��� ������ �� ��������.}

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
	variable 		fetchurl		"http://rifmovnik.ru/cgi/find.exe"
		
	# ������� ��������
	variable 		reqqueue
	array unset 	reqqueue

	# ��������� ����������
	variable 		laststamp
	array unset		laststamp 
	variable		updinprogress	0
	variable		updatetimeout	60000

#---body---

	proc msg:rifma {unick uhost handle str} {
		pub:rifma $unick $uhost $handle $unick $str
		return
	}

	proc pub:rifma {unick uhost handle uchan str} {
		variable requserid
		variable fetchurl
		variable chflag
		variable flagactas
		variable errsend	
		variable maxres
		variable pubprefix
		variable pubsend
		variable msgsend
		variable unamespace
		variable type
		variable mpage
		variable query
		variable logrequests

		set id [subst -nocommands $requserid]
		set prefix [subst -nocommands $errsend]
		if {$unick ne $uchan} {if {![channel get $uchan $chflag] ^ $flagactas eq "no" } {return}}
		set why  [queue_isfreefor $id]
		if {$why != ""} {lput puthelp $why $prefix ; return}
		set query ""

		set ustr [string trim $str]
		if {[regexp -nocase -- {^-(\d+)} $ustr -> mpage]} {regsub -- {-\d+\s+} $ustr "" ustr} {set mpage 1}
		if {[regexp -nocase -- {-q(\d)} $ustr -> cq]} {regsub -- {-q\d\s+} $ustr "" ustr} {set cq 0}

		::http::config -urlencoding cp1251 -useragent "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; 240x320)"	
		set query [::http::formatQuery sWord $ustr submit "�����" cQuality $cq cPos 11 cSylls 0 bVariants OFF bInLine ON cFreq * bPrefixedWords ON cAcc 3 lang ru help "" wordCount "" updateStat "" showPopularWords "" detailedStat ""]
			if {[string is space $ustr]} {
						set prefix [subst -nocommands $msgsend]
						lput puthelp "\002������\002: $pubprefix$unamespace \[-�����\] \[-q0-5\] <�����> - ������ �����." $prefix
						lput puthelp "\002���������\002: '-q' - �������� (0-������, 5-������), �� ��������� -q0. ���-�� ����� ������� �������� ���������� ' (����� �������)." $prefix		
						return
			}

		if {$logrequests ne ""} {set logstr [subst -nocommands $logrequests] ; lput putlog $logstr "$unamespace: "}
		if {[queue_add "$fetchurl" $id "[namespace current]::rifma:parser" [list $unick $uhost $uchan $str]]} {
			variable err_ok ; if {$err_ok ne ""} {lput puthelp "$err_ok." $prefix}
		} {
			variable err_fail ; if {$err_fail ne ""} {lput puthelp "$err_fail" $prefix}
		}

	return
	}

#---parser
	proc rifma:parser {errid errstr body extra} {
		upvar $errid lerrid $errstr lerrstr $body lbody $extra lextra

		variable err_fail
		variable pubsend
		variable msgsend
		variable errsend
		variable useurl
		variable maxres
		variable mpage

		foreach {unick uhost uchan ustr} $lextra {break}
		if {$lerrid ne {ok}} {lput putserv [subst -nocommands $err_fail] [subst -nocommands $errsend] ; return}
		if {$uchan eq $unick} {set prefix [subst -nocommands $msgsend]} {set prefix [subst -nocommands $pubsend]}

#--suzi-patch
	if {[info exists ::sp_version]} {set str [encoding convertfrom [encoding system] $lbody]} {set str $lbody}

#----------------------------------------------------------------------------
##---parser-specific------
#----------------------------------------------------------------------------
	regsub -all -- "\n|\r|\t" $str " " str

	if {![regexp -nocase -- {</form>.*?<b>(.+?)<br>.*?</script>(.+?)<script language="JavaScript">} $str -> rhead rdata]} {
		regexp -- {<div class=error>(.+?)</div>} $str -> rerr ; regsub -all -- "<.*?>" $rerr " " rerr
		lput putserv "\00304������:\003 [sspace $rerr]" $prefix ; return
	}
	regexp -- {<span class=caps>(.+?)</span>} $rhead -> rh ; set rh [string map -noc {"<u>" "\00304" "</u>" "\003"} $rh]
	set rw ""
	foreach {- rhd} [regexp -all -inline -- {<a class=nolink title="(.+?)">} $rhead] {append rw " $rhd ::"}
	regsub -all -- "<br><br>" $rdata "\n" rdata

	set cnt 0 ; set rres [list]
	foreach rwords [split $rdata "\n"] {
		if {[regexp -- {<div class=pos>(.+?)</div>(.+?)$} $rwords -> rt rr]} {
			set rr [string map -noc {"<u>" "\00304" "</u>" "\003" "<br>" "" "<span class=pref>" "\00305" "<span class=suff>" "\00305" "</span>" "\003"} $rr]
			if {[llength $rr] > $maxres} {
				set rwn "\[��������� ~$maxres\] "
				while {[llength $rr] > $maxres} {
					set r_rnd [expr {round(rand() * [llength $rr]-1)}]
						if {[regexp -- {\[} [lindex $rr $r_rnd]]} {
							set rr [lreplace $rr $r_rnd [lsearch -regexp -start $r_rnd $rr {\]}] ]
						} elseif {[regexp -- {\(} [lindex $rr $r_rnd]]} {
							set rr [lreplace $rr $r_rnd [lsearch -regexp -start $r_rnd $rr {\)}] ]
						} elseif {![regexp -- {\]|\)} [lindex $rr $r_rnd]]} {
							set rr [lreplace $rr $r_rnd $r_rnd]
						}
				}
			} {set rwn ""}
			lappend rres "\00314$rt ${rwn}\003-> [string trimright $rr ","]"
			incr cnt
		}
	}
	if {$cnt == 0} {lput putserv "\037������ �� �������\037" $prefix ; return}
	if {$mpage > $cnt} {lput putserv "\037�������� ����� ����������\037. �����: $cnt" $prefix ; return}
	if {[llength $rres] > 0} {lput putserv "\[$mpage/$cnt\] \002$rh\002 :: [sspace $rw] [join [lindex $rres [expr {$mpage - 1}]]]" $prefix}

	return
	}		
#----------------------------------------------------------------------------
##---end-parser------
#----------------------------------------------------------------------------

	proc sspace {strr} {return [string trim [regsub -all {[\t\s]+} $strr { }]]}
	proc tolow  {strr} {return [string tolower [string map {� � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �} $strr]]}

	proc lput {cmd str {prefix {}} {maxchunk 420}} {
	set buf1 ""; set buf2 [list]
		foreach word [split $str] {
			append buf1 " " $word
			if {[string length $buf1]-1 >= $maxchunk} {lappend buf2 [string range $buf1 1 end]; set buf1 ""}
		}
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

	proc queue_add {newurl id parser extra {redir 0}} {
		variable reqqueue
		variable proxy
		variable timeout
		variable laststamp
		variable query
		variable type

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

	proc queue_proxy { url } {
		variable proxy

		if {$proxy ne {}} {return [split $proxy {:}]}		
		return [list]
	}
	
	proc queue_done {token} {
		upvar #0 $token state
		variable reqqueue
		variable maxredir
		variable fetchurl

		set errid  		[::http::status $token]
		set errstr 		[::http::error  $token]		
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

		variable laststamp
		variable timeout
		variable timerID

		set curr [expr {[unixtime] - 2 * $timeout / 1000}];
		foreach {id} [array names laststamp] {
			if {$laststamp($id) < $curr} {array unset laststamp $id}
		}		
		set timerID [timer 10 "[info level 0]"]
	}

	proc cmdaliases {{ action {bind}}} {
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
  	variable sfil [lindex [split [info script] "/"] end]
  	variable modf [clock format [file mtime [info script]] -format "%d-%b-%Y : %H:%M:%S"]
	if {[info exists ::sp_version]} {putlog "[namespace current] v$version (suzi_$sp_version) :: file:$sfil / rel:\[$date\] / mod:\[$modf\] :: by $author :: loaded."} {putlog "[namespace current] v$version :: file:$sfil / rel:\[$date\] / mod:\[$modf\] :: by $author :: loaded."}

} ;#end











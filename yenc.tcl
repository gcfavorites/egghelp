#----------------------------------------------------------------------------
# yenc - ������-������������
#----------------------------------------------------------------------------

package require Tcl 	8.4
package require http	2.5
package require htmlparse
package require struct::tree

namespace eval yenc {

#----------------------------------------------------------------------------
# ��������� ��������� ������������ (Suzi / http.tcl)
#----------------------------------------------------------------------------
	# �������� � ������������ �������, ������, ���� ��������� �����������
	variable author			"anaesthesia"
	variable version		"01.03"
	variable date			"31-Jul-2009"

	# ��� ���������� ��� ������� ���������
	variable unamespace		[namespace tail [namespace current]]

	# ������� ��� ��������� ������ (����� ���� ������ �������)
	variable pubprefix 		{!}
	variable pubflag		{-|-}

	# pubcmd:���_����������� "�������1 �������2 ..."
	# ������� � � ��������� ��������, ������ � ������� �������� ��������� ��������
	variable pub:yenc		"$unamespace ���"

	# ���� ��� � ����, ��� ��������� ������
	variable msgprefix		{!}
	variable msgflag		{-|-}
	# ����� �� ������� ��� ��� ��������� �������
	variable msg:yenc		${pub:yenc}

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
	variable err_ok			{}

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
	variable 		fetchurl		"http://slovari.yandex.ru/search.xml"

	# ���������� ��������� �����������
	variable maxres		1

	# ������� ��������
	variable 		reqqueue
	array unset 	reqqueue

	# ��������� ����������
	variable 		laststamp
	array unset		laststamp 

	variable curTree
	set curTree [::struct::tree]

	variable		updinprogress	0
	variable		updatetimeout	60000

#---body---

	proc tolow {strr} {return [string tolower [string map {� � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �} $strr]]}
	proc sspace {strr} {return [string trim [regsub -all {[\t\s]+} $strr { }]]}

	proc uenc {strr} {
	set str ""
		foreach byte [split [encoding convertto utf-8 $strr] ""] {
        scan $byte %c i
        	if {[string match {[%<>"]} $byte] || $i < 65 || $i > 122} {
				append str [format %%%02X $i]
        	} else {
				append str $byte
        	}
		}
	return [string map {%3A : %2D - %2E . %30 0 %31 1 %32 2 %33 3 %34 4 %35 5 %36 6 %37 7 %38 8 %39 9 \[ %5B \\ %5C \] %5D \^ %5E \_ %5F \` %60} $str]
    }

	proc msg:yenc { unick uhost handle str } {
		pub:yenc $unick $uhost $handle $unick $str
		return
	}

	proc pub:yenc { unick uhost handle uchan str } {

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
		variable idx
		variable idxi

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

#---���������
	set ustr $str

		if {$ustr == ""} {
			if {$uchan eq $unick} {set prefix [subst -nocommands $msgsend]} {set prefix [subst -nocommands $pubsend]}
			lput puthelp "������-������������. \002������\002: $pubprefix\��� \[-�����\] <������>" $prefix		
			return
		} else {
 			if {[regexp -- {^-(\d+)} [lindex $ustr 0] -> idx] && $idx > 0} { 
				set idxi [expr {$idx > 0 ? $idx - 1 : 0}]
				if {$idx > 20} {
					set pg "&p=[expr {$idx / 20}]"
					set idx [expr {($idx % 20) > 0 ? ($idx % 20) - 1 : 0}]
					set ustr [lrange $ustr 1 end]
				} else {
				set idx [expr {$idx > 0 ? $idx - 1 : 0}]
    			set ustr [lrange $ustr 1 end]
				set pg ""
				}
  			} else { set idx 0 ; set idxi 0; set pg ""}
				set ustr "?text=[uenc $ustr]$pg"
		}

		variable logrequests

		if { $logrequests ne "" } {
			set logstr [subst -nocommands $logrequests]
			variable unamespace
			lput putlog $logstr "$unamespace: "
		}

		::http::config -useragent "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; 240x320)"	

		variable fetchurl
		
		if { [queue_add "$fetchurl$ustr" $id "[namespace current]::dream:parser" [list $unick $uhost $uchan {}]] } {
			variable err_ok
			if { $err_ok ne "" } {

				lput puthelp "$err_ok." $prefix
			}
		} else {
			variable err_fail
			if { $err_fail ne "" } {
				lput puthelp $err_fail $prefix
			}
		}

		return
	}
#---parser
	proc dream:parser { errid errstr body extra } {
		upvar $errid lerrid $errstr lerrstr $body lbody $extra lextra

		variable err_fail
		variable pubsend
		variable msgsend
		variable errsend
		variable maxres
		variable idx
		variable idxi
		variable curTree

		foreach { unick uhost uchan ustr } $lextra { break }

		if { $uchan eq $unick } {
			set prefix [subst -nocommands $msgsend]
		} else {
			set prefix [subst -nocommands $pubsend]
		}

		if {$lerrid eq "wredir"} {
			lput putserv "\037������ �� ������ ������� �� �������.\037 (redir)" $prefix
			return
		}

		if { $lerrid ne {ok} } {
			lput putserv [subst -nocommands $err_fail] [subst -nocommands $errsend]
			return
		}

#----------------------------------------------------------------------------
##---parser-specific------
#----------------------------------------------------------------------------
set lbody [encoding convertfrom utf-8 $lbody]
	if {[regexp -nocase -- {<div class="suggest.*?>(.*?)</div>} $lbody -> yerr]} {
		regsub -all -nocase -- {<b>|</b>} $yerr "\002" yerr
		regsub -all -nocase -- {<span class="fix">} $yerr "\00304" yerr
		regsub -all -nocase -- {</span>} $yerr "\003" yerr
		regsub -all -nocase -- {<.*?>} $yerr "" yerr
		lput putserv "[sspace $yerr]" $prefix
	}

	if {[Parse2Tree $lbody]} {

	set count 1
	set start $idx

	if {![regexp -- {<h2 class="word">.*?(\d+).*?</h2>} $lbody -> overall]} {
		set overall [expr [$curTree numchildren root] - 1]
	}

	set denc1 [$curTree get head data]

	lput putserv "\037�������\037: \002$denc1\002 - \037�����\037: $overall" $prefix
		if {$start > $overall} { return }
		set i $start
		set cnt $idxi
		foreach node [lrange [$curTree children root] $start [expr $start + $count - 1]] {
			lput putserv "\002[incr cnt].\002 \[[$curTree get $node data]\]" $prefix
				foreach subnode [$curTree children $node] {
					if {[$curTree get $subnode type] eq "INTERPR"} {
						lput putserv "\002-\002 [$curTree get $subnode data]" $prefix
					} {
						lput putserv "\002�\002 [$curTree get $subnode data]" $prefix
						foreach subsubnode [$curTree children $subnode] {
							lput putserv "\002-\002 [$curTree get $subsubnode data]" $prefix
						} ;# foreach subsubnode
					}
				} ;# foreach subnode ...
		} ;# foreach node ...
	} {
		lput putserv "\037������ �� ������ ������� �� �������.\037" $prefix
	}

  if {[$curTree size]} {
     foreach node [$curTree children root] { $curTree delete $node }
  }

return
}		
#----------------------------------------------------------------------------
##---ok------
#----------------------------------------------------------------------------
	proc Parse2Tree {strr} {
   	variable curTree

# 	regsub -all -- "\n|\t|\r" $strr {} strr

	if {[string match "*: 0�������*" $strr] || [string match "*<b>������ �� �������?</b> �����*" $strr] || [string match "*�����������*�� ������ ������� �� �������.*" $strr]} {
		return no
	}
  
	set pTree [::struct::tree]
	regexp -- {(?i)<h2 class=\"word\">�(.+?)�.+?</h2>} $strr -> head
	regexp -- {(?i)<ol class=\"results\">(.+?)</ol>} $strr -> strr
	regsub -all -nocase -- {<b>|</b>} $strr "\002" strr
	regsub -all -nocase -- {>\s+?<} $strr {><} strr

	regsub -all -nocase -- {<span class=\"source\">(.+?)</span>} $strr " \[\\1\] " strr
	regsub -all -nocase -- {<span class=\"title\">(.+?)</span>} $strr {\1} strr
	regsub -all -nocase -- {<div class=\"title\">(.+?)</div>} $strr {\1} strr
	regsub -all -nocase -- {<div class=\"description\">(.+?)</div>} $strr {\1} strr

	regsub -all -nocase -- {<a .+?>} $strr {} strr
	regsub -all -nocase -- {</a>} $strr {} strr
	regsub -all -nocase -- {<font .+?>} $strr {} strr
	regsub -all -nocase -- {</font>} $strr {} strr
	regsub -all -nocase -- {�} $strr {...} strr
	regsub -all -nocase -- {&#x301;} $strr {'} strr

	set token [::htmlparse::mapEscapes $strr]
	::htmlparse::2tree $token $pTree
	::htmlparse::removeFormDefs $pTree
  
	set path {}; set nn 1

	$pTree walk root -order post n {
			TransTree $pTree $n
	}
	$pTree destroy
	if {![info exists head]} {return 0}

	$curTree insert root end head
	$curTree set head data $head

	return yes
	}

	proc TransTree {tree node} {
  		variable curTree
  		upvar 1 path curPath
  		upvar 1 nn tNode
  		if {$node eq "root" || $node eq "head"} { return }

  		if {[$tree get $node type] eq "PCDATA"} {
    		set data [$tree get $node data]
    		set depth [$tree depth $node]
    		switch -exact -- $depth {
      		3 {
				$curTree insert root end $tNode
     			$curTree set $tNode type "VARIANT"
    			$curTree set $tNode data $data
     			set curPath $tNode
    			incr tNode
      			}
      		4 - 5 {
        		$curTree insert [lindex $curPath 0] end $tNode
        		$curTree set $tNode type [expr {$depth == 4 ? "INTERPR" : "CONTEXT"}]
        		$curTree set $tNode data $data
        			if {[llength $curPath] == 1} {
          			lappend curPath $tNode
        			} {
         			 set curPath [lreplace $curPath 1 end $tNode]
        			}
        		incr tNode
      			}
      		6 {
        		$curTree insert [lindex $curPath end] end $tNode
        		$curTree set $tNode type "INTERPR"
        		$curTree set $tNode data $data
        		incr tNode
      			}
    		} ;# switch ...
  		}
	}

#--����� � ��������� ����� ������ � ��������� �� ������
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

#---add-to-queue
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

#---proxy
	proc queue_proxy { url } {
		variable proxy
		if { $proxy ne {} } { return [split $proxy {:}] }		
		return [list]
	}
	
#---callback
	proc queue_done { token } {
		upvar #0 $token state
		variable reqqueue
		variable maxredir
		variable fetchurl
	
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
						if {[string match "*lingvo*yandex*ru*" $meta(Location)]} {
							set errid "wredir" ; set errstr  "Wrong redir."
							$parser {errid} {errstr} {state(body)} {extra} ; break
						} {
							queue_add "$fetchurl$meta(Location)" $id $parser $extra [incr redir] ; putlog "redir: $fetchurl$meta(Location)" ; break
						}
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











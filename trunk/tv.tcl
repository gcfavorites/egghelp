# tv.tcl 3.0
# ������������� Rambler
#
# �������: anaesthesia <elenium@bonbon.net>
# �� ������� tv.tcl �� Drakon_ <drakon@eggdrop.org.ru>
# *** ������ ��� egglib
# ������� - irc: anaesthesia#eggdrop@Rusnet
# 
#####################################################################################
# ������ 3.0 - �������� ����� ��������
# !tv +������ ������
# ������ 2.5 - ���������� ����������� ��� ���������, ��������� ������, ��������� ����� ���, ����������� suzi patch � �.�
# - ��������� ������� ������ ������� ������������� ����� �������
# !tv <�����> [���� ������] [hh] [hh]
# ������: !�� ��� �� 18 2 (��������� ��� �� ����� � 18:00 �� 02:00)
# - ���� ������ ��������� ����, �� ��������� ��������� �� ��������� ���� ��������� ������
# - ����� ��������� ����� ������ � ����� ������� (� �����)
# ��� ����������� ���������������� ������� ����� ���������� egglib_pub.tcl ������ 1.5.3a
#
if { ![info exists egglib(ver)] || [string first $egglib(ver) "1.53a"] != 0 } {
	putlog "***********************************************"
	putlog "             egglib_pub �� ������� !"
	putlog "  �e�������� ���������� egglib_pub ������ 1.53�"
	putlog "  http://eggdrop.org.ru/scripts/egglib_pub.zip"
	putlog "***********************************************"	
	return
}

namespace eval tv {
foreach bnd [binds ::tv::*] {catch {unbind [lindex $bnd 0] [lindex $bnd 1] [lindex $bnd 2] [lindex $bnd 4]}}
foreach clr [array names tv *] {catch {unset tv($clr) } }

variable tv
# --- ��������� ---
# ���� ��������� ������� ( ���������� ������ �� ������: .chanset #����� +tv )
set tv(flag)			"tv"
# ��� �������
set tv(binds)			"�� tv"
# ������� �������
set tv(prefix)			"!"
# ������������ �� ������ (1 - ��, 0 - ���)
set tv(use_proxy) 		0
# ��������� ������
set tv(proxy_host) 		"proxy1.bezeqint.net"
set tv(proxy_port)		3128
# ������� ���������� (� ��������)
set tv(timeout) 		30
# �������� (� ��������)
set tv(timer) 			30
# ���� �������� ������
set tv(c_n)				"\00310"
# ���� ��������� �� �������
set tv(c_e)				"\00304"
# ���� ������� �������������
set tv(c_v)				"\00305"
# ���� ������ �������������
set tv(c_t)				"\00307"
# ���� ������ �������
set tv(c_a)				"\00314"
# ������� ����� �������� ������� � ���������� (� �����)
set tv(offset)			"+0"
# ����� ������������ ������������� �� ����� ���� (� �����)
set tv(newday)			"+6"
# ����������
# "�������� ���������,�������� ����������,�������� ������,����� ������"
set tv(pchan) {
"ort,���,������ �����,1"
"rtr,���,������,2"
"tvc,���,���,3"
"ntv,���,���,4"
"kult,��������,��������,5"
"sport,�����,�����,235"
"tvm,3�����,3 �����,7"
"tnt,���,���,101"
"dom,��������,��������,102"
"ren,�����,�����,103"
"ctc,���,���-������,104"
"tv3,��3,��3,105"
"mtv,���,MTV,107"
"muz,�����,�����,108"
"dtv,���,���,109"
"7tv,7��,7��,209"
"school,��������,��������,272"
"zvezda,������,������,330"
"2x2,2�2,2�2,276"
"o2tv,�2��,O2TV,369"
"planeta,�������,������� ��������,214"
"romanti,���������,���������,213"
"detsk,�������,������� ���,216"
"cnn,cnn,CNN,221"
"disco,���������,Discovery Russia,226"
"extreme,�������,Extreme Sports,259"
"sport_online,�����_������,����� ��-����,207"
"footbal,������,������,205"
"eurosport,���������,���������,206"
"ntv+sport,���+�����,���+�����,204"
"nba,nba,NBA,454"
}

# --- ����� ����� ������ �� ������ ---

set tv(agent) 			"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; .NET CLR 1.1.4322; .NET CLR 1.0.3705)"
set tv(days)			{"����������� ��" "������� ��" "����� ��" "������� ��" "������� ��" "������� ��" "����������� ��"}
setudef flag $tv(flag)
foreach bind [split $tv(binds)] {
	bind pub - $tv(prefix)$bind ::tv::pubtv
	bind msg - $tv(prefix)$bind ::tv::msgtv
}

} ;#ns

proc ::tv::pubtv {n uh h c args} {
variable tv
	if {![channel get $c $tv(flag)]} { return }
	if { [llength [split [lindex $args 0] ] ] > 1 || [llength [split [lindex $args 0] ] ] == 0 } { set args [split [lindex $args 0]] }
	::tv::tv $n $uh $h $c $args
}

proc ::tv::msgtv {n uh h args} {
	if { [llength [split [lindex $args 0] ] ] > 1 || [llength [split [lindex $args 0] ] ] == 0 } { set args [split [lindex $args 0]] }
	::tv::tv $n $uh $h $n $args
}

proc ::tv::tv {n uh h c i} {
variable tv

	set tvtimer [utimers]
 		foreach line $tvtimer {
 			if {"::tv::tv:reset $uh" == [lindex $line 1]} { set tv(time) [lindex $line 0] }
 		}
 	if { [info exists tv(host,$uh)] } {  
 		if {$tv(timer) > 0} { putserv "NOTICE $n :�� ������� ������������ ������� $tv(prefix)[lindex $tv(binds) 0] ����� [::egglib::rus_duration [duration $tv(time)]]"
 		return
 		}
 	}
	
	set tv(host,$uh) 1
	set tv(timer,$uh) [utimer $tv(timer) [list ::tv::tv:reset $uh ] ]

		if {[llength $i] == 0} { 
			::tv::tv:usage $n $c
			return 
		}

	set ptime [expr [clock seconds] - ($tv(offset) * 60 * 60) - ($tv(newday) * 60 * 60) ]

	if {[string first "+" $i] == 0} {
		set po [string map {" " "+"} $i]
		set url "http://p-search.rambler.ru/srch?set=telek&where=15&st_date=[clock format $ptime -format "%d.%m.%Y"]&words=$po"
		set psearch 1
		set pr 0
		set zag ""
		set stime ""
		set etime ""
	} else {
		set po [lindex $i 0]
		set psearch 0
		set pr 0

	if {[lindex $i 1] != ""} {
		if { [lsearch -regexp $tv(days) (?i)[lindex $i 1]] >= 0 } {
			set day [expr [lsearch -glob [::egglib::tolower $tv(days)] "*[::egglib::tolower [lindex $i 1]]*"] + 1]
		} else {
			set day [clock format $ptime -format "%u"]
		}
			if { $day < [clock format $ptime -format "%u"]} { 
				set ploct [expr {$ptime - ([clock format $ptime -format "%u"] - $day - 7) * (60 * 60 * 24)}]
			} else {
				set ploct [expr {$ptime - ([clock format $ptime -format "%u"] - $day) * (60 * 60 * 24)}]
			}
		set aday [lindex [ lindex $tv(days) [expr {$day - 1}] ] 0]
	} else {
		set day [clock format $ptime -format "%u"]
		set ploct $ptime
		set aday [lindex [ lindex $tv(days) [expr {$day - 1}] ] 0]
	}

		set stime ""
		set etime ""
		if { [regexp -- {(\d{1,2})\s+(\d{0,2})$} $i -> stime etime]} {
			if {$stime >= 0 && $stime <= 23} {
				set stime [scan $stime %d]
			} else {
 				::egglib::out $n $n "$tv(c_e)����� ������ ������� ������ ���� � �������� 00 - 23\003"
				return
			}
			if {$etime != ""} {
 				if {$etime >= 0 && $etime <= 23} {
					set etime [scan $etime %d]
				} else {
					::egglib::out $n $n "$tv(c_e)����� ����� ������� ������ ���� � �������� 00 - 23\003"
					return
				}
			}
		}

		foreach ipr $tv(pchan) {
			if {[string match -nocase "*[lindex [split $ipr ","] 0]*" $po] || [string match -nocase "*[lindex [split $ipr ","] 1]*" $po]} {
				set pr [lindex [split $ipr ","] end]
				set zag "$tv(c_n)��������� ����������� ��$tv(c_v) [clock format $ploct -format "%d.%m.%y"]$tv(c_n) :: $aday :: $tv(c_e)[lindex [split $ipr ","] 2]"
			}
		}

	if {$pr == 0} {
		::tv::tv:usage $n $c
		return
	}

	set url "http://tv.rambler.ru/index.html?d=[clock format $ploct -format "%Y-%m-%d"]&channel_id=$pr"
	}

	set id [::egglib::http_init "::tv::"]
	if { $tv(use_proxy) } { ::egglib::http_set_proxy $id $tv(proxy_host) $tv(proxy_port) }
	::egglib::http_set_timeout $id $tv(timeout)
	::egglib::http_set_agent $id $tv(agent)
  	::egglib::http_get $id $url [list $n $c $uh $pr $zag $stime $etime $psearch]
}

proc ::tv::on_data {id html n c uh pr zag stime etime psearch} {
variable tv

	::egglib::http_cleanup $id

	global sp_version
	if {[info exists sp_version]} {	
    	set html [encoding convertfrom cp1251 $html]
	}

	if {$psearch == 0} {

	regsub -all -- "\n|\r" $html {} html
	regsub -all -- "</tr>" $html "</tr>\n" html

	set html [split $html \n]

		foreach item $html {
			if {[regexp -nocase -- {<td[^>]*><font[^>]*><b>(.*?)<sup><u>(.*?)</u></sup>\ &ndash;\ (.*?)<sup><u>(.*?)</u></sup></b></font></td><td>&nbsp;</td><td width=[^>]*><font size=[^>]*>*[^>]*>(.*?)<nobr>} $item -> a b c d pn] } { 
				lappend tvp "$a $b $c $d [::egglib::unhtml $pn]"
   			} 
		}

	if { [info exist tvp] } {

	set t_len [llength $tvp]
	set s_prog [scan [lindex [split [lindex $tvp 0]] 0] %d]
	set e_prog [scan [lindex [split [lindex $tvp [expr $t_len - 1]]] 2] %d]

	if {$stime >= $s_prog} {
		for {set i 0} {$i <= $t_len} {incr i} {
			if { [scan [lindex [split [lindex $tvp $i]] 0] %d] >= $stime } {
				set s_start $i
				break 
			}
		}
	} else {
		for {set i $t_len} {$i >= 0} {set i [expr $i - 1]} {
			if { [scan [lindex [split [lindex $tvp [expr $i - 1]]] 0] %d] <= $stime } {
				set s_start $i
				break
			}
		}
	}

	if {$etime != ""} {
		if {$etime >= $s_prog} {
			for {set j $i} {$j <= $t_len} {incr j} {
				if { [scan [lindex [split [lindex $tvp $j]] 2] %d] >= $etime } {
					set s_end $j
					break
				}
			}
		} else {
			for {set j $t_len} {$j >= 0} {set j [expr $j - 1]} {
				if { [scan [lindex [split [lindex $tvp [expr $j - 1]]] 2] %d] <= $etime } {
					set s_end [expr $j - 1]
					set s_start [expr $s_start - 1]
					break 
				}
			}
		}
	} else {
		set s_end "end"
	}

		if {![info exist s_end]} {
			::egglib::out $n $n "$tv(c_e)������ �� ������� (�������� ��������� �������).\003"
			 return 
		}

	set tvp [lrange $tvp $s_start $s_end]

		if { [llength $tvp] > 0 } {
			::egglib::out $n $n $zag
			foreach item [string map {\" \\\"} $tvp] { ::egglib::out $n $n "$tv(c_v) [lindex $item 0]:[lindex $item 1] - [lindex $item 2]:[lindex $item 3] $tv(c_t) [join [lrange $item 4 end]]" }
		} else { 
			::egglib::out $n $n "$tv(c_e)������ �� ������� (�������� ��������� �������).\003"
			 return 
		}

	} else { 
			::egglib::out $n $n "$tv(c_e)������ �� ������� (�������� ����������� �������������).\003"
			 return 
	}

	} else {
#	�����

	if { [string match -nocase "*������� �� ������ ���������*" $html] } {
		::egglib::out $n $n "$tv(c_e)�� ������ ������� ������ �� �������.\003"
		return
	}
		regsub -all -- "\n|\r" $html { } html
		regsub -all -- "</a> <br><br>" $html "</a>\n" html

        regsub -all -- {<b>} $html "\002" html
        regsub -all -- {</b>} $html "\002" html
		regsub -all -- {&nbsp;} $html { } html
		regsub -all -- {&quot;} $html {"} html

	set html [split $html \n]
		foreach item $html {
			if {[regexp -nocase -- {<span class="sdata".*?>(.*?)</span>(.*?)\[<a.*?>(.*?)</a>\](.*?)���������} $item -> p_time p_desc p_chan p_ann]} {
        		regsub -all -- {<.*?>} $p_desc "" p_desc
        		regsub -all -- {<.*?>} $p_ann "" p_ann

				::egglib::out $n $n "$tv(c_v)[::tv::tv:sspace $p_time] $tv(c_e)\002\[ [::tv::tv:sspace $p_chan] \]\002 $tv(c_t)[::tv::tv:sspace $p_desc] $tv(c_a)\002*\002 [::tv::tv:sspace $p_ann] \003"
			}
		}
	}
}

proc ::tv::on_error {id n c uh} {
	::egglib::out $n $c "$tv(c_e)�� ���� ����������� � ��������.\003"
}

proc ::tv::tv:usage {n c} {
variable tv
	foreach ipr $tv(pchan) { lappend prlist [lindex [split $ipr ","] 1] }
	::egglib::out $n $c "$tv(c_e)$tv(prefix)[lindex $tv(binds) 0]$tv(c_n) <�������� ������> \[���� ������\] \[����� ��\] \[����� ��\] $tv(c_v)�� ��������� - ��������� �� �������. \002������:\002 $tv(c_e)$tv(prefix)[lindex $tv(binds) 0] ��� ������� 12 18\003"
	::egglib::out $n $c "$tv(c_v)\002�����:\002 $tv(c_e)$tv(prefix)[lindex $tv(binds) 0] $tv(c_n)\002\+\002������ ������ $tv(c_v)(����� ���� �� \002����\002 �������!) \002������:\002 $tv(c_e)$tv(prefix)[lindex $tv(binds) 0] +������\003"
	::egglib::out $n $c "$tv(c_v)\002������:\002$tv(c_n) [join $prlist "/"]\003"
	return
}

proc ::tv::tv:reset {uh} {
variable tv
	catch {killutimer $tv(timer,$uh)}
	catch {unset tv(timer,$uh)}
	catch {unset tv(host,$uh)}
}

proc ::tv::tv:sspace {strr} {
  	return [string trim [regsub -all {[\t\s]+} $strr { }]]
}

putlog ":: TV programm (Rambler) :: v3 by anaesthesia loaded."

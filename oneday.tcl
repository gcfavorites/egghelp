#----------------------------------------------------------------------------
# Oneday - ��������� ("���� ���� � �������") / ������� / ���������
# !oneday (!����) (!�������) <���> <���> <���������> <���������+> <��.��> <����>
# ���������:
# ��� - ��� ������� � ���� ����*
# ��� - ��� ��������� � ���� ����*
# (* �� ��������� ������� ����� ��������� $maxres (�� ��������� - 5) ����������� ��������� �����������)
# ��������� - ������� � ����������� ������ ����������
# ���������+ - ��������� � ������ �������� ����������
# ��-��-���� - ������� ���� (�� ��������� - �������). ��� ����� � �� ������ ;)
# ���� - ������
# ������ ��� ���������� (��� ������ � �����) ������� ��������� (����������� ��� �� ��������� ����)
#--- ������ ������� ��� eggdrop1.6.18+suzi_patch008, �� ������ ������������� �������� �����
#----------------------------------------------------------------------------
#--- ���������:
# v01.01 - �������� ����� ����
# v01.02 - ��������� �������� �� suzi_patch
# v01.03 - �������� ����� ������������ �������� ������� (����, ���������, ��� ��������)
# v01.50 - �������� ����� ���� (calend.ru), ������� !���� ���������
# v01.51 - ���������� ��������� ������ ��������� (������ ��������� ������� ������ �� ������)
# v01.52 - �������� �������� '���������+' (����� �������� ����������)
# v01.53 - ������� ������ ����������� ����������, ������ ������ ������ � ������� � ��������� �� ������
#----------------------------------------------------------------------------

package require Tcl 	8.4
package require http	2.5

namespace eval oneday {
foreach p [array names oneday *] { catch {unset oneday ($p) } }

#----------------------------------------------------------------------------
# ��������� ��������� ������������ (Suzi / http.tcl)
#----------------------------------------------------------------------------
	# �������� � ������������ �������, ������, ���� ��������� �����������
	variable author			"anaesthesia"
	variable version		"01.53"
	variable date			"30-mar-2008"

	# ��� ���������� ��� ������� ���������
	variable unamespace		[string range [namespace current] 2 end]

	# ������� ��� ��������� ������ (����� ���� ������ �������)
	variable pubprefix 		{!}
	variable pubflag		{-|-}

	# pubcmd:���_����������� "�������1 �������2 ..."
	# ������� � � ��������� ��������, ������ � ������� �������� ��������� ��������
	variable pub:oneday		"$unamespace ���� �������"

	# ���� ��� � ����, ��� ��������� ������
	variable msgprefix		{!}
	variable msgflag		{-|-}
	# ����� �� ������� ��� ��� ��������� �������
	variable msg:oneday		${pub:oneday}

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
	# �����, � �������� ���������� ��������� ����������
	variable 		fetchurl		"http://www.km.ru"
	variable 		fetchurlc		"http://www.calend.ru"

	# ���������� ��������� �����������
	variable maxres		5

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

	proc sspace {strr} {
  		return [string trim [regsub -all {[\t\s]+} $strr { }]]
	}

	proc msg:oneday { unick uhost handle str } {
		pub:oneday $unick $uhost $handle $unick $str
		return
	}

	proc pub:oneday { unick uhost handle uchan str } {

		variable requserid
		variable fetchurl
		variable fetchurlc
		variable chflag
		variable flagactas
		variable errsend
		variable cityid		
		variable maxres
		variable pubprefix
		variable unamespace
		variable ttype
		variable oflag
		variable cflag
		variable cflagl

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
	set ustr [tolow $str]

#---����
	if { [regexp -- {(\d{1,2})[\s\,\.\-\/\\](\d{1,2})[\s\,\.\-\/\\](\d{2,4})} $str -> tdd tdm tdy] || [regexp -- {(\d{1,2})[\s\,\.\-\/\\](\d{1,2})} $str -> tdd tdm] } {
		if {[string length $tdd] < 2} {set $tdd "0$tdd"}
		if {$tdd < 1 || $tdd > 31} {set tdd [clock format [clock seconds] -format "%d"]}
		if {[string length $tdm] < 2} {set $tdm "0$tdm"}
		if {$tdm < 1 || $tdm > 12} {set tdm [clock format [clock seconds] -format "%m"]}
			if {[info exist tdy]} { if {[string length $tdy] == 2} {set tdy "20$tdy"} } else { set tdy [clock format [clock seconds] -format "%Y"] }
		set odate "?data=$tdd.$tdm.$tdy"
		set cdate "/holidays/$tdm-$tdd/"
		set oflag "����:"
		set cflag 1
	} else {
		set odate "?data=[clock format [clock seconds] -format "%d.%m.%Y"]"
		set cdate "/holidays/[clock format [clock seconds] -format "%m-%d"]/"
		set oflag "�������:"
		set cflag 0
	}
#---��� �������
	if 	{ [string match "*���*" $ustr] } { 
		set ttype "who" } elseif {
	 	  [string match "*���*" $ustr] } { 
		set ttype "day" } elseif {
	 	  [string match "*�����*" $ustr] || [string match "*���*" $ustr] } { 
				if { [string match "*+*" $ustr] } {
				set cflagl 1 } else {
				set cflagl 0 }
		set ttype "calend" } elseif {
		  [string match "*help*" $ustr] || [string match "*����*" $ustr] } {
			lput puthelp "������: $pubprefix$unamespace (!����) <���> <���> <���������> <����> <��.��.����>" $prefix
			lput puthelp "\002���\002 - ��� ������� � ���� ����\002*\002." $prefix
			lput puthelp "\002���\002 - ��� ��������� � ���� ����\002*\002." $prefix
			lput puthelp "\002���������\002 - ����������� ������ ����������." $prefix
			lput puthelp "\002���������+\002 - ����������� ������ ���������� � ���������." $prefix
			lput puthelp "\002��-��\002 - ������� ���� (�� ��������� - �������)." $prefix
			lput puthelp "(������� ���������� \002*\002 ������� $maxres ��������� ����������� ��� ������ �������." $prefix
			lput puthelp "������ ��� ���������� (��� ������ � �����) ������� ��������� (����������� ��� �� ��������� ����)" $prefix
			return } else {
		set ttype "ann"
		}
		
		variable logrequests

		if { $logrequests ne "" } {
			set logstr [subst -nocommands $logrequests]
			variable unamespace
			lput putlog $logstr "$unamespace: "
		}

		variable fetchurl		

		if { $ttype == "calend" } {
			set furl $fetchurlc	
			set odate $cdate
			::http::config -urlencoding cp1251 -useragent "Mozilla/5.0 (Windows; U; Windows NT 5.1; ru-RU; rv:1.8.1.1) Gecko/20061204 Firefox/2.0.0.1" 
		} else {
			set furl $fetchurl/oneday/index.asp
			::http::config -urlencoding cp1251 -useragent "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; 240x320)"	
		}

		if { [queue_add "$furl$odate" $id "[namespace current]::dream:parser" [list $unick $uhost $uchan {}]] } {
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
		variable useurl
		variable maxres
		variable ttype
		variable oflag
		variable cflag
		variable cflagl

		foreach { unick uhost uchan ustr } $lextra { break }

		if { $lerrid ne {ok} } {
			lput putserv [subst -nocommands $err_fail] [subst -nocommands $errsend]
			return
		}

		if { $uchan eq $unick } {
			set prefix [subst -nocommands $msgsend]
		} else {
			set prefix [subst -nocommands $pubsend]
		}
#--suzi-patch
	global sp_version
	if {[info exists sp_version]} {	
		set str [encoding convertfrom cp1251 $lbody] 
		} else {
		set str $lbody
		}

#----------------------------------------------------------------------------
##---parser-specific------
#----------------------------------------------------------------------------
	if {$ttype == "calend"} {
#---calend.ru(����)-------------
	if {$cflag} {
#---����(����)
		regexp -nocase -- {<h1>(.*?)</h1>} $str -> ddate
		lput putserv "$oflag \037[lrange [split $ddate " "] 0 1]\037" $prefix
	} else {
#---����(�������)
		if { [regexp -- {<div class=segodnya-date>(.*?)</div>} $str -> cday] } {
		regsub -all -- "&nbsp;" $cday { } cday
		regsub -all -- "\n|\r" $cday {} cday
		regsub -all -- "<.*?>" $cday {} cday
		lput putserv "$oflag \037[sspace $cday]\037" $prefix 
		}
	}
		set d_cal [list]
		set d_dimen [list]

	#regexp -nocase -- {<h1>.*?</h1>(.*?)<td  class="sideblocks_area" valign="top"  >} $str -> dstr
	regexp -nocase -- {<h1>.*?</h1>(.*?)<!-- ����� ������� -->} $str -> dstr
 
		regsub -all -- "\n|\r" $dstr {} dstr
		regsub -all -- "</table>" $dstr "\n" dstr

		foreach line [split $dstr \n] {
#--�������
			if { [regexp -nocase -- {<a href=.*?names.*?class=".*?" >(.*?)</a>} $line match dimen] } {
			regsub -all -- "<.*?>" $dimen {} dimen
			lappend d_dimen "[sspace $dimen]"			
			}
#---��������-��������
			if { [regexp -nocase -- {<a href=.*?holidays.*?class=".*?" >(.*?)</a>} $line match dname] } {
			regsub -all -- "<.*?>" $dname {} dname
#			lappend d_cal "\002*\002 $dname "
#---��������-���
					set subctype [list]
				foreach {full subctype} [regexp -all -nocase -inline -- {<img src=/img/.*?title=\'(.*?)\'.*?>} $line ] {			
					if {![string match "*��������*" $subctype] && ![string match "*$dname*" $subctype]} {lappend d_cal "\[$subctype\]"} {lappend d_cal "\002::\002 \037$subctype\037"}	
				}
#---��������-��������
				if { [regexp -nocase -- {<font class="sm">(.*?)<div align=right>} $line match ddesc] } {
				regsub -all -- "<.*?>" $ddesc "" ddesc
#				regsub -all -- "\n|\r" $ddesc "" ddesc
					if {$cflagl} {
					lappend d_cal " \002::\002 [sconv [sspace $ddesc]]" "~"
					} else {
					lappend d_cal {~}
					}							
				}			
			}
		}
			lput putserv ":�������: [join $d_dimen ", "]" $prefix
			set d_tmp [split $d_cal "~"]
			foreach d_disp $d_tmp {
			lput putserv "[join $d_disp]" $prefix 
			}
return
	} else {
#---km.ru-------------
		set t_owho ""
		set t_odate ""
		set t_oann ""
#---����
		if { [regexp {<div class=h2_r2.*?>(.*?)</div>} $str -> tdate] } {
		regsub -all -- "&nbsp;" $tdate { } tdate
		regsub -all -- "\n|\r" $tdate {} tdate
		set tdate [lrange [split $tdate " "] 0 1]
			}
#---���������
		if { [regexp {<ul style=.*?>(.*?)</ul>} $str match oann] } {
			regsub -all -- "<li>" $oann "\002 * \002" oann
			regsub -all -- "<.*?>" $oann {} oann
			regsub -all -- "&nbsp;" $oann { } oann
			regsub -all -- "\n|\r|\t" $oann {} oann
				}
		if { [regexp {<span class=h3>(.*?)</span>.*?<div class=l><span class=t>(.*?)</span>} $str match oannhead oannlong] } {
			regsub -all -- "\n|\r|\t|<.*?>" $oannlong {} oannlong
			regsub -all -- "\n|\r|\t|<.*?>" $oannhead {} oannhead
				}
#---�������(�������)
		if { [regexp {<div class=h5>(.*?)</div>.*?<div class=l>(.*?)</div>.*?<div class=h5>(.*?)</div>.*?<div class=l>(.*?)</div>} $str match owhohead owholong odayhead odaylong] } {
			regsub -all -- "\n|\r|\t" $owhohead {} owhohead
			regsub -all -- "<.*?>" $owhohead {} owhohead
			regsub -all -- {\((\d+)\)} $owhohead (\002\\1\002) owhohead

			regsub -all -- "\n|\r|\t" $owholong {} owholong
			regsub -all -- "<.*?>" $owholong {} owholong

			regsub -all -- "\n|\r|\t" $odayhead {} odayhead
			regsub -all -- "<.*?>" $odayhead {} odayhead
			regsub -all -- {\((\d+)\)} $odayhead (\002\\1\002) odayhead

			regsub -all -- "\n|\r|\t" $odaylong {} odaylong
			regsub -all -- "<.*?>" $odaylong {} odaylong
				}

		regsub -all -- "\n|\r|\t" $str "" str
		regsub -all -- "</div>" $str "</div>\n" str

		foreach line [split $str \n] {
#---���-��������(���)
		if { [regexp {<div class=s><li>(.*?)</div>} $line match owho] } {
			regsub -all -- "<.*?>" $owho {} owho
			regsub -all -- "&nbsp;" $owho { } owho
			regsub -all -- "\t" $owho {} owho
			regsub -all -- {\((\d+)\)} $owho (\002\\1\002) owho
			lappend t_owho $owho
				}
#---����(���)
		if { [regexp {<div class=s><b>(.*?)</div>} $line match odate] } {
			regsub -all -- "</b>" $odate "\002" odate
			regsub -all -- "<.*?>" $odate {} odate
			regsub -all -- "&nbsp;" $odate { } odate
			regsub -all -- "\t" $odate {} odate
			lappend t_odate $odate
				}
									}
#---����� ��������

		if {$ttype == "who"} {
		lput putserv "$oflag \037$tdate\037. � ���� ���� ��������:" $prefix
		lput putserv "\002*\002 [sspace $owhohead] :: [sspace $owholong]" $prefix 

#---��������� maxres �����
			while {[llength $t_owho] > $maxres} {
				set t_rnd [expr round(rand() * [llength $t_owho]-1)]
				set t_owho [lreplace $t_owho $t_rnd $t_rnd]
			}
			foreach t_disp $t_owho {
			lput putserv "[sspace $t_disp]" $prefix 
									}
			return
		}
		if {$ttype == "day"} {
		lput putserv "$oflag \037$tdate\037. � ���� ����:" $prefix
		lput putserv "\002*\002 [sspace $odayhead] :: [sspace $odaylong]" $prefix 

			while {[llength $t_odate] > $maxres} {
				set t_rnd [expr round(rand() * [llength $t_odate]-1)]
				set t_odate [lreplace $t_odate $t_rnd $t_rnd]
			}
			foreach t_disp $t_odate {
			lput putserv "\002[sspace $t_disp]" $prefix 
									}
			return
		}
		if {$ttype == "ann"} {
			lput putserv "$oflag \037$tdate\037" $prefix
			lput putserv "\002*\002 [sspace $oannhead] :: [sspace $oannlong]" $prefix 
			lput putserv "[sspace $oann]" $prefix 
			return
		}
#---end
} ;#ttype
		return
}		
#----------------------------------------------------------------------------
##---ok------
#----------------------------------------------------------------------------

proc sconv {txt} {

set smaps {
&quot;     '     &apos;     \x27  &amp;      \x26  &lt;       \x3C   &gt;       \x3E  &nbsp;     \x20
&iexcl;    \xA1  &curren;   \xA4  &cent;     \xA2  &pound;    \xA3   &yen;      \xA5  &brvbar;   \xA6
&sect;     \xA7  &uml;      \xA8  &copy;     \xA9  &ordf;     \xAA   &laquo;    \xAB  &not;      \xAC
&shy;      \xAD  &reg;      \xAE  &macr;     \xAF  &deg;      \xB0   &plusmn;   \xB1  &sup2;     \xB2
&sup3;     \xB3  &acute;    \xB4  &micro;    \xB5  &para;     \xB6   &middot;   \xB7  &cedil;    \xB8
&sup1;     \xB9  &ordm;     \xBA  &raquo;    \xBB  &frac14;   \xBC   &frac12;   \xBD  &frac34;   \xBE
&iquest;   \xBF  &times;    \xD7  &divide;   \xF7  &Agrave;   \xC0   &Aacute;   \xC1  &Acirc;    \xC2
&Atilde;   \xC3  &Auml;     \xC4  &Aring;    \xC5  &AElig;    \xC6   &Ccedil;   \xC7  &Egrave;   \xC8
&Eacute;   \xC9  &Ecirc;    \xCA  &Euml;     \xCB  &Igrave;   \xCC   &Iacute;   \xCD  &Icirc;    \xCE
&Iuml;     \xCF  &ETH;      \xD0  &Ntilde;   \xD1  &Ograve;   \xD2   &Oacute;   \xD3  &Ocirc;    \xD4
&Otilde;   \xD5  &Ouml;     \xD6  &Oslash;   \xD8  &Ugrave;   \xD9   &Uacute;   \xDA  &Ucirc;    \xDB
&Uuml;     \xDC  &Yacute;   \xDD  &THORN;    \xDE  &szlig;    \xDF   &agrave;   \xE0  &aacute;   \xE1
&acirc;    \xE2  &atilde;   \xE3  &auml;     \xE4  &aring;    \xE5   &aelig;    \xE6  &ccedil;   \xE7
&egrave;   \xE8  &eacute;   \xE9  &ecirc;    \xEA  &euml;     \xEB   &igrave;   \xEC  &iacute;   \xED
&icirc;    \xEE  &iuml;     \xEF  &eth;      \xF0  &ntilde;   \xF1   &ograve;   \xF2  &oacute;   \xF3
&ocirc;    \xF4  &otilde;   \xF5  &ouml;     \xF6  &oslash;   \xF8   &ugrave;   \xF9  &uacute;   \xFA
&ucirc;    \xFB  &uuml;     \xFC  &yacute;   \xFD  &thorn;    \xFE   &yuml;     \xFF  &#8214;    ||
\"         '     &ldquo;    `     &rdquo;    '     <b>        ""     </b>       ""    <i>        ""
</i>       ""    <tr>       ""    </tr>      ""    </a>       ""     &ndash;    "-"   &mdash;    "-"
</table>   ""    </td>      ""    </span>    ""    &#275;     e      &#257;     a     &#772;     "-"
&#769;     '     <sup>      ""    </sup>     ""    </font>    ""     &#333;     o     &#34;      '
&#38;      &     &#91;      (     &#92;      /     &#93;      )      &#123;     (     &#125;     )
&#163;     �     &#168;     �     &#169;     �     &#171;     �      &#173;     �     &#174;     �
&#161;     �     &#191;     �     &#180;     �     &#183;     �      &#185;     �     &#187;     �
&#188;     �     &#189;     �     &#190;     �     &#192;     �      &#193;     �     &#194;     �
&#195;     �     &#196;     �     &#197;     �     &#198;     �      &#199;     �     &#200;     �
&#201;     �     &#202;     �     &#203;     �     &#204;     �      &#205;     �     &#206;     �
&#207;     �     &#208;     �     &#209;     �     &#210;     �      &#211;     �     &#212;     �
&#213;     �     &#214;     �     &#215;     �     &#216;     �      &#217;     �     &#218;     �
&#219;     �     &#220;     �     &#221;     �     &#222;     �      &#223;     �     &#224;     �
&#225;     �     &#226;     �     &#227;     �     &#228;     �      &#229;     �     &#230;     �
&#231;     �     &#232;     �     &#233;     �     &#234;     �      &#235;     �     &#236;     �
&#237;     �     &#238;     �     &#239;     �     &#240;     �      &#241;     �     &#242;     �
&#243;     �     &#244;     �     &#245;     �     &#246;     �      &#247;     �     &#248;     �
&#249;     �     &#250;     �     &#251;     �     &#252;     �      &#253;     �     &#254;     �
&#176;     �     &#8231;    �     &#716;     .     &#363;     u      &#299;     i     &#712;     '
&#596;     o     &#618;     i     </li>      ""    <cite>     ""     </cite>    ""    </ol>      ""
"<br />"   ""    <tt>       ""    </tt>      ""    &#147;     '      &#148;     '     <em>       ""
</em>      ""  <BLOCKQUOTE> ""  </BLOCKQUOTE> ""   &#146;     '      <dd>       ""    </dd>      ""
<dl>       ""    </dl>      ""    <dt>       ""    </dt>      ""     <ol>       ""    </p>       ""
&#331;     n     &#8212;    "-"   &#491;     Q     &#771;     ~      &#365;     u     <br/>      ""
<br>       ""    &#483;     "ae"  &#603;     e     <div>      ""     </div>     ""    <sub>      ""
</sub>     ""    &#8810;    "<<"  &#601;     e     &#375;     �      &#593;     a     &#650;     u
&#703;     c     <tbody>    ""    </tbody>   ""    \{         (     \}          ) 	&dagger; 	" ��. "
}
	return [string map -nocase $smaps $txt]
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











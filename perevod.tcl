#----------------------------------------------------------------------------
# Perevod 		-������������� ����������
# ���������:	.chanset #chan +perevod
# ������:		!tr [?] [-�����] [����]|[����1[*|-|@|#|%]����2] [+]<�����>
# ������:		!tr [����1[*|-|@|#|%]����2] - ������� ����/����
#				!tr [-�����] [����] [+]<�����> - ������� ���� ����� Yandex	
# 				!t  [-�����] [����] [+]<�����> - ������� ���� ����� Multitran
#				!ttt [�������] [����� �������� �������] <�����> - ������� ������ ����� Promt
#				!tt [+]<�����> - ������� ������ ����� Cognitive Translator
# �������:		anaesthesia #eggdrop@Rusnet
# �������:		http://egghelp.ru
#----------------------------------------------------------------------------
# �������: 
# * ���� + ����� ������ ��� ������� �������� ����������� �����
# !tr ����� (������� ����� ����� ������)
# !tr -2 +����� (+ ����� ������ - ����� � ����������, ����� ������ ������ ��������)
# !tr de ����� (������� �/�� �������� ����)
# !t +test (������� ����� ����� multitran � ������� ���������)
# !tt test (������� ����� ����� cognitive translator)
# !ttt re �������� �������� (������� ���� ����� promt)
# !ttt re (���� ����� ��� �������� ����������� - ��������� �������� �������� ��� ���������� ����������� ��������)
#
# ����������� ������: !tr ����1@#%-����2 <�����>
# * ������ �� �������� *-@#% ����� ����1 � ����2 ���������� ��� �����������, ��������
#   '!tr ru*en ����� ��� �����' - ������� ���� ����� promt (�������������� ������)
#   '!tr ru-en ����� ��� �����' - ������� ���� ����� google
#   '!tr ru@en ����� ��� �����' - ������� ���� ����� text.pro
#   '!tr ru#en ����� ��� �����' - ������� ���� ����� meta
#   '!tr ru%en �����' - ������� ���� ����� slovnik
# ������ ������: !tr ?	
#----------------------------------------------------------------------------
# v.1.51	- ����������� � ������� (����� ���������� � �.�)
# v.1.52	- ������ ������ �������
# v.1.53	- ��������� ������ � �������
# v.2.0		+ �������� ������� ����� translate.ru
#			+ �������� ������� ����� promt (���� ������� �������� ������ � Shrike ;)
# v.2.01	- ������������� �����������
# v.2.10	+ �������� ����� ��������� ������� ��� �������� ����� Promt, ��������� �������� � ��������� ������� ����������
# v.2.11	+ �������� ������ ������� �������� ����� promt (����������� ����� ������ �������� �������..)
# v.2.12	- ����������� � promt
# v.2.13	- ����������� � promt
# v.2.5		+ �������� ������� ����� Cognitive Translator
# v.2.51	- ��������� ������ Multitran 
# v.2.55	- ��������� ������ Yandex
# v.2.56	- ��������� ������� Google

package require Tcl 	8.5
package require http	2.7

namespace eval perevod {

#----------------------------------------------------------------------------
# ��������� ��������� ������������ (Suzi / http.tcl)
#----------------------------------------------------------------------------
	# �������� � ������������ �������, ������, ���� ��������� �����������
	variable author			"anaesthesia"
	variable version		"02.56"
	variable date			"01-Oct-2009"
	variable unamespace		[namespace tail [namespace current]]

#--�������� ���������
	# ������� ��� ��������� ������ (����� ���� ������ �������)
	variable pubprefix 		{!}
	variable pubflag		{-|-}

	# ������� ��� Promt
	variable bprm			{ttt} 
	# ������� ��� ����������
	variable bmtr			{t}
	# ������� ��� Cognitive Translator
	variable bcog			{tt}
	# �������� ������� ������
	variable ball			{tr}

	# ����� ����� ���������, � ������� ������� ������ ���������� ��� �������������, ������ 
	variable pause			10

#--����� ������ ���-���� ������������� ���� �� ��������� ��������� ����� ���� ��������

	# pubcmd:���_����������� "�������1 �������2 ..."
	# ������� � � ��������� ��������, ������ � ������� �������� ��������� ��������
	variable pub:perevod	"$ball $bmtr $bprm $bcog"

	# ���� ��� � ����, ��� ��������� ������
	variable msgprefix		${pubprefix}
	variable msgflag		{-|-}
	# ����� �� ������� ��� ��� ��������� �������
	variable msg:perevod	${pub:perevod}

	# ����� ��������� ��������� ��� ��������� �������, ������ � �������� ������� ������ ������
	# ��� ��������������� ����������  variable [pub|msg]:handler "string ..."

	# ����� �������������� ������������ ��� ���������� ��������
	# �������� $unick, $uhost, $uchan
	# ������� tcl ���������, ����������� ������������ ���������� id ��� ������������� �������.
	variable requserid		{$uhost}
	
	# ������������ ����� ��������� ���������� �������� ��� ������ id
	variable maxreqperuser	1

	# ������������ ����� ��������� ���������� ��������
	variable maxrequests	5
	
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
	variable maxredir		1
	
	# ������� ������� � �������������, �� ���� 30 ������
	variable timeout		30000

	# ��������� � �������� �������
	variable err_ok			{}

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
	# ���������� ��������� �����������
	variable maxres		5

	# �����, � �������� ���������� ��������� ����������
	variable 		furl1		"http://perevod.text.pro/"
	variable		furl2		"http://www.t.a.ua/"
	variable		furl3		"http://slovnyk.org.ua/"
	variable		furl4		"http://m.slovari.yandex.ru/"
	variable		furl5		"http://translate.google.com/translate_t"
	variable 		furl6		"http://www.translate.ru/forms/google_gadget/decode.aspx"
	variable 		furl61		"http://m.translate.ru/translator/result/"
	variable		furl7		"http://www.multitran.ru/c/m.exe"
	variable 		furl8		"http://cs.isa.ru:10000/lf/tpda.php?ef=0"

	# ������� ��������
	variable 		reqqueue
	array unset 	reqqueue

	# ��������� ����������
	variable 		laststamp
	array unset		laststamp 

#---body---

	proc msg:perevod {unick uhost handle str} {pub:perevod $unick $uhost $handle $unick $str ; return}

	proc pub:perevod {unick uhost handle uchan str} {
		variable furl1 ; variable furl2 ; variable furl3 ; variable furl4 ; variable furl5 ; variable furl6 ; variable furl61 ; variable furl7 ; variable furl8 ; variable fetchurl
		variable chflag ; variable flagactas ; 	variable pub:perevod ; variable bprm ; variable bmtr ; variable bcog
		variable errsend ; variable pubsend ; variable msgsend
		variable maxres ; variable pubprefix ; variable unamespace ; variable requserid
		variable type ; variable ya ; variable gt ; variable tru ; variable mtr ; variable mtrt ; variable gta ; variable mpage ; variable yfull ; variable dct7 ; variable pdicn ; variable lang ; variable ccog ; variable cexp
		variable query ; variable logrequests ; variable hdr

		set id [subst -noc $requserid]
		set prefix [subst -noc $msgsend]

		if {$unick ne $uchan} {if {![channel get $uchan $chflag] ^ $flagactas eq "no" } {return}}
		set why  [queue_isfreefor $id]
		if {$why != ""} {lput puthelp $why $prefix ; return}

#---���������

	set ustr $str
	set lng  [list en de nl es it zh ko no pt ru uk fr ja]
	set lni  [list "en (English)" "de (German)" "nl (Dutch; Flemish)" "es (Spanish; Castilian)" "it (Italian)" "zh (Chinese)" "ko (Korean)" "no (Norwegian)" "pt (Portuguese)" "ru (Russian)" "uk (Ukrainian)" "fr (French)" "ja (Japanese)"]
	set lng2 [list en de la pl ru uk fr]
	set lni2 [list Eng Ger Lat Pol Rus Ukr Fre]
	set lng3 [list en us be bg hu nl gr dk is es it lat lv lt mk de no pl pt ro ru sr sk sl uk fi fr hr cz sv eo ee]
	set lni3 [list en-gb en-us be-by bg-bg hu-hu nl-nl el-gr da-dk is-is es-es it-it la-va lv-lv lt-lt mk-mk de-de no-no pl-pl pt-pt ro-ro ru-ru sr-rs sk-sk sl-si uk-ua fi-fi fr-fr hr-hr cs-cz sv-se eo-xx et-ee]
	set lng4 [list de fr it es en uk ku la]
	set lni4 [list de-ru-de fr-ru-fr it-ru-it es-ru-es en-ru-en uk-ru ru-uk la-ru]
	set lng5 [list ? ar bg hr cz dk nl en fi fr de gr hi it ja no pl pt ro ru es sv ca tl iw lv lt sr sk sl uk af sq be hu id qa mk ms mt sw tr et sw th cy yi gl cn hi vi]
	set lni5 [list auto ar bg hr cs da nl en fi fr de el hi it ja no pl pt ro ru es sv ca tl iw lv lt sr sk sl uk af sq be hu id qa mk ms mt sw tr et sw th cy yi gl zh-CN hi vi]
	set lng6 [list en ru de fr sp it pl]
	set lni6 [list e r g f s i p]
	set lnp6 [list er re gr rg fr rf sr rs ir eg ge es se ep pe ef fe fs sf fg]
	set lng7 [list en de sp fr it du ee la af]
	set lni7 [list 1 3 5 4 23 24 26 27 31]
	array set dct7 {
    er {{�����-�������} {General} {����� �������} {Software} {����������� �����������} {Internet} {��������} {Automotive} {����������} {Banking} {���������� ����} {Business} {������� ���������������} {Games} {������������ ����} {Logistics} {���������} {Sport} {�����} {Travels} {�����������}}
    re {{������-����������} {General} {����� �������} {Software} {���������� �����������} {Internet} {��������} {Phrasebook} {�����������} {Automotive} {����������} {Business} {������� ���������������} {Logistics} {���������} {Travels} {�����������}}
    gr {{�������-�������} {General} {����� �������} {Software} {���������� �����������} {Internet} {��������} {Automotive} {����������} {Business} {������� ���������������} {Football} {������}}
    rg {{������-��������} {General} {����� �������} {Internet} {��������} {Business} {������� ���������������} {Football} {������}}
    fr {{����������-�������} {General} {����� �������} {Internet} {��������} {Business} {������� ���������������} {Perfumery} {����������} {Football} {������}}
    rf {{������-�����������} {General} {����� �������} {Internet} {��������} {Business} {������� ���������������}}
    sr {{��������-�������} {General} {����� �������}}
    rs {{������-���������} {General} {����� �������}}
    ir {{����������-�������} {General} {����� �������}}
    eg {{�����-��������} {General} {����� �������} {Software} {����������� �����������} {Business} {������� ���������������} {Football} {������}}
    ge {{�������-����������} {General} {����� �������} {Software} {����������� �����������} {Business} {������� ���������������} {Football} {������}}
    es {{�����-���������} {General} {����� �������}}
    se {{��������-����������} {General} {����� �������}}
    ef {{�����-�����������} {General} {����� �������}}
    fe {{����������-����������} {General} {����� �������}}
    ep {{�����-�������������} {General} {����� �������}}
    pe {{������������-����������} {General} {����� �������}}
    fg {{����������-��������} {General} {����� �������} {Football} {������}}
    gf {{�������-�����������} {General} {����� �������} {Football} {������}}
    fs {{����������-���������} {General} {����� �������}}
    sf {{��������-�����������} {General} {����� �������}}
    gs {{�������-���������} {General} {����� �������} {Football} {������}}
    sg {{��������-��������} {General} {����� �������} {Football} {������}}
    ie {{����������-����������} {General} {����� �������}}
	}
	set ya 0 ; set gt 0; set gta 0 ; set tru 0 ; set mtr 0 ; set ccog 0
	set query "" ; set hdr ""
	::http::config -urlencoding utf-8 -useragent "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; 240x320)"	

		if {[string trimleft $::lastbind $pubprefix] in $bmtr} {
			if {[string is space $ustr]} {lput putserv "\002������\002: ${pubprefix}[lindex ${bmtr} 0] \[����\] \[+\]<�����> :: \002�����\002: [join $lng7] :: \002en\002-����������, \002de\002-��������, \002fr\002-�����������, \002sp\002-���������, \002it\002-�����������, \002du\002-�����������, \002la\002-���������, \002ee\002-���������, \002af\002-���������" $prefix ; return}
			if {[regexp -- {^-(\d+)} $ustr -> mpage]} {regsub -- {-\d+\s+} $ustr "" ustr} {set mpage 1}
			if {[lindex [split $ustr] 0] ni $lng7} {set lang 1 ; set ustr [lindex [split $ustr] 0]} {set lang [lindex $lni7 [lsearch -exact $lng7 [lindex [split $ustr] 0]]] ; set ustr [lindex [split $ustr] 1]}
			if {[string first "+" $ustr] == 0} {regsub -- {\+} $ustr "" ustr; set mtrt 1} {set mtrt 0}
			set fetchurl "${furl7}?l1=$lang&s=[uenc ${ustr}]" ; set type 1 ; set mtr 1
		} elseif {[string trimleft $::lastbind $pubprefix] in $bcog} {
			if {[string is space $ustr]} {lput putserv "\002������\002: ${pubprefix}[lindex ${bcog} 0] \[+\]<�����/�����> :: ������� � ���������� �����" $prefix ; return}
			if {[string first "+" $ustr] == 0} {regsub -- {\+} $ustr "" ustr; set cexp 1} {set cexp 0}
			::http::config -urlencoding cp1251 -useragent "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; 240x320)"	
			set query [::http::formatQuery inputtext $ustr submit "Translate text"]
			set fetchurl ${furl8} ; set ccog 1 ; set type 0
		} elseif {[string trimleft $::lastbind $pubprefix] in $bprm} {
			if {[string is space $ustr]} {lput putserv "\002������\002: ${pubprefix}[lindex ${bprm} 0] \[�������\] \[����� �������� �������\] <����� ��� �����> :: \002�������\002: [join $lnp6] :: \002e\002-����������, \002r\002-�������, \002g\002-��������, \002f\002-�����������, \002s\002-���������, \002i\002-�����������, \002p\002-�������������" $prefix ; return}
			if {[lindex [split $ustr] 0] ni $lnp6} {
				if {[regexp -- {[�-��-߸�]} $ustr]} {set lang "re"} {set lang "er"}
				if {[string is digit [lindex [split $ustr] 0]]} {
					set pdic  [lindex $dct7($lang) [expr {[lindex [split $ustr] 0] * 2 - 1}]] ; set pdicn [lindex $dct7($lang) [expr {[lindex [split $ustr] 0] * 2}]]
	 				set ustr [lrange [split $ustr] 1 end]	
				} {set pdic [lindex $dct7($lang) 1] ; set pdicn [lindex $dct7($lang) 2]}
			} {
				set lang [lindex [split $ustr] 0]
					if {[string is space [lindex $ustr 1]]} {
						set dctn "" ; set dn 1 ; foreach {- n} [lrange $dct7($lang) 1 end] {append dctn "\002$dn\002-$n " ; incr dn}
						lput putserv "\037�������� ��������\037: $dctn" $prefix ; return
					}
					if {[string is digit [lindex [split $ustr] 1]]} {
						set pdic  [lindex $dct7($lang) [expr {[lindex [split $ustr] 1] * 2 - 1}]] ; set pdicn [lindex $dct7($lang) [expr {[lindex [split $ustr] 1] * 2}]]
						set ustr [lrange [split $ustr] 2 end]
					} {
						set pdic  [lindex $dct7($lang) 1] ; set pdicn [lindex $dct7($lang) 2]
	 					set ustr [lrange [split $ustr] 1 end]
					}
			}
			if {$pdic eq ""} {set pdic [lindex $dct7($lang) 1]}
#			set fetchurl "${furl61}?lang=ru&status=translate&template=$pdic&direction=${lang}&source=[uenc $ustr cp1251]" ; set type 1 ; set tru 1
			set fetchurl "${furl61}?text=[uenc $ustr utf-8]&dirCode=${lang}&asd=&kb1=&kb2=&kb3=&template=$pdic"  ; set type 1 ; set tru 1
			set hdr ""
#temp. promt
		} elseif {[regexp -nocase -- {^(.+?)@(.+?)\s(.+?)$} $ustr -> lang1 lang2 utxt]} {
			if {[lsearch -exact $lng $lang1] == -1 || [lsearch -exact $lng $lang2] == -1} {
				lput putserv "\037������� ������ ���� ��������\037. [join $lng]" $prefix
				return
			} {
				set lang1 [lindex $lni [lsearch -exact $lng $lang1]] ; set lang2 [lindex $lni [lsearch -exact $lng $lang2]]
				set utxt [string map {" " "+"} [string trim $utxt]]
				set query [::http::formatQuery tr_text $utxt lang1 $lang1 lang2 $lang2 submit submit]
				set fetchurl $furl1 ; set type 0
			}
		} elseif {[regexp -nocase -- {^(.+?)\*(.+?)\s(.+?)$} $ustr -> lang1 lang2 utxt]} {
			if {[lsearch -exact $lng6 $lang1] == -1 || [lsearch -exact $lng6 $lang2] == -1} {
				lput putserv "\037������� ������ ���� ��������\037. [join $lng6]" $prefix
				return
			} {
				set lang [lindex $lni6 [lsearch -exact $lng6 $lang1]][lindex $lni6 [lsearch -exact $lng6 $lang2]]
				set pdic  [lindex $dct7($lang) 1] ; set pdicn [lindex $dct7($lang) 2]
				if {$lang ni $lnp6} {lput putserv "\037����� ����������� �������� �� ��������������\037." $prefix ; return}
				set fetchurl "${furl6}?lang=ru&status=translate&template=general&FromGoogle=WeAreFromGoogle&link=&direction=${lang}&source=[uenc $utxt]" ; set type 1 ; set tru 1
#				set fetchurl "${furl61}?lang=ru&status=translate&template=$pdic&&direction=${lang}&source=[uenc $ustr cp1251]" ; set type 1 ; set tru 1
#temp. promt
			}
		} elseif {[regexp -nocase -- {^(.+?)-(.+?)\s(.+?)$} $ustr -> lang1 lang2 utxt]} {
			if {[lsearch -exact $lng5 $lang1] == -1 || [lsearch -exact $lng5 $lang2] == -1} {
				lput putserv "\037������� ������ ���� ��������\037. [join $lng5]" $prefix
				return
			} {
				set lang1 [lindex $lni5 [lsearch -exact $lng5 $lang1]] ; set lang2 [lindex $lni5 [lsearch -exact $lng5 $lang2]]
				set ustr $utxt
				if {$lang1 eq "auto"} {set gta 1} {set gta 0}
				::http::config -urlencoding utf-8 -useragent "Mozilla/6.0 (compatible;)"
				set query [::http::formatQuery text $utxt sl $lang1 tl $lang2 ie utf-8 submit Translate]	
				set fetchurl $furl5 ; set type 0 ; set gt 1
			}
		} elseif {[regexp -nocase -- {^(.+?)#(.+?)\s(.+?)$} $ustr -> lang1 lang2 utxt]} {
			if {[lsearch -exact $lng2 $lang1] == -1 || [lsearch -exact $lng2 $lang2] == -1} {
				lput putserv "\037������� ������ ���� ��������\037. [join $lng2]" $prefix
				return
			} {
				set lang1 [lindex $lni2 [lsearch -exact $lng2 $lang1]] ; set lang2 [lindex $lni2 [lsearch -exact $lng2 $lang2]]
				set ustr $utxt
				set utxt [string map {" " "+"} [string trim $utxt]]
				set query [::http::formatQuery from_language $lang1 to_language $lang2 text_to_translate $utxt translation_theme "**" submit [encoding convertto [encoding system] "���������"]]
				set fetchurl $furl2 ; set type 0 
			}
		} elseif {[regexp -nocase -- {^(.+?)%(.+?)\s(.+?)$} $ustr -> lang1 lang2 utxt]} {
			if {[lsearch -exact $lng3 $lang1] == -1 || [lsearch -exact $lng3 $lang2] == -1} {
				lput putserv "\037������� ������ ���� ��������\037. [join $lng3]" $prefix
				return
			} elseif {[llength [split [string trim $utxt]]] > 1} {
				lput putserv "\037� ���� ������ ����������� ������ \002����\002 �����\037." $prefix
				return
			} {
				set lang1 [lindex $lni3 [lsearch -exact $lng3 $lang1]] ; set lang2 [lindex $lni3 [lsearch -exact $lng3 $lang2]]
				set ustr $utxt
				set utxt [uenc [string trim $utxt]]
				set fsuff "fcgi-bin/dic.fcgi?hn=sel&translate=%D0%9F%D0%B5%D1%80%D0%B5%D0%B2%D0%B5%D1%81%D1%82%D0%B8&ul=ru-ru&il=$lang1&ol=$lang2&iw=$utxt"
				set fetchurl $furl3$fsuff ; set type 1
			}
		} {
			if {![string is space $ustr]} {
					if {[regexp -- {\?} $ustr]} {
						set prefix [subst -noc $errsend]
						lput puthelp "\002������� \037����\037 \[Promt\]\002: \002${pubprefix}[lindex ${pub:perevod} 0]\002 en\002\*\002ru <�����> \002:: �����\002: \002ru\002-�������, \002en\002-����������, \002de\002-��������, \002pl\002-��������, \002sp\002-���������, \002fr\002-�����������" $prefix		
						lput puthelp "\002������� \037����\037 \[Google\]\002: \002${pubprefix}[lindex ${pub:perevod} 0]\002 en\002\-\002ru <�����> \002:: �����\002: \002ru\002-�������, \002en\002-����������, \002ar\002-��������, \002bg\002-����������, \002hr\002-����������, \002cz\002-�������, \002dk\002-�������, \002nl\002-�����������, \002fi\002-�������, \002fr\002-�����������, \002de\002-��������, \002gr\002-���������, \002hi\002-�����, \002it\002-�����������, \002ja\002-��������, \002no\002-����������, \002pl\002-��������, \002pt\002-�������������, \002ro\002-���������, \002es\002-���������, \002sv\002-��������, \002ca\002-�����������, \002tl\002-������������, \002iw\002-�����, \002lv\002-����������, \002lt\002-���������, \002sr\002-��������, \002sk\002-���������, \002sl\002-����������, \002uk\002-����������" $prefix   
						lput puthelp "\002������� \037����\037 \[Textpro\]\002: \002${pubprefix}[lindex ${pub:perevod} 0]\002 en\002\@\002ru <�����> \002:: �����\002: \002ru\002-�������), \002uk\002-����������, \002en\002-����������, \002de\002-��������, \002nl\002-�����������, \002es\002-���������, \002it\002-�����������, \002no\002-����������, \002pt\002-�������������, \002fr\002-�����������, \002ja\002-��������, \002zh\002-���������, \002ko\002-���������" $prefix		
						lput puthelp "\002������� \037����\037 \[Meta\]\002: \002${pubprefix}[lindex ${pub:perevod} 0]\002 uk\002\#\002ru <�����> \002:: �����\002: \002ru\002-�������, \002uk\002-����������, \002en\002-����������, \002de\002-��������, \002pl\002-��������, \002la\002-����������, \002fr\002-�����������" $prefix		
						lput puthelp "\002������� \037����\037 \[Slovnik\]\002: \002${pubprefix}[lindex ${pub:perevod} 0]\002 de\002\%\002ru <�����> \002:: �����\002: \002ru\002-�������, \002uk\002-����������, \002be\002-�����������, \002en\002-����������, \002us\002-������������, \002bg\002-����������, \002hu\002-����������, \002nl\002-�����������, \002gr\002-���������, \002dk\002-�������, \002is\002-����������, \002es\002-���������, \002it\002-�����������, \002lv\002-���������, \002lt\002-���������, \002ee\002-���������, \002mk\002-�����������, \002de\002-��������, \002no\002-����������, \002pl\002-��������, \002pt\002-�������������, \002ro\002-���������, \002sr\002-��������, \002sk\002-���������, \002sl\002-����������, \002fi\002-�������, \002fr\002-�����������, \002hr\002-����������, \002cz\002-�������, \002sv\002-��������, \002lat\002-���������, \002eo\002-���������" $prefix
					return
					}
					if {[regexp -nocase -- {^-(\d+)} $ustr -> mpg]} {set mpage $mpg ; regsub -- {-\d+\s+} $ustr "" ustr} {set mpage 1}
					if {[regexp -- {\+} $ustr]} {set yfull 1 ; regsub -- {\+} $ustr "" ustr} {set yfull 0}
				if {[lsearch -exact $lng4 [lindex $ustr 0]] != -1} {set fetchurl "$furl4\search.xml?lang=[lindex $lni4 [lsearch -exact $lng4 [lindex $ustr 0]]]&text=[uenc [lindex $ustr 1]]&where=3"} {set fetchurl "$furl4\search.xml?lang=en-ru-en&text=[uenc [lindex $ustr 0]]&where=3"} ; set type 1 ; set ya 1
			} {
				if {$uchan eq $unick} {set prefix [subst -noc $errsend]} {set prefix [subst -noc $pubsend]}
				lput puthelp "\037������� ���� Yandex\037. \002������\002: \002${pubprefix}[lindex ${pub:perevod} 0]\002 \[\002-\002����� ����������\] \[����\] \[\002+\002\]<\037�����\037> :: \002�����\002: \002de\002-��������, \002fr\002-�����������, \002it\002-�����������, \002es\002-���������, \002en\002-���������� (\037�� ���������\037)" $prefix		
				lput puthelp "\037������� ���� Multitran\037. \002������\002: \002${pubprefix}[lindex ${bmtr} 0]\002 \[\002-\002����� ����������\] \[����\] \[\002+\002\]<\037�����\037> :: \002�����\002: \002de\002-��������, \002fr\002-�����������, \002it\002-�����������, \002sp\002-���������, \002du\002-�����������, \002la\002-���������, \002ee\002-���������, \002af\002-���������, \002en\002-���������� (\037�� ���������\037)" $prefix		
				lput puthelp "\037������� ���� Cognitive\037. \002������\002: \002${pubprefix}[lindex ${bcog} 0]\002 \[\002+\002\]<\037����� ��� �����\037> :: \002�����\002: ����������, �������" $prefix		
				lput puthelp "\037������� ���� Promt\037. \002������\002: \002${pubprefix}[lindex ${bprm} 0]\002 \[�������\] \[����� �������� �������\] <\037����� ��� �����\037> :: \002�������\002: [join $lnp6] :: \002�����\002: \002e\002-����������, \002r\002-�������, \002g\002-��������, \002f\002-�����������, \002s\002-���������, \002i\002-�����������, \002p\002-�������������" $prefix		
				lput puthelp "\002������\002: \002${pubprefix}[lindex ${pub:perevod} 0]\002 test :: \002${pubprefix}[lindex ${pub:perevod} 0]\002 -2 +test (\002+\002 ����� ������ - ����� � �������������) :: \002${pubprefix}[lindex ${bmtr} 0]\002 de ������ :: \002${pubprefix}[lindex ${bprm} 0]\002 rg �������� ��������" $prefix
				lput puthelp "\002����������� ������\002: \002${pubprefix}[lindex ${pub:perevod} 0]\002 ����1\002*-@#%\002����2 <�����> :: \002������ ������\002: \002${pubprefix}[lindex ${pub:perevod} 0]\002 \002?\002" $prefix		
			return
			}
		}
		if {$logrequests ne ""} {set logstr [subst -noc $logrequests] ; lput putlog $logstr "$unamespace: "}
		if {[queue_add "$fetchurl" $id "[namespace current]::perevod:parser" [list $unick $uhost $uchan $ustr]]} {variable err_ok ; if {$err_ok ne ""} {lput puthelp "$err_ok." $prefix}} {variable err_fail ; if {$err_fail ne ""} {lput puthelp "$err_fail" $prefix}}
#putlog "$fetchurl"
	return
	}

#---parser
	proc perevod:parser {errid errstr body extra} {
		upvar $errid lerrid $errstr lerrstr $body lbody $extra lextra
		variable err_fail ;variable pubsend ; variable msgsend ; variable errsend ; variable useurl ; variable maxres
		variable type ; variable ya ; variable gt ; variable tru ; variable mtr ; variable mtrt ; variable gta ; variable mpage ; variable yfull ; variable ccog ; variable cexp
		variable dct7 ; variable pdicn ; variable lang

		foreach {unick uhost uchan ustr} $lextra {break}
		if {$lerrid ne {ok}} {lput putserv [subst -noc $err_fail] [subst -noc $errsend] ; return}
		if {$uchan eq $unick} {set prefix [subst -noc $msgsend]} {set prefix [subst -noc $pubsend]}
		if {[info exists ::sp_version]} {if {$gt} {if {$gta} {set str [encoding convertfrom utf-8 $lbody]} {set str [encoding convertfrom utf-8 $lbody]}} {if {$mtr || $ccog} {set str [encoding convertfrom cp1251 $lbody]} {set str [encoding convertfrom utf-8 $lbody]}}} {set str $lbody}
		#if {[info exists ::sp_version]} {if {$gt} {if {$gta} {set str $lbody} {set str $lbody}} {if {$mtr || $ccog} {set str [encoding convertfrom cp1251 $lbody]} {set str [encoding convertfrom utf-8 $lbody]}}} {set str $lbody}

#----------------------------------------------------------------------------
##---parser-specific------
#----------------------------------------------------------------------------

	if {$gt} {
		regsub -all "&raquo;" $str "-" str
		if {![regexp -- {</td><td id=autotrans style="display: block">.*?</span>(.+?)</td></tr>} $str {} det]} {set det ""}
		if {![regexp -- {<div id=result_box.*?>(.+?)</div>} $str - res]} {set res ""}
		if {$res != ""} {lput putserv "\[ Google \] ::[sconv $det] :: [sconv ${res}]" $prefix} {lput putserv "\037������ ��������\037. :: $det" $prefix}
	} elseif {$mtr} {
		if {[regexp -- {<td width="10%">��������&nbsp;������:</td><td width="90%">(.*?)</td></tr>} $str -> repl]} {
			regsub -all -nocase -- {&nbsp;} $repl {} repl
			regsub -all -nocase -- {<.*?>} $repl {} repl
			lput putserv "\037�������� ������\037: [sconv [sspace $repl]]" $prefix
		return
		}
		regexp -nocase -- {</form>(.*?)<table border="0" width="100%" height="1">} $str -> str
		regsub -all -- "\n|\r|\t" $str "" str
		regsub -all -nocase -- {<td bgcolor="#DBDBDB" width="100%" colspan="2">} $str \n str
		set mtout [list] ; set cnt 0
			foreach mtl [split $str \n] {
				if {[regexp -nocase -- {<a href="m.exe\?a=.*?">(.*?)</a>.*?<em>(.*?)</em>.*?</td></tr><tr>(.*?)$} $mtl -> mword mtype mdat]} {
					regsub -all -nocase -- {<tr>} $mdat \n mdat
					set mword [string map -nocase {{<span STYLE="color:gray">} \00314 {<span STYLE="color:black">} \003} $mword]
					set mdout "" ; incr cnt
					foreach mdl [split $mdat \n] {
						if {[regexp -- {<td width="1%">.*?<a title="(.*?)".*?<i>(.*?)</i>(.*?)$} $mdl -> mdtype mdt mddat]} {
							if {$mtrt} {
								set mddat [string map -nocase {{<i>} \00315 {</i>} \003 {&nbsp;} {} {<span STYLE="color:gray">} \00314 {<span STYLE="color:black">} \003} $mddat]
								regsub -all -nocase -- {<.*?>} $mddat "" mddat
								append mdout " ($mdtype) $mddat ::"
							} {
								set mds ""
								foreach {- mdd} [regexp -all -inline -- {<a href="m.exe\?t=.*?">(.*?)</a>} $mddat] {append mds "$mdd; "}	
								append mdout "$mds"
							}	
						}
					}
				lappend mtout "\002$mword\002 - \00305$mtype\003 :: [string trimright $mdout " ::"]"
				}
			}
		if {$cnt > 0} {
			set mo [sconv [lindex $mtout [expr {$mpage - 1}]]]
			if {[string length $mo] > 380 && $uchan ne $unick} {lput putserv "\[ Multitran \] :: ������� ������� �������, ����� ��������� � ������." $prefix ; set prefix [subst -noc $msgsend]}
			lput putserv "\[ Multitran \] ($mpage/$cnt) :: $mo" $prefix
		} {lput putserv "\037������ ��������\037." $prefix}
	} elseif {$tru} {
		if {[regexp -- {<textarea name="lResult".*?>(.*?)</textarea>} $str -> res]} {
			set res [sconv [sspace $res]]
			if {![string is space $res]} {lput putserv "\[ Promt \] \([lindex $dct7($lang) 0] :: $pdicn\) \002::\002 [sconv [sspace "$res"]]" $prefix} {lput putserv "\037�� ������� ����� �������\037." $prefix}
		} elseif {[regexp -- {<div class="tres">(.*?)</div>} $str -> res]} {
			if {![string is space $res]} {lput putserv "\[ Promt \] \([lindex $dct7($lang) 0] / $pdicn\) :: [sconv [sspace [join $res]]]" $prefix} {lput putserv "\037�� ������� ����� �������\037." $prefix}
		} {lput putserv "\037������ ��������\037." $prefix}
	} elseif {$ya} {

		if {[string match -nocase "*��������� �������� ���������*" $str]} {
			regexp -nocase -- {<h2 class="b-title">(.*?)</h2><div class="info">(.*?)</div><div class="b-foot">} $str -> yword ysugg
			regsub -all -nocase -- {<p>} $ysugg " " ysugg
			regsub -all -nocase -- {<.*?>} $ysugg "" ysugg
			lput putserv "\002$yword\002 :: $ysugg" $prefix
		return
		}
	
		if {![regexp -nocase -- {<h2 class="b-title">(.*?)</h2><div class="info">(.*?)</div>} $str -> yword ydir]} {lput putserv "\037�� ������� ����� �������\037." $prefix ; return}
		regexp -- {<div class="res">(.*?)<div class="b-foot">} $str -> str
		regsub -all -- {(\d+)\)} $str "\002\\1\.\002" str
		regsub -all -- {<b>Syn:</b>} $str "\002\Syn:\002" str

		set str [sspace $str] ; set yres "" ; set cnt 0
		regsub -all -- "\n|\r|\t" $str {} str
		regsub -all -nocase -- {<b>I+\s</b>} $str "\n" str

		foreach ystr [split $str \n] {
			if {![string is space $ystr]} {incr cnt}
				if {$cnt == $mpage} {
					if {!$yfull} {regsub -all -nocase -- {<p class="m2">.*?</p>} $ystr "" ystr} {regsub -all -nocase -- {<p class="m2">(.*?)</p>} $ystr "\00314\\1\003" ystr}
					regsub -all -nocase -- {<I>(.*?)</I>} $ystr "\00314\\1\003" ystr
					regsub -all -nocase -- {<abbr title=".*?">(.*?)</abbr>} $ystr "\00305\\1\003 " ystr
					regsub -all -- "<.*?>" $ystr { } ystr
					set yres $ystr
				}
		}
		if {[string length $yres] > 380 && $uchan ne $unick} {lput putserv "\[ Yandex \] :: ������� ������� �������, ����� ��������� � ������." $prefix ; set prefix [subst -noc $msgsend]}
		if {$mpage <= $cnt} {lput putserv "\[ Yandex \] \($mpage/$cnt\) :: \00314[string map {"���������� " "" "." ""} $ydir]\003 :: \002[sconv $yword]\002 :: [sconv [sspace $yres]]" $prefix} {lput putserv "\037�������� ����� ����������\037. �����: $cnt" $prefix}
	} elseif {$ccog} {
	regsub -all -- "\n|\r|\t" $str "" str
	if {[regexp -- {<table><tbody>.*?<textarea rows=5 cols=32>(.*?)</textarea>.*?<textarea name="inputtext" rows=5 cols=32>(.*?)</textarea>} $str -> cin cdata]} {
		if {[regexp -- {<tr><td width=200>(.+?)</table></form>} $str -> cdop]} {
			regsub -all -nocase -- {<a href="#".*?>(.+?)</a>} $cdop " \002\\1\002 " cdop
			regsub -all -nocase -- {<div class="L1">(.+?)</div>} $cdop " \00314(\\1)\003 " cdop
			regsub -all -nocase -- {<div class=L2>(.+?)</div>} $cdop " \00305\\1\003 " cdop
			regsub -all -nocase -- {<div class=L3>(.+?)</div>} $cdop " \\1 " cdop
			regsub -all -nocase -- {<span class=g>(.+?)</span>} $cdop "\00303\\1\003" cdop
			regsub -all -nocase -- {<!-- hr -->} $cdop { :: } cdop
			regsub -all -- "<.*?>" $cdop " " cdop
		}
		regsub -all -- "<.*?>" $cdata " " cdata
		lput putserv "\[ Cognitive \] :: [sspace [sconv $cin]]" $prefix
		if {$cexp} {lput putserv [string trim [string trimright [sspace [sconv $cdop]] " :: "]] $prefix}
	} {lput putserv "\037�� ������� ���������\037." $prefix}
	} {
		set ostr "" ; set dic ""
		if {[regexp -nocase -- {<td class="alt2" width="50%" align="left" valign="top">(.*?)</tbody>} $str -> ostr]} {set dic "\[ Meta \]"}
		if {[regexp -nocase -- {<textarea id="translated_text_id" class="b_area">(.*?)</textarea>} $str -> ostr]} {set dic "\[ TextPro \]"}
		if {[regexp -nocase -- {<DT lang=.*?<INPUT maxlength="1024" name="iw" size="64" value="(.*?)" class="required">} $str -> ostr]} {set dic "\[ Slovnik \]"}
			regsub -all -- "\n|\t|\r" $ostr {} ostr
			regsub -all -nocase -- "<.*?>" $ostr {} ostr	
		if {![string is space $ostr]} {lput putserv "$dic :: [sconv [sspace $ostr]]" $prefix} {lput putserv "\037��� ��������\037." $prefix}
		if {[string is space $dic]} {lput putserv "\037�� ������� ���������\037: $ustr." $prefix}
	}

	return
	}		
#----------------------------------------------------------------------------
##---ok------
#----------------------------------------------------------------------------
	proc sspace {strr} {return [string trim [regsub -all {[\t\s]+} $strr { }]]}

	proc uenc {strr {enc {utf-8}}} {
	set str "" ; foreach byte [split [encoding convertto $enc $strr] ""] {scan $byte %c i ; if {[string match {[%<>"]} $byte] || $i < 65 || $i > 122} {append str [format %%%02X $i]} {append str $byte}}
	return [string map {%3A : %2D - %2E . %30 0 %31 1 %32 2 %33 3 %34 4 %35 5 %36 6 %37 7 %38 8 %39 9 \[ %5B \\ %5C \] %5D \^ %5E \_ %5F \` %60} $str]
    }

	proc sconv {strr} {
	set escapes {
        &nbsp; \x20 &quot; \x22 &amp; \x26 &apos; \x27 &ndash; \x2D
        &lt; \x3C &gt; \x3E &tilde; \x7E &euro; \x80 &iexcl; \xA1
        &cent; \xA2 &pound; \xA3 &curren; \xA4 &yen; \xA5 &brvbar; \xA6
        &sect; \xA7 &uml; \xA8 &copy; \xA9 &ordf; \xAA &laquo; \xAB
        &not; \xAC &shy; \xAD &reg; \xAE &hibar; \xAF &deg; \xB0
        &plusmn; \xB1 &sup2; \xB2 &sup3; \xB3 &acute; \xB4 &micro; \xB5
        &para; \xB6 &middot; \xB7 &cedil; \xB8 &sup1; \xB9 &ordm; \xBA
        &raquo; \xBB &frac14; \xBC &frac12; \xBD &frac34; \xBE &iquest; \xBF
        &Agrave; \xC0 &Aacute; \xC1 &Acirc; \xC2 &Atilde; \xC3 &Auml; \xC4
        &Aring; \xC5 &AElig; \xC6 &Ccedil; \xC7 &Egrave; \xC8 &Eacute; \xC9
        &Ecirc; \xCA &Euml; \xCB &Igrave; \xCC &Iacute; \xCD &Icirc; \xCE
        &Iuml; \xCF &ETH; \xD0 &Ntilde; \xD1 &Ograve; \xD2 &Oacute; \xD3
        &Ocirc; \xD4 &Otilde; \xD5 &Ouml; \xD6 &times; \xD7 &Oslash; \xD8
        &Ugrave; \xD9 &Uacute; \xDA &Ucirc; \xDB &Uuml; \xDC &Yacute; \xDD
        &THORN; \xDE &szlig; \xDF &agrave; \xE0 &aacute; \xE1 &acirc; \xE2
        &atilde; \xE3 &auml; \xE4 &aring; \xE5 &aelig; \xE6 &ccedil; \xE7
        &egrave; \xE8 &eacute; \xE9 &ecirc; \xEA &euml; \xEB &igrave; \xEC
        &iacute; \xED &icirc; \xEE &iuml; \xEF &eth; \xF0 &ntilde; \xF1
        &ograve; \xF2 &oacute; \xF3 &ocirc; \xF4 &otilde; \xF5 &ouml; \xF6
        &divide; \xF7 &oslash; \xF8 &ugrave; \xF9 &uacute; \xFA &ucirc; \xFB
        &uuml; \xFC &yacute; \xFD &thorn; \xFE &yuml; \xFF
	}
	set strr [string map {\[ \\\[ \] \\\] \( \\\( \) \\\) \{ \\\{ \} \\\} \\ \\\\} [string map $escapes [join [lrange [split $strr] 0 end]]]] 
  	regsub -all -- {&#([[:digit:]]{1,5});} $strr {[format %c [string trimleft "\1" "0"]]} strr
 	regsub -all -- {&#x([[:xdigit:]]{1,4});} $strr {[format %c [scan "\1" %x]]} strr
 	regsub -all -- {&#?[[:alnum:]]{2,7};} $strr "" strr
	return [subst -nov $strr]
	}

	proc lput {cmd str {prefix {}} {maxchunk 420}} {
	set buf1 ""; set buf2 [list]
		foreach word [split $str] {append buf1 " " $word ; if {[string length $buf1]-1 >= $maxchunk} {lappend buf2 [string range $buf1 1 end] ; set buf1 ""}}
		if {$buf1 != ""} {lappend buf2 [string range $buf1 1 end]}
		foreach line $buf2 {$cmd $prefix$line}

	return
	}

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

	proc queue_add {newurl id parser extra {redir 0}} {
		variable reqqueue ; variable proxy ; variable timeout ; variable laststamp ; variable query ; variable type ; variable hdr

		::http::config -proxyfilter "[namespace current]::queue_proxy"

	if {$type} {
		if {![catch {set token [::http::geturl $newurl -command [namespace current]::queue_done -binary true -timeout $timeout -headers $hdr]} errid]} {					
			set reqqueue($token,$id) [list $parser $extra $redir] ; set laststamp(stamp,$id) [unixtime]
		} {return false}
	} {
		if {![catch {set token [::http::geturl $newurl -command [namespace current]::queue_done -binary true -timeout $timeout -query $query]} errid]} {					
			set reqqueue($token,$id) [list $parser $extra $redir] ; set laststamp(stamp,$id) [unixtime]
		} {return false}
	}

	return true
	}

	proc queue_proxy {url} {
		variable proxy
		if {$proxy ne {}} {return [split $proxy {:}]}		
	return [list]
	}
	
	proc queue_done {token} {
		upvar #0 $token state
		variable reqqueue ; variable maxredir ; variable fetchurl
		
		set errid  [::http::status $token]
		set errstr [::http::error  $token]
		set	id [array  names reqqueue "$token,*"]
		foreach {parser extra redir} $reqqueue($id) {break}
		regsub -- "^$token," $id {} id
	
		while (1) {
			if {$errid == "ok" && [::http::ncode $token] == 302} {
				if {$redir < $maxredir} {			
					array set meta $state(meta)
					if {[info exists meta(Location)]} {queue_add "$fetchurl$meta(Location)" $id $parser $extra [incr redir] ; break}
				} {set errid "error" ; set errstr  "Maxi. redir."}
			} 
			
			if {[catch {$parser {errid} {errstr} {state(body)} {extra}} errid]} {lput putlog $errid "[namespace current] "}
		break
		}
		array unset reqqueue "$token,*"
		::http::cleanup $token

	return
	}

	proc queue_clear_stamps {} {
		variable laststamp ; variable timeout ; variable timerID

		set curr [expr {[unixtime] - 2 * $timeout / 1000}];
		foreach {id} [array names laststamp] {if {$laststamp($id) < $curr} {array unset laststamp $id}}		
		set timerID [timer 10 "[info level 0]"]
	}

	proc cmdaliases {{action {bind}}} {
		foreach {bindtype} {pub msg dcc} {
			foreach {bindproc} [info vars "[namespace current]::${bindtype}:*"] {
				variable "${bindtype}prefix" ; variable "${bindtype}flag"			
				foreach {alias} [set $bindproc] {catch {$action $bindtype [set ${bindtype}flag] [set ${bindtype}prefix]$alias $bindproc}}				
			}
		}
		
	return
	}
#--init
	if {[info exists timerID]} {catch {killtimer $timerID} ; catch {unset timerID}}	
	[namespace current]::queue_clear_stamps
	foreach bind [binds "[namespace current]::*"] {catch {unbind [lindex $bind 0] [lindex $bind 1] [lindex $bind 2] [lindex $bind 4]}}
	[namespace current]::cmdaliases
	putlog "[namespace current] v$version [expr {[info exists ::sp_version]?"(suzi_$::sp_version)":""}] :: file:[lindex [split [info script] "/"] end] / rel:\[$date\] / mod:\[[clock format [file mtime [info script]] -format "%d-%b-%Y : %H:%M:%S"]\] :: by $author :: loaded."

} ;#end perevod











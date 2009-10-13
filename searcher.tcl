#----------------------------------------------------------------------------
# Searcher 		- ����� �� Yandex / Google / Youtube / Gogo / Wikipedia / Bing
# * ������ ���������� xml-������ ����������� ������, ������� �� ������� �� ��������� � ������� ������
# ���������:	.chanset #chan +searcher
# ������:		!y   [-�����] [img:|���:|sp:|����:] <������> - ����� � �������
# 				!ya  [-�����] [img:|���:|sp:|����:] <������> - ����� � ������� (����������� ������ ������)
# 				!yy  [-�����] [img:|���:] <������> - ����� � ������� (������������� ������ ������)
#				!go  [-�����] [img:|video:][site:<����>] <������> - ����� � Gogo.ru		
#				!goo [-�����] [img:|video:][site:<����>] <������> - ����� � Gogo.ru	(������������� ������ ������)	
#					 *	������������: img: - ����� ��������, video: - ����� �����, site: - ����� ������ �����
#				!g   [-�����] [img:|video:|news:|blog:|local:|spell:|tr:����1-����2][site:<����>] <������> - ����� � Google		
#				!gg  [-�����] [img:|video:|news:|blog:|local:][site:<����>] <������> - ����� � Google (������������� ������ ������)		
#					 *	����������� video: ����� ��������� ����������� ����������: -rate (�������) -view (���������) -pop (����������) -fav (��������) -comm (�����������)
#						��������: !g video:-rate ������� $maxres (3) ����� ����������� �����
#					 *	����������� img: ����� ��������� ����������� ����������: ++ (������� ��������), +++ (����� ������� ��������), +face (����� ���), +photo (����� ����������), +clip (��������), +line (�������)
#						��������: !g img:������ +face ++ ������� ������� ���������� �������
#				!yt  [-�����] <������> - ����� � Youtube (������ !gg video:)
#				!ytt [-�����] <������> - ����� � Youtube (������������� ������ ������)
#				!wkp [-��������] [-?] [.����] [+]<������[#�����]> - ����� � ��������� (���� �� ��������� - .ru, �������� '-�����' - ����� ��������, '-?' - ����������, '+' - ����� ���������)
#				!gbs [-�����] <������> - ����� � Google Base
#				!b   [-�����] [img:|video:|news:|ans:|phone:|spell|tr:����1-����2] <������> - ����� � Bing		
#				!bb   [-�����] [img:|video:|news:|ans:|phone:] <������> - ����� � Bing (������������� ������ ������)		
#
# �������:		!go img:putin ��� !go -2 site:zhurnal.lib.ru ������
#				!gg -2 news:��������� ��� !g video:boney m
#				!ya -2 ������ ��������� �������
#				!yt -rate ��� !yt ufo
#				!wkp -2 ������#�������
#
# �������:		anaesthesia #eggdrop@Rusnet
# �������:		http://weird.42-club.ru/tcl-skripty/
#----------------------------------------------------------------------------
# ����������: 	Tcl ������ �� ���� 8.5
#				eggdrop 1.6.18 / suzi patch
# * ��� ������������� ������ � ������� ������������ ���������� ���������������� IP-����� ���� �� http://xml.yandex.ru/ip.xml
# * ��������� ������������ ����� ������� � ��������� ����, ����� ��� ���������� ������� �� ����� ������������ ���������
#   ��� ����� �������� � �������� �� �������� ���� searcher.set � ������� ������� ����������� ��������� �� ������� "��������� ��������� ������������"
#
# v2.0			! ������ ��������� �����
# v2.01			% �������� ��������� ���� ��� Youtube, ������ �����������
# v2.1			+ �������� ����� �� ���������
# v2.12			% ���������� ������ � Google search � ��������� ������������� ��������, ��������� �������������� ������� ������ ������
# v2.13			+ �������� ����� � Google Base (����� ������� � ���)
# v2.15			+ �������� ����� ������������ ���������� ����������� ������ (������������� �����, ���������� ������� ��� Yandex, Google, GoGo, Youtube � Bing)
# v2.16			% ����������� � Youtube � Wikipedia
# v2.17			+ �������� ����� ������� � ���� �������� � ������ ����������� Google
# v2.2			+ �������� ����� �� Bing
# v2.21 		+ ��������� �������� ���������� ������ (!y sp:����� ��� !ys) � Google (!g sp:����� ��� !gs) ( * ��� ����� ����� package tls)
# v2.22			+ �������� ������� ����� Google
# v2.23			+ �������� ����� �� ������������� ������

package require Tcl		8.5
package require http	2.7

namespace eval searcher {

	# �������� � ������������ �������, ������, ���� ��������� �����������
	variable author			"anaesthesia"
	variable version		"02.23-public"
	variable date			"07-Oct-2009"
	variable unamespace		[namespace tail [namespace current]]

#----------------------------------------------------------------------------
# ��������� ��������� ������������
#----------------------------------------------------------------------------
	# ������� ��� ������ (����� ���� ������ �������)
	variable pubprefix 		{!}
	variable pubflag		{-|-}

	# ������� ������ (�����)
	# ������ (������� �����)
	variable bya 			"y"
	# ������ (������ �����)
	variable byaf			"ya"
	# ������ (������������� �����)
	variable byal			"yy"
	# ������ (����������)
	variable byao			"ys"
	# Gogo.ru
	variable bgogo			"go"
	# Gogo.ru (������������� �����)
	variable bgogol			"goo"
	# Google
	variable bgoog			"g"
	# Google (������������� �����)
	variable bgoogl			"gg"
	# Google (����������)
	variable bgoogo			"gs"
	# Google Base
	variable bbase			"gbs"
	# Youtube
	variable byt			"yt"
	# Youtube (������������� �����)
	variable bytl			"ytt"
	# Wiki
	variable bwiki			"wkp"
	# Bing
	variable bbing			"b bing"
	# Bing (������������� �����)
	variable bbingl			"bb"

	# �������������� ���� (�������� ������ ������������ api ������ �� ���� 1.3)
	# ������: bind {url}
	variable altwiki
	array set altwiki		{
							abs {absurdopedia.wikia.com}
							egg {wiki.egghelp.ru}
							lm {lurkmore.ru}
							}

	# ������������� ����� (����� �� ����������� �����)
	# ������: bind {url}
	variable altsite
	array set altsite		{
							u {packages.ubuntu.com}
							deb {getdeb.net}
							}


	# ���������� ��������� ����������� (�� ������������� ������� ����� 5)
	variable maxres			3

	# ����� ����� ���������, � ������� ������� ������ ���������� ��� �������������, ������ 
	variable pause			5

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
	variable msgprefix		${pubprefix}
	variable msgflag		${pubflag}

	# pubcmd:���_����������� "�������1 �������2 ..."
	# ������� � � ��������� ��������, ������ � ������� �������� ��������� ��������
	variable pub:searcher		"$bya $byaf $byal $byao $bgogo $bgogol $bgoog $bgoogl $bgoogo $byt $bytl $bbase $bbing $bbingl $bwiki [array names altwiki] [array names altsite]"

	# ����� �� ������� ��� ��� ��������� �������
	variable msg:searcher	${pub:searcher}

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
	
	# ����� ������-�������
	# ������ ���� "proxyhost.dom:proxyport" ��� ������ ������, ���� ������-������ �� ������������
	variable proxy 			{}

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
	# �����, � �������� ���������� ��������� ����������
	variable		furlya		"http://xmlsearch.yandex.ru/xmlsearch"
	variable		furlyi		"http://images-xmlsearch.yandex.ru/xmlsearch"
	variable		furlys		"http://speller.yandex.net/services/spellservice/checkText?text="
	variable		furlgo		"http://gogo.ru/xml"
	variable		furlgg		"http://ajax.googleapis.com/ajax/services/search"
	variable		furlyt		"http://gdata.youtube.com/feeds/api/"
	variable		furlgb		"http://www.google.com/base/feeds/snippets"
	variable		furlbi		"http://api.search.live.net/json.aspx?AppId=9F620C0348176DCFF5EA39AC1E923DC4C172C610"
	variable		furlgs 		"https://www.google.com/tbproxy/spell"
	variable		furlgt		"http://ajax.googleapis.com/ajax/services/language/translate"
	variable		furlgd		"http://ajax.googleapis.com/ajax/services/language/detect"


	# ������� ��������
	variable 		reqqueue
	array unset 	reqqueue

	# ��������� ����������
	variable 		laststamp
	array unset		laststamp 

#---body---

	proc msg:searcher {unick uhost handle str} {
		pub:searcher $unick $uhost $handle $unick $str
		return
	}

	proc pub:searcher {unick uhost handle uchan str} {
		variable requserid ; variable fetchurl ; variable furlya ; variable furlyi ; variable furlgg ; variable furlgo ; variable furlyt ; variable furlgb ; variable furlbi ; variable furlys ; variable furlgs ; variable furlgt ; variable furlgd
		variable chflag ; variable flagactas
		variable errsend ; variable pubsend ; variable msgsend
		variable unamespace ; variable maxres ; variable pubprefix
		variable type ; variable ytype ; variable mpage ; variable query ; variable logrequests ; variable ext ; variable lng ; variable ya ; variable altwiki ; variable altsite ; variable bbing ; variable bbingl
		variable bya ; variable byaf ; variable byal ; variable byao ; variable bgogo ; variable bgogol ; variable bgoog ; variable bgoogl ; variable bgoogo ; variable bbase ; variable byt ; variable bytl ; variable bwiki ; variable wlang ; variable wpage ; variable wparm ; variable wpart ; variable whdr

		set id [subst -noc $requserid]
		set prefix [subst -noc $errsend]
		if {$unick ne $uchan} {if {![channel get $uchan $chflag] ^ $flagactas eq "no" } {return}}
		set why [queue_isfreefor $id]
		if {$why != ""} {lput puthelp $why $prefix ; return}
		set query ""

#---���������
		set ustr $str ; set lng 0
		if {[string trimleft $::lastbind ${pubprefix}] in "$bya $byaf $byal $byao"} {
			if {[regexp -nocase -- {^-[0]*(\d+)} $ustr -> mpage]} {regsub -- {-\d+\s+} $ustr "" ustr} {set mpage 1}
			if {[string trimleft $::lastbind ${pubprefix}] in $byal} {set lng 1 ; set ndoc $maxres} {set ndoc 1}
			if {[regexp -nocase -- {img:|image:|���:} $ustr]} {
				regsub -all -- {img:|image:|���:} $ustr "" ustr
				set query "<\?xml version=\"1.0\" encoding=\"windows-1251\"\?><request><query>[string trim [uenc $ustr]]</query><page>[expr {$mpage - 1}]</page><groupings><groupby attr=\"ih\" mode=\"deep\" groups-on-page=\"$ndoc\" docs-in-group=\"1\" /></groupings></request>"
				set fetchurl $furlyi ; set type 1 ; set ext 0
			} elseif {[regexp -nocase -- {sp:|����:|���:} $ustr] || [string trimleft $::lastbind ${pubprefix}] in "$byao"} {
				regsub -all -- {sp:|����:|���:} $ustr "" ustr
				set fetchurl "$furlys[uencg $ustr]" ; set type 8
			} {
				if {[string trimleft $::lastbind ${pubprefix}] in $byaf} {set ext 1} {set ext 0}
				set query "<\?xml version=\"1.0\" encoding=\"windows-1251\"\?><request><query>[uenc $ustr]</query><page>[expr {$mpage - 1}]</page><groupings><groupby attr=\"d\" mode=\"deep\" groups-on-page=\"$ndoc\" docs-in-group=\"1\" /></groupings></request>"
				set fetchurl $furlya ; set type 1
			}
		} elseif {[string trimleft $::lastbind ${pubprefix}] in "$bbing $bbingl "} {
			if {[regexp -nocase -- {^-[0]*(\d+)} $ustr -> mpage]} {regsub -- {-\d+\s+} $ustr "" ustr} {set mpage 1}
			if {[string trimleft $::lastbind ${pubprefix}] in $bbingl} {set lng 1 ; set bdoc $maxres} {set bdoc 1}
			set btype "Web" ; set bopt "&Adult=Off&Web.Offset=[expr {$mpage - 1}]&Web.Count=$bdoc&Options=EnableHighlighting" ; set bsl "" ; set btl "" ; set bll "ru en fr de it es pt ar nl ja co pl"
			if {[regexp -nocase -- {web:|���:} $ustr]} {regsub -- {web:|���:} $ustr "" ustr ; set btype "Web"}
			if {[regexp -nocase -- {video:|vid:|�����:|���:} $ustr]} {regsub -- {video:|vid:|�����:|���:} $ustr "" ustr ; set btype "Video" ; set bopt "&Adult=Off&Video.Offset=[expr {$mpage - 1}]&Video.Count=$bdoc"}
			if {[regexp -nocase -- {(?!trans:|tr:|�������:)(..)\-(..)\s+} $ustr - bsl btl]} {regsub -- {(trans:|tr:|�������:)(..)\-(..)\s+} $ustr "" ustr ; set btype "Translation" ; if {$bsl in $bll && $btl in $bll} {set bopt "&Translation.SourceLanguage=$bsl&Translation.TargetLanguage=$btl&Market=en-us"} {lput putserv "�����: $bll" $prefix ; return}}
			if {[regexp -nocase -- {spell:|sp:|����:} $ustr]} {regsub -- {spell:|sp:|����:} $ustr "" ustr ; set btype "Spell" ; set bopt "&Options=EnableHighlighting&Market=en-us"}
			if {[regexp -nocase -- {phone:|���:} $ustr]} {regsub -- {phone:|���:} $ustr "" ustr ; set btype "PhoneBook" ; set bopt "&PhoneBook.Offset=[expr {$mpage - 1}]&PhoneBook.Count=$bdoc"}
			if {[regexp -nocase -- {news:|�������:|���:} $ustr]} {regsub -- {news:|�������:|���:} $ustr "" ustr ; set btype "News" ; set bopt "&News.Offset=[expr {$mpage - 1}]&News.Count=$bdoc&Options=EnableHighlighting&Market=en-us"}
			if {[regexp -nocase -- {answer:|ans:|�����:|���:} $ustr]} {regsub -- {answer:|ans:|�����:|���:} $ustr "" ustr ; set btype "InstantAnswer" ; set bopt "&Market=en-us"}
			if {[regexp -nocase -- {image:|img:|���:} $ustr]} {regsub -- {image:|img:|���:} $ustr "" ustr ; set btype "Image" ; set bopt "&Image.Offset=[expr {$mpage - 1}]&Image.Count=$bdoc"}
			set fetchurl "${furlbi}&Query=[uencg [string trim $ustr]]&Sources=$btype$bopt" ; set type 7
		} elseif {[string trimleft $::lastbind ${pubprefix}] in "$bwiki [array names altwiki]"} {
			if {[string trimleft $::lastbind ${pubprefix}] in [array names altwiki]} {
				set wlang [lindex [array get altwiki [string trimleft $::lastbind ${pubprefix}]] 1]
			} {
				if {[regexp -nocase -- {\.(.*?)\s} $ustr - wlang]} {regsub -- {\.(.+?)\s} $ustr "" ustr} {set wlang "ru"}
				if {![regexp -- {\.} $wlang]} {set wlang "$wlang.wikipedia.org/w"}
			}
			if {[regexp -nocase -- {\-[0]*(\d+)\s*} $ustr - wpage]} {regsub -- {\-(\d+)\s*} $ustr "" ustr} {set wpage 1}	
			if {[regexp -nocase -- {\+} $ustr]} {regsub -- {\+} $ustr "" ustr ; set whdr 1} {set whdr 0}	
			if {[regexp -nocase -- {\-\?\s*} $ustr]} {regsub -- {\-\?\s*} $ustr "" ustr ; set wparm 1} {set wparm 0}	
			if {[regexp -nocase -- {#(.*?)$} $ustr - wpart]} {regsub -- {#(.*?)$} $ustr "" ustr ; set wpart [string trim $wpart]} {set wpart ""}	
				set fetchurl "http://${wlang}/api.php?action=query&list=search&format=xml&srsearch=[uencg [string trim $ustr]]"
				set type 5
		} elseif {[string trimleft $::lastbind ${pubprefix}] in "$bbase"} {
			if {[regexp -nocase -- {^-[0]*(\d+)} $ustr -> mpage]} {regsub -- {-\d+\s+} $ustr "" ustr} {set mpage 1}
			set fetchurl "${furlgb}?q=[uencg [string trim $ustr]]&start-index=$mpage&max-results=1" ; set type 6
		} elseif {[string trimleft $::lastbind ${pubprefix}] in "$bgoog $bgoogl $bgoogo $byt $bytl [array names altsite]"} {
			if {[regexp -nocase -- {^-[0]*(\d+)} $ustr -> mpage]} {regsub -- {-\d+\s+} $ustr "" ustr} {set mpage 1}
			if {[string trimleft $::lastbind ${pubprefix}] in $bgoogl} {set lng 1}
			if {[string trimleft $::lastbind ${pubprefix}] in $bytl} {set lng 1 ; set mpage [expr {$maxres * ($mpage - 1) + 1}]}
			if {[string trimleft $::lastbind ${pubprefix}] in [array names altsite]} {set ustr "$ustr site:[lindex [array get altsite [string trimleft $::lastbind ${pubprefix}]] 1]"}
			if {[regexp -nocase -- {spell:|sp:|����:} $ustr] || [string trimleft $::lastbind ${pubprefix}] in "$bgoogo"} {
				regsub -- {spell:|sp:|����:} $ustr "" ustr ; set type 8
				if {[catch {package require tls}] != 0} {putlog "\[searcher.tcl\] Package 'tls' �� ������." ; return} {::http::register https 443 ::tls::socket}
				regsub -all -- {[][${}"\\]} $ustr {} ustr
				if {[regexp -- {[�-��-߸�]} $ustr]} {set lns "ru"} {set lns "en"}
				if {[regexp -nocase -- {^-(.+?)\s} $ustr -> lng]} {regsub -- {^-(.+?)\s} $ustr "" ustr}
				set query "<spellrequest><text>[encoding convertto utf-8 $ustr]</text></spellrequest>"
				set fetchurl "${furlgs}?lang=$lns&hl=$lns"
			} elseif {[regexp -nocase -- {trans:|tr:} $ustr] && [string trimleft $::lastbind ${pubprefix}] in "$bgoog"} {
				set lng5 [list ? ar bg hr cz dk nl en fi fr de gr hi it ja no pl pt ro ru es sv ca tl iw lv lt sr sk sl uk]
				set lni5 [list auto ar bg hr cs da nl en fi fr de el hi it ja no pl pt ro ru es sv ca tl iw lv lt sr sk sl uk]
				regsub -- {trans:|tr:} $ustr "" ustr ; set type 9
				regexp -nocase -- {^(.+?)-(.+?)\s(.+?)$} $ustr -> lang1 lang2 utxt
					if {[lsearch -exact $lng5 $lang1] == -1 || [lsearch -exact $lng5 $lang2] == -1} {
						lput putserv "\037������� ������ ���� ��������\037. [join $lng5]" $prefix
						return
					} {
						set lang1 [lindex $lni5 [lsearch -exact $lng5 $lang1]] ; set lang2 [lindex $lni5 [lsearch -exact $lng5 $lang2]]
						set ustr $utxt
						set fetchurl "${furlgt}?v=1.0&q=[uencg $ustr]&langpair=${lang1}%7C${lang2}"
					}
			} elseif {[regexp -nocase -- {det:|def:} $ustr] && [string trimleft $::lastbind ${pubprefix}] in "$bgoog"} {
				regsub -- {det:|def:} $ustr "" ustr ; set type 9
				set fetchurl "${furlgd}?v=1.0&q=[uencg [string trim $ustr]]"

			} elseif {[regexp -nocase -- {video:|�����:} $ustr] || [string trimleft $::lastbind ${pubprefix}] in "$byt $bytl"} {
				regsub -- {video:|�����:} $ustr "" ustr ; set type 4 ; set ytype 1
 				if {[string match "*-rate*" $ustr]} {set fetchurl "${furlyt}standardfeeds/top_rated?start-index=$mpage&max-results=$maxres&racy=include" ; set ytype 2
				} elseif {[string match "*-fav*" $ustr]} {set fetchurl "${furlyt}standardfeeds/top_favorites?start-index=$mpage&max-results=$maxres&racy=include" ; set ytype 2
				} elseif {[string match "*-view*" $ustr]} {set fetchurl "${furlyt}standardfeeds/most_viewed?start-index=$mpage&max-results=$maxres&racy=include" ; set ytype 2
				} elseif {[string match "*-pop*" $ustr]} {set fetchurl "${furlyt}standardfeeds/most_popular?start-index=$mpage&max-results=$maxres&racy=include" ; set ytype 2
				} elseif {[string match "*-comm*" $ustr]} {set fetchurl "${furlyt}standardfeeds/most_discussed?start-index=$mpage&max-results=$maxres&racy=include" ; set ytype 2
				} {set fetchurl "${furlyt}videos?vq=[uencg $ustr]&orderby=relevance&start-index=$mpage&max-results=$maxres&racy=include"}
			} {
				if {$mpage > 20} {set mpage 20}
				set pfix "web"
				if {[regexp -nocase -- {img:|image:|���:} $ustr]} {
					regsub -- {img:|image:|���:} $ustr "" ustr
					set pfix "images" ; set imgp "&imgsz=medium" ; set imgt ""
					if {[regexp -nocase -- {\+\+} $ustr]} {regsub -- {\+\+} $ustr "" ustr ; set imgp "&imgsz=xxlarge"}
					if {[regexp -nocase -- {\+\+\+} $ustr]} {regsub -- {\+\+\+} $ustr "" ustr ; set imgp "&imgsz=huge"}
					if {[regexp -nocase -- {\+face} $ustr]} {regsub -- {\+face} $ustr "" ustr ; set imgt "&imgtype=face"}
					if {[regexp -nocase -- {\+photo} $ustr]} {regsub -- {\+photo} $ustr "" ustr ; set imgt "&imgtype=photo"}
					if {[regexp -nocase -- {\+clip} $ustr]} {regsub -- {\+clip} $ustr "" ustr ; set imgt "&imgtype=clipart"}
					if {[regexp -nocase -- {\+line} $ustr]} {regsub -- {\+line} $ustr "" ustr ; set imgt "&imgtype=lineart"}
				} {set imgp "" ; set imgt ""}
				if {[regexp -nocase -- {blog:|����:} $ustr]} {regsub -- {blog:|����:} $ustr "" ustr ; set pfix "blogs"}
				if {[regexp -nocase -- {news:|�������:} $ustr]} {regsub -- {news:|�������:} $ustr "" ustr ; set pfix "news"}
				if {[regexp -nocase -- {loc:|local:|���:} $ustr]} {regsub -- {loc:|local:|���:} $ustr "" ustr ; set pfix "local"}
				if {[regexp {[�-��-߸�]} $ustr]} {set prus "&hl=ru"} {set prus ""}
				set fetchurl "$furlgg/$pfix?v=1.0&start=[expr {$lng?[expr {$maxres * ($mpage - 1)}]:[expr {$mpage - 1}]}]&safe=off&q=[string trim [uencg $ustr]]$prus$imgp$imgt" ; set type 2
			}
		} {
			if {[regexp -nocase -- {^-[0]*(\d+)} $ustr -> mpage]} {regsub -- {-\d+\s+} $ustr "" ustr} {set mpage 1}
			if {[string trimleft $::lastbind ${pubprefix}] in $bgogol} {set lng 1}
			set pfix ""
			if {[regexp -nocase -- {img:|image:|���:} $ustr]} {regsub -- {img:|image:|���:} $ustr "" ustr ; set pfix "_images"}
			if {[regexp -nocase -- {vid:|video:|�����:} $ustr]} {regsub -- {vid:|video:|�����:} $ustr "" ustr ; set pfix "_video"}
			if {[regexp -nocase -- {site:(.+?)(?:\s|$)} $ustr -> insite]} {regsub -- "site:$insite" $ustr "" ustr ; set site "&site=[string trim [string map {"http://" "" "www" ""} $insite]]&g=0&d=0"} {set site ""}
			set fetchurl "${furlgo}${pfix}?q=[uencg [string trim $ustr]]&sf=[expr {$lng?[expr {($maxres * ($mpage - 1)) + 1}]:$mpage}]$site" ; set type 3
		}

		::http::config -urlencoding cp1251 -useragent "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; 240x320)"	

			if {[string is space $ustr]} {
				set prefix [subst -noc $msgsend]
				lput puthelp "\002${pubprefix}[lindex $bya 0]\002 \[-�����\] \[img:|sp:\] <������> - ����� � ������� :: \002${pubprefix}[lindex $byaf 0]\002 - ����������� ����� :: \002${pubprefix}[lindex $byal 0]\002 - ������������� �����" $prefix
				lput puthelp "\002${pubprefix}[lindex $bgogo 0]\002 \[-�����\] \[img:|video:\]\[site:<����>\] <������> - ����� � GoGo.ru :: \002${pubprefix}[lindex $bgogol 0]\002 - ������������� �����" $prefix		
				lput puthelp "\002${pubprefix}[lindex $bgoog 0]\002 \[-�����\] \[img:|video:|news:|blog:|local:|spell:|tr:lng1-lng2|det:\]\[site:<����>\] <������> - ����� � Google :: \002${pubprefix}[lindex $bgoogl 0]\002 - ������������� ����� :: ( [set r ""; foreach n [array names altsite] {append r "${pubprefix}$n "}]$r) - ������������� �����" $prefix		
				lput puthelp "\002${pubprefix}[lindex $byt 0]\002 \[-�����\] <������> - ����� � Youtube :: \002${pubprefix}[lindex $bytl 0]\002 - ������������� �����" $prefix		
				lput puthelp "\002${pubprefix}[lindex $bbase 0]\002 \[-�����\] <������> - ����� � Google Base" $prefix		
				lput puthelp "\002${pubprefix}[lindex $bwiki 0]\002 ( [set r ""; foreach n [array names altwiki] {append r "${pubprefix}$n "}]$r) \[-��������\] \[-?\] \[\002.\002����\] \[+\]<������\[#�����\]> - ����� � ����������" $prefix		
				lput puthelp "\002${pubprefix}[lindex $bbing 0]\002 \[-�����\] \[img:|video:|news:|spell:|ans:|phone:|tr:lng1-lng2\] <������> - ����� � Bing :: \002${pubprefix}[lindex $bbingl 0]\002 - ������������� �����" $prefix		
			return
			}
putlog "$fetchurl"
		if {$logrequests ne ""} {set logstr [subst -noc $logrequests] ; lput putlog $logstr "$unamespace: "}
		if {[queue_add "$fetchurl" $id "[namespace current]::searcher:parser" [list $unick $uhost $uchan $ustr]]} {variable err_ok ; if {$err_ok ne ""} {lput puthelp "$err_ok." $prefix}} {variable err_fail ; if {$err_fail ne ""} {lput puthelp "$err_fail" $prefix}}

	return
	}

#---parser
	proc searcher:parser {errid errstr body extra} {
		upvar $errid lerrid $errstr lerrstr ${body} lbody ${extra} lextra
		variable err_fail ; variable pubsend ; variable msgsend ; variable errsend
		variable maxres ; variable mpage ; variable ext ; variable lng ; variable type ; variable ytype ; variable wlang ; variable wpage ; variable wparm ; variable wpart ; variable whdr

		foreach {unick uhost uchan ustr} ${lextra} {break}
		if {$lerrid ne {ok}} {lput putserv [subst -noc $err_fail] [subst -noc $errsend] ; return}
		if {$uchan eq $unick} {set prefix [subst -noc $msgsend]} {set prefix [subst -noc $pubsend]}
		if {[info exists ::sp_version]} {if {$type != 3} {regsub -all -- {(?x)[\xCC][\x81]} $lbody "'" lbody ; set str [encoding convertfrom utf-8 $lbody]} {set str [encoding convertfrom cp1251 $lbody]}} {set str $lbody}

#----------------------------------------------------------------------------
##---parser-specific------
#----------------------------------------------------------------------------
	if {$type == 1} {
		regsub -all -- "\n|\t|\r" $str " " str
		if {![regexp -- {<error code="(.*?)">(.+?)</error>} $str -> yerrc yerr]} 	{set yerrc 0 ; set yerr ""}
		if {![regexp -- {<found priority="all">(.+?)</found>} $str -> ytotal]}		{set ytotal ""}		{set ytotal "/$ytotal"}
		if {![regexp -- {<city>(.+?)</city>} $str -> ycity]}						{set ycity ""}		{set ycity "\00303$ycity\003 "}
		if {![regexp -- {<weather>(.+?)</weather>} $str -> yweather]}				{set yweather ""}	{regsub -all -- "<.*?>" [sconv $yweather] " " yweather ; set yweather " - $yweather "}
		if {![regexp -- {<spcctx>(.+?)</spcctx>} $str -> yspc]}						{set yspc ""}		{regsub -all -- "<.*?>" [sconv $yspc] "" yspc ; set yspc " - $yspc "}
		if {![regexp -- {<link>(.+?)</link>} $str -> ylink]}						{set ylink ""}		{regsub -all -- "<.*?>" [sconv $ylink] "" ylink ; set ylink " - $ylink "}
		if {![regexp -- {<linkusd>(.+?)</linkusd>} $str -> yusd]}					{set yusd ""}		{regsub -all -- "<.*?>" [sconv $yusd] "" yusd ; set yusd " - $yusd "}
		if {![regexp -- {<linkeur>(.+?)</linkeur>} $str -> yeur]}					{set yeur ""}		{regsub -all -- "<.*?>" [sconv $yeur] "" yeur ; set yeur " - $yeur "}
		set ylong [list] ; set yshort [list] ; set yext [list]
		if {[regexp -- {<grouping.*?>(.+?)</grouping>} $str -> ygg]} {
			regsub -all -- {<hlword.*?>} $ygg "\002" ygg ; regsub -all -- {</hlword>} $ygg "\002" ygg
			regsub -all -- {</group>} $ygg "</group>\n" ygg
			foreach yg [split $ygg \n] {
				if {![regexp -- {<url>(.+?)</url>} $yg -> yurl]}						{set yurl ""}		{set yurl " @ \037\00312$yurl\037\003"}
				if {![regexp -- {<title>(.+?)</title>} $yg -> ytitle]}					{set ytitle ""}		{set ytitle "\00305$ytitle\003"}
				if {![regexp -- {<domain>(.+?)</domain>} $yg -> ydomain]}				{set ydomain ""}	{set ydomain "\002$ydomain\002 "}
				if {![regexp -- {<headline>(.+?)</headline>} $yg -> yheadl]}			{set yheadl ""}		{set yheadl " - \00314$yheadl\003"}
				if {![regexp -- {<size>(.+?)</size>} $yg -> ysize]}						{set ysize ""}
				if {![regexp -- {<charset>(.+?)</charset>} $yg -> ycharset]}			{set ycharset ""}
				if {![regexp -- {<mime-type>(.+?)</mime-type>} $yg -> ymime]}			{set ymime ""}
				if {![regexp -- {<modtime>(.+?)</modtime>} $yg -> ymtime]}				{set ymtime ""}		{set ymtime "([clock format [clock scan $ymtime] -format "%d-%m-%Y %H:%M:%S"])"}	
				if {![regexp -- {<passages>(.+?)</passages>} $yg -> ypassages]}			{set yp ""}			{set yp "" ; foreach {- yps} [regexp -all -inline {<passage>(.+?)</passage>} $ypassages] {regsub -all -- "<.*?>" [sconv $yps] "" yps ; append yp "\003 $yps "}}	
				if {![regexp -- {<image-properties>(.+)</image-properties>} $yg -> yi]}	{set yi ""}			{regexp -- {<original-width>(.*?)</original-width>.*?<original-height>(.*?)</original-height>} $yi -> yiw yih ; set yi " \00314\[ ${yiw}x${yih} - $ysize ����\]\003"}
				lappend ylong  "${ytitle}${yi}${yurl}"
				lappend yshort "${ycity}${yweather}${ylink}${yspc}${yusd}${yeur}$yp $yi $yurl"
				lappend yext   "\00314\[$ysize ���� $ymtime $ymime / $ycharset\]\003 | ${ydomain}${ytitle}${yheadl}"
			}
			if {$lng} {lput putserv [sconv [sspace "\[Yandex/$mpage$ytotal\] :: [join $ylong " | "]"]] $prefix} {lput putserv [sconv [sspace "\[Yandex/$mpage$ytotal\] ::[lindex $yshort 0]"]] $prefix}
			if {$ext} {lput putserv [sconv [sspace [lindex $yext 0]]] $prefix}
		} {lput putserv "\[Yandex\] :: [sconv $yerr] (err:$yerrc)" $prefix}
	} ;#ya

	if {$type == 2} {
		set gdata [json2dict $str]
		regsub -all "<b>|</b>" $gdata "\002" gdata
		if {$lng} {
			set gout [list]
			set gdl [lrange [dict get $gdata responseData results] 0 [expr {$maxres - 1}]]
			if {[catch {set gnr "[dict get $gdata responseData cursor estimatedResultCount]/"}]} {set gnr ""}
			if {[llength $gdl]} {
				foreach gd $gdl {
					set gt [dict get $gd GsearchResultClass]
					if {$gt eq "GwebSearch"}   {set got "Web" ; lappend gout [sconv "\00305[dict get $gd title]\003 @ \037\00312[dict get $gd unescapedUrl]\003\037"]} 
					if {$gt eq "GblogSearch"}  {set got "Blog" ; lappend gout [sconv "\00305[catch {[dict get $gd title]}\003 @ \037\00312[catch {[dict get $gd postUrl]}\003\037"]} 
					if {$gt eq "GnewsSearch"}  {set got "News" ; lappend gout [sconv "\00305[dict get $gd title]\003 @ \037\00312[dict get $gd unescapedUrl]\003\037"]} 
					if {$gt eq "GlocalSearch"} {set got "Local" ; lappend gout [sconv "\00305[dict get $gd title]\003 @ \037\00312[dict get $gd url]\003\037"]} 
					if {$gt eq "GimageSearch"} {set got "Image" ; lappend gout [sconv "\00305[dict get $gd title]\003 \00314\[[dict get $gd width]x[dict get $gd height]\]\003 @ \037\00312[dict get $gd unescapedUrl]\003\037"]}
				} 
			lput putserv "\[Google/[expr {($maxres * ($mpage - 1)) + 1}]..[expr {($maxres * ($mpage - 1)) + $maxres}]/${gnr}$got\] [join $gout " | "]" $prefix
			} {lput putserv "\037������ �� �������\037." $prefix}
		} {
			set gd [lindex [dict get $gdata responseData results] 0]
			if {$gd ne ""} {
				set gt [dict get $gd GsearchResultClass]
				if {$gt eq "GwebSearch"}   {lput putserv [sconv "\[Google/$mpage/[dict get $gdata responseData cursor estimatedResultCount]/Web\] \00305[dict get $gd title]\003 :: [dict get $gd content] @ \037\00312[dict get $gd unescapedUrl]\003\037"] $prefix} 
				if {$gt eq "GblogSearch"}  {lput putserv [sconv "\[Google/$mpage/Blog\] \00305[dict get $gd title]\003 [dict get $gd author] :: [dict get $gd content] - [dict get $gd publishedDate] @ \037\00312[dict get $gd postUrl]\003\037"] $prefix} 
				if {$gt eq "GnewsSearch"}  {lput putserv [sconv "\[Google/$mpage/[dict get $gdata responseData cursor estimatedResultCount]/News\] \00305[dict get $gd title]\003 :: [dict get $gd content] :: [dict get $gd publisher] :: [dict get $gd location] [dict get $gd publishedDate] @ \037\00312[dict get $gd unescapedUrl]\003\037 [expr {[dict get $gd clusterUrl] eq "" ? [set cu ""] : [set cu "<= \037\00312[dict get $gd clusterUrl]\003\037"]}]"] $prefix} 
				if {$gt eq "GlocalSearch"} {set r "" ; foreach {t n} [join [catch {[dict get $gd phoneNumbers]}]] {append r "$n "} ; lput putserv [sconv "\[Google/$mpage/Local\] \00305[dict get $gd title]\003 :: ${r}[dict get $gd streetAddress] [dict get $gd city] [dict get $gd region] [dict get $gd country] :: [dict get $gd lat]-[dict get $gd lng] @ \037\00312[dict get $gd url]\003\037"] $prefix} 
				if {$gt eq "GimageSearch"} {lput putserv [sconv "\[Google/$mpage/[dict get $gdata responseData cursor estimatedResultCount]/Images\] \00305[dict get $gd title]\003 :: [dict get $gd content] \00314\[[dict get $gd width]x[dict get $gd height]\]\003 @ \037\00312[dict get $gd unescapedUrl]\003\037 <= \037\00312[dict get $gd originalContextUrl]\003\037"] $prefix}
			} {lput putserv "\037������ �� �������\037." $prefix}
		}
	} ;#google

	if {$type == 3} {
		regsub -all -- "\n|\t|\r" $str "" str
		if {![regexp -- {<totalWebPages>(.+?)</totalWebPages>} $str -> gtwp]} 	{set gtwp 0}
		if {![regexp -- {<totalSites>(.+?)</totalSites>} $str -> gts]} 			{set gts 0}
		if {![regexp -- {<startIndex>(.+?)</startIndex>} $str -> gsi]} 			{set gsi 0}
		if {$gtwp > 0 && $gts > 0} {
			regsub -all "<b>|</b>" [sconv $str] "\002" str
			regsub -all -- "</item>" $str "</item>\n" str
			set gres [list] ; set gresi [list] ; set gresv [list]
			foreach g [split $str \n] {
				if {[regexp -- {<title>(.*?)</title>.*?<link>(.+?)</link>.*?<description>(.*?)</description>} $g -> gt gl gd]} {if {$lng} {lappend gres "\00305$gt\003 @ \037\00312$gl\003\037 |"} {lappend gres "\00305$gt\003 :: $gd @ \037\00312$gl\003\037"}}
				if {[regexp -- {<Url>(.*?)</Url>.*?<name>(.*?)</name>} $g -> gvu gvn]} {lappend gresv "\00305$gvn\003 @ \037\00312$gvu\003\037 |"}
				if {[regexp -- {<imageUrl>(.+?)</imageUrl>.*?<size>(.*?)</size>.*?<width>(.*?)</width>.*?<height>(.*?)</height>.*?<description>(.*?)</description>} $g -> gu gs gw gh gd]} {lappend gresi "\00305$gd\003 \00314\[${gw}\x${gh} - $gs ����\]\003 @ \037\00312http://$gu\003\037 |"}
			}
		}
			if {$gtwp > 0 && $gtwp >= $mpage} {lput putserv "\[GoGo/[expr {$lng?[set gsi "$gsi..[expr {$gsi + $maxres - 1}]"]:$gsi}]/$gtwp\($gts\)\] :: [expr {$lng?[sspace [string trimright [join [lrange $gres 0 [expr {$maxres - 1}]]] "|"]]:[sspace [lindex $gres 0]]}][sspace [string trimright [join [lrange $gresi 0 [expr {$maxres - 1}]]] "|"]][sspace [string trimright [join [lrange $gresv 0 [expr {$maxres - 1}]]] "|"]]" $prefix} {lput putserv "\037������ �� �������\037." $prefix}
	} ;#gogo

	if {$type == 4} {
	regsub -all -- "\n" $str "" str
	regsub -all -- "</entry>" $str "</entry>\n" str
	if {![regexp -- {^(.+?)<entry>} $str -> yhead]} {lput putserv "\037������ �� �������\037." $prefix ; return}
	regexp -- {<openSearch:totalResults>(.+?)</openSearch:totalResults>} $yhead -> ytotal
	regexp -- {<title type='text'>(.+?)</title>} $yhead -> ytitle
	regsub -- {^(.+?)<entry>} $str "" str

	set res [list] ; set cnt 0
	foreach yd [split $str \n] {
		regexp -- {<published>(.+?)</published>} $yd -> ydate
		regexp -- {<title type='text'>(.+?)</title>} $yd -> ytshort
		regexp -- {<content type='text'>(.+?)</content>} $yd -> ytlong
		regexp -- {<link rel='alternate' type='text/html' href='(.+?)'/>} $yd -> ylink
		regexp -- {<media:keywords>(.+?)</media:keywords>} $yd -> ykeyw
		regexp -- {<yt:duration seconds='(.+?)'/>} $yd -> ydur
		regexp -- {<media:category.*?'>(.+?)</media:category>} $yd -> ycat
		if {![regexp -- {<yt:statistics.*?viewCount='(.+?)'.*?/>} $yd -> yview]} {set yview "-"}
		if {![regexp -- {<yt:statistics.*?favoriteCount='(.+?)'.*?/>} $yd -> yfav]} {set yfav "-"}
		if {![regexp -- {<gd:rating.*?numRaters='(.+?)'.*?/>} $yd -> yraten]} {set yraten  "-"}
		if {![regexp -- {<gd:rating.*?average='(.+?)'.*?/>} $yd -> yrate]} {set yrate "-"}
		if {$ytype == 1 && !$lng} {
				lappend res "\[Youtube/$mpage/$ytotal\] :: \00305$ytshort\003 :: [expr {[string length $ytlong] > 300 ? [set ytlong "[string range $ytlong 0 300] ..."] : [set ytlong $ytlong]}] :: \00314($ykeyw)\003 :: \[\002T\002:[clock format $ydur -format "%M:%S"]/\002R\002:${yrate}($yraten)/\002V\002:$yview/\002F\002:$yfav/\002A\002:[clock format [clock scan [string range $ydate 0 9]] -format %d-%m-%Y]/\002$ycat\002\] \@ \037\00312$ylink\003\037"
				lput putserv "[sconv [join $res]]" $prefix ; break
		} {
			incr cnt
			lappend res "\00305$ytshort\003 @ \037\00312$ylink\003\037 |"  
			if {$cnt == $maxres} {break}
		}
	}
		if {$ytype == 0} {lput putserv "\[Youtube/$ytotal\] :: [sconv [join $res]]" $prefix}
		if {$ytype == 1 && $lng} {lput putserv "\[Youtube/$mpage..[expr {$mpage + ($maxres - 1)}]/$ytotal\] :: [sconv [join $res]]" $prefix}
		if {$ytype == 2} {lput putserv "\[Youtube/\002$ytitle\002\] :: [sconv [join $res]]" $prefix}
	} ;#ytube

	if {$type == 5} {
		if {[regexp -- {<search>(.+?)</search>} $str -> wsearch]} {
			regsub -all -- "\n|\t|\r" $str "" str
			set wpg [list]
			foreach {- res} [regexp -all -inline -- {title=\"(.+?)\".*?/>} $wsearch] {lappend wpg $res}
			queue_add "http://${wlang}/api.php?action=query&format=xml&prop=info%7Crevisions&rvprop=timestamp%7Ccontent&rvlimit=1&redirects&titles=[uencg [lindex $wpg 0]]" [unixtime] "[namespace current]::searcher:parser" [list $unick $uhost $uchan $wpg]
		} elseif {[regexp -- {<page.*?title=\"(.+?)\".*?touched=\"(.+?)\".*?length=\"(.+?)\">} $str -> ptitle pdate psize]} {
			set pdate [string map {T " " Z ""} $pdate]
			regexp -- {<rev timestamp.*?>(.+?)</rev>} $str -> ptext
			set ptext [string map {&lt; < &gt; > nbsp; " " &lt;s&gt; \00315 &lt;/s&gt; \003} $ptext]
			regsub -all -- {<ref>.*?</ref>} $ptext "" ptext
			regsub -all -- {<.*?>} $ptext "" ptext
			regsub -all -- {'''} $ptext {"} ptext
			regsub -all -- {^(={2,5})\s*(.+?)\s*(={2,5})} $ptext "\\1 \\2 \\3" ptext

			if {$wpart ne ""} {
				set wstart [string first "== $wpart ==" $ptext]
				#set wend [string first "== " $ptext $wstart+[string length $wpart]]
				set ptext [string range $ptext $wstart end]
			}

			set wres "" ; set wtoc [list]
			foreach pline [split $ptext \n] {
				if {![regexp -- {^\s*(\||\!)} $pline]} {
					if {![regexp -- {^\[\[.*?\:.*$} $pline]} {
						regsub -all -- {\[\[(?:[^\[\]]*?\||)([^\[\]]*)\]\]} $pline "\00314\\1\003" pline
						regsub -all -- {\[\[(.*?)\]\]} $pline "\00312\\1\003" pline
						regsub -all -- {\{\{��\|(\d+)\|(.+?)\|(\d+)\|(\d+)\|(.+?)\}\}} $pline  "\\1 \\2 (\\4 \\5) \\3" pline 
						regsub -all -- {\{\{.*?\|.*?\|.*?\}\}} $pline "" pline					
						regsub -all -- {\{\{(?:[^\{\}]*?\|)([^\{\}]*)\}\}} $pline "\00314\\1\003" pline
						regsub -all -- {\{\{.*?\}\}} $pline "" pline
						if {[regexp -- {^==\s*(.+?)\s*==} $pline -> toc]} {lappend wtoc [string map {= ""} $toc]}
						regsub -all -- {(?:\={2,4})\s*(.*?)\s*(?:\={2,4})} $pline "\002 * \002\037\\1\037 " pline
						regsub -all -- {^(\*{1,3}\s*|#{1,3}\s*)} $pline " \002\\1\002 " pline
						regsub -all -- {\[http://(.+?)\s(.*?)\]} $pline " \002*\002 \037\00312http://\\1\003\037 - \\2" pline
						append wres "$pline "
					}
				} elseif {$whdr && [regexp -- {^\s*\|\s*(.+?)\s*\=\s*(.+?)$} $pline -> wh wd]} {
					regsub -all -- {\{\{.*?\|(\d+)\|(.+?)\|(\d+)\|(\d+)\|(.+?)\}\}} $wd "\\1 \\2 (\\4 \\5) \\3" wd
					regsub -all -- {\[\[(?:[^\[\]]*?\||)([^\[\]]*)\]\]} $wd "\00314\\1\003" wd
					regsub -all -- {\[http://(.+?)\s(.*?)\]} $pline "\037\00312http://\\1\003\037 - \\2" pline
					append wres "$wh - $wd / "
				}
			}

			set wplen 360
			regsub -all -- "\n|\t|\r" $wres " " wres
			regsub -all -- {\{\{.*?\}\}} $wres "" wres
			set ptxt [sspace [sconv [string range $wres [expr {($wpage - 1) * $wplen}] [expr {(($wpage - 1) * $wplen) + $wplen}]] 0]]
			if {$wparm} {lput putserv "\002ToC\002: [join $wtoc " :: "]" $prefix ; return}
			if {$wpage == 1 && $wpart eq ""} {
				set ptxt "\[Wiki/���.:${wpage}/[expr {([string length $wres] / 360) + 1}]\] \002$ptitle\002 :: ${ptxt}" 
				if {[string length $ptxt] < $wplen} {set cont ""} {set cont " <...>"}
				lput putserv "${ptxt}$cont" $prefix
				lput putserv "\037\00312http://[string map {"/w" "/wiki"} ${wlang}]/[uencg [string map {" " "_"} $ptitle]]\003\037" $prefix
				if {[llength [lrange $ustr 1 end]]} {lput putserv "\037��� �������\037: [sconv [join [lrange $ustr 1 end] " / "]]" $prefix}	
			} {
				if {[string length $ptxt] < $wplen} {set cont ""} {set cont " <...>"}
				lput putserv "\[���.:${wpage}/[expr {([string length $wres] / 360) + 1}]\] :: ${ptxt}$cont" $prefix
			}
		} else {lput putserv "\037������ �� �������\037." $prefix ; return}
	} ;#wiki

	if {$type == 6} {
		regsub -all -- "\n" $str "" str
		regsub -all -- "</entry>" $str "</entry>\n" str

		if {![regexp -- {^(.+?)<entry>} $str -> ghead]} {lput putserv "\037������ �� �������\037." $prefix ; return}
		regexp -- {<openSearch:totalResults>(.+?)</openSearch:totalResults>} $ghead -> gtotal
		regexp -- {<title type='text'>(.+?)</title>} $ghead -> gtitle
		regsub -- {^(.+?)<entry>} $str "" str

		foreach gd [split $str \n] {
			if {[regexp -- {<published>(.+?)</published>} $gd -> gdate]}					{set gdate [frmd $gdate]} {set gdate ""}
			if {[regexp -- {<title type='(?:text|html)'>(.+?)</title>} $gd -> gsdesc]}		{set gsdesc $gsdesc} {set gsdesc ""}
			if {[regexp -- {<content type='(?:text|html)'>(.+?)</content>} $gd -> gldesc]}	{set gldesc $gldesc} {set gldesc ""}
			if {[regexp -- {<link rel='alternate'.*?href='(.+?)'/>} $gd -> glink]}			{regexp -- {loc=(.*?)$} $glink -> glink ; regsub -- {^.*?mpre=} $glink "" glink ; set glink [sconv [string map {"%3A" ":" "%2F" "/"} $glink]]} {set glink ""}

			if {[regexp -- {<g:condition type='text'>(.+?)</g:condition>} $gd -> gcond]}	{set gcond "<$gcond>"} {set gcond ""}
			if {[regexp -- {<g:product_type type='text'>(.+?)</g:product_type>} $gd -> gprod]}	{set gprod "\[[sconv $gprod]\]"} {set gprod ""}
			if {[regexp -- {<author><name>(.+?)</name>} $gd -> ganame]}						{set ganame "$ganame"} {set ganame ""}
			if {[regexp -- {<g:price type=.*?>(.+?)</g:price>} $gd -> gprice]}				{set gprice "(\037$gprice\037) "} {set gprice ""}

			lput putserv "[sconv [sspace "\[GBase/$mpage/$gtotal\] \002::\002 \00305$gsdesc\003 \002::\002 $gldesc \002::\002 $ganame $gcond $gprice $gprod"]]" $prefix
			lput putserv "\037\00312$glink\003\037" $prefix
			break
		}
	} ;# Google Base

	if {$type == 7} {
		set bdata [json2dict $str]
		regsub -all -- {\uE000|\uE001} $bdata "\002" bdata
		if {[dict exists $bdata SearchResponse Errors]} {lput putserv "\037������ �� �������\037.([join [dict get $bdata SearchResponse Errors]])" $prefix ; return} {
			set bit [lindex [dict keys [dict get $bdata SearchResponse]] 2]
#putlog "bit - $bit"
			if {[dict exists $bdata SearchResponse Query AlterationOverrideQuery]} {lput putserv "[dict get $bdata SearchResponse Query AlterationOverrideQuery]" $prefix}
			if {![dict exists $bdata SearchResponse $bit Total] || [dict get $bdata SearchResponse $bit Total] == 0} {if {$bit ne "Translation" && $bit ne "Spell"} {lput putserv "������ ������ ������������ ������." $prefix ; return}}
			if {$lng} {
				set bout [list]
				set bdl [lrange [dict get $bdata SearchResponse $bit Results] 0 [expr {$maxres - 1}]]
				if {[catch {set bnr "[dict get $bdata SearchResponse $bit Total]/"}]} {set bnr ""}
				if {[llength $bdl]} {
					foreach bd $bdl {
						if {$bit eq "Web"} {lappend bout [sconv "\00305[dict get $bd Title]\003 @ \037\00312[dict get $bd Url]\003\037"]} 
						if {$bit eq "Video"} {lappend bout [sconv "\00305[dict get $bd Title]\003 @ \037\00312[dict get $bd PlayUrl]\003\037"]} 
						if {$bit eq "Image"} {lappend bout [sconv "\00305[dict get $bd Title]\003 :: [dict get $bd Width]x[dict get $bd Height] @ \037\00312[dict get $bd MediaUrl]\003\037"]} 
						if {$bit eq "News"}  {lappend bout [sconv "\00305[dict get $bd Title]\003 (\00314[dict get $bd Source]\003 / [clock format [clock scan [string map {T " " Z ""} [dict get $bd Date]]] -format "%d-%h-%Y %H:%M" -locale ru]) :: \[[expr {![dict get $bd BreakingNews] ? [set bbn "N"] : [set bbn "\00304B\003"]}]\] @ [expr {[dict exists $bd Url] ? [set nurl "\037\00312[dict get $bd Url]\003\037"] : [set nurl " --- "]}]"]}
					} 
				if {[llength $bout]} {lput putserv "\[Bing/[expr {($maxres * ($mpage - 1)) + 1}]..[expr {($maxres * ($mpage - 1)) + $maxres}]/${bnr}$bit\] [join $bout " | "]" $prefix} {lput putserv "\037������������� ����� �� ��������������\037 (����...)" $prefix}
				} {lput putserv "\037������ �� �������\037." $prefix}
			} {
				set bd [lindex [dict get $bdata SearchResponse $bit Results] 0]
				if {$bit eq "Web"} {lput putserv [sconv "\[Bing/$mpage/[dict get $bdata SearchResponse $bit Total]/Web\] \00305[dict get $bd Title]\003 :: [expr {[dict exists $bd Description] ? [dict get $bd Description] : [set bds ""]}] [expr {[dict exists $bd DateTime] ? [set wdt "([clock format [clock scan [string map {T " " Z ""} [dict get $bd DateTime]]] -format "%d-%h-%Y %H:%M" -locale ru])"] : [set wdt ""]}] @ \037\00312[dict get $bd Url]\003\037"] $prefix} 
				if {$bit eq "Video"} {lput putserv [sconv "\[Bing/$mpage/[dict get $bdata SearchResponse $bit Total]/Video\] \00305[dict get $bd Title]\003 :: ([dict get $bd SourceTitle]) @ \037\00312[dict get $bd PlayUrl]\003\037 ([clock format [expr {[dict get $bd RunTime] / 1000}] -format "%Mm %Ss"])"] $prefix} 
				if {$bit eq "Translation"} {lput putserv [sconv "\[Bing/Translate\] :: [dict get $bd TranslatedTerm]"] $prefix} 
				if {$bit eq "Spell"} {lput putserv [sconv "\[Bing/Spell\] :: [dict get $bd $bit Value]"] $prefix} 
			if {$bit eq "PhoneBook"} {lput putserv [sconv "\[Bing/[dict get $bdata SearchResponse $bit Total]/Phone\] :: [dict get $bd $bit Results]"] $prefix} 
				if {$bit eq "News"} {lput putserv [sconv "\[Bing/$mpage/[dict get $bdata SearchResponse $bit Total]/News\] \00305[dict get $bd Title]\003 (\00314[dict get $bd Source]\003 / [clock format [clock scan [string map {T " " Z ""} [dict get $bd Date]]] -format "%d-%h-%Y %H:%M" -locale ru]) :: [dict get $bd Snippet] \[[expr {![dict get $bd BreakingNews] ? [set bbn "N"] : [set bbn "\00304B\003"]}]\] @ [expr {[dict exists $bd Url] ? [set nurl "\037\00312[dict get $bd Url]\003\037"] : [set nurl " --- "]}]"] $prefix} 
				if {$bit eq "InstantAnswer"} {lput putserv [sconv "\[Bing/$mpage/[dict get $bdata SearchResponse $bit Total]/Answer\] \00305[dict get $bd Title]\003 ([dict get $bd Attribution] / [dict get $bd ContentType]) :: [expr {[dict exists $bd InstantAnswerSpecificData] ? [set asd "[dict get $bd InstantAnswerSpecificData]"] : [set asd ""]}] @ [expr {[dict exists $bd Url] ? [set nurl "\037\00312[dict get $bd Url]\003\037"] : [set nurl " --- "]}]"] $prefix} 
				if {$bit eq "Image"} {lput putserv [sconv "\[Bing/$mpage/[dict get $bdata SearchResponse $bit Total]/Image\] \00305[dict get $bd Title]\003 :: [dict get $bd Width]x[dict get $bd Height] @ \037\00312[dict get $bd Url]\003\037 -> \037\00312[dict get $bd MediaUrl]\003\037"] $prefix} 
			}
		}
	} ;# Bing

	if {$type == 8} {
		if {[regexp -- {suggestedlang="(.+?)"} $str -> ln]} {set ln "\[$ln\] "} {set ln ""}
		if {[regexp -nocase -- {<spellresult.*?>(.*?)</spellresult>} $str -> gd]} {
			set gd [string map {\t " " "</c>" \n "</error>" \n} $gd]
			foreach gl [split $gd \n] {
				if {[regexp -- {<c o="(\d+)" l="(\d+)" s="(\d+)">(.*?)$} $gl -> s l q w]} {
					set spt "Google"
					set w0 [string range $ustr $s [expr {$s + $l}]]
						if {![string is space $w]} {
							append t "\"$w0\"" " \"\037[string trim $w0]\037 ([join [split [string trim $w]] ", "]) \" "
						} {
							append t "\"$w0\"" " \"\037[string trim $w0]\037 \" "
						}
				}
				if {[regexp -- {<error .*?pos="(\d+)".*?len="(\d+)".*?>} $gl -> s l]} {
					set spt "Yandex" ; set w ""
					regexp -- {<word>(.*?)</word>} $gl -> w0
					foreach {- r} [regexp -all -inline -- {<s>(.*?)</s>} $gl] {append w "$r "}
						if {![string is space $w]} {
							append t "\"$w0\"" " \"\037[string trim $w0]\037 ([join [split [string trim $w]] ", "]) \" "
						} {
							append t "\"$w0\"" " \"\037[string trim $w0]\037 \" "
						}
				}
			}
			lput putserv "\[$spt/Spell\] :: $ln[string map $t $ustr]" $prefix
		} {lput putserv "\037\[Spell\]\037 :: ${ustr}" $prefix}

	} ;# Yspell / Gspell

	if {$type == 9} {
		if {[regexp -- {"translatedText":"(.*?)"\}} $str -> t]} {lput putserv "\[Google/Trans\] :: $t" $prefix 
		} elseif {[regexp -- {"language":"(.*?)".*?"isReliable":(.*?),.*?"confidence":(.*?)\}} $str - l r c]} {
			set glang {af Africaans sq Albanian am Amharic ar Arabic hy Armenian az Azerbaijani eu Basque be Belarusian bn Bengali bh Bihari bg Bulgarian my Burmese ca Catalan chr Cherokee zh Chinese zh-CN Chinese_simpl zh-TW Cninese_trad hr Croatian cs Czech da Danish dv Dhivehi nl Dutch en English eo Esperanto et Estonian tl Filipino fi Finnish fr French gl Galician ka Georgian de German el Greek gn Guarani gu Gujarati iw Hebrew hi Hindi hu Hungarian is Icelandic id Indonesian iu Inuktitut it Italian ja Japanese kn Kannada kk Kazakh km Khmer ko Korean ku Kurdish ky Kyrgyz lo Laothian lv Latvian lt Lithuanian mk Macedonian ms Malay ml Malayam mt Maltese mr Marathi mn Mongolian ne Nepali no Norwegian or Oriya ps Pashto fa Persian pl Polish pt-PT Portuguese pa Punjabi ro Romanian ru Russian sa Sanskrit sr Serbian sd Sindhi si Singhalese sk Slovak sl Slovenian es Spanish sw Swahili sv Swedish tg Tajik ta Tamil tl Tagalog te Telugu th Thai bo Tibetan tr Turkish uk Ukrainian ur Urdu uz Uzbek ug Uighur vi Vietnamese}
 			lput putserv "\[Google/Detect\] :: [list [string map $glang $l] :: ($r / $c)]" $prefix
		} {lput putserv "\[Google/Trans\] :: \037��� ��������\037." $prefix}
	} ;# Google Translate / Detect

	return
	}		
#----------------------------------------------------------------------------
##---end-parser------
#----------------------------------------------------------------------------

	proc sspace {strr} {return [string trim [regsub -all {[\t\s]+} $strr { }]]}
	proc frmd {strr} {return [clock format [clock scan [string range $strr 0 9]] -format %d-%m-%Y]}
	proc uenc {strr} {return [encoding convertto cp1251 [string map {\& "&amp;" \" "&quot;" < "&lt;" > "&gt;"} $strr]]}

	proc uencg {strr} {
	set str "" ; foreach byte [split [encoding convertto utf-8 $strr] ""] {scan $byte %c i ; if {[string match {[%<>"]} $byte] || $i < 65 || $i > 122} {append str [format %%%02X $i]} {append str $byte}}
	return [string map {%3A : %2D - %2E . %30 0 %31 1 %32 2 %33 3 %34 4 %35 5 %36 6 %37 7 %38 8 %39 9 \[ %5B \\ %5C \] %5D \^ %5E \_ %5F \` %60} $str]
    }

	proc sconv {strr {mode {1}}} {
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
		if {$mode} {
			set strr [string map {\[ \\\[ \] \\\] \( \\\( \) \\\) \{ \\\{ \} \\\} \\ \\\\} [string map $escapes [join [lrange [split $strr] 0 end]]]] 
  			regsub -all -- {&#([[:digit:]]{1,5});} $strr {[format %c [string trimleft "\1" "0"]]} strr
 			regsub -all -- {&#x([[:xdigit:]]{1,4});} $strr {[format %c [scan "\1" %x]]} strr
 			regsub -all -- {&#?[[:alnum:]]{2,7};} $strr "" strr
			return [subst -nov $strr]
		} {return [string map $escapes $strr]}
	}

	proc lput {cmd str {prefix {}} {maxchunk 420}} {
	set buf1 "" ; set buf2 [list]
		foreach word [split $str] {append buf1 " " $word ; if {[string length $buf1]-1 >= $maxchunk} {lappend buf2 [string range $buf1 1 end]; set buf1 ""}}
		if {$buf1 != ""} {lappend buf2 [string range $buf1 1 end]}
	foreach line $buf2 {$cmd $prefix$line}
	return
	}

	proc queue_isfreefor {{ id {}}} {
		variable reqqueue ; variable maxreqperuser ; variable maxrequests
		variable laststamp ; variable pause
		variable err_queue_full	; variable err_queue_id ; variable err_queue_time 

		if {[info exists laststamp(stamp,$id)]} {set timewait [expr {$laststamp(stamp,$id) + $pause - [unixtime]}] ; if {$timewait > 0} {return [subst -nocommands $err_queue_time]}}
		if {[llength [array names reqqueue -glob "*,$id"]] >= $maxreqperuser} {return $err_queue_id}
		if {[llength [array names reqqueue]] >= $maxrequests} {return $err_queue_full}		
	return
	}

	proc queue_add {newurl id parser extra {redir 0}} {
		variable reqqueue ; variable proxy ; variable timeout
		variable laststamp ; variable query ; variable type

		::http::config -proxyfilter "[namespace current]::queue_proxy"
		if {$query eq ""} {
			if {![catch {set token [::http::geturl $newurl -command [namespace current]::queue_done -binary true -timeout $timeout]} errid]} {					
			set reqqueue($token,$id) [list $parser $extra $redir] ; set laststamp(stamp,$id) [unixtime]
			} {return false}
		} {
			if {![catch {set token [::http::geturl $newurl -command [namespace current]::queue_done -binary true -timeout $timeout -query ${query}]} errid]} {					
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
		upvar #0 ${token} state
		variable reqqueue ; variable maxredir ; variable fetchurl

		set errid  		[::http::status ${token}]
		set errstr 		[::http::error  ${token}]		
		set	id  		[array  names reqqueue "$token,*"]
		foreach {parser extra redir} $reqqueue($id) {break}
		regsub -- "^$token," $id {} id
	
		while (1) {
			if {$errid == "ok" && [::http::ncode $token] == 302} {
				if {$redir < $maxredir} {			
					array set meta $state(meta)
					if {[info exists meta(Location)]} {queue_add "$meta(Location)" $id $parser $extra [incr redir]; putlog "redir: $meta(Location)" ; break}
				} {set errid "error" ; set errstr "Max. redir."}
			} 
			
			if {[catch {$parser {errid} {errstr} {state(body)} {extra}} errid]} {lput putlog [string range $errid 0 50] "[namespace current] - "}
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

# json from tcllib
	proc getc {{txtvar txt}} {
    upvar 1 $txtvar txt
    if {$txt eq ""} {return -code error "unexpected end of text"}
    set c [string index $txt 0] ; set txt [string range $txt 1 end]
    return $c
	}

	proc json2dict {txt} {return [_json2dict]}

	proc _json2dict {{txtvar txt}} {
    upvar 1 $txtvar txt

    set state TOP

    set txt [string trimleft $txt]
    while {$txt ne ""} {
    	set c [string index $txt 0]
    	while {[string is space $c]} {getc ; set c [string index $txt 0]}

	if {$c eq "\{"} {
	    switch -- $state {
		TOP {getc ; set state OBJECT ; set dictVal [dict create]}
		VALUE {dict set dictVal $name [_json2dict] ; set state COMMA}
		LIST {lappend listVal [_json2dict] ; set state COMMA}
		default {return -code error "unexpected open brace in $state mode"}
	    }
	} elseif {$c eq "\}"} {
	    getc ; if {$state ne "OBJECT" && $state ne "COMMA"} {return -code error "unexpected close brace in $state mode"} ; return $dictVal
	} elseif {$c eq ":"} {
	    getc ; if {$state eq "COLON"} {set state VALUE} {return -code error "unexpected colon in $state mode"}
	} elseif {$c eq ","} {
	    if {$state eq "COMMA"} {
		getc
		if {[info exists listVal]} {
		    set state LIST
		} elseif {[info exists dictVal]} {
		    set state OBJECT
		}
	    } else {
		return -code error "unexpected comma in $state mode"
	    }
	} elseif {$c eq "\""} {
	    set reStr {(?:(?:\")(?:[^\\\"]*(?:\\.[^\\\"]*)*)(?:\"))}
	    set string ""
	    if {![regexp $reStr $txt string]} {
		set txt [string replace $txt 32 end ...]
		return -code error "invalid formatted string in $txt"
	    }
	    set txt [string range $txt [string length $string] end]
	    set string [subst -nocommand -novariable \
			    [string range $string 1 end-1]]

	    switch -- $state {
		TOP {return $string}
		OBJECT {set name $string ; set state COLON}
		LIST {lappend listVal $string ; set state COMMA}
		VALUE {dict set dictVal $name $string ; unset name ; set state COMMA}
	    }
	} elseif {$c eq "\["} {
	    switch -- $state {
		TOP {getc ; set state LIST}
		LIST {lappend listVal [_json2dict] ; set state COMMA}
		VALUE {dict set dictVal $name [_json2dict] ; set state COMMA}
		default {return -code error "unexpected open bracket in $state mode"}
	    }
	} elseif {$c eq "\]"} {
	    getc ; if {![info exists listVal]} {return ""}
	    return $listVal
	} elseif {0 && $c eq "/"} {
	    getc ; set c [getc]
	    switch -- $c {
		/ {
		    # // comment form
		    set i [string first "\n" $txt]
		    if {$i == -1} {
			set txt ""
		    } else {
			set txt [string range $txt [incr i] end]
		    }
		}
		* {
		    # /* comment */ form
		    getc
		    set i [string first "*/" $txt]
		    if {$i == -1} {
			return -code error "incomplete /* comment"
		    } else {
			set txt [string range $txt [incr i] end]
		    }
		}
		default {
		    return -code error "unexpected slash in $state mode"
		}
	    }
	} elseif {[string match {[-0-9]} $c]} {
	    string is double -failindex last $txt
	    if {$last > 0} {
		set num [string range $txt 0 [expr {$last - 1}]]
		set txt [string range $txt $last end]

		switch -- $state {
		    TOP {return $num}
		    LIST {lappend listVal $num ; set state COMMA}
		    VALUE {dict set dictVal $name $num ; set state COMMA}
		    default {getc ; return -code error "unexpected number '$c' in $state mode"}
		}
	    } {getc ; return -code error "unexpected '$c' in $state mode"}
	} elseif {[string match {[ftn]} $c]
		  && [regexp {^(true|false|null)} $txt val]} {
	    set txt [string range $txt [string length $val] end]

	    switch -- $state {
		TOP {return $val}
		LIST {lappend listVal $val ; set state COMMA}
		VALUE {dict set dictVal $name $val ; set state COMMA}
		default {getc ; return -code error "unexpected '$c' in $state mode"}
	    }
	} else {
	    return -code error "unexpected '$c' in $state mode"
	}
    }
	} ;#json

#---init
	if {[info exists timerID]} {catch {killtimer $timerID} ; catch {unset timerID}}	
	[namespace current]::queue_clear_stamps
	foreach bind [binds "[namespace current]::*"] {catch {unbind [lindex $bind 0] [lindex $bind 1] [lindex $bind 2] [lindex $bind 4]}}
	if {[catch {source [string map {.tcl .set} [info script]] ; set cfig "external"}]} {set cfig "internal"}
	[namespace current]::cmdaliases
	putlog "[namespace current] v$version [expr {[info exists ::sp_version]?"(suzi_$::sp_version)":""}] :: file:[lindex [split [info script] "/"] end] / rel:\[$date\] / mod:\[[clock format [file mtime [info script]] -format "%d-%b-%Y : %H:%M:%S"]\] :: config: $cfig :: by $author :: loaded."

} ;#end searcher











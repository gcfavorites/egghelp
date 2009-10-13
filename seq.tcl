#----------------------------------------------------------------------------
# seq - информация о товарах
#----------------------------------------------------------------------------

package require Tcl 	8.4
package require http	2.5

namespace eval seq {
foreach p [array names seq *] { catch {unset seq ($p) } }

#----------------------------------------------------------------------------
# Первичные параметры конфигурации (Suzi / http.tcl)
#----------------------------------------------------------------------------
	# сведения о разработчике скрипта, версии, дате последней модификации
	variable author			"anaesthesia"
	variable version		"01.01"
	variable date			"12-dec-2007"

	# имя нэймспэйса без ведущих двоеточий
	variable unamespace		[string range [namespace current] 2 end]

	# префикс для публичных команд (может быть пустой строкой)
	variable pubprefix 		{!}
	variable pubflag		{-|-}

	# pubcmd:имя_обработчика "вариант1 вариант2 ..."
	# команда и её публичные варианты, строка в которой варианты разделены пробелом
	variable pub:seq		"$unamespace"

	# тоже что и выше, для приватных команд
	variable msgprefix		{!}
	variable msgflag		{-|-}
	# такие же команды как для публичных алиасов
	variable msg:seq		${pub:seq}

	# можно отключить приватные или публичные команды, указав в качестве алиасов пустую строку
	# или закоменнтировав объявление  variable [pub|msg]:handler "string ..."

	# какие идентификаторы используются для различения запросов
	# доступны $unick, $uhost, $uchan
	# обычное tcl выражение, позволяющие сформировать уникальный id для
	# идентификации запроса.
	variable requserid		{$uhost}
	
	# максимальное число ожидающих выполнения запросов для одного id
	variable maxreqperuser	1

	# максимальное число ожидающих выполнения запросов
	variable maxrequests	5

	# пауза между запросами, в течении которой сервис недоступен для использования, 
	# секунд 
	variable pause			15
	
	# адрес прокси-сервера
	# строка вида "proxyhost.dom:proxyport" или пустая строка, если прокси-сервис
	# не используется
	variable proxy 			{}

	# поведение канального флага, если значение "" -- носит разрешающий
	# характер, то есть если этот флаг установлен на канале -- сервис работает
	# если "no" значения этой переменной указывают что флаг носит запрещающий
	# характер и будучи установлен на канале запрещает работу сервиса
	# (при этом сервис работает на ВСЕХ каналах, где не установлене этот флаг)
	variable flagactas		""
	
	# имя канального флага, служащего для включения/выключения сервиса на канале
	# по умолчанию формируется из режима работы флага и имени неймспейса
	# в данном случае режим работы запрещающий  
	# при установке на канале запрещает работу

	variable chflag			"$flagactas$unamespace"

	setudef  flag 			$chflag

#----------------------------------------------------------------------------
# Вторичные параметры конфигурации
#----------------------------------------------------------------------------
	# вести лог запросов -- пустая строка лог не ведётся
	# иначе форматированный вывод в лог
	variable logrequests	{'$unick', '$uhost', '$handle', '$uchan', '$ustr'}
	
	# Команда вывода для публичного запроса, по умолчанию -- на канал
	# доступны $uchan & $unick
	variable pubsend		{PRIVMSG $uchan :}

	# Команда вывода для приватного запроса, по умолчанию -- приватное сообщение
	# доступно только $unick ($uchan == $unick)
	variable msgsend		{PRIVMSG $unick :}
	
	# команда вывода для ошибок/недоступности сервиса
	# доступны $unick
	variable errsend		{NOTICE $unick :}

	# Максимальное число редиректов с запрошенной страницы
	variable maxredir		1
	
	# Таймаут запроса в миллисекундах, то есть 30 секунд
	variable timeout		30000

	# сообщение о принятии запроса
	variable err_ok			{Ваш запрос принят}

	# сообщение о невозможности получить данные, разницы в ошибках не делается
	# просто сообщается о невозможности их получить 
	variable err_fail		{к сожалению Ваш запрос не выполнен. Возможно не удалось связаться с интернет-сервисом.}

	# сообщение о заполненности очереди запросов
	variable err_queue_full	{в данное время очередь сервиса заполнена и не может выполнить Ваш запрос. Повторите попытку позже.}
	
	# сообщение о заполненности очереди для конкретного id
	variable err_queue_id	{пожалуйста дождитесь обработки предыдущих запросов.}
	
	# сообщение о том что пауза между использованиями сервиса не истекла
	# доступна переменная $timewait -- оставшееся время, по истечении которого
	# сервис будет доступен
	variable err_queue_time {пожалуйста повторите попытку позже. Сервис будет доступен для использования через $timewait сек.}
	
#----------------------------------------------------------------------------
#  Внутренние переменные и код
#----------------------------------------------------------------------------
	# количество выводимых результатов
	variable maxres		19

	# адрес, с которого происходит получение информации
	variable 		fetchurl		"http://www.research.att.com/~njas/sequences/?fmt=1&language=russian&p=1&n=20&hl=1&q="

	# очередь запросов
	variable 		reqqueue
	array unset 	reqqueue

	# последние таймстампы
	variable 		laststamp
	array unset		laststamp 

	variable 		cityid
	array unset		cityid 

	variable		updinprogress	0

	variable		updatetimeout	60000

#---body---

	proc tolow {strr} {
    	return [string tolower [string map {Й й Ц ц У у К к Е е Н н Г г Ш ш Щ щ З з Х х Ъ ъ Ф ф Ы ы В в А а П п Р р О о Л л Д д Ж ж Э э Я я Ч ч С с М м И и Т т Ь ь Б б Ю ю Ё ё} $strr]]
	}

	proc sspace {strr} {
  		return [string trim [regsub -all {[\t\s]+} $strr { }]]
	}

	proc msg:seq { unick uhost handle str } {
		pub:seq $unick $uhost $handle $unick $str
		return
	}

	proc pub:seq { unick uhost handle uchan str } {

		variable requserid
		variable fetchurl
		variable chflag
		variable flagactas
		variable errsend
		variable cityid		
		variable maxres
		variable pubprefix
		variable pubsend
		variable msgsend
		variable unamespace
		variable mpage
		variable query

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

#---параметры

	if { [regexp -nocase -- {^-(\d+)} $str -> mpg] } { 
		set mpage $mpg
		regsub -- {-\d+\s+} $str "" str
		 } else {
		set mpage 1
		}

	set ustr [string map { " " "+" } [tolow $str]]
#	set ustr [tolow $str]

		if {$ustr == ""} {
			if { $uchan eq $unick } {
			set prefix [subst -nocommands $errsend]
			} else {
			set prefix [subst -nocommands $pubsend]
			}
		lput puthelp "\002Формат\002: !seq \[-номер результата\] <последовательность чисел>" $prefix		
		lput puthelp "Введите ряд чисел, и система сообщит вам, по какому принципу он построен. \002Пример:\002 !seq 2,4,8,16,32,64" $prefix		
		return
		}

		variable logrequests

		if { $logrequests ne "" } {
			set logstr [subst -nocommands $logrequests]
			variable unamespace
			lput putlog $logstr "$unamespace: "
		}

#		set query [::http::formatQuery exp $ustr posted "1"]
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
		variable useurl
		variable maxres
		variable mpage

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

#regexp -nocase -- {<!-- END AD TAG -->(.*?)<!--- end of central table --->} $dstr -> str

	if {[string match "*&#1048;&#1079;&#1074;&#1080;&#1085;&#1080;&#1090;&#1077;, &#1087;&#1086;&#1089;&#1083;&#1077;&#1076;&#1086;&#1074;&#1072;&#1090;&#1077;&#1083;&#1100;&#1085;&#1086;&#1089;&#1090;&#1100; &#1086;&#1090;&#1089;&#1091;&#1090;&#1089;&#1090;&#1074;&#1091;&#1077;&#1090; &#1074; &#1073;&#1072;&#1079;&#1077; &#1076;&#1072;&#1085;&#1085;&#1099;&#1093;*" $str]} {
		lput putserv "\037ничего не найдено\037." $prefix
		return
	}

		regsub -all -- "\n|\r" $str {} str
		regsub -all -- "</table>" $str "\n" str

		set count 0
		foreach line [split $str \n] {

			if {[regexp {<td valign=top align=left>(.*?)<.*?>} $line -> qres]} {
				regsub -all -- "<.*?>" $qres {} qres

			incr count
				if {$count == $mpage} {
				set qr $qres
				}
			}
		if {$count > $maxres} {break}
		}
	if {$count != 0 && $count >= $mpage} {
		lput putserv "\($mpage\/$count\) :: [sconv [sspace $qr]]" $prefix
	} else {
		lput putserv "Вы пытаетесь найти \002$mpage\002-й результат из найденных \002$count\002" $prefix
	}

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
&#163;     Ј     &#168;     Ё     &#169;     ©     &#171;     «      &#173;     ­     &#174;     ®
&#161;     Ў     &#191;     ї     &#180;     ґ     &#183;     ·      &#185;     №     &#187;     »
&#188;     ј     &#189;     Ѕ     &#190;     ѕ     &#192;     А      &#193;     Б     &#194;     В
&#195;     Г     &#196;     Д     &#197;     Е     &#198;     Ж      &#199;     З     &#200;     И
&#201;     Й     &#202;     К     &#203;     Л     &#204;     М      &#205;     Н     &#206;     О
&#207;     П     &#208;     Р     &#209;     С     &#210;     Т      &#211;     У     &#212;     Ф
&#213;     Х     &#214;     Ц     &#215;     Ч     &#216;     Ш      &#217;     Щ     &#218;     Ъ
&#219;     Ы     &#220;     Ь     &#221;     Э     &#222;     Ю      &#223;     Я     &#224;     а
&#225;     б     &#226;     в     &#227;     г     &#228;     д      &#229;     е     &#230;     ж
&#231;     з     &#232;     и     &#233;     й     &#234;     к      &#235;     л     &#236;     м
&#237;     н     &#238;     о     &#239;     п     &#240;     р      &#241;     с     &#242;     т
&#243;     у     &#244;     ф     &#245;     х     &#246;     ц      &#247;     ч     &#248;     ш
&#249;     щ     &#250;     ъ     &#251;     ы     &#252;     ь      &#253;     э     &#254;     ю
&#176;     °     &#8231;    ·     &#716;     .     &#363;     u      &#299;     i     &#712;     '
&#596;     o     &#618;     i     </li>      ""    <cite>     ""     </cite>    ""    </ol>      ""
"<br />"   ""    <tt>       ""    </tt>      ""    &#147;     '      &#148;     '     <em>       ""
</em>      ""  <BLOCKQUOTE> ""  </BLOCKQUOTE> ""   &#146;     '      <dd>       ""    </dd>      ""
<dl>       ""    </dl>      ""    <dt>       ""    </dt>      ""     <ol>       ""    </p>       ""
&#331;     n     &#8212;    "-"   &#491;     Q     &#771;     ~      &#365;     u     <br/>      ""
<br>       ""    &#483;     "ae"  &#603;     e     <div>      ""     </div>     ""    <sub>      ""
</sub>     ""    &#8810;    "<<"  &#601;     e     &#375;     э      &#593;     a     &#650;     u
&#703;     c     <tbody>    ""    </tbody>   ""    \{         (     \}          ) 	&dagger; 	" им. "
}
	return [string map -nocase $smaps $txt]
}

#--вывод с проверкой длины строки и переносом по словам
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
		variable query

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

#---clear
	proc queue_clear_stamps {} {

		variable laststamp
		variable timeout
		variable timerID

		set curr [expr { [unixtime] - 2 * $timeout / 1000 }];
#		putlog "dbg: $curr"		

		foreach { id } [array names laststamp] {
			if { $laststamp($id) < $curr } {
				array unset laststamp $id;
			}
		}		

#		putlog "dbg: [array get laststamp]"

		set timerID [timer 10 "[info level 0]"]
	}

#---command aliases & bnd
	proc cmdaliases { { action {bind} } } {
		foreach { bindtype } {pub msg dcc} {
			foreach { bindproc } [info vars "[namespace current]::${bindtype}:*"] {
				variable "${bindtype}prefix"
				variable "${bindtype}flag"			
				foreach { alias } [set $bindproc] {
#					putlog "$action $bindtype [set ${bindtype}flag] [set ${bindtype}prefix]$alias $bindproc"
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











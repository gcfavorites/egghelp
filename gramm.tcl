#----------------------------------------------------------------------------
# gramota - словарь
# включение скрипта на канале - .chanset #chan +gramota
# :: Формат: !грамота [@[словарь]] [+] <слово>	
# :: параметр '+' - расширенный поиск
# :: параметр '@' или '@словарь' - поиск в словарях
# :: Примеры: !грамота + профессор (в словах можно использовать символ '*', если не уверены в написании, например: пр*фес*ор		
# ::          !грамота @ профессор (или !грамота @dahl профессор - поиск в указанном словаре)		
#----------------------------------------------------------------------------

package require Tcl 	8.4
package require http	2.5

namespace eval gramota {
foreach p [array names gramota *] { catch {unset gramota ($p) } }

#----------------------------------------------------------------------------
# Первичные параметры конфигурации (Suzi / http.tcl)
#----------------------------------------------------------------------------
	# сведения о разработчике скрипта, версии, дате последней модификации
	variable author			"anaesthesia"
	variable version		"01.1"
	variable date			"02-apr-2008"

	# имя нэймспэйса без ведущих двоеточий
	variable unamespace		[namespace tail [namespace current]]

	# префикс для публичных команд (может быть пустой строкой)
	variable pubprefix 		{!}
	variable pubflag		{-|-}

	# pubcmd:имя_обработчика "вариант1 вариант2 ..."
	# команда и её публичные варианты, строка в которой варианты разделены пробелом
	variable pub:gramota		"$unamespace enc gramota грамота"

	# тоже что и выше, для приватных команд
	variable msgprefix		$pubprefix
	variable msgflag		{-|-}
	# такие же команды как для публичных алиасов
	variable msg:gramota		${pub:gramota}

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
	variable maxredir		3
	
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
	# адрес, с которого происходит получение информации
	variable 		furl		"http://www.gramota.ru/slovari/dic/"
	variable 		furld		"http://www.diclib.com"

	# количество выводимых результатов
	variable maxres		10

	# очередь запросов
	variable 		reqqueue
	array unset 	reqqueue

	# последние таймстампы
	variable 		laststamp
	array unset		laststamp 

	variable		updinprogress	0
	variable		updatetimeout	60000

#---body---

	proc tolow {strr} {
    	return [string tolower [string map {Й й Ц ц У у К к Е е Н н Г г Ш ш Щ щ З з Х х Ъ ъ Ф ф Ы ы В в А а П п Р р О о Л л Д д Ж ж Э э Я я Ч ч С с М м И и Т т Ь ь Б б Ю ю Ё ё} $strr]]
	}

	proc sspace {strr} {
  		return [string trim [regsub -all {[\t\s]+} $strr { }]]
	}

	proc msg:gramota { unick uhost handle str } {
		pub:gramota $unick $uhost $handle $unick $str
		return
	}

	proc pub:gramota { unick uhost handle uchan str } {

		variable requserid
		variable fetchurl
		variable furld
		variable furl
		variable chflag
		variable flagactas
		variable errsend
		variable msgsend
		variable pubsend
		variable maxres
		variable pubprefix
		variable unamespace
		variable gsite
		variable ustrr

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
	set ustr [tolow $str]

		if {$ustr == ""} {
			if { $uchan eq $unick } {
			set prefix [subst -nocommands $msgsend]
			} else {
			set prefix [subst -nocommands $pubsend]
			}
			lput puthelp "\002Формат\002: $pubprefix\грамота \[@\[словарь\]\] \[\+\] <слово>" $prefix		
			lput puthelp "параметр '\002+\002' - расширенный поиск. \002Пример\002: $pubprefix\грамота + профессор (в словах можно использовать \002*\002, если не уверены в написании, пример: пр*фес*ор" $prefix		
			lput puthelp "параметр '\002@\002' - поиск в словарях. \002Пример\002: $pubprefix\грамота @ профессор (или $pubprefix\грамота @dahl профессор)" $prefix		
		return
		}

		if { [string match "*@*" $ustr] } {
				if { [regexp -- {@(.*?)\s} $ustr -> slov] } { set slov [string trim $slov] ; regsub -- $slov $ustr "" ustr }
				set fetchurl "$furld\/cgi-bin/d.cgi?page=search&vkb=0&base=$slov&prefbase=&newinput=1&l=ru&category=cat1&p="
				set ustr [string map {"@" "" "+" ""} $ustr]
				set gsite 1
		} else {
			if 	{ [string match "*+*" $ustr] } { 
				set fetchurl "$furl\?lop=x&gorb=x&efr=x&ag=x&zar=x&ab=x&sin=x&lv=x&pe=x&word="
				set ustr [string map {"@" "" "+" ""} $ustr]
			} else {
				set fetchurl "$furl\?efr=x&word="
			}
				set gsite 0
		}

		set ustrr $ustr
		variable logrequests

		if { $logrequests ne "" } {
			set logstr [subst -nocommands $logrequests]
			variable unamespace
			lput putlog $logstr "$unamespace: "
		}

		::http::config -urlencoding cp1251 -useragent "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; 240x320)"	
	
		if { [queue_add "$fetchurl[uenc [string trim $ustr]]" $id "[namespace current]::dream:parser" [list $unick $uhost $uchan {}]] } {
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
		variable gsite
		variable pubprefix
		variable ustrr

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
	if {$gsite} {
#--diclib.com
	if {[regexp -nocase -- {<td style="border: #FFFFFF 1px solid" width="1" align="left" valign="top">(.*?)<td valign="top" align="left" style="border-left: 1px solid #DFDFDF">} $str -> dstr]} {
##-TODO	- переделать регекспы	
		regsub -all -- "\n|\r" $dstr {} dstr
		regsub -all -- "Результаты поиска " $dstr {} dstr
		regsub -all -- {(\d+\.)} $dstr " \002\\1\002" dstr
		regsub -all -nocase -- {<b>} $dstr "\002" dstr
		regsub -all -nocase -- {</b>} $dstr "\002" dstr
		regsub -all -nocase -- {<h1 style="font-size: 18px">} $dstr "\037" dstr
		regsub -all -nocase -- {</h1>} $dstr "\037\n" dstr
		regsub -all -nocase -- {<font size="3">} $dstr "\n" dstr
		regsub -all -nocase -- {<font color="gray">} $dstr "\00314" dstr
		regsub -all -nocase -- {<font color="green">} $dstr "\00303" dstr
		regsub -all -nocase -- {<font color="red">} $dstr "\00304" dstr
		regsub -all -nocase -- {</font>} $dstr "\003" dstr
		regsub -all -nocase -- {<a href=.*?>} $dstr "\00302" dstr
		regsub -all -nocase -- {</a>} $dstr "\003" dstr
		regsub -all -nocase -- "<br>" $dstr { } dstr
		regsub -all -nocase -- "<tr>" $dstr { } dstr
		regsub -all -nocase -- "<.*?>" $dstr {} dstr

		if { [string match "*Ничего не найдено*" $dstr] } {
			lput putserv "\037Ничего не найдено\037." $prefix
		} else {
			foreach aline [split $dstr \n] {
				lput putserv "[sconv [sspace $aline]]" $prefix
			}
		}
	} else {
			lput putserv "\037Ничего не найден0\037." $prefix
	}

	if {[regexp -nocase -- {<td valign="top" align="left" style="border-left: 1px solid #DFDFDF">(.*?)<!-- HotLog -->} $str -> ostr]} {
		regsub -all -- "\n|\r" $ostr {} ostr
		regsub -all -- "</a>" $ostr "</a>\n" ostr
		set od ""
			foreach oline [split $ostr \n] {
				if { [regexp -nocase -- {<a class=\"vmenu2\".*?base=(.*?)\&prefbase.*?\((.*?)\)</a>} $oline -> odic onum] } { 
				append od "\@$odic ($onum) "
				}
			}
		if {[llength $od]} {lput putserv "\037Найдено в других словарях\037: $od :: Поиск: $pubprefix\грамота @словарь [string trim $ustrr]" $prefix}
	}

return

	} else {
#--gramota.ru
#		regexp -nocase -- {<!--/LiveInternet-->(.*?)</html>} $str -> dstr

		regsub -all -- "\n|\r" $str {} str
		regsub -all -- "</div>" $str "</div>\n" str
			if { [regexp -nocase -- {<p style="padding-left:50px">(.*?)</p>} $str -> gword] } {
				regsub -all -nocase -- {<b>} $gword "\002" gword
				regsub -all -nocase -- {</b>} $gword "\002" gword
				regsub -all -nocase -- {<i>} $gword "\00314" gword
				regsub -all -nocase -- {</i>} $gword "\003" gword
				regsub -all -nocase -- {<li>} $gword "\00314* \003" gword
				regsub -all -nocase -- {<span class=\"accent\">} $gword "\0034" gword
				regsub -all -nocase -- {</span>} $gword "\003" gword
				regsub -all -nocase -- "<.*?>" $gword {} gword
				lput putserv "\037Искомое слово отсутствует\037. Похожие слова: [sconv $gword]" $prefix
			return
			}
		set count 0
		foreach line [split $str \n] {

			if { [regexp -nocase -- {<h2>(.*?)</h2>.*?<div\ style=\"padding\-left\:50px\">(.*?)</div>} $line -> gdic gword] } {
				regsub -all -nocase -- {<b>} $gword "\002" gword
				regsub -all -nocase -- {</b>} $gword "\002" gword
				regsub -all -nocase -- {<i>} $gword "\00314" gword
				regsub -all -nocase -- {</i>} $gword "\003" gword
				regsub -all -nocase -- {<li>} $gword "\00314* \003" gword
				regsub -all -nocase -- {<span class=\"accent\">} $gword "\0034" gword
				regsub -all -nocase -- {</span>} $gword "\003" gword
				regsub -all -nocase -- {<SUP>(\d+)</SUP>} $gword " \00314\(\\1\)\003 " gword

				regsub -all -nocase -- "</OL>" $gword "\n" gword

				regsub -all -nocase -- "<br>" $gword { } gword
				regsub -all -nocase -- "<.*?>" $gword {} gword
				regsub -all -nocase -- "<.*?>" $gdic {} gdic

				if {![string match {искомое*слово*отсутствует} $gword]} {
				lput putserv "\037\[$gdic\]\037" $prefix
					foreach aline [split $gword \n] {
						if {![string is space $aline]} {lput putserv "[sconv $aline]" $prefix}
					}
					incr count
					if {$count == $maxres} {break}
				} 
			}
		}
		if {$count == 0} { lput putserv "\037Ничего не найдено\037." $prefix }
return
	} ;#gsite
}		
#----------------------------------------------------------------------------
##---ok------
#----------------------------------------------------------------------------

#---декодирование специальных символов
	proc sconv {text} {
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
	};
	set text [string map $escapes [join [lrange [split $text] 0 end]]]; 
    regsub -all -- {\[} $text "\\\[" text
    regsub -all -- {\]} $text "\\\]" text
    regsub -all -- {\(} $text "\\\(" text
    regsub -all -- {\)} $text "\\\)" text
  	regsub -all -- {&#([[:digit:]]{1,5});} $text {[format %c [string trimleft "\1" "0"]]} text
 	regsub -all -- {&#x([[:xdigit:]]{1,4});} $text {[format %c [scan "\1" %x]]} text
 	regsub -all -- {&#?[[:alnum:]]{2,7};} $text "" text
	return [subst -novariables $text]
	}

#---кодирование url
	proc uenc {strr} {
	set str ""
		foreach byte [split [encoding convertto cp1251 $strr] ""] {
        scan $byte %c i
        	if {[string match {[%<>"]} $byte] || $i < 65 || $i > 122} {
				append str [format %%%02X $i]
        	} else {
				append str $byte
        	}
		}
	return [string map {%3A : %2D - %2E . %30 0 %31 1 %32 2 %33 3 %34 4 %35 5 %36 6 %37 7 %38 8 %39 9 \[ %5B \\ %5C \] %5D \^ %5E \_ %5F \` %60} $str]
    }

#---вывод с проверкой длины строки и переносом по словам
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

#---очередь
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

#---добавление в очередь
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

#---прокси
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
						queue_add "$meta(Location)" $id $parser $extra [incr redir]
						break
					}
				} else {
					set errid   "error"
					set errstr  "Максимальное количество переадресаций"
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

#---алиасы и бинды
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
#---done	
	[namespace current]::queue_clear_stamps
	cmdaliases
	global sp_version
	if {[info exists sp_version]} {
	putlog "[namespace current] v$version suzi_$sp_version \[$date\] by $author loaded."
	} else {
	putlog "[namespace current] v$version \[$date\] by $author loaded."
	}
}











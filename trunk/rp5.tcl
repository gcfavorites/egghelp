#----------------------------------------------------------------------------
# rp5 			-прогноз погоды
# Включение:	.chanset #chan +rp5
# Формат:		!rp5 [-номер результата] [+день] <город>
#				* если найдено несколько одноименных городов, то параметр '-номер результата' выбирает следующий город 
# Алиасы:		!прогноз !п
# Вопросы:		anaesthesia #eggdrop@Rusnet
# Оффсайт:		http://www.egghelp.ru
#----------------------------------------------------------------------------
# v.1.02		-исправление бага транслитерации на сайте rp5.ru
# v.1.03		-фикс показа прогноза на следующие дни

package require Tcl 	8.4
package require http	2.5

namespace eval rp5 {
#----------------------------------------------------------------------------
# Первичные параметры конфигурации
#----------------------------------------------------------------------------
	# сведения о разработчике скрипта, версии, дате последней модификации
	variable author			"anaesthesia"
	variable version		"01.03"
	variable date			"08-Jul-2009"
	variable unamespace		[namespace tail [namespace current]]

	# префикс для публичных команд (может быть пустой строкой)
	variable pubprefix 		{!}
	variable pubflag		{-|-}

	# команды вызова (бинды)
	# pubcmd:имя_обработчика "вариант1 вариант2 ..."
	# команда и её публичные варианты, строка в которой варианты разделены пробелом
	variable pub:rp5		"$unamespace прогноз п"

	# тоже что и выше, для приватных команд
	variable msgprefix		{!}
	variable msgflag		{-|-}

	# такие же команды как для публичных алиасов
	variable msg:rp5		${pub:rp5}

	#* можно отключить приватные или публичные команды, указав в качестве алиасов пустую строку
	#* или закоменнтировав объявление  variable [pub|msg]:handler "string ..."

	# какие идентификаторы используются для различения запросов
	# доступны $unick, $uhost, $uchan
	# обычное tcl выражение, позволяющие сформировать уникальный id для идентификации запроса.
	variable requserid		{$uhost}
	
	# максимальное число ожидающих выполнения запросов для одного id
	variable maxreqperuser	1

	# максимальное число ожидающих выполнения запросов
	variable maxrequests	5

	# пауза между запросами, в течении которой сервис недоступен для использования, секунд 
	variable pause			15
	
	# адрес прокси-сервера
	# строка вида "proxyhost.dom:proxyport" или пустая строка, если прокси-сервис не используется
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
	variable maxredir		3
	
	# Таймаут запроса в миллисекундах, то есть 30 секунд
	variable timeout		30000

	# сообщение о принятии запроса
	variable err_ok			{}

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
	variable maxres		5

	# адрес, с которого происходит получение информации
	variable 		fetchurl		"http://pda.rp5.ru/"
	
	# очередь запросов
	variable 		reqqueue
	array unset 	reqqueue

	# последние таймстампы
	variable 		laststamp
	array unset		laststamp 
	variable		updinprogress	0
	variable		updatetimeout	60000

#---body---

	proc msg:rp5 {unick uhost handle str} {pub:rp5 $unick $uhost $handle $unick $str ; return}

	proc pub:rp5 {unick uhost handle uchan str} {
		variable requserid ; variable unamespace
		variable chflag ; variable flagactas ; variable logrequests
		variable pubprefix ; variable pubsend ; variable msgsend ; variable errsend
		variable maxres ; variable type ; variable mpage ; variable mday
		variable query ; variable fetchurl

		set id [subst -noc $requserid]
		set prefix [subst -noc $errsend]
		if {$unick ne $uchan} {if {![channel get $uchan $chflag] ^ $flagactas eq "no" } {return}}
		set why  [queue_isfreefor $id]
		if {$why != ""} {lput puthelp $why $prefix ; return}
		set query ""

#---параметры
# rp5 translit fix
		set ustr [string map -nocase {а a б b в v г g д d е e ё e ж zh з z и i й y к k л l м m н n о o п p р r с s т t у u ф f х kh ц ts ч ch ш sh щ sch ъ \"\" ы y ь \' э e ю yu я ya} $str]

		if {[regexp -- {^-(\d+)} $ustr -> mpage]} {regsub -- {-\d+\s+} $ustr "" ustr} {set mpage 1}
		if {[regexp -- {^\+(\d+)} $ustr -> mday]} {regsub -- {\+\d+\s+} $ustr "" ustr ; set mday ".$mday"} {set mday ""}
		::http::config -urlencoding utf-8 -useragent "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; 240x320)"	
		set furl "${fetchurl}?q=[uenc $ustr]"	
			if {[string is space $ustr]} {
				set prefix [subst -noc $msgsend]
				lput puthelp "\002Формат\002: $pubprefix$unamespace \[-номер результата\] \[+число\] <город>" $prefix		
				lput puthelp "\002Пример\002: $pubprefix$unamespace +1 москва :: погода в Москве на завтра. " $prefix		
			return
			}

		if {$logrequests ne ""} {set logstr [subst -noc $logrequests] ; lput putlog $logstr "$unamespace: "}
		if {[queue_add "$furl" $id "[namespace current]::rp5:parser" [list $unick $uhost $uchan {}]]} {
			variable err_ok ; if {$err_ok ne ""} {lput puthelp "$err_ok." $prefix}
		} {
			variable err_fail ; if {$err_fail ne ""} {lput puthelp "$err_fail" $prefix}
		}

	return
	}

#---parser
	proc rp5:parser {errid errstr body extra} {
		upvar $errid lerrid $errstr lerrstr $body lbody $extra lextra
		variable err_fail ; variable pubsend ; variable msgsend ; variable errsend
		variable maxres ; variable mpage ; variable mday ; variable fetchurl

		foreach {unick uhost uchan ustr} $lextra {break}
		if {$lerrid ne {ok}} {lput putserv [subst -noc $err_fail] [subst -noc $errsend] ; return}
		if {$uchan eq $unick} {set prefix [subst -noc $msgsend]} {set prefix [subst -noc $pubsend]}
		if {[info exists ::sp_version]} {set str [encoding convertfrom utf-8 $lbody]} {set str $lbody}

#----------------------------------------------------------------------------
##---parser-specific------
#----------------------------------------------------------------------------
	if {[regexp -- {<p class="navy">(.+?)<form.*?>} $str -> rcit]} {
		set clist [list]
		foreach {- cnum cnam} [regexp -all -inline -- {<a href="(.+?)/ru">(.+?)</a>} $rcit] {lappend clist "$cnum $cnam"}
		if {[llength $clist]} {queue_add "${fetchurl}[lindex $clist [expr {$mpage - 1}] 0]$mday" [unixtime] "[namespace current]::rp5:parser" [list $unick $uhost $uchan $clist]}
	} elseif {[regexp -- {<h1>(.+?)</h1><table>(.+?)</table>} $str -> rcity rdata]} {
		regsub -all -- "\n|\r|\t" $rdata "" rdata
		regsub -all -- "</td></tr><tr><td>" $rdata "\n" rdata
		regsub -all -- {<.*?>} [string map {"<b>" "\002" "</b>" "\002" "<font color=\"red\">" "\00304" "</font>" "\003" "<b class=\"blue\">" ":: \002" "<b class=\"red\">" ":: \002" "&ordm;" " "} $rdata] " " rdata
		set rdata "\[$mpage/[llength $ustr]\] :: \002$rcity\002 :: \[[lrange [lindex $ustr [expr {$mpage - 1}]] 1 end]\] :: [sq $rdata]"
		foreach rline [split $rdata \n] {lput putserv [sspace $rline] $prefix}
	} {lput putserv "\037Ничего не найдено\037." $prefix}

	return
	}		
#----------------------------------------------------------------------------
##---end-parser------
#----------------------------------------------------------------------------

	proc sspace {strr} {return [string trim [regsub -all {[\t\s]+} $strr { }]]}

	proc uenc {strr} {
		set str "" ; foreach byte [split [encoding convertto utf-8 $strr] ""] {scan $byte %c i ; if {[string match {[%<>"]} $byte] || $i < 65 || $i > 122} {append str [format %%%02X $i]} {append str $byte}}
	return [string map {%3A : %2D - %2E . %30 0 %31 1 %32 2 %33 3 %34 4 %35 5 %36 6 %37 7 %38 8 %39 9 \[ %5B \\ %5C \] %5D \^ %5E \_ %5F \` %60} $str]
    }

	proc lput {cmd str {prefix {}} {maxchunk 420}} {
		set buf1 ""; set buf2 [list]
		foreach word [split $str] {append buf1 " " $word ; if {[string length $buf1]-1 >= $maxchunk} {lappend buf2 [string range $buf1 1 end]; set buf1 ""}}
		if {$buf1 != ""} {lappend buf2 [string range $buf1 1 end]}
		foreach line $buf2 {$cmd $prefix$line}
	return
	}

	proc sq {strr} {return [string map {"облачность" "обл." "влажность" "влж." "ветер" "вет." "давление" "двл."} $strr]}

	proc queue_isfreefor {{ id {}}} {
		variable reqqueue ; variable maxreqperuser ; variable maxrequests ; variable laststamp
		variable pause ; variable err_queue_full ; variable err_queue_id ; variable err_queue_time 

		if {[info exists laststamp(stamp,$id)]} {set timewait [expr {$laststamp(stamp,$id) + $pause - [unixtime]}] ; if {$timewait > 0} {return [subst -noc $err_queue_time]}}
		if {[llength [array names reqqueue -glob "*,$id"]] >= $maxreqperuser} {return $err_queue_id}
		if {[llength [array names reqqueue]] >= $maxrequests} {return $err_queue_full}		
	return
	}

	proc queue_add {newurl id parser extra {redir 0}} {
		variable reqqueue ; variable proxy ; variable timeout ; variable laststamp ; variable query ; variable type

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

	proc queue_proxy {url} {
		variable proxy
		if {$proxy ne {}} {return [split $proxy {:}]}		
	return [list]
	}
	
	proc queue_done {token} {
		upvar #0 $token state
		variable reqqueue ; variable maxredir ; variable fetchurl

		set errid  	[::http::status $token]
		set errstr 	[::http::error  $token]		
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

#---init
	if {[info exists timerID]} {catch {killtimer $timerID} ; catch {unset timerID}}	
	[namespace current]::queue_clear_stamps
	foreach bind [binds "[namespace current]::*"] {catch {unbind [lindex $bind 0] [lindex $bind 1] [lindex $bind 2] [lindex $bind 4]}}
	[namespace current]::cmdaliases
  	variable sfil [lindex [split [info script] "/"] end]
  	variable modf [clock format [file mtime [info script]] -format "%d-%b-%Y : %H:%M:%S"]
	if {[info exists ::sp_version]} {putlog "[namespace current] v$version (suzi_$sp_version) :: file:$sfil / rel:\[$date\] / mod:\[$modf\] :: by $author :: loaded."} {putlog "[namespace current] v$version :: file:$sfil / rel:\[$date\] / mod:\[$modf\] :: by $author :: loaded."}

} ;#end











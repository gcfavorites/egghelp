#----------------------------------------------------------------------------
# musmap		-поиск похожих фильмов или музыки
# Включение:	.chanset #chan +musmap
# Формат:		!musmap <name>
#				!movmap	<name>
# Алиасы:		!musicmap !moviemap
# Вопросы:		anaesthesia #eggdrop@Rusnet
# Оффсайт:		http://egghelp.ru
#----------------------------------------------------------------------------

package require Tcl 	8.5
package require http	2.5

namespace eval musmap {

#----------------------------------------------------------------------------
# Первичные параметры конфигурации (Suzi / http.tcl)
#----------------------------------------------------------------------------
	# сведения о разработчике скрипта, версии, дате последней модификации
	variable author			"anaesthesia"
	variable version		"01.02"
	variable date			"29-Dec-2007"

	# имя нэймспэйса без ведущих двоеточий
	variable unamespace		[namespace tail [namespace current]]

	# префикс для публичных команд (может быть пустой строкой)
	variable pubprefix 		{!}
	variable pubflag		{-|-}

	# команды вызова
	variable musbnd 		{musmap musicmap}
	variable movbnd			{movmap moviemap}

	# pubcmd:имя_обработчика "вариант1 вариант2 ..."
	# команда и её публичные варианты, строка в которой варианты разделены пробелом
	variable pub:musmap		"$musbnd $movbnd"

	# тоже что и выше, для приватных команд
	variable msgprefix		$pubprefix
	variable msgflag		{-|-}
	# такие же команды как для публичных алиасов
	variable msg:musmap		${pub:musmap}

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

	# пауза между запросами, в течении которой сервис недоступен для использования, секунд 
	variable pause			30
	
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
	variable maxredir		2
	
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
	# доступна переменная $timewait -- оставшееся время, по истечении которого сервис будет доступен
	variable err_queue_time {пожалуйста повторите попытку позже. Сервис будет доступен для использования через $timewait сек.}
	
#----------------------------------------------------------------------------
#  Внутренние переменные и код
#----------------------------------------------------------------------------
	# адрес, с которого происходит получение информации
	variable 		furlmus		"http://www.music-map.com"
	variable		furlmov		"http://www.movie-map.com"

	# количество выводимых результатов
	variable maxres		1

	# очередь запросов
	variable 		reqqueue
	array unset 	reqqueue

	# последние таймстампы
	variable 		laststamp
	array unset		laststamp 
	variable		updinprogress	0
	variable		updatetimeout	60000

#---body---

	proc tolow {strr} {return [string tolower [string map {Й й Ц ц У у К к Е е Н н Г г Ш ш Щ щ З з Х х Ъ ъ Ф ф Ы ы В в А а П п Р р О о Л л Д д Ж ж Э э Я я Ч ч С с М м И и Т т Ь ь Б б Ю ю Ё ё} $strr]]}
	proc sspace {strr} {return [string trim [regsub -all {[\t\s]+} $strr { }]]}
	proc chkrusl {symb} {if {[lsearch -exact {Й Ц У К Е Н Г Ш Щ З Х Ъ Ф Ы В А П Р О Л Д Ж Э Я Ч С М И Т Ь Б Ю Ё й ц у к е н г ш щ з х ъ ф ы в а п р о л д ж э я ч с м и т ь б ю ё} $symb] > -1} {return 1} {return 0}}

	proc chkrus {strr} {
  		set len [string length $strr]
  		set cnt 0 ; while {$cnt < $len} {if {[chkrusl [string index $strr $cnt]]} {return 1} ; incr cnt}
  	return 0
	}

	proc msg:musmap {unick uhost handle str} {
		pub:musmap $unick $uhost $handle $unick $str
		return
	}

	proc pub:musmap {unick uhost handle uchan str} {
		variable requserid ; variable chflag ; variable flagactas ; variable errsend
		variable maxres ; variable pubprefix ; variable pubsend ; variable msgsend ; variable unamespace ; variable logrequests
		variable musbnd ; variable movbnd ; variable fetchurl ; variable furlmov ; variable furlmus

		set id 	 [subst -noc $requserid]
		set prefix [subst -noc $errsend]
		if {$unick ne $uchan} {if {![channel get $uchan $chflag] ^ $flagactas eq "no"} {return}}
		set why [queue_isfreefor $id]
		if {$why != ""} {lput puthelp $why $prefix ; return}

#---параметры
	set ustr [string map { " " "+" } [tolow $str]]

		if {$ustr == "" || [chkrus $ustr]} {
			if {$uchan eq $unick} {set prefix [subst -noc $msgsend]} {set prefix [subst -noc $pubsend]}
		lput puthelp "\002Формат\002: \002${pubprefix}[lindex $musbnd 0]\002 <name> или \002${pubprefix}[lindex $movbnd 0]\002 <name> \(имя пишите \037латиницей\037\)" $prefix		
		lput puthelp "Поиск похожих музыкальных групп или фильмов. \002Пример:\002 ${pubprefix}[lindex $musbnd 0] nine inch nails" $prefix		
		return
		}
		if {[string trimleft $::lastbind $pubprefix] in $musbnd} {set fetchurl $furlmus} {set fetchurl $furlmov}

		if {$logrequests ne ""} {set logstr [subst -noc $logrequests] ; lput putlog $logstr "$unamespace: "}
		::http::config -useragent "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; 240x320)"	

		if {[queue_add "${fetchurl}/map-search.php?f=${ustr}" $id "[namespace current]::musmap:parser" [list $unick $uhost $uchan {}]]} {
			variable err_ok ; if {$err_ok ne ""} {lput puthelp "$err_ok." $prefix}
		} {
			variable err_fail ; if {$err_fail ne ""} {lput puthelp $err_fail $prefix}
		}

	return
	}

#---parser
	proc musmap:parser {errid errstr body extra} {
		upvar $errid lerrid $errstr lerrstr $body lbody $extra lextra
		variable err_fail ; variable pubsend ; variable msgsend ; variable errsend ; variable useurl ; variable maxres

		foreach {unick uhost uchan ustr} $lextra {break}
		if {$lerrid ne {ok}} {lput putserv [subst -noc $err_fail] [subst -noc $errsend] ; return}
		if {$uchan eq $unick} {set prefix [subst -noc $msgsend]} {set prefix [subst -noc $pubsend]}
#--suzi-patch
	if {[info exists ::sp_version]} {set str $lbody} {set str $lbody}

#----------------------------------------------------------------------------
##---parser-specific------
#----------------------------------------------------------------------------
		regsub -all -- "\n|\r" $str {} str

	if {[regexp {gnodMapSettings.*?</script>(.*?)<script>} $str -> res]} {
		regsub -all -- "<a href.*?>" $res " \002*\002 " res
		regsub -all -- "<.*?>" $res {} res
		lput putserv "[sspace $res]" $prefix
	} {
		lput putserv "MusicMap: \037ничего не найдено\037." $prefix
		return
	}

	return
	}		
#----------------------------------------------------------------------------
##---ok------
#----------------------------------------------------------------------------

	proc lput {cmd str {prefix {}} {maxchunk 420}} {
	set buf1 "" ; set buf2 [list]
		foreach word [split $str] {append buf1 " " $word ; if {[string length $buf1]-1 >= $maxchunk} {lappend buf2 [string range $buf1 1 end] ; set buf1 ""}}
		if {$buf1 != ""} {lappend buf2 [string range $buf1 1 end]}
		foreach line $buf2 {$cmd $prefix$line}
	return
	}

#---queue
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

#---add-to-queue
	proc queue_add {newurl id parser extra {redir 0}} {
		variable reqqueue ; variable proxy ; variable timeout ; variable laststamp

		::http::config -proxyfilter "[namespace current]::queue_proxy"
		
		if {![catch {
			set token [::http::geturl $newurl -command "[namespace current]::queue_done" -binary true -timeout $timeout]} errid]} {
			set reqqueue($token,$id) [list $parser $extra $redir]		
			set laststamp(stamp,$id) [unixtime]
		} {return false}
	return true
	}

#---proxy
	proc queue_proxy {url} {
		variable proxy
		if {$proxy ne {}} {return [split $proxy {:}]}		
	return [list]
	}
	
#---callback
	proc queue_done {token} {
		upvar #0 $token state
		variable reqqueue ; variable maxredir 
		
		set errid  	[::http::status $token]
		set errstr 	[::http::error  $token]
		set	id  	[array  names reqqueue "$token,*"]
		foreach {parser extra redir} $reqqueue($id) {break}
		regsub -- "^$token," $id {} id
	
		while (1) {
			if {$errid == "ok" && [::http::ncode $token] == 302} {
				if {$redir < $maxredir} {			
					array set meta $state(meta)
					if {[info exists meta(Location)]} {variable fetchurl ; queue_add "$fetchurl$meta(Location)" $id $parser $extra [incr redir] ; break}
				} {set errid   "error" ; set errstr  "Maximum redirects reached"}
			} 
			if {[catch {$parser {errid} {errstr} {state(body)} {extra}} errid]} {lput putlog $errid "[namespace current] "}
		break
		}
			
		array unset reqqueue "$token,*"
		::http::cleanup $token

	return
	}

#---clear
	proc queue_clear_stamps {} {
		variable laststamp ; variable timeout ; variable timerID

		set curr [expr { [unixtime] - 2 * $timeout / 1000 }]
		foreach {id} [array names laststamp] {if {$laststamp($id) < $curr} {array unset laststamp $id}}		
		set timerID [timer 10 "[info level 0]"]
	}

#---command aliases & bnd
	proc cmdaliases {{action {bind}}} {
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
	if {[info exists timerID]} {catch {killtimer $timerID} ; catch {unset timerID}}
#---rest	
	[namespace current]::queue_clear_stamps
	[namespace current]::cmdaliases
  	variable sfil [lindex [split [info script] "/"] end]
  	variable modf [clock format [file mtime [info script]] -format "%d-%b-%Y : %H:%M:%S"]
	if {[info exists ::sp_version]} {putlog "[namespace current] v$version (suzi_$sp_version) :: file:$sfil / rel:\[$date\] / mod:\[$modf\] :: by $author :: loaded."} {putlog "[namespace current] v$version :: file:$sfil / rel:\[$date\] / mod:\[$modf\] :: by $author :: loaded."}

}











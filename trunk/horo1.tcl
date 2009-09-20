# Дуроскоп - генератор псевдослучайных текстов
# v.1.5 - добавлен новый сайт и новые типы гироскопов
# Включение скрипта: 			.chanset #chan +horoscope
# Тихий режим (вывод в приват):	.chanset #chan +horoscopeq

package require Tcl 	8.4
package require http	2.5

namespace eval horoscope {

# ---------------------------------------------------------------------------
# Параметры конфигурации
# ---------------------------------------------------------------------------

	variable author			"Suzi /mod anaesthesia"
	variable version		"01.5"
	variable date			"18-may-2008"

	# имя нэймспэйса без ведущих двоеточий
	variable unamespace		[namespace tail [namespace current]]

	# префикс для публичных команд (может быть пустой строкой)
	variable pubprefix 		{!}

	# pubcmd:имя_обработчика "алиас1 алиас2 ..."
	# команда и её публичные алиасы, строка в которой алиасы разделены пробелом
	variable pub:horoscope	"$unamespace гороскоп horo горо"

	# тоже что и выше, для приватных команд
	variable msgprefix		{!}
	# такие же команды как для публичных алиасов, но приватные команды работают без префикса
	# (префикс -- пустая строка)
	variable msg:horoscope	${pub:horoscope}

	# можно отключить приватные или публичные команды, указав в качестве алиасов пустую строку
	# или закоменнтировав объявление  variable [pub|msg]:handler "string ..."

	# какие идентификаторы используются для различения запросов
	# допступны $unick, $uhost, $uchan
	# обычное tcl выражение, позволяющие сформировать уникальный id для
	# идентификации запроса.
	variable requserid		{$unick}
	
	# максимальное число ожидающих выполнения запросов для одного id
	variable maxreqperuser	1

	# максимальное число ожидающих выполнения запросов
	variable maxrequests	10

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
	setudef	 flag			$chflag\q
# ---------------------------------------------------------------------------
# Менее интересные параметры конфигурации
# ---------------------------------------------------------------------------
	# вести лог запросов -- пустая строка лог не ведётся
	# иначе форматированный вывод в лог
	variable logrequests	{'$unick', '$uhost', '$handle', '$uchan', '$ustr'}
	
	# Команда вывода для публичного запроса, по умолчанию -- нотис
	# доступны $uchan & $unick
	variable pubsend		{PRIVMSG $uchan :}

	# Команда вывода для приватного запроса, по умолчанию --приватное сообщение
	# доступно только $unick ($uchan == $unick)
	variable msgsend		{PRIVMSG $unick :}
	
	# команда вывода для ошибок/недоступности сервиса
	# доступны $unick
	variable errsend		{NOTICE $unick :$unick, }

	# Максимальное число редиректов с запрошенной страницы
	variable maxredir		1
	
	# Таймаут запроса в миллисекундах, то есть 20 секунд
	variable timeout		30000

	# сообщение о принятии запроса
	variable err_ok			{}

	# сообщение о невозможности получить данные, разницы в ошибках не делается
	# просто сообщается о невозможности их получить 
	variable err_fail		{к сожалению Ваш запрос не выполнен. Произошла ошибка. Возможно не удалось связаться с интернет-сервисом.}

	# сообщение о заполненности очереди запросов
	variable err_queue_full	{в данное время очередь сервиса заполнена и не может выполнить Ваш запрос. Повторите попытку позже.}
	
	# сообщение о заполненности очереди для конкретного id
	variable err_queue_id	{пожалуйста дождитесь обработки предыдущих запросов.}
	
	# сообщение о том что пауза между использованиями сервиса не истекла
	# доступна переменная $timewait -- оставшееся время, по истечении которого
	# сервис будет доступен
	variable err_queue_time {пожалуйста повторите попытку позже. Сервис будет доступен для использования через $timewait сек.}
	
# ---------------------------------------------------------------------------
# Совсем неинтересно, внутренние переменные и код
# ---------------------------------------------------------------------------
	# адрес, с которого происходит получение информации
	variable 		fetchurl		"http://horo.ru/lov"
	variable		fetchurlp		"http://horo.ukr.net/horoscope/astro"

	variable 		reqqueue
	array unset 	reqqueue
	variable 		laststamp
	array unset		laststamp 

	proc tolow {strr} {
    	return [string tolower [string map {Й й Ц ц У у К к Е е Н н Г г Ш ш Щ щ З з Х х Ъ ъ Ф ф Ы ы В в А а П п Р р О о Л л Д д Ж ж Э э Я я Ч ч С с М м И и Т т Ь ь Б б Ю ю Ё ё} $strr]]
	}

	proc sspace {strr} {
  		return [string trim [regsub -all {[\t\s]+} $strr { }]]
	}

	proc msg:horoscope { unick uhost handle str } {
		pub:horoscope $unick $uhost $handle $unick $str
		return
	}

	proc pub:horoscope { unick uhost handle uchan str } {

		variable requserid
		variable fetchurl
		variable fetchurlp
		variable chflag
		variable flagactas
		variable errsend
		variable pubsend
		variable msgsend
		variable htype

		set id 	 [regsub -all -- {[][${}\\]} [subst -nocommands $requserid] {}]

		if { $uchan eq $unick || [channel get $uchan $chflag\q]} {
			set prefix [subst -nocommands $msgsend]
		} else {
			set prefix [subst -nocommands $pubsend]
		}

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

		array set daysyn { 
			завтра		{tom}
			tomorrow 	{tom}
			сегодня		{tod}
			today		{tod}
			вчера		{yes}
			yesterday	{yes}
		}

		array set daysynp {
			завтра		{tomorrow}
			сегодня		{today}
			вчера		{yesterday}
			неделя		{week}
			месяц		{month}
			год			{year}
		}

		array set hvid {
			флирт		flirt
			семейный	family
			карьерный	career
			здоровье	health
			тинейджер	teen
			амигос		amigos
			любовный	love
		}

		array set lovesyn {
			любовный    1
			love        1
			лав         1
		}

		array set signsyn {
			овен		aries
			aries		aries
			телец		taurus
			taurus		taurus
			близнецы    gemini
			gemini		gemini
			рак			cancer
			cancer		cancer
			лев			leo
			leo			leo
			дева		virgo
			virgo		virgo
			весы		libra
			libra		libra
			скорпион	scorpio
			scorpio		scorpio
			стрелец		sagittarius
			sagittarius	sagittarius
			козерог		capricorn
			capricorn	capricorn
			водолей		aquarius
			aquarius	aquarius
			рыбы		pisces
			pisces		pisces
		}

	if {[regexp -- {\+} $str]} {
		regsub -- {\+} $str {} str
		set ustr [string trim [tolow $str]]
		set wtype		{more}
		set wday        {today}
		set wlove 		{0}
		set wsign		{}
		set valid		{1}
		set htype		{0}

		foreach { wrd } [split $ustr] {

			if { [string length $wrd] >= 3 } {
				set wrd [string tolower "$wrd*"];
				set lvals [array names signsyn -glob $wrd];
				if { [llength $lvals] == 1 } {
					set wsign $signsyn($lvals)
					continue
				}

				set lvals [array names daysynp -glob $wrd];
				if { [llength $lvals] == 1 } {
					set wday $daysynp($lvals)
					set wdayname $wrd
					continue
				} else { set wdayname "сегодня" }

				set lvals [array names hvid -glob $wrd];
				if { [llength $lvals] == 1 } {
					set wtype $hvid($lvals)
					continue
				}
			}

			set valid {0}
			break;
		}

	} else {
		set ustr [string trim [tolow $str]]

		set wlove 		{0}
		set wday        {tod}
		set wsign		{}
		set valid		{1}
		set htype		{1}

		foreach { wrd } [split $ustr] {

			if { [string length $wrd] >= 3 } {
				set wrd [string tolower "$wrd*"];
				set lvals [array names signsyn -glob $wrd];
				if { [llength $lvals] == 1 } {
					set wsign $signsyn($lvals)
					continue
				}

				set lvals [array names daysyn -glob $wrd];
				if { [llength $lvals] == 1 } {
					set wday $daysyn($lvals)
					set wdayname $wrd
					continue
				} else { set wdayname "сегодня" }

				set lvals [array names lovesyn -glob $wrd];
				if { [llength $lvals] == 1 } {
					set wlove $lovesyn($lvals)
					continue
				}
			}
			
			set valid {0}
			break;
		}
	} ;#type

		if { !$valid || $wsign eq "" } {
			lput putserv "\037Полный гороскоп\037: \002!гороскоп +\002 \[флирт|семейный|карьерный|здоровье|тинейджер|амигос|любовный\] <Овен|Телец|Близнецы|Рак|Лев|Дева|Весы|Скорпион|Стрелец|Козерог|Водолей|Рыбы> \[завтра|вчера|неделя|месяц|год\]" $prefix
			lput putserv "\002Пример\002: !гороскоп + стрелец флирт завтра" $prefix
			lput putserv "\037Краткий гороскоп\037: \002!гороскоп\002 \[любовный\] <Овен|Телец|Близнецы|Рак|Лев|Дева|Весы|Скорпион|Стрелец|Козерог|Водолей|Рыбы> \[завтра|сегодня|вчера\]" $prefix
			lput putserv "\002Пример\002: !гороскоп рыбы или !гороскоп любовный овен завтра" $prefix
			return;
		}

		if { $wday eq {yes} } { set wdayname {вчера} }
		if { $wday eq {tod} || $wday eq {today} } { set wdayname {сегодня} }
		if { $wday eq {tom} } { set wdayname {завтра} }

	if {$htype == 1} {
		set furl "$fetchurl/$wday/$wsign.html"
	} else {
		if {$wday eq ""} {set wday "today"}
		if {$wtype eq "" && ($wday eq "today" || $wday eq "tomorrow" || $wday eq "yesterday")} {set wtype "more"} 
		if {$wtype eq "" && ($wday eq "week" || $wday eq "month" || $wday eq "year")} {set wtype "general"} 
		set furl "$fetchurlp/$wtype/$wday/$wsign.html"
	}
		variable logrequests

		if { $logrequests ne "" } {
			set logstr [subst -nocommands $logrequests]
			variable unamespace
			lput putlog $logstr "$unamespace: $furl : "
		}

		if { [queue_add "$furl" $id "[namespace current]::horoscope:parser" [list $unick $uhost $wdayname $uchan $wlove]] } {
			variable err_ok
			if { $err_ok ne "" } {
				lput puthelp $err_ok $prefix
			}
		} else {
			variable err_fail
			if { $err_fail ne "" } {
				lput puthelp $err_fail $prefix
			}
		}

		return
	}

	proc horoscope:parser { errid errstr body extra } {
		upvar $errid lerrid $errstr lerrstr $body lbody $extra lextra

		variable err_fail
		variable chflag
		variable pubsend
		variable msgsend
		variable errsend
		variable htype

		foreach { unick uhost uhandle uchan ustr } $lextra { break }

		if { $lerrid ne {ok} } {
			lput putserv [subst -nocommands $err_fail] [subst -nocommands $errsend]
			return
		}

	global sp_version
	if {[info exists sp_version]} {	
		set str [encoding convertfrom cp1251 $lbody] 
		} else {
		set str $lbody
		}

		if { $uchan eq $unick || [channel get $uchan $chflag\q]} {
			set prefix [subst -nocommands $msgsend]
		} else {
			set prefix [subst -nocommands $pubsend]
		}

	if {$htype == 1} {

		if { [regexp -nocase -- {<h2>(.+?)</h2>.*?<!--text begin-->(.+?)<!--text end-->.*?<h2>(.+?)</h2>.*?<!--r.daily.tom._file_.text-->(.+?)</div>} $str -> lovesign lovehoro gensign genhoro] } {
			
			if { $ustr eq "1" } {
				lput putserv "\00305$lovesign\003 \002::\002 [sspace $lovehoro]" $prefix
			} else {
				lput putserv "\00305$gensign\003  \002::\002 [sspace $genhoro]" $prefix
			}
		} else {
			lput putserv "\037Ошибка парсинга\037." [subst -nocommands $errsend]
		}

	} else {

	set data $str
		regsub -all -- \n $data {} data
		regsub -all -- {>\ +<} $data {><} data
		regsub -all -- {^\ +} $data "" data
		regsub -all -- {\ +} $data { } data
		regsub -all -- {</([^<]+)> +<} $data {</\1><} data
		regsub -all -- {<br />} $data "" data
   			foreach item [split $data \n] {
   				if { [regexp -- {<div\ class=.*?\ id=.*?><h2\ class=.*?\ id=\"inl\">(.*?)</h2><h2 class=\"inl\">(.*?)</h2><h3 class=\"cat\" id=.*?>(.*?)</h3>} $item g chislo horolove2 horoobsh]} {
   					lput putserv "\00310 [sspace $chislo] $horolove2 \003:: \00303 Раздел: $horoobsh\003" $prefix
				}
   				if { [regexp -- {<h4>(.*?)<span class=.*?>(.*?)</span></h4></div><p>(.*?)</p>} $item g q w e]} {
   					lput putserv "\00303 $q $w\003 :: $e" $prefix
					return
   				}
			lput putserv "\037Ошибка парсинга\037." [subst -nocommands $errsend]
			}
	}	
	return
}
# ---------------------------------------------------------------------------
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

	proc queue_add { newurl id parser extra {redir 0} } {
		variable reqqueue
		variable proxy
		variable timeout
		variable laststamp

		::http::config -proxyfilter "[namespace current]::queue_proxy"

		if { ![catch {
			set token [::http::geturl $newurl -command "[namespace current]::queue_done" -binary true -timeout $timeout]
			} errid] } {
					
			set reqqueue($token,$id) [list $parser $extra $redir]		
			set laststamp(stamp,$id) [unixtime]

		} else {
			return false
		}

		return true
	}

	proc queue_proxy { url } {
		variable proxy
		if { $proxy ne {} } { return [split $proxy {:}] }		
		return [list]
	}
	
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

	proc cmdaliases { { action {bind} } } {
		foreach { bindtype } {pub msg dcc} {
			foreach { bindproc } [info vars "[namespace current]::${bindtype}:*"] {
				variable "${bindtype}prefix"
				foreach { alias } [set $bindproc] {
					catch { $action $bindtype -|- [set ${bindtype}prefix]$alias $bindproc }
				}				
			}
		}
		
		return
	}
	
	if {[info exists timerID]} {
		catch {killtimer $timerID}; 
		catch {unset timerID}
	}
	
	[namespace current]::queue_clear_stamps
	cmdaliases
	global sp_version
	if {[info exists sp_version]} {
	putlog "[namespace current] v$version suzi_$sp_version \[$date\] by $author loaded."
	} else {
	putlog "[namespace current] v$version \[$date\] by $author loaded."
	}}

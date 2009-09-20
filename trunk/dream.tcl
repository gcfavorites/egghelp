# Для включения скрипта на канале необходимо в патилайне бота выполнить команду:
#   .chanset #канал +dream
# Команды скрипта:
#   !dream, !сонник
#######################################################################################

package require Tcl 	8.4
package require http	2.5

namespace eval dream {

# ---------------------------------------------------------------------------
# Параметры конфигурации
# ---------------------------------------------------------------------------
	# сведения о разработчике скрипта, версии, дате последней модификации

	variable author			"Suzi /mod anaesthesia"
	variable version		"01.05"
	variable date			"21-may-2008"

	# имя нэймспэйса без ведущих двоеточий
	variable unamespace		[namespace tail [namespace current]]

	# префикс для публичных команд (может быть пустой строкой)
	variable pubprefix 		{!}

	# pubcmd:имя_обработчика "алиас1 алиас2 ..."
	# команда и её публичные алиасы, строка в которой алиасы разделены пробелом
	# в данном случае будут работать публичные команды "+dream" и "+сонник"
	variable pub:dream		"$unamespace сонник"

	# тоже что и выше, для приватных команд
	variable msgprefix		{!}
	# такие же команды как для публичных алиасов, но приватные команды работают без префикса
	# (префикс -- пустая строка)
	variable msg:dream		${pub:dream}

	# можно отключить приватные или публичные команды, указав в качестве алиасов пустую строку
	# или закоменнтировав объявление  variable [pub|msg]:handler "string ..."

	# какие идентификаторы используются для различения запросов
	# допступны $unick, $uhost, $uchan
	# обычное tcl выражение, позволяющие сформировать уникальный id для
	# идентификации запроса.
	variable requserid		{$uhost}
	
	# максимальное число ожидающих выполнения запросов для одного id
	variable maxreqperuser	1

	# максимальное число ожидающих выполнения запросов
	variable maxrequests	10

	# пауза между запросами, в течении которой сервис недоступен для использования, 
	# секунд 
	variable pause			30
	
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
	# в данном случае режим работы запрещающий и имя флага -- "nodream"
	# при установке на канале запрещает работу

	variable chflag			"$flagactas$unamespace"

	setudef  flag 			$chflag

# ---------------------------------------------------------------------------
# Менее интересные параметры конфигурации
# ---------------------------------------------------------------------------
	# вести лог запросов -- пустая строка лог не ведётся
	# иначе форматированный вывод в лог
	variable logrequests	{'$unick', '$uhost', '$handle', '$uchan', '$ustr'}
	
	# Команда вывода для публичного запроса, по умолчанию -- нотис
	# доступны $uchan & $unick
	variable pubsend		{PRIVMSG $unick :}

	# Команда вывода для приватного запроса, по умолчанию --приватное сообщение
	# доступно только $unick ($uchan == $unick)
	variable msgsend		{PRIVMSG $unick :}
	
	# команда вывода для ошибок/недоступности сервиса
	# доступны $unick
	variable errsend		{NOTICE $unick :$unick, }

	# Максимальное число редиректов с запрошенной страницы
	variable maxredir		1
	
	# Таймаут запроса в миллисекундах, то есть 20 секунд
	variable timeout		60000

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
	variable 		fetchurl		"http://www.sonnik.ru"

	# очередь запросов
	variable 		reqqueue
	array unset 	reqqueue

	# последние таймстампы
	variable 		laststamp
	array unset		laststamp 

	proc msg:dream { unick uhost handle str } {
		pub:dream $unick $uhost $handle $unick $str
		return
	}

	proc pub:dream { unick uhost handle uchan str } {

		variable requserid
		variable fetchurl
		variable chflag
		variable flagactas
		variable errsend
		variable msgprefix
		
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

		set ustr $str
		if { $ustr eq "" } {
			lput puthelp "Непонятно нифига. Используйте: '${msgprefix}сонник слово'." $prefix
			return;
		}
					
		variable logrequests

		if { $logrequests ne "" } {
			set logstr [subst -nocommands $logrequests]
			variable unamespace
			lput putlog $logstr "$unamespace: "
		}

		::http::config -useragent "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; 240x320)" -urlencoding cp1251

		set query [::http::formatQuery key $ustr]
		variable fetchurl		

		if { [queue_add "$fetchurl/search.php?$query" $id "[namespace current]::dream:parser" [list $unick $uhost {} $uchan {}]] } {
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

	proc dream:parser { errid errstr body extra } {
		upvar $errid lerrid $errstr lerrstr $body lbody $extra lextra

		variable err_fail

		variable pubsend
		variable msgsend
		variable errsend

		foreach { unick uhost handle uchan str } $lextra { break }

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

		if { [regexp -nocase -- {<h2 title="(.*?)">.*?<p id="main3">(.*?)</p><br><p class="smalltxt">(.*?)</p>} $str -> info1 info2 info3] } {

			proc striphtmltags { str } {
				
				regsub -all -nocase -- {<strong>} $str "\00310\037" str
				regsub -all -nocase -- {</strong>} $str "\037\003" str
				regsub -all -nocase -- {<.*?>} $str "" str
				regsub -all -nocase -- {&nbsp;} $str " " str
			return [string trim $str]
			}
			
			if { $uchan eq $unick } {
				set prefix [subst -nocommands $msgsend]
			} else {
				set prefix [subst -nocommands $pubsend]
			}

			lput putserv "\00310$info1" $prefix
			lput putserv "$info2" $prefix
			lput putserv "\00310[striphtmltags $info3]" $prefix
		} else {
			lput putserv "\00302[subst -nocommands $err_fail]" [subst -nocommands $errsend]
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
	}
}

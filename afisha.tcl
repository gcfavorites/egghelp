#
# Yandex Afisha 
# 
# включение скрипта: .chanset #chan +afisha
# справка: !afisha

package require Tcl 	8.4
package require http	2

namespace eval afisha {
foreach p [array names afisha *] { catch {unset afisha ($p) } }

# ---------------------------------------------------------------------------
# Первичные параметры конфигурации (Suzi / http.tcl)
# ---------------------------------------------------------------------------
	# сведения о разработчике скрипта, версии, дате последней модификации
	variable author			"anaesthesia"
	variable version		"01.5"
	variable date			"20-sep-2007"

	# имя нэймспэйса без ведущих двоеточий
	variable unamespace		[string range [namespace current] 2 end]

	# префикс для публичных команд (может быть пустой строкой)
	variable pubprefix 		{!}
	variable pubflag		{-|-}

	# pubcmd:имя_обработчика "алиас1 алиас2 ..."
	# команда и её публичные алиасы, строка в которой алиасы разделены пробелом
	variable pub:afisha		"$unamespace afisha афиша"

	# тоже что и выше, для приватных команд
	variable msgprefix		{!}
	variable msgflag		{-|-}
	# такие же команды как для публичных алиасов
	variable msg:afisha		${pub:afisha}

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
	# в данном случае режим работы запрещающий и имя флага -- "nodream"
	# при установке на канале запрещает работу

	variable chflag			"$flagactas$unamespace"

	setudef  flag 			$chflag

# ---------------------------------------------------------------------------
# Вторичные параметры конфигурации
# ---------------------------------------------------------------------------
	# вести лог запросов -- пустая строка лог не ведётся
	# иначе форматированный вывод в лог
	variable logrequests	{'$unick', '$uhost', '$handle', '$uchan', '$str'}
	
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
	
# ---------------------------------------------------------------------------
#  Внутренние переменные и код
# ---------------------------------------------------------------------------

	# количество выводимых результатов
	variable maxres		5

	# адрес, с которого происходит получение информации
	variable 		fetchurl	""

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

proc fdate {strr} {
	return [string map {"Sunday" "Воскресенье" "Monday" "Понедельник" "Tuesday" "Вторник"  "Wednesday" "Среда" "Thursday" "Четверг" "Friday" "Пятница" "Saturday" "Суббота" 
 "January" "Января" "February" "Февраля" "March" "Марта" "April" "Апреля" "May" "Мая" "June" "Июня" "July" "Июля" "August" "Августа" "September" "Сентября" "October" "Октября" "November" "Ноября" "December" "Декабря" } [clock format [clock scan $strr] -format "%e %B (%A)"]] 
}

	proc msg:afisha { unick uhost handle str } {
		pub:afisha $unick $uhost $handle $unick $str
		return
	}

	proc pub:afisha { unick uhost handle uchan str } {

		variable requserid
		variable fetchurl
		variable chflag
		variable flagactas
		variable errsend
		variable cityid		
		variable pubprefix
		variable unamespace
		variable maxres
		variable logrequests
		
		global afdate
		global aftype
		global afpage
		global afcity
		global afs

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
#---разбор параметров----------
	set str [tolow $str]
#---строка поиска-s-(формирование урлы)
		set afs 0
	if { [regexp -nocase -- {\+(.+)} $str tr afsearch] } {
		set afsearch [string map { " " "+" } $afsearch]
		set fetchurl "http://www.afisha.yandex.ru/search/?&text=$afsearch"
		set afs 1 } else {
		set fetchurl "http://www.afisha.yandex.ru/chooser.xml?"
	} 
#---номер страницы-p
	if { [regexp -nocase -- {-p(\d+)} $str tr afpage] } {
		set afpage $afpage } else {
		set afpage 1
	}
#---дата-d
	if { [regexp -nocase -- {-d(\d+)} $str tr afdatep] } {
		set afdate [clock format [expr {[clock seconds] + $afdatep * 86400 }] -format "%Y-%m-%d"] } else {
		set afdate [clock format [clock seconds] -format "%Y-%m-%d"]
	}
#--город
	if 	{ [string match "*петербург*" $str] || [string match "*спб*" $str] } { 
		set afcity "&city=SPB" 
				} elseif {
		  [string match "*алма*" $str] } { 
		set afcity "&city=ATA" 
				} elseif { 
		  [string match "*волгоград*" $str] } { 
		set afcity "&city=VLG" 
				} elseif {  
		  [string match "*екатеринбург*" $str] || [string match "*ебург*" $str] } { 
		set afcity "&city=EKT" 
				} elseif {  
		  [string match "*иркутск*" $str] } { 
		set afcity "&city=IRK" 
				} elseif {
		  [string match "*казань*" $str] } { 
		set afcity "&city=KZN" 
				} elseif {
		  [string match "*киев*" $str] } { 
		set afcity "&city=KYV" 
				} elseif {
		  [string match "*краснодар*" $str] } { 
		set afcity "&city=KRD" 
				} elseif {
		  [string match "*мурманск*" $str] } { 
		set afcity "&city=MRM" 
				} elseif {
		  [string match "*новгород*" $str] } { 
		set afcity "&city=NNV" 
				} elseif {
		  [string match "*новосибирск*" $str] || [string match "*нск*" $str]} { 
		set afcity "&city=NVS" 
				} elseif {
		  [string match "*одесса*" $str] } { 
		set afcity "&city=ODS" 
				} elseif {
		  [string match "*петрозаводск*" $str] } { 
		set afcity "&city=PTR" 
				} elseif {
		  [string match "*ростов*" $str] } { 
		set afcity "&city=RND" 
				} elseif {
		  [string match "*ставрополь*" $str] } { 
		set afcity "&city=STV" 
				} elseif {
		  [string match "*уфа*" $str] } { 
		set afcity "&city=UFA" 
				} elseif {
		  [string match "*челябинск*" $str] } { 
		set afcity "&city=CHL" 
				} elseif {
		  [string match "*ярославль*" $str] } { 
		set afcity "&city=YRS" 
				} else {
		set afcity "&city=MSK" 
				}
#---тип поиска
	if 	{ [string match "*концерт*" $str] || [string match "*музыка*" $str] } { 
		set aftype "concert" 
				} elseif {
	 	 [string match "*кино*" $str] } { 
		set aftype "cinema" 
				} elseif {
	 	 [string match "*спорт*" $str] } { 
		set aftype "sport" 
				} elseif {
	 	 [string match "*театр*" $str] } { 
		set aftype "theatre" 
				} elseif {
	 	 [string match "*арт*" $str] } { 
		set aftype "art" 
				} elseif {
	 	 [string match "*клуб*" $str] } { 
		set aftype "club" 
				} elseif {
	 	 [string match "*+*" $str] } { 
		set aftype "search" 
				} else {
			lput puthelp "\002Команда:\002 $pubprefix$unamespace \<кино\|концерты\|клубы\|арт\|театры\|спорт\> \[город\] \[-dдень\] \[-pстраница\]. \002Например:\002 $pubprefix$unamespace кино новосибирск -d3 -p2" $prefix
			lput puthelp "\002параметры:\002 '-dдень' - номер дня, считая от текущего, '-pстраница' - номер страницы (по умолчанию выводятся пять результатов, т.е например '-p3' выведет результаты с 10-го по 15-й)" $prefix 
			lput puthelp "\002поиск:\002 $pubprefix$unamespace +строка поиска" $prefix 
			lput puthelp "\002города:\002 С.-Петербург (спб) Алма-Ата, Волгоград, Екатеринбург, Иркутск, Казань, Киев, Краснодар, Мурманск, Новгород, Новосибирск, Одесса, Петрозаводск, Ростов, Ставрополь, Уфа, Челябинск, Ярославль (по умолчанию - Москва)" $prefix
			return
			}

		if { $logrequests ne "" } {
			set logstr [subst -nocommands $logrequests]
			lput putlog $logstr "$unamespace: "
		}

		::http::config -urlencoding cp1251
		
		if { $afs == 1 } { 
			set fetchurl "$fetchurl$afcity&p=[expr {$afpage - 1}]" 
		} else {
			set fetchurl "$fetchurl&type=$aftype&date=$afdate$afcity&limit=$maxres&page=$afpage&"
		}
		
		if { [queue_add "$fetchurl" $id "[namespace current]::dream:parser" [list $unick $uhost $uchan {}]] } {
			variable err_ok
			if { $err_ok ne "" } {
				lput puthelp "$err_ok. " $prefix
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
		variable maxres

		global afdate
		global aftype
		global afpage
		global afcity
		global afs

		foreach { unick uhost uchan str } $lextra { break }

		if { $lerrid ne {ok} } {
			lput putserv [subst -nocommands $err_fail] [subst -nocommands $errsend]
			return
		}

		if { $uchan eq $unick } {
			set prefix [subst -nocommands $msgsend]
		} else {
			set prefix [subst -nocommands $pubsend]
		}

	global sp_version
	if {[info exists sp_version]} {	
		set str [encoding convertfrom cp1251 $lbody] 
		} else {
		set str $lbody
		}

# ---------------------------------------------------------------------------
##---parser-specific---afisha---
# ---------------------------------------------------------------------------

regsub -all -nocase -- "&city=" $afcity {} afcity 
		regsub -all -- "\n|\r|\t" $str {} str
		regsub -all -- "&amp;" $str {\&} str

		if { [string match -nocase "*опробуйте выбрать другой день*" $str] || [string match -nocase "*комбинация слов нигде не встречается*" $str] } {
		lput putserv "\037Ничего не найдено.\017" $prefix 
		return
			}
#---если поиск
		if { $afs == 1 } {

	regexp {<title>(.*?)</title>} $str match stotal 
	lput putserv "$stotal" $prefix
	
	regexp {<ol.*?>(.*?)</ol>} $str match str

	regsub -all -- <li> $str </li>\n str

		set count 0
		foreach line [split $str \n] {

	if { [regexp {<a href=.*?>(.*?)</a><div>(.*?)</div>} $line match sname sdesc] } {

		if { [regexp {date=(.*?)\&} $line match sdate] } {
			set sdate [string map {"Sunday" "Вс." "Monday" "Пон." "Tuesday" "Вт."  "Wednesday" "Ср." "Thursday" "Чт" "Friday" "Пт" "Saturday" "Сб" 
 "January" "Янв." "February" "Фев." "March" "Марта" "April" "Апр." "May" "Мая" "June" "Июня" 
 "July" "Июля" "August" "Авг." "September" "Сент." 
 "October" "Окт." "November" "Ноя." "December" "Дек." } [clock format [clock scan $sdate] -format "%e %B (%A)"]] 
			} else { set sdate "" }

	regsub -all -nocase -- "<b>" $sname "\002" sname
	regsub -all -nocase -- "</b>" $sname "\017" sname
	regsub -all -nocase -- "<a href=.*?>" $sdesc " - " sdesc
	regsub -all -nocase -- "</a>" $sdesc "" sdesc

	lput putserv "\002\037Назв.:\017 $sname - $sdesc - $sdate" $prefix 
	}
		incr count
		if {$count == $maxres} {break}
		}
		} else {
#---если не поиск
		regexp {<tr id="f">(.*?)</body>} $str match str
	regsub -all -nocase -- </tr> $str </tr>\n str

#---TODO:парсеры можно и совместить
#---концерты-клубы
	if { $aftype == "concert" || $aftype == "club"} {
	lput putserv "\002\037Афиша\017  на \002[fdate $afdate]\002 ($aftype) ($afcity) стр. $afpage" $prefix 
	
		set count 0
		foreach line [split $str \n] {

		if { [regexp {<a href=.*?>(.*?)</a>(.*?)<a class=.*?>(.*?)</a>(.*?)</tr>} $line match aname astyle aplace atime] } {
		set dconcert "1"
		regsub -all -- "<.*?>" $astyle "" astyle
		regsub -all -- "<.*?>" $atime "" atime
			} else {
				set dconcert "0"
					}
if { $dconcert != "0" } {
lput putserv "\002\037Назв.:\017 $aname ([string trim $astyle]) - \002\037Где:\017 $aplace ([string trim $atime] )" $prefix 
		incr count
		if {$count == $maxres} {break}
		}
								}
if { $count == 0 } {
lput putserv "\037Ничего не найдено.\017" $prefix 
					}
	}
#---выставки
	if { $aftype == "art" } {
	lput putserv "\002\037Афиша\017  на \002[fdate $afdate]\002 ($aftype) ($afcity) стр. $afpage" $prefix 
	
		set count 0
		foreach line [split $str \n] {

		if { [regexp {<a href=.*?>(.*?)</a>(.*?)<a class=.*?>(.*?)</a>} $line match ename estyle eplace] } {
		set dconcert "1"
		regsub -all -- "<.*?>" $estyle "" estyle
			} else {
				set dconcert "0"
					}

if { $dconcert != "0" } {
lput putserv "\002\037Назв.:\017 $ename ([string trim $estyle]) - \002\037Где:\017 $eplace " $prefix
		incr count
		if {$count == $maxres} {break}
		}
								}
if { $count == 0 } {
lput putserv "\037Ничего не найдено.\017" $prefix 
					}
	}
#---театры-спорт
	if { $aftype == "theatre" || $aftype == "sport" } {
	lput putserv "\002\037Афиша\017  на \002[fdate $afdate]\002 ($aftype) ($afcity) стр. $afpage" $prefix 
	
		set count 0
		foreach line [split $str \n] {

		if { [regexp {<a href=.*?>(.*?)</a>(.*?)<a class=.*?>(.*?)</a>.*?<li>(.*?)</li>} $line match tname tstyle tplace ttime] } {
		set dtheatre "1"
		regsub -all -- "</div>" $tstyle " - " tstyle
		regsub -all -- "<.*?>" $tstyle "" tstyle
		regsub -all -- "<span.*?>" $ttime "" ttime
		regsub -all -- "</span>" $ttime "" ttime
			} else {
				set dtheatre "0"
					}

if { $dtheatre != "0" } {
lput putserv "\002\037Назв:\017 $tname ([string trim $tstyle]) - \002\037Где:\017 $tplace ( $ttime )" $prefix
		incr count
		if {$count == $maxres} {break}
		}
								}
if { $count == 0 } {
lput putserv "\037Ничего не найдено.\017" $prefix 
					}
	}
#---кино
	if { $aftype == "cinema" } {
	lput putserv "\002\037Афиша\017  на \002[fdate $afdate]\002 ($aftype) ($afcity) стр. $afpage" $prefix 
	
		set count 0
		foreach line [split $str \n] {

		if { [regexp {<a href=.*?>(.*?)</a>.*?<div class="comment">(.*?)</div>(.*?)<a class=.*?>(.*?)</a>(.*?)</tr>} $line match cname ccomm ctype cplace ctime] } {
		set dcinema "1"
		regsub -all -- "<.*?>" $ctype "" ctype
		regsub -all -- "<li>" $ctime "  " ctime
		regsub -all -- "<.*?>" $ctime "" ctime
			} elseif { [regexp {<a href=.*?>(.*?)</a>.*?<div class="comment">(.*?)</div>.*?<td.*?>(.*?)<td.*?>(.*?)</tr>} $line match cname ccomm ctype cplace] } {
		set dcinema "1"
		regsub -all -- "<.*?>" $ctype "" ctype
		regsub -all -- "<.*?>" $cplace "" cplace
		set ctime ""
			} else {
				set dcinema "0"
					}

if { $dcinema != "0" } {
lput putserv "\002\037Назв.:\017 $cname ($ccomm - [string trim $ctype]) - \002\037Где:\017 $cplace - $ctime " $prefix
		incr count
		if {$count == $maxres} {break}
		}
								}
if { $count == 0 } {
lput putserv "\037Ничего не найдено.\017" $prefix 
					}
	}
#putlog "parser done"
#--end-поиск
	}
		return
}		
# ---------------------------------------------------------------------------
##---ok---
# ---------------------------------------------------------------------------

	proc lput { cmd str { prefix {} } {maxchunk 400} } {
		set plen 	[string length $prefix]
		set	slen    [string length $str]
		set sidx	0
		
		while { $slen != 0 } {
			set nsl [expr { [expr { $slen + $plen }] < $maxchunk ? $slen : [ expr { $maxchunk - $plen } ] } ]
			
			$cmd $prefix[string range $str $sidx [expr { $sidx + $nsl - 1} ] ]
		
			incr slen -$nsl
			incr sidx  $nsl
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











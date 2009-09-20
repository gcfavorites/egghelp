#----------------------------------------------------------------------------
# Anekd 	     - анекдоты 
# Включение:	.chanset #chan +anekd
# Формат:		!anekd [номер] [#chan минуты] [update]	
# Алиасы:		!anek !анек !anekdot !анекдот !баян
# Вопросы:		anaesthesia #eggdrop@Rusnet
# Оффсайт:		http://egghelp.ru
#----------------------------------------------------------------------------
# Команда !anekd #chan минуты - включение вывода по таймеру
# например, !anekd #humor 10 - вывод анекдота раз в 10 мин. в канал #humor
# если время равно 0 - вывод по таймеру отключен
# по умолчанию эта команда доступна операторам канала
# * канальный флаг запрета скрипта отключает так-же и вывод по таймеру
# * после первой загрузки скрипта рекомендуется выполнить команду !anekd update
#   для подсчета текущего количества анекдотов. В дальнейшем эта процедура
#   происходит автоматически ежесуточно в 00 часов.

package require Tcl 	8.4
package require http	2.5

namespace eval anekd {
foreach p [array names anekd *] { catch {unset anekd ($p) } }

#----------------------------------------------------------------------------
# Первичные параметры конфигурации (Suzi / http.tcl)
#----------------------------------------------------------------------------
	# сведения о разработчике скрипта, версии, дате последней модификации
	variable author			"anaesthesia"
	variable version		"01.21"
	variable date			"07-Aug-2008"
	variable unamespace		[namespace tail [namespace current]]

	# префикс для публичных команд (может быть пустой строкой)
	variable pubprefix 		{!}
	variable pubflag		{-|-}

	# pubcmd:имя_обработчика "вариант1 вариант2 ..."
	# команда и её публичные варианты, строка в которой варианты разделены пробелом
	variable pub:anekd		"$unamespace anek anekdot анек анекдот баян"

	# тоже что и выше, для приватных команд
	variable msgprefix		{!}
	variable msgflag		{-|-}

	# такие же команды как для публичных алиасов
	variable msg:anekd		${pub:anekd}

	# флаги юзера бота, которому разрешено включать вывод по таймеру
	variable setflag		{o|o}

	# можно отключить приватные или публичные команды, указав в качестве алиасов пустую строку
	# или закомментировав объявление  variable [pub|msg]:handler "string ..."

	# пауза между запросами, в течении которой сервис недоступен для использования, секунд 
	variable pause			35

	# макс. количество выводимых строк
	variable maxres			15

	# какие идентификаторы используются для различения запросов
	# доступны $unick, $uhost, $uchan
	# обычное tcl выражение, позволяющие сформировать уникальный id для идентификации запроса.
	variable requserid		{$uhost}
	
	# максимальное число ожидающих выполнения запросов для одного id
	variable maxreqperuser	1

	# максимальное число ожидающих выполнения запросов
	variable maxrequests	5
	
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
	variable chflag			"$flagactas$unamespace"
	variable chflagt		"${unamespace}\-time"

	setudef  flag 			$chflag
	setudef  int			$chflagt

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
	# адрес, с которого происходит получение информации
	variable 		fetchurl		"http://ostrie.moskva.com/"

	# диапазон номеров анекдотов (лучше не менять)
	# начальный
	variable anmin		903001
	# последний (устанавливается автоматически раз в сутки)
	variable anmax		935550

	# очередь запросов
	variable 		reqqueue
	array unset 	reqqueue

	# последние таймстампы
	variable 		laststamp
	array unset		laststamp 
	variable		updinprogress	0
	variable		updatetimeout	60000

	# отладка
	variable		debug		0

#---body---конец настроек

	proc time:anekd {} {
		variable chflag ; variable chflagt ; variable flagactas ; variable debug
		foreach ach [channels] {
			if {[validchan $ach]} {
				set acht [channel get $ach $chflagt]
				if {![channel get $ach $chflag] ^ $flagactas eq "no"} {continue}
				if {[botonchan $ach] && $acht > 0} {
					if {[timerexists "[namespace current]::pub:anekd ntime time@time htime $ach time"] == ""} {
						set achn($ach) [timer $acht "[namespace current]::pub:anekd ntime time@time htime $ach time"]
						if {$debug} {putlog "time:anekd :: set timer - $ach - $achn($ach) - [lindex [timers] [lsearch [timers] "*$achn($ach)*"] 0] мин."}
					}
				}
			} {putlog "invalid channel $ach" ; return}
		}
	}

	proc upd:anekd {mi ho da mo ye} {pub:anekd nupd upd@upd hupd * "update"}
	proc msg:anekd {unick uhost handle str} {pub:anekd $unick $uhost $handle $unick $str ; return}
	proc pub:anekd {unick uhost handle uchan str} {
		variable requserid ; variable fetchurl ; variable pubprefix ; variable logrequests
		variable chflag ; variable chflagt ; variable flagactas ; variable setflag
		variable errsend ; variable pubsend ; variable msgsend
		variable maxres ; variable unamespace
		variable anum ; variable anmin ; variable anmax
		variable upd 0

		if {$str ne "time"} {set id [subst -noc $requserid]} {set id [unixtime]}
		set prefix [subst -noc $errsend]
		if {$unick ne $uchan && $str ne "update"} {if {![channel get $uchan $chflag] ^ $flagactas eq "no"} {return}}

		if {[string first "#" [lindex $str 0]] == 0} {
			if {[validchan [lindex $str 0]] && [string is digit [lindex $str 1]]} {
				if {![matchattr [nick2hand $unick] $setflag [lindex $str 0]]} {lput putserv "Изменять режимы могут только прописанные на боте операторы" $prefix ; return}
				set atimer [string trim [lindex $str 1]]
				channel set [lindex $str 0] $chflagt $atimer
				channel set [lindex $str 0] "+$chflag"
				savechannels
				if {$atimer > 0} {
					[namespace current]::time:anekd
					lput putserv "Включен автоматический постинг баянов в канал [lindex $str 0] (раз в $atimer мин.)" $prefix
				} {catch {killtimer [lindex [timers] [lsearch [timers] "*[lindex $str 0]*"] end]} ; lput putserv "Выключен автоматический постинг баянов в канал [lindex $str 0]" $prefix}
			} {lput putserv "Формат: $pubprefix$unamespace #канал время" $prefix}
		return
		}

		set why  [queue_isfreefor $id]
		if {$why != ""} {lput puthelp $why $prefix ; return}

	set ustr [string trim [tolow $str]]
		if {$ustr eq "?"} {
			if {$uchan eq $unick} {set prefix [subst -nocommands $msgsend]} {set prefix [subst -nocommands $pubsend]}
			lput puthelp "\002Формат\002: $pubprefix\анекдот <?|номер> " $prefix ; return
		} elseif {$ustr eq "update"} {set aurl "" ; set upd 1
		} {
			if {[string is digit $ustr] && $ustr ne ""} {
				if {$ustr == 0} {set anum 1
				} elseif {$ustr >= [expr {$anmax - $anmin}]} {lput puthelp "\037Слишком большой номер\037." $prefix ; return
				} {set anum $ustr ; set aurl "?do=Item&id=[expr {$anum + [expr {$anmin - 1}]}]"}
			} {set atmp [rrand $anmin $anmax] ; set anum [expr {$atmp - [expr {$anmin - 1}]}] ; set aurl "?do=Item&id=$atmp"}
		}

		if {$logrequests ne ""} {set logstr [subst -noc $logrequests] ; if {$ustr ne "time"} {lput putlog $logstr "$unamespace: $fetchurl$aurl :: "}}
		::http::config -useragent "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; 240x320)"	
		if {[queue_add "$fetchurl$aurl" $id "[namespace current]::anekd:parser" [list $unick $uhost $uchan $str]]} {
			variable err_ok ; if {$err_ok ne ""} {lput puthelp "$err_ok." $prefix}
		} {
			variable err_fail ; if {$err_fail ne ""} {lput puthelp $err_fail $prefix} ; if {$ustr eq "time"} {[namespace current]::time:anekd}
		}

	return
	}

#---parser
	proc anekd:parser {errid errstr body extra} {
		upvar $errid lerrid $errstr lerrstr $body lbody $extra lextra
		variable err_fail ; variable upd ; variable debug
		variable pubsend ;variable msgsend ; variable errsend
		variable useurl ; variable maxres
		variable anum ;variable anmax ; variable anmin
		
		foreach {unick uhost uchan ustr} $lextra {break}
		if {$lerrid ne {ok}} {lput putserv [subst -nocommands $err_fail] [subst -nocommands $errsend] ; return}
		if {$uchan eq $unick} {set prefix [subst -nocommands $msgsend]} {set prefix [subst -nocommands $pubsend]}
		if {[info exists ::sp_version]} {set str [encoding convertfrom koi8-r $lbody]} {set str [encoding convertto cp1251 [encoding convertfrom koi8-r $lbody]]}

#----------------------------------------------------------------------------
##---parser-specific------
#----------------------------------------------------------------------------
	if {$upd} {
		if {[regexp -nocase -- {<script>us\((.*?)\);} $str -> nnum]} {
			set anmax [lindex [split $nnum ","] 2] ; set adate [string map {"&nbsp;" " " \" ""} [lindex [split $nnum ","] 3]]
			putlog "[namespace current] Last: $anmax \[$adate\]"
		}
	return
	}

	if {[regexp {<dl class="anek">(.*?)<dd.*?>(.*?)<div class="instr">} $str -> apar atemp]} {
		if {[regexp -nocase -- {<script>us\((.*?)\);} $apar -> apar]} {set arate [lindex [split $apar ","] 4] ; set adate [string map {"&nbsp;" " " \" ""} [lindex [split $apar ","] 3]]} {set arate "-" ; set adate "-"}
		regsub -all -- "\n|\r" $atemp {} atemp
		regsub -all -- "<br />" $atemp "\n" atemp
		regsub -all -- "<.*?>" $atemp "" atemp
			set lnum [llength [split $atemp "\n"]]
			if {$lnum > $maxres && $ustr ne "time"} {
				lput putserv "\00310Баян \00312N\00304$anum \00310слишком большой (\00312$lnum \00310строк)." $prefix
				set prefix [subst -nocommands $msgsend]
			} {set prefix [subst -nocommands $pubsend]}
		lput putserv "\00303.-\00303-\00314\[\017 Баян N\00312$anum \00314\]\00310------\00303-\00310--\00303--\00314-\00303-\00314-- -" $prefix
		foreach aline [split $atemp "\n"] {if {$aline != ""} {lput putserv "\00303|\017 [sconv [sspace $aline]]" $prefix}}
		lput putserv "\00303`-\00303-\00314\[\017 Рейтинг:\00305$arate\017 Дата:\00305$adate \00314]\00303---\00303-\00303--\00303--\00314-\00303-\00314----" $prefix
	} else {
		variable fetchurl
		set idr [unixtime] ; set atmp [rrand $anmin $anmax] ; set anum [expr {$atmp - 903000}] ; set aurl "?do=Item&id=$atmp"
		queue_add "$fetchurl$aurl" $idr "[namespace current]::anekd:parser" [list $unick $uhost $uchan {}]
	}

	if {$ustr eq "time"} {[namespace current]::time:anekd}
	if {$debug} {putlog "time:anekd :: parser :: $ustr"}
	return
	}	
#----------------------------------------------------------------------------
##---ok------
#----------------------------------------------------------------------------
	proc tolow  {strr} {return [string tolower [string map {Й й Ц ц У у К к Е е Н н Г г Ш ш Щ щ З з Х х Ъ ъ Ф ф Ы ы В в А а П п Р р О о Л л Д д Ж ж Э э Я я Ч ч С с М м И и Т т Ь ь Б б Ю ю Ё ё} $strr]]}
	proc sspace {strr} {return [string trim [regsub -all {[\t\s]+} $strr { }]]}
	proc rrand {min max} {return [expr {int(rand()*($max-$min+1)+$min)}]}

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
	set strr [string map $escapes [join [lrange [split $strr] 0 end]]] 
    regsub -all -- {\[} $strr "\\\[" strr
    regsub -all -- {\]} $strr "\\\]" strr
    regsub -all -- {\(} $strr "\\\(" strr
    regsub -all -- {\)} $strr "\\\)" strr
  	regsub -all -- {&#([[:digit:]]{1,5});} $strr {[format %c [string trimleft "\1" "0"]]} strr
 	regsub -all -- {&#x([[:xdigit:]]{1,4});} $strr {[format %c [scan "\1" %x]]} strr
 	regsub -all -- {&#?[[:alnum:]]{2,7};} $strr "" strr

	return [subst -nov $strr]
	}

	proc lput {cmd str {prefix {}} {maxchunk 420}} {
	set buf1 "" ; set buf2 [list]
		foreach word [split $str] {append buf1 " " $word ; if {[string length $buf1]-1 >= $maxchunk} {lappend buf2 [string range $buf1 1 end]; set buf1 ""}}
		if {$buf1 != ""} {lappend buf2 [string range $buf1 1 end]}
	foreach line $buf2 {$cmd $prefix$line}
	return
	}

	proc queue_isfreefor {{id {}}} {
		variable reqqueue ; variable maxreqperuser ; variable maxrequests ; variable laststamp ; variable pause
		variable err_queue_full	; variable err_queue_id ; variable err_queue_time 

		if {[info exists laststamp(stamp,$id)]} {
			set timewait [expr { $laststamp(stamp,$id) + $pause - [unixtime]}]
			if {$timewait > 0} {return [subst -nocommands $err_queue_time]}			
		}
		if {[llength [array names reqqueue -glob "*,$id"]] >= $maxreqperuser} {return $err_queue_id}
		if {[llength [array names reqqueue]] >= $maxrequests} {return $err_queue_full}
		
	return
	}

	proc queue_add {newurl id parser extra {redir 0}} {
		variable reqqueue ; variable proxy ; variable timeout ; variable laststamp

		::http::config -proxyfilter "[namespace current]::queue_proxy"
		if {![catch {set token [::http::geturl $newurl -command "[namespace current]::queue_done" -binary true -timeout $timeout]} errid]} {
			set reqqueue($token,$id) [list $parser $extra $redir]		
			set laststamp(stamp,$id) [unixtime]
		} {return false}

	return true
	}

	proc queue_proxy {url} {variable proxy ; if {$proxy ne {}} {return [split $proxy {:}]} ; return [list]}
	
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
					if {[info exists meta(Location)]} {queue_add "$fetchurl$meta(Location)" $id $parser $extra [incr redir] ; break}
				} {set errid   "error" ; set errstr  "Maximum redirects reached"}
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
				foreach {alias} [set $bindproc] {
					catch {$action $bindtype [set ${bindtype}flag] [set ${bindtype}prefix]$alias $bindproc}
				}				
			}
		}
		
	return
	}

	if {[info exists timerID]} {catch {killtimer $timerID} ; catch {unset timerID}}
	[namespace current]::queue_clear_stamps
	[namespace current]::cmdaliases
	[namespace current]::time:anekd
	bind time - "00 00 * * *"  [namespace current]::upd:anekd
  	variable sfil [lindex [split [info script] "/"] end]
  	variable modf [clock format [file mtime [info script]] -format "%d-%b-%Y : %H:%M:%S"]
	if {[info exists ::sp_version]} {putlog "[namespace current] v$version (suzi_$sp_version) :: file:$sfil / rel:\[$date\] / mod:\[$modf\] :: by $author :: loaded."} {putlog "[namespace current] v$version :: file:$sfil / rel:\[$date\] / mod:\[$modf\] :: by $author :: loaded."}

} ;#end











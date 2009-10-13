#----------------------------------------------------------------------------
# kino 			-информация о фильмах и актерах 
# Включение:	.chanset #chan +kino
# Формат:		!kino [?] <запрос>
# Алиасы:		!кино
# Вопросы:		anaesthesia #eggdrop@Rusnet
# Оффсайт:		http://egghelp.ru
#----------------------------------------------------------------------------
# v01.1			+ добавлены шаблоны вывода
# v01.11		% косметические исправления и мелкие правки
# v01.12		% крупные правки (изменения на сайте) 
# v01.13		% пофикшена неработоспособность в некоторых конфигурациях бота (спасибо Vertigo@Rusnet) 

package require Tcl 	8.4
package require http	2.5

namespace eval kino {
#----------------------------------------------------------------------------
# Первичные параметры конфигурации
#----------------------------------------------------------------------------
	# сведения о разработчике скрипта, версии, дате последней модификации
	variable author			"anaesthesia"
	variable version		"01.13"
	variable date			"19-Jul-2009"
	variable unamespace		[namespace tail [namespace current]]

	# префикс для публичных команд (может быть пустой строкой)
	variable pubprefix 		{!}
	variable pubflag		{-|-}

	# команды вызова (бинды)
	# pubcmd:имя_обработчика "вариант1 вариант2 ..."
	# команда и её публичные варианты, строка в которой варианты разделены пробелом
	variable pub:kino		"$unamespace кино"

	# тоже что и выше, для приватных команд
	variable msgprefix		{!}
	variable msgflag		{-|-}

	# такие же команды как для публичных алиасов
	variable msg:kino		${pub:kino}

	#* можно отключить приватные или публичные команды, указав в качестве алиасов пустую строку
	#* или закоменнтировав объявление  variable [pub|msg]:handler "string ..."

	# тип вывода (0 - по шаблону, 1 - полный)
	variable		ktype	1
	# шаблон вывода инфы о фильме
	variable		m_template	{\[ \002%название%\002 \] :: \002Рейтинг\002: %рейтинг% @ \037\00312%линк%\003\037 \n%инфо% \n\002В ролях\002: %актеры% \n\002О чем\002: %описание% \n%похожие%}
	# шаблон вывода инфы об актере
	variable		a_template	{\[ %актер% \]\n %актер_инфо% \n\002Лучшие фильмы\002: %актер_лучшее%}

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
	variable maxredir		4
	
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
	variable 		fetchurl		"http://www.kinopoisk.ru"
		
	# очередь запросов
	variable 		reqqueue
	array unset 	reqqueue

	# последние таймстампы
	variable 		laststamp
	array unset		laststamp 

#---body---

	proc msg:kino {unick uhost handle str} {pub:kino $unick $uhost $handle $unick $str ; return}

	proc pub:kino {unick uhost handle uchan str} {
		variable requserid ; variable unamespace
		variable chflag ; variable flagactas ; variable logrequests
		variable pubprefix ; variable pubsend ; variable msgsend ; variable errsend
		variable maxres ; variable type ; variable src
		variable fetchurl

		set id [subst -noc $requserid]
		set prefix [subst -noc $errsend]
		if {$unick ne $uchan} {if {![channel get $uchan $chflag] ^ $flagactas eq "no" } {return}}
		set why [queue_isfreefor $id]
		if {$why != ""} {lput puthelp $why $prefix ; return}

#---параметры
		set ustr $str
		if {[regexp -nocase -- {\?} $ustr]} {regsub -- {\?\s*} $ustr "" ustr ; set src 1} {set src 0}
		::http::config -accept "text/*" -useragent "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; 240x320)"	
			if {[string is space $ustr]} {
				if {$uchan eq $unick} {set prefix [subst -noc $msgsend]} {set prefix [subst -noc $pubsend]}
				lput puthelp "\002Формат\002: \002$pubprefix$unamespace\002 \[?\] <запрос> :: поиск информации о фильмах или актерах" $prefix		
			return
			}
		if {$logrequests ne ""} {set logstr [subst -noc $logrequests] ; lput putlog $logstr "$unamespace: "}
		if {[queue_add "${fetchurl}/index.php?kp_query=[uenc $ustr cp1251]" $id "[namespace current]::kino:parser" [list $unick $uhost $uchan]]} {
			variable err_ok ; if {$err_ok ne ""} {lput puthelp "$err_ok." $prefix}
		} {
			variable err_fail ; if {$err_fail ne ""} {lput puthelp "$err_fail" $prefix}
		}

	return
	}

#---parser
	proc kino:parser {errid errstr body extra} {
		upvar $errid lerrid $errstr lerrstr $body lbody $extra lextra
		variable err_fail ; variable pubsend ; variable msgsend ; variable errsend
		variable maxres ; variable src ; variable fetchurl ; variable ktype ; variable m_template ; variable a_template

		foreach {unick uhost uchan ustr} $lextra {break}
		if {$lerrid ne {ok}} {lput putserv [subst -noc $err_fail] [subst -noc $errsend] ; return}
		if {$uchan eq $unick} {set prefix [subst -noc $msgsend]} {set prefix [subst -noc $pubsend]}
		if {[info exists ::sp_version]} {set str [encoding convertfrom cp1251 $lbody]} {set str $lbody}

#----------------------------------------------------------------------------
##---parser-specific------
#----------------------------------------------------------------------------

	regsub -all -- "\n|\r|\t" $str "" str

	if {$src} {
		if {[regexp -nocase -- {<H2 class="textorangebig".*?>(.*?)<H2 class="textorangebig".*?>(.*?)<tr><td colspan=2 align="right">} $str -> s1 s2]} {
			regsub -all -nocase -- {<font color="#999999">} $s2 "\00314" s2
			regsub -all -nocase -- {</font>} $s2 "\003" s2
			regsub -all -nocase -- "<b>|</b>" $s1 "\002" s1
			regsub -all -nocase -- "<b>|</b>" $s2 "\002" s2
			regsub -all -- "<.*?>" $s1 " " s1 ; regsub -all -- "<.*?>" $s2 " " s2
			lput putserv "[sspace [sconv $s1]] :: [sspace [sconv $s2]]" $prefix
		} {lput putserv "\037Нет соответствий\037." $prefix}
	return
	}

	set mout "" ; set m_tit "" ; set m_dat "" ; set aout "" ; set m_act "" ; set acout "" ; set a_dat "" ; set acbf "" ; set a_bf ""

	if {[regexp -nocase -- {<!-- результаты поиска -->.*?<a class="all" href="(.+?)">(.+?)</a>} $str -> kurl kname]} {
		queue_add "${fetchurl}[string map {"sr/1/" ""} $kurl]" [unixtime] "[namespace current]::kino:parser" [list $unick $uhost $uchan "${fetchurl}[string map {"sr/1/" ""} $kurl]"]
	} {
		if {[regexp -nocase -- {<!-- инфа о фильме -->(.*?)<!-- /инфа о фильме -->} $str -> kinf]} {
			if {[regexp -nocase -- {<H1 style=.*?class="moviename-big">(.+?)</H1>} $kinf -> kname]} {regsub -all -- "<.*?>" $kname "" kname ; set m_name [string map {{;} {}} $kname]}
			regsub -all -- {</td></tr>} $kinf \n kinf
				foreach kinfl [split $kinf \n] {
					if {[regexp -nocase -- {<tr><td class="type">(.*?)</td><td.*?>(.*?)$} $kinfl -> mtit mdat]} {
						regsub -all -- "<.*?>" $mtit " " mtit ; regexp -all -- {<.*?alt=\"Рейтинг(.*?)\".*?>} $mdat "\\1" mdat ; regsub -all -- "<.*?>" $mdat " " mdat
						append mout "\002[sspace [sconv $mtit]]\002: [sspace [sconv $mdat]] / "
						append m_dat "\002[sspace [sconv $mtit]]\002: [sspace [sconv $mdat]] "
					}
				}

			if {[regexp -nocase -- {<!-- актеры фильма -->(.*?)<!-- /актеры фильма -->} $str -> kinf]} {
				regsub -all -- {</td></tr>} $kinf \n kinf
					foreach kinfl [split $kinf \n] {
						if {[regexp -nocase -- {<tr><td style.*?">(.*?)$} $kinfl -> mact]} {
							regsub -all -- "<.*?>" $mact " " mact
							append aout "[sspace [sconv $mact]] / "
							append m_act "[sspace [sconv $mact]] / "
						}
					}
			} {set aout ""}

			if {[regexp -nocase -- {<span class="_reachbanner_">(.*?)</span>} $str -> mdesc]} {
				regsub -all -- "<.*?>" [string map {"&#151;" "-"} $mdesc] "" mdesc
				set dout "\002О чем\002: [sspace [sconv $mdesc]]"
				set m_desc [sspace [sconv $mdesc]]
			} {set dout "" ; set m_desc ""}
		
			if {[regexp -nocase -- {<div class="block2">(.*?)<div class="block3">} $str -> mrate]} {
				regsub -all -- "<.*?>" [string map {"&nbsp;&nbsp;" " голосов: "} $mrate] "" mrate
				set orat "\002Рейтинг\002: [sspace $mrate] ::"
				set m_rat "[sspace $mrate]"
			} {set orat "" ; set m_rat ""}

			if {[regexp -nocase -- {<b style="color:#777">(.*?)</table>} $str -> msim]} {
				regsub -all -nocase -- "<span .*?>" $msim "\002" msim
				regsub -all -nocase -- "</span>" $msim "\002" msim
				regsub -all -nocase -- "</a><br>" $msim { / } msim
				regsub -all -- "<.*?>" $msim " " msim
				set sout [sconv [sspace $msim]]
				set m_sim [sconv [sspace $msim]]
			} {set sout "" ; set m_sim ""}
		} {set mout ""}

		if {[regexp -nocase -- {<!-- инфа об актере -->(.*?)<!-- /инфа об актере -->} $str -> ainf]} {
			if {[regexp -nocase -- {<H1.*?>(.+?)</H1>} $ainf -> aname]} {regsub -all -- "<.*?>" $aname "" aname} {set aname ""}
			if {[regexp -nocase -- {<span style="font-size.*?#666">(.*?)</span>} $ainf -> aname2]} {if {![string is space [sconv $aname2]]} {append aname " ([sconv $aname2])"}}
			regsub -all -- {</td></tr>} $ainf \n ainf
				foreach ainfl [split $ainf \n] {
					if {[regexp -nocase -- {<tr><td class="type">(.*?)</td><td.*?>(.*?)$} $ainfl -> atit adat]} {
						regsub -all -- "<.*?>" $atit " " atit ; regsub -all -- "<.*?>" $adat " " adat
						append acout "\002[sspace [sconv $atit]]\002: [sspace [sconv $adat]] / "
						append a_dat "\002[sspace [sconv $atit]]\002: [sspace [sconv $adat]] "
					}
				}

			if {[regexp -nocase -- {<!-- лучшие фильмы -->(.*?)<!-- /лучшие фильма -->} $str -> finf]} {
				regsub -all -- {</td></tr>} $finf \n finf
					foreach finfl [split $finf \n] {
						if {[regexp -nocase -- {<tr><td style.*?align=right>(.*?)$} $finfl -> bfilm]} {
							regsub -all -- "<.*?>" $bfilm " " bfilm
							append acbf "[sspace [sconv $bfilm]] / "
							append a_bf "[sspace [sconv $bfilm]] :: "
						}
					}
			} {set acbf "" ; set $a_bf ""}
		} {set acout ""}

	if {$ktype} {
		if {$mout ne ""} {
			lput putserv "\[ \002[string trim [sconv $kname]]\002 \] :: [sspace $orat] @ \00312\037[string trimright $ustr "sr/1/"]\037\003" $prefix
			lput putserv "[string trimright $mout "/ "]" $prefix
			lput putserv "\002В ролях\002: [string trimright $aout "/ "]" $prefix
			if {![string is space $dout]} {lput putserv "$dout" $prefix}
			if {![string is space $sout]} {lput putserv "$sout" $prefix}
		} elseif {$acout ne ""} {
			lput putserv "\[ \002[string trim [sconv $aname]]\002 \] @ \00312\037[string trimright $ustr "sr/1/"]\037\003" $prefix
			if {![string is space $acout]} {lput putserv "[string map {"&nbsp" ""} $acout]" $prefix}
			if {![string is space $acbf]} {lput putserv "\002Лучшие фильмы\002: $acbf" $prefix}
		} else {
			lput putserv "\037Ничего не найдено\037." $prefix
		}
	} {
		set m_link [string trimright $ustr "sr/1/"]
		if {$mout ne ""} {
			foreach m_l [split [subst -noc [string map {%название% \$m_name %линк% \$m_link %инфо% \$m_dat %актеры% \$m_act %описание% \$m_desc %рейтинг% \$m_rat %похожие% \$m_sim} $m_template]] \n] {lput putserv [string map {"&nbsp" ""} $m_l] $prefix}
		} {
			foreach m_l [split [subst -noc [string map {%актер% \$aname %актер_инфо% \$a_dat %актер_лучшее% \$a_bf} $a_template]] \n] {lput putserv [string map {"&nbsp" ""} $m_l] $prefix}
		}
	}
	}
	return
	}		
#----------------------------------------------------------------------------
##---end-parser------
#----------------------------------------------------------------------------

	proc sspace {strr} {return [string trim [regsub -all {[\t\s]+} $strr { }]]}

	proc uenc {strr {encd {utf-8}}} {
		set str "" ; foreach byte [split [encoding convertto $encd $strr] ""] {scan $byte %c i ; if {[string match {[%<>"]} $byte] || $i < 65 || $i > 122} {append str [format %%%02X $i]} {append str $byte}}
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
	set strr [string map {\[ \\\[ \] \\\] \{ \\\{ \} \\\}} [string map $escapes [join [lrange [split $strr] 0 end]]]] 
  	regsub -all -- {&#([[:digit:]]{1,5});} $strr {[format %c [string trimleft "\1" "0"]]} strr
 	regsub -all -- {&#x([[:xdigit:]]{1,4});} $strr {[format %c [scan "\1" %x]]} strr
 	regsub -all -- {&#?[[:alnum:]]{2,7};} $strr "" strr
	return [subst -nov $strr]
	}

	proc lput {cmd str {prefix {}} {maxchunk 420}} {
		set buf1 ""; set buf2 [list]
		foreach word [split $str] {append buf1 " " $word ; if {[string length $buf1]-1 >= $maxchunk} {lappend buf2 [string range $buf1 1 end]; set buf1 ""}}
		if {$buf1 != ""} {lappend buf2 [string range $buf1 1 end]}
		foreach line $buf2 {$cmd $prefix$line}
	return
	}

	proc queue_isfreefor {{ id {}}} {
		variable reqqueue ; variable maxreqperuser ; variable maxrequests ; variable laststamp
		variable pause ; variable err_queue_full ; variable err_queue_id ; variable err_queue_time 

		if {[info exists laststamp(stamp,$id)]} {set timewait [expr {$laststamp(stamp,$id) + $pause - [unixtime]}] ; if {$timewait > 0} {return [subst -noc $err_queue_time]}}
		if {[llength [array names reqqueue -glob "*,$id"]] >= $maxreqperuser} {return $err_queue_id}
		if {[llength [array names reqqueue]] >= $maxrequests} {return $err_queue_full}		
	return
	}

	proc queue_add {newurl id parser extra {redir 0}} {
		variable reqqueue ; variable proxy ; variable timeout ; variable laststamp

		::http::config -proxyfilter "[namespace current]::queue_proxy"
			if {![catch {set token [::http::geturl $newurl -command [namespace current]::queue_done -binary true -timeout $timeout]} errid]} {					
			set reqqueue($token,$id) [list $parser $extra $redir] ; set laststamp(stamp,$id) [unixtime]
			} {return false}
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
					if {[info exists meta(Location)]} {queue_add "$fetchurl$meta(Location)" $id $parser "$extra $fetchurl$meta(Location)" [incr redir] ; break}
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
	[namespace current]::cmdaliases unbind
	[namespace current]::cmdaliases
	putlog "[namespace current] v$version [expr {[info exists ::sp_version]?"(suzi_$::sp_version)":""}] :: file:[lindex [split [info script] "/"] end] / rel:\[$date\] / mod:\[[clock format [file mtime [info script]] -format "%d-%b-%Y : %H:%M:%S"]\] :: by $author :: loaded."

} ;#end











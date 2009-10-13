#----------------------------------------------------------------------------
# Perevod 		-универсальный переводчик
# Включение:	.chanset #chan +perevod
# Формат:		!tr [?] [-число] [язык]|[язык1[*|-|@|#|%]язык2] [+]<текст>
# Алиасы:		!tr [язык1[*|-|@|#|%]язык2] - перевод слов/фраз
#				!tr [-число] [язык] [+]<слово> - перевод слов через Yandex	
# 				!t  [-число] [язык] [+]<слово> - перевод слов через Multitran
#				!ttt [словарь] [номер варианта словаря] <текст> - перевод текста через Promt
#				!tt [+]<текст> - перевод текста через Cognitive Translator
# Вопросы:		anaesthesia #eggdrop@Rusnet
# Оффсайт:		http://egghelp.ru
#----------------------------------------------------------------------------
# Примеры: 
# * знак + перед словом или текстом включает расширенный вывод
# !tr слово (перевод слова через яндекс)
# !tr -2 +слово (+ перед словом - вывод с пояснениям, будет выдано второе значение)
# !tr de слово (перевод с/на немецкий язык)
# !t +test (перевод слова через multitran с выводом пояснений)
# !tt test (перевод слова через cognitive translator)
# !ttt re проверка перевода (перевод фраз через promt)
# !ttt re (если фраза для перевода отсутствует - выводятся варианты словарей для выбранного направления перевода)
#
# Расширенный формат: !tr язык1@#%-язык2 <текст>
# * каждый из символов *-@#% между язык1 и язык2 определяет тип переводчика, например
#   '!tr ru*en слово или фраза' - перевод фраз через promt (альтернативный способ)
#   '!tr ru-en слово или фраза' - перевод фраз через google
#   '!tr ru@en слово или фраза' - перевод фраз через text.pro
#   '!tr ru#en слово или фраза' - перевод фраз через meta
#   '!tr ru%en слово' - перевод слов через slovnik
# Список языков: !tr ?	
#----------------------------------------------------------------------------
# v.1.51	- исправления в парсере (номер результата и т.д)
# v.1.52	- разные мелкие доделки
# v.1.53	- небольшая правка в парсере
# v.2.0		+ добавлен перевод через translate.ru
#			+ добавлен перевод через promt (идея парсера частично сперта у Shrike ;)
# v.2.01	- косметические исправления
# v.2.10	+ добавлен выбор вариантов словаря при переводе через Promt, доработка парсеров и процедуры разбора параметров
# v.2.11	+ добавлен второй вариант перевода через promt (промтовский гугль гаджет оказался глючный..)
# v.2.12	- исправления в promt
# v.2.13	- исправления в promt
# v.2.5		+ добавлен перевод через Cognitive Translator
# v.2.51	- переделан парсер Multitran 
# v.2.55	- переделан парсер Yandex
# v.2.56	- поправлен перевод Google

package require Tcl 	8.5
package require http	2.7

namespace eval perevod {

#----------------------------------------------------------------------------
# Первичные параметры конфигурации (Suzi / http.tcl)
#----------------------------------------------------------------------------
	# сведения о разработчике скрипта, версии, дате последней модификации
	variable author			"anaesthesia"
	variable version		"02.56"
	variable date			"01-Oct-2009"
	variable unamespace		[namespace tail [namespace current]]

#--основные настройки
	# префикс для публичных команд (может быть пустой строкой)
	variable pubprefix 		{!}
	variable pubflag		{-|-}

	# Команда для Promt
	variable bprm			{ttt} 
	# Команда для Мультитран
	variable bmtr			{t}
	# Команда для Cognitive Translator
	variable bcog			{tt}
	# Основная команда вызова
	variable ball			{tr}

	# пауза между запросами, в течении которой сервис недоступен для использования, секунд 
	variable pause			10

#--далее менять что-либо рекомендуется если вы правильно понимаете смысл этих настроек

	# pubcmd:имя_обработчика "вариант1 вариант2 ..."
	# команда и её публичные варианты, строка в которой варианты разделены пробелом
	variable pub:perevod	"$ball $bmtr $bprm $bcog"

	# тоже что и выше, для приватных команд
	variable msgprefix		${pubprefix}
	variable msgflag		{-|-}
	# такие же команды как для публичных алиасов
	variable msg:perevod	${pub:perevod}

	# можно отключить приватные или публичные команды, указав в качестве алиасов пустую строку
	# или закоменнтировав объявление  variable [pub|msg]:handler "string ..."

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
	variable 		furl1		"http://perevod.text.pro/"
	variable		furl2		"http://www.t.a.ua/"
	variable		furl3		"http://slovnyk.org.ua/"
	variable		furl4		"http://m.slovari.yandex.ru/"
	variable		furl5		"http://translate.google.com/translate_t"
	variable 		furl6		"http://www.translate.ru/forms/google_gadget/decode.aspx"
	variable 		furl61		"http://m.translate.ru/translator/result/"
	variable		furl7		"http://www.multitran.ru/c/m.exe"
	variable 		furl8		"http://cs.isa.ru:10000/lf/tpda.php?ef=0"

	# очередь запросов
	variable 		reqqueue
	array unset 	reqqueue

	# последние таймстампы
	variable 		laststamp
	array unset		laststamp 

#---body---

	proc msg:perevod {unick uhost handle str} {pub:perevod $unick $uhost $handle $unick $str ; return}

	proc pub:perevod {unick uhost handle uchan str} {
		variable furl1 ; variable furl2 ; variable furl3 ; variable furl4 ; variable furl5 ; variable furl6 ; variable furl61 ; variable furl7 ; variable furl8 ; variable fetchurl
		variable chflag ; variable flagactas ; 	variable pub:perevod ; variable bprm ; variable bmtr ; variable bcog
		variable errsend ; variable pubsend ; variable msgsend
		variable maxres ; variable pubprefix ; variable unamespace ; variable requserid
		variable type ; variable ya ; variable gt ; variable tru ; variable mtr ; variable mtrt ; variable gta ; variable mpage ; variable yfull ; variable dct7 ; variable pdicn ; variable lang ; variable ccog ; variable cexp
		variable query ; variable logrequests ; variable hdr

		set id [subst -noc $requserid]
		set prefix [subst -noc $msgsend]

		if {$unick ne $uchan} {if {![channel get $uchan $chflag] ^ $flagactas eq "no" } {return}}
		set why  [queue_isfreefor $id]
		if {$why != ""} {lput puthelp $why $prefix ; return}

#---параметры

	set ustr $str
	set lng  [list en de nl es it zh ko no pt ru uk fr ja]
	set lni  [list "en (English)" "de (German)" "nl (Dutch; Flemish)" "es (Spanish; Castilian)" "it (Italian)" "zh (Chinese)" "ko (Korean)" "no (Norwegian)" "pt (Portuguese)" "ru (Russian)" "uk (Ukrainian)" "fr (French)" "ja (Japanese)"]
	set lng2 [list en de la pl ru uk fr]
	set lni2 [list Eng Ger Lat Pol Rus Ukr Fre]
	set lng3 [list en us be bg hu nl gr dk is es it lat lv lt mk de no pl pt ro ru sr sk sl uk fi fr hr cz sv eo ee]
	set lni3 [list en-gb en-us be-by bg-bg hu-hu nl-nl el-gr da-dk is-is es-es it-it la-va lv-lv lt-lt mk-mk de-de no-no pl-pl pt-pt ro-ro ru-ru sr-rs sk-sk sl-si uk-ua fi-fi fr-fr hr-hr cs-cz sv-se eo-xx et-ee]
	set lng4 [list de fr it es en uk ku la]
	set lni4 [list de-ru-de fr-ru-fr it-ru-it es-ru-es en-ru-en uk-ru ru-uk la-ru]
	set lng5 [list ? ar bg hr cz dk nl en fi fr de gr hi it ja no pl pt ro ru es sv ca tl iw lv lt sr sk sl uk af sq be hu id qa mk ms mt sw tr et sw th cy yi gl cn hi vi]
	set lni5 [list auto ar bg hr cs da nl en fi fr de el hi it ja no pl pt ro ru es sv ca tl iw lv lt sr sk sl uk af sq be hu id qa mk ms mt sw tr et sw th cy yi gl zh-CN hi vi]
	set lng6 [list en ru de fr sp it pl]
	set lni6 [list e r g f s i p]
	set lnp6 [list er re gr rg fr rf sr rs ir eg ge es se ep pe ef fe fs sf fg]
	set lng7 [list en de sp fr it du ee la af]
	set lni7 [list 1 3 5 4 23 24 26 27 31]
	array set dct7 {
    er {{Англо-Русский} {General} {Общая лексика} {Software} {Программное обеспечение} {Internet} {Интернет} {Automotive} {Автомобили} {Banking} {Банковское дело} {Business} {Деловая корреспонденция} {Games} {Компьютерные игры} {Logistics} {Логистика} {Sport} {Спорт} {Travels} {Путешествия}}
    re {{Русско-Английский} {General} {Общая лексика} {Software} {Програмное обеспечение} {Internet} {Интернет} {Phrasebook} {Разговорник} {Automotive} {Автомобили} {Business} {Деловая корреспонденция} {Logistics} {Логистика} {Travels} {Путешествия}}
    gr {{Немецко-Русский} {General} {Общая лексика} {Software} {Програмное обеспечение} {Internet} {Интернет} {Automotive} {Автомобили} {Business} {Деловая корреспонденция} {Football} {Футбол}}
    rg {{Русско-Немецкий} {General} {Общая лексика} {Internet} {Интернет} {Business} {Деловая корреспонденция} {Football} {Футбол}}
    fr {{Французско-Русский} {General} {Общая лексика} {Internet} {Интернет} {Business} {Деловая корреспонденция} {Perfumery} {Парфюмерия} {Football} {Футбол}}
    rf {{Русско-Французский} {General} {Общая лексика} {Internet} {Интернет} {Business} {Деловая корреспонденция}}
    sr {{Испанско-Русский} {General} {Общая лексика}}
    rs {{Русско-Испанский} {General} {Общая лексика}}
    ir {{Итальянско-Русский} {General} {Общая лексика}}
    eg {{Англо-Немецкий} {General} {Общая лексика} {Software} {Программное обеспечение} {Business} {Деловая корреспонденция} {Football} {Футбол}}
    ge {{Немецко-Английский} {General} {Общая лексика} {Software} {Программное обеспечение} {Business} {Деловая корреспонденция} {Football} {Футбол}}
    es {{Англо-Испанский} {General} {Общая лексика}}
    se {{Испанско-Английский} {General} {Общая лексика}}
    ef {{Англо-Французский} {General} {Общая лексика}}
    fe {{Французско-Английский} {General} {Общая лексика}}
    ep {{Англо-Португальский} {General} {Общая лексика}}
    pe {{Португальско-Английский} {General} {Общая лексика}}
    fg {{Французско-Немецкий} {General} {Общая лексика} {Football} {Футбол}}
    gf {{Немецко-Французский} {General} {Общая лексика} {Football} {Футбол}}
    fs {{Французско-Испанский} {General} {Общая лексика}}
    sf {{Испанско-Французский} {General} {Общая лексика}}
    gs {{Немецко-Испанский} {General} {Общая лексика} {Football} {Футбол}}
    sg {{Испанско-Немецкий} {General} {Общая лексика} {Football} {Футбол}}
    ie {{Итальянско-Английский} {General} {Общая лексика}}
	}
	set ya 0 ; set gt 0; set gta 0 ; set tru 0 ; set mtr 0 ; set ccog 0
	set query "" ; set hdr ""
	::http::config -urlencoding utf-8 -useragent "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; 240x320)"	

		if {[string trimleft $::lastbind $pubprefix] in $bmtr} {
			if {[string is space $ustr]} {lput putserv "\002Формат\002: ${pubprefix}[lindex ${bmtr} 0] \[язык\] \[+\]<слово> :: \002Языки\002: [join $lng7] :: \002en\002-английский, \002de\002-немецкий, \002fr\002-французский, \002sp\002-испанский, \002it\002-итальянский, \002du\002-голландский, \002la\002-латышский, \002ee\002-эстонский, \002af\002-африкаанс" $prefix ; return}
			if {[regexp -- {^-(\d+)} $ustr -> mpage]} {regsub -- {-\d+\s+} $ustr "" ustr} {set mpage 1}
			if {[lindex [split $ustr] 0] ni $lng7} {set lang 1 ; set ustr [lindex [split $ustr] 0]} {set lang [lindex $lni7 [lsearch -exact $lng7 [lindex [split $ustr] 0]]] ; set ustr [lindex [split $ustr] 1]}
			if {[string first "+" $ustr] == 0} {regsub -- {\+} $ustr "" ustr; set mtrt 1} {set mtrt 0}
			set fetchurl "${furl7}?l1=$lang&s=[uenc ${ustr}]" ; set type 1 ; set mtr 1
		} elseif {[string trimleft $::lastbind $pubprefix] in $bcog} {
			if {[string is space $ustr]} {lput putserv "\002Формат\002: ${pubprefix}[lindex ${bcog} 0] \[+\]<слово/фраза> :: русский и английский языки" $prefix ; return}
			if {[string first "+" $ustr] == 0} {regsub -- {\+} $ustr "" ustr; set cexp 1} {set cexp 0}
			::http::config -urlencoding cp1251 -useragent "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; 240x320)"	
			set query [::http::formatQuery inputtext $ustr submit "Translate text"]
			set fetchurl ${furl8} ; set ccog 1 ; set type 0
		} elseif {[string trimleft $::lastbind $pubprefix] in $bprm} {
			if {[string is space $ustr]} {lput putserv "\002Формат\002: ${pubprefix}[lindex ${bprm} 0] \[словарь\] \[номер варианта словаря\] <слово или фраза> :: \002Словари\002: [join $lnp6] :: \002e\002-английский, \002r\002-русский, \002g\002-немецкий, \002f\002-французский, \002s\002-испанский, \002i\002-итальянский, \002p\002-португальский" $prefix ; return}
			if {[lindex [split $ustr] 0] ni $lnp6} {
				if {[regexp -- {[а-яА-ЯёЁ]} $ustr]} {set lang "re"} {set lang "er"}
				if {[string is digit [lindex [split $ustr] 0]]} {
					set pdic  [lindex $dct7($lang) [expr {[lindex [split $ustr] 0] * 2 - 1}]] ; set pdicn [lindex $dct7($lang) [expr {[lindex [split $ustr] 0] * 2}]]
	 				set ustr [lrange [split $ustr] 1 end]	
				} {set pdic [lindex $dct7($lang) 1] ; set pdicn [lindex $dct7($lang) 2]}
			} {
				set lang [lindex [split $ustr] 0]
					if {[string is space [lindex $ustr 1]]} {
						set dctn "" ; set dn 1 ; foreach {- n} [lrange $dct7($lang) 1 end] {append dctn "\002$dn\002-$n " ; incr dn}
						lput putserv "\037Варианты словарей\037: $dctn" $prefix ; return
					}
					if {[string is digit [lindex [split $ustr] 1]]} {
						set pdic  [lindex $dct7($lang) [expr {[lindex [split $ustr] 1] * 2 - 1}]] ; set pdicn [lindex $dct7($lang) [expr {[lindex [split $ustr] 1] * 2}]]
						set ustr [lrange [split $ustr] 2 end]
					} {
						set pdic  [lindex $dct7($lang) 1] ; set pdicn [lindex $dct7($lang) 2]
	 					set ustr [lrange [split $ustr] 1 end]
					}
			}
			if {$pdic eq ""} {set pdic [lindex $dct7($lang) 1]}
#			set fetchurl "${furl61}?lang=ru&status=translate&template=$pdic&direction=${lang}&source=[uenc $ustr cp1251]" ; set type 1 ; set tru 1
			set fetchurl "${furl61}?text=[uenc $ustr utf-8]&dirCode=${lang}&asd=&kb1=&kb2=&kb3=&template=$pdic"  ; set type 1 ; set tru 1
			set hdr ""
#temp. promt
		} elseif {[regexp -nocase -- {^(.+?)@(.+?)\s(.+?)$} $ustr -> lang1 lang2 utxt]} {
			if {[lsearch -exact $lng $lang1] == -1 || [lsearch -exact $lng $lang2] == -1} {
				lput putserv "\037Неверно выбран язык перевода\037. [join $lng]" $prefix
				return
			} {
				set lang1 [lindex $lni [lsearch -exact $lng $lang1]] ; set lang2 [lindex $lni [lsearch -exact $lng $lang2]]
				set utxt [string map {" " "+"} [string trim $utxt]]
				set query [::http::formatQuery tr_text $utxt lang1 $lang1 lang2 $lang2 submit submit]
				set fetchurl $furl1 ; set type 0
			}
		} elseif {[regexp -nocase -- {^(.+?)\*(.+?)\s(.+?)$} $ustr -> lang1 lang2 utxt]} {
			if {[lsearch -exact $lng6 $lang1] == -1 || [lsearch -exact $lng6 $lang2] == -1} {
				lput putserv "\037Неверно выбран язык перевода\037. [join $lng6]" $prefix
				return
			} {
				set lang [lindex $lni6 [lsearch -exact $lng6 $lang1]][lindex $lni6 [lsearch -exact $lng6 $lang2]]
				set pdic  [lindex $dct7($lang) 1] ; set pdicn [lindex $dct7($lang) 2]
				if {$lang ni $lnp6} {lput putserv "\037Такое направление перевода не поддерживается\037." $prefix ; return}
				set fetchurl "${furl6}?lang=ru&status=translate&template=general&FromGoogle=WeAreFromGoogle&link=&direction=${lang}&source=[uenc $utxt]" ; set type 1 ; set tru 1
#				set fetchurl "${furl61}?lang=ru&status=translate&template=$pdic&&direction=${lang}&source=[uenc $ustr cp1251]" ; set type 1 ; set tru 1
#temp. promt
			}
		} elseif {[regexp -nocase -- {^(.+?)-(.+?)\s(.+?)$} $ustr -> lang1 lang2 utxt]} {
			if {[lsearch -exact $lng5 $lang1] == -1 || [lsearch -exact $lng5 $lang2] == -1} {
				lput putserv "\037Неверно выбран язык перевода\037. [join $lng5]" $prefix
				return
			} {
				set lang1 [lindex $lni5 [lsearch -exact $lng5 $lang1]] ; set lang2 [lindex $lni5 [lsearch -exact $lng5 $lang2]]
				set ustr $utxt
				if {$lang1 eq "auto"} {set gta 1} {set gta 0}
				::http::config -urlencoding utf-8 -useragent "Mozilla/6.0 (compatible;)"
				set query [::http::formatQuery text $utxt sl $lang1 tl $lang2 ie utf-8 submit Translate]	
				set fetchurl $furl5 ; set type 0 ; set gt 1
			}
		} elseif {[regexp -nocase -- {^(.+?)#(.+?)\s(.+?)$} $ustr -> lang1 lang2 utxt]} {
			if {[lsearch -exact $lng2 $lang1] == -1 || [lsearch -exact $lng2 $lang2] == -1} {
				lput putserv "\037Неверно выбран язык перевода\037. [join $lng2]" $prefix
				return
			} {
				set lang1 [lindex $lni2 [lsearch -exact $lng2 $lang1]] ; set lang2 [lindex $lni2 [lsearch -exact $lng2 $lang2]]
				set ustr $utxt
				set utxt [string map {" " "+"} [string trim $utxt]]
				set query [::http::formatQuery from_language $lang1 to_language $lang2 text_to_translate $utxt translation_theme "**" submit [encoding convertto [encoding system] "Перевести"]]
				set fetchurl $furl2 ; set type 0 
			}
		} elseif {[regexp -nocase -- {^(.+?)%(.+?)\s(.+?)$} $ustr -> lang1 lang2 utxt]} {
			if {[lsearch -exact $lng3 $lang1] == -1 || [lsearch -exact $lng3 $lang2] == -1} {
				lput putserv "\037Неверно выбран язык перевода\037. [join $lng3]" $prefix
				return
			} elseif {[llength [split [string trim $utxt]]] > 1} {
				lput putserv "\037В этом режиме переводится только \002одно\002 слово\037." $prefix
				return
			} {
				set lang1 [lindex $lni3 [lsearch -exact $lng3 $lang1]] ; set lang2 [lindex $lni3 [lsearch -exact $lng3 $lang2]]
				set ustr $utxt
				set utxt [uenc [string trim $utxt]]
				set fsuff "fcgi-bin/dic.fcgi?hn=sel&translate=%D0%9F%D0%B5%D1%80%D0%B5%D0%B2%D0%B5%D1%81%D1%82%D0%B8&ul=ru-ru&il=$lang1&ol=$lang2&iw=$utxt"
				set fetchurl $furl3$fsuff ; set type 1
			}
		} {
			if {![string is space $ustr]} {
					if {[regexp -- {\?} $ustr]} {
						set prefix [subst -noc $errsend]
						lput puthelp "\002Перевод \037фраз\037 \[Promt\]\002: \002${pubprefix}[lindex ${pub:perevod} 0]\002 en\002\*\002ru <фраза> \002:: Языки\002: \002ru\002-русский, \002en\002-английский, \002de\002-немецкий, \002pl\002-польский, \002sp\002-испанский, \002fr\002-французский" $prefix		
						lput puthelp "\002Перевод \037фраз\037 \[Google\]\002: \002${pubprefix}[lindex ${pub:perevod} 0]\002 en\002\-\002ru <фраза> \002:: Языки\002: \002ru\002-русский, \002en\002-английский, \002ar\002-арабский, \002bg\002-болгарский, \002hr\002-хорватский, \002cz\002-чешский, \002dk\002-датский, \002nl\002-голландский, \002fi\002-финский, \002fr\002-французский, \002de\002-немецкий, \002gr\002-греческий, \002hi\002-хинди, \002it\002-итальянский, \002ja\002-японский, \002no\002-норвежский, \002pl\002-польский, \002pt\002-португальский, \002ro\002-румынский, \002es\002-испанский, \002sv\002-шведский, \002ca\002-каталонский, \002tl\002-филлипинский, \002iw\002-иврит, \002lv\002-латвийский, \002lt\002-литовский, \002sr\002-сербский, \002sk\002-словацкий, \002sl\002-словенский, \002uk\002-украинский" $prefix   
						lput puthelp "\002Перевод \037фраз\037 \[Textpro\]\002: \002${pubprefix}[lindex ${pub:perevod} 0]\002 en\002\@\002ru <фраза> \002:: Языки\002: \002ru\002-русский), \002uk\002-украинский, \002en\002-английский, \002de\002-немецкий, \002nl\002-голландский, \002es\002-испанский, \002it\002-итальянский, \002no\002-норвежский, \002pt\002-португальский, \002fr\002-французский, \002ja\002-японский, \002zh\002-китайский, \002ko\002-корейский" $prefix		
						lput puthelp "\002Перевод \037фраз\037 \[Meta\]\002: \002${pubprefix}[lindex ${pub:perevod} 0]\002 uk\002\#\002ru <фраза> \002:: Языки\002: \002ru\002-русский, \002uk\002-украинский, \002en\002-английский, \002de\002-немецкий, \002pl\002-польский, \002la\002-латвийский, \002fr\002-французский" $prefix		
						lput puthelp "\002Перевод \037слов\037 \[Slovnik\]\002: \002${pubprefix}[lindex ${pub:perevod} 0]\002 de\002\%\002ru <слово> \002:: Языки\002: \002ru\002-русский, \002uk\002-украинский, \002be\002-беларусский, \002en\002-английский, \002us\002-американский, \002bg\002-болгарский, \002hu\002-венгерский, \002nl\002-голландский, \002gr\002-греческий, \002dk\002-датский, \002is\002-исландский, \002es\002-испанский, \002it\002-итальянский, \002lv\002-латышский, \002lt\002-литовский, \002ee\002-эстонский, \002mk\002-македонский, \002de\002-немецкий, \002no\002-норвежский, \002pl\002-польский, \002pt\002-португальский, \002ro\002-румынский, \002sr\002-сербский, \002sk\002-словацкий, \002sl\002-словенский, \002fi\002-финский, \002fr\002-французский, \002hr\002-хорватский, \002cz\002-чешский, \002sv\002-шведский, \002lat\002-латинский, \002eo\002-эсперанто" $prefix
					return
					}
					if {[regexp -nocase -- {^-(\d+)} $ustr -> mpg]} {set mpage $mpg ; regsub -- {-\d+\s+} $ustr "" ustr} {set mpage 1}
					if {[regexp -- {\+} $ustr]} {set yfull 1 ; regsub -- {\+} $ustr "" ustr} {set yfull 0}
				if {[lsearch -exact $lng4 [lindex $ustr 0]] != -1} {set fetchurl "$furl4\search.xml?lang=[lindex $lni4 [lsearch -exact $lng4 [lindex $ustr 0]]]&text=[uenc [lindex $ustr 1]]&where=3"} {set fetchurl "$furl4\search.xml?lang=en-ru-en&text=[uenc [lindex $ustr 0]]&where=3"} ; set type 1 ; set ya 1
			} {
				if {$uchan eq $unick} {set prefix [subst -noc $errsend]} {set prefix [subst -noc $pubsend]}
				lput puthelp "\037Перевод слов Yandex\037. \002Формат\002: \002${pubprefix}[lindex ${pub:perevod} 0]\002 \[\002-\002номер результата\] \[язык\] \[\002+\002\]<\037слово\037> :: \002Языки\002: \002de\002-немецкий, \002fr\002-французский, \002it\002-итальянский, \002es\002-испанский, \002en\002-английский (\037по умолчанию\037)" $prefix		
				lput puthelp "\037Перевод слов Multitran\037. \002Формат\002: \002${pubprefix}[lindex ${bmtr} 0]\002 \[\002-\002номер результата\] \[язык\] \[\002+\002\]<\037слово\037> :: \002Языки\002: \002de\002-немецкий, \002fr\002-французский, \002it\002-итальянский, \002sp\002-испанский, \002du\002-голландский, \002la\002-латышский, \002ee\002-эстонский, \002af\002-африкаанс, \002en\002-английский (\037по умолчанию\037)" $prefix		
				lput puthelp "\037Перевод фраз Cognitive\037. \002Формат\002: \002${pubprefix}[lindex ${bcog} 0]\002 \[\002+\002\]<\037слово или фраза\037> :: \002Языки\002: английский, русский" $prefix		
				lput puthelp "\037Перевод фраз Promt\037. \002Формат\002: \002${pubprefix}[lindex ${bprm} 0]\002 \[словарь\] \[номер варианта словаря\] <\037слово или фраза\037> :: \002Словари\002: [join $lnp6] :: \002Языки\002: \002e\002-английский, \002r\002-русский, \002g\002-немецкий, \002f\002-французский, \002s\002-испанский, \002i\002-итальянский, \002p\002-португальский" $prefix		
				lput puthelp "\002Пример\002: \002${pubprefix}[lindex ${pub:perevod} 0]\002 test :: \002${pubprefix}[lindex ${pub:perevod} 0]\002 -2 +test (\002+\002 перед словом - вывод с комментариями) :: \002${pubprefix}[lindex ${bmtr} 0]\002 de работа :: \002${pubprefix}[lindex ${bprm} 0]\002 rg проверка перевода" $prefix
				lput puthelp "\002Расширенный формат\002: \002${pubprefix}[lindex ${pub:perevod} 0]\002 язык1\002*-@#%\002язык2 <текст> :: \002Список языков\002: \002${pubprefix}[lindex ${pub:perevod} 0]\002 \002?\002" $prefix		
			return
			}
		}
		if {$logrequests ne ""} {set logstr [subst -noc $logrequests] ; lput putlog $logstr "$unamespace: "}
		if {[queue_add "$fetchurl" $id "[namespace current]::perevod:parser" [list $unick $uhost $uchan $ustr]]} {variable err_ok ; if {$err_ok ne ""} {lput puthelp "$err_ok." $prefix}} {variable err_fail ; if {$err_fail ne ""} {lput puthelp "$err_fail" $prefix}}
#putlog "$fetchurl"
	return
	}

#---parser
	proc perevod:parser {errid errstr body extra} {
		upvar $errid lerrid $errstr lerrstr $body lbody $extra lextra
		variable err_fail ;variable pubsend ; variable msgsend ; variable errsend ; variable useurl ; variable maxres
		variable type ; variable ya ; variable gt ; variable tru ; variable mtr ; variable mtrt ; variable gta ; variable mpage ; variable yfull ; variable ccog ; variable cexp
		variable dct7 ; variable pdicn ; variable lang

		foreach {unick uhost uchan ustr} $lextra {break}
		if {$lerrid ne {ok}} {lput putserv [subst -noc $err_fail] [subst -noc $errsend] ; return}
		if {$uchan eq $unick} {set prefix [subst -noc $msgsend]} {set prefix [subst -noc $pubsend]}
		if {[info exists ::sp_version]} {if {$gt} {if {$gta} {set str [encoding convertfrom utf-8 $lbody]} {set str [encoding convertfrom utf-8 $lbody]}} {if {$mtr || $ccog} {set str [encoding convertfrom cp1251 $lbody]} {set str [encoding convertfrom utf-8 $lbody]}}} {set str $lbody}
		#if {[info exists ::sp_version]} {if {$gt} {if {$gta} {set str $lbody} {set str $lbody}} {if {$mtr || $ccog} {set str [encoding convertfrom cp1251 $lbody]} {set str [encoding convertfrom utf-8 $lbody]}}} {set str $lbody}

#----------------------------------------------------------------------------
##---parser-specific------
#----------------------------------------------------------------------------

	if {$gt} {
		regsub -all "&raquo;" $str "-" str
		if {![regexp -- {</td><td id=autotrans style="display: block">.*?</span>(.+?)</td></tr>} $str {} det]} {set det ""}
		if {![regexp -- {<div id=result_box.*?>(.+?)</div>} $str - res]} {set res ""}
		if {$res != ""} {lput putserv "\[ Google \] ::[sconv $det] :: [sconv ${res}]" $prefix} {lput putserv "\037Ошибка перевода\037. :: $det" $prefix}
	} elseif {$mtr} {
		if {[regexp -- {<td width="10%">Варианты&nbsp;замены:</td><td width="90%">(.*?)</td></tr>} $str -> repl]} {
			regsub -all -nocase -- {&nbsp;} $repl {} repl
			regsub -all -nocase -- {<.*?>} $repl {} repl
			lput putserv "\037Варианты замены\037: [sconv [sspace $repl]]" $prefix
		return
		}
		regexp -nocase -- {</form>(.*?)<table border="0" width="100%" height="1">} $str -> str
		regsub -all -- "\n|\r|\t" $str "" str
		regsub -all -nocase -- {<td bgcolor="#DBDBDB" width="100%" colspan="2">} $str \n str
		set mtout [list] ; set cnt 0
			foreach mtl [split $str \n] {
				if {[regexp -nocase -- {<a href="m.exe\?a=.*?">(.*?)</a>.*?<em>(.*?)</em>.*?</td></tr><tr>(.*?)$} $mtl -> mword mtype mdat]} {
					regsub -all -nocase -- {<tr>} $mdat \n mdat
					set mword [string map -nocase {{<span STYLE="color:gray">} \00314 {<span STYLE="color:black">} \003} $mword]
					set mdout "" ; incr cnt
					foreach mdl [split $mdat \n] {
						if {[regexp -- {<td width="1%">.*?<a title="(.*?)".*?<i>(.*?)</i>(.*?)$} $mdl -> mdtype mdt mddat]} {
							if {$mtrt} {
								set mddat [string map -nocase {{<i>} \00315 {</i>} \003 {&nbsp;} {} {<span STYLE="color:gray">} \00314 {<span STYLE="color:black">} \003} $mddat]
								regsub -all -nocase -- {<.*?>} $mddat "" mddat
								append mdout " ($mdtype) $mddat ::"
							} {
								set mds ""
								foreach {- mdd} [regexp -all -inline -- {<a href="m.exe\?t=.*?">(.*?)</a>} $mddat] {append mds "$mdd; "}	
								append mdout "$mds"
							}	
						}
					}
				lappend mtout "\002$mword\002 - \00305$mtype\003 :: [string trimright $mdout " ::"]"
				}
			}
		if {$cnt > 0} {
			set mo [sconv [lindex $mtout [expr {$mpage - 1}]]]
			if {[string length $mo] > 380 && $uchan ne $unick} {lput putserv "\[ Multitran \] :: Перевод слишком большой, будет отправлен в приват." $prefix ; set prefix [subst -noc $msgsend]}
			lput putserv "\[ Multitran \] ($mpage/$cnt) :: $mo" $prefix
		} {lput putserv "\037Ошибка перевода\037." $prefix}
	} elseif {$tru} {
		if {[regexp -- {<textarea name="lResult".*?>(.*?)</textarea>} $str -> res]} {
			set res [sconv [sspace $res]]
			if {![string is space $res]} {lput putserv "\[ Promt \] \([lindex $dct7($lang) 0] :: $pdicn\) \002::\002 [sconv [sspace "$res"]]" $prefix} {lput putserv "\037Не удалось найти перевод\037." $prefix}
		} elseif {[regexp -- {<div class="tres">(.*?)</div>} $str -> res]} {
			if {![string is space $res]} {lput putserv "\[ Promt \] \([lindex $dct7($lang) 0] / $pdicn\) :: [sconv [sspace [join $res]]]" $prefix} {lput putserv "\037Не удалось найти перевод\037." $prefix}
		} {lput putserv "\037Ошибка перевода\037." $prefix}
	} elseif {$ya} {

		if {[string match -nocase "*Возможные варианты написания*" $str]} {
			regexp -nocase -- {<h2 class="b-title">(.*?)</h2><div class="info">(.*?)</div><div class="b-foot">} $str -> yword ysugg
			regsub -all -nocase -- {<p>} $ysugg " " ysugg
			regsub -all -nocase -- {<.*?>} $ysugg "" ysugg
			lput putserv "\002$yword\002 :: $ysugg" $prefix
		return
		}
	
		if {![regexp -nocase -- {<h2 class="b-title">(.*?)</h2><div class="info">(.*?)</div>} $str -> yword ydir]} {lput putserv "\037Не удалось найти перевод\037." $prefix ; return}
		regexp -- {<div class="res">(.*?)<div class="b-foot">} $str -> str
		regsub -all -- {(\d+)\)} $str "\002\\1\.\002" str
		regsub -all -- {<b>Syn:</b>} $str "\002\Syn:\002" str

		set str [sspace $str] ; set yres "" ; set cnt 0
		regsub -all -- "\n|\r|\t" $str {} str
		regsub -all -nocase -- {<b>I+\s</b>} $str "\n" str

		foreach ystr [split $str \n] {
			if {![string is space $ystr]} {incr cnt}
				if {$cnt == $mpage} {
					if {!$yfull} {regsub -all -nocase -- {<p class="m2">.*?</p>} $ystr "" ystr} {regsub -all -nocase -- {<p class="m2">(.*?)</p>} $ystr "\00314\\1\003" ystr}
					regsub -all -nocase -- {<I>(.*?)</I>} $ystr "\00314\\1\003" ystr
					regsub -all -nocase -- {<abbr title=".*?">(.*?)</abbr>} $ystr "\00305\\1\003 " ystr
					regsub -all -- "<.*?>" $ystr { } ystr
					set yres $ystr
				}
		}
		if {[string length $yres] > 380 && $uchan ne $unick} {lput putserv "\[ Yandex \] :: Перевод слишком большой, будет отправлен в приват." $prefix ; set prefix [subst -noc $msgsend]}
		if {$mpage <= $cnt} {lput putserv "\[ Yandex \] \($mpage/$cnt\) :: \00314[string map {"Переведено " "" "." ""} $ydir]\003 :: \002[sconv $yword]\002 :: [sconv [sspace $yres]]" $prefix} {lput putserv "\037Неверный номер результата\037. всего: $cnt" $prefix}
	} elseif {$ccog} {
	regsub -all -- "\n|\r|\t" $str "" str
	if {[regexp -- {<table><tbody>.*?<textarea rows=5 cols=32>(.*?)</textarea>.*?<textarea name="inputtext" rows=5 cols=32>(.*?)</textarea>} $str -> cin cdata]} {
		if {[regexp -- {<tr><td width=200>(.+?)</table></form>} $str -> cdop]} {
			regsub -all -nocase -- {<a href="#".*?>(.+?)</a>} $cdop " \002\\1\002 " cdop
			regsub -all -nocase -- {<div class="L1">(.+?)</div>} $cdop " \00314(\\1)\003 " cdop
			regsub -all -nocase -- {<div class=L2>(.+?)</div>} $cdop " \00305\\1\003 " cdop
			regsub -all -nocase -- {<div class=L3>(.+?)</div>} $cdop " \\1 " cdop
			regsub -all -nocase -- {<span class=g>(.+?)</span>} $cdop "\00303\\1\003" cdop
			regsub -all -nocase -- {<!-- hr -->} $cdop { :: } cdop
			regsub -all -- "<.*?>" $cdop " " cdop
		}
		regsub -all -- "<.*?>" $cdata " " cdata
		lput putserv "\[ Cognitive \] :: [sspace [sconv $cin]]" $prefix
		if {$cexp} {lput putserv [string trim [string trimright [sspace [sconv $cdop]] " :: "]] $prefix}
	} {lput putserv "\037Не удалось перевести\037." $prefix}
	} {
		set ostr "" ; set dic ""
		if {[regexp -nocase -- {<td class="alt2" width="50%" align="left" valign="top">(.*?)</tbody>} $str -> ostr]} {set dic "\[ Meta \]"}
		if {[regexp -nocase -- {<textarea id="translated_text_id" class="b_area">(.*?)</textarea>} $str -> ostr]} {set dic "\[ TextPro \]"}
		if {[regexp -nocase -- {<DT lang=.*?<INPUT maxlength="1024" name="iw" size="64" value="(.*?)" class="required">} $str -> ostr]} {set dic "\[ Slovnik \]"}
			regsub -all -- "\n|\t|\r" $ostr {} ostr
			regsub -all -nocase -- "<.*?>" $ostr {} ostr	
		if {![string is space $ostr]} {lput putserv "$dic :: [sconv [sspace $ostr]]" $prefix} {lput putserv "\037Нет перевода\037." $prefix}
		if {[string is space $dic]} {lput putserv "\037Не удалось перевести\037: $ustr." $prefix}
	}

	return
	}		
#----------------------------------------------------------------------------
##---ok------
#----------------------------------------------------------------------------
	proc sspace {strr} {return [string trim [regsub -all {[\t\s]+} $strr { }]]}

	proc uenc {strr {enc {utf-8}}} {
	set str "" ; foreach byte [split [encoding convertto $enc $strr] ""] {scan $byte %c i ; if {[string match {[%<>"]} $byte] || $i < 65 || $i > 122} {append str [format %%%02X $i]} {append str $byte}}
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
	set strr [string map {\[ \\\[ \] \\\] \( \\\( \) \\\) \{ \\\{ \} \\\} \\ \\\\} [string map $escapes [join [lrange [split $strr] 0 end]]]] 
  	regsub -all -- {&#([[:digit:]]{1,5});} $strr {[format %c [string trimleft "\1" "0"]]} strr
 	regsub -all -- {&#x([[:xdigit:]]{1,4});} $strr {[format %c [scan "\1" %x]]} strr
 	regsub -all -- {&#?[[:alnum:]]{2,7};} $strr "" strr
	return [subst -nov $strr]
	}

	proc lput {cmd str {prefix {}} {maxchunk 420}} {
	set buf1 ""; set buf2 [list]
		foreach word [split $str] {append buf1 " " $word ; if {[string length $buf1]-1 >= $maxchunk} {lappend buf2 [string range $buf1 1 end] ; set buf1 ""}}
		if {$buf1 != ""} {lappend buf2 [string range $buf1 1 end]}
		foreach line $buf2 {$cmd $prefix$line}

	return
	}

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

	proc queue_add {newurl id parser extra {redir 0}} {
		variable reqqueue ; variable proxy ; variable timeout ; variable laststamp ; variable query ; variable type ; variable hdr

		::http::config -proxyfilter "[namespace current]::queue_proxy"

	if {$type} {
		if {![catch {set token [::http::geturl $newurl -command [namespace current]::queue_done -binary true -timeout $timeout -headers $hdr]} errid]} {					
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
		
		set errid  [::http::status $token]
		set errstr [::http::error  $token]
		set	id [array  names reqqueue "$token,*"]
		foreach {parser extra redir} $reqqueue($id) {break}
		regsub -- "^$token," $id {} id
	
		while (1) {
			if {$errid == "ok" && [::http::ncode $token] == 302} {
				if {$redir < $maxredir} {			
					array set meta $state(meta)
					if {[info exists meta(Location)]} {queue_add "$fetchurl$meta(Location)" $id $parser $extra [incr redir] ; break}
				} {set errid "error" ; set errstr  "Maxi. redir."}
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
#--init
	if {[info exists timerID]} {catch {killtimer $timerID} ; catch {unset timerID}}	
	[namespace current]::queue_clear_stamps
	foreach bind [binds "[namespace current]::*"] {catch {unbind [lindex $bind 0] [lindex $bind 1] [lindex $bind 2] [lindex $bind 4]}}
	[namespace current]::cmdaliases
	putlog "[namespace current] v$version [expr {[info exists ::sp_version]?"(suzi_$::sp_version)":""}] :: file:[lindex [split [info script] "/"] end] / rel:\[$date\] / mod:\[[clock format [file mtime [info script]] -format "%d-%b-%Y : %H:%M:%S"]\] :: by $author :: loaded."

} ;#end perevod











###
#
#  Название: girls.tcl
#  Версия: 1.0
#  Автор: username 
#
###
#
# Описание: Скрипт забирает с сайта http://x-love.ru/ анкеты проституток.
#           Возможет поиск по таким параметрам как Размер бюста, Рост, Возраст, Цена услуг.
#
###
#
# Установка: 
#         1. Для работы скрипта необходим пакет http.tcl
#         2. Скопируйте скрипт girls1.0.tcl в папку scripts вашего бота.
#         3. В файле eggdrop.conf _после_ загрузки http.tcl впишите 
#            строку source scripts/girls1.0.tcl 
#         4. Сделайте .rehash боту.
#
###
#
# Версион хистори:
#
#              1.0(28.02.2008) Первая версия.
#
###

# Указываем пространство имен.
namespace eval girls {}

# Сбрасываем значения всех переменных.
foreach p [array names girls *] { catch {unset girls($p) } }

# Указываем канальный флаг(.chanset #chan +nopubgirls для отключения скрипта).
setudef flag nopubgirls

###                            ###
# Меню настроек ниже этой линии: #
# ______________________________ #
###                            ###

# Префикс команд.
set girls(pref) "!"

# Список команд на которые будет отзываться скрипт.
set girls(binds) "девушки girls девушка"

# Разрешить работу со скриптом в привате у бота? (да-1/нет-0)
set girls(msg) 1

# Сколько команд за сколько секунд считать флудом и начинать игнорить юзера.
set girls(flood) 6:60

# Время(мин) игнора.
set girls(ignore) 3

# Сколько анкет девушек показывать в результатах поиска и по команде без параметров.
set girls(count) 5

###
# Настройки цветов.

# Цвет полей анкеты.
set girls(color1) "\00303"

# Цвет значейний анкеты.
set girls(color2) "\00305"

# Цвет услуг девушки.
set girls(color3) "\00310"

# Цвет описания девушки.
set girls(color4) "\00304"
###

###                                                                  ###
# Ниже этой линии начинается код, не изменяйте его если не знаете TCL: #
# ____________________________________________________________________ #
###                                                                  ###

# Версия скрипта.
set girls(version) "girls.tcl version 1.0"

# Автор скрипта.
set girls(author) "username"

# Обработка биндов.
foreach bind [split $girls(binds) " "] {
bind pub -|- "$girls(pref)$bind" girls_pub
if {$girls(msg) >= 1} {
bind msg -|- "$girls(pref)$bind" girls_msg
  }
}

# Процедура обработки приватных команд.
proc girls_msg {nick uhost hand text} {
global girls
girls_proc "PRIVMSG" $nick $uhost $hand $nick $text
}

# Процедура обработки паблик команд.
proc girls_pub {nick uhost hand chan text} {
global girls

# Проверяем наличие флага.
if {[channel get $chan nopubgirls]} { 
return 
}
girls_proc "NOTICE" $nick $uhost $hand $nick $text
}

# Процедура обработки запроса.
proc girls_proc {method nick uhost hand chan text} {
global girls lastbind
variable url

# Проверка на флуд.
if {[flood_girls $nick $uhost]} {
return
}

putlog "$nick/$chan $lastbind"

set text [girls_tolower $text]

if {$text == "" } {

girls_parser "$method" "$chan" "http://pda.x-love.ru/index.php?city=&metro=&bust_from=&bust_to=&age_from=&age_to=&height_from=&height_to=&price_from=&price_to="

} elseif {[isnumber $text]} {

set agent "Mozilla"
set girls(agent) [::http::config -useragent $agent]
set girls(url) [::http::geturl "http://pda.x-love.ru/details.php?id=$text" -timeout 25000]
set html [::http::data $girls(url)]
::http::cleanup $girls(url)

regsub -all -nocase -- {\n} $html "" html
regsub -all -nocase -- {</td>} $html "" html
regsub -all -nocase -- {</tr>} $html "" html
regsub -all -nocase -- {</span>} $html "" html
regsub -all -nocase -- {</table>} $html "" html
regsub -all -nocase -- {</th>} $html "" html
regsub -all -nocase -- {<span.*?>} $html "" html
regsub -all -nocase -- {&nbsp} $html " " html
regsub -all -nocase -- {<th>} $html "" html
regsub -all -nocase -- {<br>} $html "" html
regsub -all -nocase -- {<b>} $html "" html
regsub -all -nocase -- {<td>} $html "" html
regsub -all -nocase -- {<tr>} $html "" html
regsub -all -nocase -- {<!--MAIN-->} $html "" html
regsub -all -nocase -- {</BODY>} $html "" html
regsub -all -nocase -- {</HTML>} $html "" html
regsub -all -nocase -- {<table.*?>} $html "" html
regsub -all -nocase -- {<td.*?>} $html "" html
regsub -all -nocase -- {<img.*?>} $html "" html
regsub -all -nocase -- {<p.*?>} $html "" html
regsub -all -nocase -- {<a.*?>.*?</a>} $html "" html
regsub -all -nocase -- {<h3.*?>.*?</a>} $html "" html
regsub -all -nocase -- {  } $html " " html
regsub -all -nocase -- {<col align=center>} $html "\n" html
    if {$html == ""} {
        putquick "$method $chan :$girls(color1)Девушки с ID $girls(color2)$text $girls(color1)не существует."
        return 
    }
    foreach line [split $html "\n"] {
        if {[regexp -nocase -- {<font color=#FFFF00>.*?</font> <font color=#FFFF00>(.*?)</font>возраст:(.*?) рост:(.*?) вес:(.*?) бюст:(.*?) размер:(.*?) город:(.*?) метро:(.*?)выезд1 час:(.*?) 2 часа:(.*?) ночь:(.*?) апартаменты1 час:(.*?) 2 часа:(.*?) ночь:(.*?) телефон:(.*?)<I>услуги:<FONT color= #FFFFFF>(.*?)</FONT></I>(.*?)</P>} $line garb name age height weight boobs size city metro v1hour v2hour vnight a1hour a2hour anight phone uslugi descr]} {
            putquick "$method $chan :$girls(color1)Имя: $girls(color2)$name"
            putquick "$method $chan :$girls(color1)Возраст: $girls(color2)$age"
            putquick "$method $chan :$girls(color1)Рост: $girls(color2)$height"
            putquick "$method $chan :$girls(color1)Вес: $girls(color2)$weight"
            putquick "$method $chan :$girls(color1)Бюст: $girls(color2)$boobs"
            putquick "$method $chan :$girls(color1)Размер: $girls(color2)$size"
            putquick "$method $chan :$girls(color1)Город: $girls(color2)$city$girls(color1), Метро: $girls(color2)$metro"
            putquick "$method $chan :$girls(color1)Выезд час: $girls(color2)$v1hour$girls(color1), 2 часа: $girls(color2)$v2hour$girls(color1), ночь: $girls(color2)$vnight"
                if {[regexp -nocase -- {(.*?)доп.\ услуги(.*?)\ ;р} $anight garb anight2 dopusl]} {
                    putquick "$method $chan :$girls(color1)Апартаменты час: $girls(color2)$a1hour$girls(color1), 2 часа: $girls(color2)$a2hour$girls(color1), ночь: $girls(color2)$anight2"
                    putquick "$method $chan :$girls(color1)Дополнительные услуги: $girls(color2)$dopusl $girls(color1)р"
                } else {
                    putquick "$method $chan :$girls(color1)Апартаменты час: $girls(color2)$a1hour$girls(color1), 2 часа: $girls(color2)$a2hour$girls(color1), ночь: $girls(color2)$anight"
                }
            regsub -all -nocase -- {Золот.} $uslugi {Золотой} uslugi
            putquick "$method $chan :$girls(color1)Телефон: $girls(color2)$phone"
            girls_largetext $method $chan "$girls(color1)Услуги: $girls(color3)$uslugi" $girls(color3)
            girls_largetext $method $chan "$girls(color1)О девушке: $girls(color4)$descr" $girls(color4)
            putquick "$method $chan :$girls(color1)Ссылка на фото девушки: \037\00312http://x-love.ru/details.php?id=$text\037"
        }
    }
    return
} elseif {[string match "-*" $text]} {

set key [lindex [split $text] 0]
set min [lindex [split $text] 1]
set max [lindex [split $text] 2]

switch -exact -- "$key" {
"-город" {
putquick "$method $chan :$girls(color1)Ищем анкеты девушек города $girls(color2)$min$girls(color1)."
girls_parser "$method" "$chan" "http://pda.x-love.ru/index.php?city=$min&metro=&bust_from=&bust_to=&age_from=&age_to=&height_from=&height_to=&price_from=&price_to="
}
"-метро" {
putquick "$method $chan :$girls(color1)Ищем анкеты девушек недалеко от метро $girls(color2)$min$girls(color1)."
girls_parser "$method" "$chan" "http://pda.x-love.ru/index.php?city=&metro=$min&bust_from=&bust_to=&age_from=&age_to=&height_from=&height_to=&price_from=&price_to="
}
"-бюст" {
if {$max != ""} {
putquick "$method $chan :$girls(color1)Ищем анкеты девушек с бюстом от $girls(color2)$min $girls(color1)до $girls(color2)$max $girls(color1)размера."
girls_parser "$method" "$chan" "http://pda.x-love.ru/index.php?city=&metro=&bust_from=$min&bust_to=$max&age_from=&age_to=&height_from=&height_to=&price_from=&price_to="
} else {
putquick "$method $chan :$girls(color1)Ищем анкеты девушек с бюстом $girls(color2)$min $girls(color1)размера."
girls_parser "$method" "$chan" "http://pda.x-love.ru/index.php?city=&metro=&bust_from=$min&bust_to=$max&age_from=&age_to=&height_from=&height_to=&price_from=&price_to="
}
}
"-возраст" {
if {$max != ""} {
putquick "$method $chan :$girls(color1)Ищем анкеты девушек в возрасте от $girls(color2)$min $girls(color1) до $girls(color2)$max $girls(color1)лет."
girls_parser "$method" "$chan" "http://pda.x-love.ru/index.php?city=&metro=&bust_from=&bust_to=&age_from=$min&age_to=$max&height_from=&height_to=&price_from=&price_to="
} else {
putquick "$method $chan :$girls(color1)Ищем анкеты девушек в возрасте от $girls(color2)$min $girls(color1)лет."
girls_parser "$method" "$chan" "http://pda.x-love.ru/index.php?city=&metro=&bust_from=&bust_to=&age_from=$min&age_to=$max&height_from=&height_to=&price_from=&price_to="
}
}
"-рост" {
if {$max != ""} {
putquick "$method $chan :$girls(color1)Ищем анкеты девушек ростом от $girls(color2)$min $girls(color1) до $girls(color2)$max $girls(color1)см."
girls_parser "$method" "$chan" "http://pda.x-love.ru/index.php?city=&metro=&bust_from=&bust_to=&age_from=&age_to=&height_from=$min&height_to=$max&price_from=&price_to="
} else {
putquick "$method $chan :$girls(color1)Ищем анкеты девушек ростом от $girls(color2)$min $girls(color1)см."
girls_parser "$method" "$chan" "http://pda.x-love.ru/index.php?city=&metro=&bust_from=&bust_to=&age_from=&age_to=&height_from=$min&height_to=$max&price_from=&price_to="
}
}
"-цена" {
if {$max != ""} {
putquick "$method $chan :$girls(color1)Ищем анкеты девушек с ценой на услуги от $girls(color2)\$/руб.$min $girls(color1)до $girls(color2)\$/руб.$max$girls(color1)."
girls_parser "$method" "$chan" "http://pda.x-love.ru/index.php?city=&metro=&bust_from=&bust_to=&age_from=&age_to=&height_from=&height_to=&price_from=$min&price_to=$max"
} else {
putquick "$method $chan :$girls(color1)Ищем анкеты девушек с ценой на услуги от $girls(color2)$min $girls(color1)руб."
girls_parser "$method" "$chan" "http://pda.x-love.ru/index.php?city=&metro=&bust_from=&bust_to=&age_from=&age_to=&height_from=&height_to=&price_from=$min&price_to=$max"
}
}
default {
putquick "$method $chan :$girls(color1)Список ключей поиска: $girls(color2)-город -метро -бюст -возраст -рост -цена"
}
}

}

#proc end
}

# Продедура пасинга страницы с анкетами.
proc girls_parser {method dest url} {
global girls
global lastbind
variable count

set agent "Mozilla"
set girls(agent) [::http::config -useragent $agent]
set girls(url) [::http::geturl "$url" -timeout 25000]
set html [::http::data $girls(url)]
::http::cleanup $girls(url)

regsub -all -nocase -- {\n} $html "" html
regsub -all -nocase -- {</td><td height=25>} $html "</td><td height=25>|%\n" html
regsub -all -nocase -- {<table.*?>} $html "" html
regsub -all -nocase -- {<td.*?>} $html "" html
regsub -all -nocase -- {<img.*?>} $html "" html
regsub -all -nocase -- {<tr>} $html "" html
regsub -all -nocase -- {<span.*?>} $html "" html
regsub -all -nocase -- {</table>} $html "" html
regsub -all -nocase -- {</td>} $html "" html
regsub -all -nocase -- {</tr>} $html "" html
regsub -all -nocase -- {</span>} $html " " html
regsub -all -nocase -- {&nbsp;} $html "" html
regsub -all -nocase -- {\[.*?\]} $html "" html
regsub -all -nocase -- {</a>} $html "" html
regsub -all -nocase -- {  } $html " " html
regsub -all -nocase -- {<br> <br>} $html "\n" html
set count 0
	foreach line [split $html "\n"] {
    if {[string match "*Попробуйте сформулировать запрос иначе.*" $line]} {
        putquick "$method $dest :$girls(color1)По вашему запросу ничего не найдено. Попробуйте сформулировать запрос иначе."
        return 0
    }
      if {[regexp -nocase -- {(.*?)аст: (.*?)рост: (.*?) вес: (.*?)бюст: (.*?) город: (.*?) метро: (.*?) выезд:1 час: (.*?) 2 часа: (.*?) ночь: (.*?) апартаменты:1 час: (.*?) 2 часа: (.*?) ночь: (.*?)  телефон: (.*?)%} $line garb name age height weight boobs city metro v1hour v2hour vnight a1hour a2hour anight phone]} {
          if {[regexp -nocase -- {<a\ href=\/details.php\?id=(.*?)\ target=_blank><a\ href=\/details.php\?id=(.*?)\ class=index1\ target=_blank>(.*?)\ возр} $name garb id id2 name]} {
          }
              set regz "<a\\ href=\\/details.php\\?id=$id\\ class=index1\\ target=_blank>(.*?)\\|"
              if {[regexp -nocase -- $regz $phone garb phone]} {
              }
              putquick "$method $dest :$girls(color1)Случайная анкета \002№$girls(color2)[expr $count +1]$girls(color1)\002, ID: $girls(color2)$id"
              putquick "$method $dest :$girls(color1)Имя: $girls(color2)$name$girls(color1), Возраст: $girls(color2)$age$girls(color1), Рост: $girls(color2)$height$girls(color1), Вес: $girls(color2)$weight$girls(color1), Бюст: $girls(color2)$boobs$girls(color1), Город: $girls(color2)$city$girls(color1), Метро: $girls(color2)$metro$girls(color1)."
             #putquick "$method $dest :$girls(color1)Выезд: Час: $girls(color2)$v1hour$girls(color1), 2 Часа: $girls(color2)$v2hour$girls(color1), Ночь: $girls(color2)$vnight$girls(color1), Апартаменты: Час: $girls(color2)$a1hour$girls(color1), 2 Часа: $girls(color2)$a2hour$girls(color1), Ночь: $girls(color2)$anight$girls(color1), Телефон: $girls(color2)$phone$girls(color1)."
              putquick "$method $dest :$girls(color1)Для просмотра подробной анкеты девушки пиши $girls(color2)$lastbind $id$girls(color1)."
                  incr count
                      if {$count == $girls(count)} {return 0}
	       } 
      }
return
}


proc girls_largetext {method target text color {lineLen 200} {delims {,.}}} {
     global bor girls
     regsub -all {\{} $text "" text
     regsub -all {\}} $text "" text
     if {[string length $text] <= $lineLen} { 
         putserv "$method $target :$color$text"
         return
     }
  set _text [split $text $delims]
  set x 0; set i 0
  while {$x < $lineLen} {
    if {$i >= [llength $_text]} { return }
    set wordlen [string length [lindex $_text $i]];
      if {$x + $wordlen > $lineLen} { break }
      incr x $wordlen
      incr x; incr i
      }
putserv "$method $target :$color[string range $text 0 [expr $x - 1]]"
girls_largetext $method $target [string trimleft [string range $text $x end]] $color $lineLen $delims
}

    # Процедура инициализации антифлуда.
    proc flood_init {} {
    variable flood_array
    global girls
      if {$girls(ignore) < 1} {
        return 0
      }
      if {![string match *:* $girls(flood)]} {
        putlog "$girls(version): variable flood not set correctly."
        return 1
      }
      set girls(flood_num) [lindex [split $girls(flood) :] 0]
      set girls(flood_time) [lindex [split $girls(flood) :] 1]
      set i [expr $girls(flood_num) - 1]
      while {$i >= 0} {
        set flood_array($i) 0
        incr i -1
      }
    }
    ; flood_init

    # Процедура обновляет и возвращает флудстатус юзеров.
    proc flood_girls {nick uhost} {
    variable flood_array
    global girls
     if {$girls(ignore) < 1} {
        return 0
      }
      if {$girls(flood_num) == 0} {
        return 0
      }
      set i [expr $girls(flood_num) - 1]
      while {$i >= 1} {
        set flood_array($i) $flood_array([expr $i - 1])
        incr i -1
      }
      set flood_array(0) [unixtime]
      set aaa [expr $girls(flood_num) - 1]
      set bbb [expr [unixtime] - $flood_array($aaa)]
      if {$bbb <= $girls(flood_time) } {
        putlog "$girls(version): flood detected from ${nick}."
        putquick "NOTICE $nick :$girls(color1)В следующий раз команда будет доступна через $girls(color2)$girls(ignore) $girls(color1)минут."
        newignore [join [maskhost *!*[string trimleft $uhost ~]]] $girls(version) flooding $girls(ignore)
        catch {unset girls($uhost)}
        return 1
      } else {
        return 0
      }
    }

# Процедура перевода текста в нижний регистр.
proc girls_tolower {text} {
	return [string map {А а Б б В в Г г Д д Е е Ё ё Ж ж З з И и Й й К к Л л М м Н н О о П п Р р С с Т т У у Ф ф Х х Ц ц Ч ч Ш ш Щ щ Ъ ъ Ы ы Ь ь Э э Ю ю Я я} [string tolower $text]]
}

# Выводим сообщение о том, что скрипт удачно загружен.
putlog "\[girls\] $girls(version) by $girls(author) loaded"
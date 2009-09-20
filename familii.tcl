###
#
#  Название: familii.tcl
#  Версия: 1.0
#  Автор: username 
#
###
#
# Описание: Скрипт выдает результаты компьютерного фоносемантического анализа фамилий
#           с сайта http://www.analizfamilii.ru/
#
###
#
# Установка: 
#         1. Скопируйте скрипт familii1.0.tcl в папку scripts вашего бота.
#         2. В файле eggdrop.conf впишите строку source scripts/familii1.0.tcl 
#         4. Сделайте .rehash боту.
#
###
#
# Версион хистори:
#
#              1.0(26.11.2007) Первая паблик версия.
#
###

# Указываем пространство имен.
namespace eval familii {}

# Сбрасываем значения всех переменных.
foreach p [array names familii *] { catch {unset familii($p) } }

# Указываем канальный флаг(.chanset #chan +nopubfamilii для отключения скрипта).
setudef flag nopubfamilii

###                            ###
# Меню настроек ниже этой линии: #
# ______________________________ #
###                            ###

# Префикс команд.
set familii(pref) "!"

# Список команд на которые будет отзываться скрипт.
set familii(binds) "familia фамилия"

# Разрешить работу со скриптом в привате у бота? (да-1/нет-0)
set familii(msg) 1

# Каналы на которых будет работать этот скрипт.
set familii(channels) "#egghelp #testchan #bash.org"

# Сколько команда за сколько секунд считать флудом и начинать игнорить юзера.
set familii(flood) 5:180

# Время(мин) игнора.
set familii(ignore) 10

###
# Настройки цветов.

# Основной цвет текста.
set familii(color1) "\00314"

# Цвет фамилий.
set familii(color2) "\00303"

# Цвет положительных характеристик.
set familii(color3) "\00310"

# Цвет отрицательных характеристик.
set familii(color4) "\00305"
###

###                                                                  ###
# Ниже этой линии начинается код, не изменяйте его если не знаете TCL: #
# ____________________________________________________________________ #
###                                                                  ###

   # Проверяем наличие egglib.
   if { ![info exists egglib(ver)] } {
   putlog "***********************************************"
   putlog "             egglib_pub NOT FOUND !"
   putlog "   Download last version of egglib_pub here:"
   putlog "  http://eggdrop.org.ru/scripts/egglib_pub.zip"
   putlog "***********************************************"    
   die
   }

   if { [expr {$egglib(ver) < 1.4}] } {
   putlog "***********************************************"
   putlog " YOUR VERSION OF egglib_pub IS TOO OLD !"
   putlog "   Download last version of egglib_pub here:"
   putlog "  http://eggdrop.org.ru/scripts/egglib_pub.zip"
   putlog "***********************************************"
   putlog " version installed : $egglib(ver)"
   putlog " version required: 1.4"
   die
}

# Версия скрипта.
set familii(version) "familii.tcl version 1.0"

# Автор скрипта.
set familii(author) "username"

# Обработка биндов.
foreach bind [split $familii(binds) " "] {
    bind pub -|- "$familii(pref)$bind" familii_pub
    if {$familii(msg) >= 1} {
        bind msg -|- "$familii(pref)$bind" familii_msg
    }
}

# Процедура обработки приватных команд.
proc familii_msg {nick uhost hand text} {
    global familii
    familii_proc $nick $uhost $hand $nick $text
}

# Процедура обработки паблик команд.
proc familii_pub {nick uhost hand chan text} {
    global familii

    if {[string range $chan 0 0] == "#" && [lsearch -exact [split [string tolower $familii(channels)]] [string tolower $chan]] == -1} {
        return
    }

    # Проверяем наличие флага.
    if {[channel get $chan nopubfamilii]} { 
        return 
    }
    familii_proc $nick $uhost $hand $chan $text
}

proc familii_proc {nick uhost hand chan text} {
global familii lastbind

    # Проверка на флуд.
    if {[familii_flood $nick $uhost]} {
        return
    }

set text [lindex [split $text] 0]
    if {$text == ""} { 
    putserv "PRIVMSG $chan :$familii(color2)$nick$familii(color1), используй: $familii(color2)$lastbind <фамилия>\003"
    return
    }
putlog "\[familii\] $text $nick/$chan"
set query "http://www.analizfamilii.ru/pham.php?pham=$text"
set id [::egglib::http_init "familii_"]
::egglib::http_get $id $query [list $nick $uhost $chan $text]
}
   
proc familii_on_error {id nick uhost chan text} {
    putserv "PRIVMSG $chan :$familii(color1)Я не смог соединиться с $familii(color2)http://www.analizfamilii.ru $familii(color1)..."
}
   
proc familii_on_data {id data nick uhost chan text} {
global familii
regsub -all -- "\n" $data {} data
    foreach line [split $data "\n"] {
        if {[regexp -nocase -- {<p></p><I></index>(.*?)</I><BR><BR><index>} $line garb val]} {
            regsub -all -- "<FONT\ COLOR=#2f63fa>" $val "$familii(color3)" val
            regsub -all -- "<FONT\ COLOR=#ff0000>" $val "$familii(color4)" val
            regsub -all -- "," $val "$familii(color1)," val
            regsub -all -- "<B>" $val {} val
            regsub -all -- "</B>" $val {} val
            regsub -all -- "</FONT>" $val {} val
                if {$nick == $chan } {
                putserv "PRIVMSG $nick :$familii(color1)Результат компьютерного фоносемантического анализа слова $familii(color2)$text$familii(color1)\: это слово обладает следующими фоносемантическими признаками из 25 возможных\: $val"
                return
                } else {
                putserv "PRIVMSG $chan :$familii(color1)Результат компьютерного фоносемантического анализа слова $familii(color2)$text$familii(color1)\: это слово обладает следующими фоносемантическими признаками из 25 возможных\: $val"
                return
                }
        }
    }
putserv "PRIVMSG $chan :$familii(color1)Я не смог узнать результаты компьютерного фоносемантического анализа слова $familii(color2)$text$familii(color1)."
}

    # Процедура инициализации антифлуда.
    proc flood_init {} {
    variable flood_array
    global familii
      if {$familii(ignore) < 1} {
        return 0
      }
      if {![string match *:* $familii(flood)]} {
        putlog "$familii(version): variable flood not set correctly."
        return 1
      }
      set familii(flood_num) [lindex [split $familii(flood) :] 0]
      set familii(flood_time) [lindex [split $familii(flood) :] 1]
      set i [expr $familii(flood_num) - 1]
      while {$i >= 0} {
        set flood_array($i) 0
        incr i -1
      }
    }
    ; flood_init

    # Процедура обновляет и возвращает флудстатус юзеров.
    proc familii_flood {nick uhost} {
    variable flood_array
    global familii
     if {$familii(ignore) < 1} {
        return 0
      }
      if {$familii(flood_num) == 0} {
        return 0
      }
      set i [expr $familii(flood_num) - 1]
      while {$i >= 1} {
        set flood_array($i) $flood_array([expr $i - 1])
        incr i -1
      }
      set flood_array(0) [unixtime]
      set aaa [expr $familii(flood_num) - 1]
      set bbb [expr [unixtime] - $flood_array($aaa)]
      if {$bbb <= $familii(flood_time) } {
        putlog "$familii(version): flood detected from ${nick}."
        newignore [join [maskhost *!*[string trimleft $uhost ~]]] $familii(version) flooding $familii(ignore)
        catch {unset familii($uhost)}
        return 1
      } else {
        return 0
      }
    }

# Выводим сообщение о том, что скрипт удачно загружен.
putlog "\[familii\] $familii(version) by $familii(author) loaded"
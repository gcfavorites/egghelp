###
#
#  Название: uhelp.tcl
#  Версия: 1.0
#  Автор: username 
#
###
#
# Описание:  Структурированный хелп для бота. Идея DNK@IrcNet.ru
#
###
#
# Установка: 
#         1. Скопируйте скрипт uhelp1.0.tcl в папку scripts/uhelp вашего бота.
#         2. Файлы помощи help.txt, help1.txt, help2.txt, ... поместите в папку scripts/uhelp
#         3. В файле eggdrop.conf впишите строку source scripts/uhelp/uhelp1.0.tcl 
#         4. Сделайте .rehash боту.
#
###
#
# Версион хистори:
#
#              1.0(22.12.2007) Первая паблик версия.
#
###

# Указываем пространство имен.
namespace eval uhelp {}

# Сбрасываем значения всех переменных.
foreach p [array names uhelp *] { catch {unset uhelp($p) } }

# Указываем канальный флаг(.chanset #chan +nopubuhelp для отключения скрипта).
setudef flag nopubuhelp

###                            ###
# Меню настроек ниже этой линии: #
# ______________________________ #
###                            ###

# Префикс команд.
set uhelp(pref) "!"

# Список команд на которые будет отзываться скрипт.
set uhelp(binds) "help хелп"

# Тут указываем ключевые слова и файлы которые им соответствуют.
# Первой строкой укажите файл читаемый при команде без ключевого слова.
set uhelp(trigs) {
scripts/uhelp/help.txt
инфо scripts/uhelp/help1.txt
игры scripts/uhelp/help2.txt
знания scripts/uhelp/help3.txt
}

# Разрешить работу со скриптом в привате у бота? (да-1/нет-0)
set uhelp(msg) 1

# Каналы на которых будет работать этот скрипт.
set uhelp(channels) "#egghelp #testchan"

# Сколько команда за сколько секунд считать флудом и начинать игнорить юзера.
set uhelp(flood) 5:60

# Время(мин) игнора.
set uhelp(ignore) 10

###
# Настройки цветов.

# Основной цвет текста.
set uhelp(color1) "\00314"

# Цвет строки количества просмотров.
set uhelp(color2) "\00310"

# Цвет текста количества просмотров.
set uhelp(color3) "\00304"
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
set uhelp(version) "uhelp.tcl version 1.0"

# Автор скрипта.
set uhelp(author) "username"

# Обработка биндов.
foreach bind [split $uhelp(binds) " "] {
    bind pub -|- "$uhelp(pref)$bind" uhelp_pub
    if {$uhelp(msg) >= 1} {
        bind msg -|- "$uhelp(pref)$bind" uhelp_msg
    }
}

# Процедура обработки приватных команд.
proc uhelp_msg {nick uhost hand text} {
    global uhelp
    uhelp_proc $nick $uhost $hand $nick $text
}

# Процедура обработки паблик команд.
proc uhelp_pub {nick uhost hand chan text} {
    global uhelp

    # Проверяем наличие флага.
    if {[channel get $chan nopubuhelp]} { 
        return 
    }
    uhelp_proc $nick $uhost $hand $chan $text
}

# Процедура обработки запроса.
proc uhelp_proc {nick uhost hand chan text} {
    global uhelp lastbind

    # Проверка на флуд.
    if {[flood_uhelp $nick $uhost]} {
        return
    }
    foreach trig [split $uhelp(trigs) "\n"] {
        lappend triglist [lindex [split $trig " "] 0]
        if {[string tolower [lindex $text 0]] == [string tolower [lindex [split $trig " "] 0]]} {
                set uhelpname [lindex [split $trig " "] 1]
                set uhelpdata [::egglib::readdata $uhelpname]
        }
    }
        if {[string tolower [lindex $text 0]] == ""} {
                set uhelpname [lindex [split $uhelp(trigs) "\n"] 1]
                set uhelpdata [::egglib::readdata $uhelpname]
        }
        if {[isnumber [lindex $uhelpdata 0]]} {
            set uhelpdata2 [lrange $uhelpdata 1 end]
            foreach line $uhelpdata2 {
                if { $line != "" } {
                    uhelp_largetext $nick $line
                }
    }
        set counter [expr [lindex $uhelpdata 0]+1]
        putserv "privmsg $nick :$uhelp(color2)Этот файл просмотрели $uhelp(color3)$counter $uhelp(color2)ра[lindex {. з за з} [numgrp $counter]].\003"
        uhelp_largetext $nick "Смотри также $uhelp(color2)$lastbind $uhelp(color3)[lrange $triglist 2 end]" 
        set uhelpdata2 [linsert $uhelpdata2 0 $counter]
        ::egglib::writedata "$uhelpname" $uhelpdata2
    } else {
            foreach line $uhelpdata {
                if { $line != "" } {
                    uhelp_largetext $nick $line
                }
            }
        putserv "privmsg $nick :$uhelp(color2)Этот файл просмотрели $uhelp(color3)1 $uhelp(color2)раз."
        set uhelpdata [linsert $uhelpdata 0 "1"]
        ::egglib::writedata "$uhelpname" $uhelpdata
    }
}

proc numgrp {number} { switch -glob -- "$number" { *11 {return 3} *12 {return 3} *13 {return 3} *14 {return 3} *1 {return 1} *2 {return 2} *3 {return 2} *4 {return 2} default {return 3} } }

# Процедура вывода длинных строк и разбиения их по определенным символам.
proc uhelp_largetext {target text {lineLen 400} {delims {-.!,}}} {
     global uhelp
     regsub -all {\{} $text "" text
     regsub -all {\}} $text "" text
     if {[string length $text] <= $lineLen} { 
         putserv "PRIVMSG $target :$uhelp(color1)$text"
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
putserv "PRIVMSG $target :$uhelp(color1)[string range $text 0 [expr $x - 1]]"
uhelp_largetext $target [string trimleft [string range $text $x end]] $lineLen $delims
}

    # Процедура инициализации антифлуда.
    proc flood_init {} {
    variable flood_array
    global uhelp
      if {$uhelp(ignore) < 1} {
        return 0
      }
      if {![string match *:* $uhelp(flood)]} {
        putlog "$uhelp(version): variable flood not set correctly."
        return 1
      }
      set uhelp(flood_num) [lindex [split $uhelp(flood) :] 0]
      set uhelp(flood_time) [lindex [split $uhelp(flood) :] 1]
      set i [expr $uhelp(flood_num) - 1]
      while {$i >= 0} {
        set flood_array($i) 0
        incr i -1
      }
    }
    ; flood_init

    # Процедура обновляет и возвращает флудстатус юзеров.
    proc flood_uhelp {nick uhost} {
    variable flood_array
    global uhelp
     if {$uhelp(ignore) < 1} {
        return 0
      }
      if {$uhelp(flood_num) == 0} {
        return 0
      }
      set i [expr $uhelp(flood_num) - 1]
      while {$i >= 1} {
        set flood_array($i) $flood_array([expr $i - 1])
        incr i -1
      }
      set flood_array(0) [unixtime]
      set aaa [expr $uhelp(flood_num) - 1]
      set bbb [expr [unixtime] - $flood_array($aaa)]
      if {$bbb <= $uhelp(flood_time) } {
        putlog "$uhelp(version): flood detected from ${nick}."
        newignore [join [maskhost *!*[string trimleft $uhost ~]]] $uhelp(version) flooding $uhelp(ignore)
        catch {unset uhelp($uhost)}
        return 1
      } else {
        return 0
      }
    }

# Выводим сообщение о том, что скрипт удачно загружен.
putlog "\[uhelp\] $uhelp(version) by $uhelp(author) loaded"
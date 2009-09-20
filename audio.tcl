###
#
#  Название: audio.tcl
#  Версия: 1.2
#  Автор: username 
#
###
#
# Описание: Скрипт собирает с сайта http://www.telephone.ru характеристики audio плееров.
#
###
#
# Установка: 
#         1. Скопируйте скрипт audio.tcl в папку scripts/audio вашего бота.
#         2. В файле eggdrop.conf впишите строку source scripts/audio/audio.tcl 
#         4. Сделайте .rehash боту.
#
###
#
# Версион хистори:
#
#              1.0(29.03.2007) Первая паблик версия.
#              1.1(08.06.2007) + Исправлены регэкспы для работы с новым хтмл кодом на сайте.
#              1.2(23.08.2008) + Исправлены регэкспы для работы с новым хтмл кодом на сайте.
#                              + Показ цены девайсов.
#                              + Поддержка Suzi патча.
#               
###

# Указываем пространство имен.
namespace eval audio {}

# Сбрасываем значения всех переменных.
foreach p [array names audio *] { catch {unset audio($p) } }

# Указываем канальный флаг(.chanset #chan +nopubaudio для отключения скрипта).
setudef flag nopubaudio

###                            ###
# Меню настроек ниже этой линии: #
# ______________________________ #
###                            ###

# Префикс команд.
set audio(pref) "!"

# Список команд на которые будет отзываться скрипт.
set audio(binds) "audio mp3 мп3 плеер"

# Разрешить работу со скриптом в привате у бота? (да-1/нет-0)
set audio(msg) 1

# Сколько команда за сколько секунд считать флудом и начинать игнорить юзера.
set audio(flood) 5:60

# Время(мин) игнора.
set audio(ignore) 10

###
# Настройки цветов.

# Основной цвет текста.
set audio(color1) "\00314"

# Цвет марок, моделей и характеристик телефонов.
set audio(color2) "\00303"

# Цвет разделителя между марками и моделями в списке.
set audio(color3) "\00304"

# Цвет заголовков разделов характеристик.
set audio(color4) "\00305"
###

###                                                                  ###
# Ниже этой линии начинается код, не изменяйте его если не знаете TCL: #
# ____________________________________________________________________ #
###                                                                  ###

#версия скрипта.
set audio(version) "audio.tcl version 1.2"

# втор скрипта.
set audio(author) "username"

# Обработка биндов.
foreach bind [split $audio(binds) " "] {
bind pub -|- "$audio(pref)$bind" audio_pub
if {$audio(msg) >= 1} {
bind msg -|- "$audio(pref)$bind" audio_msg
  }
}

# Процедура обработки приватных команд.
proc audio_msg {nick uhost hand text} {
global tcl_platform audio
audio_proc $nick $uhost $hand $nick $text
}

# Процедура обработки паблик команд.
proc audio_pub {nick uhost hand chan text} {
global tcl_platform audio

if {[channel get $chan nopubaudio]} { 
return 
}

audio_proc $nick $uhost $hand $chan $text
}

# Процедура обработки запроса.
proc audio_proc {nick uhost hand chan text} {
global tcl_platform audio sp_version

set audiomark [lindex $text 0]

# Проверка на флуд.
if {[flood_audio $nick $uhost]} {
return
}

# Если марку телефона не указали.
if {$audiomark == "" } {

set agent "Mozilla"
set audio(agent) [::http::config -useragent $agent]
set audio(url) [::http::geturl http://telephone.ru/audio/mp3.html]
set html [::http::data $audio(url)]
::http::cleanup $audio(url)

if {[info exists sp_version]} {	
    set html [encoding convertto cp1251 $html]
}

set file [open "scripts/audio/audio.txt" "w"]
  foreach line [split $html "\n"] {
      if {[regexp -- {<td><a href="/audio/mp3_g__g_1_tree_(.*?).html" class="ta12blue">(.*?)</a></td>} $line - nomer audiomark]} {
        regsub -all " " $audiomark "-" audiomark
        if {[string length $nomer] <= "5" } {
        set data "$audiomark|$nomer"
        puts $file $data
        }
      }
  }
close $file
set data [read [set file [open "scripts/audio/audio.txt" r]]]
close $file
  foreach line $data {
  set line [split $line "|"]
  lappend marklist "$audio(color2)[lindex $line 0]"
  }
set marklist [join $marklist " $audio(color3)• "]
putserv "NOTICE $nick :$audio(color1)Доступна информация по $audio(color2)MP3 Плеерам $audio(color1)следующих марок:"
audio_largetext $nick $marklist
putserv "NOTICE $nick :$audio(color1)Для получения списка моделей используйте $audio(color3)!audio $audio(color2)Марка_плеера"
return
  }

  # Если марку плеера указали.
  set audio(total) [string length $text]
  set audiomodel [string range $text [expr [string length [lindex $text 0]] + 1] [expr $audio(total) - 3]]

  # Если не указали модель плеера.
  if {$audiomodel == "" } {
  set data [read [set file [open "scripts/audio/audio.txt" r]]]
  close $file
  foreach lines $data {
  set line [split $lines "|"]
    if {[string tolower [lindex $line 0]] == [string tolower [lindex $text 0]]} {
      set nomer [lindex $line 1]
    }
  }

  set agent "Mozilla"
  set audio(agent) [::http::config -useragent $agent]
  set audio(url) [::http::geturl http://telephone.ru/audio/mp3_page_all_g__g_1_tree_$nomer\.html]
  set html [::http::data $audio(url)]
  ::http::cleanup $audio(url)

if {[info exists sp_version]} {	
    set html [encoding convertto cp1251 $html]
}

  set re "<a\\ href=\\\"/audio/mp3_page_all_g__g_1_tree_$nomer\\_id_(.*?).html\\\"\\ class=\\\"ta12blue\\\">(.*?)</a>"  
  set file [open "scripts/audio/$nomer.txt" w]
  foreach line [split $html "\n"] {
        if {[regexp -- $re $line - nomerr modell]} {
          regsub -all "\"" $modell "" modell
          regsub -all " " $modell "" modell
          set data "$modell|$nomerr"
          puts $file $data
        }
    }
  close $file
  
  set data [read [set file [open "scripts/audio/$nomer.txt" r]]]
  close $file
    foreach line [split $data \n] {
      set line [split $line "|"]
        if {$line==""} { continue }
      lappend modellist "$audio(color2)[lindex $line 0]"
    }
  set modellist [join $modellist " $audio(color3)• "]
  putserv "NOTICE $nick :$audio(color1)Доступна информация по следующим моделям MP3 Плееров марки $audio(color2)$audiomark$audio(color1):"
  audio_largetext $nick $modellist
  putserv "NOTICE $nick :$audio(color1)Для получения информации используйте: $audio(color3)!audio $audio(color2)Марка_плеера $audio(color4)Выбранная_модель $audio(color2)-Ключ"
  putserv "NOTICE $nick :$audio(color2)Ключи: $audio(color3)a$audio(color1) - Основные характеристики, $audio(color3)b$audio(color1) - Хранение и воспроизведение файлов, $audio(color3)c$audio(color1) - Корпус, $audio(color3)d$audio(color1) - Дисплей и индикация, $audio(color3)e$audio(color1) - Наушники, $audio(color3)f$audio(color1) - Звуковые параметры, $audio(color3)g$audio(color1) - Параметры записи и диктофона, $audio(color3)h$audio(color1) - Радио, $audio(color3)i$audio(color1) - Разъемы и подключение к ПК, $audio(color3)k$audio(color1) - Дополнительные функции."
  return
  } else {
      
      # Если указали модель плеера.
      if {[string index $text [expr $audio(total) - 2]] == "-" && [string index $text [expr $audio(total) - 3]] == " "} {
      #set audiomodel [string range $text [expr [string length [lindex $text 0]] + 1] [expr $audio(total) - 3]]
      set text [split $text " "]
      set audiomodel [lindex $text 1]
      set audiokey [string range $text [expr $audio(total) - 2] end]
      } else {
  putserv "NOTICE $nick :$audio(color1)Для получения информации используйте: $audio(color3)!audio $audio(color2)Марка_плеера $audio(color4)Выбранная_модель $audio(color2)-Ключ"
  putserv "NOTICE $nick :$audio(color2)Ключи: $audio(color3)a$audio(color1) - Основные характеристики, $audio(color3)b$audio(color1) - Хранение и воспроизведение файлов, $audio(color3)c$audio(color1) - Корпус, $audio(color3)d$audio(color1) - Дисплей и индикация, $audio(color3)e$audio(color1) - Наушники, $audio(color3)f$audio(color1) - Звуковые параметры, $audio(color3)g$audio(color1) - Параметры записи и диктофона, $audio(color3)h$audio(color1) - Радио, $audio(color3)i$audio(color1) - Разъемы и подключение к ПК, $audio(color3)k$audio(color1) - Дополнительные функции."
  return 
     }
    }
  ###
  set data [read [set file [open "scripts/audio/audio.txt" r]]]
  close $file
  foreach lines $data {
  set line [split $lines "|"]
    if {[string tolower [lindex $line 0]] == [string tolower [lindex $text 0]]} {
      set nomer [lindex $line 1]
    }
  }
###
set audiokey [string range $text [expr $audio(total) - 2] end]
set result [read [set file [open "scripts/audio/$nomer.txt" r]]]
close $file
  foreach pos [split $result \n] {
  set line [split $pos "|"]
      set a $audiomodel
      set b [lindex $line 0]
      if {[string compare $a $b]} {
      set nomerrr [string tolower [lindex $line 1]]
      audioparce $nick $chan $nomer $nomerrr $audiokey $audiomark $audiomodel
      return
      }
   }
}

# Процедура парсинга информации.
proc audioparce {nick chan nomer nomerrr audiokey audiomark audiomodel} {
global audio sp_version
set agent "Mozilla"
set audio(agent) [::http::config -useragent $agent]
set audio(url) [::http::geturl http://telephone.ru/audio/mp3_g__g_1_tree_$nomer\_$nomerrr\.html]
set html [::http::data $audio(url)]
::http::cleanup $audio(url)

if {[info exists sp_version]} {	
    set html [encoding convertto cp1251 $html]
}

    set filee [open "scripts/audio/debug.txt" w]
    set data [split $html \n]
    regsub -all "	" $data "" data
    regsub -all -- {\n} $data "" data
    regsub -all -- {\ +} $data { } data
    regsub -all -- {^\ +} $data "" data
    regsub -all -- {> +<} $data {><} data
    regsub -all -- {</([^<]+)> +<} $data {</\1><} data
    regsub -all -- {<!--[^-]*-[^-]*-[^>]*>} $data "" data
    regsub -all -- {\n+} $data "\n" data
    regsub -all -- {\n$} $data "" data
    regsub -all -- {&nbsp;} $data " " data
    set data [encoding convertfrom [encoding system] $data]
    puts $filee $data
    close $filee

set html [read [set file [open "scripts/audio/debug.txt" r]]]
close $file

    if {[regexp -- {<span>(.*?)р.</span>} $html - p]} {
      set elem "$audio(color1)Цена: $audio(color2)\002$p\002 $audio(color1)рублей."
      lappend list $elem
    }

if {$audiokey == "-a"} {
putserv "NOTICE $nick :$audio(color1)audio Плеер $audio(color2)$audiomark $audiomodel $audio(color4)— Основные характеристики:"
    if {[regexp -- {Размеры:</span>.*?<b>(.*?)</b></td>} $html - p]} {
      set elem "$audio(color1)Размеры: $audio(color2)$p"
      lappend list $elem
    }
    if {[regexp -- {Вес:</span>.*?<b>(.*?)</b></td>} $html - p]} {
      set elem "$audio(color1)Вес: $audio(color2)$p"
      lappend list $elem
    }
    if {[regexp -- {Аккумуляторная батарея:</span>.*?<b>(.*?)</b></td>} $html - p]} {
      set elem "$audio(color1)Аккумуляторная батарея: $audio(color2)$p"
      lappend list $elem
    }
    if {[regexp -- {Время работы от батареи:</span>.*?<b>(.*?)</b></td>} $html - p]} {
      set elem "$audio(color1)Время работы от батареи: $audio(color2)$p"
      lappend list $elem
    }
    if {[regexp -- {Способы подзарядки батареи:</span>.*?<b>(.*?)</b></td>} $html - p]} {
      set elem "$audio(color1)Способы подзарядки батареи: $audio(color2)$p"
      lappend list $elem
    }
    if {[regexp -- {Основные языки меню:</span>.*?<b>(.*?)</b></td>} $html - p]} {
      set elem "$audio(color1)Основные языки меню: $audio(color2)$p"
      lappend list $elem
    }
    if {[regexp -- {Комплектация:</span>.*?<b>(.*?)</b></td>} $html - p]} {
      set elem "$audio(color1)Комплектация: $audio(color2)$p"
      lappend list $elem
    }
    if {[regexp -- {Русскоязычная инструкция:</span>.*?<b>(.*?) </b></td>} $html - p]} {
      set elem "$audio(color1)Русскоязычная инструкция: $audio(color2)$p"
      lappend list $elem
    }
set list [join $list " $audio(color3)• "]
regsub -all "  " $list " " list
audio_largetext $nick $list
}

if {$audiokey == "-b"} {
putserv "NOTICE $nick :$audio(color1)audio Плеер $audio(color2)$audiomark $audiomodel $audio(color4)— Хранение и воспроизведение файлов:"
    if {[regexp -- {Тип носителя:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Тип носителя: $audio(color2)$p"
    lappend list1 $elem
    }
    if {[regexp -- {Поддерживаемые карты памяти:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Поддерживаемые карты памяти: $audio(color2)$p"
    lappend list1 $elem
    }
    if {[regexp -- {Объем встроенной памяти или носителя:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Объем встроенной памяти или носителя: $audio(color2)$p"
    lappend list1 $elem
    }
    if {[regexp -- {Форматы аудио файлов:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Форматы аудио файлов: $audio(color2)$p"
    lappend list1 $elem
    }
    if {[regexp -- {Форматы видео файлов:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Форматы видео файлов: $audio(color2)$p"
    lappend list1 $elem
    }
    if {[regexp -- {Форматы графических файлов:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Форматы графических файлов: $audio(color2)$p"
    lappend list1 $elem
    }
    if {[regexp -- {Поддержка прочих форматов:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Поддержка прочих форматов: $audio(color2)$p"
    lappend list1 $elem
    }
    if {[regexp -- {Поддерживаемые теги:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Поддерживаемые теги: $audio(color2)$p"
    lappend list1 $elem
    }
    if {[regexp -- {Отображение тегов на русском:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Отображение тегов на русском: $audio(color2)$p"
    lappend list1 $elem
    }
    if {[regexp -- {Поддержка плей-листов:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Поддержка плей-листов: $audio(color2)$p"
    lappend list1 $elem
    }
set list1 [join $list1 " $audio(color3)• "]
regsub -all "  " $list1 " " list1
audio_largetext $nick $list1 
}

if {$audiokey == "-c"} {
putserv "NOTICE $nick :$audio(color1)audio Плеер $audio(color2)$audiomark $audiomodel $audio(color4)— Корпус:"
    if {[regexp -- {Варианты расцветок корпуса:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Варианты расцветок корпуса: $audio(color2)$p"
    lappend list2 $elem
    }
    if {[regexp -- {Материал корпуса:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Материал корпуса: $audio(color2)$p"
    lappend list2 $elem
    }
    if {[regexp -- {Дополнительная защита:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Дополнительная защита: $audio(color2)$p"
    lappend list2 $elem
    }
    if {[regexp -- {Изменяемый внешний вид:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Изменяемый внешний вид: $audio(color2)$p"
    lappend list2 $elem
    }
    if {[regexp -- {Держатель для ремешка:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Держатель для ремешка: $audio(color2)$p"
    lappend list2 $elem
    }
    if {[regexp -- {Крепление при помощи клипсы:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Крепление при помощи клипсы: $audio(color2)$p"
    lappend list2 $elem
    }
set list2 [join $list2 " $audio(color3)• "]
regsub -all "  " $list2 " " list2
audio_largetext $nick $list2 
}

if {$audiokey == "-d"} {   
putserv "NOTICE $nick :$audio(color1)audio Плеер $audio(color2)$audiomark $audiomodel $audio(color4)— Дисплей и индикация:"
    if {[regexp -- {Тип дисплея:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Тип дисплея: $audio(color2)$p"
    lappend list3 $elem
    }
    if {[regexp -- {Технология производства:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Технология производства: $audio(color2)$p"
    lappend list3 $elem
    }
    if {[regexp -- {Количество цветов:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Количество цветов: $audio(color2)$p"
    lappend list3 $elem
    }
    if {[regexp -- {Разрешение дисплея:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Разрешение дисплея: $audio(color2)$p"
    lappend list3 $elem
    }
    if {[regexp -- {Физические размеры:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Физические размеры: $audio(color2)$p"
    lappend list3 $elem
    }
    if {[regexp -- {Подсветка дисплея:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Подсветка дисплея: $audio(color2)$p"
    lappend list3 $elem
    }
set list3 [join $list3 " $audio(color3)• "]
regsub -all "  " $list3 " " list3
audio_largetext $nick $list3 
}

if {$audiokey == "-e"} {
putserv "NOTICE $nick :$audio(color1)audio Плеер $audio(color2)$audiomark $audiomodel $audio(color4)— Наушники:"
    if {[regexp -- {Тип наушников в комплекте:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Тип наушников в комплекте: $audio(color2)$p"
    lappend list4 $elem
    }
    if {[regexp -- {Модель наушников в комплекте:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Модель наушников в комплекте: $audio(color2)$p"
    lappend list4 $elem
    }
    if {[regexp -- {Разъем для наушников:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Разъем для наушников: $audio(color2)$p"
    lappend list4 $elem
    }
    if {[regexp -- {Подключение наушников:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Подключение наушников: $audio(color2)$p"
    lappend list4 $elem
    }
    if {[regexp -- {Частотный диапазон:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Частотный диапазон: $audio(color2)$p"
    lappend list4 $elem
    }
set list4 [join $list4 " $audio(color3)• "]
regsub -all "  " $list4 " " list4
audio_largetext $nick $list4 
}

if {$audiokey == "-f"} {
putserv "NOTICE $nick :$audio(color1)audio Плеер $audio(color2)$audiomark $audiomodel $audio(color4)— Звуковые параметры:"
    if {[regexp -- {Предустановленные режимы эквалайзера:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Предустановленные режимы эквалайзера: $audio(color2)$p"
    lappend list5 $elem
    }
    if {[regexp -- {Режимы воспроизведения:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Режимы воспроизведения: $audio(color2)$p"
    lappend list5 $elem
    }
set list5 [join $list5 " $audio(color3)• "]
regsub -all "  " $list5 " " list5
audio_largetext $nick $list5 
}

if {$audiokey == "-g"} {    
    if {[regexp -- {Функции диктофона:</span>.*?<b>(.*?)</b></td>} $html - p]} {
putserv "NOTICE $nick :$audio(color1)audio Плеер $audio(color2)$audiomark $audiomodel $audio(color4)— Параметры записи и диктофона:"
    set elem "$audio(color1)Функции диктофона: $audio(color2)$p"
    lappend list6 $elem
    } else {
putserv "NOTICE $nick :$audio(color1)audio Плеер $audio(color2)$audiomark $audiomodel $audio(color4)— Возможность записи и диктофон в данной модели отсутствуют."
    }
    if {[regexp -- {Максимальное время записи:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Максимальное время записи: $audio(color2)$p"
    lappend list6 $elem
    }
    if {[regexp -- {Формат записи аудио файлов:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Формат записи аудио файлов: $audio(color2)$p"
    lappend list6 $elem
    }
    if {[regexp -- {Микрофон:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Микрофон: $audio(color2)$p"
    lappend list6 $elem
    }
    if {[regexp -- {Максимальная дистанция записи:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Максимальная дистанция записи: $audio(color2)$p"
    lappend list6 $elem
    }
    if {[regexp -- {Запись с радио:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Запись с радио: $audio(color2)$p"
    lappend list6 $elem
    }
    if {[regexp -- {Запись с линейного входа:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Запись с линейного входа: $audio(color2)$p"
    lappend list6 $elem
set list6 [join $list6 " $audio(color3)• "]
regsub -all "  " $list6 " " list6
audio_largetext $nick $list6 

    }
}

if {$audiokey == "-h"} {
putserv "NOTICE $nick :$audio(color1)audio Плеер $audio(color2)$audiomark $audiomodel $audio(color4)— Радио:"
    if {[regexp -- {Встроенный тюнер:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Встроенный тюнер: $audio(color2)$p"
    lappend list7 $elem
    }
    if {[regexp -- {Память радиостанций:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Память радиостанций: $audio(color2)$p"
    lappend list7 $elem
    }
    if {[regexp -- {Поддержка RDS:</span></a>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Поддержка RDS: $audio(color2)$p"
    lappend list7 $elem
    }
set list7 [join $list7 " $audio(color3)• "]
regsub -all "  " $list7 " " list7
audio_largetext $nick $list7 
}

if {$audiokey == "-i"} {
putserv "NOTICE $nick :$audio(color1)audio Плеер $audio(color2)$audiomark $audiomodel $audio(color4)— Разъемы и подключение к ПК:"
    if {[regexp -- {Линейный вход:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Линейный вход: $audio(color2)$p"
    lappend list8 $elem
    }
    if {[regexp -- {Линейный выход:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Линейный выход: $audio(color2)$p"
    lappend list8 $elem
    }
    if {[regexp -- {Подключение к ПК:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Подключение к ПК: $audio(color2)$p"
    lappend list8 $elem
    }
    if {[regexp -- {Режим съемного диска:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Режим съемного диска: $audio(color2)$p"
    lappend list8 $elem
    }
    if {[regexp -- {Функции USB-storage:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Функции USB-storage: $audio(color2)$p"
    lappend list8 $elem
    }
    if {[regexp -- {Самостоятельное обновление прошивки:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Самостоятельное обновление прошивки: $audio(color2)$p"
    lappend list8 $elem
    }
set list8 [join $list8 " $audio(color3)• "]
regsub -all "  " $list8 " " list8
audio_largetext $nick $list8 
}

if {$audiokey == "-k"} {
putserv "NOTICE $nick :$audio(color1)audio Плеер $audio(color2)$audiomark $audiomodel $audio(color4)— Дополнительные функции:"
    if {[regexp -- {Встроенный динамик:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Встроенный динамик: $audio(color2)$p"
    lappend list9 $elem
    }
    if {[regexp -- {Часы:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Часы: $audio(color2)$p"
    lappend list9 $elem
    }
    if {[regexp -- {Будильник:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Будильник: $audio(color2)$p"
    lappend list9 $elem
    }
    if {[regexp -- {Календарь:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Календарь: $audio(color2)$p"
    lappend list9 $elem
    }
    if {[regexp -- {Записная книжка:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Записная книжка: $audio(color2)$p"
    lappend list9 $elem
    }
    if {[regexp -- {Таймер отключения:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Таймер отключения: $audio(color2)$p"
    lappend list9 $elem
    }
    if {[regexp -- {Пульт ДУ:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)Пульт ДУ: $audio(color2)$p"
    lappend list9 $elem
    }
set list9 [join $list9 " $audio(color3)• "]
regsub -all "  " $list9 " " list9
audio_largetext $nick $list9 
}
}

# Процедура вывода длинных строк и разбиения их по определенным символам.
proc audio_largetext {target text {lineLen 400} {delims {•.!?}}} {
     global audio
     regsub -all {\{} $text "" text
     regsub -all {\}} $text "" text
     if {[string length $text] <= $lineLen} { 
     putserv "NOTICE $target :$text"
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
putserv "NOTICE $target :[string range $text 0 [expr $x - 1]]"
audio_largetext $target [string trimleft [string range $text $x end]] $lineLen $delims
}

    # Процедура инициализации антифлуда.
    proc flood_init {} {
    variable flood_array
    global audio
      if {$audio(ignore) < 1} {
        return 0
      }
      if {![string match *:* $audio(flood)]} {
        putlog "$audio(version): variable flood not set correctly."
        return 1
      }
      set audio(flood_num) [lindex [split $audio(flood) :] 0]
      set audio(flood_time) [lindex [split $audio(flood) :] 1]
      set i [expr $audio(flood_num) - 1]
      while {$i >= 0} {
        set flood_array($i) 0
        incr i -1
      }
    }
    ; flood_init

    # Процедура обновляет и возвращает флудстатус юзеров.
    proc flood_audio {nick uhost} {
    variable flood_array
    global audio
     if {$audio(ignore) < 1} {
        return 0
      }
      if {$audio(flood_num) == 0} {
        return 0
      }
      set i [expr $audio(flood_num) - 1]
      while {$i >= 1} {
        set flood_array($i) $flood_array([expr $i - 1])
        incr i -1
      }
      set flood_array(0) [unixtime]
      set aaa [expr $audio(flood_num) - 1]
      set bbb [expr [unixtime] - $flood_array($aaa)]
      if {$bbb <= $audio(flood_time) } {
        putlog "$audio(version): flood detected from ${nick}."
        newignore [join [maskhost *!*[string trimleft $uhost ~]]] $audio(version) flooding $audio(ignore)
        catch {unset audio($uhost)}
        return 1
      } else {
        return 0
      }
    }

# Выводим сообщение о том, что скрипт удачно загружен.
putlog "\[audio\] $audio(version) by $audio(author) loaded"
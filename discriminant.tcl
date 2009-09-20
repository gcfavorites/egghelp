###
#
#  Название: discriminant.tcl
#  Версия: 1.0
#  Автор: username 
#  Идея: CappY :) @ http://forums.egghelp-bg.com
#
###
#
# Описание: Скрипт решает квадратные уравнения.
#
###
#
# Установка: 
#         1. Скопируйте скрипт discriminant.tcl в папку scripts вашего бота.
#         2. В файле eggdrop.conf впишите строку source scripts/discriminant.tcl 
#         3. Сделайте .rehash боту.
#
###
#
# Версион хистори:
#
#              1.0(23.03.2008) Первая версия.
#
###

# Указываем пространство имен.
namespace eval discriminant {

# Указываем канальный флаг(.chanset #chan +nopubdiscriminant для отключения скрипта).
setudef flag nopubdiscriminant

###                            ###
# Меню настроек ниже этой линии: #
# ______________________________ #
###                            ###

# Префикс команд.
variable pref "!"

# Список команд на которые будет отзываться скрипт.
variable binds "дискр discriminant"

# Разрешить работу со скриптом в привате у бота? (да-1/нет-0)
variable msg 1

###
# Настройки цветов.

# Цвет текста.
variable color1 "\00314"

# Цвет дискриминанта и результата разложения на множители.
variable color2 "\00303"

# Цвет корней уравнения.
variable color3 "\00312"
###

###                                                                  ###
# Ниже этой линии начинается код, не изменяйте его если не знаете TCL: #
# ____________________________________________________________________ #
###                                                                  ###

# Версия скрипта.
variable version "discriminant.tcl version 1.0"

# Автор скрипта.
variable author "username"

# Обработка биндов.
foreach bind [split $binds " "] {
bind pub -|- "$pref$bind" ::discriminant::pubproc
if {$msg >= 1} {
bind msg -|- "$pref$bind" ::discriminant::msgproc
  }
}

# Процедура обработки приватных команд.
proc msgproc {nick uhost hand text} {
variable discriminant
::discriminant::mainproc $nick $uhost $hand $nick $text
}

# Процедура обработки паблик команд.
proc pubproc {nick uhost hand chan text} {
variable udefflag

# Проверяем наличие флага.
if {[channel get $chan $udefflag]} { 
return 
}
::discriminant::mainproc $nick $uhost $hand $chan $text
}

# Процедура обработки запроса.
proc mainproc {nick uhost hand chan text} {
variable color1
variable color2
variable color3

if {[regexp -nocase -- {(.*?)xx(.*?)x(.*?)=0} $text garb a b c]} {
set d [expr $b*$b-4*$a*$c]
if {$d<0} {
putserv "PRIVMSG $chan :$color2\002D=$d\002$color1. Дискриминант < 0, следовательно, уравнение не имеет действительных корней."
return
}
set x1 [expr (-$b + sqrt($d)) / (2*$a)]
set x2 [expr (-$b - sqrt($d)) / (2*$a)]
set vid "$a\(x-$x1\)\(x-$x2\)"
set vid [string map {"--" "+" "-+" "-"} $vid]
set msg "$color2\002D=$d\002$color1\."
if {$d==0} {
lappend msg "Дискриминант = 0, следовательно, уравнение имеет единственный корень. $color3\002X=$x1\002"
lappend msg "$color1\При разложении на множители квадратный трехчлен примет вид: $color2\002$vid"
} elseif {$d>0} {
lappend msg "Дискриминант > 0, следовательно, уравнение имеет два действительных корня. $color3\002X1=$x1\002 и \002X2=$x2\002"
lappend msg "$color1\При разложении на множители квадратный трехчлен примет вид: $color2\002$vid"
}
putserv "PRIVMSG $chan :[join $msg]"
return
} else { 
putserv "PRIVMSG $chan :$color1\Введенное Вами уравнение не является квадратным или форма записи не верна. Верная форма записи: $color2\002axx+/-bx+/-c=0\002$color1\, где a, b и c - заданные числа."
return
}
}

# Выводим сообщение о том, что скрипт удачно загружен.
putlog "\[discriminant\] $version by $author loaded"

}
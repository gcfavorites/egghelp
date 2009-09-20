###
#
#  Название: irpglogin.tcl
#  Версия: 1.1
#  Автор: username 
#
###
#
# Описание: Скрипт позволяет вашему боту регистрироваться и участвовать в idleRPG,
# вы можете изменять характер персонажа вашего бота через приватные команды
# которые вы сами указываете в меню настройки скрипта.   
#   Процедура автоматической авторизации работает таким образом, что если на игровой
# канал заходит либо ваш бот, либо бот который ведет игру, то последнему будет отсылаться
# необходимая команда. Чтобы отключить автоматическую авторизацию используйте канальный
# флаг nopubirpg.
#   Все команды работают только в привате бота.  
#
###
#
# Установка: 
#   1. Скопируйте скрипт irpglogin.tcl в папку scripts вашего бота 
#   2. В файле eggdrop.conf впишите строку source scripts/irpglogin.tcl 
#   3. Сделайте .rehash боту
#
###
#
# Версион хистори:
#  1.1(22.11.2006) 
#  + раздел настроек скрипта
#  + комментарии и путлоги
#  + флаг для отключения скрипта nopubirpg
#  + процедура автоматической авторизации при входе на канал 
#  + возможность установки характера персонажа
#
#  1.0(02.11.2006)
#    первая версия без каких либо настроек и пояснений 
#
###

#указываем пространство имен
namespace eval irpg {}
catch {unset irpg}
foreach p [array names irpg *] { catch {unset irpg($p) } }

#указываем канальный флаг(.chanset #chan +nopubirpg для отключения автоматической авторизации)
setudef flag nopubirpg

###                            ###
# Меню настроек ниже этой линии: #
# ______________________________ #
###                            ###

#канал на котором проход игра
set irpg(chan) "#idlerpg"

#ник бота ведущего игру
set irpg(nick) "idlerpg"

#имя аккаунта вашего бота(не более 16 символов)
set irpg(acct) "Robotronic"

#пароль вашего персонажа(не более 8 символов)
set irpg(pass) "accpass"

#класс вашего персонажа(не более 30 символов)
set irpg(char) "Eggdrop 1.6.18"

#команда для регистрации вашего персонажа
set irpg(regcmd) !irpgreg 

#команда для "ручной" авторизации у игрового бота
set irpg(logcmd) "!irpglogin"

#команда изменения характера на GOOD
set irpg(galigncmd) "!galign"

#команда изменения характера на NEUTRAL
set irpg(naligncmd) "!nalign"

#команда изменения характера на EVIL
set irpg(ealigncmd) "!ealign"

###                                                                  ###
# Ниже этой линии начинается код, не изменяйте его если не знаете TCL: #
# ____________________________________________________________________ #
###                                                                  ###

#версия скрипта
set irpg(version) "irpg.tcl version 1.1"

#автор скрипта
set irpg(author) "username"

#процедура автоматической авторизации
bind join - "$irpg(chan) *" irpg:login
proc irpg:login {nick uhost hand chan} {
  global botnick irpg
  if {[channel get $chan nopubirpg]} {return}
  if {($nick == "$botnick") || ($nick == "$irpg(nick)")} {
    putserv "PRIVMSG $irpg(nick) :login $irpg(acct) $irpg(pass)"
    putlog "IRPG Auto Login Initiated.. Request is Being Processed."
  }
}

#процедура "ручной" авторизации
bind msg n $irpg(logcmd) irpg:manual:login
proc irpg:manual:login {nick uhost hand arg} {
 global botnick irpg
 putserv "NOTICE $nick :Login Request sent to $irpg(nick)" 
 putserv "PRIVMSG $irpg(nick) :login $irpg(acct) $irpg(pass)"
}

#процедура регистрации персонажа
bind msg n $irpg(regcmd) irpg:reg
proc irpg:reg {nick uhost hand arg} {
 global botnick irpg
 putserv "NOTICE $nick :Register Request sent to $irpg(nick)" 
 putserv "PRIVMSG $irpg(nick) :register $irpg(acct) $irpg(pass) $irpg(char)"
}

#процедур изменения характера на GOOD
bind msg n $irpg(galigncmd) align:good
proc align:good {nick uhost hand arg} {
 global botnick irpg
 putserv "NOTICE $nick :Align Request GOOD sent to $irpg(nick)" 
 putserv "PRIVMSG $irpg(nick) :align good"
}

#процедура изменения характера на NEUTRAL
bind msg n $irpg(naligncmd) align:neutral
proc align:neutral {nick uhost hand arg} {
 global botnick irpg
 putserv "NOTICE $nick :Align Request NEUTRAL sent to $irpg(nick)" 
 putserv "PRIVMSG $irpg(nick) :align neutral"
}

#процедура изменения характера на EVIL
bind msg n $irpg(ealigncmd) align:evil
proc align:evil {nick uhost hand arg} {
 global botnick irpg
 putserv "NOTICE $nick :Align Request EVIL sent to $irpg(nick)" 
 putserv "PRIVMSG $irpg(nick) :align evil"
}

#выводим сообщение о том, что скрипт удачно загружен
putlog "\[irpglogin\] $irpg(version) by $irpg(author) loaded"

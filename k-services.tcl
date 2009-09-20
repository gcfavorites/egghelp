###############################
# k-services.tcl LITE version #
####################################
# Current version: 1.2             #
# Author: Kein (kein-of@yandex.ru) #
#######################################
# Description:                        #
# -> скрипт предназначен для самых    #
#    минимальных нужд бота, а именно: #
#    идентификация на сервисах и      #
#    получение и применение ключа     #
#    канала на сервисах, которые      #
#    поддерживают функцию возвращения #
#    активного ключа канала           #
###############################################
# Рекомендации:                               #
# 1. Что бы работала процедура обработки      #
#    ключа, настоятельно рекомендуется        #
#    изменить язык сервисов на английский,    #
#    а так же, значение need-key установить в #
#    putserv "PRIVMSG ChanServ :getkey #chan" #
# 2. Изменить язык сервисов на английский для #
#    бота рекомендуется в принципе :P         #
###############################################
# Следующий апдейт:                           #
# -> Пароленезависимый ghost'инг, проверка на #
#    то, является ли ghost'уемый овнером      #
###############################################

# Namespace evaluation
namespace eval kservices {}

# Reset of variables
foreach k [array names kservices *] { catch {unset kservices($k) } }

# Settings (настройки #

# Автор, версия
set kservices(author) "Kein"
set kservices(version) "1.2"
set kservices(amail) "kein-of@yandex.ru"

# Сервер сервисов
## Описание: сервер, на котором висят сервисы.
## Обязательно должен начинаться с "@"! Узнать
## сервер можно банальным /WHOIS NickServ NickServ
## Если не знаете, просто оставьте поле пустым.
#### Для InspIRCD версии 1.1.15 и менее, оставляем
#### поле пустым!!! И вообще, для IRCD, которые
#### не поддерживают формат сообщений вида:
#### PRIVMSG nick@server значение не ставим!
set kservices(server) "@services.dalnet.ru"

# Параметры команды OP|HALFOP|VOICE
## Установите в "yes" если сервисы вашей сети
## позволяют использовать команды OP|HALFOP|VOICE
## без каких-либо параметров для получения статуса
## на всех каналах, где он (статус) прописан.
## В противном случае, ставьте значение в "no".
set kservices(opall) "yes"

# Автозапрос статуса
## Укажите, какую команду должен использовать бот
## сразу же после идентификации на сервисах.
## Валидные значения:
## -> OP - для получения статуса опа
## -> HALFOP - для получения статуса хопа
## -> VOICE - для получения статуса войса
set kservices(cscmd) "OP"

# Версия сервисов
## Структура строки с возвращаемым ключом
## канала разнится от версии и типа сервисов.
## Расскоментируйте одну из опции ниже, в
## в зависимости от версии сервисов.
## (Узнать ее можно по /version NickServ)
# ---------------------------------
# Для Anope версии 1.6.5 и ниже:
# set kservices(version) "anopeold"
# Для Anope версии 1.7.x:
set kservices(version) "anopenew"
# Для Atheme services:
#set kservices(version) "atheme"

# Пароль бота на сервисах
set kservices(nspasswd) "krutoi_pass"

# Ник и хостмаска сервисов
set kservices(nsnick) "NickServ"
set kservices(nshost) "services@services.dalnet.ru"
set kservices(csnick) "ChanServ"
set kservices(cshost) "services@services.dalnet.ru"

# Команда идентификации
set kservices(nsidcmd) "PRIVMSG $kservices(nsnick)$kservices(server) :IDENTIFY"

# Префикс для команды identify
set kservices(prefix) "!"

# Binds (бинды)
## Описание: нотисы по маске, на которые
### будет реагировать бот.

# anopenew
## english
bind notc - "*Key*for*channel*#*is*" kservices:usekey
## russian
bind notc - "*люч*для*канала*#*-*" kservices:usekey
# atheme
bind notc - "*Channel*#*key*is:*" kservices:usekey
# anopeold
bind notc - "*KEY*#*" kservices:usekey

# id-request
bind notc - "*$kservices(nsnick)*IDENTIFY*" kservices:aid

bind pub m|m ${kservices(prefix)}identify kservices:mid

# Code (Код)
## Don't change anything below this line!
## Ниже идет код. Желательно не трогать, если не
## знаем, что к чему...

# Проверка на валидность хостов и ников сервисов
## основа взята из TCS
proc kservices:vldcheck {nick host} {
global kservices
set nick [string tolower [join $nick]]
set host [string tolower [join $host]]
if {(($nick == [string tolower $kservices(nsnick)]) && ($host == [string tolower $kservices(nshost)])) || (($nick == [string tolower $kservices(csnick)]) && ($host == [string tolower $kservices(cshost)]))} { return 1 }
return 0
}

# Ручная идентификация по identify
## Проверка на идентификацию завязана на флаге +Q,
## который используется в большинстве скриптов по
## управлению каналами. Тестировалось с CCS от Buster.
proc kservices:mid {nick host hand chan text} {
global kservices
if {![matchattr $hand Q]} {
 putserv "NOTICE $nick :Вы не идентифицированы!"
 putcmdlog "::k-services.tcl:: Fake authorization request from $nick!$host on $chan * Ignoring..."
 return 0
}
putserv "$kservices(nsidcmd) $kservices(nspasswd)"
putcmdlog "::k-services.tcl:: Received authorization request from $nick!$host on $chan * Identifying..."
if {$kservices(opall) == "no"} {
 foreach c [channels] {
 putserv "PRIVMSG $kservices(csnick) :$kservices(cscmd) $c"
}
} else {
 putserv "PRIVMSG $kservices(csnick) :$kservices(cscmd)"
}
}

# Автоидентификация на сервисах
proc kservices:aid {nick host hand chan text {dest ""}} {
global botnick kservices
if {![kservices:vldcheck $nick $host]} {putcmdlog "::k-services.tcl:: Fake login request from $nick!$host * Ignoring..."; return 0}
putserv "$kservices(nsidcmd) $kservices(nspasswd)"
putcmdlog "::k-services.tcl:: Received authorization request from $host * Identifying..."
if {$kservices(opall) == "no"} {
 foreach c [channels] {
 putserv "PRIVMSG $kservices(csnick) :$kservices(cscmd) $c"
}
} else {
 putserv "PRIVMSG $kservices(csnick) :$kservices(cscmd)"
}
}

# Обработка полученного ключа
proc kservices:usekey { nick uhost hand text dest } {
global botnick kservices
# anope NEW
if {$kservices(version) == "anopenew"} {
 set jchan [lindex $text 3]
 if {![string match "#*" $jchan]} {putcmdlog "::k-services.tcl:: I've got a strange channel name... Are you sure that's is your network used an Anope version 1.7.x?"; return 0}
 set jkey [stripcodes b [lindex $text 5]]
 set jkey [string range $jkey 0 [expr [string length $jkey]-2]]
}
# anope OLD
if {$kservices(version) == "anopeold"} {
 set jchan [lindex $text 1]
 if {![string match "#*" $jchan]} {putcmdlog "::k-services.tcl:: I've got a strange channel name... Are you sure that's is your network used an Anope version 1.6.x?"; return 0}
 set jkey [lindex $text 2]
}
# Atheme
if {$kservices(version) == "atheme"} {
 set jchan [stripcodes b [lindex $text 1]]
 if {![string match "#*" $jchan]} {putcmdlog "::k-services.tcl:: I've got a strange channel name... Are you sure that's is your network used an Atheme?"; return 0}
 set jkey [lindex $text 4]
}
# проверка на валидность хостов и джойн
if {[kservices:vldcheck $nick $uhost]} {
 if {[validchan $jchan] && ![botonchan $jchan] && ![channel get $jchan inactive]} {
  putcmdlog "::k-services.tcl:: Received key $jkey from $nick!$uhost for channel $jchan * Now trying to join..."
  putserv "JOIN $jchan :$jkey"
  return
 } else {
  putcmdlog "::k-services.tcl:: Received key $jkey from $nick!$uhost for channel $jchan, but not needed yet..."
  return
 }
} else {
 putcmdlog "::k-services.tcl:: Fake key-response from $nick!$uhost"
 return 0
}
}

putlog "K-services.tcl LITE by $kservices(author) ($kservices(amail)) version $kservices(version) successfully loaded!"
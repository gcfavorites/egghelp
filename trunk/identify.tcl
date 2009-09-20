##
## Скрипт автоидентификации бота на никсерве by Dark_Agent
## сервисы: HybServ (hybrid) для сетей DalNet(RU), XNet.net.ru, для других сетей 
## работоспособность возможна, но после небольшой модификации
## email: darkagent@yandex.ru
## 

set identify(pass) "пароль от ника"
set identify(botnick) "ник бота"
set identify(command) "IDENTIFY"
set identify(service) "NickServ"
set identify(bindru) "*Этот*ник*зарегистрирован*"
set identify(binden) "*This*nickname*is*owned*by*someone*else*"

bind evnt - init-server evnt:init-server:identify
proc evnt:init-server:identify {type} {
	identify
}

if {[info exists identify(bind)]} {
	bind notc -|- $identify(bindru) notc:identify
	bind notc -|- $identify(binden) notc:identify
	proc notc:identify {nick uhost hand chan params} {
		global identify
		if {[string tolower $nick] == [string tolower $identify(service)]} {
			identify
		}
	}
}

proc identify {} {
 global identify botnick
 if {[info exists identify(botnick)]} {
  if {[string tolower $botnick] != [string tolower $identify(botnick)]} {
   return
   }
  }
 putserv "PRIVMSG $identify(service) :$identify(command) $identify(pass)"
}

proc servantiflood {} {
  if {[string match *servantiflood* [utimers]]} {
    return 0
  } else {
  utimer 15 servantiflood
  return 1
  }
}


bind need - "% op" need:op
proc need:op {chan type} {
  if { [servantiflood] == 1} { putserv "PRIVMSG ChanServ :OP all" }
}

bind need - "% unban" need:unban
proc need:unban {chan type} {
 if { [servantiflood] == 1} { putserv "PRIVMSG ChanServ :UNBAN $chan" }
}

bind need - "% invite" need:invite
proc need:invite {chan type} {
 if { [servantiflood] == 1} { putserv "PRIVMSG ChanServ :INVITE $chan" }
}

putlog "TCL Script> работа с сервисами загружена."
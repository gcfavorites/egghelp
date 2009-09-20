# clientstats.tcl v1.1 (3 January 1999) by slennox <slenny@ozemail.com.au>
# Latest versions can be found at www.ozemail.com.au/~slenny/eggdrop/
#
# Pretty useless little script that basically makes the bot gather
# information about the IRC clients people are using when you use the
# public command 'clstats', and displays the info to the channel :-)
#
# Note that this script has only been tested for eggdrop 1.3.x
#
# v1.0 - Initial release
# v1.1 - Now separates unknown clients and non-replies, added OpenChat and
# Microsoft Chat, changed putserv to puthelp, now only lets you use pub
# command if you're opped, fixed up some variables


# Don't edit below unless you know what you're doing

bind pub -|- !clstats pub_clstats

bind ctcr - VERSION gatherstat

proc pub_clstats {nick uhost hand chan arg} {
  global inuse 
  global statchan
  global scanchan
  global scanusers
  global mircuser
  global eggdropuser
  global kvircuser
  global mozillauser
  global operauser
  global bitchxuser
  global irciiuser
  global unkwnuser
  if {![isop $nick $chan]} {return 0}
  set scanchan [lindex [split $arg] 0]
  if {![string length $scanchan]} { set scanchan $chan}
  putcmdlog "clientstats: requested by $hand on $chan for $scanchan"
  if {$inuse} {
    putserv "PRIVMSG $chan :Предыдущий запрос еще не выполнен, подождите минуту и попробуйте снова!"
    return 1
  }
  set inuse 1
  set statchan $chan
  set scanusers [llength [chanlist $scanchan]]
  set mircuser 0
  set eggdropuser 0
  set kvircuser 0
  set mozillauser 0
  set operauser 0
  set bitchxuser 0
  set irciiuser 0
  set unkwnuser 0
  putserv "PRIVMSG $chan :Рассчитываю статистику использования IRC клиентов для канала $scanchan..."
  putserv "PRIVMSG $scanchan :VERSION"
  utimer 10 pub_displaystats
}

proc pub_displaystats {} {
  global inuse 
  global statchan 
  global scanchan 
  global scanusers 
  global mircuser 
  global eggdropuser 
  global kvircuser 
  global mozillauser
  global operauser
  global bitchxuser 
  global irciiuser 
  global unkwnuser

  set numusers [llength [chanlist $scanchan]]
  set replies [expr $mircuser + $eggdropuser + $kvircuser + $mozillauser + $operauser + $bitchxuser + $irciiuser + $unkwnuser]
  set otheruser [expr $numusers - $replies]
  puthelp "PRIVMSG $statchan :Статистика IRC клиентов для канала $scanchan:"
  if {$mircuser != 0} {
  puthelp "PRIVMSG $statchan :mIRC: $mircuser  "
  }
  if {$kvircuser != 0} {
  puthelp "PRIVMSG $statchan :KVIrc: $kvircuser"
  }
  if {$mozillauser != 0} {
  puthelp "PRIVMSG $statchan :ChatZilla: $mozillauser  "
  }
  if {$operauser != 0} {
  puthelp "PRIVMSG $statchan :OperaIRC: $operauser  "
  }
  if {$bitchxuser != 0} {
  puthelp "PRIVMSG $statchan :BitchX: $bitchxuser  "
  }
  if {$irciiuser != 0} {
  puthelp "PRIVMSG $statchan :ircII: $irciiuser  "
  }
  if {$eggdropuser != 0} {
  puthelp "PRIVMSG $statchan :EggDrop: $eggdropuser  "
  }
  if {$unkwnuser != 0} {
  puthelp "PRIVMSG $statchan :Неизвестные: $unkwnuser  "
  }
  if {$otheruser != 0} {
  puthelp "PRIVMSG $statchan :Нет ответа: $otheruser  "
  }
  puthelp "PRIVMSG $statchan :Всего клиентов: $scanusers"
  set inuse 0
}

proc gatherstat {nick uhost hand dest keyword arg} {
  global mircuser 
  global eggdropuser 
  global kvircuser 
  global bitchxuser 
  global mozillauser
  global operauser
  global irciiuser 
  global unkwnuser
  set arg [string tolower $arg]
  if {[string match *mirc* $arg] || [string match *nnscript* $arg] || [string match *neon* $arg] || [string match *vidocq* $arg] || [string match *pirc* $arg]} {
    incr mircuser 1
  } elseif {[string match *eggdrop* $arg]} {
    incr eggdropuser 1
  } elseif {[string match "*kvirc*" $arg]} {
    incr kvircuser 1
  } elseif {[string match *chatzilla* $arg] || [string match *firefox* $arg]} {
    incr mozillauser 1
  } elseif {[string match *opera* $arg]} {
    incr operauser 1
  } elseif {[string match *bitchx* $arg]} {
    incr bitchxuser 1
  } elseif {[string match *ircii* $arg]} {
    incr irciiuser 1
  } else {
    incr unkwnuser 1
  }
}

set inuse 0
set statchan 0
set scanchan 0
set scanusers 0
set mircuser 0
set eggdropuser 0
set kvircuser 0
set mozillauser 0
set operauser 0
set bitchxuser 0
set irciiuser 0
set unkwnuser 0

putlog "Loaded clientstats.tcl v1.1 by slennox"

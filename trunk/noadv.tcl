#-- скрипт антирекламы каналов
#-- * перед наказанием проверяет наличие канала
#-- заточен под RusNet
#-- v0.2

bind raw - NOTICE ::noadv::advnotice
bind pubm -|- "*" ::noadv::noadv

namespace eval noadv {

#--настройки
# флаг включения скрипта (.chanset #channel +noadv)
variable advflag	"noadv"
# слова, по которым идет проверка
variable adwrd 		{"#" " канал "}
# разрешенные каналы
variable adwp		{"#help" "#abuse" "#freebot" "#eggdrop" "#humor"}
# лог в патилайн
variable advlog		1
# время бана (минуты) (0 - перманентный бан)
variable btime		60
# сообщение при бане-кике
variable bmsg		"не рекламь"
# маска бана
variable bmask 		1 
					# 1 - *!*@some.host.com
					# 2 - *!*@*.host.com
					# 3 - *!*ident@some.domain.com
					# 4 - *!*ident@*.host.com
					# 5 - *!*ident*@*.host.com
					# 6 - *!*ident*@some.host.com
					# 7 - nick*!*@*.host.com
					# 8 - *nick*!*@*.host.com
					# 9 - nick*!*@some.host.com
					# 10 - *nick*!*@some.host.com
					# 11 - nick!ident@some.host.com
					# 12 - nick!ident@*.host.com
					# 13 - *nick*!*ident@some.host.com
					# 14 - nick*!*ident*@some.host.com
					# 15 - *nick*!*ident*@some.host.com
					# 16 - nick!*ident*@some.host.com
					# 17 - nick*!*ident@*.host.com
					# 18 - nick*!*ident*@*.host.com
					# 19 - *nick*!*ident@*.host.com
					# 20 - *nick*!*ident*@*.host.com

#--конец настроек

setudef flag $advflag

proc noadv {nick uhost handle chan text} {
	variable gchan  $chan
	variable guhost $uhost
	variable gnick  $nick
	variable advflag
	variable adwrd
	variable advlog
	variable adwp

	if {![channel get $chan $advflag]} {return}

	regsub -all -- {[\x02\x16\x1f]|\x03\d{0,2}(,\d{0,2})?} [string map {\\ "" \] "" \( "" \* "" \" "" \} "" \) "" \, "" \[ "" \{ "" \. "" \? ""} $text] "" str

	foreach adw $adwrd {
		if {[string match -nocase "*$adw*" $str]} {
			set areg {\s*(\w+)} 
			if {[regexp -nocase -- "$adw$areg" $str -> schan]} {
				set schan "#[string trimleft $schan "#"]"
					if {$advlog} {putlog "adv :: $schan"}
					if {$chan != $schan && [lsearch $adwp $schan] == -1} {putserv "squery list :list $schan"}
			} 
		} 
	}
} ;#noadv

proc advnotice {from keyword text} {
	variable btime
	variable gchan
	variable guhost
	variable gnick
	variable bmsg
	variable advlog

		if {[regexp -nocase -- {найдено (\d+) видимых} $text -> cnum]} {
			if {$cnum != 0} {
          		if {[botisop $gchan] || [botishalfop $gchan] } {
					putquick "PRIVMSG $gchan :($cnum) $gnick :: $bmsg"
            		putserv "KICK $gchan $gnick :$bmsg" 
						if {$advlog} {putlog "KICK $gchan $gnick :$bmsg"}				
    				newchanban $gchan [advban $gchan $guhost $gnick] $::botnick "$bmsg" $btime
						if {$advlog} {putlog "ban: $gchan [advban $gchan $guhost $gnick] $::botnick $bmsg $btime"}
				}
			}
		}
}

proc advban {chan uhost nick} {
 	variable bmask
   	switch -- $bmask {
     1 { set banmask "*!*@[lindex [split $uhost @] 1]" }
     2 { set banmask "*!*@[lindex [split [maskhost $uhost] "@"] 1]" }
     3 { set banmask "*!*$uhost" }
     4 { set banmask "*!*[lindex [split [maskhost $uhost] "!"] 1]" }
     5 { set banmask "*!*[lindex [split $uhost "@"] 0]*@[lindex [split [maskhost $uhost] "@"] 1]" }
     6 { set banmask "*!*[lindex [split $uhost "@"] 0]*@[lindex [split $uhost "@"] 1]" }
     7 { set banmask "$nick*!*@[lindex [split [maskhost $uhost] "@"] 1]" }
     8 { set banmask "*$nick*!*@[lindex [split [maskhost $uhost] "@"] 1]" }
     9 { set banmask "$nick*!*@[lindex [split $uhost "@"] 1]" }
    10 { set banmask "*$nick*!*@[lindex [split $uhost "@"] 1]" }
    11 { set banmask "$nick*!*[lindex [split $uhost "@"] 0]@[lindex [split $uhost @] 1]" }
    12 { set banmask "$nick*!*[lindex [split $uhost "@"] 0]@[lindex [split [maskhost $uhost] "@"] 1]" }
    13 { set banmask "*$nick*!*$uhost" }
    14 { set banmask "$nick*!*[lindex [split $uhost "@"] 0]*@[lindex [split $uhost "@"] 1]" }
    15 { set banmask "*$nick*!*[lindex [split $uhost "@"] 0]*@[lindex [split $uhost "@"] 1]" } 
    16 { set banmask "$nick!*[lindex [split $uhost "@"] 0]*@[lindex [split $uhost "@"] 1]" } 
    17 { set banmask "$nick![lindex [split $uhost "@"] 0]@[lindex [split [maskhost $uhost] "@"] 1]" }
    18 { set banmask "$nick!*[lindex [split $uhost "@"] 0]*@[lindex [split [maskhost $uhost] "@"] 1]" } 
    19 { set banmask "*$nick*!*[lindex [split $uhost "@"] 0]@[lindex [split [maskhost $uhost] "@"] 1]" }
    20 { set banmask "*$nick*!*[lindex [split $uhost "@"] 0]*@[lindex [split [maskhost $uhost] "@"] 1]" } 
    default { set banmask "*!*@[lindex [split $uhost @] 1]" }
    return $banmask
	}
} ;#from sbw_345.tcl

proc tolow {str} {if {[info exists ::sp_version]} {return [string tolower $str]} {return [encoding convertto cp1251 [string tolower [encoding convertfrom cp1251 $str]]]}}

} ;#ns
putlog ":: antiadv v0.2 by anaesthesia."
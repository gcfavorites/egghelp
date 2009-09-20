#       Аббревиатуры & Acronyms (c)anaesthesia
#       по мотивам acro.tcl by MenzAgitat
#
# 		v1.1 	Добавлен канальный флаг 
#				Изменен формат вывода
#				Добавлен новый параметр '+n' для вывода очередных $maxdef результатов
#		v1.5	Добавлен сайт для поиска русскоязычных аббревиатур		
#				Скрипт переписан с использованием namespace
#		v1.6	Оптимизированы процедуры кодирования url
#				Автоматический выбор сайта в зависимости от языка запроса

namespace eval acro {

##### - Настройки -
##### Команды для вызова
variable acronymcmd  "!acro"
variable acronymcmdr "!сокр"
##### Канальный флаг (.chanset #chan +acro для включения скрипта на канале #chan)
variable acronymflag acro
##### Число результатов выводимых за один раз
variable maxdef 5
##### Разрешить работу в привате? (1 - да, 0 - нет)
variable apriv 1

##### - далее лучше ничего не менять -
package require http
setudef flag $acronymflag
variable useragent "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.1) Gecko/20061204 Firefox/2.0.0.1"
variable acronymurl "http://acronyms.thefreedictionary.com/"
variable useragentr "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; 240x320)"	
variable acronymurlr "http://pda.sokr.ru/?where=abbr&exact=on&text="

bind pub -|- $acronymcmd ::acro::acronym_pub
bind pub -|- $acronymcmdr ::acro::acronym_pub
bind msg - $acronymcmd ::acro::acronym_msg
bind msg - $acronymcmdr ::acro::acronym_msg

proc acronym_pub {nick host hand chan arg} {
variable acronymflag
	if {![channel get $chan $acronymflag]} {return}
	acron $nick $host $hand $chan $arg
}

proc acronym_msg {nick host hand arg} {
variable apriv
	if {!$apriv} {return}
	acron $nick $host $hand $nick $arg
}

proc urlenc {strr} {
	global sp_version
	set url ""
 	if {![info exists sp_version]} {set aenc "encoding convertfrom utf-8"} {set aenc "encoding convertto cp1251"}
	foreach byte [split [eval $aenc $strr] ""] {
		scan $byte %c i
			if {[string match {[%<>"]} $byte] || $i < 65 || $i > 122} {
				append url [format %%%02X $i]
			} else {
				append url $byte
			}
      }
    return [string map {%3A : %2D - %2E . %30 0 %31 1 %32 2 %33 3 %34 4 %35 5 %36 6 %37 7 %38 8 %39 9 \[ %5B \\ %5C \] %5D \^ %5E \_ %5F \` %60} $url]
}

proc sconv {strr} {
	set smaps {
&quot;     '     &apos;     \x27  &amp;      \x26  &lt;       \x3C   &gt;       \x3E  &nbsp;     \x20
&iexcl;    \xA1  &curren;   \xA4  &cent;     \xA2  &pound;    \xA3   &yen;      \xA5  &brvbar;   \xA6
&sect;     \xA7  &uml;      \xA8  &copy;     \xA9  &ordf;     \xAA   &laquo;    \xAB  &not;      \xAC
&shy;      \xAD  &reg;      \xAE  &macr;     \xAF  &deg;      \xB0   &plusmn;   \xB1  &sup2;     \xB2
&sup3;     \xB3  &acute;    \xB4  &micro;    \xB5  &para;     \xB6   &middot;   \xB7  &cedil;    \xB8
&sup1;     \xB9  &ordm;     \xBA  &raquo;    \xBB  &frac14;   \xBC   &frac12;   \xBD  &frac34;   \xBE
&iquest;   \xBF  &times;    \xD7  &divide;   \xF7  &Agrave;   \xC0   &Aacute;   \xC1  &Acirc;    \xC2
&Atilde;   \xC3  &Auml;     \xC4  &Aring;    \xC5  &AElig;    \xC6   &Ccedil;   \xC7  &Egrave;   \xC8
&Eacute;   \xC9  &Ecirc;    \xCA  &Euml;     \xCB  &Igrave;   \xCC   &Iacute;   \xCD  &Icirc;    \xCE
&Iuml;     \xCF  &ETH;      \xD0  &Ntilde;   \xD1  &Ograve;   \xD2   &Oacute;   \xD3  &Ocirc;    \xD4
&Otilde;   \xD5  &Ouml;     \xD6  &Oslash;   \xD8  &Ugrave;   \xD9   &Uacute;   \xDA  &Ucirc;    \xDB
&Uuml;     \xDC  &Yacute;   \xDD  &THORN;    \xDE  &szlig;    \xDF   &agrave;   \xE0  &aacute;   \xE1
&acirc;    \xE2  &atilde;   \xE3  &auml;     \xE4  &aring;    \xE5   &aelig;    \xE6  &ccedil;   \xE7
&egrave;   \xE8  &eacute;   \xE9  &ecirc;    \xEA  &euml;     \xEB   &igrave;   \xEC  &iacute;   \xED
&icirc;    \xEE  &iuml;     \xEF  &eth;      \xF0  &ntilde;   \xF1   &ograve;   \xF2  &oacute;   \xF3
&ocirc;    \xF4  &otilde;   \xF5  &ouml;     \xF6  &oslash;   \xF8   &ugrave;   \xF9  &uacute;   \xFA
&ucirc;    \xFB  &uuml;     \xFC  &yacute;   \xFD  &thorn;    \xFE   &yuml;     \xFF  
\"         '     &ldquo;    `     &rdquo;    '     &ndash;    "-"    &mdash;    "-"	  &dagger; 	" им. "
\{         (     \}          )	
}

	set ret ""
  	while { [regexp {^(.*?)&#(\d{1,4});(.*)$} $strr - p e strr] } {
    	append ret $p [format %c $e]
  	}
  	set strr [append ret $strr]
	return [string map -nocase $smaps $strr]
}

proc chkrus {strr} {
  set len [string length $strr]
  set cnt 0
  	while {$cnt < $len} {
   		if {[regexp -all -- {[ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮЁйцукенгшщзхъфывапролджэячсмитьбюё]} [string index $strr $cnt]]} {return 1}
   		incr cnt
  		}
  return 0
}

proc scount {subs string} {regsub -all $subs $string $subs string}

proc acron {nick host hand chan arg}  {
variable useragent 
variable useragentr
variable acronymurl
variable acronymurlr
variable acronymcmd
variable acronymcmdr
variable maxdef

	set arg [string trim $arg]
  	if {$arg == ""} {
  		acronym_syntax $chan
	} else {
  		putcmdlog "$nick $chan $::lastbind $arg"
		set res ""

		if { [regexp -nocase -- {^[-|+](\d+)\s+} $arg -> mpg] } { 
			set mpage $mpg
			regsub -- {^[-|+]\d+\s+} $arg "" arg
		} else {
			set mpage 0
		}
		if {[chkrus $arg]} {
  			set url "$acronymurlr[urlenc $arg]"
 			::http::config -useragent $useragentr
			set token [::http::geturl "$url"]
			if {[::http::status $token] == "ok"} {
    			regexp "</form></div>(.+?)</body></html>" [::http::data $token] -> res
				regsub -all -- "\n|\r|\t" $res "" res
				regexp -all -nocase -- {<small>.*?<b>(.*?)</b></small><br /><br />} $res -> numresults
    			regexp -all -- "<br /><br />(.*?)$" $res -> res
				regsub -all -- "</div>" $res "\n" res
    			if { $numresults != "0"  } {
    				set counter 1
						if {$numresults == 1} {
	   						puthelp "privmsg $chan :\002\037найдено $numresults\037 :\002"
	   					} elseif {$numresults >1 && [expr $mpage * $maxdef] <= $numresults} {
	   						puthelp "privmsg $chan :\002\([expr ($mpage * $maxdef) + 1]\/[expr [expr (($mpage + 1) * $maxdef)] > $numresults ? $numresults : [expr (($mpage + 1) * $maxdef)]]\) \037всего:\037 $numresults \002"
	   					} else { puthelp "privmsg $chan :\037неверный параметр\037" }

					foreach rline [split $res \n] {
						if {[regexp -nocase -- {<b>(.*?)</b>.*?<div\ class=\"what\">(.*?)$} $rline -> rname rdesc]} {
							regsub -all -- "<br />" $rdesc { } rdesc
							regsub -all -- "<i>" $rdesc "\00314" rdesc
							regsub -all -- "</i>" $rdesc "\003" rdesc
							regsub -all -- "<.*?>" $rdesc { } rdesc

							set line "$rname — [sconv $rdesc]"
							if {( $counter >= [expr $maxdef + ($mpage * $maxdef)]) && ($numresults > [expr $maxdef + ($mpage * $maxdef)])} { 
								set line "$line  \00304($acronymcmdr \+[ expr $mpage + 1 ] $arg)\003 - следующие $maxdef результатов" 
							}
							if {$counter >= [expr ($mpage * $maxdef) + 1 ]} {
      							puthelp "privmsg $chan :$line"
							}
							if {( $counter >= [expr $maxdef + ($mpage * $maxdef)]) && ($numresults > [expr $maxdef + ($mpage * $maxdef)])} {
								return
							}
							incr counter
						}
					}	
				} else { 
					puthelp "privmsg $chan :\002$nick\002 > \037Ничего не найдено\037."
				}
			} else {
				puthelp "privmsg $chan :\037Timeout\037."
			}
		} else {
			set url "$acronymurl[urlenc $arg]"
			::http::config -useragent $useragent
			set token [::http::geturl "$url"]
			if {[::http::status $token] == "ok"} {
    			regexp "<tr><th>Acronym</th><th>Definition</th></tr>(.+?)</table>" [::http::data $token] res

    			if { $res != ""  } {
      				set res [encoding convertfrom "utf-8" $res ]
					regsub -all "<th>Acronym</th><th>Definition</th>" $res "" res
					regsub -all "</td></tr>" $res "\n" res
					regsub -all "</td><td>" $res " — " res
					regsub -all "<\[^<\]*>" $res "" res
					regsub -all "</td></tr>" $res "</td></tr>\n" res

      					if {$res != ""} {
							set numresults [scount "\n" $res]
      						set res [split $res "\n"]
 		      				set counter 1
	   							if {$numresults == 1} {
	   								puthelp "privmsg $chan :\002\037$numresults result\037 :\002"
	   							} elseif {$numresults >1 && [expr $mpage * $maxdef] <= $numresults} {
	   								puthelp "privmsg $chan :\002\([expr ($mpage * $maxdef) + 1]\/[expr [expr (($mpage + 1) * $maxdef)] > $numresults ? $numresults : [expr (($mpage + 1) * $maxdef)]]\) \037total:\037 $numresults\002"
	   							} else { puthelp "privmsg $chan :\037bad parameter\037" }

	   						foreach line $res {
      							if {[string trim $line] != "" && [string trim $line] != " "} {
									if {( $counter >= [expr $maxdef + ($mpage * $maxdef)]) && ($numresults > [expr $maxdef + ($mpage * $maxdef)])} { 
										set line "$line  \00304($acronymcmd \+[ expr $mpage + 1 ] $arg)\003 - next $maxdef results" 
									}
									if {$counter >= [expr ($mpage * $maxdef) + 1 ]} {
      									puthelp "privmsg $chan :$line"
									}
									if {( $counter >= [expr $maxdef + ($mpage * $maxdef)]) && ($numresults > [expr $maxdef + ($mpage * $maxdef)])} {
										break
									}
									incr counter
								}
      						}
						}
				} else {
  					puthelp "privmsg $chan :\002$nick\002 > \037No results\037"
				}
			} else {
				puthelp "privmsg $chan :\037Timeout\037"
			}
		::http::cleanup $token
		}
	}
}

proc acronym_syntax { chan } {
variable acronymcmd
	puthelp "privmsg $chan :\002$acronymcmd\002 \00314\[\003+num\00314\] <\003acronym\/сокращение\00314>"
	return done
}

}
putlog "::acro v01.6 by anaesthesia loaded."
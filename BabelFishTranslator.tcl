 ###############################################
#                                               #
#   B A B E L   F I S H   T R A N S L A T O R   #
#      v1.12en (07/07/2008)  by MenzAgitat      #
#                                               #
#          http://www.boulets-roxx.com          #
#        IRC:  irc.teepi.net    #boulets        #
#              irc.epiknet.org  #boulets        #
#                                               #
#        You can download my scripts at         #
#            http://www.egghelp.org             #
#                                               #
 ###############################################
# The Tinyurl procedure has been written by
# Tomekk (tomekk@oswiecim.eu.org), thanks to him.

#
# Description:
#   This script allow you to translate words or sentences
#   from/to various languages by typing "!translate <languages> <word or sentence>".
#
# Changelog:
#   1.0:  First version
#   1.01: Fixed the available languages list that was wrong (thanks to raktivist).
#          (only for english version, the french one do not have this problem)
#   1.1:  - It is now possible to do a request in private msg with the bot like this :
#            /msg botname !translate en-fr This is a test
#         - Integration in a namespace
#   1.11: - The help displays now faster
#         - Bug fix, the script should now work as expected. Sorry for that.
#		1.12: - fixes according to website changes (thanks to Ennery)

# LICENCE:
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA


namespace eval bftrans {
	###########################
	#        SETTINGS         #
	###########################

	##### Public command
	variable translatorcmd "!translate"

	##### Authorizations for the public command
	variable translatoraut "-|-"

	##### Allow private requests ? (0 = no, 1 = yes)
	variable translatorprivate "1"

	##### Private command
	variable translatorprivcmd "!translate"

	##### Authorizations for the private command
	variable translatorprivaut "-|-"

	##### Channels on which the translator will be active.
	##### (Use blank space as a separator)
	##### Add as many as you want or leave just one.
	##### Warning : chan's names are case sensitive !!
	variable translatorchans "#chan1 #chan2 #chan3"


################################################################
#                                                              #
# DO NOT MODIFY ANYTHING BELOW THIS BOX IF YOU DON'T KNOW TCL  #
#                                                              #
################################################################

package require http
	variable translatorversion "1.12en"
	variable DEBUGMODE 0
	variable useragent "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.1) Gecko/20061204 Firefox/2.0.0.1"
	variable translatorlanguages "en-fr en-de en-nl en-it en-pt en-es fr-en de-en nl-en it-en pt-en es-en"
	variable private 0
	bind pub $translatoraut $translatorcmd bftrans::translate
	bind msg $translatorprivaut $translatorprivcmd bftrans::translate_priv
}

##### Main procedure
proc bftrans::translate {nick host hand chan arg}  {
	variable private
	##### Do we have permission to use this command on this chan ?
	if {([channel_check_translator $chan] == 0) && ($chan ne "#****")} {return}
	if { $private == 1 } {set chan $nick}
	set arg [string trim $arg]
  if {$arg == ""} {
  	bftrans::translator_syntax $chan
		if $private {set private 0}
		return
  } elseif {$arg == "langlist"} {
		puthelp "PRIVMSG $nick :\037Available languages:\037"
    puthelp "PRIVMSG $nick :\002fr-en\002 覧 French/English  |  \002de-en\002 覧 German/English"
    puthelp "PRIVMSG $nick :\002nl-en\002 覧 Dutch/English  |  \002it-en\002 覧 Italian/English"
    puthelp "PRIVMSG $nick :\002pt-en\002 覧 Portuguese/English  |  \002es-en\002 覧 Spanish/English"
    puthelp "PRIVMSG $nick :\002en-fr\002 覧 English/French  |  \002en-de\002 覧 English/German"
    puthelp "PRIVMSG $nick :\002en-nl\002 覧 English/Dutch  |  \002en-it\002 覧 English/Italian"
    puthelp "PRIVMSG $nick :\002en-pt\002 覧 English/Portuguese  |  \002en-es\002 覧 English/Spanish"
		if $private {set private 0}
		return
	} else {
		set url1 "http://fr.babelfish.yahoo.com/translate_txt?doit=done&tt=urltext&intl=1&fr=bf-res&btnTrTxt=Traduire&lp="
  	set url2 "&trtext="
		set res ""
  	# putcmdlog "$nick@$chan translate $arg"
		set langtype [string range $arg 0 4]
		if $bftrans::DEBUGMODE {putlog "\00304\[BABEL DEBUG\]\003 langtype = $langtype"}

##### Are the requested languages	in the allowed languages list ?
		set lang_permission_result [bftrans::language_check_translator $langtype]
		if $bftrans::DEBUGMODE {putlog "\00304\[BABEL DEBUG\]\003 lang_permission_result = $lang_permission_result"}
		if {$lang_permission_result == 0} {
			puthelp "privmsg $chan :\00314This is not a valid language."
			bftrans::translator_syntax $chan
			if $private {set private 0}
#			return -code break
			return
		}
		set langtype [string map {- _} $langtype]
		set text [string range $arg 6 end]
		if $bftrans::DEBUGMODE {putlog "\00304\[BABEL DEBUG\]\003 text = $text"}
		if {$text == ""} {
			puthelp "privmsg $chan :\00314You must specify what you want to translate."
			bftrans::translator_syntax $chan
			if $private {set private 0}
#			return -code break
			return
		}
##### URL construction
		set text [string map {
      " "     "%20"		"\""    "%22"		"#"     "%23"		"$"     "%24"		"%"     "%25"
      "&"     "%26"   "'"     "%27"		"\("    "%28"   "\)"    "%29"   "*"     "%2A"
      "+"     "%2B"   ","     "%2C"   "."     "%2E"   "\/"    "%2F"   ":"     "%3A"
      ";"     "%3B"   "<"     "%3C"   "="     "%3D"   ">"     "%3E"   "?"     "%3F"
      "@"     "%40"   "\["    "%5B"   "\\"    "%5C"   "\]"    "%5D"		"^"			"%5E"
      "\{"    "%7B"   "|"     "%7C"   "\}"    "%7D"   "~"     "%7E"   "｡"     "%A1"
      "｢"			"%A2"		"｣"			"%A3"		"､"			"%A4"		"･"			"%A5"		"ｦ"			"%A6"
			"ｧ"			"%A7"		"ｨ"			"%A8"		"ｩ"			"%A9"		"ｪ"			"%AA"		"ｫ"			"%AB"
			"ｬ"			"%AC"		"ｭ"			"%AD"		"ｮ"			"%AE"		"ｯ"			"%AF"		"ｰ"			"%B0"
			"ｱ"			"%B1"		"ｲ"			"%B2"		"ｳ"			"%B3"		"ｴ"			"%B4"		"ｵ"			"%B5"
			"ｶ"			"%B6"		"ｷ"			"%B7"		"ｸ"			"%B8"		"ｹ"			"%B9"		"ｺ"			"%BA"
			"ｻ"			"%BB"		"ｼ"			"%BC"		"ｽ"			"%BD"		"ｾ"			"%BE"		"ｿ"			"%BF"
			"ﾀ"			"%C0"		"ﾁ"			"%C1"		"ﾂ"			"%C2"		"ﾃ"			"%C3"		"ﾄ"			"%C4"
			"ﾅ"			"%C5"		"ﾆ"			"%C6"		"ﾇ"			"%C7"		"ﾈ"			"%C8"		"ﾉ"			"%C9"
			"ﾊ"			"%CA"		"ﾋ"			"%CB"		"ﾌ"			"%CC"		"ﾍ"			"%CD"		"ﾎ"			"%CE"
			"ﾏ"			"%CF"		"ﾐ"			"%D0"		"ﾑ"			"%D1"		"ﾒ"			"%D2"		"ﾓ"			"%D3"
			"ﾔ"			"%D4"		"ﾕ"			"%D5"		"ﾖ"			"%D6"		"ﾗ"			"%D7"		"ﾘ"			"%D8"
			"ﾙ"			"%D9"		"ﾚ"			"%DA"		"ﾛ"			"%DB"		"ﾜ"			"%DC"		"ﾝ"			"%DD"
			"ﾞ"			"%DE"		"ﾟ"			"%DF"		"�"			"%E0"		"�"			"%E1"		"�"			"%E2"
			"�"			"%E3"		"�"			"%E4"		"�"			"%E5"		"�"			"%E6"		"�"			"%E7"
			"�"			"%E8"		"�"			"%E9"		"�"			"%EA"		"�"			"%EB"		"�"			"%EC"
			"�"			"%ED"		"�"			"%EE"		"�"			"%EF"		"�"			"%F0"		"�"			"%F1"
			"�"			"%F2"		"�"			"%F3"		"�"			"%F4"		"�"			"%F5"		"�"			"%F6"
			"�"			"%F7"		"�"			"%F8"		"�"			"%F9"		"�"			"%FA"		"�"			"%FB"
			"�"			"%FC"		"�"			"%FD"		"�"			"%FE"		"�"			"%FF"
		} $text]

  	set url "$url1$langtype$url2$text"
		if $bftrans::DEBUGMODE {putlog "\00304\[BABEL DEBUG\]\003 url = $url"}
  	::http::config -useragent $bftrans::useragent
		set token [::http::geturl "$url"]

		if {[::http::status $token] == "ok"} {
    	regexp "<div id=\"result\"><div style=\"padding:0.6em;\">(.+?)</div></div>" [::http::data $token] res
			if $bftrans::DEBUGMODE {putlog "\00304\[BABEL DEBUG\]\003 $res"}
    	if { $res != ""  } {
				regsub -all "\n" $res " " res
				regsub -all "<\[^<\]*>" $res "" res
      	set res [encoding convertfrom "utf-8" $res ]
      	if {$res != ""} {
	   			puthelp "privmsg $chan :\00314\037Translation\037:\003 $res"
				}
			} else {
  			puthelp "privmsg $chan :\00314$nick > Translation is impossible\003"
			}
		} else {
			puthelp "privmsg $chan :\00314The connexion to Babel Fish can't be established. Maybe the website suffer technical difficulties. Try again later.\003"
		}
		::http::cleanup $token
		if $private {set private 0}
	}
}

proc bftrans::translate_priv {nick host hand arg} {
	if !$bftrans::translatorprivate {return}
	variable private
	variable private 1
	bftrans::translate $nick $host $hand #**** $arg
	return
}

##### Syntax
proc bftrans::translator_syntax { chan } {
	variable private
	if $private {set private 0}
	puthelp "privmsg $chan :\037Syntax :\037 \002!translate\002 \00314<\003languages\00314> <\003word or sentence\00314> \00307| \003Display the translation for a given word or sentence. For a list of available languages, type \002!translate langlist\002"
	return
}


##### Check if the requested language is in the allowed languages list
proc bftrans::language_check_translator { langtype } {
	if {[lsearch -exact $bftrans::translatorlanguages $langtype] != -1} {
		return 1
	} else {
		return 0
	}
}


##### Check if the chan is in the allowed chans list
proc bftrans::channel_check_translator { chan } {
	if {[lsearch -exact $bftrans::translatorchans $chan] != -1} {
		return 1
	} else {
		return 0
	}
}


putlog "\002*Babel Fish Translator v$bftrans::translatorversion*\002 by MenzAgitat (\037\00312http://www.boulets-roxx.com\003\037) has been loaded"

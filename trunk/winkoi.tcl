# Win2Koi v1.0 by Stream

setudef flag nopubwk

bind pub - "!wk" pub:wintokoi
bind pub - "!kw" pub:koitowin

proc pub:wintokoi {nick uhost hand chan text} {
	if {[channel get $chan nopubwk]} return
	set Message "$nick: [win_to_koi $text]"
	putquick "PRIVMSG $chan :$Message"
	putlog "pub:trans $text ($chan: $nick) $Message"
}

proc pub:koitowin {nick uhost hand chan text} {
	if {[channel get $chan nopubwk]} return
	set Message "$nick: [koi_to_win $text]"
	putquick "PRIVMSG $chan :$Message"
	putlog "pub:trans $text ($chan: $nick) $Message"
}

proc win_to_koi {text} {
	return [string map {� � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �} [rus_lower $text]]
}

proc koi_to_win {text} {
	return [string map {� � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �} [rus_upper $text]]
}

proc rus_upper {text} {
	return [string map {� � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �} $text]
}

proc rus_lower {text} {
	return [string map {� � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �} $text]
}

putlog "[info script] by Stream loaded."
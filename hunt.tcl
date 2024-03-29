set msghunt 0
set puthunt PRIVMSG
set indhonline 0
setudef flag nopubhunt

bind pub - !hunt hunt:pub
bind pub - !��������� hunt:pub
bind pub - !���� hunt:pub

bind msg - !hunt hunt:msg
bind msg - !��������� hunt:msg
bind msg - !���� hunt:msg

bind bot - hunt  hunt:bot
bind bot - rephunt rephunt:bot


proc hunt:msg { nick mask hand text } {
	global msghunt
	set msghunt 1
	set chan ""
	hunt:pub $nick $mask $hand $chan $text
}


proc hunt:pub { nick mask hand chan text } {
	global indhunt hnick huntchan honline indhonline botnick msghunt puthunt

	if { $chan != "" } {
		if { [channel get $chan nopubhunt] } { return 0 }
	}

	set indhunt 0
	set honline 0
	set indhonline 0

	set hnick $nick
	set huntchan $chan

	if { $msghunt == 1 } {
		putlog "msg:hunt \[$nick\] $text"
		set puthunt PRIVMSG
	} else {
		putlog "pub:hunt \[$nick: $chan\] $text"
		set puthunt NOTICE
	}

	if { $text == "" } {
		putquick "$puthunt $nick :���������: \002!hunt <���>\002"
		set msghunt 0
		return 0
	}

	if { [hunt:to_lower [lindex $text 0]] == [hunt:to_lower $botnick] } {
		putquick "$puthunt $nick :Surley we have better things to do with our time than make a service message itself?"
		set msghunt 0
		return 0
	}

	if { [hunt:to_lower [lindex $text 0]] == [hunt:to_lower $nick] } {
		if { $msghunt == 1 } {
			putquick "PRIVMSG $nick :�������� ����� ����?"
			set msghunt 0
			return 0
		} else {
			putquick "PRIVMSG $chan :\001ACTION \002::\002 $nick �������� �� ����������� �����...\001"
			return 0
		}
	}

	if { $msghunt == 0 } {
		putquick "PRIVMSG $chan :\001ACTION \002::\002 $nick ��������������� � ������ �� �����...\001"
	}

	if { ![validuser [lindex $text 0]] } {
		if { $msghunt == 0 } {
			if { [onchan [lindex $text 0] $chan] } {
				putquick "NOTICE $nick :\002[lindex $text 0]\002 �����!"
				return 0
			}
		}

		foreach hchan [channels] {
			if { [onchan [lindex $text 0] $hchan] } {
				putquick "$puthunt $nick :�� ����������, ��� \002[lindex $text 0]\002 �� ������ \002$hchan\002."
				set msghunt 0
				return 0
			}
		}
	} else {
		if { $msghunt == 0 } {
			if { [handonchan [lindex $text 0] $chan] } {
				if { [hand2nick [lindex $text 0] $chan] == [lindex $text 0] } {
					putquick "NOTICE $nick :\002[lindex $text 0]\002 �����!"
					return 0
				} else {
					putquick "NOTICE $nick :\002[lindex $text 0]\002 ���� \002[hand2nick [lindex $text 0] $chan]\002 �����!"
					return 0
				}
			}
		}

		foreach hchan [channels] {
			if { [handonchan [lindex $text 0] $hchan] } {
				if { [hand2nick [lindex $text 0] $hchan] == [lindex $text 0] } {
					putquick "$puthunt $nick :�� ����������, ��� \002[lindex $text 0]\002 �� ������ \002$hchan\002."
					set msghunt 0
					return 0
				} else {
					putquick "$puthunt $nick :�� ����������, ��� \002[lindex $text 0]\002 ���� \002[hand2nick [lindex $text 0] $hchan]\002 �� ������ \002$hchan\002."
					set msghunt 0
					return 0
				}
			}
		}
	}

	bind raw - 319 hunt:whois
	bind raw - 401 hunt:nowhois
	bind raw - 312 hunt:online

	putserv "WHOIS [lindex $text 0]"
}


proc hunt:bot { bot comm arg } {
	global network bot_honline bot_indhonline hbot

	set bot_honline 0
	set bot_indhonline 0
	set hbot $bot

	if { ![validuser $arg] } {
		foreach hchan [channels] {
			if { [onchan $arg $hchan] } {
				putbot $bot "rephunt 0 $network $arg $hchan 0"
				return 0
			}
		}
	} else {
		foreach hchan [channels] {
			if { [handonchan $arg $hchan] } {
				if { [hand2nick $arg $hchan] == $arg } {
					putbot $bot "rephunt 0 $network $arg $hchan 0"
					return 0
				} else {
					putbot $bot "rephunt 0 $network $arg $hchan 1 [hand2nick $arg $hchan]"
					return 0
				}
			}
		}
	}

	bind raw - 319 bot_hunt:whois
	bind raw - 401 bot_hunt:nowhois
	bind raw - 312 bot_hunt:online

	putserv "WHOIS $arg"

}


proc rephunt:bot { bot comm arg } {
	global indhunt hnick puthunt msghunt network

	if { $indhunt == 1 } { return 0 }
	set indhunt 1

	if { [hunt:to_lower $network] == [hunt:to_lower [lindex $arg 1]] } {
		set rephand ""
	
		if { [lindex [lindex $arg 2] 0] == "" } {
			set repmess "��������, ��� \002[lindex $arg 2]\002"
		} else {
			set repmess "��������, ��� \002[lindex [lindex $arg 2] 0]\002"
		}

		if { [lindex $arg 4] == 1 } {

			if { [lindex [lindex $arg 5] 0] == "" } {
				set rephand "���� \002[lindex $arg 5]\002 "
			} else {
				set rephand "���� \002[lindex [lindex $arg 5] 0]\002 "
			}

		}

		putquick "$puthunt $hnick :$bot ��������: $repmess $rephand�� ������ \002[lindex $arg 3]\002."

	} else {

		if { [lindex [lindex $arg 2] 0] == "" } {
			set repmess "��������, ��� \002[lindex $arg 2]\002"
		} else {
			set repmess "��������, ��� \002[lindex [lindex $arg 2] 0]\002"
		}

		if { [lindex $arg 4] == 0 } {
			set rephide "����������� �"
		} else {
			set rephide "�� ������ [lindex $arg 5] �"
		}

		if { [lindex $arg 0] == 1 } {
			putquick "$puthunt $hnick :$bot ��������: $repmess $rephide ���� \002[lindex $arg 1]\002 (������: \002[lindex $arg 3]\002)."
		} else {
			
			set rephand ""
			
			if { [lindex [lindex $arg 2] 0] == "" } {
				set repmess "��������, ��� \002[lindex $arg 2]\002"
			} else {
				set repmess "��������, ��� \002[lindex [lindex $arg 2] 0]\002"
			}
			
			if { [lindex $arg 4] == 1 } {
				
				if { [lindex [lindex $arg 5] 0] == "" } {
					set rephand "���� \002[lindex $arg 5]\002 "
				} else {
					set rephand "���� \002[lindex [lindex $arg 5] 0]\002 "
				}
				
			}
			
			putquick "$puthunt $hnick :$bot ��������: $repmess $rephand�� ������ \002[lindex $arg 3]\002 ���� \002[lindex $arg 1]\002."
		}
		
	}
	set msghunt 0
	return 0
}


proc hunt:whois { from keywrd servarg } {
	global hnick honline puthunt msghunt

	set honline 1
	putquick "$puthunt $hnick :�� ����������, ��� \002[lindex $servarg 1]\002 �� ������ \002#[hunt:strip_special [lrange $servarg 2 2]]\002."
	set msghunt 0

	unbind raw - 319 hunt:whois
	unbind raw - 401 hunt:nowhois
	unbind raw - 312 hunt:online

	return 0
}


proc hunt:nowhois { from keywrd servarg } {
	global hnick huntchan puthunt msghunt

	putlog "bot:hunt \[$hnick\] botnet hunt active!"

	unbind raw - 319 hunt:whois
	unbind raw - 401 hunt:nowhois
	unbind raw - 312 hunt:online

	putallbots "hunt [lindex $servarg 1]"
	putquick "$puthunt $hnick :�� �������� ����� ���� � \002[lindex $servarg 1]\002."
	set msghunt 0

	return 0
}


proc hunt:online { from keywrd servarg } {
	global hnick honline indhonline puthunt msghunt

	if { $honline == 0 } { 
		incr indhonline
	}

	if { $indhonline == 1 } {
		putquick "$puthunt $hnick :�� ���������� ��� \002[lindex $servarg 1]\002 �����������."
		set msghunt 0

		unbind raw - 319 hunt:whois
		unbind raw - 401 hunt:nowhois
		unbind raw - 312 hunt:online

		return 0
	}
}


proc bot_hunt:whois { from keywrd servarg } {
	global  bot_honline network hbot halfput

	set bot_honline 1
	set halfput "#[hunt:strip_special [lrange $servarg 2 2]]"

	return 0
}


proc bot_hunt:nowhois { from keywrd servarg } {

	unbind raw - 319 bot_hunt:whois
	unbind raw - 401 bot_hunt:nowhois
	unbind raw - 312 bot_hunt:online

	return 0
}


proc bot_hunt:online { from keywrd servarg } {
	global hbot bot_honline bot_indhonline network halfput

	if { $bot_honline == 0 } { 
		putbot $hbot "rephunt 1 $network [lindex $servarg 1] [lindex $servarg 2] 0"
	} else {
		putbot $hbot "rephunt 1 $network [lindex $servarg 1] [lindex $servarg 2] 1 $halfput"
	}

	unbind raw - 319 bot_hunt:whois
	unbind raw - 401 bot_hunt:nowhois
	unbind raw - 312 bot_hunt:online

	return 0
}


##############################################


proc hunt:to_lower {t} {
	regsub -all -- {�} $t {�} t; regsub -all -- {�} $t {�} t; regsub -all -- {�} $t {�} t
	regsub -all -- {�} $t {�} t; regsub -all -- {�} $t {�} t; regsub -all -- {�} $t {�} t
	regsub -all -- {�} $t {�} t; regsub -all -- {�} $t {�} t; regsub -all -- {�} $t {�} t
	regsub -all -- {�} $t {�} t; regsub -all -- {�} $t {�} t; regsub -all -- {�} $t {�} t
	regsub -all -- {�} $t {�} t; regsub -all -- {�} $t {�} t; regsub -all -- {�} $t {�} t
	regsub -all -- {�} $t {�} t; regsub -all -- {�} $t {�} t; regsub -all -- {�} $t {�} t
	regsub -all -- {�} $t {�} t; regsub -all -- {�} $t {�} t; regsub -all -- {�} $t {�} t
	regsub -all -- {�} $t {�} t; regsub -all -- {�} $t {�} t; regsub -all -- {�} $t {�} t
	regsub -all -- {�} $t {�} t; regsub -all -- {�} $t {�} t; regsub -all -- {�} $t {�} t
	regsub -all -- {�} $t {�} t; regsub -all -- {�} $t {�} t; regsub -all -- {�} $t {�} t
	regsub -all -- {�} $t {�} t; regsub -all -- {�} $t {�} t; regsub -all -- {�} $t {�} t
	
	regsub -all -- {A} $t {a} t; regsub -all -- {B} $t {b} t; regsub -all -- {C} $t {c} t
	regsub -all -- {D} $t {d} t; regsub -all -- {E} $t {e} t; regsub -all -- {F} $t {f} t
	regsub -all -- {G} $t {g} t; regsub -all -- {H} $t {h} t; regsub -all -- {I} $t {i} t
	regsub -all -- {J} $t {j} t; regsub -all -- {K} $t {k} t; regsub -all -- {L} $t {l} t
	regsub -all -- {M} $t {m} t; regsub -all -- {M} $t {n} t; regsub -all -- {O} $t {o} t
	regsub -all -- {P} $t {p} t; regsub -all -- {Q} $t {q} t; regsub -all -- {R} $t {r} t
	regsub -all -- {S} $t {s} t; regsub -all -- {T} $t {t} t; regsub -all -- {U} $t {u} t
	regsub -all -- {V} $t {v} t; regsub -all -- {W} $t {w} t; regsub -all -- {X} $t {x} t
	regsub -all -- {Y} $t {y} t; regsub -all -- {Z} $t {z} t
                   
	return $t
}


proc hunt:strip_special {t} {

	regsub -all -- {\:} $t {} t
	regsub -all -- {\+} $t {} t
	regsub -all -- {\@} $t {} t
	regsub -all -- {\#} $t {} t

	return $t
}


putlog "hunt.tcl v1.5.1 by mrBuG <mrbug@eggdrop.org.ru> loaded"
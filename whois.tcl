	# Author : MeTroiD, #v1per on Quakenet.
	# Please don't be lame and rip my script.
	# I've made it for Quakenet but i assume if the ircd you want to use it on has the same RAW's you can use it just fine.
	# Адаптация скрипта для сети IrcNet.ru и другие изменения
      # tvrsh
      set whois(author) "MeTroiD, #v1per on Quakenet"	
      set whois(coauthor) "tvrsh, #egghelp on IrcNet.ru"	

	# Version History
      # MeTroiD
	# 0.1      - Made a start, first expermimental test.
	# 0.2-0.5  - Finished some more code
	# 0.6-0.8  - The script was fully functional
	# 0.9      - Removed some silly crap that didnt work for Quakenet anyhow (shows which server he was on)
	# 1.0      - Cleaned some of the code, and it works fine on Quakenet, It also shows idle time and signon time now.
      # tvrsh
      # 1.1      - Изменены RAW бинды для работы в сети IrcNet.ru
      #          - Добавлена возможность работы со скриптом в привате бота.
      #          - Добавлен канальный флаг nopubwhois
	set whois(version) "1.10"
	# End of Version History

	# Config:
	# What is the minimum access someone needs to perform a whois with the bot?
	# o = global op, m = global master, n = global owner
	# |o = channel op, |m = channel master, |n = channel owner
	set whois(acc) ""

      set whois(msg) "1"
 
      #Channel flag to enable ~whois command
      setudef flag nopubwhois
	# End of Config

	bind pub $whois(acc) "~whois" pubwhois:nick
	bind msg $whois(acc) "~whois" msgwhois:nick

      proc pubwhois:nick { nickname hostname handle channel arguments } {
      global whois lastbind
       if { [channel get $channel nopubwhois] } { return 0 }
              set target [lindex [split $arguments] 0]
              if {$target == ""} {
                  putquick "PRIVMSG $channel :Use $lastbind <nick>"
	            return 0
	        }
	        if {[string length $target] >= "31"} {
	            putquick "PRIVMSG $channel :Sorry, That nickname is too long. Please try a user with less than 14 characters."; return
	        }
      whois:nick $nickname $hostname $handle $channel $target
      return
      }

      proc msgwhois:nick { nickname hostname handle arguments } {
      global whois lastbind
          if { $whois(msg) != "1" } { return 0 }
              set target [lindex [split $arguments] 0]
              if {$target == ""} {
                  putquick "PRIVMSG $nickname :Use $lastbind <nick>"
	            return 0
	        }
	        if {[string length $target] >= "31"} {
	            putquick "PRIVMSG $nickname :Sorry, That nickname is too long. Please try a user with less than 30 characters."
                  return 0
	        }
      whois:nick $nickname $hostname $handle $nickname $target
      return
      }

	proc whois:nick { nickname hostname handle channel target } {
	global whois lastbind
	putquick "WHOIS $target $target"
      set ::whoischannel $channel
	set ::whoistarget $target
	bind RAW - 402 whois:nosuch
	bind RAW - 311 whois:info
	bind RAW - 319 whois:channels
	bind RAW - 301 whois:away
	bind RAW - 310 whois:helper
	bind RAW - 312 whois:server
	bind RAW - 313 whois:ircop
	bind RAW - 307 whois:auth
	bind RAW - 317 whois:idle
	}

	proc whois:putmsg { channel arguments } {
		putquick "PRIVMSG $channel :$arguments"
	}

	proc whois:info { from keyword arguments } {
		set channel $::whoischannel
		set nickname [lindex [split $arguments] 1]
		set ident [lindex [split $arguments] 2]
		set host [lindex [split $arguments] 3]
		set realname [string range [join [lrange $arguments 5 end]] 1 end]
		whois:putmsg $channel "$nickname is $ident@$host * $realname"
		unbind RAW - 311 whois:info
	}

	proc whois:ircop { from keyword arguments } {
		set channel $::whoischannel
		set target $::whoistarget
            set ircopmessage [string range [join [lrange $arguments 2 end]] 1 end]
		whois:putmsg $channel "$target $ircopmessage"
		#unbind RAW - 313 whois:ircop
	}

proc whois:helper { from keyword arguments } {
		set channel $::whoischannel
		set target $::whoistarget
            set helpermessage [string range [join [lrange $arguments 2 end]] 1 end]
		whois:putmsg $channel "$target $helpermessage"
		unbind RAW - 310 whois:helper
	}

	proc whois:away { from keyword arguments } {
		set channel $::whoischannel
		set target $::whoistarget
		set awaymessage [join [lrange $arguments 2 end]]
		whois:putmsg $channel "$target is away: $awaymessage"
		unbind RAW - 301 whois:away
	}

	proc whois:server { from keyword arguments } {
		set channel $::whoischannel
		set target $::whoistarget
		set servername [join [lrange $arguments 2 2]]
		set serverdesc [string range [join [lrange $arguments 3 end]] 1 end]
		whois:putmsg $channel "$target using $servername $serverdesc"
		unbind RAW - 312 whois:server
	}

	proc whois:channels { from keyword arguments } {
		set channel $::whoischannel
		set channels [string range [join [lrange $arguments 2 end]] 1 end]
		set target $::whoistarget
            while { $channels != "" } { whois:putmsg $channel "$target on [string range $channels 0 399]"
            set channels [string range $channels 400 end] }
		unbind RAW - 319 whois:channels
	}

	proc whois:auth { from keyword arguments } {
		set channel $::whoischannel
		set target $::whoistarget
		set authmessage [string range [join [lrange $arguments 2 end]] 1 end]
		whois:putmsg $channel "$target $authmessage"
		unbind RAW - 307 whois:auth
	}

	proc whois:nosuch { from keyword arguments } {
		set channel $::whoischannel
		set target $::whoistarget
		whois:putmsg $channel "No such nickname \"$target\""
		unbind RAW - 402 whois:nosuch
	}

	proc whois:idle { from keyword arguments } {
		set channel $::whoischannel
		set target $::whoistarget
		set idletime [lindex [split $arguments] 2]
		set signon [lindex [split $arguments] 3]
		whois:putmsg $channel "$target has been idle [duration $idletime], signed on [ctime $signon]"
		unbind RAW - 317 whois:idle
	}

	putlog "Public whois script $whois(version) by $whois(author) and $whois(coauthor) loaded"

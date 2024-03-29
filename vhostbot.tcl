# vhostbot.tcl version 1.0b by TCL_no_TK <ispmailsucks@googlemail.com>

# An highly configurable vhost bot script, options configured via chanset command.
# ability to have differant flag/channel assignment for vhosts. Also able to remove
# a vhost on part. (with support for v-ident)

# To give everyone that joins are channel a vhost
# .chanset #channel +vhost-onjoin
# .chanset #channel onjoin-vhost of.this.channel.org
# .chanset #channel onjoin-vident users
#
# To give users with a serton flag a vhost when they join are channel
# .chanset #channel +vhostbot
# .chanset #channel flag-vhost of.this.channel.org
# .chanset #channel flag-vident ops
# .chanset #channel vhost-flag o
#
# To remove users vhost's they are given when they leave the channel
# .chanset #channel +remove-vhost-onpart
#
# To remove users vident's they are given when they leave the channel
# .chanset #channel +remove-vident-onpart

# -- Notes
# Users must be in eggdrop's userfile if you wish to use the channel option(s); remove-vhost-onpart or remove-vident-onpart.
# The vhost-flag option, must be given to users via .chattr <handle> <[+]flag> see the doc/ folder and look at the file USERS
# if you need information on this. v-ident's may not be supported by your ircd, Please check your ircd'd documents if you are unsure.
# Using both vhost-onjoin and vhostbot on the same channel, may result in a user's vhost being set twice.

#code
if {![info exists whois-fields]} {
 set whois-fields "LSH LSI"
} else {
 append whois-fields " LSH"
 append whois-fields " LSI"
}

proc part:vhostbot {nick host handle channel {msg ""}} {
global vhostbot_botusersonly
 if {[validuser $handle]} {
  if {[channel get $channel remove-vhost-onpart] == "+" && [channel get $channel remove-vident-onpart] == "+" && [getuser $handle XTRA LSH] != "" && [getuser $handle XTRA LSI] != ""} {
   putserv "CHGHOST $nick [getuser $handle XTRA LSH]"
    putserv "CHGIDENT $nick [getuser $handle XTRA LSI]"
     return
  }
   if {[channel get $channel remove-vhost-onpart] == "+" && [channel get $channel remove-vident-onpart] == "+" && [getuser $handle XTRA LSH] != "" && [getuser $handle XTRA LSI] == ""} {
    putserv "CHGHOST $nick [getuser $handle XTRA LSH]"
     return
   }
    if {[channel get $channel remove-vhost-onpart] == "+" && [channel get $channel remove-vident-onpart] == "+" && [getuser $handle XTRA LSH] == "" && [getuser $handle XTRA LSI] != ""} {
     putserv "CHGIDENT $nick [getuser $handle XTRA LSI]"
      return
    }
     if {[channel get $channel remove-vhost-onpart] == "+" && [channel get $channel remove-vident-onpart] != "+" && [getuser $handle XTRA LSH] != ""} {
      putserv "CHGHOST $nick [getuser $handle XTRA LSH]"
       return
     }
      if {[channel get $channel remove-vhost-onpart] != "+" && [channel get $channel remove-vident-onpart] == "+" && [getuser $handle XTRA LSI] != ""} {
       putserv "CHGIDENT $nick [getuser $handle XTRA LSI]"
        return
      }
 }
}

proc join:vhostbot {nick host handle channel} {
global vhostbot_botusersonly
 if {[channel get $channel vhost-onjoin] == "+" && [channel get $channel onjoin-vhost] != "" && [channel get $channel onjoin-vident] != ""} {
  if {[validuser $handle]} {
   setuser $handle XTRA LSH "[lindex [split $host "@"] 1]"
    setuser $handle XTRA LSI "[lindex [split $host "@"] 0]"
  }
   putserv "CHGHOST $nick [channel get $channel onjoin-vhost]"
    putserv "CHGIDENT $nick [channel get $channel onjoin-vident]"
     return
  }
   if {[channel get $channel vhost-onjoin] == "+" && [channel get $channel onjoin-vhost] != "" && [channel get $channel onjoin-vident] == ""} {
    if {[validuser $handle]} {
     setuser $handle XTRA LSH "[lindex [split $host "@"] 1]"
    }
     putserv "CHGHOST $nick [channel get $channel onjoin-vhost]"
      return
   }
    if {[channel get $channel vhost-onjoin] == "+" && [channel get $channel onjoin-vhost] == "" && [channel get $channel onjoin-vident] != ""} {
     if {[validuser $handle]} {setuser $handle XTRA LSI "[lindex [split $host "@"] 0]"}
      putserv "CHGIDENT $nick [channel get $channel onjoin-vident]"
       return
    }
     if {[channel get $channel vhostbot] == "+" && [channel get $channel vhost-flag] != "" && [channel get $channel flag-vhost] != "" && [channel get $channel flag-vident] != ""} {
      if {[validuser $handle] && [matchattr $handle +[channel get $channel vhost-flag]]} {
       setuser $handle XTRA LSH "[lindex [split $host "@"] 1]"
        setuser $handle XTRA LSI "[lindex [split $host "@"] 0]"
         putserv "CHGHOST $nick [channel get $channel flag-vhost]"
          putserv "CHGIDENT $nick [channel get $channel flag-vident]"
           return
      }
     }
      if {[channel get $channel vhostbot] == "+" && [channel get $channel vhost-flag] != "" && [channel get $channel flag-vhost] != "" && [channel get $channel flag-vident] == ""} {
       if {[validuser $handle] && [matchattr $handle +[channel get $channel vhost-flag]]} {
        setuser $handle XTRA LSH "[lindex [split $host "@"] 1]"
         putserv "CHGHOST $nick [channel get $channel flag-vhost]"
          return
       }
      }
       if {[channel get $channel vhostbot] == "+" && [channel get $channel vhost-flag] != "" && [channel get $channel flag-vhost] == "" && [channel get $channel flag-vident] != ""} {
        if {[validuser $handle] && [matchattr $handle +[channel get $channel vhost-flag]]} {
         setuser $handle XTRA LSI "[lindex [split $host "@"] 0]"
          putserv "CHGIDENT $nick [channel get $channel flag-vident]"
           return
        }
       }
}

#channel options
setudef flag vhost-onjoin
setudef flag vhostbot
setudef flag remove-vhost-onpart
setudef flag remove-vident-onpart
setudef str onjoin-vhost
setudef str onjoin-vident
setudef str vhost-flag
setudef str flag-vhost
setudef str flag-vident

#binds
bind join - "* *" join:vhostbot
bind part - "* *" part:vhostbot

#end
putlog "loaded vhostbot.tcl version 1.0b by TCL_no_TK"
return
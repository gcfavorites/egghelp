# botnick.tcl v1.0 (21 November 1999)
# copyright � 1999 by slennox <slennox@egghelp.org>
# slennox's eggdrop page - http://www.egghelp.org/
#
# This script adds a little feature that lots of people ask for - a DCC
# command (for global +n users) that changes the bot's nickname.
#
# Usage: botnick <newnick>
#
# Additional Features
# * You can use question marks in the newnick and the bot will substitute
#   random numbers, e.g. '.botnick harry??' would create a nick like
#   'harry53'.
# * You can use '.botnick -altnick' to make the bot switch to its alternate
#   nickname.


# Don't edit below unless you know what you're doing.

proc bn_dccbotnick {hand idx arg} {
  global altnick nick
  putcmdlog "#$hand# botnick $arg"
  set newnick [lindex [split $arg] 0]
  if {$newnick == ""} {
    putidx $idx "Usage: botnick <newnick>"
    return 0
  }
  if {$newnick == "-altnick"} {
    set newnick $altnick
  }
  while {[regsub -- \\? $newnick [rand 10] newnick]} {continue}
  putidx $idx "Changing nick to '$newnick'..."
  set nick $newnick
  return 0
}

bind dcc n botnick bn_dccbotnick

putlog "Loaded botnick.tcl v1.0 by slennox"

return

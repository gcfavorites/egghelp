############################################################################
# Title: Simple eggdrop uptime script
############################################################################
# Description: 
#  - An os independent os script verry simple. I know to simple but seems 
#    hard to find a deasend script that doesn't use the shell uptime but
#    but the actual uptime of the eggdrop. You can also use this in scripts
#    Example: [eggtime] this will return the value that is returned in 
#             channel. 
#  - This has dcc, pub & msg binds you can set them to your preference.
#
# Install: 
#  - Put this script into the scripts dir of the eggdrop
#  - Add this to your eggdrop config: "source scripts/uptime.tcl"
#  - Rehash the bot and your done.
#
# HomePage: http://www.ofloo.net/
# Mail: support[at]ofloo.net
#
# ChangeLog:
#  - 15/12/2003 :: Weak fix & adjusted msg little & added n00b help ;)
############################################################################

############################################################################
# SETTINGS

# Set the triggers to you preference..
# Dcc is always with a . infront also you don't have to add it in the bind
# I prefer for msg it to be a . as well so I always use . for msg (.uptime)
# You can use whatever of course for example ?uptime
# For channel triggers I always use ! you can change that as well to your 
# preference also it doesn't have to be uptime you can choose whatever

set time(dcc) "uptime"
set time(msg) "!uptime"
set time(pub) "!uptime"

# This is the flag to whom is able to use it if you would like only known 
# users to use it set it to "h" because the eggdrop will add users by default
# as hp if you didn't change it of course. You can also limit it to channel
# operators this means they have to be known to the eggdrop of course then 
# set it to "o" masters "m" owers "n" whatever you prefer of course.
# read the doc files to find out more about flags 

set time(flag) "-"

# How to edit the colors:
# for an eggdrop to know its an color you always need \003 so then put your
# favorite color behind it like mirc <ctrl> <k> you get a choice menu
# <ctrl> <k> <4> = red so look below \0034 = red yellow \0038 orange = \0037 
# and so on and so on think you get the idea ?

set time(col1) "\00314"
set time(col2) "\00303"

############################# DO NOT EDIT BELOW ############################

set vrs "0.2"

############################################################################
# BINDS

bind pub "$time(flag)" "$time(pub)" uptime:pub
bind dcc "$time(flag)" "$time(dcc)" uptime:dcc
bind msg "$time(flag)" "$time(msg)" uptime:msg

############################################################################
# PROCS

proc uptime:pub {nick uhost hand chan arg} {
  putserv "NOTICE $nick :[eggtime]"
}

proc uptime:msg {nick uhost hand arg} {
  putserv "PRIVMSG $nick :[eggtime]"
}

proc uptime:dcc {hand idx arg} {
  putdcc $idx "[eggtime]"
}

proc eggtime {} {
  set ::time(uptime) [expr [clock seconds]-$::uptime]
  set ::time(weak) [expr $::time(uptime)/604800]
  set ::time(uptime) [expr $::time(uptime)-$::time(weak)*604800]
  set ::time(days) [expr $::time(uptime)/86400]
  set ::time(uptime) [expr $::time(uptime)-$::time(days)*86400]
  set ::time(hour) [expr $::time(uptime)/3600]
  set ::time(uptime) [expr $::time(uptime)-$::time(hour)*3600]
  set ::time(mins) [expr $::time(uptime)/60]
  set ::time(uptime) [expr $::time(uptime)-$::time(mins)*60]
  set ::time(secs) $::time(uptime)
  set ::time(return) "$::time(col2)$::botnick $::time(col1)has been up for:$::time(col2) $::time(weak) $::time(col1)weak\(s\)$::time(col2) $::time(days) $::time(col1)day\(s\)$::time(col2) $::time(hour) $::time(col1)hour\(s\)$::time(col2) $::time(mins) $::time(col1)minute\(s\)$::time(col2) $::time(secs) $::time(col1)second\(s\)."
  return $::time(return)
}

############################################################################
putlog "Sucsesfully loaded \002Ofloo\002 uptime script version\002 $vrs\002"

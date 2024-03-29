# aidle.tcl v1.1 (28 March 1999) by slennox <slenny@ozemail.com.au>
# Latest versions can be found at www.ozemail.com.au/~slenny/eggdrop/
#
# Basic anti-idle script, sends random msg's to the specified channel at
# random time intervals.
#
# v1.0 - Initial release
# v1.1 - Stremlined startup timer check, added +1 to utimer

# Channel to send anti-idle messages to
set ai_chan "#mychannel"

# Maximum time interval between messages (in minutes)
set ai_time 60

# Messages to send
set ai_msgs {
  "*yawn*"
  "*sigh*"
  "*chuckle*"
  "afk"
  "anyone awake?"
  "anyone here?"
  "anyway"
  "argh"
  "bbiam"
  "la la la"
  "blah"
  "bleh"
  "brb"
  "damn"
  "gawd"
  "haha"
  "hahahaha"
  "heh"
  "hehe"
  "hehehe"
  "hello"
  "hi"
  "hey"
  "ic"
  "idiot"
  "rofl"
}


# Don't edit anything below unless you know what you're doing

proc ai_start {} {
  global ai_time
  if {[string match *ai_sendmsg* [timers]]} {return 0}
  timer [expr [rand $ai_time] + 1] ai_sendmsg
}

proc ai_sendmsg {} {
  global botnick ai_chan ai_msgs ai_time
  if {[validchan $ai_chan] && [onchan $botnick $ai_chan]} {
    puthelp "PRIVMSG $ai_chan :[lindex $ai_msgs [rand [llength $ai_msgs]]]"
  }
  timer [expr [rand $ai_time] + 1] ai_sendmsg
}

set ai_chan [string tolower $ai_chan]

ai_start

putlog "Loaded aidle.tcl v1.1 by slennox"

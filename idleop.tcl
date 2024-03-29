#         Script : IdleOP v1.03 by David Proper (Dr. Nibble [DrN])
#                  Copyright 2002 Radical Computer Systems
#
# modified and fixed by Kreon <starcom2k@gmail.com> in 2006
# official support @ http://irc.case.net.ru

proc idleopinit {} {
	global IDLEOP
# [0/1] Set this to 1 if you want the bot to +v users when it deops them.
 set IDLEOP(voice) 1 

# [0/1] Defualt status for IdleOP checking. 0:off 1:on
set IDLEOP(active) 1

# Set this to the number of minutes you want between each scan.
if {![info exists IDLEOP(timer)]} { set IDLEOP(timer) 5 }

# Set to anything above 0 to warn them of thier idle time. After someone will be idle more than warnidle, he will receive this msg. 
if {![info exists IDLEOP(warnidle)]} { set IDLEOP(warnidle) 15 }
set IDLEOP(idlemsg) "You've been idle for !idle! minutes on !channel!."

# This is the time in minutes to DeOP if longer then.
if {![info exists IDLEOP(maxidle)]} { set IDLEOP(maxidle) 30 }

# This is the time in minutes to DeVoice +v'ed OPs that are idle.
if {![info exists IDLEOP(maxidlev)]} { set IDLEOP(maxidlev) 60 }

# [0/1] Set this to 1 to devoice idle +v users. 0 not to.
set IDLEOP(dodevoice) 1

# Set this to the channels you want to be scanned by default.
if {![info exists IDLEOP(chans)]} { set IDLEOP(chans) {
	"#asd"
	"#dsa"
}
}

# Set this to a flag you want to be exempt from checks.
set IDLEOP(exempt) "E"


set IDLEOP(tag) "\002\[IdleOP\]\002"
set IDLEOP(ver) "v1.05"
}

set cmdchar_ "!"
proc cmdchar { } {
global cmdchar_
 return $cmdchar_
}
idleopinit

bind dcc o idleopchk dcc_idleopchk
proc dcc_idleopchk {handle idx args} {
global IDLEOP
 set chan [string tolower [lindex [console $idx] 0]]
 putidx $idx "$IDLEOP(tag) Checking OP Idle times for $chan"
 idleopchk $chan $idx
                                  }

proc check_idleop {} {
global IDLEOP
 timer $IDLEOP(timer) check_idleop
 if {$IDLEOP(active) == 0} {putlog "IdleOP Checking is Deactivated. Skipping Check."
                            return 0}
 foreach c [string tolower [channels]] {idleopchk $c 0}
                     }
 foreach t [timers] {
 	if {[lindex $t 1] == "check_idleop"} {killtimer [lindex $t 2]}
}
 timer $IDLEOP(timer) check_idleop

proc idleopchk {chan idx} {
global IDLEOP
 set dochan 999
 foreach c [string tolower $IDLEOP(chans)] {
 if {$c == $chan} {set dochan 1}
                                              }
 if {$dochan != 1} {return 0}

 foreach user1 [chanlist $chan] {
  if {[isbotnick $user1]} {continue}
  subst -nobackslashes -nocommands -novariables user1
  set ex 999
  set hand [nick2hand $user1 $chan]
  if {([matchattr $hand m] == 1) ||
      ([matchchanattr $hand |m $chan] == 1) ||
      ([matchattr $hand b] == 1)} {set ex 1}
  if {[matchattr $hand $IDLEOP(exempt)] || [matchchanattr $hand |$IDLEOP(exempt) $chan)]} {set ex 1}

 if {($ex != 1) && ([isvoice $user1 $chan])} { 
 set idletime [getchanidle $user1 $chan]
 if {(($IDLEOP(dodevoice)) && ($idletime > $IDLEOP(maxidlev)))} {
  if {($idx > 0)} {putidx $idx "User $user1 idle for $idletime minutes. DeVoiceing."
                } else {putlog "User $user1 idle for $idletime minutes. DeVoiceing."}
  putserv "NOTICE $user1 :You have been idle over $idletime minutes. Forced DeVoice."
  pushmode $chan -v $user1

                                       }
                                              }

 if {($ex != 1) && ([isop $user1 $chan])} {
 set idletime [getchanidle $user1 $chan]
 if {($idletime > $IDLEOP(warnidle))} {
  set idlemsg $IDLEOP(idlemsg)
  regsub -all {!idle!} $idlemsg "$idletime" idlemsg
  regsub -all {!channel!} $idlemsg "$chan" idlemsg
  putserv "NOTICE $user1 :$idlemsg"
                                      } 
 if {($idletime > $IDLEOP(maxidle))} {
  if {($idx > 0)} {putidx $idx "User $user1 idle for $idletime minutes. DeOPing."
                } else {putlog "User $user1 idle for $idletime minutes. DeOPing."}
  putserv "NOTICE $user1 :You have been idle over $idletime minutes. Forced DeOP."
#  putserv "MODE $chan -o $user1"
  pushmode $chan -o $user1

  if {($IDLEOP(voice) == 1) && (![isvoice $user1 $chan])} {
                       pushmode $chan +v $user1
                                                          }
  }
                                         }
                                 }
}


bind dcc o idleop dcc_idleop
proc dcc_idleop {handle idx args} {
global IDLEOP

foreach c $IDLEOP(chans) {
 listidleops $c $idx
                         }
}

proc listidleops {chan idx} {
global IDLEOP
 putidx $idx "$IDLEOP(tag) Listing Idle times for $chan"
 set exnum 0
 foreach user1 [chanlist $chan] {
  set hand [nick2hand $user1 $chan]
  set ex " "
 if {([matchattr $hand m] == 1) ||
     ([matchchanattr $hand m $chan] == 1) ||
     ([matchattr $hand b] == 1)} {set ex "E"
                                  set exnum [expr $exnum + 1]}
  if {$ex != " "} {set ex " \($ex\) "}
  if {([isop $user1 $chan]) || ([isvoice $user1 $chan])} {
  
   putdcc $idx "$IDLEOP(tag)  User $user1${ex}has been idle [getchanidle $user1 $chan] mins."
                              }
                                }
  if {$exnum > 0} {putidx $idx "$IDLEOP(tag) NOTE: Users marked with a (E) after thier nick are exempted from idle-deop"}
}


bind pub o [cmdchar]idleop pub_idleop
proc pub_idleop {nick uhost hand channel rest} {
global IDLEOP
switch [string tolower [lindex $rest 0]] {
 ""    { putserv "NOTICE $nick :IdleOP scanning is now [expr {$IDLEOP(active) == 1 && [lsearch $IDLEOP(chans) [string tolower $channel]] != -1 ? "active on $channel; settings: scantime $IDLEOP(timer), maxidle $IDLEOP(maxidle), maxidle-voice $IDLEOP(maxidlev)" : "disabled on $channel"}]"}
 "off" { set IDLEOP(active) 0; putserv "NOTICE $nick :Idleop is globally disabled" }
 "on"  { set IDLEOP(active) 1; putserv "NOTICE $nick :Idleop is globally enabled" }
 "enable" { if {[lsearch $IDLEOP(chans) [string tolower $channel]] == -1} {lappend IDLEOP(chans) $channel; putserv "NOTICE $nick :Idleop scan is enabled on $channel"} else {putserv "NOTICE $nick :Idleop scan is already enabled on $channel" }}
 "disable" { if {[set t [lsearch $IDLEOP(chans) [string tolower $channel]]] != -1} {set IDLEOP(chans) [lreplace $IDLEOP(chans) $t $t]; putserv "NOTICE $nick :Idleop scan is disabled on $channel"} else {putserv "NOTICE $nick :Idleop scan is already disabled on $channel" }}  
 "scan" { if {[string is integer [lindex $rest 1]]} {set IDLEOP(timer) [lindex $rest 1]; putserv "NOTICE $nick :Idleop scan time has been set to [lindex $rest 1]"} else {putserv "NOTICE $nick :String must be an integer"} }
 "maxidle" { if {[string is integer [lindex $rest 1]]} {set IDLEOP(maxidle) [lindex $rest 1]; putserv "NOTICE $nick :Idleop maxidle time has been set to [lindex $rest 1]"} else {putserv "NOTICE $nick :String must be an integer"}}
 "maxidlev" { if {[string is integer [lindex $rest 1]]} {set IDLEOP(maxidlev) [lindex $rest 1]; putserv "NOTICE $nick :Idleop maxidle-voice time has been set to [lindex $rest 1]"} else {putserv "NOTICE $nick :String must be an integer"}}
 "warnidle" { if {[string is integer [lindex $rest 1]]} {set IDLEOP(warnidle) [lindex $rest 1]; putserv "NOTICE $nick :Idleop warnidle time has been set to [lindex $rest 1]"} else {putserv "NOTICE $nick :String must be an integer"}}
 "help" { putserv "NOTICE $nick :Syntax: [cmdchar]idleop \[on|off|enable|disable|scan <time>|maxidle <time>|maxidlev <time>\]" }
 default { putserv "NOTICE $nick :Syntax: [cmdchar]idleop \[on|off|enable|disable|scan <time>|maxidle <time>|maxidlev <time>\]" }
 }
 }

putlog "IdleOP $IDLEOP(ver) loaded"



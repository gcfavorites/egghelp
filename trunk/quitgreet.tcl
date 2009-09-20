#---------------------------------------------------------------------
# quitgreet.tcl
# Tcl script for IRC bot eggdrop
#
# On a PART/SIGN/QUIT of a user sets the quit message as the infoline
# of that user. The user will be greeted with that message when 
# joining the channel. Channel needs +greet setting.
#
# v1: 04-Jul-2003
# 
#---------------------------------------------------------------------

package require Tcl 8.0
package require eggdrop 1.6.13

bind SIGN - * quitgreet
bind PART - * quitgreet
bind KICK - * kickgreet

proc storegreet { hand chan text } {

   # - must be valid hand
   # - must be valid chan
   # - check text on length

   if {![validuser $hand]} { return }

   if {![validchan $chan]} { return }

   if { $text == "" } {
      set text "Welcome back again! :)"
   }

   if {[string length $text] > 80 } {
      set text [string range $text 0 76]
      append text "..."
   }

   putlog "QUITGREET: setting info for $hand on $chan to $text."

   setinfo $hand $text

   setchaninfo $hand $chan $text

   return

}

proc quitgreet { nick uhost hand chan { text "" } } {

   if { [string match "Quit: " $text] } { set text "" }

   storegreet $hand $chan $text

}

proc kickgreet { nick uhost hand chan kickednick reason } {

   set kickedhand [nick2hand $kickednick $chan]

   storegreet $kickedhand $chan $reason

}

putlog {Loaded (version 1): QuitGreet.}

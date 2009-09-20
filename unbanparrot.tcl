#---------------------------------------------------------------------
# unbanparrot.tcl
# TCL script for IRC bot eggdrop.
# By default, bans set in the bot are removed from the bot after
# (ban-time) minutes or after explicit removal (.-ban) from the bot.
# This script removes the ban from the bots internal banlist if a
# known handle with the appropriate flags issues an unban 
# on a channel.
#
# Channel masters/operators can remove channel bans only.
# Global owners/masters/operators can remove channel and global bans.
# 
# v0: 23-Feb-2002
# v1: 23-Feb-2002
# v2: 24-Feb-2002
# - both above and below 1.3.23 (do not mess with or rename "args"!)
#---------------------------------------------------------------------

bind mode - * chanunbanlist

proc chanunbanlist { nick uhost hand chan args } {

   global botnick

   # below 1.3.23 passes 1 arg, otherwise 2 args. Join them.
   set modechange [join $args]

   # check if modechange is an unban 
   if {[scan $modechange "-b %s" banmask] != 1} { return }
   # bot issued unban (check is not really needed...)
   if {[string compare $nick $botnick] == 0 } { return }
   # return if handle is unknown (this will also skip server modes)
   if {[string compare hand "*"] == 0 } { return }
   # return if it is not a listed global and/or channel ban
   if {![isban $banmask $chan]} { return }

   # global flags: allow to kill global and/or channel ban
   foreach globflag "n m o" {
      if {[matchattr $hand $globflag]} {
         killban $banmask
         killchanban $chan $banmask
         putlog "Ban $banmask killed by $hand ($nick!$uhost)"
         return
      }
   }

   # return if it is a global ban
   if {[isban $banmask]} { return }

   # channel flags: allow to kill channel ban only
   foreach chanflag "m o" {
      if {[matchchanattr $hand $chanflag $chan]} {
         killchanban $chan $banmask
         putlog "Channel ban $banmask killed by $hand ($nick!$uhost)"
         return
      }
   }
   return
}   
     
putlog "UnbanParrot version 2 loaded."

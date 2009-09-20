# traffic.tcl

# General info:
# version 1.0
# prints eggdrop's traffic (in/out) information 
# Author: CoolCold <coolcold at eggdrop.org.ru>
# #rea@irc.coolcold.org:6667
#
#
#  __    __  __    _           _    
# \  \  /  /|  \  | |         | |   
#  \  \/  / |   \ | |  ____  _| |_  
#   \    /  | |\ \| | /  _ \|_   _| 
#   /    \  | | \   | | /_\/  | |   
#  /  /\  \ | |  \  | | \__   | |__ 
# /__/  \__\|_|   \_| \____/  \___/ 
#
# http://xnet.net.ru irc://xnet.net.ru
#
#
# with help of
#
#               :::[  T h e   R u s s i a n   E g g d r o p  R e s o u r c e  ]::: 
#      ____                __                                                      
#     / __/___ _ ___ _ ___/ /____ ___   ___      ___   ____ ___ _     ____ __ __   
#    / _/ / _ `// _ `// _  // __// _ \ / _ \    / _ \ / __// _ `/    / __// // /   
#   /___/ \_, / \_, / \_,_//_/   \___// .__/ __ \___//_/   \_, / __ /_/   \___/    
#        /___/ /___/                 /_/    /_/           /___/ /_/                
#
#
# Created with FAR ( http://www.farmanager.com )
# and colorer ( http://colorer.sf.net )
#
#
# Requirements:
# eggdrop (windrop) 1.6.15,tcl 8.4.5 (8.3.4)

# Usage:
# type !traffic (or any other trigger u set below ) and read instructions ;)

namespace eval traffic {
    
    ::putlog "Loading traffic.tcl..."
    
    #public command trigger
    set trig "!traffic"

    #access flags - m|- recommended
    set accflags "m|-"

    #messaging type - 1=privmsg, any other = notice (for nick)
    set messaging "1"

    ######################################
    #                                    #
    # Please do not edit anything below  #
    #                                    #
    ######################################
    
    #определяем собственный putlog в нашем пространстве имен
    proc putlog { text } {
            if {$text!=""} {
                    ::putlog "--- Traffic: $text"
            }
    }
    
    
    putlog "using namespace [namespace current]"
    
    set ver "1.0"
    set infoline "traffic.tcl by xadmin request"
    set author {CoolCold <coolcold [at] eggdrop.org.ru>}
    
    
    #удаляем старые bind'ы
    putlog "Removing our old binds ( if any ) ..."
    set tbinds [llength [binds "[namespace current]::*"]]
    foreach bind [binds "[namespace current]::*"] {
        catch {unbind [lindex $bind 0] [lindex $bind 1] [lindex $bind 2] [lindex $bind 4]}
    }
    putlog "$tbinds old binds removed"
    bind pub $accflags $trig [namespace current]::trigger

    proc trigger { nick uhost hand chan text } {
        global lastbind
        variable messaging
        if {$messaging == 1 } {set mstyle "PRIVMSG $nick"} else {
                set mstyle "NOTICE $nick"
        }
        set traffic [traffic]
        
        #creating all traffic types list
        foreach i $traffic {
            lappend ttypes [lindex $i 0]
        }
        
        switch -exact -- [string tolower $text] \
            [lindex $ttypes 0] -\
            [lindex $ttypes 1] -\
            [lindex $ttypes 2] -\
            [lindex $ttypes 3] -\
            [lindex $ttypes 4] -\
            [lindex $ttypes 5] {
                set ttype [lsearch $ttypes [string tolower $text]]
                set total [lindex [traffic] [lsearch $ttypes [string tolower $text]]]
                set today_in [lindex $total 1]
                set total_in [lindex $total 2]
                set today_out [lindex $total 3]
                set total_out [lindex $total 4]
                putserv "$mstyle :$text traffic statistics"
                putserv "$mstyle :   Сегодня in/out:\00303[convertvalue $today_in]\017/\00304[convertvalue $today_out]\017, Всего in/out:\00303[convertvalue $total_in]\017/\00304[convertvalue $total_out]"
            }\
            "all" {
                foreach i $ttypes { trigger $nick $uhost $hand $chan $i }
            }\
            default {
                putserv "$mstyle :Используй \"$lastbind <type>\", где <type> один из \"$ttypes\" или \"all\""
            }
        #end of switch should be here

    }
    proc convertvalue { value } {
       #let's round to Kb, Mb or Gb (?) if needed
            set suffix "b"
            if {[expr $value / 1024.0] > 1} {
                    #kilobytes
                    set value [expr $value / 1024.0]
                    set suffix "Kb"

                    if {[expr $value / 1024.0] > 1} {
                    #megabytes
                            set value [expr $value / 1024.0]
                            set suffix "Mb"
                            if {[expr $value / 1024.0] > 1} {
                            #gigabytes
                                    set value [expr $value / 1024.0]
                                    set suffix "Gb"
                                    if {[expr $value / 1024.0] > 1} {
                                    #terabytes
                                            set value [expr $value / 1024.0]
                                            set suffix "Tb"
                                    }
                            
                            }
                    }
       }
            set value [expr "round ( [expr $value * 1000] )" / 1000.0]
            return "$value $suffix"
    }


    putlog "$infoline version $ver by $author loaded"
}       

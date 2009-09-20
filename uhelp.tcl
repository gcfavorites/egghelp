###
#
#  ��������: uhelp.tcl
#  ������: 1.0
#  �����: username 
#
###
#
# ��������:  ����������������� ���� ��� ����. ���� DNK@IrcNet.ru
#
###
#
# ���������: 
#         1. ���������� ������ uhelp1.0.tcl � ����� scripts/uhelp ������ ����.
#         2. ����� ������ help.txt, help1.txt, help2.txt, ... ��������� � ����� scripts/uhelp
#         3. � ����� eggdrop.conf ������� ������ source scripts/uhelp/uhelp1.0.tcl 
#         4. �������� .rehash ����.
#
###
#
# ������� �������:
#
#              1.0(22.12.2007) ������ ������ ������.
#
###

# ��������� ������������ ����.
namespace eval uhelp {}

# ���������� �������� ���� ����������.
foreach p [array names uhelp *] { catch {unset uhelp($p) } }

# ��������� ��������� ����(.chanset #chan +nopubuhelp ��� ���������� �������).
setudef flag nopubuhelp

###                            ###
# ���� �������� ���� ���� �����: #
# ______________________________ #
###                            ###

# ������� ������.
set uhelp(pref) "!"

# ������ ������ �� ������� ����� ���������� ������.
set uhelp(binds) "help ����"

# ��� ��������� �������� ����� � ����� ������� �� �������������.
# ������ ������� ������� ���� �������� ��� ������� ��� ��������� �����.
set uhelp(trigs) {
scripts/uhelp/help.txt
���� scripts/uhelp/help1.txt
���� scripts/uhelp/help2.txt
������ scripts/uhelp/help3.txt
}

# ��������� ������ �� �������� � ������� � ����? (��-1/���-0)
set uhelp(msg) 1

# ������ �� ������� ����� �������� ���� ������.
set uhelp(channels) "#egghelp #testchan"

# ������� ������� �� ������� ������ ������� ������ � �������� �������� �����.
set uhelp(flood) 5:60

# �����(���) ������.
set uhelp(ignore) 10

###
# ��������� ������.

# �������� ���� ������.
set uhelp(color1) "\00314"

# ���� ������ ���������� ����������.
set uhelp(color2) "\00310"

# ���� ������ ���������� ����������.
set uhelp(color3) "\00304"
###

###                                                                  ###
# ���� ���� ����� ���������� ���, �� ��������� ��� ���� �� ������ TCL: #
# ____________________________________________________________________ #
###                                                                  ###

# ��������� ������� egglib.
if { ![info exists egglib(ver)] } {
    putlog "***********************************************"
    putlog "             egglib_pub NOT FOUND !"
    putlog "   Download last version of egglib_pub here:"
    putlog "  http://eggdrop.org.ru/scripts/egglib_pub.zip"
    putlog "***********************************************"
    die
}

if { [expr {$egglib(ver) < 1.4}] } {
    putlog "***********************************************"
    putlog " YOUR VERSION OF egglib_pub IS TOO OLD !"
    putlog "   Download last version of egglib_pub here:"
    putlog "  http://eggdrop.org.ru/scripts/egglib_pub.zip"
    putlog "***********************************************"
    putlog " version installed : $egglib(ver)"
    putlog " version required: 1.4"
    die
}

# ������ �������.
set uhelp(version) "uhelp.tcl version 1.0"

# ����� �������.
set uhelp(author) "username"

# ��������� ������.
foreach bind [split $uhelp(binds) " "] {
    bind pub -|- "$uhelp(pref)$bind" uhelp_pub
    if {$uhelp(msg) >= 1} {
        bind msg -|- "$uhelp(pref)$bind" uhelp_msg
    }
}

# ��������� ��������� ��������� ������.
proc uhelp_msg {nick uhost hand text} {
    global uhelp
    uhelp_proc $nick $uhost $hand $nick $text
}

# ��������� ��������� ������ ������.
proc uhelp_pub {nick uhost hand chan text} {
    global uhelp

    # ��������� ������� �����.
    if {[channel get $chan nopubuhelp]} { 
        return 
    }
    uhelp_proc $nick $uhost $hand $chan $text
}

# ��������� ��������� �������.
proc uhelp_proc {nick uhost hand chan text} {
    global uhelp lastbind

    # �������� �� ����.
    if {[flood_uhelp $nick $uhost]} {
        return
    }
    foreach trig [split $uhelp(trigs) "\n"] {
        lappend triglist [lindex [split $trig " "] 0]
        if {[string tolower [lindex $text 0]] == [string tolower [lindex [split $trig " "] 0]]} {
                set uhelpname [lindex [split $trig " "] 1]
                set uhelpdata [::egglib::readdata $uhelpname]
        }
    }
        if {[string tolower [lindex $text 0]] == ""} {
                set uhelpname [lindex [split $uhelp(trigs) "\n"] 1]
                set uhelpdata [::egglib::readdata $uhelpname]
        }
        if {[isnumber [lindex $uhelpdata 0]]} {
            set uhelpdata2 [lrange $uhelpdata 1 end]
            foreach line $uhelpdata2 {
                if { $line != "" } {
                    uhelp_largetext $nick $line
                }
    }
        set counter [expr [lindex $uhelpdata 0]+1]
        putserv "privmsg $nick :$uhelp(color2)���� ���� ����������� $uhelp(color3)$counter $uhelp(color2)��[lindex {. � �� �} [numgrp $counter]].\003"
        uhelp_largetext $nick "������ ����� $uhelp(color2)$lastbind $uhelp(color3)[lrange $triglist 2 end]" 
        set uhelpdata2 [linsert $uhelpdata2 0 $counter]
        ::egglib::writedata "$uhelpname" $uhelpdata2
    } else {
            foreach line $uhelpdata {
                if { $line != "" } {
                    uhelp_largetext $nick $line
                }
            }
        putserv "privmsg $nick :$uhelp(color2)���� ���� ����������� $uhelp(color3)1 $uhelp(color2)���."
        set uhelpdata [linsert $uhelpdata 0 "1"]
        ::egglib::writedata "$uhelpname" $uhelpdata
    }
}

proc numgrp {number} { switch -glob -- "$number" { *11 {return 3} *12 {return 3} *13 {return 3} *14 {return 3} *1 {return 1} *2 {return 2} *3 {return 2} *4 {return 2} default {return 3} } }

# ��������� ������ ������� ����� � ��������� �� �� ������������ ��������.
proc uhelp_largetext {target text {lineLen 400} {delims {-.!,}}} {
     global uhelp
     regsub -all {\{} $text "" text
     regsub -all {\}} $text "" text
     if {[string length $text] <= $lineLen} { 
         putserv "PRIVMSG $target :$uhelp(color1)$text"
         return
     }
  set _text [split $text $delims]
  set x 0; set i 0
  while {$x < $lineLen} {
    if {$i >= [llength $_text]} { return }
    set wordlen [string length [lindex $_text $i]];
      if {$x + $wordlen > $lineLen} { break }
      incr x $wordlen
      incr x; incr i
      }
putserv "PRIVMSG $target :$uhelp(color1)[string range $text 0 [expr $x - 1]]"
uhelp_largetext $target [string trimleft [string range $text $x end]] $lineLen $delims
}

    # ��������� ������������� ���������.
    proc flood_init {} {
    variable flood_array
    global uhelp
      if {$uhelp(ignore) < 1} {
        return 0
      }
      if {![string match *:* $uhelp(flood)]} {
        putlog "$uhelp(version): variable flood not set correctly."
        return 1
      }
      set uhelp(flood_num) [lindex [split $uhelp(flood) :] 0]
      set uhelp(flood_time) [lindex [split $uhelp(flood) :] 1]
      set i [expr $uhelp(flood_num) - 1]
      while {$i >= 0} {
        set flood_array($i) 0
        incr i -1
      }
    }
    ; flood_init

    # ��������� ��������� � ���������� ���������� ������.
    proc flood_uhelp {nick uhost} {
    variable flood_array
    global uhelp
     if {$uhelp(ignore) < 1} {
        return 0
      }
      if {$uhelp(flood_num) == 0} {
        return 0
      }
      set i [expr $uhelp(flood_num) - 1]
      while {$i >= 1} {
        set flood_array($i) $flood_array([expr $i - 1])
        incr i -1
      }
      set flood_array(0) [unixtime]
      set aaa [expr $uhelp(flood_num) - 1]
      set bbb [expr [unixtime] - $flood_array($aaa)]
      if {$bbb <= $uhelp(flood_time) } {
        putlog "$uhelp(version): flood detected from ${nick}."
        newignore [join [maskhost *!*[string trimleft $uhost ~]]] $uhelp(version) flooding $uhelp(ignore)
        catch {unset uhelp($uhost)}
        return 1
      } else {
        return 0
      }
    }

# ������� ��������� � ���, ��� ������ ������ ��������.
putlog "\[uhelp\] $uhelp(version) by $uhelp(author) loaded"
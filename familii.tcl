###
#
#  ��������: familii.tcl
#  ������: 1.0
#  �����: username 
#
###
#
# ��������: ������ ������ ���������� ������������� ������������������ ������� �������
#           � ����� http://www.analizfamilii.ru/
#
###
#
# ���������: 
#         1. ���������� ������ familii1.0.tcl � ����� scripts ������ ����.
#         2. � ����� eggdrop.conf ������� ������ source scripts/familii1.0.tcl 
#         4. �������� .rehash ����.
#
###
#
# ������� �������:
#
#              1.0(26.11.2007) ������ ������ ������.
#
###

# ��������� ������������ ����.
namespace eval familii {}

# ���������� �������� ���� ����������.
foreach p [array names familii *] { catch {unset familii($p) } }

# ��������� ��������� ����(.chanset #chan +nopubfamilii ��� ���������� �������).
setudef flag nopubfamilii

###                            ###
# ���� �������� ���� ���� �����: #
# ______________________________ #
###                            ###

# ������� ������.
set familii(pref) "!"

# ������ ������ �� ������� ����� ���������� ������.
set familii(binds) "familia �������"

# ��������� ������ �� �������� � ������� � ����? (��-1/���-0)
set familii(msg) 1

# ������ �� ������� ����� �������� ���� ������.
set familii(channels) "#egghelp #testchan #bash.org"

# ������� ������� �� ������� ������ ������� ������ � �������� �������� �����.
set familii(flood) 5:180

# �����(���) ������.
set familii(ignore) 10

###
# ��������� ������.

# �������� ���� ������.
set familii(color1) "\00314"

# ���� �������.
set familii(color2) "\00303"

# ���� ������������� �������������.
set familii(color3) "\00310"

# ���� ������������� �������������.
set familii(color4) "\00305"
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
set familii(version) "familii.tcl version 1.0"

# ����� �������.
set familii(author) "username"

# ��������� ������.
foreach bind [split $familii(binds) " "] {
    bind pub -|- "$familii(pref)$bind" familii_pub
    if {$familii(msg) >= 1} {
        bind msg -|- "$familii(pref)$bind" familii_msg
    }
}

# ��������� ��������� ��������� ������.
proc familii_msg {nick uhost hand text} {
    global familii
    familii_proc $nick $uhost $hand $nick $text
}

# ��������� ��������� ������ ������.
proc familii_pub {nick uhost hand chan text} {
    global familii

    if {[string range $chan 0 0] == "#" && [lsearch -exact [split [string tolower $familii(channels)]] [string tolower $chan]] == -1} {
        return
    }

    # ��������� ������� �����.
    if {[channel get $chan nopubfamilii]} { 
        return 
    }
    familii_proc $nick $uhost $hand $chan $text
}

proc familii_proc {nick uhost hand chan text} {
global familii lastbind

    # �������� �� ����.
    if {[familii_flood $nick $uhost]} {
        return
    }

set text [lindex [split $text] 0]
    if {$text == ""} { 
    putserv "PRIVMSG $chan :$familii(color2)$nick$familii(color1), ���������: $familii(color2)$lastbind <�������>\003"
    return
    }
putlog "\[familii\] $text $nick/$chan"
set query "http://www.analizfamilii.ru/pham.php?pham=$text"
set id [::egglib::http_init "familii_"]
::egglib::http_get $id $query [list $nick $uhost $chan $text]
}
   
proc familii_on_error {id nick uhost chan text} {
    putserv "PRIVMSG $chan :$familii(color1)� �� ���� ����������� � $familii(color2)http://www.analizfamilii.ru $familii(color1)..."
}
   
proc familii_on_data {id data nick uhost chan text} {
global familii
regsub -all -- "\n" $data {} data
    foreach line [split $data "\n"] {
        if {[regexp -nocase -- {<p></p><I></index>(.*?)</I><BR><BR><index>} $line garb val]} {
            regsub -all -- "<FONT\ COLOR=#2f63fa>" $val "$familii(color3)" val
            regsub -all -- "<FONT\ COLOR=#ff0000>" $val "$familii(color4)" val
            regsub -all -- "," $val "$familii(color1)," val
            regsub -all -- "<B>" $val {} val
            regsub -all -- "</B>" $val {} val
            regsub -all -- "</FONT>" $val {} val
                if {$nick == $chan } {
                putserv "PRIVMSG $nick :$familii(color1)��������� ������������� ������������������ ������� ����� $familii(color2)$text$familii(color1)\: ��� ����� �������� ���������� ������������������ ���������� �� 25 ���������\: $val"
                return
                } else {
                putserv "PRIVMSG $chan :$familii(color1)��������� ������������� ������������������ ������� ����� $familii(color2)$text$familii(color1)\: ��� ����� �������� ���������� ������������������ ���������� �� 25 ���������\: $val"
                return
                }
        }
    }
putserv "PRIVMSG $chan :$familii(color1)� �� ���� ������ ���������� ������������� ������������������ ������� ����� $familii(color2)$text$familii(color1)."
}

    # ��������� ������������� ���������.
    proc flood_init {} {
    variable flood_array
    global familii
      if {$familii(ignore) < 1} {
        return 0
      }
      if {![string match *:* $familii(flood)]} {
        putlog "$familii(version): variable flood not set correctly."
        return 1
      }
      set familii(flood_num) [lindex [split $familii(flood) :] 0]
      set familii(flood_time) [lindex [split $familii(flood) :] 1]
      set i [expr $familii(flood_num) - 1]
      while {$i >= 0} {
        set flood_array($i) 0
        incr i -1
      }
    }
    ; flood_init

    # ��������� ��������� � ���������� ���������� ������.
    proc familii_flood {nick uhost} {
    variable flood_array
    global familii
     if {$familii(ignore) < 1} {
        return 0
      }
      if {$familii(flood_num) == 0} {
        return 0
      }
      set i [expr $familii(flood_num) - 1]
      while {$i >= 1} {
        set flood_array($i) $flood_array([expr $i - 1])
        incr i -1
      }
      set flood_array(0) [unixtime]
      set aaa [expr $familii(flood_num) - 1]
      set bbb [expr [unixtime] - $flood_array($aaa)]
      if {$bbb <= $familii(flood_time) } {
        putlog "$familii(version): flood detected from ${nick}."
        newignore [join [maskhost *!*[string trimleft $uhost ~]]] $familii(version) flooding $familii(ignore)
        catch {unset familii($uhost)}
        return 1
      } else {
        return 0
      }
    }

# ������� ��������� � ���, ��� ������ ������ ��������.
putlog "\[familii\] $familii(version) by $familii(author) loaded"
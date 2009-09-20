###
#
#  ��������: audio.tcl
#  ������: 1.2
#  �����: username 
#
###
#
# ��������: ������ �������� � ����� http://www.telephone.ru �������������� audio �������.
#
###
#
# ���������: 
#         1. ���������� ������ audio.tcl � ����� scripts/audio ������ ����.
#         2. � ����� eggdrop.conf ������� ������ source scripts/audio/audio.tcl 
#         4. �������� .rehash ����.
#
###
#
# ������� �������:
#
#              1.0(29.03.2007) ������ ������ ������.
#              1.1(08.06.2007) + ���������� �������� ��� ������ � ����� ���� ����� �� �����.
#              1.2(23.08.2008) + ���������� �������� ��� ������ � ����� ���� ����� �� �����.
#                              + ����� ���� ��������.
#                              + ��������� Suzi �����.
#               
###

# ��������� ������������ ����.
namespace eval audio {}

# ���������� �������� ���� ����������.
foreach p [array names audio *] { catch {unset audio($p) } }

# ��������� ��������� ����(.chanset #chan +nopubaudio ��� ���������� �������).
setudef flag nopubaudio

###                            ###
# ���� �������� ���� ���� �����: #
# ______________________________ #
###                            ###

# ������� ������.
set audio(pref) "!"

# ������ ������ �� ������� ����� ���������� ������.
set audio(binds) "audio mp3 ��3 �����"

# ��������� ������ �� �������� � ������� � ����? (��-1/���-0)
set audio(msg) 1

# ������� ������� �� ������� ������ ������� ������ � �������� �������� �����.
set audio(flood) 5:60

# �����(���) ������.
set audio(ignore) 10

###
# ��������� ������.

# �������� ���� ������.
set audio(color1) "\00314"

# ���� �����, ������� � ������������� ���������.
set audio(color2) "\00303"

# ���� ����������� ����� ������� � �������� � ������.
set audio(color3) "\00304"

# ���� ���������� �������� �������������.
set audio(color4) "\00305"
###

###                                                                  ###
# ���� ���� ����� ���������� ���, �� ��������� ��� ���� �� ������ TCL: #
# ____________________________________________________________________ #
###                                                                  ###

#������ �������.
set audio(version) "audio.tcl version 1.2"

# ���� �������.
set audio(author) "username"

# ��������� ������.
foreach bind [split $audio(binds) " "] {
bind pub -|- "$audio(pref)$bind" audio_pub
if {$audio(msg) >= 1} {
bind msg -|- "$audio(pref)$bind" audio_msg
  }
}

# ��������� ��������� ��������� ������.
proc audio_msg {nick uhost hand text} {
global tcl_platform audio
audio_proc $nick $uhost $hand $nick $text
}

# ��������� ��������� ������ ������.
proc audio_pub {nick uhost hand chan text} {
global tcl_platform audio

if {[channel get $chan nopubaudio]} { 
return 
}

audio_proc $nick $uhost $hand $chan $text
}

# ��������� ��������� �������.
proc audio_proc {nick uhost hand chan text} {
global tcl_platform audio sp_version

set audiomark [lindex $text 0]

# �������� �� ����.
if {[flood_audio $nick $uhost]} {
return
}

# ���� ����� �������� �� �������.
if {$audiomark == "" } {

set agent "Mozilla"
set audio(agent) [::http::config -useragent $agent]
set audio(url) [::http::geturl http://telephone.ru/audio/mp3.html]
set html [::http::data $audio(url)]
::http::cleanup $audio(url)

if {[info exists sp_version]} {	
    set html [encoding convertto cp1251 $html]
}

set file [open "scripts/audio/audio.txt" "w"]
  foreach line [split $html "\n"] {
      if {[regexp -- {<td><a href="/audio/mp3_g__g_1_tree_(.*?).html" class="ta12blue">(.*?)</a></td>} $line - nomer audiomark]} {
        regsub -all " " $audiomark "-" audiomark
        if {[string length $nomer] <= "5" } {
        set data "$audiomark|$nomer"
        puts $file $data
        }
      }
  }
close $file
set data [read [set file [open "scripts/audio/audio.txt" r]]]
close $file
  foreach line $data {
  set line [split $line "|"]
  lappend marklist "$audio(color2)[lindex $line 0]"
  }
set marklist [join $marklist " $audio(color3)� "]
putserv "NOTICE $nick :$audio(color1)�������� ���������� �� $audio(color2)MP3 ������� $audio(color1)��������� �����:"
audio_largetext $nick $marklist
putserv "NOTICE $nick :$audio(color1)��� ��������� ������ ������� ����������� $audio(color3)!audio $audio(color2)�����_������"
return
  }

  # ���� ����� ������ �������.
  set audio(total) [string length $text]
  set audiomodel [string range $text [expr [string length [lindex $text 0]] + 1] [expr $audio(total) - 3]]

  # ���� �� ������� ������ ������.
  if {$audiomodel == "" } {
  set data [read [set file [open "scripts/audio/audio.txt" r]]]
  close $file
  foreach lines $data {
  set line [split $lines "|"]
    if {[string tolower [lindex $line 0]] == [string tolower [lindex $text 0]]} {
      set nomer [lindex $line 1]
    }
  }

  set agent "Mozilla"
  set audio(agent) [::http::config -useragent $agent]
  set audio(url) [::http::geturl http://telephone.ru/audio/mp3_page_all_g__g_1_tree_$nomer\.html]
  set html [::http::data $audio(url)]
  ::http::cleanup $audio(url)

if {[info exists sp_version]} {	
    set html [encoding convertto cp1251 $html]
}

  set re "<a\\ href=\\\"/audio/mp3_page_all_g__g_1_tree_$nomer\\_id_(.*?).html\\\"\\ class=\\\"ta12blue\\\">(.*?)</a>"  
  set file [open "scripts/audio/$nomer.txt" w]
  foreach line [split $html "\n"] {
        if {[regexp -- $re $line - nomerr modell]} {
          regsub -all "\"" $modell "" modell
          regsub -all " " $modell "" modell
          set data "$modell|$nomerr"
          puts $file $data
        }
    }
  close $file
  
  set data [read [set file [open "scripts/audio/$nomer.txt" r]]]
  close $file
    foreach line [split $data \n] {
      set line [split $line "|"]
        if {$line==""} { continue }
      lappend modellist "$audio(color2)[lindex $line 0]"
    }
  set modellist [join $modellist " $audio(color3)� "]
  putserv "NOTICE $nick :$audio(color1)�������� ���������� �� ��������� ������� MP3 ������� ����� $audio(color2)$audiomark$audio(color1):"
  audio_largetext $nick $modellist
  putserv "NOTICE $nick :$audio(color1)��� ��������� ���������� �����������: $audio(color3)!audio $audio(color2)�����_������ $audio(color4)���������_������ $audio(color2)-����"
  putserv "NOTICE $nick :$audio(color2)�����: $audio(color3)a$audio(color1) - �������� ��������������, $audio(color3)b$audio(color1) - �������� � ��������������� ������, $audio(color3)c$audio(color1) - ������, $audio(color3)d$audio(color1) - ������� � ���������, $audio(color3)e$audio(color1) - ��������, $audio(color3)f$audio(color1) - �������� ���������, $audio(color3)g$audio(color1) - ��������� ������ � ���������, $audio(color3)h$audio(color1) - �����, $audio(color3)i$audio(color1) - ������� � ����������� � ��, $audio(color3)k$audio(color1) - �������������� �������."
  return
  } else {
      
      # ���� ������� ������ ������.
      if {[string index $text [expr $audio(total) - 2]] == "-" && [string index $text [expr $audio(total) - 3]] == " "} {
      #set audiomodel [string range $text [expr [string length [lindex $text 0]] + 1] [expr $audio(total) - 3]]
      set text [split $text " "]
      set audiomodel [lindex $text 1]
      set audiokey [string range $text [expr $audio(total) - 2] end]
      } else {
  putserv "NOTICE $nick :$audio(color1)��� ��������� ���������� �����������: $audio(color3)!audio $audio(color2)�����_������ $audio(color4)���������_������ $audio(color2)-����"
  putserv "NOTICE $nick :$audio(color2)�����: $audio(color3)a$audio(color1) - �������� ��������������, $audio(color3)b$audio(color1) - �������� � ��������������� ������, $audio(color3)c$audio(color1) - ������, $audio(color3)d$audio(color1) - ������� � ���������, $audio(color3)e$audio(color1) - ��������, $audio(color3)f$audio(color1) - �������� ���������, $audio(color3)g$audio(color1) - ��������� ������ � ���������, $audio(color3)h$audio(color1) - �����, $audio(color3)i$audio(color1) - ������� � ����������� � ��, $audio(color3)k$audio(color1) - �������������� �������."
  return 
     }
    }
  ###
  set data [read [set file [open "scripts/audio/audio.txt" r]]]
  close $file
  foreach lines $data {
  set line [split $lines "|"]
    if {[string tolower [lindex $line 0]] == [string tolower [lindex $text 0]]} {
      set nomer [lindex $line 1]
    }
  }
###
set audiokey [string range $text [expr $audio(total) - 2] end]
set result [read [set file [open "scripts/audio/$nomer.txt" r]]]
close $file
  foreach pos [split $result \n] {
  set line [split $pos "|"]
      set a $audiomodel
      set b [lindex $line 0]
      if {[string compare $a $b]} {
      set nomerrr [string tolower [lindex $line 1]]
      audioparce $nick $chan $nomer $nomerrr $audiokey $audiomark $audiomodel
      return
      }
   }
}

# ��������� �������� ����������.
proc audioparce {nick chan nomer nomerrr audiokey audiomark audiomodel} {
global audio sp_version
set agent "Mozilla"
set audio(agent) [::http::config -useragent $agent]
set audio(url) [::http::geturl http://telephone.ru/audio/mp3_g__g_1_tree_$nomer\_$nomerrr\.html]
set html [::http::data $audio(url)]
::http::cleanup $audio(url)

if {[info exists sp_version]} {	
    set html [encoding convertto cp1251 $html]
}

    set filee [open "scripts/audio/debug.txt" w]
    set data [split $html \n]
    regsub -all "	" $data "" data
    regsub -all -- {\n} $data "" data
    regsub -all -- {\ +} $data { } data
    regsub -all -- {^\ +} $data "" data
    regsub -all -- {> +<} $data {><} data
    regsub -all -- {</([^<]+)> +<} $data {</\1><} data
    regsub -all -- {<!--[^-]*-[^-]*-[^>]*>} $data "" data
    regsub -all -- {\n+} $data "\n" data
    regsub -all -- {\n$} $data "" data
    regsub -all -- {&nbsp;} $data " " data
    set data [encoding convertfrom [encoding system] $data]
    puts $filee $data
    close $filee

set html [read [set file [open "scripts/audio/debug.txt" r]]]
close $file

    if {[regexp -- {<span>(.*?)�.</span>} $html - p]} {
      set elem "$audio(color1)����: $audio(color2)\002$p\002 $audio(color1)������."
      lappend list $elem
    }

if {$audiokey == "-a"} {
putserv "NOTICE $nick :$audio(color1)audio ����� $audio(color2)$audiomark $audiomodel $audio(color4)� �������� ��������������:"
    if {[regexp -- {�������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
      set elem "$audio(color1)�������: $audio(color2)$p"
      lappend list $elem
    }
    if {[regexp -- {���:</span>.*?<b>(.*?)</b></td>} $html - p]} {
      set elem "$audio(color1)���: $audio(color2)$p"
      lappend list $elem
    }
    if {[regexp -- {�������������� �������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
      set elem "$audio(color1)�������������� �������: $audio(color2)$p"
      lappend list $elem
    }
    if {[regexp -- {����� ������ �� �������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
      set elem "$audio(color1)����� ������ �� �������: $audio(color2)$p"
      lappend list $elem
    }
    if {[regexp -- {������� ���������� �������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
      set elem "$audio(color1)������� ���������� �������: $audio(color2)$p"
      lappend list $elem
    }
    if {[regexp -- {�������� ����� ����:</span>.*?<b>(.*?)</b></td>} $html - p]} {
      set elem "$audio(color1)�������� ����� ����: $audio(color2)$p"
      lappend list $elem
    }
    if {[regexp -- {������������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
      set elem "$audio(color1)������������: $audio(color2)$p"
      lappend list $elem
    }
    if {[regexp -- {������������� ����������:</span>.*?<b>(.*?) </b></td>} $html - p]} {
      set elem "$audio(color1)������������� ����������: $audio(color2)$p"
      lappend list $elem
    }
set list [join $list " $audio(color3)� "]
regsub -all "  " $list " " list
audio_largetext $nick $list
}

if {$audiokey == "-b"} {
putserv "NOTICE $nick :$audio(color1)audio ����� $audio(color2)$audiomark $audiomodel $audio(color4)� �������� � ��������������� ������:"
    if {[regexp -- {��� ��������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)��� ��������: $audio(color2)$p"
    lappend list1 $elem
    }
    if {[regexp -- {�������������� ����� ������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)�������������� ����� ������: $audio(color2)$p"
    lappend list1 $elem
    }
    if {[regexp -- {����� ���������� ������ ��� ��������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)����� ���������� ������ ��� ��������: $audio(color2)$p"
    lappend list1 $elem
    }
    if {[regexp -- {������� ����� ������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)������� ����� ������: $audio(color2)$p"
    lappend list1 $elem
    }
    if {[regexp -- {������� ����� ������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)������� ����� ������: $audio(color2)$p"
    lappend list1 $elem
    }
    if {[regexp -- {������� ����������� ������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)������� ����������� ������: $audio(color2)$p"
    lappend list1 $elem
    }
    if {[regexp -- {��������� ������ ��������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)��������� ������ ��������: $audio(color2)$p"
    lappend list1 $elem
    }
    if {[regexp -- {�������������� ����:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)�������������� ����: $audio(color2)$p"
    lappend list1 $elem
    }
    if {[regexp -- {����������� ����� �� �������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)����������� ����� �� �������: $audio(color2)$p"
    lappend list1 $elem
    }
    if {[regexp -- {��������� ����-������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)��������� ����-������: $audio(color2)$p"
    lappend list1 $elem
    }
set list1 [join $list1 " $audio(color3)� "]
regsub -all "  " $list1 " " list1
audio_largetext $nick $list1 
}

if {$audiokey == "-c"} {
putserv "NOTICE $nick :$audio(color1)audio ����� $audio(color2)$audiomark $audiomodel $audio(color4)� ������:"
    if {[regexp -- {�������� ��������� �������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)�������� ��������� �������: $audio(color2)$p"
    lappend list2 $elem
    }
    if {[regexp -- {�������� �������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)�������� �������: $audio(color2)$p"
    lappend list2 $elem
    }
    if {[regexp -- {�������������� ������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)�������������� ������: $audio(color2)$p"
    lappend list2 $elem
    }
    if {[regexp -- {���������� ������� ���:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)���������� ������� ���: $audio(color2)$p"
    lappend list2 $elem
    }
    if {[regexp -- {��������� ��� �������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)��������� ��� �������: $audio(color2)$p"
    lappend list2 $elem
    }
    if {[regexp -- {��������� ��� ������ ������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)��������� ��� ������ ������: $audio(color2)$p"
    lappend list2 $elem
    }
set list2 [join $list2 " $audio(color3)� "]
regsub -all "  " $list2 " " list2
audio_largetext $nick $list2 
}

if {$audiokey == "-d"} {   
putserv "NOTICE $nick :$audio(color1)audio ����� $audio(color2)$audiomark $audiomodel $audio(color4)� ������� � ���������:"
    if {[regexp -- {��� �������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)��� �������: $audio(color2)$p"
    lappend list3 $elem
    }
    if {[regexp -- {���������� ������������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)���������� ������������: $audio(color2)$p"
    lappend list3 $elem
    }
    if {[regexp -- {���������� ������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)���������� ������: $audio(color2)$p"
    lappend list3 $elem
    }
    if {[regexp -- {���������� �������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)���������� �������: $audio(color2)$p"
    lappend list3 $elem
    }
    if {[regexp -- {���������� �������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)���������� �������: $audio(color2)$p"
    lappend list3 $elem
    }
    if {[regexp -- {��������� �������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)��������� �������: $audio(color2)$p"
    lappend list3 $elem
    }
set list3 [join $list3 " $audio(color3)� "]
regsub -all "  " $list3 " " list3
audio_largetext $nick $list3 
}

if {$audiokey == "-e"} {
putserv "NOTICE $nick :$audio(color1)audio ����� $audio(color2)$audiomark $audiomodel $audio(color4)� ��������:"
    if {[regexp -- {��� ��������� � ���������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)��� ��������� � ���������: $audio(color2)$p"
    lappend list4 $elem
    }
    if {[regexp -- {������ ��������� � ���������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)������ ��������� � ���������: $audio(color2)$p"
    lappend list4 $elem
    }
    if {[regexp -- {������ ��� ���������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)������ ��� ���������: $audio(color2)$p"
    lappend list4 $elem
    }
    if {[regexp -- {����������� ���������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)����������� ���������: $audio(color2)$p"
    lappend list4 $elem
    }
    if {[regexp -- {��������� ��������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)��������� ��������: $audio(color2)$p"
    lappend list4 $elem
    }
set list4 [join $list4 " $audio(color3)� "]
regsub -all "  " $list4 " " list4
audio_largetext $nick $list4 
}

if {$audiokey == "-f"} {
putserv "NOTICE $nick :$audio(color1)audio ����� $audio(color2)$audiomark $audiomodel $audio(color4)� �������� ���������:"
    if {[regexp -- {����������������� ������ �����������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)����������������� ������ �����������: $audio(color2)$p"
    lappend list5 $elem
    }
    if {[regexp -- {������ ���������������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)������ ���������������: $audio(color2)$p"
    lappend list5 $elem
    }
set list5 [join $list5 " $audio(color3)� "]
regsub -all "  " $list5 " " list5
audio_largetext $nick $list5 
}

if {$audiokey == "-g"} {    
    if {[regexp -- {������� ���������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
putserv "NOTICE $nick :$audio(color1)audio ����� $audio(color2)$audiomark $audiomodel $audio(color4)� ��������� ������ � ���������:"
    set elem "$audio(color1)������� ���������: $audio(color2)$p"
    lappend list6 $elem
    } else {
putserv "NOTICE $nick :$audio(color1)audio ����� $audio(color2)$audiomark $audiomodel $audio(color4)� ����������� ������ � �������� � ������ ������ �����������."
    }
    if {[regexp -- {������������ ����� ������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)������������ ����� ������: $audio(color2)$p"
    lappend list6 $elem
    }
    if {[regexp -- {������ ������ ����� ������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)������ ������ ����� ������: $audio(color2)$p"
    lappend list6 $elem
    }
    if {[regexp -- {��������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)��������: $audio(color2)$p"
    lappend list6 $elem
    }
    if {[regexp -- {������������ ��������� ������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)������������ ��������� ������: $audio(color2)$p"
    lappend list6 $elem
    }
    if {[regexp -- {������ � �����:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)������ � �����: $audio(color2)$p"
    lappend list6 $elem
    }
    if {[regexp -- {������ � ��������� �����:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)������ � ��������� �����: $audio(color2)$p"
    lappend list6 $elem
set list6 [join $list6 " $audio(color3)� "]
regsub -all "  " $list6 " " list6
audio_largetext $nick $list6 

    }
}

if {$audiokey == "-h"} {
putserv "NOTICE $nick :$audio(color1)audio ����� $audio(color2)$audiomark $audiomodel $audio(color4)� �����:"
    if {[regexp -- {���������� �����:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)���������� �����: $audio(color2)$p"
    lappend list7 $elem
    }
    if {[regexp -- {������ ������������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)������ ������������: $audio(color2)$p"
    lappend list7 $elem
    }
    if {[regexp -- {��������� RDS:</span></a>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)��������� RDS: $audio(color2)$p"
    lappend list7 $elem
    }
set list7 [join $list7 " $audio(color3)� "]
regsub -all "  " $list7 " " list7
audio_largetext $nick $list7 
}

if {$audiokey == "-i"} {
putserv "NOTICE $nick :$audio(color1)audio ����� $audio(color2)$audiomark $audiomodel $audio(color4)� ������� � ����������� � ��:"
    if {[regexp -- {�������� ����:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)�������� ����: $audio(color2)$p"
    lappend list8 $elem
    }
    if {[regexp -- {�������� �����:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)�������� �����: $audio(color2)$p"
    lappend list8 $elem
    }
    if {[regexp -- {����������� � ��:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)����������� � ��: $audio(color2)$p"
    lappend list8 $elem
    }
    if {[regexp -- {����� �������� �����:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)����� �������� �����: $audio(color2)$p"
    lappend list8 $elem
    }
    if {[regexp -- {������� USB-storage:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)������� USB-storage: $audio(color2)$p"
    lappend list8 $elem
    }
    if {[regexp -- {��������������� ���������� ��������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)��������������� ���������� ��������: $audio(color2)$p"
    lappend list8 $elem
    }
set list8 [join $list8 " $audio(color3)� "]
regsub -all "  " $list8 " " list8
audio_largetext $nick $list8 
}

if {$audiokey == "-k"} {
putserv "NOTICE $nick :$audio(color1)audio ����� $audio(color2)$audiomark $audiomodel $audio(color4)� �������������� �������:"
    if {[regexp -- {���������� �������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)���������� �������: $audio(color2)$p"
    lappend list9 $elem
    }
    if {[regexp -- {����:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)����: $audio(color2)$p"
    lappend list9 $elem
    }
    if {[regexp -- {���������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)���������: $audio(color2)$p"
    lappend list9 $elem
    }
    if {[regexp -- {���������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)���������: $audio(color2)$p"
    lappend list9 $elem
    }
    if {[regexp -- {�������� ������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)�������� ������: $audio(color2)$p"
    lappend list9 $elem
    }
    if {[regexp -- {������ ����������:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)������ ����������: $audio(color2)$p"
    lappend list9 $elem
    }
    if {[regexp -- {����� ��:</span>.*?<b>(.*?)</b></td>} $html - p]} {
    set elem "$audio(color1)����� ��: $audio(color2)$p"
    lappend list9 $elem
    }
set list9 [join $list9 " $audio(color3)� "]
regsub -all "  " $list9 " " list9
audio_largetext $nick $list9 
}
}

# ��������� ������ ������� ����� � ��������� �� �� ������������ ��������.
proc audio_largetext {target text {lineLen 400} {delims {�.!?}}} {
     global audio
     regsub -all {\{} $text "" text
     regsub -all {\}} $text "" text
     if {[string length $text] <= $lineLen} { 
     putserv "NOTICE $target :$text"
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
putserv "NOTICE $target :[string range $text 0 [expr $x - 1]]"
audio_largetext $target [string trimleft [string range $text $x end]] $lineLen $delims
}

    # ��������� ������������� ���������.
    proc flood_init {} {
    variable flood_array
    global audio
      if {$audio(ignore) < 1} {
        return 0
      }
      if {![string match *:* $audio(flood)]} {
        putlog "$audio(version): variable flood not set correctly."
        return 1
      }
      set audio(flood_num) [lindex [split $audio(flood) :] 0]
      set audio(flood_time) [lindex [split $audio(flood) :] 1]
      set i [expr $audio(flood_num) - 1]
      while {$i >= 0} {
        set flood_array($i) 0
        incr i -1
      }
    }
    ; flood_init

    # ��������� ��������� � ���������� ���������� ������.
    proc flood_audio {nick uhost} {
    variable flood_array
    global audio
     if {$audio(ignore) < 1} {
        return 0
      }
      if {$audio(flood_num) == 0} {
        return 0
      }
      set i [expr $audio(flood_num) - 1]
      while {$i >= 1} {
        set flood_array($i) $flood_array([expr $i - 1])
        incr i -1
      }
      set flood_array(0) [unixtime]
      set aaa [expr $audio(flood_num) - 1]
      set bbb [expr [unixtime] - $flood_array($aaa)]
      if {$bbb <= $audio(flood_time) } {
        putlog "$audio(version): flood detected from ${nick}."
        newignore [join [maskhost *!*[string trimleft $uhost ~]]] $audio(version) flooding $audio(ignore)
        catch {unset audio($uhost)}
        return 1
      } else {
        return 0
      }
    }

# ������� ��������� � ���, ��� ������ ������ ��������.
putlog "\[audio\] $audio(version) by $audio(author) loaded"
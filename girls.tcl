###
#
#  ��������: girls.tcl
#  ������: 1.0
#  �����: username 
#
###
#
# ��������: ������ �������� � ����� http://x-love.ru/ ������ �����������.
#           �������� ����� �� ����� ���������� ��� ������ �����, ����, �������, ���� �����.
#
###
#
# ���������: 
#         1. ��� ������ ������� ��������� ����� http.tcl
#         2. ���������� ������ girls1.0.tcl � ����� scripts ������ ����.
#         3. � ����� eggdrop.conf _�����_ �������� http.tcl ������� 
#            ������ source scripts/girls1.0.tcl 
#         4. �������� .rehash ����.
#
###
#
# ������� �������:
#
#              1.0(28.02.2008) ������ ������.
#
###

# ��������� ������������ ����.
namespace eval girls {}

# ���������� �������� ���� ����������.
foreach p [array names girls *] { catch {unset girls($p) } }

# ��������� ��������� ����(.chanset #chan +nopubgirls ��� ���������� �������).
setudef flag nopubgirls

###                            ###
# ���� �������� ���� ���� �����: #
# ______________________________ #
###                            ###

# ������� ������.
set girls(pref) "!"

# ������ ������ �� ������� ����� ���������� ������.
set girls(binds) "������� girls �������"

# ��������� ������ �� �������� � ������� � ����? (��-1/���-0)
set girls(msg) 1

# ������� ������ �� ������� ������ ������� ������ � �������� �������� �����.
set girls(flood) 6:60

# �����(���) ������.
set girls(ignore) 3

# ������� ����� ������� ���������� � ����������� ������ � �� ������� ��� ����������.
set girls(count) 5

###
# ��������� ������.

# ���� ����� ������.
set girls(color1) "\00303"

# ���� ��������� ������.
set girls(color2) "\00305"

# ���� ����� �������.
set girls(color3) "\00310"

# ���� �������� �������.
set girls(color4) "\00304"
###

###                                                                  ###
# ���� ���� ����� ���������� ���, �� ��������� ��� ���� �� ������ TCL: #
# ____________________________________________________________________ #
###                                                                  ###

# ������ �������.
set girls(version) "girls.tcl version 1.0"

# ����� �������.
set girls(author) "username"

# ��������� ������.
foreach bind [split $girls(binds) " "] {
bind pub -|- "$girls(pref)$bind" girls_pub
if {$girls(msg) >= 1} {
bind msg -|- "$girls(pref)$bind" girls_msg
  }
}

# ��������� ��������� ��������� ������.
proc girls_msg {nick uhost hand text} {
global girls
girls_proc "PRIVMSG" $nick $uhost $hand $nick $text
}

# ��������� ��������� ������ ������.
proc girls_pub {nick uhost hand chan text} {
global girls

# ��������� ������� �����.
if {[channel get $chan nopubgirls]} { 
return 
}
girls_proc "NOTICE" $nick $uhost $hand $nick $text
}

# ��������� ��������� �������.
proc girls_proc {method nick uhost hand chan text} {
global girls lastbind
variable url

# �������� �� ����.
if {[flood_girls $nick $uhost]} {
return
}

putlog "$nick/$chan $lastbind"

set text [girls_tolower $text]

if {$text == "" } {

girls_parser "$method" "$chan" "http://pda.x-love.ru/index.php?city=&metro=&bust_from=&bust_to=&age_from=&age_to=&height_from=&height_to=&price_from=&price_to="

} elseif {[isnumber $text]} {

set agent "Mozilla"
set girls(agent) [::http::config -useragent $agent]
set girls(url) [::http::geturl "http://pda.x-love.ru/details.php?id=$text" -timeout 25000]
set html [::http::data $girls(url)]
::http::cleanup $girls(url)

regsub -all -nocase -- {\n} $html "" html
regsub -all -nocase -- {</td>} $html "" html
regsub -all -nocase -- {</tr>} $html "" html
regsub -all -nocase -- {</span>} $html "" html
regsub -all -nocase -- {</table>} $html "" html
regsub -all -nocase -- {</th>} $html "" html
regsub -all -nocase -- {<span.*?>} $html "" html
regsub -all -nocase -- {&nbsp} $html " " html
regsub -all -nocase -- {<th>} $html "" html
regsub -all -nocase -- {<br>} $html "" html
regsub -all -nocase -- {<b>} $html "" html
regsub -all -nocase -- {<td>} $html "" html
regsub -all -nocase -- {<tr>} $html "" html
regsub -all -nocase -- {<!--MAIN-->} $html "" html
regsub -all -nocase -- {</BODY>} $html "" html
regsub -all -nocase -- {</HTML>} $html "" html
regsub -all -nocase -- {<table.*?>} $html "" html
regsub -all -nocase -- {<td.*?>} $html "" html
regsub -all -nocase -- {<img.*?>} $html "" html
regsub -all -nocase -- {<p.*?>} $html "" html
regsub -all -nocase -- {<a.*?>.*?</a>} $html "" html
regsub -all -nocase -- {<h3.*?>.*?</a>} $html "" html
regsub -all -nocase -- {  } $html " " html
regsub -all -nocase -- {<col align=center>} $html "\n" html
    if {$html == ""} {
        putquick "$method $chan :$girls(color1)������� � ID $girls(color2)$text $girls(color1)�� ����������."
        return 
    }
    foreach line [split $html "\n"] {
        if {[regexp -nocase -- {<font color=#FFFF00>.*?</font> <font color=#FFFF00>(.*?)</font>�������:(.*?) ����:(.*?) ���:(.*?) ����:(.*?) ������:(.*?) �����:(.*?) �����:(.*?)�����1 ���:(.*?) 2 ����:(.*?) ����:(.*?) �����������1 ���:(.*?) 2 ����:(.*?) ����:(.*?) �������:(.*?)<I>������:<FONT color= #FFFFFF>(.*?)</FONT></I>(.*?)</P>} $line garb name age height weight boobs size city metro v1hour v2hour vnight a1hour a2hour anight phone uslugi descr]} {
            putquick "$method $chan :$girls(color1)���: $girls(color2)$name"
            putquick "$method $chan :$girls(color1)�������: $girls(color2)$age"
            putquick "$method $chan :$girls(color1)����: $girls(color2)$height"
            putquick "$method $chan :$girls(color1)���: $girls(color2)$weight"
            putquick "$method $chan :$girls(color1)����: $girls(color2)$boobs"
            putquick "$method $chan :$girls(color1)������: $girls(color2)$size"
            putquick "$method $chan :$girls(color1)�����: $girls(color2)$city$girls(color1), �����: $girls(color2)$metro"
            putquick "$method $chan :$girls(color1)����� ���: $girls(color2)$v1hour$girls(color1), 2 ����: $girls(color2)$v2hour$girls(color1), ����: $girls(color2)$vnight"
                if {[regexp -nocase -- {(.*?)���.\ ������(.*?)\ ;�} $anight garb anight2 dopusl]} {
                    putquick "$method $chan :$girls(color1)����������� ���: $girls(color2)$a1hour$girls(color1), 2 ����: $girls(color2)$a2hour$girls(color1), ����: $girls(color2)$anight2"
                    putquick "$method $chan :$girls(color1)�������������� ������: $girls(color2)$dopusl $girls(color1)�"
                } else {
                    putquick "$method $chan :$girls(color1)����������� ���: $girls(color2)$a1hour$girls(color1), 2 ����: $girls(color2)$a2hour$girls(color1), ����: $girls(color2)$anight"
                }
            regsub -all -nocase -- {�����.} $uslugi {�������} uslugi
            putquick "$method $chan :$girls(color1)�������: $girls(color2)$phone"
            girls_largetext $method $chan "$girls(color1)������: $girls(color3)$uslugi" $girls(color3)
            girls_largetext $method $chan "$girls(color1)� �������: $girls(color4)$descr" $girls(color4)
            putquick "$method $chan :$girls(color1)������ �� ���� �������: \037\00312http://x-love.ru/details.php?id=$text\037"
        }
    }
    return
} elseif {[string match "-*" $text]} {

set key [lindex [split $text] 0]
set min [lindex [split $text] 1]
set max [lindex [split $text] 2]

switch -exact -- "$key" {
"-�����" {
putquick "$method $chan :$girls(color1)���� ������ ������� ������ $girls(color2)$min$girls(color1)."
girls_parser "$method" "$chan" "http://pda.x-love.ru/index.php?city=$min&metro=&bust_from=&bust_to=&age_from=&age_to=&height_from=&height_to=&price_from=&price_to="
}
"-�����" {
putquick "$method $chan :$girls(color1)���� ������ ������� �������� �� ����� $girls(color2)$min$girls(color1)."
girls_parser "$method" "$chan" "http://pda.x-love.ru/index.php?city=&metro=$min&bust_from=&bust_to=&age_from=&age_to=&height_from=&height_to=&price_from=&price_to="
}
"-����" {
if {$max != ""} {
putquick "$method $chan :$girls(color1)���� ������ ������� � ������ �� $girls(color2)$min $girls(color1)�� $girls(color2)$max $girls(color1)�������."
girls_parser "$method" "$chan" "http://pda.x-love.ru/index.php?city=&metro=&bust_from=$min&bust_to=$max&age_from=&age_to=&height_from=&height_to=&price_from=&price_to="
} else {
putquick "$method $chan :$girls(color1)���� ������ ������� � ������ $girls(color2)$min $girls(color1)�������."
girls_parser "$method" "$chan" "http://pda.x-love.ru/index.php?city=&metro=&bust_from=$min&bust_to=$max&age_from=&age_to=&height_from=&height_to=&price_from=&price_to="
}
}
"-�������" {
if {$max != ""} {
putquick "$method $chan :$girls(color1)���� ������ ������� � �������� �� $girls(color2)$min $girls(color1) �� $girls(color2)$max $girls(color1)���."
girls_parser "$method" "$chan" "http://pda.x-love.ru/index.php?city=&metro=&bust_from=&bust_to=&age_from=$min&age_to=$max&height_from=&height_to=&price_from=&price_to="
} else {
putquick "$method $chan :$girls(color1)���� ������ ������� � �������� �� $girls(color2)$min $girls(color1)���."
girls_parser "$method" "$chan" "http://pda.x-love.ru/index.php?city=&metro=&bust_from=&bust_to=&age_from=$min&age_to=$max&height_from=&height_to=&price_from=&price_to="
}
}
"-����" {
if {$max != ""} {
putquick "$method $chan :$girls(color1)���� ������ ������� ������ �� $girls(color2)$min $girls(color1) �� $girls(color2)$max $girls(color1)��."
girls_parser "$method" "$chan" "http://pda.x-love.ru/index.php?city=&metro=&bust_from=&bust_to=&age_from=&age_to=&height_from=$min&height_to=$max&price_from=&price_to="
} else {
putquick "$method $chan :$girls(color1)���� ������ ������� ������ �� $girls(color2)$min $girls(color1)��."
girls_parser "$method" "$chan" "http://pda.x-love.ru/index.php?city=&metro=&bust_from=&bust_to=&age_from=&age_to=&height_from=$min&height_to=$max&price_from=&price_to="
}
}
"-����" {
if {$max != ""} {
putquick "$method $chan :$girls(color1)���� ������ ������� � ����� �� ������ �� $girls(color2)\$/���.$min $girls(color1)�� $girls(color2)\$/���.$max$girls(color1)."
girls_parser "$method" "$chan" "http://pda.x-love.ru/index.php?city=&metro=&bust_from=&bust_to=&age_from=&age_to=&height_from=&height_to=&price_from=$min&price_to=$max"
} else {
putquick "$method $chan :$girls(color1)���� ������ ������� � ����� �� ������ �� $girls(color2)$min $girls(color1)���."
girls_parser "$method" "$chan" "http://pda.x-love.ru/index.php?city=&metro=&bust_from=&bust_to=&age_from=&age_to=&height_from=&height_to=&price_from=$min&price_to=$max"
}
}
default {
putquick "$method $chan :$girls(color1)������ ������ ������: $girls(color2)-����� -����� -���� -������� -���� -����"
}
}

}

#proc end
}

# ��������� ������� �������� � ��������.
proc girls_parser {method dest url} {
global girls
global lastbind
variable count

set agent "Mozilla"
set girls(agent) [::http::config -useragent $agent]
set girls(url) [::http::geturl "$url" -timeout 25000]
set html [::http::data $girls(url)]
::http::cleanup $girls(url)

regsub -all -nocase -- {\n} $html "" html
regsub -all -nocase -- {</td><td height=25>} $html "</td><td height=25>|%\n" html
regsub -all -nocase -- {<table.*?>} $html "" html
regsub -all -nocase -- {<td.*?>} $html "" html
regsub -all -nocase -- {<img.*?>} $html "" html
regsub -all -nocase -- {<tr>} $html "" html
regsub -all -nocase -- {<span.*?>} $html "" html
regsub -all -nocase -- {</table>} $html "" html
regsub -all -nocase -- {</td>} $html "" html
regsub -all -nocase -- {</tr>} $html "" html
regsub -all -nocase -- {</span>} $html " " html
regsub -all -nocase -- {&nbsp;} $html "" html
regsub -all -nocase -- {\[.*?\]} $html "" html
regsub -all -nocase -- {</a>} $html "" html
regsub -all -nocase -- {  } $html " " html
regsub -all -nocase -- {<br> <br>} $html "\n" html
set count 0
	foreach line [split $html "\n"] {
    if {[string match "*���������� �������������� ������ �����.*" $line]} {
        putquick "$method $dest :$girls(color1)�� ������ ������� ������ �� �������. ���������� �������������� ������ �����."
        return 0
    }
      if {[regexp -nocase -- {(.*?)���: (.*?)����: (.*?) ���: (.*?)����: (.*?) �����: (.*?) �����: (.*?) �����:1 ���: (.*?) 2 ����: (.*?) ����: (.*?) �����������:1 ���: (.*?) 2 ����: (.*?) ����: (.*?)  �������: (.*?)%} $line garb name age height weight boobs city metro v1hour v2hour vnight a1hour a2hour anight phone]} {
          if {[regexp -nocase -- {<a\ href=\/details.php\?id=(.*?)\ target=_blank><a\ href=\/details.php\?id=(.*?)\ class=index1\ target=_blank>(.*?)\ ����} $name garb id id2 name]} {
          }
              set regz "<a\\ href=\\/details.php\\?id=$id\\ class=index1\\ target=_blank>(.*?)\\|"
              if {[regexp -nocase -- $regz $phone garb phone]} {
              }
              putquick "$method $dest :$girls(color1)��������� ������ \002�$girls(color2)[expr $count +1]$girls(color1)\002, ID: $girls(color2)$id"
              putquick "$method $dest :$girls(color1)���: $girls(color2)$name$girls(color1), �������: $girls(color2)$age$girls(color1), ����: $girls(color2)$height$girls(color1), ���: $girls(color2)$weight$girls(color1), ����: $girls(color2)$boobs$girls(color1), �����: $girls(color2)$city$girls(color1), �����: $girls(color2)$metro$girls(color1)."
             #putquick "$method $dest :$girls(color1)�����: ���: $girls(color2)$v1hour$girls(color1), 2 ����: $girls(color2)$v2hour$girls(color1), ����: $girls(color2)$vnight$girls(color1), �����������: ���: $girls(color2)$a1hour$girls(color1), 2 ����: $girls(color2)$a2hour$girls(color1), ����: $girls(color2)$anight$girls(color1), �������: $girls(color2)$phone$girls(color1)."
              putquick "$method $dest :$girls(color1)��� ��������� ��������� ������ ������� ���� $girls(color2)$lastbind $id$girls(color1)."
                  incr count
                      if {$count == $girls(count)} {return 0}
	       } 
      }
return
}


proc girls_largetext {method target text color {lineLen 200} {delims {,.}}} {
     global bor girls
     regsub -all {\{} $text "" text
     regsub -all {\}} $text "" text
     if {[string length $text] <= $lineLen} { 
         putserv "$method $target :$color$text"
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
putserv "$method $target :$color[string range $text 0 [expr $x - 1]]"
girls_largetext $method $target [string trimleft [string range $text $x end]] $color $lineLen $delims
}

    # ��������� ������������� ���������.
    proc flood_init {} {
    variable flood_array
    global girls
      if {$girls(ignore) < 1} {
        return 0
      }
      if {![string match *:* $girls(flood)]} {
        putlog "$girls(version): variable flood not set correctly."
        return 1
      }
      set girls(flood_num) [lindex [split $girls(flood) :] 0]
      set girls(flood_time) [lindex [split $girls(flood) :] 1]
      set i [expr $girls(flood_num) - 1]
      while {$i >= 0} {
        set flood_array($i) 0
        incr i -1
      }
    }
    ; flood_init

    # ��������� ��������� � ���������� ���������� ������.
    proc flood_girls {nick uhost} {
    variable flood_array
    global girls
     if {$girls(ignore) < 1} {
        return 0
      }
      if {$girls(flood_num) == 0} {
        return 0
      }
      set i [expr $girls(flood_num) - 1]
      while {$i >= 1} {
        set flood_array($i) $flood_array([expr $i - 1])
        incr i -1
      }
      set flood_array(0) [unixtime]
      set aaa [expr $girls(flood_num) - 1]
      set bbb [expr [unixtime] - $flood_array($aaa)]
      if {$bbb <= $girls(flood_time) } {
        putlog "$girls(version): flood detected from ${nick}."
        putquick "NOTICE $nick :$girls(color1)� ��������� ��� ������� ����� �������� ����� $girls(color2)$girls(ignore) $girls(color1)�����."
        newignore [join [maskhost *!*[string trimleft $uhost ~]]] $girls(version) flooding $girls(ignore)
        catch {unset girls($uhost)}
        return 1
      } else {
        return 0
      }
    }

# ��������� �������� ������ � ������ �������.
proc girls_tolower {text} {
	return [string map {� � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � � �} [string tolower $text]]
}

# ������� ��������� � ���, ��� ������ ������ ��������.
putlog "\[girls\] $girls(version) by $girls(author) loaded"
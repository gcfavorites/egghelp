# IMDb query v1.10
# Copyright (C) 2007-2008 perpleXa
# http://perplexa.ugug.org / #perpleXa on QuakeNet
#
# Redistribution, with or without modification, are permitted provided
# that redistributions retain the above copyright notice, this condition
# and the following disclaimer.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY, to the extent permitted by law; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.
#
# Usage:
#  !imdb <movie name>

package require http 2.7; # TCL 8.5

namespace eval imdb {
  variable version "1.11";

  # flood protection (seconds)
  variable antiflood "10";
  # character encoding
  variable encoding "utf-8";
  # user agent
  variable agent "Mozilla/5.0 (X11; U; Linux i686; en-GB; rv:1.8.1) Gecko/2006101023 Firefox/2.0";

  # internal
  bind pub -|- "!imdb" [namespace current]::public;
  variable flood;
  namespace export *;
}

proc imdb::public {nick host hand chan argv} {
  variable flood; variable antiflood;
  if {![info exists flood($chan)]} { set flood($chan) 0; }
  if {[unixtime] - $flood($chan) <= $antiflood} { return 0; }
  set flood($chan) [unixtime];

  set argv [string trim $argv];
  if {$argv == ""} {
    puthelp "NOTICE $nick :Usage: $::lastbind movie";
    return 0;
  }

  set id [id $argv];
  if {$id == ""} {
    chanmsg $chan "Movie not found: $argv";
    return 0;
  }

  set info [getinfo $id];
  if {![llength $info]} {
    chanmsg $chan "Couldn't get information for movie id $id.";
    return 0;
  }

  for {set i 0} {$i < [llength $info]} {incr i} {
    set info [lreplace $info $i $i [decode [lindex $info $i]]];
  }

  set name     [lindex $info 0];  set year    [lindex $info 1];
  set genre    [lindex $info 2];  set tagline [lindex $info 3];
  set plot     [lindex $info 4];  set rating  [lindex $info 5];
  set votes    [lindex $info 6];  set runtime [lindex $info 7];
  set language [lindex $info 8];

  if {$name == ""} {
    chanmsg $chan "Couldn't get information for movie id $id.";
    return 0;
  }

  chanmsg $chan "\002$name\002 ($year) (http://imdb.com/title/$id/) \002Genre:\002 $genre \002Runtime:\002 $runtime \002Language:\002 $language \002Rating:\002 [bar $rating] $rating/10 ($votes votes)";
  chanmsg $chan "\002Tagline:\002 $tagline \002Plot:\002 $plot";
}

proc imdb::bar {float} {
  set stars [format "%1.0f" $float];
  return "\00312\[\00307[string repeat "*" $stars]\00314[string repeat "-" [expr 10-$stars]]\00312\]\003";
}

proc imdb::chanmsg {chan text} {
  if {[validchan $chan]} {
    if {[string first "c" [lindex [split [getchanmode $chan]] 0]] >= 0} {
      regsub -all {(?:\002|\003([0-9]{1,2}(,[0-9]{1,2})?)?|\017|\026|\037)} $text "" text;
    }
  }
  putquick "PRIVMSG $chan :$text";
}

proc imdb::id {movie} {
  variable agent;
  http::config -useragent $agent;
  if {[catch {http::geturl "http://www.imdb.com/find?q=[urlencode $movie];s=tt;site=aka" -timeout 20000} token]} {
    return;
  }
  set data [http::data $token];
  set code [http::ncode $token];
  set meta [http::meta $token];
  http::cleanup $token;
  if {$code == 200} {
    set id "";
    regsub -nocase -- {^.*<b>Titles \(Exact Matches\)</b>} $data "" data;
    regexp -nocase -- {<a href="/title/(tt[0-9]+)/"} $data -> id;
    return $id;
  } else {
    foreach {var val} $meta {
      if {![string compare -nocase "Location" $var]} {
        regexp -nocase {tt\d+} $val val;
        return $val;
      }
    }
  }
}

proc imdb::getinfo {id} {
  variable agent;
  http::config -useragent $agent;
  if {[catch {http::geturl "http://www.imdb.com/title/$id/" -timeout 20000} token]} {
    return;
  }
  set data [http::data $token];
  regsub -all -- {\r\n} $data "\n" data;
  http::cleanup $token;

  set name ""; set year ""; set genre ""; set tagline ""; set plot "";
  set rating 0; set votes ""; set runtime ""; set language "";
  regexp -nocase -- {<div id="tn15title">\n<h1>([^<]+)<span>\(<a href="/Sections/Years/\d+">(\d+)</a>} $data -> name year;
  foreach {null gen} [regexp -all -nocase -inline -- {<a href="/Sections/Genres/([a-z]+?)/">} $data] {
    lappend genre $gen;
  }
  foreach {null lang} [regexp -all -nocase -inline -- {<a href="/Sections/Languages/.*?/">(.*?)</a>} $data] {
    lappend language [string trim $lang];
  }
  regexp -nocase -- {<h5>Tagline:</h5>([^<]+)} $data -> tagline;
  regexp -nocase -- {<h5>Plot:</h5>(.+?)</div>(.*)} $data -> plot;
  regsub -all "<a.*?>.*?</a>" $plot "" plot;
  regexp -nocase -- {<b>([0-9.]+?)/10</b>[\n\s]+<small>\(<a href="ratings">([0-9,]+?) votes</a>\)} $data -> rating votes;
  regexp -nocase -- {<h5>Runtime:</h5>([^<]+)} $data -> runtime;

  return [list [string trim $name] $year [join $genre "/"] [string trim $tagline] [string trim $plot "\r\n\t| "] $rating $votes [string trim $runtime] [join $language "/"]];
}

proc imdb::urlencode {i} {
  variable encoding
  set index 0;
  set i [encoding convertto $encoding $i]
  set length [string length $i]
  set n ""
  while {$index < $length} {
    set activechar [string index $i $index]
    incr index 1
    if {![regexp {^[a-zA-Z0-9]$} $activechar]} {
      append n %[format "%02X" [scan $activechar %c]]
    } else {
      append n $activechar
    }
  }
  return $n
}

proc imdb::decode {content} {
  if {$content == ""} {
    return "n/a";
  }
  if {![string match *&* $content]} {
    return $content;
  }
  set escapes {
    &nbsp; \x20 &quot; \x22 &amp; \x26 &apos; \x27 &ndash; \x2D
    &lt; \x3C &gt; \x3E &tilde; \x7E &euro; \x80 &iexcl; \xA1
    &cent; \xA2 &pound; \xA3 &curren; \xA4 &yen; \xA5 &brvbar; \xA6
    &sect; \xA7 &uml; \xA8 &copy; \xA9 &ordf; \xAA &laquo; \xAB
    &not; \xAC &shy; \xAD &reg; \xAE &hibar; \xAF &deg; \xB0
    &plusmn; \xB1 &sup2; \xB2 &sup3; \xB3 &acute; \xB4 &micro; \xB5
    &para; \xB6 &middot; \xB7 &cedil; \xB8 &sup1; \xB9 &ordm; \xBA
    &raquo; \xBB &frac14; \xBC &frac12; \xBD &frac34; \xBE &iquest; \xBF
    &Agrave; \xC0 &Aacute; \xC1 &Acirc; \xC2 &Atilde; \xC3 &Auml; \xC4
    &Aring; \xC5 &AElig; \xC6 &Ccedil; \xC7 &Egrave; \xC8 &Eacute; \xC9
    &Ecirc; \xCA &Euml; \xCB &Igrave; \xCC &Iacute; \xCD &Icirc; \xCE
    &Iuml; \xCF &ETH; \xD0 &Ntilde; \xD1 &Ograve; \xD2 &Oacute; \xD3
    &Ocirc; \xD4 &Otilde; \xD5 &Ouml; \xD6 &times; \xD7 &Oslash; \xD8
    &Ugrave; \xD9 &Uacute; \xDA &Ucirc; \xDB &Uuml; \xDC &Yacute; \xDD
    &THORN; \xDE &szlig; \xDF &agrave; \xE0 &aacute; \xE1 &acirc; \xE2
    &atilde; \xE3 &auml; \xE4 &aring; \xE5 &aelig; \xE6 &ccedil; \xE7
    &egrave; \xE8 &eacute; \xE9 &ecirc; \xEA &euml; \xEB &igrave; \xEC
    &iacute; \xED &icirc; \xEE &iuml; \xEF &eth; \xF0 &ntilde; \xF1
    &ograve; \xF2 &oacute; \xF3 &ocirc; \xF4 &otilde; \xF5 &ouml; \xF6
    &divide; \xF7 &oslash; \xF8 &ugrave; \xF9 &uacute; \xFA &ucirc; \xFB
    &uuml; \xFC &yacute; \xFD &thorn; \xFE &yuml; \xFF
  };
  set content [string map $escapes $content];
  set content [string map [list "\]" "\\\]" "\[" "\\\[" "\$" "\\\$" "\\" "\\\\"] $content];
  regsub -all -- {&#([[:digit:]]{1,5});} $content {[format %c [string trimleft "\1" "0"]]} content;
  regsub -all -- {&#x([[:xdigit:]]{1,4});} $content {[format %c [scan "\1" %x]]} content;
  regsub -all -- {&#?[[:alnum:]]{2,7};} $content "?" content;
  return [subst $content];
}

putlog "Script loaded: IMDb query v$imdb::version by perpleXa"

# average.tcl (C) perpleXa 2005
# just type *average to receive some channel statistics.

namespace eval average {
  variable version "2.13";
  variable dbase "scripts/dbase/average";
  bind pub  m|m "*average"   [namespace current]::pubtrigger;
  bind time -|- "* * * * *"  [namespace current]::expression;
  bind evnt -|- "save"       [namespace current]::savedb;
}

proc average::pubtrigger {nick host hand chan args} {
  set text [lindex $args 0];
  if {[llength [clean $text]] < 1} {
    set channel $chan;
  } else {
    set channel [lindex [clean $text] 0];
  }
  if {![validchan $channel]} {
    putquick "PRIVMSG $chan :Channel $channel is unknown.";
    return;
  }
  set data [getchaninfo [string tolower $channel]];
  set lasthour [lindex $data 0]; set today [lindex $data 1]; set yesterday [lindex $data 2];
  set sevenday [lindex $data 3]; set fourteenday [lindex $data 4];
  set lasthoura [lindex [split $lasthour] 0]
  set todaya [lindex [split $today] 0]; set todaym [lindex [split $today] 1];
  set yesterdaya [lindex [split $yesterday] 0]; set yesterdaym [lindex [split $yesterday] 1];
  set sevendaya [lindex [split $sevenday] 0]; set sevendaym [lindex [split $sevenday] 1];
  set fourteendaya [lindex [split $fourteenday] 0]; set fourteendaym [lindex [split $fourteenday] 1];

  putquick [format "PRIVMSG %s :Statistics for channel %s:" $chan $channel];
  putquick [format "PRIVMSG %s :  Last hour     : %6.1f average users" $chan $lasthoura];
  putquick [format "PRIVMSG %s :  Today so far  : %6.1f average users, %4d max" $chan $todaya $todaym];
  putquick [format "PRIVMSG %s :  Yesterday     : %6.1f average users, %4d max" $chan $yesterdaya $yesterdaym];
  putquick [format "PRIVMSG %s :  7-day average : %6.1f average users, %4d max" $chan $sevendaya $sevendaym];
  putquick [format "PRIVMSG %s :  14-day average: %6.1f average users, %4d max" $chan $fourteendaya $fourteendaym];
}

proc average::getchaninfo {chan} {
  variable data;
  set houra 0; set todaya 0; set yesterdaya 0; set sevendaya 0; set fourteendaya 0;
  set todaym 0; set yesterdaym 0; set sevendaym 0; set fourteendaym 0;
  set time [clock seconds];
  set todayts [clock scan [strftime "%m/%d/%Y" $time]];
  set yesterdayts [clock scan [strftime "%m/%d/%Y" [expr $time-86400]]];
  foreach {item value} [array get data [string tolower $chan],*] {
    set timestamp [lindex [split $item ,] 1];
    if {[expr $time - $timestamp] <= 3600} {
      # last hour
      incr houra $value;
    }
    if {$timestamp >= $todayts} {
      # today
      incr todaya $value;
      if {$value > $todaym} {set todaym $value;}
    }
    if {($timestamp >= $yesterdayts) && ($timestamp < $todayts)} {
      # yesterday
      incr yesterdaya $value;
      if {$value > $yesterdaym} {set yesterdaym $value;}
    }
    if {[expr $time - $timestamp] <= 604800} {
      # 7 days
      incr sevendaya $value;
      if {$value > $sevendaym} {set sevendaym $value;}
    }
    if {[expr $time - $timestamp] <= 1209600} {
      # 14 days
      incr fourteendaya $value;
      if {$value > $fourteendaym} {set fourteendaym $value;}
    }
  }
  set houra [expr $houra/60.0];
  set todaya [expr $todaya/(($time-$todayts)/60.0)];
  set yesterdaya [expr $yesterdaya/1440.0];
  set sevendaya [expr $sevendaya/10080.0];
  set fourteendaya [expr $fourteendaya/20160.0];
  return [list $houra "$todaya $todaym" \
  "$yesterdaya $yesterdaym" "$sevendaya $sevendaym" "$fourteendaya $fourteendaym"];
}

proc average::expression {args} {
  variable data;
  set time [clock seconds];
  foreach chan [channels] {
    set data([string tolower $chan],$time) [users $chan];
  }
}

proc average::users {chan} {
  set users 0; set clones 0;
  foreach user [chanlist $chan] {
    if {[string length $user] == 1} {
      continue;
    }
    set host [lindex [split [getchanhost $user] @] 1];
    incr users;
    if {![info exists fakeuser($host)]} {
      set fakeuser($host) $user;
    } else {
      lappend fakeuser($host) $user;
      incr clones 1;
    }
  }
  return [expr $users - $clones];
}

proc average::clean {i} {
  return [regsub -all -- {([\(\)\[\]\{\}\$\"\\])} $i {\\\1}];
}

proc average::loaddb {args} {
  variable dbase; variable data;
  if {![file exists $dbase]} {return 0;}
  set fp [open $dbase r+];
  while {![eof $fp]} {
    gets $fp line;
    if {[regexp -- {^([^\s]+)\s(\d+)\s(\d+)$} $line -> chan timestamp udata]} {
      set data($chan,$timestamp) $udata;
    }
  }
  close $fp;
  return;
}

proc average::savedb {args} {
  variable dbase; variable data;
  if {![file isdirectory [file dirname $dbase]]} {
    file mkdir [file dirname $dbase];
  }
  set fp [open $dbase w+];
  foreach item [array names data] {
    set chan [lindex [split $item ,] 0];
    set timestamp [lindex [split $item ,] 1];
    set time [clock seconds];
    if {[expr $time - $timestamp] < 1209600} {
      if {[validchan $chan]} {
        puts $fp "$chan $timestamp $data($item)";
      } else {
        unset data($item);
      }
    } else {
      unset data($item);
    }
  }
  close $fp;
  return;
}

proc average::version {args} {
  variable file [lindex [split [info script] "/"] end];
  variable version;
  variable modified [clock format [file mtime [info script]] -format "%Y/%m/%d %H:%M:%S"];
  variable owner "perpleXa";
  putlog "\$Id: $file,v $version $modified $owner Exp \$";
}

average::loaddb;
average::version;
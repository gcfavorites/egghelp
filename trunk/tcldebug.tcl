bind pub n "!tcl" tcldebug:tcl
proc tcldebug:tcl {nick host hand chan args} {
  set args [lindex $args 0]
  putcmdlog "!tcl: $nick $host $hand $chan $args"
  if { [string match {*exec*} $args] && [string match {* rm*} $args] && ![matchattr $hand +n|- $chan] } { putserv "PRIVMSG $chan :exec rm not allow"; putlog "exec rm not allow $args"; return 0; }
  if { [string match {*exec*} $args] && ( [string match {*var/log*} $args] || [string match {*sbin*} $args] || [string match {*etc*} $args] ) && ![matchattr $hand +n|- $chan]} { putlog "exec not allow $args"; return 0; }
  if { ( [string match {*global*} $args] || [string match {*file*} $args] || [string match {*open*} $args] || [string match {*dcc*} $args] || [string match {*add*} $args] || [string match {*user*} $args] || [string match {*chhand*} $args] || [string match {*chattr*} $args] || [string match {*botattr*} $args] ) && ![matchattr $hand +n|- $chan]} { putlog "global/add/user/file/open/dcc/chhand/chattr/botattr not allow in $args"; return 0; }
  #if { [string match *die* $args] || [string match *kill* $args] } { putserv "PRIVMSG $chan :die/kill not allow"; putlog "die not allow $args"; return 0; }
  if { ( [string match {*rehash*} $args] || [string match {*restart*} $args] || [string match {*quit*} $args] ) && ![matchattr $hand +n|- $chan] } { putlog "rehash/restart/quit not allow $args"; return 0; }
  set start [clock clicks]
  set errnum [catch {eval $args} error]
  set end [clock clicks]
  if {$error==""} {set error "<empty string>"}
  	switch -- $errnum {
  		0 {if {$error=="<empty string>"} {set error "OK"} {set error "OK: $error"}}
  		2 {set error "Return: $error"}
  		1 {set error "Error: $error"}
  		default {set error "$errnum: $error"}
  	}
  set error "$error - [expr ($end-$start)/1000.0] ms"
  set error [split $error "\n"]
  foreach line $error { putserv "PRIVMSG $chan :$line" }
  
}
bind pub n "!exec" tcldebug:exec
proc tcldebug:exec {nick host hand chan args} {
  set args "exec [lindex $args 0]"
  set errnum [catch {eval $args} error]
  if {$error==""} {set error "<$errnum>"}
  if {$errnum!=0} {set error "$errnum - $error"}
  set error [split $error "\n"]
  foreach erro $error { putserv "PRIVMSG $chan :$erro" }
}

bind pub n "!error" tcldebug:error
proc tcldebug:error {nick host hand chan args} {
  foreach line [split $::errorInfo \n] {
    puthelp "PRIVMSG $chan :$line"
  }
}
putlog "tcldebug loaded, (c) never - sometime updated by c*bex :)"

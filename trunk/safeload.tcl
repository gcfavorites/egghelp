      set lflags "n"
  	set lscriptsdir "scripts"
  	set ltrigger "!"
  	
  	bind pub $lflags ${ltrigger}load load:file
  	
  	
  	proc load:file {nick host hand chan text} {
  	    global lscriptsdir  ltrigger
 	    set file [lindex [split $text] 0]
  	    if {$file == ""} {
  	        putserv "PRIVMSG $nick :-(Load)- ${ltrigger}load <scriptname.tcl> -(Info)-"
 	        return 0
          } elseif {![file exists [file join $lscriptsdir $file]]} {
  	        putserv "PRIVMSG $nick :-(Load)- Sorry $file doesn`t exists -(Info)-"
 	        return 0
 	    } else {
 	        set kbsize [expr {[file size [file join $lscriptsdir/$file]] / 1024.0}]
 	        if {[catch {uplevel "source [file join $lscriptsdir $file]"} error]} {
 	            putserv "PRIVMSG $nick :-(Load)- Script: $file Size: $kbsize Kb Status: Error -(Info)-"
 	            putserv "PRIVMSG $nick :-(Load)- $error -(Info)-"
 	        } else {
 	            putserv "PRIVMSG $nick :-(Load)- Script: $file - Size: $kbsize Kb - Status: OK -(Info)-"
 	        }
  	    }
  	}
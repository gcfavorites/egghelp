proc putfast {text} {
append text "\n" 
putdccraw 0 [string length $text] $text 
}
if {[info commands "putserv_original"]=="putserv_original"} {
rename putserv "" 
rename putserv_original putserv 
}
rename putserv putserv_original
proc putserv { text {mode ""}} { 
putfast $text 
}
if {[info commands "puthelp_original"]=="puthelp_original"} {
rename puthelp "" 
rename puthelp_original puthelp 
}
rename puthelp puthelp_original
proc puthelp { text {mode ""}} { 
putfast $text
}
if {[info commands "putquick_original"]=="putquick_original"} {
rename putquick ""
rename putquick_original putquick
}
rename putquick putquick_original
proc putquick { text {mode ""}} {
putfast $text 
}
putlog "Quick.tcl initialized."
 

#####################################################################################
#
#		:::[  T h e   R u s s i a n   E g g d r o p  R e s o u r c e  ]::: 
#      ____                __                                                      
#     / __/___ _ ___ _ ___/ /____ ___   ___      ___   ____ ___ _     ____ __ __   
#    / _/ / _ `// _ `// _  // __// _ \ / _ \    / _ \ / __// _ `/    / __// // /   
#   /___/ \_, / \_, / \_,_//_/   \___// .__/ __ \___//_/   \_, / __ /_/   \___/    
#        /___/ /___/                 /_/    /_/           /___/ /_/                
#
#
#####################################################################################
#
# horolove.tcl 0.2
#
# ��������:
# ������ ���������� �������� ��������
# 
# ���������: �������� ������ � ����� scripts
# � eggdrop.conf ��������� source scripts/horolove.tcl
#
# Authors: hunt <hunt@eggshell.ru>
#
# Official support: irc.eggdrop.org.ru @ #eggdrop
# 
#####################################################################################


#
# UAFS support & some namespace optimizations by CoolCold
# \|/ http://forum.eggdrop.org.ru powered \|/
#

   if { ![info exists egglib(ver)] } {
   putlog "***********************************************"
   putlog "             egglib_pub NOT FOUND !"
   putlog "   Download last version of egglib_pub here:"
   putlog "  http://eggdrop.org.ru/scripts/egglib_pub.zip"
   putlog "***********************************************"    
   die
   }

   if { [expr {$egglib(ver) < 1.53}] } {
   putlog "***********************************************"
   putlog " YOUR VERSION OF egglib_pub IS TOO OLD !"
   putlog "   Download last version of egglib_pub here:"
   putlog "  http://eggdrop.org.ru/scripts/egglib_pub.zip"
   putlog "***********************************************"
   putlog " version installed : $egglib(ver)"
   putlog " version required: 1.5.3"
   die


}
######################################################
foreach p [array names horolove *] { catch {unset horolove($p) } }
namespace eval horolove {
    
    set floodlimit "1:300"
    set nolimitflags "f|f"

    #��������� - �������� �� uafs,���������� ��� ��� tcl ����������
    #"�������" ��������� - �� ���� �� ��������� ��� ���������,� �� ������.
    #����� �������, ���� ���������� ::uafs::numver �� ����������, ��������
    #�� �������� �� ����� �����������.
    if {[info exists "::uafs::numver"] && $::uafs::numver>="000010"} {
            #��������,������������ ��� handler
            #� ����������� -  ����������� �� floodlimit
            #��� ��������� - #masks(host) - ����� ���� *!*@hostname
            #������������ ������������� � ������� �� $ignoreflags
            set ufh [::uafs::registerhandle $floodlimit $::uafs::masks(all) $nolimitflags "" "1" "horolove"]
            if {$ufh>0} {
                    ;#����������� ������ �������,������ �������
                    ;#bind pub $accessflags "$trigger" [namespace current]::trigger
                    bind pub - !horolove ::horolove::love
                    bind pub - !�������� ::horolove::love

            } else {
                    #� ������ ������ ������� ��������� � ��� � ����� ������ � ���������
                    putlog "registerhandle failed. error code \"$ufh\",error info: \"[::uafs::formatmessage $ufh]\""
            }
            
    } else {
            putlog "--------------------------------------------------"
            putlog "| No UAFS.tcl installed or too old version found |"
            putlog "| Install UAFS.tcl first and load it before      |"
            putlog "| loading this script!                           |"
            putlog "| Download latest version of uafs here:          |"
            putlog "| http://eggdrop.org.ru/scripts/uafs_beta10.zip  |"
            putlog "--------------------------------------------------"
            putlog "$infoline version $ver by $author load failed"
            die "UAFS not found or version is too old"
    }
    bind evnt -|- prerehash [namespace current]::deInit

}

setudef flag nopubhorolove

#####################################################
################# Copyrights ########################
#####################################################

set horolove(authors) "hunt @ RusNet <hunt@eggshell.ru>"
set horolove(version) "0.2"

#####################################################
  proc ::horolove::love {nick uhost hand chan text} {
  global horolove, lastbind
  variable ufh
  if {[channel get $chan nopubhorolove]} { return }
        #������ �������� �� ����
        set flooded [::uafs::isflood $ufh $nick $uhost $chan]
        if {$flooded=="1"} {
        	putlog "flood from $nick!$uhost with $lastbind, ignored"
        	putserv "NOTICE $nick :$nick �������, � ��������� ��� ������� \"$lastbind\" ����� ������������ ����� [::egglib::rus_duration [duration [::uafs::peacetime $ufh $nick $uhost $chan]]]"
        	return 0
        } elseif {$flooded!="0"} {
        	putlog "error while checking isflood, error code \"$flooded\", description:[::uafs::formatmessage $counter]"
        	return 0
        }

  set text [lindex $text 0]
  set horo [::egglib::tolower $text]
  if {$text == ""} { ::egglib::outhc $nick $chan "!horolove" "����|�����|��������|���|���|����|����|��������|�������|�������|�������|����"
  return
  }
  if {[string match "*����*" $horo]} {set h "aries"}
  if {[string match "*�����*" $horo]} {set h "taurus"}
  if {[string match "*�������*" $horo]} {set h "gemini"}
  if {[string match "*���*" $horo]} {set h "cancer"}
  if {[string match "*���*" $horo]} {set h "leo"}
  if {[string match "*����*" $horo]} {set h "virgo"}
  if {[string match "*����*" $horo]} {set h "libra"}
  if {[string match "*��������*" $horo]} {set h "scorpio"}
  if {[string match "*�������*" $horo]} {set h "sagittarius"}
  if {[string match "*�������*" $horo]} {set h "capricorn"}
  if {[string match "*�������*" $horo]} {set h "aquarius"}
  if {[string match "*����*" $horo]} {set h "pisces"}
  if {![info exists h]} { ::egglib::outhc $nick $chan "!horolove" "����|�����|��������|���|���|����|����|��������|�������|�������|�������|����"
  return
  }
  set query "http://www.horo.ru/lov/tom/$h.html"
  set id [::egglib::http_init "::horolove::"]
  ::egglib::http_get $id $query [list $nick $hand $uhost $chan $horo]
   }
   
   proc ::horolove::on_error {id nick uhost chan} {
      ::egglib::out $nick $chan "� �� ���� ����������� � horo.ru.. -.-"
   }
   proc ::horolove::on_data {id data nick hand uhost chan horo} {
   regsub -all -- \n $data {} data
   regsub -all -- {<!--[^-]*-[^-]*-[^>]*>} $data "<>" data
   regsub -all -- {<h2>*[^>]*</h2>} $data "" data
   regsub -all -- {\ +} $data { } data
   regsub -all -- {^\ +} $data "" data
   regsub -all -- {> +<} $data {><} data
   regsub -all -- {</([^<]+)> +<} $data {</\1><} data
   foreach item [split $data \n] {
   if { [regexp -- {<div class="int-text">(.*?)</div>} $item g horolove]} {
   set horolove [::egglib::unhtml $horolove]
   if {![channel get $chan usecolors]} {
   ::egglib::out $nick $chan "�������� �������� ���\002 $horo \002- $horolove"
   } else {
   ::egglib::out $nick $chan "\00314�������� �������� ��� \002\0034$horo\002 - \00310$horolove\003"
   return
   }
   }
   ::egglib::out $chan $nick "� �� ���� �������� ��� \002$horo\002"
}
}

proc ::horolove::deInit {args} {
    catch {unbind evnt -|- prerehash [namespace current]::deInit}
    set tbinds [llength [binds "[namespace current]::*"]]
    foreach bind [binds "[namespace current]::*"] {
        catch {unbind [lindex $bind 0] [lindex $bind 1] [lindex $bind 2] [lindex $bind 4]}
    }
    namespace delete [namespace current]
}

::egglib::srcloadlog "Horolove" "$horolove(version)" "$horolove(authors)"
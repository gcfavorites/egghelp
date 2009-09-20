#####################################################################################
#
#	:::[  T h e   R u s s i a n   E g g d r o p  R e s o u r c e  ]:::
#				 ___                 _
#				| __| __ _  __ _  __| | _ _  ___  _ __
#				| _| / _` |/ _` |/ _` || '_|/ _ \| '_ \
#				|___|\__, |\__, |\__,_||_|  \___/| .__/
#				     |___/ |___/                 |_|
#
#####################################################################################
#
# Скрипт позволяет записывать новости для канала.
#
# Команды в канале:
# !addnews <новость> - добавляет строку в конец списка новостей;
# !delnews <номер новости> - удаляет соответствующую новость;
# !insnews <номер новости> <новость> - вставляет на соответствующую позицию новую новость;
# !clearnews - очистить все новости для данного канала;
# !news, !новость, !новости - показать текущие новости.
#
# Команды в патилайне:
# .chanset #chan [+|-]channews - включить/выключить показ новостей по команде !news.
#
# Новости хранятся в папке data/news/ (она должна существовать!) корневого каталога бота.
# Файлы новостей сохраняются в виде файла "#канал.news" (к примеру, #yourchan.news).
#
# Автор оригинального скрипта: Deniska #eggdrop @RusNet http://forum.eggdrop.org.ru
# Дополнения, исправления, улучшения: Adium #eggdrop @RusNet
#
###################################################################################
#	08.03.2008
#	v1.5 Edit by adium
#	- Изменена архитектура скрипта, теперь он в едином пространстве имен;
#	- Добавлена поддержка DEBUG-режима;
#	- Обновлена строка вывода новостей;
#	- Убрана зависимость от egglib_pub.tcl;
####
#	09.02.2008
#	v1.4 Edit by aduim
#	- Функция [::egglib::tolower $variable] убрана из скрипта как нерациональная;
#	- Введено использование [string is space $variable];
#	- Изменены части процедур с целью сокращения времени реакции скрипта;
#	- Исправлены ошибки в процедуре ::channews::delnews;
#	- Добавлено цветовое оформление;
#	- Добавлено вырецание цветовых кодов из добавляемых новостей;
#	- Изменена строка вывода новостей;
#	- Изменена структура удаления новостей, теперь идет удаление по номеру новости в файле,
#	  а все последующие строки за счет сдвига перезаписываются с обновленным индексом новости;
####
#	08.11.2007
#	v1.3 Edit by adium
#	- Исправлена ошибка с обрезанием фраз, добавляемых новостей;
#	- Добавлена возможность выбора префикса команд;
#	- Переписан код получения даты создания новости, теперь
#	  используется функция [ctime [unixtime]];
#	- Добавлены переменные со сведениями об авторе скрипта и версии;
###################################################################################

namespace eval channews {

	variable prefix			{!}
	variable flags			{mno|mno}
	variable author			{Deniska@RusNet}
	variable fixed			{adium@RusNet}
	variable version		{1.5}
	variable date			{08-MAY-2008}
	variable unamespace		[string range [namespace current] 2 end]
	# only for debug! DON'T CHANGE!
	variable debug			0
	# Путь к файлам с новостями. ВНИМАНИЕ! Путь должен существовать!
	variable datapath		{data/news/}

	bind pub	$flags	${prefix}addnews		::channews::addnews
	bind pub	$flags	${prefix}delnews		::channews::delnews
	bind pub	$flags	${prefix}insnews		::channews::insnews
	bind pub	$flags	${prefix}joinnews		::channews::onoff
	bind pub	$flags	${prefix}clearnews		::channews::clearnews
	bind pub	-		${prefix}news			::channews::shownews
	bind pub	-		${prefix}новости		::channews::shownews
	bind pub	-		${prefix}новость		::channews::shownews

	setudef flag			channews

# --------------------------------------------------
# ---------------- add new news --------------------
# --------------------------------------------------
	proc addnews {nick uhost hand chan text} {
		if {![channel get $chan channews]} {
			variable debug
			if {$debug} {
				return -code error "$nick!$uhost \($hand\) \[$chan\] trying to ADD news, but channel $chan doesn\'t supported!"
			}
			return 0
		}
		set text [stripcodes cubr [string range [join $text] 0 end]]
		if {[string is space $text]} {
			variable prefix
			putserv "NOTICE $nick :\00314Используйте: \00304${prefix}addnews \00314<\00304новость\00314>"
			return 0
		}
		set chan [string tolower $chan]
		variable datapath
		if {![file exists "$datapath/$chan.news"]} {
			set file [open "$datapath/$chan.news" w+]
			close $file
		}
		set news [readdata "$datapath/$chan.news"]
		set ourdate [datestamp]
		if {[string is space $news]} {
			set num 0
		} else {
			foreach p $news {
				set num [lindex [stripcodes cubr $p] 0]
			}
		}
		incr num
		lappend news "$num $ourdate $nick $text"
		variable debug
		if {$debug} {
			return -code error "$nick!$uhost \($hand\) \[$chan\] ADD news \'$text\'"
		}
		writedata "$datapath/$chan.news" $news
		putserv "NOTICE $nick :\00314Новость #$num добавлена.\003"
		return 0
	}

# --------------------------------------------------
# ---------------- del new news --------------------
# --------------------------------------------------

	proc delnews {nick uhost hand chan text} {
		if {![channel get $chan channews]} {
			variable debug
			if {$debug} {
				return -code error "$nick!$uhost \($hand\) \[$chan\] trying to DEL news, but channel $chan doesn\'t supported!"
			}
			return 0
		}
		variable datapath
		set news [readdata "$datapath/$chan.news"]
		if {[string is space $news]} {
			putserv "NOTICE $nick :\00314Для данного канала нет новостей.\003"
			variable debug
			if {$debug} {
				return -code error "$nick!$uhost \($hand\) \[$chan\] trying to DEL news, but data-file is empty!"
			}
			return 0
		}
		set text [stripcodes cubr [string range [join $text] 0 end]]
		if {[string is space $text] || ![regexp -- {^\d+$} $text]} {
			variable prefix
			putserv "NOTICE $nick :\00314Используйте: \00304${prefix}delnews\00314 <\00304номер новости\00314>\003"
			variable debug
			if {$debug} {
				return -code error "$nick!$uhost \($hand\) \[$chan\] trying to DEL news - syntax error \'$text\'!"
			}
			return 0
		}
		set chan [string tolower $chan]
		if {![file exists "$datapath/$chan.news"]} {
			variable debug
			if {$debug} {
				return -code error "File '$datapath/$chan.news' doesn't exists. Create it..."
			}
			set file [open "$datapath/$chan.news" w+]
			close $file
		}
		if {[expr $text < 0] || $text > [llength $news]} {
			putserv "NOTICE $nick :\00314В списке только \00304[llength $news]\00314 новост[end [llength $news]].\003"
			variable debug
			if {$debug} {
				return -code error "$nick!$uhost \($hand\) \[$chan\] trying to DEL undefined news \'$text\'!"
			}
			return 0
		}
		set news [lreplace $news [expr $text - 1] [expr $text - 1]]
		writedata "$datapath/$chan.news" $news
		variable debug
		if {$debug} {
			return -code error "$nick!$uhost \($hand\) \[$chan\] DELeted news #$text."
		}
		set news [readdata "$datapath/$chan.news"]
		set i 0
		foreach t $news {
			incr i
			if {[lindex $t 0] > $text} {
				set line "[expr [lindex $t 0] - 1] [lindex $t 1] [lindex $t 2] [lindex $t 3] [lindex $t 4] [lrange $t 5 end]"
				set news [lreplace $news [expr $i - 1] [expr $i - 1] $line]
				writedata "$datapath/$chan.news" $news
				variable debug
				if {$debug} {
					return -code error "File \'$datapath/$chan.news\' successfully updated (renumbered all news indexes)."
				}
			}
		}
		putserv "NOTICE $nick :\00314Новость #$text удалена.\003"
	}

# --------------------------------------------------
# --------------- insert new news ------------------
# --------------------------------------------------
	proc insnews {nick uhost hand chan text} {
		if {![channel get $chan channews]} {
			variable debug
			if {$debug} {
				return -code error "$nick!$uhost \($hand\) \[$chan\] trying to INSERT new news, but channel $chan doesn\'t supported."
			}
			return 0
		}
		set text [stripcodes cubr [string range [join $text] 0 end]]
		if {[string is space $text]} {
			variable prefix
			putserv "NOTICE $nick :\00314Используйте: \00304${prefix}insnews\00314 <\00304номер новости\00314> <\00304новость\00314>\003"
			variable debug
			if {$debug} {
				return -code error "$nick!$uhost \($hand\) \[$chan\] trying to INSERT news, but string is space - syntax error."
			}
			return 0
		}
		set position [lindex $text 0]
		if {![regexp -- {^\d+$} $position]} {
			variable prefix
			putserv "NOTICE $nick :\00314Используйте:\00304 ${prefix}insnews\00314 <\00304номер новости\00314> <\00304новость\00314>\003"
			variable debug
			if {$debug} {
				return -code error "$nick!$uhost \($hand\) \[$chan\] trying to INSERT news, but string index is wrong - syntax error."
			}
			return 0
		}
		set arg [lrange $text 1 end]
	
		if {[string is space $arg]} {
			variable prefix
			putserv "NOTICE $nick :\00314Используйте:\00304 ${prefix}insnews\00314 <\00304номер новости\00314> <\00304новость\00314>\003"
			variable debug
			if {$debug} {
				return -code error "$nick!$uhost \($hand\) \[$chan\] trying to INSERT news, but news string is space - syntax error."
			}
			return 0
		}
		set chan [string tolower $chan]
		variable datapath
		if {![file exists "$datapath/$chan.news"]} {
			variable debug
			if {$debug} {
				return -code error "File '$datapath/$chan.news' doesn't exists. Create it..."
			}
			set file [open "$datapath/$chan.news" w+]
			close $file
		}
		set news [readdata "$datapath/$chan.news"]
		
		if {[expr $position <= 0]} {
			putserv "NOTICE $nick :\00314Позиции новостей должна начинаться с \003041\00314.\003"
			variable debug
			if {$debug} {
				return -code error "$nick!$uhost \($hand\) \[$chan\] trying to INSERT news, but string index is wrong - syntax error."
			}
			return 0
		}
		if {$position > [llength $news]} {
			putserv "NOTICE $nick :\00314В списке только \00304[llength $news]\00314 новостей.\003"
			variable debug
			if {$debug} {
				return -code error "$nick!$uhost \($hand\) \[$chan\] trying to INSERT news, but string index is wrong - syntax error."
			}
			return 0
		}
		set ourdate [datestamp]
		if {[string is space $news]} {
			set num 0
		} else {
			foreach p $news {
				set num [lindex [stripcodes cbr $p] 0]
			}
		}
		incr num
		set news [linsert $news [expr $position - 1] "$num $ourdate $nick $text"]
		variable debug
		if {$debug} {
			return -code error "$nick!$uhost \($hand\) \[$chan\] INSERT new news with string index \'$position\'."
		}
		writedata "$datapath/$chan.news" $news
		variable debug
		if {$debug} {
			return -code error "File \'$datapath/$chan.news\' successfully updated (inserted new news)."
		}
		putserv "NOTICE $nick :\00314Новость добавлена - #$position.\003"
	}
	
# --------------------------------------------------
# ------------------ show news ---------------------
# --------------------------------------------------
	proc shownews {nick uhost hand chan text} {
		if {![channel get $chan channews]} { return 0 }
		set chan [string tolower $chan]
		variable datapath
		if {![file exists "$datapath/$chan.news"]} {
			set file [open "$datapath/$chan.news" w+]
			close $file
		}
		set news [readdata "$datapath/$chan.news"]
		if {[string is space $news]} { 
			putserv "NOTICE $nick :\00314На сегодня новостей нет.\003"
			return 0
		}
		set newscount [llength $news]
		foreach line $news {
			putserv "NOTICE $nick :\00310Новость \[\00305[lindex $line 0]\00310\/$newscount\]: \00314[lrange $line 5 end] \00307(\00303[lindex $line 4]\00314; \00305[lindex $line 1].[lindex $line 2].[lindex $line 3]\00307)\003"
		}
		return 0
	}

# --------------------------------------------------
# --------------- clear all news -------------------
# --------------------------------------------------
	proc clearnews {nick uhost hand chan text} {
		if {![channel get $chan channews]} {
			variable debug
			if {$debug} {
				return -code error "$nick!$uhost \($hand\) \[$chan\] trying to CLEAR all news, but channel $chan doesn\'t supported."
			}
			return 0
		}
		variable datapath
		set data [readdata "$datapath/$chan.news"]
		if {[string is space $data]} {
			putserv "NOTICE $nick :\00314В базе нет ни одной новости.\003"
			variable debug
			if {$debug} {
				return -code error "File \'$datapath/$chan.news\' is empty."
			}
			return 0
		}
		writedata "$datapath/$chan.news" ""
		variable debug
		if {$debug} {
			return -code error "$nick!$uhost \($hand\) \[$chan\] CLEAR all news."
		}
		putserv "NOTICE $nick :\00314Все новости удалены.\003"
	}

# --------------------------------------------------
# ------------- special functions ------------------
# --------------------------------------------------
	proc readdata {file} {
		if {![file exists $file]} {
			return ""
		} else {
			if {[catch {set fileio [open $file r]} r]} {return $r}
			set lines [list]
			while {![eof $fileio]} {
				set line [gets $fileio]
				if {![string is space $line]} { lappend lines $line }
			}
			close $fileio
			return $lines
		}
	}
	
	proc writedata {file data} {
		if {[catch {set fileio [open $file w]} r]} {return $r}
		foreach line $data {
			puts $fileio $line
		}
		flush $fileio
		close $fileio
	}

	proc datestamp {} {
		set ourdate [ctime [unixtime]]
		set od_m [list]
		if {[string match "*Jan*" "$ourdate"]} {set od_m "01"} 
		if {[string match "*Feb*" "$ourdate"]} {set od_m "02"} 
		if {[string match "*Mar*" "$ourdate"]} {set od_m "03"} 
		if {[string match "*Apr*" "$ourdate"]} {set od_m "04"} 
		if {[string match "*May*" "$ourdate"]} {set od_m "05"} 
		if {[string match "*Jun*" "$ourdate"]} {set od_m "06"} 
		if {[string match "*Jul*" "$ourdate"]} {set od_m "07"} 
		if {[string match "*Aug*" "$ourdate"]} {set od_m "08"} 
		if {[string match "*Sep*" "$ourdate"]} {set od_m "09"} 
		if {[string match "*Oct*" "$ourdate"]} {set od_m "10"} 
		if {[string match "*Nov*" "$ourdate"]} {set od_m "11"} 
		if {[string match "*Dec*" "$ourdate"]} {set od_m "12"}
		set od_d [lindex $ourdate 2]
		set od_y [lindex $ourdate 4]
		return "$od_d $od_m $od_y"
	}
	proc end {t} {
		switch -- [string index $t end] { 1 {return "ь"} 2-3-4 { return "и" } default { return "ей" } }
	}

	putlog "[namespace current]:: v$version \[$date\] by $author & $fixed successfully loaded."
}
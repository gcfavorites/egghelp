#####################################################################################################
## housenum.tcl
##
## Описание: Мистики считают, что жизнь человека во многом определяется числами, которые его
## окружают. Это серия паспорта, год и день рождения, количество букв в имени фамилии...
## А недавно выяснилось, что жизнь наша еще зависит и от цифр, которыми обозначены дом и квартира,
## где мы живем.
##
## Установка: скопировать скрипт в папку scripts вашего бота. Пропишите в eggdrop.conf строчку
## source scripts/housenum.tcl
## * Требует egglib_pub.tcl
##
## Информация взята из газеты ИНТЕРЕС.
##---------------------------------------------------------------------------------------------------
## Автор: xamyt <xamyt@aviel.ru>
## WeNet @ #eggdrop
#####################################################################################################

# На каком канале работать.
set housenum_chans "#chan"

# Режим работы. (notice\chan\msg)
set housenum_mode "chan"

# Максимально допустимое количество символов в строке.
set housenum_maxstr 450

bind pub - !дом housenum:dom
bind pub - !dom housenum:dom

proc housenum:bigstr {housenum_chan housenum_tell housenum_nick} {
global housenum_maxstr housenum_mode
if {$housenum_mode == "msg"} {set housenum_out "privmsg $housenum_nick"}
if {$housenum_mode == "chan"} {set housenum_out "privmsg $housenum_chan"}
if {$housenum_mode == "notice"} {set housenum_out "notice $housenum_nick"}
if {!($housenum_mode == "msg") && !($housenum_mode == "chan") && !($housenum_mode == "notice")} {return}
while {[string length $housenum_tell] > 0} {
if {[string length $housenum_tell] <= $housenum_maxstr || [llength [split $housenum_tell]] == 1} {putserv "$housenum_out :\00310$housenum_tell" ; break}
set msg ""
set newtext ""
set str "0"
set txt [split $housenum_tell " "]
foreach word $txt {
if {[expr [string length $msg] + [string length $word]] <= $housenum_maxstr} {
if {$str != "1"} {
set msg [concat $msg $word]
} else {set newtext [concat $newtext $word]}
} else {
set str "1"
set newtext [concat $newtext $word]
}
}
if {$msg != ""} {putserv "$housenum_out :\00310$msg"}
set housenum_tell $newtext
}
}

proc housenum:dom {nick host hand chan text} {
global housenum_chan housenum_chans housenum_tell housenum_nick
if {![string match *$chan* $housenum_chans]} {putquick "notice $nick :На этом канале запрещено." ; return}
if {($text == "") || !([string match "*;*" $text])} {putquick "notice $nick :\00310Введите адрес вашего дома, например, такой адрес\00302 дом 27, корп. 2, кв. 348 \00310надо будет ввести как\00304 !дом 27;2;348" ; return}
if {([string index $text 0]==";") || ([string index $text end]==";") || ([string match "*;;*" $text])} {putquick "notice $nick :\00310Вы ввели \00304неверные\00310 данные." ; return}
set text [::egglib::tolower $text]
set allow "1234567890аибтвкглдменожпзр;"
set kol [string length $text]
set i 0
while {$i<$kol} {
if {![string match *[string index $text $i]* $allow]} {putquick "notice $nick :\00310Вы ввели \00304неверные\00310 данные." ; return}
incr i
}
regsub -nocase -all {а} $text {1} text
regsub -nocase -all {и} $text {1} text
regsub -nocase -all {б} $text {2} text
regsub -nocase -all {т} $text {2} text
regsub -nocase -all {в} $text {3} text
regsub -nocase -all {к} $text {3} text
regsub -nocase -all {г} $text {4} text
regsub -nocase -all {л} $text {4} text
regsub -nocase -all {д} $text {5} text
regsub -nocase -all {м} $text {5} text
regsub -nocase -all {е} $text {6} text
regsub -nocase -all {н} $text {6} text
regsub -nocase -all {о} $text {7} text
regsub -nocase -all {ж} $text {8} text
regsub -nocase -all {п} $text {8} text
regsub -nocase -all {з} $text {9} text
regsub -nocase -all {р} $text {9} text
set text [split $text ";"]
set kol [llength $text]
set i 0
set z 0
while {$i<$kol} {
set z [expr $z+[lindex $text $i]]
incr i
}
if {[string length $z]==1} {set z1 $z}
while {[string length $z]>1} {
set z [split $z ""]
set kol [llength $z]
set i 0
set z1 0
while {$i<$kol} {
set z1 [expr $z1+[lindex $z $i]]
incr i
}
set z $z1
}
switch $z1 {
1 {set housenum_chan $chan ; set housenum_nick $nick ; set housenum_tell "\002\00304$nick\,\00310\002 ваше число\002\00302 ЕДИНИЦА.\00310\002 Такая цифра подходит для человека, который хочет открыть частное предприятие. Живущие в \"доме Единицы\" хорошо учатся на своем опыте, а не на опыте других. Он хорошо подходит для тех, кто хочет жить в соответствии со своими наклонностями, независимо от всех. В доме этого человека всегда чисто. Если ваша работа связана с заботой о других или вы занимаете видное место в жизни (директор, глава фирмы), то вам надо жить в \"доме Единицы\". В нем вы будете чувствовать себя уверенно. Но он не подходит к людям, склонным к одиночеству." ; housenum:bigstr $housenum_chan $housenum_tell $housenum_nick}
2 {set housenum_chan $chan ; set housenum_nick $nick ; set housenum_tell "\002\00304$nick\,\00310\002 ваше число\002\00302 ДВОЙКА.\00310\002 Все претензии тут решаются мирным путем. Хорош для ученых, спортсменов, экстрасенсов. Двойка поможет решить свои проблемы сдержанным людям, так как способствует развитию чувственности. Но жить под этой цифрой не рекомендуется чрезмерно эмоциональным и нервным людям." ; housenum:bigstr $housenum_chan $housenum_tell $housenum_nick}
3 {set housenum_chan $chan ; set housenum_nick $nick ; set housenum_tell "\002\00304$nick\,\00310\002 ваше число\002\00302 ТРОЙКА.\00310\002 В этом \"доме\" хорошо всем. Хорошо подходит для вечеринок и развлечений. В нем духовная и сексуальная энергии будут увеличиваться. Не подходит только тем, кто привык сорить деньгами." ; housenum:bigstr $housenum_chan $housenum_tell $housenum_nick}
4 {set housenum_chan $chan ; set housenum_nick $nick ; set housenum_tell "\002\00304$nick\,\00310\002 ваше число\002\00302 ЧЕТВЕРКА.\00310\002 Это число обладает защитной и стабильной энергией. Этот \"дом\" - хорошее место для неуверенных в жизни, потерянных людей. Четверка поможет таким людям исправить ситуацию, обрести стабильность, практичность. Она хороша для группы людей, которые работают над достижением единой цели. Этот \"дом\" хорошо подходит садоводам, потому что число \"4\" объединяет все стихии - Огонь, Воздух, Воду, Землю. Не подходит четверка только для трудоголиков, так как они будут работать еще больше." ; housenum:bigstr $housenum_chan $housenum_tell $housenum_nick}
5 {set housenum_chan $chan ; set housenum_nick $nick ; set housenum_tell "\002\00304$nick\,\00310\002 ваше число\002\00302 ПЯТЕРКА.\00310\002 В этом \"доме\" все вертится колесом. Жизнь в нем - непрерывная череда походов, встреч, вечеринок, выездов за город. \"Дом\" хорош для ученых, журналистов, потому что он стимулирует активность своих жильцов. В \"доме Пятерки\" возрастает сексуальная привлекательность. Противопоказан людям, склонным к спокойной, размеренной жизни, уставшим от жизненной чехарды." ; housenum:bigstr $housenum_chan $housenum_tell $housenum_nick}
6 {set housenum_chan $chan ; set housenum_nick $nick ; set housenum_tell "\002\00304$nick\,\00310\002 ваше число\002\00302 ШЕСТЕРКА.\00310\002 \"Дом\" гармонии и равновесия. Хорош для семьи с детьми и для желающих развивать свои артистические способности, адвокатов. Шестерка пробуждает дружеские и любовные чувства. В нем могут обрести второе дыхание пары, которые давно живут вместе." ; housenum:bigstr $housenum_chan $housenum_tell $housenum_nick}
7 {set housenum_chan $chan ; set housenum_nick $nick ; set housenum_tell "\002\00304$nick\,\00310\002 ваше число\002\00302 СЕМЕРКА.\00310\002 \"Храм\" уединения и созерцания, где можно проанализировать прошлый опыт и настоящую ситуацию. Здесь хорошо тем, кто хочет жить один, заниматься медитацией, эзотерикой. В нем хорошо живется тем, кто занимается изучением философии и того, что помогает найти жизненный путь. Не подходит тем, кто хочет добиться материального успеха, избавиться от одиночества. Энергия семерки позволяет сосредоточиться на духовных ценностях." ; housenum:bigstr $housenum_chan $housenum_tell $housenum_nick}
8 {set housenum_chan $chan ; set housenum_nick $nick ; set housenum_tell "\002\00304$nick\,\00310\002 ваше число\002\00302 ВОСЬМЕРКА.\00310\002 Хорошая цирфа, несущая изобилие во всех сферах жизни, а также обретения большого количества друзей, благополучия в семье и достатка. Если хотите улучшить материальное положение, вам просто необходимо жить под цифрой восемь. Подходит она и для тех, кому нужны высокая должность, награды, почести, признание в обществе. Цифра \"восемь\" означает целостность, поэтому успех придет не в одной, а во многих областях. Это же относится и к духовным сферам. Но этот дом не подходит людям, не умеющим разумно и рационально распоряжаться финансовыми средствами." ; housenum:bigstr $housenum_chan $housenum_tell $housenum_nick}
9 {set housenum_chan $chan ; set housenum_nick $nick ; set housenum_tell "\002\00304$nick\,\00310\002 ваше число\002\00302 ДЕВЯТКА.\00310\002 Тут пожинают плоды прошлых усилий. В нем всегда присутствует любовь и сострадание к людям. Те, кто в нем живет, легко отдают все другим. В \"доме Девятки\" можно достичь глубины мудрости. Поэтому он хорошо подходит для последнего этапа жизненного пути. Но \"дом Девятки\" противопоказан альтруистам, так как в нем они будут думать и жить проблемами других, забывая о своих нуждах, чем будут вредить себе." ; housenum:bigstr $housenum_chan $housenum_tell $housenum_nick}
}
}

putlog "housenum.tcl by xamyt loaded."
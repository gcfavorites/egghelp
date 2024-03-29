################################################################################
#                                                                              #
#      :::[  T h e   R u s s i a n   E g g d r o p  R e s o u r c e  ]:::      #
#    ____                __                                                    #
#   / __/___ _ ___ _ ___/ /____ ___   ___      ___   ____ ___ _     ____ __ __ #
#  / _/ / _ `// _ `// _  // __// _ \ / _ \    / _ \ / __// _ `/    / __// // / #
# /___/ \_, / \_, / \_,_//_/   \___// .__/ __ \___//_/   \_, / __ /_/   \___/  #
#      /___/ /___/                 /_/    /_/           /___/ /_/              #
#                                                                              #
################################################################################
#                                                                              #
# country.tcl 1.0                                                              #
#                                                                              #
# Author: Stream@Rusnet <stream@eggdrop.org.ru>                                #
#                                                                              #
# Official support: irc.eggdrop.org.ru @ #eggdrop                              #
#                                                                              #
################################################################################

namespace eval country {}

setudef flag nopubcountry

#################################################

bind pub - !country	::country::pub_country
bind pub - !������	::country::pub_country
bind msg - !country	::country::msg_country
bind msg - !������	::country::msg_country

#################################################
##### DON'T CHANGE ANYTHING BELOW THIS LINE #####
#################################################

catch {unset country}

set country(names) {
	"AFGHANISTAN" "ALBANIA" "ALGERIA" "AMERICAN SAMOA"
	"ANDORRA" "ANGOLA" "ANGUILLA" "ANTARCTICA"
	"ANTIGUA AND BARBUDA" "ARGENTINA" "ARMENIA" "ARUBA"
	"AUSTRALIA" "AUSTRIA" "AZERBAIJAN" "BAHAMAS"
	"BAHRAIN" "BANGLADESH" "BARBADOS" "BELARUS"
	"BELGIUM" "BELIZE" "BENIN" "BERMUDA"
	"BHUTAN" "BOLIVIA" "BOSNIA" "BOTSWANA"
	"BOUVET ISLAND" "BRAZIL" "BRITISH INDIAN OCEAN TERRITORY" "BRUNEI DARUSSALAM"
	"BULGARIA" "BURKINA FASO" "BURUNDI" "BYELORUSSIA"
	"CAMBODIA" "CAMEROON" "CANADA" "CAP VERDE"
	"CAYMAN ISLANDS" "CENTRAL AFRICAN REPUBLIC" "CHAD" "CHILE"
	"CHINA" "CHRISTMAS ISLAND" "COCOS (KEELING) ISLANDS" "COLOMBIA"
	"COMOROS" "CONGO" "COOK ISLANDS" "COSTA RICA"
	"COTE D'IVOIRE" "CROATIA" "HRVATSKA" "CUBA"
	"CYPRUS" "CZECHOSLOVAKIA" "DENMARK" "DJIBOUTI"
	"DOMINICA" "DOMINICAN REPUBLIC" "EAST TIMOR" "ECUADOR"
	"EGYPT" "EL SALVADOR" "EQUATORIAL GUINEA" "ESTONIA"
	"ETHIOPIA" "FALKLAND ISLANDS" "MALVINAS" "FAROE ISLANDS"
	"FIJI" "FINLAND" "FRANCE" "FRENCH GUIANA"
	"FRENCH POLYNESIA" "FRENCH SOUTHERN TERRITORIES" "GABON" "GAMBIA"
	"GEORGIA" "GERMANY" "DEUTSCHLAND" "GHANA"
	"GIBRALTAR" "GREECE" "GREENLAND" "GRENADA"
	"GUADELOUPE" "GUAM" "GUATEMALA" "GUINEA"
	"GUINEA BISSAU" "GYANA" "HAITI" "HEARD AND MC DONALD ISLANDS"
	"HONDURAS" "HONG KONG" "HUNGARY" "ICELAND"
	"INDIA" "INDONESIA" "IRAN" "IRAQ"
	"IRELAND" "ISRAEL" "ITALY" "JAMAICA"
	"JAPAN" "JORDAN" "KAZAKHSTAN" "KENYA"
	"KIRIBATI" "NORTH KOREA" "SOUTH KOREA" "KUWAIT"
	"KYRGYZSTAN" "LAOS" "LATVIA" "LEBANON"
	"LESOTHO" "LIBERIA" "LIBYAN ARAB JAMAHIRIYA" "LIECHTENSTEIN"
	"LITHUANIA" "LUXEMBOURG" "MACAU" "MACEDONIA"
	"MADAGASCAR" "MALAWI" "MALAYSIA" "MALDIVES"
	"MALI" "MALTA" "MARSHALL ISLANDS" "MARTINIQUE"
	"MAURITANIA" "MAURITIUS" "MEXICO" "MICRONESIA"
	"MOLDOVA" "MONACO" "MONGOLIA" "MONTSERRAT"
	"MOROCCO" "MOZAMBIQUE" "MYANMAR" "NAMIBIA"
	"NAURU" "NEPAL" "NETHERLANDS" "NETHERLANDS ANTILLES"
	"NEUTRAL ZONE" "NEW CALEDONIA" "NEW ZEALAND" "NICARAGUA"
	"NIGER" "NIGERIA" "NIUE" "NORFOLK ISLAND"
	"NORTHERN MARIANA ISLANDS" "NORWAY" "OMAN" "PAKISTAN"
	"PALAU" "PANAMA" "PAPUA NEW GUINEA" "PARAGUAY"
	"PERU" "PHILIPPINES" "PITCAIRN" "POLAND"
	"PORTUGAL" "PUERTO RICO" "QATAR" "REUNION"
	"ROMANIA" "RUSSIAN FEDERATION" "RWANDA" "SAINT KITTS AND NEVIS"
	"SAINT LUCIA" "SAINT VINCENT AND THE GRENADINES" "SAMOA" "SAN MARINO"
	"SAO TOME AND PRINCIPE" "SAUDI ARABIA" "SENEGAL" "SEYCHELLES"
	"SIERRA LEONE" "SINGAPORE" "SLOVENIA" "SOLOMON ISLANDS"
	"SOMALIA" "SOUTH AFRICA" "SPAIN" "SRI LANKA"
	"ST. HELENA" "ST. PIERRE AND MIQUELON" "SUDAN" "SURINAME"
	"SVALBARD AND JAN MAYEN ISLANDS" "SWAZILAND" "SWEDEN" "SWITZERLAND"
	"CANTONS OF HELVETIA" "SYRIAN ARAB REPUBLIC" "TAIWAN" "TAJIKISTAN"
	"TANZANIA" "THAILAND" "TOGO" "TOKELAU"
	"TONGA" "TRINIDAD AND TOBAGO" "TUNISIA" "TURKEY"
	"TURKMENISTAN" "TURKS AND CAICOS ISLANDS" "TUVALU" "UGANDA"
	"UKRAINE" "UNITED ARAB EMIRATES" "UNITED KINGDOM" "GREAT BRITAIN"
	"UNITED STATES OF AMERICA" "UNITED STATES MINOR OUTLYING ISLANDS" "URUGUAY"
	"SOVIET UNION" "UZBEKISTAN" "VANUATU" "VATICAN CITY STATE" "VENEZUELA"
	"VIET NAM" "VIRGIN ISLANDS (US)" "VIRGIN ISLANDS (UK)" "WALLIS AND FUTUNA ISLANDS"
	"WESTERN SAHARA" "YEMEN" "YUGOSLAVIA" "ZAIRE"
	"ZAMBIA" "ZIMBABWE" "COMMERCIAL ORGANIZATION (US)" "EDUCATIONAL INSTITUTION (US)"
	"NETWORKING ORGANIZATION (US)" "MILITARY (US)" "NON-PROFIT ORGANIZATION (US)"
	"GOVERNMENT (US)" "KOREA - DEMOCRATIC PEOPLE'S REPUBLIC OF" "KOREA - REPUBLIC OF"
	"LAO PEOPLES' DEMOCRATIC REPUBLIC" "RUSSIA" "SLOVAKIA" "CZECH"
}

set country(domains) {
	AF AL DZ AS AD AO AI AQ AG AR AM AW AU AT AZ BS BH BD BB BY BE
	BZ BJ BM BT BO BA BW BV BR IO BN BG BF BI BY KH CM CA CV KY CF
	TD CL CN CX CC CO KM CG CK CR CI HR HR CU CY CS DK DJ DM DO TP
	EC EG SV GQ EE ET FK FK FO FJ FI FR GF PF TF GA GM GE DE DE GH
	GI GR GL GD GP GU GT GN GW GY HT HM HN HK HU IS IN ID IR IQ IE
	IL IT JM JP JO KZ KE KI KP KR KW KG LA LV LB LS LR LY LI LT LU
	MO MK MG MW MY MV ML MT MH MQ MR MU MX FM MD MC MN MS MA MZ MM
	NA NR NP NL AN NT NC NZ NI NE NG NU NF MP NO OM PK PW PA PG PY
	PE PH PN PL PT PR QA RE RO RU RW KN LC VC WS SM ST SA SN SC SL
	SG SI SB SO ZA ES LK SH PM SD SR SJ SZ SE CH CH SY TW TJ TZ TH
	TG TK TO TT TN TR TM TC TV UG UA AE UK GB US UM UY SU UZ VU VA
	VE VN VI VG WF EH YE YU ZR ZM ZW COM EDU NET MIL ORG GOV KP KR
	LA SU SK CZ
}

set country(ver)	"1.0"
set country(authors)	"Stream@RusNet <stream@eggdrop.org.ru>"

#################################################

proc ::country::out {nick chan text} {
	if {[validchan $chan]} {putserv "PRIVMSG $chan :\002$nick\002, $text"
	} elseif {$nick == $chan} {putserv "PRIVMSG $nick :$text"
	} else {putserv "NOTICE $nick :$text"}
}

#################################################

proc ::country::pub_country {nick uhost hand chan args} {
	if {[channel get $chan nopubcountry]} {return}
	::country::country $nick $chan [join $args]
}

proc ::country::msg_country {nick uhost hand args} {
	::country::country $nick $nick [join $args]
}

#################################################

proc ::country::country {nick chan args} {
	global country
	set args [string toupper [string trim [string trimleft [join $args] "."]]]
	if {[string length $args] < 1} {::country::out $nick $chan "��������� !country <����>."; return}
	putlog "\[country\] $nick/$chan $args"
	set pos [lsearch -exact $country(domains) $args]
	if {$pos != -1} {::country::out $nick $chan "������������ ������ ��� .$args: [lindex $country(names) $pos]."
	} else {::country::out $nick $chan "������������ ������ ��� .$args �� �������."}
}

putlog "country.tcl v$country(ver) by $country(authors) loaded"



# <speechles> Scripts are like children. They grow up to take
# on lives of their own, along with all their parents time.

# <speechles> Bots are so obedient, like a wife you never need
# to slap.
 
#---------------------------------------------------------------#
# UNOFFICIAL incith:google                               v1.9.9 #
#                                                               #
# performs various methods of Google searches                   #
# tested on:                                                    #
#   eggdrop v1.6.17 GNU/LINUX with Tcl 8.4                      #
#   windrop v1.6.17 CYGWIN_NT with Tcl 8.4 (http.tcl v2.5)      #
#    - http.tcl included - Linux/BSD users should NOT need this #
#                                                               #
# UNOFFICIAL NEWS:............................................. #
#                                                               #
#  As of 1.9, I (speechless) have rewritten and added several   #
#    pieces of this script, fixing various regexp's, adding     #
#    more search sites to it, added a gamefaqs upcoming list    #
#    for gamers and much much more.                             #
#  See the Egghelp forum for info or help you may need:         #
#      http://forum.egghelp.org/viewtopic.php?t=13586           #
#                                                               #
# OFFICIAL NEWS:............................................... #
#                                                               #
#  As of v1.6, I (madwoota) have taken over the development of  #
#    incith:google. If you have any feature req's, bugs, ideas, #
#    etc, please dont hesitate to send them to me.              #
#  My contact details have replaced incith's, but if you wish   #
#    to approach him directly about anything, I can point you   #
#    in the right direction.                                    #
#  See the Egghelp forum for inciths handover and all the latest#
#    info on this script:                                       #
#    http://forum.egghelp.org/viewtopic.php?t=10175             #
#                                                               #
# BASIC USEAGE GUIDE:.......................................... #
#                                                               #
#   .chanset #channel +google                                   #
#   !google [.google.country.code] [define:|spell:|movie:]      #
#      <search terms> <1+1> <1 cm in ft> <patent ##>            #
#      <weather city|zip> <??? airport>                         #
#   !images [.google.country.code] <search terms>               #
#   !groups [.google.country.code] <search terms>               #
#   !news [.google.country.code] <search terms>                 #
#   !local [.google.country.code] <what> near <where>           #
#   !book [.google.country.code] <search terms>                 #
#   !video [.google.country.code] <search terms>                #
#   !scholar [.google.country.code] <search terms>              #
#   !fight <word(s) one> vs <word(s) two>                       #
#   !youtube [.google.country.code] <search terms>              #
#   !trans region@region <text>                                 #
#   !gamespot <search terms>                                    #
#   !gamefaqs <system> in <region>                              #
#   !blog [.google.country.code] <search terms>                 #
#   !ebay [.ebay.country.code] <search terms>                   #
#   !ebayfight <word(s) one> vs <word(s) two>                   #
#   !wikipedia [.2-digit-country-code] <search terms>[#subtag]  #
#   !wikimedia [.www.wikisite.org[/wiki]] <search terms>[#subtag]
#   !locate <ip or hostmask>                                    #
#   !review <gamename> [@ <system>]                             #
#   !torrent <search terms>                                     #
#   !top <system>                                               #
#   !popular <system>                                           #
#   !dailymotion <search terms>                                 #
#   !ign <search terms>                                         #
#   !myspace <search terms>                                     #
#   !trends [.google.country.code] <YYYY-MM-DD>                 #
#                                                               #
# CHANGE LOG:.................................................. #
#                                                               #
#   1.0: first public release                                   #
#   1.1: improved bolding of search terms, compatible with      #
#          chopped descriptions                                 #
#        supports 'define: <word>' lookups                      #
#        supports calculator. !google (4+3) * 2 - 1             #
#          - converts, too. !google 1 lb in ounces              #
#        image lookups coded, !images <search>                  #
#        'spell: word1 word2' function added                    #
#          - don't rely on this, it's not a dictionary, just    #
#            corrects common typos.                             #
#        flood protection added                                 #
#   1.2: will wrap long lines (yay, a worthy solution!)         #
#        allowed setting of the seperator instead of a ' | ' by #
#          default. If you set this to "\n" then you will get   #
#          each result on a seperate line instead of one line   #
#        will display 'did you mean' if no results              #
#        [PDF] links will be parsed/included now                #
#        fixed a bug when no data was returned from google such #
#          is the case when you search for """"""""""""""""""   #
#   1.3: can return results in multiple languages now           #
#        fixed quotes being displayed around links              #
#        private messages support added (for /msg !google)      #
#        video.google.com seems impossible, Google Video Viewer #
#          is required to view videos, etc                      #
#   1.4: bit of a different output, easier to click links now   #
#        local lookups coded, use !local <what> near <where>    #
#        seems google does currency the same way my exchange    #
#          script does (!g 1 usd in cad)                        #
#        "patent ##" will return the patent link if it exists   #
#        bugfix in private messages                             #
#        sorry to all whom grabbed a borked copy on egghelp :-( #
#   1.5: fix for !local returning html on 'Unverified listing's #
#        "madwoota" has supplied some nice code updates for us! #
#          - "answer" matches, eg: !g population of japan       #
#            - !g <upc code>                                    #
#          - google groups (!gg), google news (!gn)             #
#          - movie: review lookups                              #
#          - area code lookups (!g 780)                         #
#          - print.google lookups (!gp !print)                  #
#        reworked binds to fix horrible bug allowing !g !gi !gp #
#        case insensitive binds (!gi, !GI, !gI, !Gi, etc)       #
#    .1: fix for double triggers/bad binds                      #
#    .2: fix involving "can't read link" error                  #
#-madwoota:                                                     #
#   1.6: fixed google search returning no results               #
#        fixed descriptions getting cut short on 'answers'      #
#        fixed bug where some urls were returned invalid        #
#        fixed google local searches returning no results       #
#        fixed google print searches returning invalid links    #
#        changed 'did you means' to get returned first as well  #
#        added google weather: !g weather <city|zip>            #
#          - note: US weather only (blame google!)              #
#        added travel info, eg: !g sfo airport | !g united 134  #
#        added config option to send output via /notice         #
#        added initial attempt at parsing google video (!gv)    #
#   1.7: added option to force all replies as private (req)     #
#        fixed google groups returning no results               #
#        fixed define: errors on no results                     #
#        fixed google print errors on no results/typos          #
#        fixed movie review errors on no results/typos          #
#        fixed some characters not usable as command_chars on   #
#          one of regular eggdrop or windrop+cygwin             #
#        fixed occasional weird response for travel info        #
#        updated requirements to http package 2.4               #
#        loads of other internal changes                        #
#    .1: fixed search parameters not being parsed correctly     #
#          - resulted in some bogus "no results" replies.       #
#    .2: fixed main google search returning rubbish results     #
#          - google changed their source again                  #
#        changed all methods of parsing the search results to   #
#          *hopefully* cope better with any source changes      #
#        changed output queue to stop the bot from flooding     #
#    .3: fixed some urls being returned with spaces in them     #
#          - makes them unusable in most irc clients            #
#        fixed google groups occasionally returning junk due to #
#          changes in 1.7.2 (will revisit this later)           #
#   1.8: added option to turn on "safe" searches                #
#        added channel user level filtering option (+v/+o only) #
#        added google fight! !gf or !fight <blah> vs <blah>     #
#         - inspired by www.googlefight.com                     #
#        added ability to do any custom mode to descs & links   #
#         - i'll just apologise now for this one :)             #
#        removed variable underline_links (superseded by above) #
#        removed use of 'tcl_endOfWord' to stop windrop breaking#
#        fixed excess %20's appearing in some results           #
#        fixed "translate this" only returns ? (i think)        #
#        stopped local from returning ad spam on first result   #
#-speechless                                                    #
#   1.9: updated various regexp's and regsub's in almost all    #
#          procs to fix non functioning html parsing.           #
#        added !localuk option to display United Kingdom.       #
#        added !youtube for searching videos on youtube.        #
#        added !atomfilms for searching videos on atomfilms.    #
#        added !trans for searching videos on trans.            #
#        added !gamespot for searching games, etc.              #
#        added !gamefaqs, it is able to parse multiple systems  #
#          and regions, still a work in progress, all bugs have #
#          been squashed.                                       #
#        added !test proc to help debug and dump html for       #
#          future parsing projects.                             #
#    .1: added !blog for searching blogsearch.google            #
#        added !ebay for searching ebay auctions.               #
#        added !ebayfight for amusement, same as googlefight.   #
#        fixed various miscellaneous minor annoyances in parts. #
#        finally fixed !book (aka print) to work with           #
#          books.google                                         #
#        added !ign for searching movies, games, etc..          #
#    .2: added support for total_search to show total results   #
#          or not. :)                                           #
#        added support for link_only (requested).               #
#        added back complete support for desc/link modes        #
#          they will now affect results properly.               #
#          (note: doesn't affect gamefaqs or locate)            #
#        added !locate for dns location information.            #
#    .3: added !wiki for searching wikipedia for things, very   #
#          much a work-in-progress, don't expect it to be       #
#          perfect.. it just reads very top heading <h*> so     #
#          sometimes it returns next to nothing.. like I said   #
#          it's WIP so don't bitch, thx.                        #    
#        added !review for searching gamefaqs and pulling a     #
#          games review, ranking, score, etc.. works similarly  #
#          to the way !wiki does, has same problem, so this     #
#          is also WIP.. thx                                    #
#    .4: fixed a few regexp parsers to correct broken (no       #
#          results returned) messages in some procs.            #
#        changed google populations to return only 1st desc     #
#          this fixes a small bug where excess html was shown.  #
#          ie. !g population japan || !g population of japan    #
#        fixed google define: links with quick regsub hacks.    #
#        problem with recent ign changing to javascripted html  #
#            so removed their advertising.. too bad for them.   #
#        fixed review and wikipedia to almost perfect.          #
#           note: review does not use forms submittal, instead  #
#           I chose to a single query and field matching on the #
#           first page returned. I may later use forms submital #
#           at some later time.                                 #
#        added two gamerankings triggers (!top/!popular)        #
#        added a mininova torrent search parser.                #
#        fixed parser for !blog by removing quotes. "g" -> g    #
#        beefed up the wikipedia parser so can intelligently    #
#            move to html#subtags to display info.              #
#        removed atomfilms trigger because no one was using.    #
#        added dailymotion trigger for searching tv episodes    #
#            since youtube/google seem to remove those too      #
#            often.                                             #
#        wikipedia now has ability to properly handle internal  #
#            redirects intelligently as well.                   #
#        youtube needed its regexp/regsub parsers tweaked a bit #
#            to handle new html design.                         #
#        google changed format and updated search regexp/sub    #
#            accordingly.                                       #
#        fixed !local lookups, removed !localuk as it was       #
#            redundant since !local covers UK region now.       #
#        corrected !book to actually produce an output again    #
#            i left broken intentionally earlier because of     #
#            lack of interest, but a guy named Zircon sparked   #
#            my interest again. enjoy.                          #
#        gamespot injects paid crap into their html design now  #
#            so found a way to scrape around it.. muahah        #
#        requested by a few people that somehow wikipedia is    #
#            multi-lingual so a fast hack is provided at the    #
#            moment which lacks input checking.. will fix later #
#        requested by a british friend was the ability as well  #
#            for ebay to work from different countries server.  #
#            this also lacks input checking.. will fix later.   #
#        added error catching for erroneous url's in both       #
#            wikipedia and ebay, this way bad user countries    #
#            will be reported with socket errors. thx rosc2112  #
#    .5: major modification of script to allow for dynamic      #
#            language selection of _all_ google sites.          #
#            (search,image,news,local,video,book,blog)          #
#            google group is still broken, will fix later :P    #
#        added !trans for google translate. enjoy.              #
#        added stock quotes (supplied by madwoota)              #
#        fixed translation to convertto foreign charsets.       #
#            fixes display of russian and arabic languages.     #
#        corrected google area code map results.                #
#        added google zip code map results.                     #
#        corrected google movie review lookups, now works!      #
#        search totals was incorrect on some country google     #
#            lookups. it was using elapsed search time as the   #
#            total results, so now a fallback (else) corrects   #
#            it by replace total results with 'google' in       #
#            those instances.                                   #
#        youtube undergoing major html changing to keep bots    #
#            from indexing, so changed some parsers to work.    #
#        added back !ign trigger for scraping ign's search      #
#            page for results.                                  #
#        google answers needed fixing to show correct results.  #
#        added !myspace trigger for searching their video       #
#            content.                                           #
#        corrected zipcode/areacode/airport.                    #
#        corrected all google query possibilities by spending a #
#            few hours fine tuning everything. Most languages   #
#            should work exactly as planned. Some languages     #
#            "may" display incorrectly, but this is by design   #
#            rather than an error, as the script presently uses #
#            unicode for everything except google translations. #
#        major work done to !local fixing it for every possible #
#            query result in almost every language, try it out  #
#            feeding it nonsense and try to find a flaw.        #
#        small bug concerning !google patent ##### .. wasn't    #
#            being caught as results, now all is well again.    #
#        corrected ebay parser with small change to eliminate   #
#            excess html in 'buy-it-now' parsing.               #
#        UPC codes work again.. yay.. how many use this? 1 guy? #
#        Ebay, Wikipedia and Google needed minor fixes to       #
#            correct remaining bits that were left untranslated #
#            now all output will be in language chosen.         #
#        Gamespot changed html design of their page layots for  #
#            reviews, so quick fix to !review proc to handle    #
#            their new design :)                                #
#        Corrected 'results' message displayed with totals to   #
#            also be displayed in language searched in, makes   #
#            the output look much more professional. r0x hard.  #
#            All Google triggers are now 100% dialect perfect.  #
#        Fixed small problem with wikipedia's 'no result'       #
#            message being longer than neccessary.              #
#        Added multi-language ability to youtube because it     #
#            now supports it, new default variable for setting  #
#            language default for it as well. enjoy.            #
#        Changed myspace parser query making it less prone to   #
#            breaking.                                          #
#        Added new trigger !trends to get top search results    #
#            for any date (this is limited by google cache,     #
#            not by the script) and also can be given country   #
#            switches. This is new, at present I cannot go      #
#            back beyond May 2007-05-15 ..                      #
#        Added dual results to !ebay trigger for price/bids     #
#            to account for the fact buy-it-now allows bids as  #
#            well...                                            #
#        Fixed the tiny bug in google answers lookup which      #
#            allowed for cruft to be given as 2nd result.       #
#        Fixed the tiny bug in wikipedia articles that left     #
#            parts of tables in the results.                    #
#        Added forced subtagging ability to wikipedia results   #
#            using their standard sub-tag #this so you can now  #
#            force certain sections to being your results and   #
#            it must only begin with the term doesn't need to   #
#            be entire term to force a sub-tag redirect.        #
#    .6: Added !mediawiki trigger following same abilities as   #
#            the wikipedia trigger.  This is beta at the moment #
#            and the reason this script has a revision change.  #
#        Corrected small issue regarding parsing original search#
#            results which makes this now compatabile with      #
#            every mediawiki page.                              #
#        Fixed problem parsers; Groups, News, Book              #
#        Problems with some procs sorted, Gamefaqs modified to  #
#            work with new php site design.                     #
#        Fixed issues with stubborn always changing google      #
#            based searches.  Now hopefully all triggers work   #
#            again.                                             #
#        Added prepend ability (Requested) so now each of your  #
#            lines, can be prepended with whatever you desire.  #
#        Added 'time in' feature to google search, allows you   #
#            to find out the time in any region, works like     #
#            population and date.                               #
#        Added wiki_line option to expand results.              #
#    .7: Added input/output encoding conversion to better       #
#            realize the multi-language side of this script.    #
#        Corrected mistake in input/output encoding handlers.   #
#        Added a triple lookup for youtube to include all       #
#            possible results and not miss any.                 #
#        Corrected issue with wikipedia/wikimedia incorrectly   #
#            removing some elements as page markups.            #
#        Added ability for bold to be seen in wikipedia/wikimedia
#            results again, removed stripcodes.                 #
#   .7a: Expanded Wikimedia and Wikipedia for allowing multi-   #
#            language as well as regional dialects. This also   #
#            allows for expanded custom encoding coverage.      #
#   .7b: Corrected google to return useful results once again.  #
#            broken was define, no_search, did_u_mean, and      #
#            weather.                                           #
#        Ebay now expanded upon to allow 'store' results to     #
#            appear as well as functional 'did you mean'        #
#            messaging.                                         #
#   .7c: Added remaining onebox results to google results.      #
#    .8: New features corrected longstanding shortcomings:      #
#         * Wikipedia/Wikimedia now fully decode and encode     #
#            on the fly and translate subtags seamlessly.       #
#         * Main encoding routine now includes a smart URL      #
#            encoder for those using language other than        #
#            english.                                           #
#        Corrected problem with script handling tcl special     #
#            characters as part of user input.                  #
#   .8a: All did you mean messages now report from page exactly #
#            as they appear. All sites that allow this now      #
#            handle this ability if no results are found.       #
#   .8b: Corrected deficiencies in !translate, it should now    #
#            function better regarding encodings and html       #
#            markups.  thx perplexa.                            #
#        Corrected minor problem regarding wikipedia's recent   #
#            template change. Now uses similar style as         #
#            wikimedia to prevent issues.                       #
#   .8c: Corrected google video as well as added the whois      #
#            onebox to regular google searches.                 #
#        Corrected way define: links are handled so encodings   #
#            are dealt with properly.                           #
#   .8d: Corrects issue with myspace and regional IP bases.     #
#   .8e: Corrects google video to produce results.              #
#   .8f: Added vocabulary aversion.                             #
#        Corrected flaw with wikimedia's encoding process,      #
#             improved overall functionality.                   #
#   .8g: Added domain detection for wikimedia domain's which    #
#             aren't using the standard subdomain /wiki.        #
#   .8h: Corrected !torrent                                     #
#   .8i: Corrected google zipcodes and google video.            #
#   .8j: Corrected youtube and google groups.                   #
#   .8k: Corrects some urlencoding problems regarding eggdrops  #
#             complete inability to distinguish between utf-8   #
#             and iso8859-1. Now requires http 2.5 which allows #
#             setting the -urlencoding flag.                    #
#        Corrects entire script which now uses the -urlencoding #
#             flag in some way to hopefully force eggdrop to    #
#             understand the differences and force proper       #
#             detections.                                       #
#         * requirements upped, now requries http 2.5 *         #
#   .8l: Corrects google search (calculations, did_you_mean,etc)#
#        Corrects google book                                   #
#        -- experimental version --                             #
#        Adds "automagic" detection to google translations      #
#        Possiblity for more automagic detection in the future  #
#          support procedures in place to allow this already.   #
#   .8m: Adds more "automagic" detection and a more robust      #
#          debugging display.                                   #
#        Corrected minor display problems.                      #
#   .8n: Corrects Googles embolding placement within results,   #
#           can now interpret <em> tags as bold.                #
#   .8o: Added correct support for a true utf-8 workaround.     #
#   .8p: Added proper redirect support.                         #
#        Corrected Youtube behavior.                            #
#   .8q: Corrected Dailymotion, added multilanguage support to  #
#           it and extended it's capabilities.                  #
#   .8r: Corrected minor youtube url inconsitancy.              #
#   .8s: Corrected result totals to appear again for all google #
#           sites, also corrected other google anamolies.       #
#        Corrected local as well to work with custom locations. #
#        Added mediawiki customized triggers to allow access    #
#           to mediawiki sites without so much input required.  #
#   .8t: Google template changed, <div class=g -> <li class=g   #
#   .8u: Added full support for session cookies as well as      #
#           unlimited redirect support. This allows adding      #
#           the secondary ebay template for their store server  #
#           and allows ebay to function 100% again.             #
#   .8v: Added back support for !game and !review and elaborated#
#           upon the amount of information displayed.           #
#   .8w: Added new abilities to both !locate and !trans now     #
#           allows much less input from the user and default    #
#           behavior.                                           #
#        Also correct other slight anomalies.                   #
#   .8x: Corrected ebay finally, yay! also added sorry detection#
#           to google so users experiencing this can tell. Also #
#           fixed the html cruft in gamespot review replies.    #
#   .8y: Corrected youtube, now more complaint with all templates
#           returned                                            #
#   .8z: Corrected video and group functionality.               #
#        Added scholar for parsing scholar.google.*             #
#    .9: Corrected video and youtube to work with website       #
#           re-designs.                                         #   
#        Other minor tweaks here and there.                     #
#                                                               #
# TODO:........................................................ #
#                                                               #
#   Fix broken parsers, this is a never-ending battle!          #
#   -- This is always #1 priority over anything else --         #
#                                                               #
#   Add error detection for socket/timeout to remaining procs   #
#       left without it.                                        #
#                                                               #
#   Solve inconsitancies in some countries total results and    #
#       inaccurate parsing due to differing html templates.     #
#                                                               #
#   -- Once everything above is done we can start on these:     #
#   Clean-up code where obvious hacks were left in, code them   #
#       correctly, remove debugging code from procs which is    #
#       presently commented out.                                #
#   Clean-up overly messy code that can be solved by coding     #
#       cleaner modules and not reusing so much code.           #
#                                                               #
#     For this UNOFFICIAL version please direct any and all     #
#        Suggestions/Thanks/Bugs to the forum link below:       #
#    -->  http://forum.egghelp.org/viewtopic.php?t=13586  <--   #           
#                                                               #
# LICENSE:..................................................... #
#                                                               #
#   This code comes with ABSOLUTELY NO WARRANTY.                #
#                                                               #
#   This program is free software; you can redistribute it      #
#   and/or modify it under the terms of the GNU General Public  #
#   License as published by the Free Software Foundation;       #
#   either version 2 of the License, or (at your option) any    #
#   later version.                                              #
#                                                               #
#   This program is distributed in the hope that it will be     #
#   useful, but WITHOUT ANY WARRANTY; without even the implied  #
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR     #
#   PURPOSE.  See the GNU General Public License for more       #
#   details. (http://www.gnu.org/copyleft/library.txt)          #
#                                                               #
# CREDITS:..................................................... #
#                                                               #
# ..Officially:                                                 #
# Copyright (C) 2005, Jordan (Incith)                           #
# Currently maintained by madwoota                              #
# google@woota.net                                              #
#                                                               #
# ..Unofficially:                                               #
# Copyleft (C) 2006-2008, Speechless                            #
# v1.9.9 - Dec 5th, 2oo8 - speechles <#roms-isos@efnet>         #
#---------------------------------------------------------------#

package require http 2.5
setudef flag google

# EVERYTHING IN THIS SECTION IS USER CUSTOMIZABLE.
# BEST SETTINGS ARE DEFAULT, YOU MAY HAVE OTHER IDEAS OF WHAT IS BEST.
#
# NOTE: some config options won't list how to enable/disable, but
# 0 will typically disable an option (turn it off), otherwise a
# value 1 or above will enable it (turn it on).
# ------
# start of configuration - make your changes in this section
# ------
namespace eval incith {
  namespace eval google {
    # set this to the command character you want to use for the binds
    # ------
    variable command_char "!"

    # set these to your preferred binds ("one two three etc etc" - space delimited!)
    # ------
    variable google_binds "g google goog"
    variable image_binds "i gi image images"
    variable local_binds "l gl local"
    variable group_binds "gg group groups"
    variable news_binds "n gn news"
    variable print_binds "gb book books"
    variable video_binds "v gv video"
    variable scholar_binds "s sc scholar"
    variable fight_binds "f fight googlefight"
    variable youtube_binds "y yt youtube"
    variable locate_binds "geo loc locate"
    variable gamespot_binds "gs game gamespot"
    variable trans_binds "tr trans translate"
    variable daily_binds "dm daily dailymotion"
    variable gamefaq_binds "gf gamefaq gamefaqs"
    variable blog_binds "b blog blogsearch"
    variable ebay_binds "e ebay"
    variable efight_binds "ef ebayfight"
    variable popular_binds "popular pop"
    variable rev_binds "r review"
    variable wiki_binds "w wiki wikipedia"
    variable wikimedia_binds "wm wikim wikimedia"
    variable recent_binds "top best"
    variable mininova_binds "t torrent mininova"
    variable ign_binds "ign igame"
    variable myspacevids_binds "m myspace myvids"
    variable trends_binds "gtr trends"
    variable helpbot_binds "help bot"

    # to restrict input queries to Ops (+o), Halfops (+h) or Voiced (+v) users on
    # any +google channel, use this setting.
    # set the variable to one of the following to achieve the desired filtering:
    #   at least Op -> 3      (obvious)
    #   at least Halfop -> 2  (will also allow ops)
    #   at least Voice -> 1   (will also allow halfops and ops)
    #   everyone -> 0         (no filtering)
    #
    # note: this does NOT apply to private messages, use the below setting for them.
    # ------
    variable chan_user_level 0

    # if you want to allow users to search via private /msg, enable this
    # ------
    variable private_messages 1

    # as per emailed & forum requests, use the next two variables together
    # to determine the output type like so:
    #  notice_reply 1 & force_private 1 = private notice reply only (this is as requested)
    #  notice_reply 0 & force_private 1 = private msg reply only
    #  notice_reply 1 & force_private 0 = regular channel OR private NOTICE
    #  notice_reply 0 & force_private 0 = regular channel OR private MSG (default)
    # set to 1 to enable a /notice reply instead, 0 for normal text
    # ------
    variable notice_reply 0

    # set to 1 to force all replies to be private
    # ------
    variable force_private 0

    # set this to the language you want results in! use 2 letter form.
    # "all" is the default/standard google.com search.
    # see http://www.google.com/advanced_search for a list.  You have to use
    # the 'Language' dropdown box, perform a search, and find a line in the URL
    # that looks like "&lr=lang_en" (for English). "en" is your language code.
    # popular Ones: it (italian), da (danish), de (german), es (spanish), fr (french)
    # please note, this does not 'translate', it searches Google in a
    # language of choice, which means you can still get English results.
    # ------
    variable language "all"

    # set this to "on" to let google filter "adult content" from any of your search results
    # "off" means results will not be filtered at all
    # note: this is only applicable to !google, !images and !groups
    # ------
    variable safe_search "off"

    # number of search results/image links to return, 'define:' is always 1 as some defs are huge
    # ------
    variable search_results 4
    variable image_results 4
    variable local_results 4
    variable group_results 3
    variable news_results 3
    variable print_results 3
    variable video_results 4
    variable scholar_results 4
    variable youtube_results 5
    variable locate_results 1
    variable gamespot_results 3
    variable trans_results 1
    variable daily_results 4  
    variable gamefaq_results 20
    variable blog_results 3
    variable ebay_results 3
    variable popular_results 10
    variable rev_results 1
    variable wiki_results 1
    variable wikimedia_results 1
    variable recent_results 10
    variable mininova_results 3
    variable ign_results 3
    variable myspacevids_results 3
    variable trends_results 25

    # This part was requested to be added so now here it is, it has
    # various prepends you may wish to have preceed each function.
    # To use this, just change what you see below from nothing to
    # something...ie, if you want [ GOOGLE ] to prepend google
    # search results change the search_prepend to "\[GOOGLE\]". You
    # can do the same with all of the following prepends, they will
    # start the output for each line. If you don't wish to use this,
    # leave them as "". Keep in mind tcl special characters MUST be
    # escaped or will cause tcl errors, and/or crash your bot. This
    # is your own problem, just be aware. Read about them if possible.
    #
    # Note 1: Prepends will increase your line length, and won't be
    # accommodated for in the max line length setting, so you may
    # find you need to lower your max line length setting if your
    # prepends are lengthy or contain lots of escape sequences. If
    # you don't you  may find the bots replys may get cut short or
    # cut completely by the ircd your using.
    #
    # Note 2: To use color, bold, etc.. simply use the proper escape
    # sequence to generate it here, make sure to properly CLOSE your
    # sequence (\003 for color, \002 for bold, etc) or you will see
    # the effect of the prepend bleed thru into your output as well.
    # ------
    variable search_prepend ""
    variable image_prepend ""
    variable local_prepend ""
    variable group_prepend ""
    variable news_prepend ""
    variable print_prepend ""
    variable video_prepend ""
    variable scholar_prepend ""
    variable youtube_prepend ""
    variable locate_prepend ""
    variable gamespot_prepend ""
    variable fight_prepend ""
    variable ebayfight_prepend ""
    variable trans_prepend ""
    variable dailymotion_prepend ""
    variable gamefaqs_prepend ""
    variable blog_prepend ""
    variable ebay_prepend ""
    variable popular_prepend ""
    variable rev_prepend ""
    variable wiki_prepend ""
    variable wikimedia_prepend ""
    variable recent_prepend ""
    variable mininova_prepend ""
    variable ign_prepend ""
    variable myspacevids_prepend ""
    variable trends_prepend ""

    # set this to 0 to turn google fight off (it is a tad slow after all ...)
    # this also disables or enables ebay fights (it's even slower ...)
    # ------
    variable google_fight 1

    # what to use to seperate results, set this to "\n" and it will output each result
    # on a line of its own. the seperator will be removed from the end of the last result.
    # ------
    variable seperator " | "

    # ** this is not an optional setting, if a string is too long to send, it won't be sent! **
    # it should be set to the max amount of characters that will be received in a public
    # message by your IRC server.  If you find you aren't receiving results, try lowering this.
    # ------
    variable split_length 410

    # trimmed length of returned descriptions, only for standard searches.
    # ------
    variable description_length 40

    # amount of lines you want your wiki* results to span, the more lines the more
    # of the wiki article or section you will see, some get cut short if so raise this.
    # this affects both wikipedia and wikimedia results.
    # ------
    variable wiki_lines 2

    # replace search terms appearing in the description as bolded words?
    # -> does not bold entire description, just the matching search words
    # -> this is ignored if desc_modes contains the Bold mode below.
    # ------
    variable bold_descriptions 1

    # set this to 0 to turn off total results appearing with searches.
    # ------
    variable total_results 1

    # set this to 1 to remove descriptions and set only links to show
    # ------
    variable link_only 0

    # set this to the default country you would like *.wikipedia to use when
    # no country is specified. default is "en". country is 2-letter wiki code.
    # http://*.wikipedia.org/ - en, de, it, es, fr, these are examples.
    # ------
    variable wiki_country "en"

    # set this to the default website you would like wikimedia to use when
    # no website is specified.
    # ------
    variable wikimedia_site "wiki.gbatemp.net/wiki"

    # Wikimedia URL detection
    # remove double entries from urls? would remove a '/wikisite' from this
    # type of url @ http://yoursite.com/wikisite/wikisite/search_term
    # if you have issues regarding url capture with wikimedia, enable this.
    # /wiki/wiki/ problems are naturally averted, a setting of 0 already
    # stops these type.
    # --------
    variable wiki_domain_detect 1

    # Customized Wikimedia
    # allow customized triggers for special wikimedia pages
    # Anything other than 0 will enable and will use the list below.
    variable wiki_custom 1

    # Custom wiki triggers
    # This is used to customize triggers for different wikimedia sites.
    # The format is "trigger:wikisite.here"
    variable wiki_customs {
      "rw:wiki.roms-isos.com"
      "gw:wiki.gbatemp.net/wiki"
      "ed:encyclopediadramatica.com"
      "un:uncyclopedia.org"
      "wq:en.wikiquote.org/wiki"
      "lw:lyricwiki.org"
      "wk:en.wiktionary.org"
    }

    # set this to the default country you would like ebay.* to use when no
    # country is specified. default is "com". country is ebay extension
    # http://ebay.*/ - co.uk, de, es, com, com.au, these are examples.
    # ------
    variable ebay_country "com" 

    # set this to the default country you would like *.google.* sites to use when
    # no country is specified. default is "com". country is google extension.
    # http://google.*/ - co.uk, de, es, com, com.au, these are examples.
    # ------
    variable google_country "com" 

    # set this to the default country you would like dailymotion to use when
    # no country is specified. default is "en" for international.
    # http://dailymotion.com/*/ - en, us, es, fr, nl, pt, da, el, it, pl, ro, sv, tr, ja, ko, zh, these are examples.
    # ------
    variable daily_country "en" 

    # set this to the default country you would like *.youtube to use when
    # no country is specified. default is "com". country is youtube code.
    # http://*.youtube.com/ - com, us, ie, fr, it, nl, br, gb, jp, de, es, pl, these are examples.
    # ------
    variable youtube_country "com" 

    # enable this to allow youtube links to lead to higher definition videos
    # rather than their stream optimized lower quality setting.
    # to disable use 0, anything else enables.
    # ------
    variable youtube_highquality 1

    # set your default translation language here, this is what will be assumed
    # if the user omits the 'translate to' portion of their input.
    # en, es, it, nl, de, etc.. these are merely some examples, there are more available.
    # ------
    variable trans "en"

    # Channel filter
    # this is for users who already have a google script running, but would
    # like to use the other functions of this script. You can filter out google
    # requests in any of the channels listed below.
    # default is "". To add them use: "#chan1 #CHAN2 #cHaN3 #EtC", case is irrelevant.
    # ------
    variable filtered ""

    # use these two settings to set colours, bold, reverse, underline etc on either descriptions or links
    # the following modes apply and you can use any combination of them: (NO SPACES!)
    #
    #  Bold = \002
    #  Underline = \037
    #  Reverse = \026
    #  Colours:                 #RGB/Html code:
    #   White = \0030           #FFFFFF
    #   Black = \0031           #000000
    #   Blue = \0032            #00007F
    #   Green = \0033           #008F00
    #   Light Red = \0034       #FF0000
    #   Brown = \0035           #7F0000
    #   Purple = \0036          #9F009F
    #   Orange = \0037          #FF7F00
    #   Yellow = \0038          #F0FF00
    #   Light Green = \0039     #00F700
    #   Cyan = \00310           #008F8F
    #   Light Cyan = \00311     #00F7FF
    #   Light Blue = \00312     #0000FF
    #   Pink = \00313           #FF00FF
    #   Grey = \00314           #7F7F7F
    #   Light Grey = \00315     #CFCFCF
    #
    # this example will do Bold, Underline and Light Blue: "\002\037\00312"
    # note: this will affect *ALL* descs or links. don't forget to use the \ too !
    # also note: abusing this will heavily increase the number of characters per line,
    # so your output lines will increase accordingly.
    # ------
    variable desc_modes ""
    variable link_modes ""

    # number of minute(s) to ignore flooders, 0 to disable flood protection
    # ------
    variable ignore 1

    # how many requests in how many seconds is considered flooding?
    # by default, this allows 3 queries in 10 seconds, the 4th being ignored
    # and ignoring the flooder for 'variable ignore' minutes
    # ------
    variable flood 4:10

    # would you like to use vocabulary aversion?
    # this will replace swear words with more appropriate words
    # and the query returned will be aversion free.
    # 0 disables, anything else enables
    #----------
    variable aversion_vocabulary 0
    
    # set your aversion vocabulary below if desired:
    # remember to enable, keep the setting above at 1.
    #----------
    variable aversion {
      anal:internet
      "hell:a hot place"
      sex:troll
      *fuck*:nice
      bitches:women
      bitch:woman
      "analsex:true love"
    }

#---> NOTE:
#---> IF YOUR PRIMARY LANGUAGE ISN'T ENGLISH YOU MUST CHANGE THIS SECTION BELOW POSSIBLY
    # this is the help list generated by the bot to help users become familiar with the script.
    # you can change these here to affect the language used when help is asked for.
    # there MUST be 28 entries in this list, the first must be the word for ALL.
    # this list MUST be kept entirely lowercase.
    # ------
    variable helplist "all google images groups news local book video fight youtube translate gamespot gamefaqs blog ebay ebayfight wikipedia wikimedia locate review torrent top popular dailymotion ign myspace trends scholar"

    # english words within the help phrases, spacing must be kept as it is below.
    # ------
    variable helpmsg1 "Help is only available for the following:"
    variable helpmsg2 "is disabled."
    variable helpmsg3 "with "
    variable helpmsg4 " results."

    # the help messages given.
    # ------
    variable help1 "\[.google.country.code\] \[define:|spell:|movie:\] <search terms> <1+1> <1 cm in ft> <patent ##> <weather city|zip> <??? airport>" ;#google
    variable help2 "\[.google.country.code\] <search terms>" ;#images
    variable help3 "\[.google.country.code\] <search terms>" ;#groups
    variable help4 "\[.google.country.code\] <search terms>" ;#news
    variable help5 "\[.google.country.code\] <what> near <where>" ;#local
    variable help6 "\[.google.country.code\] <search terms>" ;#book
    variable help7 "\[.google.country.code\] <search terms>" ;#video
    variable help8 "<word(s) one> vs <word(s) two>" ;#fight
    variable help9 "\[.youtube.country.code\] <search terms>" ;#youtube
    variable help10 "region@region <text>" ;#translate
    variable help11 "<search terms>" ;#gamespot
    variable help12 "<system> in <region>" ;#gamefaqs
    variable help13 "\[.google.country.code\] <search terms>" ;#blog
    variable help14 "\[.ebay.country.code\] <search terms>" ;#ebay
    variable help15 "<word(s) one> vs <word(s) two>" ;#ebayfight
    variable help16 "\[.wiki-country-code\] <search terms>\[#subtag\]" ;#wikipedia
    variable help17 "\[.www.wikisite.org\[/wiki\]\] <search terms>\[#subtag\]" ;#wikimedia
    variable help18 "<ip or hostmask>" ;#locate
    variable help19 "<gamename> \[@ <system>\]" ;#review
    variable help20 "<search terms>" ;#torrent
    variable help21 "<system>" ;#top
    variable help22 "<system>" ;#popular
    variable help23 "<search terms>" ;#dailymotion
    variable help24 "<search terms>" ;#ign
    variable help25 "<search terms>" ;#myspace
    variable help26 "\[.google.country.code\] <YYYY-MM-DD>" ;#trends
    variable help27 "\[.google.country.code\] <search terms>" ;#scholar
#---> END OF NOTE:

    

    # enable encoding conversion, set this to 1 to enable.
    # with this enabled it will follow the format of encoding conversions listed
    # below. these will affect both input and output and will follow country switch.
    # ------
    variable encoding_conversion_input 0
    variable encoding_conversion_output 1

    # THIS IS TO BE USED TO DEVELOP A BETTER LIST FOR USE BELOW.
    # To work-around certain encodings, it is now necessary to allow
    # the public a way to trouble shoot some parts of the script on
    # their own. To use these features involves the two settings below.

    # set debug and administrator here
    # this is used for debugging purposes
    #----------
    variable debug 1
    variable debugnick speechles

    # AUTOMAGIC
    # with this set to 1, the bottom encode_strings setting will become
    # irrelevant. This will make the script follow the charset encoding
    # the site is telling the bot it is. 
    # This DOES NOT affect wiki(media/pedia), it will not encode automatic.
    # Wiki(media/pedia) still requires using the encode_strings section below.
    variable automagic 1

    # UTF-8 Work-Around (for eggdrop, this helps automagic)
    # If you use automagic above, you may find that any utf-8 charsets are
    # being mangled. To keep the ability to use automagic, yet when utf-8
    # is the charset defined by automagic, this will make the script instead
    # follow the settings for that country in the encode_strings section below.
    variable utf8workaround 1

    # encoding conversion lookups
    # here is where you can correct language encoding problems by pointing their
    # abbreviation towards an encoding. if you want more, feel free to add more.
    # this is a somewhat poor example below, there are possibly hundreds of additions
    # that need to be added to this section, this is just something to see if this
    # indeed is a work around, enjoy and merry christmas ;P
    # ------
    variable encode_strings {
      zh:gb2312
      de:iso8859-1
      es:iso8859-1
      it:iso8859-1
      nl:iso8859-1
     com:iso8859-1
   co.uk:iso8859-1
      en:iso8859-1
      fr:iso8859-1
      ro:cp1251
      bg:cp1251
      rs:cp1251
      sr:cp1251
   sr-el:cp1252
      ru:cp1251
      ar:cp1256
      jp:shiftjis
      ja:shiftjis
   co.jp:shiftjis
      tr:cp857
      kr:iso2022-kr
   co.kr:iso2022-kr
   co.il:iso8859-8
  com.ua:koi8-u
      uk:koi8-u
      hu:cp1250
      pl:iso8859-2
    }
  }
}

# ------
# end of configuration, script begins - changes beyond this section aren't advised.
# ------
# *** DO NOT CHANGE THINGS BEYOND THIS POINT UNLESS YOU KNOW WHAT YOUR DOING ***
# If you know what your doing, well by all means, change anything and everything,
# but do so with the understanding that all modifications are bound by the
# GNU General Public license agreement found above regarding credit for authors
# and general copyrights.
# ------

namespace eval incith {
  namespace eval google {
    variable version "incith:google-1.9.9"
    variable encode_strings [split $encode_strings]
  }
}

# bind the public binds
bind pubm -|- "*" incith::google::public_message

# bind the private message binds, if wanted
if {$incith::google::private_messages >= 1} {
  bind msgm -|- "*" incith::google::private_message
}

namespace eval incith {
  namespace eval google {
    # GOOGLE
    # performs a search on google.
    #
    proc google {input} {
      # local variable initialization
      set results 0 ; set calc 0 ; set break 0 ; set spell 0 ; set output ""; set match ""
      set populate 0 ; set titem "" ; set no_search "" ; set did_you_mean "" ; set titen ""
      set weather 0

      # if we don't want any search results, stop now.
      if {$incith::google::search_results <= 0} {
        return
      }

      # can't be moved to fetch_html since $spell isn't global
      if {[string match -nocase "*spell:*" $input] == 1} {
        set spell 1
      }
      if {[string match -nocase "*weather:*" $input] == 1} {
        set weather 1
      }

      # fetch the html
      set html [fetch_html $input 1]

      # this isn't global, so we need to keep ctry (country) here
      regexp -nocase -- {^\.(.+?)\s(.+?)$} $input - titen input
      if {$titen == ""} {
        set titen "${incith::google::google_country}" 
      }

      # standard fetch_html error catcher
	if {[string match -nocase "*socketerrorabort*" $html]} {
            regsub {(.+?)\|} $html {} html
            return "Socket Error accessing '${html}' .. Does it exist?"
	}
	if {[string match -nocase "*timeouterrorabort*" $html]} {
		return "Connection has timed out"
	}

      # strip out 'did you mean?' first
      # what do we call 'no search results in any language?'
      if {![regexp -- {</div><div id=res class=med>(.+?)<p style} $html - no_search]} {
        if {![regexp -- {\-\-\></script><div id=res>(.+?)<br><br>} $html - no_search]} {
           regexp -- {<h1>(.+?)</p>} $html - no_search
        }
      }
      if {$no_search != ""} {
        regexp -- {^(.+?)</td></tr>} $no_search - no_search
        regsub -- {</a>} $no_search "? " no_search
        regsub -all -- {<(.+?)>} $no_search { } no_search
        while {[string match "*  *" $no_search]} {
          regsub -all -- {  } $no_search " " no_search
        }
        if {$incith::google::bold_descriptions == 0} {
          regsub -all -- "\002" $no_search {} no_search
        }
        set no_search [incithencode [string trim $no_search]]
      }

      # give results an output header with result tally.
      regexp -- {<div id=prs>.*?</div><p>(.+?)\s\002(.+?)\(\002} $html - titem match
      if {![regexp -- {1\002\s-\s\002.+?\002.+?\002(.+?)\002} $match - match]} {
         set match "Google"
         set titem ""
      }

      regsub -all -- {<(.+?)>} $match {} match
      # format output according to variables.
      if {$incith::google::total_results != 0 && $match > 0 && $spell == 0} {
        set output "\002${match}\017 [descdecode $titem]${incith::google::seperator}"
        if {$incith::google::bold_descriptions == 0} {
          regsub -all -- "\002" $output {} output
        }
      } 

      # we need this to keep blogsearch results from appearing in our zipcodes, trust me, need this ;)
      if {[string match "movie:*" $input]} {
        regexp -- {^(.+?)<p class=e><table border=0 cellpadding=1 cellspacing=0>} $html - html
        regexp -- {/table><form action=/search><br>(.+?)<br> <br>} $html - no_search
      }

      # parse the html
      while {$results < $incith::google::search_results} {
        # the regexp grabs the data and stores them into their variables, while
        # the regsub removes the data, for the next loop to grab something new.

        # check if there was an alternate spelling first
        if {[string match "*</div><div id=res class=med><p>*" $html] == 1 && [string match "define:*" $input] == 0 && [string match "*&nocalc=1\">*" $html] == 0} {
          regexp -nocase -- {</div><div id=res class=med><p>(.+?)<a href=.*?>(.+?)</a>} $html {} titem did_you_mean
          regsub -all -- {</div><div id=res class=med><p>(.+?)</a>} $html {} html
          # sometimes calculator results are mixed into our alternate spelling.
          # we want to show these like we do our 'did you mean'
          if {[string match "*<img src=/images/calc_img*" $titem] == 1} {
            regexp -nocase -- {calc_img.+?nowrap.*?>(.+?)</td></tr>} $titem - titem
            set desc $titem
          } else {
            set desc "$titem$did_you_mean"
          }
	    if {$incith::google::bold_descriptions == 0 && [string match "\002" $incith::google::desc_modes] == 1} {
            regsub -all -- "\002" $desc {} desc
          }
          regexp -- {^(.+?)</td></tr>} $desc - desc
          regsub -all -- {<(.+?)>} $desc "" desc
          # did you mean and calculate have no link
          set link ""

### ONEBOX RESULTS ###

        # answers
        } elseif {[string match "*<table border=0 cellpadding=0 cellspacing=0 id=aob><tr><td><a href=*" $html]} {
          regexp -- {<table border=0 cellpadding=0 cellspacing=0 id=aob><tr><td><a href="http\://www.google.com/url\?q=(.+?)\&sa=X.+?">(.+?)<br>} $html - link desc
          regsub -- {<table border=0 cellpadding=0 cellspacing=0 id=aob><tr><td><a href=.+?<br>} $html - html
          regsub -- {<(.+?)>} $desc - desc
        # area codes
        } elseif {[string match "*/images/map_icon2.gif*" $html] == 1} {
          regexp -- {<div class=e>.+?<a href="(.+?)".+?">(.+?)</a>} $html - link desc
          regsub -- {/images/map_icon2.gif} $html {} html
          if {[info exists link] == 1 && $link != ""} {
        	set link [urldecode $link]
        	if {[string match "/url?q=http*" $link] == 1} {
	        regexp -- {/url\?q=(.+?q=.+?)&} $link - link
            }
          }
        # zip codes
        } elseif {[string match "*&oi=geocode_result*" $html] == 1} {
          regexp -- {<td valign=top><a href="(.+?)".*?>(.+?)</a>} $html - link desc
          regsub -all {\&oi=geocode_result} $html {} html
          if {[info exists link] == 1 && $link != ""} {
            set link "[urldecode $link]"
            if {[string match "/url?q=http*" $link] == 1} {
	        regexp -- {/url\?q=(.+?q=.+?)&} $link - link
            }
          }
        # music
        } elseif {[string match "*&oi=music&ct=result*" $html] == 1} {
          regexp -- {</td><td valign=top><a href=(.+?musica\?aid=.+?)\&.+?>(.+?)\002(.+?)\002} $html - link desc
          regsub -- {\&oi=music\&ct=result} $html {} html
          if {[info exists link] == 1 && $link != ""} {
            set link "[urldecode $link]"
            if {[string match "/url?q=http*" $link] == 1} {
	        regexp -- {/url\?q=(.+?q=.+?)&} $link - link
            }
          }
        # images
        } elseif {[string match "*&oi=images&ct=title*" $html] == 1} {
          regexp -- {<div class=e>.+?href="(http://images.+?)\&.+?">(.+?)</a>} $html - link desc
          regsub -- {\&oi=images\&ct=title} $html {} html
          if {[info exists link] == 1 && $link != ""} {
            set link "[urldecode $link]"
            if {[string match "/url?q=http*" $link] == 1} {
	        regexp -- {/url\?q=(.+?q=.+?)&} $link - link
            }
          }
        # travel info
        } elseif {[string match "*/images/airplane.gif*" $html] ==1} {
          regexp -- {<div class=e>.*?/images/airplane.gif.*?<td.+?valign=top.*?>(.*?)<a.+?href="(.+?)"(?:.*?)>(.+?)</a>} $html - d1 link d2
          regsub -- {<div class=e>.*?/images/airplane.gif.*?</a>} $html - html
          set desc "$d1 $d2"
        # UPC codes
        } elseif {[string match "*/images/barcode.gif*" $html] ==1} {
          regexp -- {<td valign=top><a href="(.+?)".*?>(.+?)</a>} $html - link desc
          regsub -- {<div class=e>.*?/images/barcode.gif.*?</a>} $html - html
        # weather!
        } elseif {[string match "*/images/weather/*" $html] == 1} {
          regexp -- {div class=e>.*?<div style.*?>(.+?)</div>.*?<div style="font.*?>(.+?)</div><div.*?>(.+?)<.+?>(.+?)<.+?>(.+?)<} $html - w1 w2 w3 w4 w5
          regexp -- {<div align=center style="padding:5px;float:left;font-size:84%">(.+?)<br>.+?src="/images/weather/(.+?)\.gif".*?<nobr>(.+?)</nobr>.+?<div align=center style="padding:5px;float:left;font-size:84%">(.+?)<br>.+?src="/images/weather/(.+?)\.gif".*?<nobr>(.+?)</nobr>.+?<div align=center style="padding:5px;float:left;font-size:84%">(.+?)<br>.+?src="/images/weather/(.+?)\.gif".*?<nobr>(.+?)</nobr>} $html - f1 f2 f3 f4 f5 f6 f7 f8 f9
          regsub -- {<div class=e>(.*?)</table} $html {} html
          # not all weather stations report 5 results at all times
          # this make up for when we only get 4, and does it gracefully
          if {[string match "*<*" $w5]} {
            set w5 ""
          } else {
            set w5 ", $w5"
          }
          # clean up our conditions
          set f2 [string totitle [string map {"_" " "} $f2]]
          set f5 [string totitle [string map {"_" " "} $f5]]
          set f8 [string totitle [string map {"_" " "} $f8]]
          # cut spaces out of temperatures
          set f3 [string map {" " ""} $f3]
          set f6 [string map {" " ""} $f6]
          set f9 [string map {" " ""} $f9]
          set desc "$w1\: $w2, $w3, $w4$w5; Forecast: $f1, $f2 \($f3\); $f4, $f5 \($f6\); $f7, $f8 \($f9\)"
          regsub -all -- {&deg;} $desc {°} desc
          set link ""
          regsub -all -- {weather} $input {} input
        # time:
        } elseif {[string match "*src=http://www.google.com/chart?chs*alt=\"Clock\"*" $html] == 1} {
          if {![regexp -- {alt="Clock"></td><td valign=top>(.+?)<br>} $html - desc]} {
            regexp -- {alt="Clock"></td><td valign=middle>(.+?)</td>} $html - desc
          }
          regsub -- {alt="Clock"} $html {} html
          set link ""
        # define:
        } elseif {[string match "*define:*" $input] == 1} {
          set output ""
          regexp -- {<ul type=.+?><li>(.+?)(?=\s*<li>|<br>).*<a href.*(http.+?)">} $html - desc link
          regsub -- {<u1 type=.+?><li>(.+?)(?=\s*<li>|<br>)} $html {} html
          regsub -all -- {\+} $input {%2B} define_input
          regsub -all -- { } $input {+} define_input
          if {[info exists link] == 1 && $link != ""} {
            regexp -- {(.+?)\&sig=} $link - link
            regexp -- {(.+?)\&usg=} $link - link
            set link "[urldecode $link]"
            regsub -all " " $link "%20" link
            append link " ( http://www.google.${titen}/search?q=${define_input} )"
          } else {
            if {![regexp -- {</td></tr></table><br>(.+?)<br><br>} $html - no_search]} {
              regexp -- {</td></tr></table><p>(.+?)<br><br>} $html - no_search
            }
            regsub -all -- {<(.+?)>} $no_search "" no_search
            return "${no_search}"
          }
        # finance / stock quotes
        } elseif {[string match "*<a href=\"/url\?q=http://finance.google.com/finance%3Fclient%3D*" $html] == 1} {
        	# this has to be one of the worst regexps ever written ! 
          regexp -- {<a href="/url\?q=http://finance.google.com/finance%3Fclient%3D.*?">(.*?)</a>(.*?)<.*?<td colspan=3 nowrap>(.+?)</td>.*?Mkt Cap:.*?<td.*?>(.+?)</td>} $html - tick name price mktcap
          regsub -- {<div class=e><div><a href="/url\?q=http://finance.google.com/finance%3Fclient%3D.*?">(.*?)</a>(.*?)<.*?<td colspan=3 nowrap>(.+?)</td>.*?Mkt Cap:.*?<td.*?>(.+?)</td>} $html {} html
          if {[info exists tick] == 1 && [info exists name] == 1 && [info exists name] == 1} {
            set desc "$tick: $name = $$price"
          	set link "http://finance.google.com/finance?q=$tick"
						regsub -all -- "\002" $link {} link
          	if {[info exists mktcap] == 1} { append desc " Mkt Cap: $mktcap" }
          	unset tick ; unset name ; unset price ; unset mktcap
          }
        # patents
        } elseif {[string match "*/images/magnifier.gif*" $html] ==1} {
          regexp -- {<td valign=top><a href="(http://patft.uspto.gov/.+?)".+?">(.+?)</a>} $html - link desc
          regsub -- {/images/magnifier.gif} $html {} html
        # calculator
        } elseif {[string match "*<img src=/images/calc_img*" $html] == 1} {
          set calc 1
          # remove bold codes from the html, not necessary here.
          regexp -nocase -- {calc_img.+?nowrap.*?>(.+?)</} $html - desc
          regexp -- {^(.+?)</td></tr>} $desc {} desc
          set link ""
        # whois
        } elseif {[string match "*&oi=prbx_whois*" $html] == 1} {
          if {[regexp -- {<h3 class=r.*?<a href="(.+?)".*?>((?!<).+?)</a>.+?<div style="margin.+?">(.+?)<br>} $html - link desc descwho]} {
            regsub -- {<h3 class=r.*?<a href=".+?".*?>(?!<).+?</a>.+?<div style="margin.+?">.+?<br>} $html "" html 
            append desc " \(${descwho}\)"
          }
          if {[info exists link] == 1 && $link != ""} {
            if {[string match "*\&sa\=X*" $link]} {
              regexp -- {(^.+?)&} $link - link
            }
          }

### END ONEBOX ###

        # movie: # special query - not onebox
        } elseif {[string match "movie:*" $input] == 1} {
          regexp -- {<td valign=top><a href="/movies/reviews\?cid=(.+?)&fq.+?">(.+?)</a>} $html - cid desc
          regsub -- {<td valign=top><a href="/movies/reviews\?cid=(.+?)</a>} $html {} html
          if {[info exists cid] == 1 } { set link "http://www.google.${titen}/movies/reviews?cid=${cid}" }
        # spell: # special query - not onebox
        } elseif {$spell == 1} {
          if {$did_you_mean != ""} {
            regexp {</td></tr></table><div id=res><p>(.+?)<} $html - titem
            set desc "${titem}${did_you_mean}"
            if {[string len $desc] < 2} {
              set desc $no_search
            }
          } else {
            if {$match != "Google"} {
              return "\002${match}\002 ${titem}"
            } else {
              return $did_you_mean$no_search
            }
          }
          set link ""
        # regular search
        } else {
          if {![regexp -- {class=g(?!b).*?<a href="(.+?)".*?>((?!<).+?)</a>} $html - link desc]} {
            regexp -- {class=r.*?<a href="(.+?)".*?>((?!<).+?)</a>} $html - link desc 
          }
          if {[info exists link] == 1} {
            if {[string match "*\&sa\=X*" $link]} {
              regexp -- {(^.+?)&} $link - link
            }
          }
          if {[info exists link] == 1} {
            if {[string match "*http*" $link] == 0} {
              set link ""
            } elseif {[string match *.pdf $link] == 1} {
              set desc "\[PDF\] $desc"
            }
          }
          # snip
          if {![regsub -- {class=g(?!b).*?<a href="(.+?)".*?>(.+?)</a>} $html {} html]} {
            regexp -- {class=r.*?<a href=".+?".*?>(?!<).+?</a>} $html "" html
          }
          # trim the description
          if {[info exists desc] == 1 && $incith::google::description_length > 0} {
            set desc [string range $desc 0 [expr $incith::google::description_length - 1]]
          }
        }

        # make sure we have something to send
        if {[info exists desc] == 0} {
          if {$match == "Google"} {
            if {[string match "*<img src=/images/calc_img*" $titem] == 1} {
              regexp -nocase -- {calc_img.+?nowrap>(.+?)</} $titem - desc
              regexp -- {^(.+?)</td></tr>} $desc - desc
              set reply "${desc}"
            } else {
              set reply "${no_search}"
            }
            return $reply
          }
          return $output
        }

        if {[info exists link] == 1} {
          if {[string match "*http*" $link] == 0} {
            set link ""
          }
        }

        # Make sure we dont have an ugly %00 style url (an encoded url also wont work on buggy webservers)
        # this is a duplicate if check for debugging purposes only - trust me, you wont miss the cpu time.
        if {[string match "*\%\[2-7\]\[0-9a-fA-F\]*" $link] == 1} {
        }

        # this removes trailing spaces from the description, and converts %20's to spaces
        # \017 is ^O, read by clients as 'stop bold/colors/underline'
        set desc [string trim $desc]
        regsub -all "%20" $desc " " desc
        regsub -all "<br>" $desc " " desc
        if {[info exists desc] == 1 && $incith::google::desc_modes != ""} { set desc "$incith::google::desc_modes[string trim $desc]" }

        # add the search result
        if {$calc == 0 && $spell == 0 && $populate == 0} {
          if {[info exists link] && $link != ""} {
            if {![string match "*define:*" $input]} {
              set link [urldecode $link]
              regsub -all " " $link "%20" link
            }
            if {$incith::google::link_modes != ""} { set link "$incith::google::link_modes[string trim $link]" }
            # added because of recent google changes, needed to clean-up *.google.* links
            if {[string match "*url\?*" $link]} {
              regexp -- {url\?q=(.+?)$} $link - link
              regexp -- {(.+?)\&sig=} $link - link
              regexp -- {(.+?)\&usg=} $link - link
              regexp -- {\?url=(.+?)$} $link - link
            }
            # top result may be news, at the moment it is too close to regular
            # search results to cull this out.. so in the meantime, this hack
            # will at least remove the 10,000 google tags at the end of the url
            # to keep it from spanning 2 lines of results.
            if {[string match "http://news.google*" $link]} {
               regexp -- {^(.+?)&hl=} $link - link
            }
            regsub -all "(?:\x93|\x94|&quot;|\")" $link {} link
            if {$incith::google::link_only == 1} { 
              append output "${link}\017${incith::google::seperator}"
            } else {
              append output "[descdecode $desc]\017 \@ ${link}\017${incith::google::seperator}"
            }
          } else {
            append output "[descdecode $desc]\017 ${incith::google::seperator}"
          }
        } else {
          set output "[descdecode $desc]\017"
        }

        # I've hard-coded it to only fetch one result for define lookups, and
        #   spell shouldn't ever have to loop.
        if {[string match "define:*" $input] == 1 || $spell == 1 || $calc == 1 || $break == 1 || $populate == 1 || $weather == 1} {
          break
        }

        # increase the results, clear the variables for the next loop
        unset link ; unset desc ; set spell 0 ; set calc 0 ; set break 0
        incr results
      }

      # make sure we have something to send
      if {$output == "" && ![string match "*:*" $input] && ![string match "*<img src=/images/calc_img*" $html] } {
        set reply "${no_search}"
        return $reply
      }
      return $output
    }

    # IMAGES
    # fetches a list of links to images from images.google.
    #
    proc images {input} {
      ; set results 0 ; set output ""; set match "" ; set titem "" ; set no_search "" ; set did_you_mean ""

      # if we don't want any search results, stop now.
      if {$incith::google::image_results <= 0} {
        return
      }

      # fetch the html
      set html [fetch_html $input 2]

      # user input causing errors?
	if {[string match -nocase "*socketerrorabort*" $html]} {
            regsub {(.+?)\|} $html {} html
            return "Socket Error accessing '${html}' .. Does it exist?"
	}
	if {[string match -nocase "*timeouterrorabort*" $html]} {
		return "Connection has timed out"
	}

      # strip out 'did you mean?' first
      # what do we call 'no search results in any language?'
      if {![regexp -- {--></script><div>(.+?)<br><br>} $html - no_search]} {
        if {![regexp -- {</a></div><div><p>(.+?)<br><br>} $html - no_search]} {
          regexp -- {<table border=0 cellpadding=0 cellspacing=0><tr><td class=j><br>(.+?)<br><br>} $html - no_search
        }
      }
      if {$no_search != ""} {
        regsub -- {</a>} $no_search "? " no_search
        regsub -all -- {<(.+?)>} $no_search { } no_search
        while {[string match "*  *" $no_search]} {
          regsub -all -- {  } $no_search " " no_search
        }
        set no_search [incithencode [string trim $no_search]]
      }

      # give results an output header with result tally.
      regexp -- {align=right nowrap>(.+?)\s\002(.+?)\(\002} $html - titem match
      if {![regexp -- {1\002\s-\s\002.+?\002.+?\002(.+?)\002} $match - match]} {
         set match "Google"
         set titem ""
      }
      regsub -all -- {<(.+?)>} $match {} match
      # format output according to variables.
      if {$incith::google::total_results != 0 && $match > 0} {
        set output "\002${match}\017 $titem${incith::google::seperator}"
        if {$incith::google::bold_descriptions == 0} {
          regsub -all -- "\002" $output {} output
        }
      } 

      # parse the html
      while {$results < $incith::google::image_results} {
        if {[regexp -- {<a.+?href=/imgres\?imgurl=(.+?)&imgrefurl} $html - link]} {
          regsub -- {<a.+?href=/imgres\?imgurl=(.+?)&imgrefurl} $html {} html
          regexp -- {<td valign=top align=center width=.+?style="padding-bottom:.+?">(.+?)<br>(.+?)<br>} $html - desc size
          regsub -- {<td valign=top align=center width=.+?style="padding-bottom:\d+px">.+?</td>} $html {} html
        }
        # if there's no link, return or stop looping, depending
        if {[info exists link] == 0} {
          if {$results == 0} {
            set reply $no_search
            return $reply
          } else {
            break
          }
        }

        # prevent duplicate results is mostly useless here, but will at least
        #   ensure that we don't get the exact same picture.
        if {[string match "*$link*" $output] == 1} {
          break
        }
        if {$link != "" && [info exists link] == 1 && $incith::google::link_modes != ""} { set link "$incith::google::link_modes[string trim $link]" }

        # add the search result
        # \017 is ^O, read by clients as 'reset color' (stop bold/etc)
        append output "[descdecode $desc] ($size) @ ${link}\017${incith::google::seperator}"

        # increase the results, clear the variables for the next loop just in case
        unset link; unset desc; unset size
        incr results
      }

      # make sure we have something to send
      if {$match == ""} {
        set reply "${no_search}"
        return $reply
      }
      return $output
    }

    # LOCAL
    # fetches a list of address & phone numbers from local.google.
    # -speechless updated
    proc local {input} {
      ; set results 0 ; set output ""; set match "" ; set titem "" ; set no_search "" ; set did_you_mean "" ; set titen ""

      # if we don't want any search results, stop now.
      if {$incith::google::local_results <= 0} {
        return
      }

      # fetch the html
      set html [fetch_html $input 3]

      # this isn't global, so we need to keep ctry (country) here
      regexp -nocase -- {^\.(.+?)\s(.+?)$} $input - titen input
      if {$titen == ""} {
        set titen "${incith::google::google_country}" 
      }

      # user input causing errors?
	if {[string match -nocase "*socketerrorabort*" $html]} {
            regsub {(.+?)\|} $html {} html
            return "Socket Error accessing '${html}' .. Does it exist?"
	}
	if {[string match -nocase "*timeouterrorabort*" $html]} {
		return "Connection has timed out"
	}

      # strip out 'did you mean?' first
      # what do we call 'no search results in any language?'
      regexp -- {</td></tr></table><br><p>(.+?)</p>} $html - no_search
      if {$no_search == ""} {
        if {[regexp -- {</div><br><table cellpadding=0 cellspacing=0><tr valign=top><td>(.+?)</td></tr></table>} $html - no_search]} {
          regsub -all -- {<br>} $no_search "; " no_search
          regsub -all -- {\002} $no_search "" no_search
          regsub -all -- {<(.+?)>} $no_search "" no_search
          set no_search [incithencode [string trim [string range $no_search 0 [expr [string length $no_search] - 3]]]]
        } else {
           regexp -- {</div><br><p>(.+?)</p>} $html - no_search
        }
      }

      # give results an output header with result tally.
      if {![regexp -- {<form name="qmod".*?<br/>(.+?)\s\002(.+?)</form>} $html - titem match]} {
        regexp -- {<form name="qmod".*?>(.+?)\s\002(.+?)</form>} $html - titem match
      }
      if {![regexp -- {1\002.*?-.*?\002.+?\002.+?\002(.+?)\002} $match - match]} {
         set match "Google"
         set titem ""
      }
      regsub -all -- {<(.+?)>} $match {} match
      # format output according to variables.
      if {$incith::google::total_results != 0 && $match > 0} {
        set output "\002${match}\017 [descdecode $titem]${incith::google::seperator}"
        if {$incith::google::bold_descriptions == 0} {
          regsub -all -- "\002" $output {} output
        }
      } 

      # parse the html
      while {$results < $incith::google::local_results} {

        # is this a special location?
        if {[regexp -- {<div class=mk style=".*?">.+?<div class="bn"><a href=".+?".*?>(.+?)</a>.+?<a class=a href="(.+?)"} $html - loc add1]} {
          regsub -- {<div class=mk style=".*?">.+?<div class="bn"><a href=".+?".*?>(.+?)</a>.+?<a class=a href="(.+?)"} $html {} html
          set add1 [urldecode $add1]
          regexp {&continue=(.+?)&ei=} $add1 - add1
        # this should just be a normal location
        } else {
          if {[regexp -- {<div class=m. style=".*?">.+?<div class="bn"><a href="/maps.f.+?".*?>(.+?)</a>.+?<div class="al.*?>(.+?)</div>} $html - loc add1]} {
            regsub -all -- {<(.+?)>} $add1 "" add1
          }
          regsub -- {<div class=m. style=".*?">.+?<div class="bn">.+?<div class="al.*?>.+?</div>} $html {} html
        }
        # if there's no link, return or stop looping, depending
        if {[info exists loc] == 0} {
          if {$results == 0} {
            set reply $no_search
            return $reply
          } else {
            return $output
            break
          }
        }

        if {[info exists add1]} { 
          regsub -all -- "<.*?nobr>" $add1 {} add1
          regsub -all -- "&lrm;" $add1 {} add1
          if {[info exists link] == 0} { set link "${add1}" }
          if {$incith::google::desc_modes != ""} { set loc "$incith::google::desc_modes${loc}" }
          if {$incith::google::link_modes != ""} { set link "$incith::google::link_modes${add1}\017" }
        }
        
        # add the search result
        # \017 is ^O, read by clients as 'reset color' (stop bold/etc)
        # add the search result
        if {$incith::google::link_only == 1} { 
          append output "${link}\017${incith::google::seperator}"
        } else {
          append output "[descdecode "${loc}\017 \@ ${link}"]\017${incith::google::seperator}"
        }

        # increase the results, clear the variables for the next loop just in case
        unset loc ; unset link
        incr results
      }

      # make sure we have something to send
      if {$match == ""} {
        set reply $no_search
        return $reply
      }
      return $output
    }

    # GROUPS
    # fetches a list of threads from groups.google.
    # -speechless updated
 
    proc groups {input} {
      ; set results 0 ; set output "" ; set match "" ; set no_search "" ; set titem "" ; set titen ""

      # if we don't want any search results, stop now.
      if {$incith::google::group_results <= 0} {
        return
      }

      # this isn't global, so we need to keep ctry (country) here
      regexp -nocase -- {^\.(.+?)\s(.+?)$} $input - titen dummy
      if {$titen == ""} {
        set titen "${incith::google::google_country}" 
      }

      # fetch the html
      set html [fetch_html $input 4]

      # user input causing errors?
	if {[string match -nocase "*socketerrorabort*" $html]} {
            regsub {(.+?)\|} $html {} html
            return "Socket Error accessing '${html}' .. Does it exist?"
	}
	if {[string match -nocase "*timeouterrorabort*" $html]} {
		return "Connection has timed out"
	}

      # strip out 'did you mean?' first
      # what do we call 'no search results in any language?'
      regexp -- {<div id=res><p>(.+?)</div><div>} $html - no_search
      if {$no_search != ""} {
        regsub -- {</a>} $no_search "? " no_search
        regsub -all -- {<(.+?)>} $no_search { } no_search
        while {[string match "*  *" $no_search]} {
          regsub -all -- {  } $no_search " " no_search
        }
        set no_search [incithencode [string trim $no_search]]
      }

      # give results an output header with result tally.
      regexp -- {</td><td align="right".*?>(.+?)\s\002(.+?)(\[|<)} $html - titem match
      if {![regexp -- {1\002\s-\s.+?\002.+?\002(.+?)\002} $match - match]} {
         set match "Google"
         set titem ""
      }
      regsub -all -- {<(.+?)>} $match {} match
      # format output according to variables.
      if {$incith::google::total_results != 0 && $match > 0} {
        set output "\002${match}\017 $titem${incith::google::seperator}"
        if {$incith::google::bold_descriptions == 0} {
          regsub -all -- "\002" $output {} output
        }
      } 

      # parse the html
      while {$results < $incith::google::group_results} {
        # this grabs a google group if one exists
        # this grabs a usenet group if one exists
        if {[regexp -- {<div class="gdrr"><a\s+href="(.+?)(?:\?|\").*?>(.+?)</a>.+?</td></tr></table>} $html {} thread desc]} {
          regsub -- {<div class="gdrr">(.+?)</td></tr></table>} $html "" html
        } elseif {[regexp -- {<div class="g".*?href="(.+?)".*?>(.+?)</a>} $html - thread desc]} {
          regsub -- {div class="g".*?href=".+?".*?>(.+?)</td></tr>} $html "" html
          if {[regexp -- {url\?q=(.+?)\&} $thread - thread]} {
            set thread [urldecode $thread]
            if {[string match "*groups.google*" $thread]} {
              regsub -- {\?.+?$} $thread "" thread
            }
          }
        }

        # if there's no desc, return or stop looping, depending
        if {[info exists desc] == 0} {
          if {$results == 0} {
            set reply $no_search
            return $reply
          } else {
            break
          }
        }

        if {[info exists desc] == 1 && $incith::google::description_length > 0} {
          set desc [string range $desc 0 [expr $incith::google::description_length - 1]]
          set desc [string trim $desc]
        }

        # make the link valid because we only got a partial href result, not a full url
        #set link "http://groups.google.${titen}/group/${thread}"
        set link $thread
        
        if {[info exists desc] == 1 && $incith::google::desc_modes != ""} { set desc "$incith::google::desc_modes[string trim $desc]" }
        if {$link != "" && [info exists link] == 1 && $incith::google::link_modes != ""} { set link "$incith::google::link_modes[string trim $link]" }

        # add the search result
        if {$incith::google::link_only == 1} { 
          append output "${link}\017${incith::google::seperator}"
        } else {
          append output "[descdecode $desc]\017 \@ ${link}\017${incith::google::seperator}"
        }

        # increase the results, clear the variables for the next loop just in case
        unset link; unset desc
        incr results
      }

      # make sure we have something to send
      if {$match == ""} {
        set reply $no_search
        return $reply
      }
      return $output
    }

    # NEWS
    # fetches the news from news.google.
    # -madwoota supplied, speechless updated
    #
    proc news {input} {
      ; set results 0 ; set output ""; set match ""
      ; set no_search "" ; set titem ""

      # if we don't want any search results, stop now.
      if {$incith::google::news_results <= 0} {
        return
      }
 
      # fetch the html
      set html [fetch_html $input 5]

      # user input causing errors?
	if {[string match -nocase "*socketerrorabort*" $html]} {
            regsub {(.+?)\|} $html {} html
            return "Socket Error accessing '${html}' .. Does it exist?"
	}
	if {[string match -nocase "*timeouterrorabort*" $html]} {
		return "Connection has timed out"
	}
      # strip out 'did you mean?' first
      # what do we call 'no search results in any language?'
      if {![regexp -- {valign=top><p>(.+?)<br/} $html - no_search]} {
        regexp -- {<div style="margin:.*?px; margin-top:.*?px; margin-bottom:.*?px;">(.+?)<br} $html - no_search
      }
      if {$no_search != ""} {
        regsub -- {</a>} $no_search "? " no_search
        regsub -all -- {<(.+?)>} $no_search { } no_search
        while {[string match "*  *" $no_search]} {
          regsub -all -- {  } $no_search " " no_search
        }
        set no_search [incithencode [string trim $no_search]]
      }

      # give results an output header with result tally.
      regexp -- {</td><td bgcolor=#efefef nowrap align=right width=40% style="padding-bottom:0">(.+?)\s\002(.+?)\(\002} $html - titem match
      if {![regexp -- {1\002\s-\s\002.+?\002.+?\002(.+?)\002} $match - match]} {
         set match "Google"
         set titem ""
      }
      regsub -all -- {<(.+?)>} $match {} match
      # format output according to variables.
      if {$incith::google::total_results != 0 && $match > 0} {
        set output "\002${match}\017 [descdecode $titem]${incith::google::seperator}"
        if {$incith::google::bold_descriptions == 0} {
          regsub -all -- "\002" $output {} output
        }
      }

      # We have to do a single regsub first to get down to the rough area in the html we need because
      # its just *not* very elegant attempting doing this in a single regexp. (Read: unreliable)
      #regsub -- {<html>(.+?)</div>} $html {} html

      # parse the html
      while {$results < $incith::google::news_results} {
        # somewhat extenuated regexp due to allowing that there *might* be
        # an image next to the story
        regexp -- {<td valign=top class=j><div class=lh><a href="(.+?)".*?>(.+?)</a>.+?<nobr>(.+?)</nobr>} $html {} link desc time
        regsub -- {<td valign=top class=j><div class=lh><a href="(.+?)".*?>(.+?)</a>} $html {} html

        # if there's no desc, return or stop looping, depending
        if {[info exists desc] == 0} {
          if {$results == 0} {
            set reply $no_search
            return $reply
          } else {
            break
          }
        }
        
        if {[info exists desc] == 1 && $incith::google::description_length > 0} {
          set desc [string range $desc 0 [expr $incith::google::description_length - 1]]
          set desc [string trim $desc]
        }

        # prevent duplicate results is mostly useless here, but will at least
        #   ensure that we don't get the exact same article.
        if {[string match "*$link*" $output] == 1} {
          break
        }
       
        if {[info exists desc] == 1 && $incith::google::desc_modes != ""} { set desc "$incith::google::desc_modes[string trim $desc]" }
        if {[info exists link] == 1 && $incith::google::link_modes != ""} { set link "$incith::google::link_modes[string trim $link]" }

        # add the search result
        if {$incith::google::link_only == 1} { 
          append output "${link}\017${incith::google::seperator}"
        } else {
          append output "[descdecode $desc] \017($time\) \@ ${link}\017${incith::google::seperator}"
        }

        # increase the results, clear the variables for the next loop just in case
        unset link; unset desc
        incr results
      }

      # make sure we have something to send
      if {$match == ""} {
        set reply $no_search
        return $reply
      }
      return $output
    }

    # PRINT
    # fetches book titles from books.google.
    # -madwoota supplied, -broken-
    # -speechless updated, fixed no longer using print.google
    #
    proc print {input} {
      ; set results 0 ; set output "" ; set titem "" ; set no_search "" ; set did_you_mean "" ; set titen ""
      ; set match ""
      # if we don't want any search results, stop now.
      if {$incith::google::print_results <= 0} {
        return
      }

      # this isn't global, so we need to keep ctry (country) here
      regexp -nocase -- {^\.(.+?)\s(.+?)$} $input - titen dummy
      if {$titen == ""} {
        set titen "${incith::google::google_country}" 
      }

      # fetch the html
      set html [fetch_html $input 6]

      # user input causing errors?
	if {[string match -nocase "*socketerrorabort*" $html]} {
            regsub {(.+?)\|} $html {} html
            return "Socket Error accessing '${html}' .. Does it exist?"
	}
	if {[string match -nocase "*timeouterrorabort*" $html]} {
		return "Connection has timed out"
	}

      # strip out 'did you mean?' first
      # what do we call 'no search results in any language?'
      if {![regexp -- {</td></tr></table><p>(.+?)(?!<br><p><br>)<br><p>} $html - no_search]} {
        regexp -- {</tr></table><br>(.+?)<br><p>} $html - no_search
      }
      # if we have a no search results message, let's format it for displaying possibly.
      if {$no_search != ""} {
        regsub -all -- {\002\002} $no_search "\002" no_search
        regsub -all -- {</a>} $no_search "? " no_search
        regsub -all -- {<(.+?)>} $no_search { } no_search
        while {[string match "*  *" $no_search]} {
          regsub -all -- {  } $no_search " " no_search
        }
        set no_search [incithencode [string trim $no_search]]
      }

      # give results an output header with result tally.
      regexp -- {</script></td><td align=right>(.+?)\s\002(.+?)\(\002} $html - titem match
      if {![regexp -- {1\002\s-\s\002.+?\002.+?\002(.+?)\002} $match - match]} {
         set match "Google"
         set titem ""
      }

      regsub -all -- {<(.+?)>} $match {} match
      # format output according to variables.
      if {$incith::google::total_results != 0 && $match > 0} {
        set output "\002${match}\017 $titem${incith::google::seperator}"
        if {$incith::google::bold_descriptions == 0} {
          regsub -all -- "\002" $output {} output
        }
      } 

      while {$results < $incith::google::print_results} {

        regexp -- {<div class=resbdy><h2 class="resbdy"><a href=".+?id=(.+?)&.+?">(.+?)</a></h2>(.+?)<br} $html {} id desc author
        regsub -- {<div class=resbdy><h2 class="resbdy"><a href=(.+?)</table>} $html "" html

        # if there's no desc, return or stop looping, depending
        if {![info exists desc]} {
          if {$results == 0} {
            set reply $no_search
            return $reply
          } else {
            break
          }
        }

        # this cleans up perhaps bad html cuts
        if {[info exists desc]} {
          regsub -all -- {<(.+?)>} $desc "" desc
          set desc [string trim $desc]
        }

        if {[info exists desc]} {
          regsub -all -- {<(.+?)>} $author "" author
          set author [string trim $author]
        }

        # make link by appending book id
        set link "http://books.google.${titen}?id=${id}"
   
        # prevent duplicate results is mostly useless here, but will at least
        # ensure that we don't get the exact same article.
        if {[string match "*$link*" $output] == 1} {
         break
        }
        append desc " (${author})"
        if {[info exists desc] == 1 && $incith::google::desc_modes != ""} { set desc "$incith::google::desc_modes[string trim $desc]" }
        if {[info exists link] == 1 && $incith::google::link_modes != ""} { set link "$incith::google::link_modes[string trim $link]" }

        # add the search result
        if {$incith::google::link_only == 1} { 
          append output "${link}\017${incith::google::seperator}"
        } else {
          append output "[descdecode $desc]\017 \@ ${link}\017${incith::google::seperator}"
        }

        # increase the results, clear the variables for the next loop just in case
        unset link ; unset desc
        incr results
      }

      # make sure we have something to send
      if {![info exists output]} {
        set reply $no_search
        return $reply
      }
      return $output
    }
  
    # GeoBytes
    # Fetches IP Location information
    # -speechless supplied
    #
    proc locate {input} {
      ; set results 0 ; set output ""
      ; set city "" ; set region "" ; set country ""
      ; set certainty "" ; set timezone "" ; set population ""
      ; set currency "" ; set proxy "" ; set curr "" ; 

      # if we don't want any search results, stop now.
      if {$incith::google::locate_results <= 0} {
        return
      }

      # fetch the html
      set ua "Lynx/2.8.5rel.1 libwww-FM/2.14 SSL-MM/1.4.1 OpenSSL/0.9.7e"
      set http [::http::config -useragent $ua]
      set url "http://www.geobytes.com/IpLocator.htm?GetLocation"
      set query [::http::formatQuery ipaddress $input]
      set http [::http::geturl $url -query $query -timeout [expr 1000 * 10]]
      set html [::http::data $http]
      ::http::cleanup $http

      # is site broken? if it is, say so
      if {![string match "*<html>*" $html]} {
        return "\002 GeoBytes Error:\002 Unable to access site. www.geobytes.com seems to be down."
      }

      #strip html tags
      regsub -all "\t" $html "" html
      regsub -all "\n" $html "" html
      regsub -all "\r" $html "" html
      regsub -all "\v" $html "" html
      regsub -all "&#039;" $html "'" html

      #parse html
      regexp -- {input.+?name="ro-no_bots_pls13".+?value="(.+?)".+?size} $html {} country
      regexp -- {input.+?name="ro-no_bots_pls15".+?value="(.+?)".+?size} $html {} region
      regexp -- {input.+?name="ro-no_bots_pls17".+?value="(.+?)".+?size} $html {} city
      regexp -- {input.+?name="ro-no_bots_pls18".+?value="(.+?)".+?size} $html {} certainty
      regexp -- {input.+?name="ro-no_bots_pls9".+?value="(.+?)".+?size} $html {} timezone
      regexp -- {input.+?name="ro-no_bots_pls3".+?value="(.+?)".+?size} $html {} population
      regexp -- {input.+?name="ro-no_bots_pls1".+?value="(.+?)".+?size} $html {} currency
      #currency sometimes has a trailing space, let's fix that with a dirty hack.
      set currency [string trim $currency]
      regexp -- {input.+?name="ro-no_bots_pls11".+?value="(.+?)".+?size} $html {} proxy
      regexp -- {input.+?name="ro-no_bots_pls".+?value="(.+?)".+?size} $html {} curr

      #in case we get blocked, say we did
      if {[string match "*temporarily blocked*" $html] == 1} {
       set output "\002GeoBytes Error:\002 (${input}) Reasonable useage limit has been exceeded. This bot has been temporarily blocked from accessing services. Please try back again later."
      }

      #if we can't read a country, assume there was nothing to lookup.
      if {$country == "" && $output == ""} {
        set output "\002GeoBytes Error:\002 (${input}) Undefined IP. Nothing to LookUp."
      } elseif {$output == ""} {
        set output "\002GeoBytes Location:\002 (${input}) @ ${city}, ${region}, ${country} (${certainty}%)\017 \[\002GMT:\002${timezone}\017\|\002Proxy:\002${proxy}\|${currency}\|${curr}\]"
      }
      if {$incith::google::bold_descriptions != 1 && [string match "\002" $incith::google::desc_modes] != 1} {
         regsub -all -- "\002" $output {} output
      }
      return $output
    }

    # VIDEO
    # fetches links to video with search data in it (video.google.com)
    # -madwoota supplied, speechless updated
    #
    proc video {input} {
      ; set results 0 ; set output ""; set match ""; set ded ""
      ; set titen "" ; set titem "" ; set no_search "" ; set did_you_mean ""

      # if we don't want any search results, stop now.
      if {$incith::google::video_results <= 0} {
        return
      }

      # this isn't global, so we need to keep ctry (country) here
      regexp -nocase -- {^\.(.+?)\s(.+?)$} $input - titen dummy
      if {$titen == ""} {
        set titen "${incith::google::google_country}" 
      }

      # fetch the html
      set html [fetch_html $input 7]

      # user input causing errors?
	if {[string match -nocase "*socketerrorabort*" $html]} {
            regsub {(.+?)\|} $html {} html
            return "Socket Error accessing '${html}' .. Does it exist?"
	}
	if {[string match -nocase "*timeouterrorabort*" $html]} {
		return "Connection has timed out"
	}

      # strip out 'did you mean?' first
      # what do we call 'no search results in any language?'
      if {![regexp -- {</td></tr></table><div><p class="gpadding">(.+?)<br><br>} $html - no_search]} {
        if {![regexp -- {</a></td></tr></table><p>(.+?)<br><br>} $html - no_search]} {
          if {![regexp -- {<div id="search-results">(.+?)<br/><br/>} $html - no_search]} {
            regexp -- {<div id="spell" class="Spelling".*?<p>(.+?)<br/><br/>} $html - no_search
          }
        }
      }
      if {$no_search != ""} {
        regsub -all -- {(<strong>|</strong>)} $no_search "\002" no_search
        regsub -- {</a>} $no_search "? " no_search
        regsub -- {</td>} $no_search ". " no_search
        regsub -all -- {<(.+?)>} $no_search "" no_search
        return [string trim $no_search] 
      }

      # give results an output header with result tally.
      regexp -- {</td></tr></table></td><td align="right".*?>(.+?)\s\002(.+?)\(\002} $html - titem match
      if {![regexp -- {1\002\s-\s\002.+?\002.+?\002(.+?)\002} $match - match]} {
         set match "Google"
         set titem ""
      }
      regsub -all -- {<(.+?)>} $match {} match
      # format output according to variables.
      if {$incith::google::total_results != 0} {
        set output "\002${match}\017 [descdecode $titem]${incith::google::seperator}"
        if {$incith::google::bold_descriptions == 0} {
          regsub -all -- "\002" $output {} output
        }
      } 

      # parse the html
      while {$results < $incith::google::video_results} {
        # somewhat extenuated regexp due to allowing that there might be an image next to the title
        regexp -- {class="rl-title".+?href="(.+?)" .+?>(.+?)</a>.+?<div class="rl-details">(.*?)(?:--|<br>).*?<div class="rl-snippet">(.*?)</div>} $html {} link desc ded ded2
        regsub -- {class="rl-title".+?href="(.+?)" .+?>(.+?)</a>.+?<div class="rl-details">(.*?)(?:--|<br>).*?<div class="rl-snippet">.*?</div>} $html "" html

        # if there's no desc, return or stop looping, depending
        if {[info exists desc] == 0} {
          if {$results == 0} {
            set reply $no_search
            return $reply
          } else {
            break
          }
        }

        set desc [string range $desc 0 [expr $incith::google::description_length - 1]]
        set desc [string trim $desc]
        # append narration to description for more detail unless its identical
        # keep description from becoming too lengthy and clean up trailing spaces
        regsub {<div class="description".+?</div>} $ded "" ded
        regexp {(.+?)\)--} $ded - ded
        regsub -all {<(.*?)>} $ded "" ded
        if {[string length $ded2]} { set ded2 "\([string range $ded2 0 [expr $incith::google::description_length - 1]]\017\)" }
        append desc " \017$ded2\([string trim $ded]\)"

        # make the link valid because we were only given a partial href result, not a full url
        if {[string match [string range $link 0 0] "/"]} {
          regsub -- {&.+?$} $link "" link
          set link "http://video.google.${titen}${link}"
        }

        # prevent duplicate results is mostly useless here, but will at least
        #   ensure that we don't get the exact same article.
        if {[string match "*$link*" $output] == 1} {
         break
        }
        # quick and dirty double-space remover
        while {[string match "*  *" $desc]} {
          regsub -all -- {  } $desc " " desc
        }
        set desc [string trim $desc]
        if {[info exists desc] == 1 && $incith::google::desc_modes != ""} { set desc "$incith::google::desc_modes[string trim $desc]" }
        if {[info exists link] == 1 && $incith::google::link_modes != ""} { set link "$incith::google::link_modes[string trim $link]" }

        # add the search result
        if {$incith::google::link_only == 1} { 
          append output "${link}${incith::google::seperator}"
        } else {
          append output "[descdecode $desc] @ ${link}\017${incith::google::seperator}"
        }

        # increase the results, clear the variables for the next loop just in case
        unset link; unset desc
        incr results
      }

      # make sure we have something to send
      if {$match == ""} {
        set reply $no_search
        return $reply
      }
      return $output
    }

    # FIGHT
    # google fight !
    #
    proc fight {input} {
      set output ""; set winner 0; set match1 0; set match2 0

      # if google fight is disabled, stop now.
      if {$incith::google::google_fight <= 0} {
        return
      }
      if {![regexp -nocase -- {^\.(.+?)\s(.+?)$} $input - country input]} {
        set country "${incith::google::google_country}" 
      }
      regexp -nocase -- {^(.+?) vs (.+?)$} $input - word1 word2
      if {![regexp -nocase -- {^\.(.+?)\s(.+?)$} $word2 - country2 word2]} {
        set country2 "${incith::google::google_country}"
      }

      # fetch the first result
      set html [fetch_html ".$country $word1" 8]
      # parse the html
      regexp -nocase {<div id=prs>.*?</div><p>(.+?)(?:\(\002|\[)} $html - matches1
      regsub -- {(?:\002|\s)1\002 - \0021\002} $matches1 "" matches1
      regsub -- {(?:\002|\s)1\002-\0021\002} $matches1 "" matches1
      regsub -nocase { of about } $matches1 "" matches1
      regsub -nocase -all {<a href.*?>} $matches1 "" matches1
      regsub -nocase -all {</a>} $matches1 "" matches1
      regexp -- {\002(.+?)\002} $matches1 - match1
      if {![string is digit $match1]} {
        regexp -- {\002(.+?)\002.*?\002(.+?)\002} $matches1 - dummy match1
        if {[string match $match1 $word1]} {
          regexp -- {\002(.+?)\002} $matches1 - match1
        }
      }

      # fetch the second result
      set html [fetch_html ".$country2 $word2" 8]
      # parse the html
      regexp -nocase {<div id=prs>.*?</div><p>(.+?)(?:\(\002|\[)} $html - matches2
      regsub -- {(?:\002|\s)1\002 - \0021\002} $matches2 "" matches2
      regsub -- {(?:\002|\s)1\002-\0021\002} $matches2 "" matches2
      regsub -nocase { of about } $matches2 "" matches2
      regsub -nocase -all {<a href.*?>} $matches2 "" matches2
      regsub -nocase -all {</a>} $matches2 "" matches2
      regexp -- {\002(.+?)\002} $matches2 - match2
      if {![string is digit $match2]} {
        regexp -- {\002(.+?)\002.*?\002(.+?)\002} $matches2 - dummy match2
        if {[string match $match2 $word2]} {
          regexp -- {\002(.+?)\002} $matches2 - match2
        }
      }

      if {![string match $country $country2]} { set country "$country and Google.$country2" }
      if {![info exists match1]} {
        set match1 "0"
        set match1expr "0"
      } else {
        regsub -all {(?:\.|,| )} $match1 "" match1expr
      }

      if {![info exists match2]} {
        set match2 "0"
        set match2expr "0"
      } else {
        regsub -all {(?:\.|,| )} $match2 "" match2expr
      }

      if {[expr $match2expr < $match1expr]} {
        set winner 1
      } elseif {[string match $match2expr $match1expr]} {
        set winner 3
      } else {
        set winner 2
      }

      if {$incith::google::bold_descriptions > 0 && $incith::google::desc_modes == ""} {
        set word1 "\002$word1\017"; set word2 "\002$word2\017"
        set match1 "\002 $match1\017"; set match2 "\002 $match2\017"
      } elseif {$incith::google::desc_modes != ""} {
        set word1 "$incith::google::desc_modes$word1\017"; set word2 "$incith::google::desc_modes$word2\017"
        set match1 "$incith::google::desc_modes $match1\017"; set match2 "$incith::google::desc_modes $match2\017"
      } else {
        set match1 " $match1"; set match2 " $match2"
      }

      if {$winner == 1} {
        set output "By results on Google.$country: $word1 beats $word2 by$match1 to$match2!"
      } elseif {$winner == 2} {
        set output "By results on Google.$country: $word2 beats $word1 by$match2 to$match1!"
      } else {
        set output "Google.$country could not determine the winner. $word2 ties $word1 with$match1 results."
      }

      # make sure we have something to send
      if {[info exists output] == 0} {
        set reply "Sorry, no search results were found. Something is wrong..."
        return $reply
      }
      return $output
    }

    # YOUTUBE
    # fetches links to video with search data in it (youtube.com)
    # -speechless supplied
    #
    proc youtube {input} {
     
      ; set results 0 ; set output "" ; set ded ""; set match "" ; set titem "" ; set titen ""

      # if we don't want any search results, stop now.
      if {$incith::google::youtube_results <= 0} {
        return      
      }

      # this isn't global, so we need to keep ctry (country) here
      regexp -nocase -- {^\.(.+?)\s(.+?)$} $input - titem dummy
      if {$titem == ""} {
        set titem "${incith::google::youtube_country}" 
      }

      # fetch the html
      set html [fetch_html $input 9]

      # user input causing errors?
	if {[string match -nocase "*socketerrorabort*" $html]} {
            regsub {(.+?)\|} $html {} html
            return "Socket Error accessing '${html}' .. Does it exist?"
	}
	if {[string match -nocase "*timeouterrorabort*" $html]} {
		return "Connection has timed out"
	}

      # give results an output header with result tally.
      if {![regexp -- {<div class="name">.+?</span>(.+?)<strong>.+?</strong>.+?<strong>([,\.0-9]{1,})</strong>} $html - titen match]} {
        set match "YouTube"
        set titen "results"
      }

      # format output according to variables.
      if {$match != ""} {
        set output "\002${match}\002 ${titen}${incith::google::seperator}"
        if {$incith::google::bold_descriptions == 0} {
          regsub -all -- "\002" $output {} output
        }
      }

      # parse the html
      while {$results < $incith::google::youtube_results} {
        # somewhat extenuated regexp due to allowing that there might be an image next to the title
        regexp -nocase {id="video-short.*?href="/watch\?v=(.+?)".+?title=".+?">(.+?)</a>.*?class="video\-description">(.+?)</div.*?class="video\-date\-added">(.+?)</span.*?class="video\-view\-count">(.+?)</span.+?id="video-run-time.+?">(.+?)</span} $html - cid desc ded ded2 ded3 ded4
        if {[regexp -nocase {<div class="marT10">(.+?)(</div></div>|</div><div>|</a></div>|<\!--)} $html - reply]} {
          regsub -all -nocase {<div class="marT10">.+?(?:</div></div>|</div><div>|</a></div>|<\!--)} $html "" html
          regsub -all {<td>} $reply ". " reply
          regsub -all -- {<(.+?)>} $reply "" reply
          if {$results == 0} { append output "[descdecode [string trim $reply]]\017${incith::google::seperator}" }
        }
        regexp -nocase {<a id="video-short.*?href="/watch\?v=(.+?)".+?title=".+?">(.+?)</a>.*?class="video\-description">(.+?)</div.*?class="video\-date\-added">(.+?)</span.*?class="video\-view\-count">(.+?)</span} $html - cid desc ded ded2 ded3
        if {![regexp -nocase {id="video-run-time.+?">(.+?)</span} $html - ded4]} {
          set ded4 "n/a"
        }
        regsub -nocase {id="video-short.*?href="/watch\?v=.+?".+?title=".+?">.+?</a>.+?class="video\-description">.+?</div></div>} $html "" html
        if {[info exists desc] == 0} {
          if {$results == 0} {
            return [descdecode $reply]
          } else {
            break
          }
        }


        # keep description from becoming too lengthy and clean up trailing spaces
        if {[info exists desc]} {
          set ded [string range $ded 0 [expr $incith::google::description_length - 1]]
          set desc [string range $desc 0 [expr $incith::google::description_length - 1]]
          set desc [string trim $desc]
        }

        # append length to description for more detail
        if {[info exists ded] && [info exists desc]} {
          set ded [string trim $ded]
          if {[info exists ded4]} {
            append desc "\017 (${ded}\017) (${ded4}; ${ded2}; ${ded3})"
          } else {
            append desc "\017 (${ded}\017)"
          }
        }

        # make the link valid because we were only given a partial href result, not a full url
        if {$titem == "com" } {
          set link "http://youtube.com/watch?v=${cid}"
        } else {
          set link "http://${titem}.youtube.com/watch?v=${cid}"
        }
        # fullscreen window link - http://youtube.com/v/${cid}

        if {[info exists desc] == 1 && $incith::google::desc_modes != ""} { set desc "$incith::google::desc_modes[string trim $desc]" }
        if {[info exists link] == 1 } {
          if {$incith::google::youtube_highquality != 0 } { append link "&fmt=18" }
          if {$incith::google::link_modes != ""} { set link "$incith::google::link_modes[string trim $link]" }
        }

        # add the search result
        if {$incith::google::link_only == 1} { 
          append output "${link}\017${incith::google::seperator}"
        } else {
          append output "[descdecode $desc]\017 \@ ${link}\017${incith::google::seperator}"
        }

        # increase the results, clear the variables for the next loop just in case
        unset link; unset desc ; set ded ""
        incr results
      }
      return $output
    }

    # MYSPACEVIDS
    # fetches links to video with search data in it (videosearch.myspace.com)
    # -speechless supplied
    #
    proc myspacevids {input} {

      ; set results 0 ; set output "" ; set ded ""; set match "" ; set rating ""

      # if we don't want any search results, stop now.
      if {$incith::google::myspacevids_results <= 0} {
        return      
      }

      # fetch the html
      set html [fetch_html $input 11]

      # this is to account for ip location multilanguage feature that myspace has
      regexp -- {<a id="upload_videos_link" href="/index.cfm?fuseaction=vids.upload">.*?\s(.+?)<} $html "" videos
      if {![info exists videos]} {set videos "videos"}

      # give results an output header with result tally.
      regexp -- {<div class="paging"><div class="listing">.*?1-.*?\s.*?\s(.+?)</div} $html - match

      # format output according to variables.
      if {$match != ""} {
        set output "\002${match}\002 $videos${incith::google::seperator}"
        if {$incith::google::bold_descriptions == 0} {
          regsub -all -- "\002" $output {} output
        }
      }

      # We have to do a single regsub first to get down to the rough area in the html we need because
      # its just *not* very elegant attempting doing this in a single regexp. (Read: unreliable)
      #regsub {<td.+?class(.+?)</tr></table>} $html "" html

      # parse the html
      while {$results < $incith::google::myspacevids_results} {
        # somewhat extenuated regexp due to allowing that there might be an image next to the title

        regexp -nocase {<div class="rating">.+?<strong>(.+?)<.+?<h2 class="title"><a href=".+?\&videoid=(.+?)">(.+?)</a>.+?<strong>(.+?)<} $html {} rating cid desc ded
        regsub -nocase {<div class="rating">.+?<strong>.+?</a></td>} $html "" html
        # if there's no desc, return or stop looping, depending
        if {[info exists desc] == 0 } {
          if {$results == 0} {
            regexp -- {div class="feedback empty">(.+?)</div>} $html - reply
            return $reply
          } else {
            break
          }
        }

        # duplicate link filter, clumsy indeed.. will remove soon and fix properly
        if {[string match "*${cid}*" $output] == 1} {
          break
        }

        # keep description from becoming too lengthy and clean up trailing spaces
        if {[info exists desc]} {
          set desc "${desc} (\002${rating}\002)(${ded})"
          #set desc [string trim [string range $desc 0 [expr $incith::google::description_length - 1]]]
        }

        # make the link valid because we were only given a partial href result, not a full url
        set link "http://vids.myspace.com/index.cfm?fuseaction=vids.individual&videoid=${cid}"

        if {[info exists desc] == 1 && $incith::google::desc_modes != ""} { set desc "$incith::google::desc_modes[string trim $desc]" }
        if {[info exists link] == 1 && $incith::google::link_modes != ""} { set link "$incith::google::link_modes[string trim $link]" }

        # add the search result
        if {$incith::google::link_only == 1} { 
          append output "${link}\017${incith::google::seperator}"
        } else {
          append output "[descdecode $desc]\017 \@ ${link}\017${incith::google::seperator}"
        }

        # increase the results, clear the variables for the next loop just in case
        unset link; unset desc
        incr results
      }

      # make sure we have something to send
      if {$match == ""} {
        regexp -- {div class="feedback empty">(.+?)</div>} $html - reply
        return $reply
      }
      return $output
    }

    # trans
    # google translation -(www.google.com\translate_t?)
    # -speechless supplied
    #
    proc trans {input} {
      global incithcharset
      ; set results 0 ; set output ""; set match "" ; set titem ""

      # if we don't want any search results, stop now.
      if {$incith::google::trans_results <= 0} {
        return      
      }

      # split up stuff
      regexp -nocase -- {^(.+?)@(.+?)\s(.+?)$} $input - link desc titem
      # fetch the html
      set ua "Lynx/2.8.5rel.1 libwww-FM/2.14 SSL-MM/1.4.1 OpenSSL/0.9.7e"
      set http [::http::config -useragent $ua -urlencoding "iso8859-1"]
      set url "http://www.google.com/translate_t?"
      set query [::http::formatQuery text $titem sl "${link}" tl "${desc}" ]
	catch {set http [::http::geturl "$url" -query $query -timeout [expr 1000 * 10]]} error

      # CHECK CHECK
      upvar #0 $http state
      set incithcharset [string map -nocase {"UTF-" "utf-" "iso-" "iso" "windows-" "cp" "shift_jis" "shiftjis"} $state(charset)]
      if {$incith::google::debug > 0} {
        putserv "privmsg $incith::google::debugnick :\002url:\002 $url$query \002\037charset:\002\037 [string map -nocase {"iso-" "iso" "windows-" "cp" "shift_jis" "shiftjis"} $incithcharset]"
      }
	if {[string match -nocase "*couldn't open socket*" $error]} {
		return "Socket Error accessing '${url}' .. Does it exist?"
	}
	if { [::http::status $http] == "timeout" } {
		return "Connection has timed out"
	}
      set html [::http::data $http]
      ::http::cleanup $http

      regsub -all -nocase {<sup>(.+?)</sup>} $html {^\1} html
      regsub -all -nocase {<font.+?>} $html "" html
      regsub -all -nocase {</font>} $html "" html
      regsub -all -nocase {<span.*?>} $html "" html
      regsub -all -nocase {</span>} $html "" html
      regsub -all -nocase {<input.+?>} $html "" html
      regsub -all -nocase {(?:<i>|</i>)} $html "" html
      regsub -all -nocase {<i style.*?>} $html "" html
      regsub -all "\t" $html " " html
      regsub -all "\n" $html " " html
      regsub -all "\r" $html " " html
      regsub -all "\v" $html " " html
      regsub -all "</li>" $html ". " html
      regsub -all ";;>" $html "" html

      # make sure everything is lowercase.
      set desc [string tolower $desc]
      set link [string tolower $link]
      if {![regexp -- {</td><td id=autotrans style="display: block">(.+?)</td></tr>} $html {} detect]} {set detect ""}
      regexp -- {<textarea name=utrans.+?id=suggestion>(.+?)</textarea>} $html - match
      if {$match != ""} {
        return "Google says\: \(${link}\-\>${desc}\)\ [incithencode [descdecode "$detect >> ${match}"]]"
      } else {
        return "Google error\: \(${link}\-\>${desc}\)\ [incithencode [descdecode "$detect."]]"
      }
      return $output
    }

    # MININOVA TORRENT HUNT
    # fetches torrent links from mininova. (mininova.com)
    # -speechless supplied
    #
    proc mininova {input} {

      ; set results 0 ; set output ""; set match "" ; set ebcSP "" ; set match2 ""

      # if we don't want any search results, stop now.
      if {$incith::google::mininova_results <= 0} {
        return      
      }

      #regsub -all {-} $input { } input
      # fetch the html
      set html [fetch_html $input 51]

      # give results an output header with result tally.
      regexp -- {<h1>(?!No).*?\((.+?)\s(.+?)\)} $html - match match2
      # format output according to variables.
      if {$incith::google::total_results != 0} {
        set output "\002${match}\017 ${match2} ${incith::google::seperator}"
        if {$incith::google::bold_descriptions == 0} {
          regsub -all -- "\002" $output {} output
        }
      }
      regsub {<tr.*?>(.+?)</tr>} $html "" html

      # parse the html
      while {$results < $incith::google::mininova_results && $match != ""} {
        # this could break any second, its cumbersome and long..i know, but for now it works.
        regexp -nocase {<tr.*?>(.+?)</tr>} $html - htm
        regsub {<tr.*?>(.+?)</tr>} $html "" html
        regexp -nocase {<td>(.+?)</td><td><a href="/cat.+?>(.+?)</a>.+?<a href="/get/(.*?)".+?">.+?<a href="/tor.+?">(.+?)</a>} $htm - ebcU ebcI ebcBid ebcPR
        regexp -nocase {<td align="right">(.+?)</td><td align="right">(.+?)</td><td align="right">(.+?)</td>} $htm - ebcShpNew ebcTim ebcCheck
        regexp -nocase {title="Tracker URL: (.+?)"} $htm - ebcSP
        if {$ebcSP != ""} {
          set ebcSP "\037${ebcSP}\037 "
        }
        # keep torrent name from becoming too lengthy
        if {[info exists ebcPR]} {
          set ebcPR [string range $ebcPR 0 [expr $incith::google::description_length - 1]]
          set ebcPR [string trim $ebcPR]
        }
 
        # check results are more than 0, return or stop looping, depending
        if {$match < 1 } {
          if {$results == 0} {
            regexp -nocase {<h1>(.+?)</h1><p>} $html - reply
            if {![regexp -nocase {</h1><p>(.+?)</p><p>} $html - reply2]} { set reply2 "" } {
              if {![string match *Didn't* $reply2]} { regsub -all -- {<(.+?)>} $reply2 "" reply2 ; set reply2 ". $reply2" } { set reply2 "" }
            }
            regsub -all -- {<(.+?)>} $reply "" reply
            return "$reply$reply2"
          } else {
            break
          }
        }

        # make the link valid because we were only given a partial href result, not a full url
        set link "http://mininova.org/get/${ebcBid}"

        # prevent duplicate results is mostly useless here, but will at least
        # ensure that we don't get the exact same article.
        if {[string match "*$link*" $output] == 1} {
          break
        }

        # fix up our variables so the output looks purdy.
        set desc "${ebcU}/${ebcI} ${ebcSP}\002${ebcPR}\017 (${ebcShpNew}, ${ebcTim}s, ${ebcCheck}p)"

        if {[info exists desc] == 1 && $incith::google::desc_modes != ""} { set desc "$incith::google::desc_modes[string trim $desc]" }
        if {[info exists link] == 1 && $incith::google::link_modes != ""} { set link "$incith::google::link_modes[string trim $link]" }

        # add the search result
        if {$incith::google::link_only == 1} { 
          append output "${link}\017${incith::google::seperator}"
        } else {
          append output "[descdecode $desc]\017 \@ ${link}\017${incith::google::seperator}"
        }

        # increase the results, clear the variables for the next loop just in case
        unset link ; set ebcCheck "" ; set ebcU "" ; set ebcSP ""
        incr results
      }

      # make sure we have something to send
      if {$match == ""} {
        regexp -nocase {<h1>(.+?)</h1><p>} $html - reply
        if {![regexp -nocase {</h1><p>(.+?)</p><p>} $html - reply2]} { set reply2 "" } {
          if {![string match *Didn't* $reply2]} { regsub -all -- {<(.+?)>} $reply2 "" reply2 ; set reply2 ". $reply2" } { set reply2 "" }
        }
        regsub -all -- {<(.+?)>} $reply "" reply
        return "$reply$reply2"
      }
      regsub -all -- " " $input "+" input
      append output "www.mininova.org/search/${input}/seeds"
      #append output "www.mininova.org/search/?search=${input}"
      return $output
    }

    # DAILYMOTION
    # fetches links to video with search data in it (dailymotion.com)
    # -speechless supplied
    #
    proc dailymotion {input} {

      ; set results 0 ; set output "" ; set titem ""

      # if we don't want any search results, stop now.
      if {$incith::google::daily_results <= 0} {
        return      
      }

      # this isn't global, so we need to keep ctry (country) here
      regexp -nocase -- {^\.(.+?)\s(.+?)$} $input - titem dummy
      if {$titem == ""} {
        set titem "${incith::google::daily_country}" 
      }

      # fetch the html
      set html [fetch_html $input 14]

      # user input causing errors?
	if {[string match -nocase "*socketerrorabort*" $html]} {
            regsub {(.+?)\|} $html {} html
            return "Socket Error accessing '${html}' .. Does it exist?"
	}
	if {[string match -nocase "*timeouterrorabort*" $html]} {
		return "Connection has timed out"
	}

      if {[string match "*videos_list_empty*" $html]} {
        set reply "Sorry, no search results were found."
        return $reply
      }

      set output "DailyMotion${incith::google::seperator}"
      if {$incith::google::bold_descriptions != 0} {
        set output "\002DailyMotion\002${incith::google::seperator}"
      }
      
      # parse the html
      while {$results < $incith::google::daily_results} {
        # somewhat extenuated regexp due to allowing that there might be an image next to the title
        regexp -nocase {<div class="dmco_text duration">(.+?)<.*?<div class="dmco_text language">(.+?)<.+?<h4 class="dmco_title.*?>.*?<a class=.+?href=.*?/video/(.+?)_.*?">(.+?)<.*?<div class="dmco_date">(.+?)<.*?<div class="dmco_counter foreground.*?>(.+?)<} $html {} match lan cid desc date vote
        regsub -nocase {<div class="dmco_text duration">.+?<.*?<div class="dmco_text language">.+?<.+?<h4 class="dmco_title.*?>.*?<a class=.+?href=.*?/video/.+?_.*?">.+?<.*?<div class="dmco_date">.+?<.*?<div class="dmco_counter foreground.*?>.+?<}  $html "" html

        # if there's no desc, return or stop looping, depending
        if {[info exists desc] == 0} {
          if {$results == 0} {
            set reply "Sorry, no search results were found."
            return $reply
          } else {
            break
          }
        }
        set desc [string trim $desc]
        set desc "${desc} (${match} \002${lan}\002 ${date} - [string trim $vote])"

        # make the link valid because we were only given a partial href result, not a full url
        set link "http://www.dailymotion.com/${titem}/video/${cid}"

        # prevent duplicate results is mostly useless here, but will at least
        #   ensure that we don't get the exact same article.
        if {[string match "*$link*" $output] == 1} {
         break
        }

        if {[info exists desc] == 1 && $incith::google::desc_modes != ""} { set desc "$incith::google::desc_modes[string trim $desc]" }
        if {[info exists link] == 1 && $incith::google::link_modes != ""} { set link "$incith::google::link_modes[string trim $link]" }

        # add the search result
        if {$incith::google::link_only == 1} { 
          append output "${link}\017${incith::google::seperator}"
        } else {
          append output "[descdecode $desc]\017 \@ ${link}\017${incith::google::seperator}"
        }

        # increase the results, clear the variables for the next loop just in case
        unset link; unset desc ; unset cid
        incr results
      }

      # make sure we have something to send
      if {[info exists output] == 0} {
        set reply "Sorry, no search results were found."
        return $reply
      }
      return $output
    }

    # GAMEFAQS
    # fetches upcoming game list variable by system and region (gamefaqs.com)
    # this is far better than any gamefaqs procedure you've seen before, this is looooong, but very simple
    # in it's approach. I learned alot coding it.
    # -speechless supplied
    #
    proc gamefaqs {system region} {

      ; set results 0 ; set output "" ; set html "" ; set match 0 ; set game "" ; set date ""

      # if we don't want any search results, stop now.
      if {$incith::google::gamefaq_results <= 0} {
        return      
      }

      # strip excessive spaces from region and system desired.
      regsub -all " " $system "" system
      regsub -all " " $region "" region

      # this is where most of the work is done
      # parsing systems and regions to create an output header
      # and cut the html down to the specified region

      if {[string match -nocase "nds" $system] == 1} {
        if {[string match -nocase "usa" $region] == 1} {
          set html [fetch_html "\?limiter=1" 15]
          set output "\002NDS North America (USA)\002"
        }
        if {[string match -nocase "jap" $region] == 1} {
          set html [fetch_html "\?limiter=2" 15]
          set output "\002NDS Asia (JAPAN)\002"         
        }
        if {[string match -nocase "eur" $region] == 1} {
          set html [fetch_html "\?limiter=3" 15] 
          set output "\002NDS Europe (UK)\002"
        }
        if {[string match -nocase "aus" $region] == 1} {
          set html [fetch_html "\?limiter=4" 15]
          set output "\002NDS Australia (AUS)\002"
        }
      }

      if {[string match -nocase "gba" $system] == 1} {
        if {[string match -nocase "usa" $region] == 1} {
          set html [fetch_html "\?limiter=1" 16]  
          set output "\002GBA North America (USA)\002"
        }
        if {[string match -nocase "jap" $region] == 1} {
          set html [fetch_html "\?limiter=2" 16]
          set output "\002GBA Asia (JAPAN)\002"
        }
        if {[string match -nocase "eur" $region] == 1} {
          set html [fetch_html "\?limiter=3" 16]
          set output "\002GBA Europe (UK)\002"
        }
        if {[string match -nocase "aus" $region] == 1} {
          set html [fetch_html "\?limiter=4" 16]
          set output "\002GBA Australia (AUS)\002"
        }
      }

      if {[string match -nocase "psp" $system] == 1} {
        if {[string match -nocase "usa" $region] == 1} {
          set html [fetch_html "\?limiter=1" 17]
          set output "\002PSP North America (USA)\002"
        }
        if {[string match -nocase "jap" $region] == 1} {
          set html [fetch_html "\?limiter=2" 17]
          set output "\002PSP Asia (JAPAN)\002"
        }
        if {[string match -nocase "eur" $region] == 1} {
          set html [fetch_html "\?limiter=3" 17]
          set output "\002PSP Europe (UK)\002"
        }
        if {[string match -nocase "aus" $region] == 1} {
          set html [fetch_html "\?limiter=4" 17]
          set output "\002PSP Australia (AUS)\002"
        }
      }

      if {[string match -nocase "x360" $system] == 1} {
        if {[string match -nocase "usa" $region] == 1} {
          set html [fetch_html "\?limiter=1" 18]
          set output "\002XBOX360 North America (USA)\002"
        }
        if {[string match -nocase "jap" $region] == 1} {
          set html [fetch_html "\?limiter=2" 18]
          set output "\002XBOX360 Asia (JAPAN)\002"
        }
        if {[string match -nocase "eur" $region] == 1} {
          set html [fetch_html "\?limiter=3" 18]    
          set output "\002XBOX360 Europe (UK)\002"
        }
        if {[string match -nocase "aus" $region] == 1} {
          set html [fetch_html "\?limiter=4" 18]
          set output "\002XBOX360 Australia (AUS)\002"
        }
      }

      if {[string match -nocase "xbox" $system] == 1} {
        if {[string match -nocase "usa" $region] == 1} {
          set html [fetch_html "\?limiter=1" 19]
          set output "\002XBOX North America (USA)\002"
        }
        if {[string match -nocase "jap" $region] == 1} {
          set html [fetch_html "\?limiter=2" 19]
          set output "\002XBOX Asia (JAPAN)\002"
        }
        if {[string match -nocase "eur" $region] == 1} {
          set html [fetch_html "\?limiter=3" 19]   
          set output "\002XBOX Europe (UK)\002"
        }
        if {[string match -nocase "aus" $region] == 1} {
          set html [fetch_html "\?limiter=4" 19]
          set output "\002XBOX Australia (AUS)\002"
        }
      }

      if {[string match -nocase "gc" $system] == 1} {
        if {[string match -nocase "usa" $region] == 1} {
          set html [fetch_html "\?limiter=1" 20]
          set output "\002GAMECUBE North America (USA)\002"
        }
        if {[string match -nocase "jap" $region] == 1} {
          set html [fetch_html "\?limiter=2" 20]
          set output "\002GAMECUBE Asia (JAPAN)\002"
        }
        if {[string match -nocase "eur" $region] == 1} {
          set html [fetch_html "\?limiter=3" 20]
          set output "\002GAMECUBE Europe (UK)\002"
        }
        if {[string match -nocase "aus" $region] == 1} {
          set html [fetch_html "\?limiter=4" 20]
          set output "\002GAMECUBE Australia (AUS)\002"
        }
      }

      if {[string match -nocase "ps2" $system] == 1} {
        if {[string match -nocase "usa" $region] == 1} {
          set html [fetch_html "\?limiter=1" 21]
          set output "\002PS2 North America (USA)\002"
        }
        if {[string match -nocase "jap" $region] == 1} {
          set html [fetch_html "\?limiter=2" 21]
          set output "\002PS2 Asia (JAPAN)\002"
        }
        if {[string match -nocase "eur" $region] == 1} {
          set html [fetch_html "\?limiter=3" 21] 
          set output "\002PS2 Europe (UK)\002"
        }
        if {[string match -nocase "aus" $region] == 1} {
          set html [fetch_html "\?limiter=4" 21]
          set output "\002PS2 Australia (AUS)\002"
        }
      }

      if {[string match -nocase "pc" $system] == 1} {
        if {[string match -nocase "usa" $region] == 1} {
          set html [fetch_html "\?limiter=1" 22]
          set output "\002PC North America (USA)\002"
        }
        if {[string match -nocase "jap" $region] == 1} {
          set html [fetch_html "\?limiter=2" 22]
          set output "\002PC Asia (JAPAN)\002"
        }
        if {[string match -nocase "eur" $region] == 1} {
          set html [fetch_html "\?limiter=3" 22]
          set output "\002PC Europe (UK)\002"
        }
        if {[string match -nocase "aus" $region] == 1} {
          set html [fetch_html "\?limiter=4" 22]
          set output "\002PC Australia (AUS)\002"
        }
      }

      if {[string match -nocase "ps3" $system] == 1} {
        if {[string match -nocase "usa" $region] == 1} {
          set html [fetch_html "\?limiter=1" 23]
          set output "\002PS3 North America (USA)\002"
        }
        if {[string match -nocase "jap" $region] == 1} {
          set html [fetch_html "\?limiter=2" 23]
          set output "\002PS3 Asia (JAPAN)\002"
        }
        if {[string match -nocase "eur" $region] == 1} {
          set html [fetch_html "\?limiter=3" 23]
          set output "\002PS3 Europe (UK)\002"
        }
        if {[string match -nocase "aus" $region] == 1} {
          set html [fetch_html "\?limiter=4" 23]
          set output "\002PS3 Australia (AUS)\002"
        }
      }

      if {[string match -nocase "wii" $system] == 1} {
        if {[string match -nocase "usa" $region] == 1} {
          set html [fetch_html "\?limiter=1" 28]
          set output "\002Wii North America (USA)\002"
        }
        if {[string match -nocase "jap" $region] == 1} {
          set html [fetch_html "\?limiter=2" 28]
          set output "\002Wii Asia (JAPAN)\002"
        }
        if {[string match -nocase "eur" $region] == 1} {
          set html [fetch_html "\?limiter=3" 28]
          set output "\002Wii Europe (UK)\002"
        }
        if {[string match -nocase "aus" $region] == 1} {
          set html [fetch_html "\?limiter=4" 28]
          set output "\002Wii Australia (AUS)\002"
        }
      }

      if {[string match -nocase "dc" $system] == 1} {
        if {[string match -nocase "jap" $region] == 1} {
          set html [fetch_html "\?limiter=2" 29]
          regexp -- {<h2>Japan</h2>(.+?)</table>} $html {} html
          set output "\002Dreamcast Asia (JAPAN)\002"
        }
      }

      # remove the bold if it isn't desired.
      if {$incith::google::bold_descriptions == 0} {
        regsub -all -- "\002" $output {} output
      }

      # parse for results and loop until desired amount of results
      # is attempted to be reached if possible.
      while {$results < $incith::google::gamefaq_results && $output != ""} {

        # grab date and game title and clear future html of it for looping
        regexp -nocase {<tr.*?td>(.*?)<.+?td><td><a.+?href.+?title.+?"(.+?)">.+?<.+?a><.+?td>} $html {} date game
        regsub {<tr.*?td>(.+?)<.+?a><.+?td>} $html "" html

        # add the search result
        # if there is a date, add date in bold and game to $output
        if {[string len $date] > 3} {
          if {$incith::google::bold_descriptions == 0} {
            append output "${incith::google::seperator}${date} ${game}"
          } else {
            append output "${incith::google::seperator}\002${date}\002 ${game}"
          }
        # otherwise just add name of game
        } elseif {[string len $game] > 1}  {
          append output "${incith::google::seperator}${game}"
          #append output ",${game}"
        }

        # increase the results, clear the variables for the next loop just in case
        incr results
        ; set date "" ; set game ""    
      }

      # if we have nothing to send, we have no results :(
      if {$output == ""} {
        set output "Sorry, found no results! \[system = nds/gba/gc/wii/ps2/psp/ps3/xbox/x360/pc; region = usa/jap/eur/aus\] useage: !gamefaqs system in region"
      }
      return $output
    }

    # BLOGSEARCH
    # fetches the news from blogsearch.google.
    # -madwoota supplied (uses news.google engine), speechless updated
    #
    proc blog {input} {
      ; set results 0 ; set output "" ; set match "" ; set titem "" ; set no_search "" ; set did_you_mean ""

      # if we don't want any search results, stop now.
      if {$incith::google::blog_results <= 0} {
        return
      }

      # fetch the html
      set html [fetch_html $input 24]

      # user input causing errors?
	if {[string match -nocase "*socketerrorabort*" $html]} {
            regsub {(.+?)\|} $html {} html
            return "Socket Error accessing '${html}' .. Does it exist?"
	}
	if {[string match -nocase "*timeouterrorabort*" $html]} {
		return "Connection has timed out"
	}
      # strip out 'did you mean?' first
      # what do we call 'no search results in any language?'
      regexp -- {<p></p></div></div><div id=f>(.+?)<br><br>} $html - no_search
      if {$no_search != ""} {
        regsub -- {</a>} $no_search "? " no_search
        regsub -all -- {<(.+?)>} $no_search { } no_search
        while {[string match "*  *" $no_search]} {
          regsub -all -- {  } $no_search " " no_search
        }
        set no_search [incithencode [string trim $no_search]]
      }

      # give results an output header with result tally.
      regexp -- {</td><td align=right class=rsb>(.+?)\s\002(.+?)\(\002} $html - titem match
      if {![regexp -- {1\002\s-\s\002.+?\002.+?\002(.+?)\002} $match - match]} {
         set match "Google"
         set titem ""
      }
      regsub -all -- {<(.+?)>} $match {} match
      # format output according to variables.
      if {$incith::google::total_results != 0 && $match > 0} {
        set output "\002${match}\017 $titem${incith::google::seperator}"
        if {$incith::google::bold_descriptions == 0} {
          regsub -all -- "\002" $output {} output
        }
      }

      # parse the html
      while {$results < $incith::google::news_results} {
        # somewhat extenuated regexp due to allowing that there *might* be
        # an image next to the story
        regexp -- {</p><a href="(.+?)".+?id=.+?">(.+?)</a>.+?<td class=j>(.+?)<br>} $html {} link desc time
        regsub -- {</p><a href=(.+?)</a>} $html {} html

        # if there's no desc, return or stop looping, depending
        if {[info exists desc] == 0} {
          if {$results == 0} {
            set reply $no_search
            return $reply
          } else {
            break
          }
        }
        # clean up desc
        if {[info exists desc] == 1 && $incith::google::description_length > 0} {
          set desc [string range $desc 0 [expr $incith::google::description_length - 1]]
          set desc "[string trim $desc] \017([string trim $time])"
        }
        # prevent duplicate results is mostly useless here, but will at least
        # ensure that we don't get the exact same article.
        if {[string match "*$link*" $output] == 1} {
          break
        }

        if {[info exists desc] == 1 && $incith::google::desc_modes != ""} { set desc "$incith::google::desc_modes[string trim $desc]" }
        if {[info exists link] == 1 && $incith::google::link_modes != ""} { set link "$incith::google::link_modes[string trim $link]" }

        # add the search result
        if {$incith::google::link_only == 1} { 
          append output "${link}\017${incith::google::seperator}"
        } else {
          append output "[descdecode $desc]\017 \@ ${link}\017${incith::google::seperator}"
        }

        # increase the results, clear the variables for the next loop just in case
        unset link; unset desc
        incr results
      }

      # make sure we have something to send
      if {$match == ""} {
        set reply $no_search
        return $reply
      }
      return $output
    }

    # SCHOLAR SEARCH
    # fetches the news from scholar.google.
    # -madwoota supplied (uses news.google engine), speechless updated
    #
    proc scholar {input} {
      ; set results 0 ; set output "" ; set match "" ; set titem "" ; set no_search "" ; set did_you_mean "" ; set titen ""

      # if we don't want any search results, stop now.
      if {$incith::google::scholar_results <= 0} {
        return
      }

      # this isn't global, so we need to keep ctry (country) here
      regexp -nocase -- {^\.(.+?)\s(.+?)$} $input - titen dummy
      if {$titen == ""} {
        set titen "${incith::google::google_country}" 
      }

      # fetch the html
      set html [fetch_html $input 10]

      # user input causing errors?
	if {[string match -nocase "*socketerrorabort*" $html]} {
            regsub {(.+?)\|} $html {} html
            return "Socket Error accessing '${html}' .. Does it exist?"
	}
	if {[string match -nocase "*timeouterrorabort*" $html]} {
		return "Connection has timed out"
	}
      # strip out 'did you mean?' first
      # what do we call 'no search results in any language?'
      if {![regexp -- {</script><p>(.+?)\.<br>} $html - no_search]} {
        regexp -- {</script><br><br>(.+?)<br><br>} $html - no_search
      }
      if {$no_search != ""} {
        regsub -- {</a>} $no_search "? " no_search
        regsub -all -- {<(.*?)>} $no_search { } no_search
        while {[string match "*  *" $no_search]} {
          regsub -all -- {  } $no_search " " no_search
        }
        set no_search [incithencode [string trim $no_search]]
      }

      # give results an output header with result tally.
      regexp -- {align=right nowrap>(.+?)\s\002(.+?)\(\002} $html - titem match
      if {![regexp -- {1\002\s-\s\002.+?\002.+?\002(.+?)\002} $match - match]} {
         set match "Google"
         set titem ""
      }
      regsub -all -- {<(.+?)>} $match {} match
      # format output according to variables.
      if {$incith::google::total_results != 0 && $match > 0} {
        set output "\002${match}\017 $titem${incith::google::seperator}"
        if {$incith::google::bold_descriptions == 0} {
          regsub -all -- "\002" $output {} output
        }
      }

      # parse the html
      while {$results < $incith::google::news_results} {
        # somewhat extenuated regexp due to allowing that there *might* be
        # an image next to the story
        if {[regexp -- {<p class=g>(.+?)   } $html - ps]} {
          regsub -- {<a href="(.+?)".*?;">} $ps {} ps
          if {![regexp -- {<a href="(.+?)".*?;">} $ps - link]} { set link "none" }
          if {[regexp -- {^(.+?)<br>(.+?)<br>} $ps - desc time]} { regsub {</a>} $desc "" desc }
        }
        regsub -- {<p class=g>(.+?)   } $html {} html

        # if there's no desc, return or stop looping, depending
        if {[info exists desc] == 0} {
          if {$results == 0} {
            set reply $no_search
            return $reply
          } else {
            break
          }
        }
        # clean up desc
        if {[info exists desc] == 1 && $incith::google::description_length > 0} {
          set desc [string range $desc 0 [expr $incith::google::description_length - 1]]
          set desc "[string trim $desc] \017([string trim [join [lrange [split $time -] 0 end-1]]])"
        }
        # prevent duplicate results is mostly useless here, but will at least
        # ensure that we don't get the exact same article.
        if {[string match "*$link*" $output] == 1} {
          break
        }

        if {[info exists desc] == 1 && $incith::google::desc_modes != ""} { set desc "$incith::google::desc_modes[string trim $desc]" }
        if {[info exists link] == 1 && $incith::google::link_modes != ""} { set link "$incith::google::link_modes[string trim $link]" }

        # add the search result
        if {$incith::google::link_only == 1} { 
          append output "${link}\017${incith::google::seperator}"
        } else {
          if {![string equal $link "none"]} {
            if {![string match "http*" $link]} { set link "http://scholar.google.${titen}/$link" }
            append output "[descdecode $desc]\017 \@ ${link}\017${incith::google::seperator}"
          } else {
            append output "[descdecode $desc]\017${incith::google::seperator}"
          }
        }

        # increase the results, clear the variables for the next loop just in case
        unset link; unset desc
        incr results
      }

      # make sure we have something to send
      if {$match == ""} {
        set reply $no_search
        return $reply
      }
      return $output
    }


    # WIKI
    # fetches wiki info from *.wikipedia.org
    # -speechless supplied
    #
    proc wiki {input} {
      global incithcharset
      ; set output "" ; set ded "" ; set match "" ; set redir "" ; set country "" ; set dec ""
      ; set query "" ; set titem "" ; set ebcPR "" ; set results "" ; set tresult "" ; set red 0
      ; set subtag "" ; set region "" ; set regional ""

      # if we don't want any search results, stop now.
      if {$incith::google::wiki_results <= 0} {
        return      
      }

      # make it so people can search their country
      regexp -nocase -- {^\.(.+?)\s(.+?)$} $input - country input
      if {$country == ""} {
        set country "${incith::google::wiki_country}"
      }
      regexp -nocase -- {(.*)\@(.*)} $country - country region

      # this is my input encoding hack, this will convert input before it goes
      # out to be queried.
      if {$incith::google::encoding_conversion_input > 0 && $region != ""} {
        set encoding_found [lindex [split [lindex $incith::google::encode_strings [lsearch -glob $incith::google::encode_strings "${region}:*"]] :] 1]
      } elseif {$incith::google::encoding_conversion_input > 0 && $country != ""} {
        set encoding_found [lindex [split [lindex $incith::google::encode_strings [lsearch -glob $incith::google::encode_strings "${country}:*"]] :] 1]
      } else { set encoding_found "" }
      if {$encoding_found != "" && [lsearch -exact [encoding names] $encoding_found] != -1} {
        set input [encoding convertfrom $encoding_found $input]
      }
      # encoding test
      set input [encoding convertfrom "utf-8" $input]
      regsub -all -- {_} $input { } input
      regexp -- {^(.+?)\#(.+?)$} $input - input results
      regsub -all -- {_} $results { } results
      set input [urlencode $input 0]
      set results [string map {.20 _} [urlencode [string trim $results] 1]]

# 1st load of webpage - this is the only part which has error control
# this is where we load the search page to find an exact match or most relevant.
# we will also be able to detect bad user input in the form of socket errors.

      # beware, changing the useragent will result in differently formatted html from Google.
      set query "http://${country}.wikipedia.org/wiki/index.php?title=Special%3ASearch&search=${input}&fulltext=Search"
      set ua "Lynx/2.8.5rel.1 libwww-FM/2.14 SSL-MM/1.4.1 OpenSSL/0.9.7e"
      set http [::http::config -useragent $ua -urlencoding "utf-8"]
      # stole this bit from rosc2112 on egghelp forums
      # borrowed is a better term, all procs eventually need this error handler.
	catch {set http [::http::geturl "$query" -timeout [expr 1000 * 5]]} error

	if {[string match -nocase "*couldn't open socket*" $error]} {
		return "Socket Error accessing '${country}.wikipedia.org' .. Does it exist?"
	}
	if { [::http::status $http] == "timeout" } {
		return "Connection has timed out"
	}

      # CHECK CHECK
      upvar #0 $http state
      set incithcharset [string map -nocase {"UTF-" "utf-" "iso-" "iso" "windows-" "cp" "shift_jis" "shiftjis"} $state(charset)]
      set html [::http::data $http]
      set redir [::http::ncode $http]
      # REDIRECT
      if {[string match "*${redir}*" "302|301" ]} {
        foreach {name value} $state(meta) {
	    if {[regexp -nocase ^location$ $name]} {
	      catch {set http [::http::geturl "$value" -query "" -timeout [expr 1000 * 10]]} error
            if { $::incith::google::debug > 0 } { putserv "privmsg $::incith::google::debugnick :\002redirected:\002 $query -> $value" }
	      if {[string match -nocase "*couldn't open socket*" $error]} {
              return "socketerrorabort|${value}"
	      }
	      if { [::http::status $http] == "timeout" } {
		  return "timeouterrorabort"
	      }
            set html [::http::data $http]
            set query $value
	    }
        } 
      }
      ::http::cleanup $http
     
      # generic pre-parsing
      regsub -all "(?:\x91|\x92|&#39;)" $html {'} html
      regsub -all "(?:\x93|\x94|&quot;)" $html {"} html
      regsub -all "&amp;" $html {\&} html
      regsub -all -nocase {<sup>(.+?)</sup>} $html {^\1} html
      regsub -all -nocase {<font.+?>} $html "" html
      regsub -all -nocase {</font>} $html "" html
      regsub -all -nocase {<span.*?>} $html "" html
      regsub -all -nocase {</span>} $html "" html
      regsub -all -nocase {<input.+?>} $html "" html
      regsub -all -nocase {(?:<i>|</i>)} $html "" html
      # this is the "---" line in "population of Japan" searches
      regsub -all "&#8212;" $html "--" html
      regsub -all "&times;" $html {*} html
      regsub -all "&nbsp;" $html { } html
      regsub -all -nocase "&#215;" $html "x" html
      regsub -all -nocase "&lt;" $html "<" html
      regsub -all -nocase "&gt;" $html ">" html
      regsub -all -nocase "&mdash;" $html "--" html
      regsub -all "\t" $html " " html
      regsub -all "\n" $html " " html
      regsub -all "\r" $html " " html
      regsub -all "\v" $html " " html
      regsub -all "</li>" $html ". " html
      regsub -all "&#039;" $html "'" html
      regsub -all "&#160;" $html "'" html
      regsub -all ";;>" $html "" html

      if {$html == ""} { return "\002Wikipedia Error:\002 No html to parse." }

      # see if our direct result is available and if so, lets take it
      regexp -- {<div id="contentSub"><p>.*?<a href="(.+?)".*?title} $html - match
      if {[string match -nocase "*action=edit*" $match]} { set match "" }
      # otherwise we only care about top result
      if {$match == ""} {
        if {![regexp -- {<li><a href="((?!http).+?)"} $html - match]} { regexp -- {<li style.*?><a href="(.+?)"} $html - match} 
      }
      if {[string match -nocase "*/wiki*" $country]} {
        regsub -- {/wiki} $country {} country
      }

      # at this point we can tell if there was any match, so let's not even bother
      # going further if there wasn't a match, this pulls the 'no search etc' found.
      # this can be in any language.
      if {$match == ""} {
        # these are for 'no search results' or similar message
        # these can be in any language.
        if {[regexp -- {</form>.*?<p>(.+?)(<p><b>|</p><hr)} $html - match]} { regsub -all -- {<(.+?)>} $match {} match } 
        if {$match == ""} {
          if {[regexp -- {<div id="contentSub">(.+?)<form id=} $html - match]} {
          regsub -- { <a href="/wiki/Special\:Allpages.*?</a>} $match "." match
          regsub -- {<div.*?/div>} $match "" match
          regsub -- {\[Index\]} $match "" match
          regsub -- {<span.*?/span>} $match "" match
          } 
        }
        # this is our last error catch, this can grab the
        # 'wikimedia cannot search at this time' message
        # this can be in any language.
        if {[string len $match] < 3} { regexp -- {<center><b>(.+?)</b>} $html - match }
        if {$match == ""} {
          regsub -all -- { } $results {_} results
          if {$results != ""} { set results "#${results}" } 
          return "\002Wikimedia Error:\002 Unable to parse for: \002${input}\002 @ ${query}${results}"
        }
        # might be tags since we allowed any language here we cut them out
        regsub -all -- {<(.+?)>} $match {} match
        if {$region == ""} {
          return "[utf8encodefix $country [descdecode ${match}]]"
        } else {
          return "[utf8encodefix $region [descdecode ${match}]]"
        }
      }

      # we assume here we found another page to traverse in our search.
      if {$region != ""} {
        regsub -- {/wiki/} $match "/$region/" match
      }
      set query "http://${country}.wikipedia.org${match}"

# 2nd load of webpage - this has no error checking what-so-ever
# here is where we pluck the link to the exact match, or the most relevant 'top' link.
# or in the case of redirects, to other pages, we will handle that here as well.

      # beware, changing the useragent will result in differently formatted html from Google.
      set ua "Lynx/2.8.5rel.1 libwww-FM/2.14 SSL-MM/1.4.1 OpenSSL/0.9.7e"
      set http [::http::config -useragent $ua -urlencoding "utf-8"]
      set http [::http::geturl "$query" -timeout [expr 1000 * 5]]
      set html [::http::data $http]
      ::http::cleanup $http
      #correct the html, remove shitty tags
      # generic pre-parsing
      regsub -all "(?:\x91|\x92|&#39;)" $html {'} html
      regsub -all "(?:\x93|\x94|&quot;)" $html {"} html
      regsub -all "&amp;" $html {\&} html
      regsub -all -nocase {<sup>(.+?)</sup>} $html {^\1} html
      regsub -all -nocase {<font.+?>} $html "" html
      regsub -all -nocase {</font>} $html "" html
      regsub -all -nocase {<input.+?>} $html "" html
      regsub -all -nocase {(?:<i>|</i>)} $html "" html
      # this is the "---" line in "population of Japan" searches
      regsub -all "&#8212;" $html "--" html
      regsub -all "&times;" $html {*} html
      regsub -all "&nbsp;" $html { } html
      regsub -all -nocase "&#215;" $html "x" html
      regsub -all -nocase "&lt;" $html "<" html
      regsub -all -nocase "&gt;" $html ">" html
      regsub -all -nocase "&mdash;" $html "--" html
      regsub -all "\t" $html " " html
      regsub -all "\n" $html " " html
      regsub -all "\r" $html " " html
      regsub -all "\v" $html " " html
      regsub -all "</li>" $html ". " html
      regsub -all "&#160;" $html " " html
      regsub -all ";;>" $html "" html

      if {$incith::google::bold_descriptions > 0 && [string match "\002" $incith::google::desc_modes] != 1} {
        regsub -all -nocase {(?:<b>|</b>)} $html "\002" html
      }
      set match ""

      # are we redirected to another page? if so, let's go there
      regexp -- {alt="#REDIRECT ".+?<a href="(.+?)" title="} $html - match
      if {$match != ""} {
        incr red 1
        set query "http://${country}.wikipedia.org${match}"

# 3rd load of webpage - this has no error checking what-so-ever
# here is our final webpage, this is hopefully what the user was looking for.

        # beware, changing the useragent will result in differently formatted html from Google.
        set ua "Lynx/2.8.5rel.1 libwww-FM/2.14 SSL-MM/1.4.1 OpenSSL/0.9.7e"
        set http [::http::config -useragent $ua -urlencoding "utf-8"]
        set http [::http::geturl $query -timeout [expr 1000 * 10]]
        set html [::http::data $http]
        ::http::cleanup $http
        #correct the html, remove shitty tags
        # generic pre-parsing
        regsub -all "(?:\x91|\x92|&#39;)" $html {'} html
        regsub -all "(?:\x93|\x94|&quot;)" $html {"} html
        regsub -all "&amp;" $html {\&} html
        regsub -all -nocase {<sup>(.+?)</sup>} $html {^\1} html
        regsub -all -nocase {<font.+?>} $html "" html
        regsub -all -nocase {</font>} $html "" html
        regsub -all -nocase {<input.+?>} $html "" html
        regsub -all -nocase {(?:<i>|</i>)} $html "" html
        # this is the "---" line in "population of Japan" searches
        regsub -all "&#8212;" $html "--" html
        regsub -all "&times;" $html {*} html
        regsub -all "&nbsp;" $html { } html
        regsub -all -nocase "&#215;" $html "x" html
        regsub -all -nocase "&lt;" $html "<" html
        regsub -all -nocase "&gt;" $html ">" html
        regsub -all -nocase "&mdash;" $html "--" html
        regsub -all "\t" $html " " html
        regsub -all "\n" $html " " html
        regsub -all "\r" $html " " html
        regsub -all "\v" $html " " html
        regsub -all "</li>" $html ". " html
        regsub -all "&#160;" $html " " html
        regsub -all ";;>" $html "" html

        if {$incith::google::bold_descriptions > 0 && [string match "\002" $incith::google::desc_modes] != 1} {
          regsub -all -nocase {(?:<b>|</b>)} $html "\002" html
        }
      }

      # this is the output encoding hack.
      if {$incith::google::encoding_conversion_output > 0} {
        if {$region != ""} {
          set encoding_found [lindex [split [lindex $incith::google::encode_strings [lsearch -glob $incith::google::encode_strings "$region:*"]] :] 1]
        } else {
          set encoding_found [lindex [split [lindex $incith::google::encode_strings [lsearch -glob $incith::google::encode_strings "$country:*"]] :] 1]
        }
        if {$encoding_found != "" && [lsearch -exact [encoding names] $encoding_found] != -1} {
            set html [encoding convertto $encoding_found $html]
        }
      }

      if {$incith::google::debug > 0} {
        putserv "privmsg $incith::google::debugnick :\002url:\002 $query \002charset:\002 [string map -nocase {"iso-" "iso" "windows-" "cp" "shift_jis" "shiftjis"} $incithcharset] \002\037encode_string:\037\002 $encoding_found"
      }

      set match ""
      # give results an output header with result tally.
      if {[regexp -- {<title>(.+?)</title>} $html - match]} { regexp -- {(.+?)\s(?:-|-)\s} $match - match }
      # see if page has a redirect to fragment
      regexp -- {redirectToFragment\("\#(.+?)"\)} $html - tresult

      # this is my kludge to allow listing table of contents, to make
      # sub-tag lookups easier to see on irc.
      if {[string tolower $results] == "toc"} {
        set tresult ""
        set subtag [string tolower $results]
        # if the table of contents exists on the page, lets use real world words
        # instead of ugly subtags...
        if {[string match "*<table id=\"toc*" $html]} {
          set loop "" ; set ded "\002ToC\002\:" ; set ebcPR ""
          while {$loop == ""} {
            regexp -- {<li class="toclevel.+?<span class="toctext">(.+?)</span>} $html {} results
            if {$ebcPR == $results} {
              set loop "stop"
            } else {
              regsub -- {<li class="toclevel.+?<span class="toctext">(.+?)</span>} $html {} html
              append ded " ${results};"
              set ebcPR $results
            }
          }
          set ded [string range $ded 0 [expr [string length $ded] - 2]]
          set results ""
        } else {
          # table of contents doesnt exist for the page, so we are manually
          # going to pull them for the user ourselves.
          set loop ""; set ded "\002\(ToC)\002:" ; set ebcPR ""
          while {$loop == ""} {
            regexp -- {<a name=".+?id="(.+?)".*?>} $html {} results
            if {$ebcPR == $results} {
              set loop "stop"
            } else {
              regsub -- {<a name="(.+?)".*?>} $html {} html
              append ded " [subtagDecode $results];"
              set ebcPR $results
            }
          }
          set ded [string range $ded 0 [expr [string length $ded] - 2]]
          set results ""
        }
      }

      # this is in case an internal redirectToFragment(# ) was found
      if {$tresult != ""} {
        set subtag $tresult
        incr red 1
        set redir "<a name=\"${tresult}.*?>(.+?)(<a name|</table>|\<\!\-)"
        regexp -nocase "$redir" $html - ded
        regsub -all -- {\[<(.*?)>\]} $ded {} ded
        regsub -all -- {\[[[:digit:]]+\]}  $ded {} ded
        regsub -all -- {<table.+?</table>} $ded {} ded
        if {$ded == ""} {
            return "\002Wikipedia Error:\002 redirectToFragment(#${tresult}) not found in body of html @ ${query} .  This Wiki Entry is flawed and should be reported for redirect errors."
        }
      }

      # This is for our manual #sub-tag search..
      if {$results != ""} {
        set ded ""
        while {$ded == ""} {
          regexp -- {<div id="toctitle">.*?<a href="#(.+?)">.+?<span class="toctext">(.+?)</span>} $html {} dec titem
          # first priority is our exact match
          if {[string match -nocase "${results}" $titem]} {
            set ded "true"
            incr red 1
            set subtag $dec
          }
          # second priority, begins the tag
          if {$titem == $ebcPR} {
            regsub -all -- { } $results {_} results
            set redir "<a name=\"(${results}.*?)\".*?>"
            if {[regexp -nocase "$redir" $html {} subtag]} {
              regexp -- {^(.+?)">} $subtag - subtag
              incr red 1
              set dec "${results}.*?"
              break
            } else {
              # third priority, anywhere in the tag
              set redir "<a name=\"(\[a-z0-9\._-\]*${results}\[a-z0-9\._-\]*)\""
              if {[regexp -nocase "$redir" $html "" subtag]} {
                regexp -- {^(.+?)">} $subtag - subtag
                incr red 1
                set dec $subtag
                break
              } else {
                return "\002Wikipedia Error:\002 Manual Sub-tag (${results}) not found in body of html @ ${query} ."
                break
              }
            }
          }
          regsub -- {<li class=".+?"><a href="(.+?)".+?<span class="toctext">(.+?)</span>} $html {} html
          set ebcPR $titem
        }
        set redir "<a name=\"${dec}\".*?>(.+?)(<a name|<div class=\"printfooter\">)"
        regexp -nocase "${redir}" $html - ded
        regsub -all -- {\[<(.*?)>\]} $ded {} ded
        regsub -all -- {\[[[:digit:]]+\]}  $ded {} ded
        regsub -all -- {<table.+?</table>} $ded {} ded
        if {$ded == ""} {
            return "\002Wikipedia Error:\002 Unknown problem with (${results}) found @ ${query} ." 
        }
      }

      # we couldn't chop these earlier because we needed them
      # to easily pull our #sub-tag finder above, need to remove
      # them here before we go further, because it might upset our checks.
      regsub -all -nocase {<span.*?>} $html "" html
      regsub -all -nocase {</span>} $html "" html

      # if we have no pre-cut html, let's start the cutting process.
      if {$ded == ""} {   
        regexp -- {<p>(.+?)<h} $html - ded
        ### - trying to clear out those damned wikipedia tables --
        regsub -all -- {<table.+?</table>} $ded {} ded
        if {[string match "*</table>*" $ded]} {
          regsub -all -- {.+?</table>} $ded {} ded
        } elseif {[string match "*<table*" $ded]} {
          regsub -all -- {<table.*>.+?} $ded {} ded
        }
      }
   
      # if wiki page is non-standard, then this will attempt
      # to get at least something from the webpage to display.
      if {$ded == ""} {
        regexp -- {<p>(.+?)<div class="printfooter">} $html - ded
      }
      #clean up messy parsing.
      regsub -all -- {<br>|<br/>} $ded {. } desc
      regsub -all -- {\[<(.*?)>\]} $desc {} desc
      regsub -all -- {<(.+?)>} $desc {} desc
      while {[string match "*  *" $desc]} {
        regsub -all -- {  } $desc " " desc
      }
      regsub -all -- {\[[[:digit:]]+\]}  $desc {} desc
      regsub -all -- { , } $desc ", " desc
      regsub -all -- { \.} $desc "\." desc
      #regsub -all -- {&#(25(\[6-9\])?|2(\[6-9\])?[\d]|(\[3-9\])?[\d]{2}|[\d]{4,5});} $desc "?" desc
      set match [string trim $match]
      # if we have a very short description this will grab more.
      if {$match != ""} {
        if {[string len $desc] < 3} {
          regexp -- {<p>.+?<p>(.+?)<h} $html - ded
          regsub -all -- {<(.+?)>} $ded { } desc
        }
      }
      # if we still have a tiny description, grab more yet.
      if {$match != ""} {
        if {[string len $desc] < 3} {
          regexp -- {<p>(.+?)<p} $html - ded
          regsub -all -- {<(.+?)>} $ded { } desc
        }
      }

      # clean up messy parsing.
      # here we try to sanitize the description
      # i'm hoping this works with any language, *crosses fingers*
      set desc [string trim $desc]
      regsub -all -- {<br>} $desc {. } desc
      regsub -all -- {\[<(.*?)>\]} $desc {} desc
      regsub -all -- {<(.+?)>} $desc {} desc
      while {[string match "*  *" $desc]} {
        regsub -all -- {  } $desc " " desc
      }
      regsub -all -- {\[[[:digit:]]+\]}  $desc {} desc
      regsub -all -- { , } $desc ", " desc
      regsub -all -- { \.} $desc "\." desc
      # regsub -all -- {&#(25(\[6-9\])?|2(\[6-9\])?[\d]|(\[3-9\])?[\d]{2}|[\d]{4,5});} $desc "?" desc
      # set our variables so formatting settings work
      if {$subtag != ""} {
        #regsub -- {" id="top".*?$} $subtag "" subtag
        set subtag "#${subtag}"
      }
      set link $query
      if {![info exists loop]} { set desc "[descdecode [string range $desc 0 [expr 360 * $incith::google::wiki_lines]]]" }
      if {[info exists desc] == 1 && $incith::google::desc_modes != ""} { set desc "$incith::google::desc_modes[string trim $desc]" }
      if {[info exists link] == 1 && $incith::google::link_modes != ""} { set link "$incith::google::link_modes[string trim $link]" }
      # after stripping excessive tags if our description is
      # reduced to nothing, let's lie and say it was too much to parse :)
      if {$match != "" && $desc == ""} {
        set desc "Multiple Results"
      }
      # if we have no description, then let's decide what to do.
      if {$desc == ""} {
        regexp -- {<p>(.+?)</p>} $html - match
        if {$match != ""} { return "\002Wikipedia Error:\002 Unable to parse for: \002${input}\002 @ ${query}${subtag}" }
        if {$match == ""} { return "\002Wikipedia Error:\002 Sorry, no search results found." }
        break
      }
      # regular output displayed.
      if {$match != ""} {
        if {$red > 0} {
          set output "\002${match}\002${incith::google::seperator}${desc} \017\@ ${link}${subtag} \[${red} Redirect\(s\)\]"
        } else {
          set output "\002${match}\002${incith::google::seperator}${desc} \017\@ ${link}${subtag}"
        }
      } else {
        if {$red > 0} {
          set output "${desc} \017\@ ${link}${subtag} \[${red} Redirect\(s\)\]"
        } else {
          set output "${desc} \017\@ ${link}${subtag}"
        }
      }
      return $output
    }


    # WIKIMEDIA
    # fetches wiki info from sites other than wikipedia.org
    # -speechless supplied
    #
    proc wikimedia {input} {
      global incithcharset
      ; set output "" ; set ded "" ; set match "" ; set redir "" ; set country "" ; set dec ""
      ; set query "" ; set titem "" ; set ebcPR "" ; set results "" ; set tresult "" ; set red 0
      ; set subtag "" ; set no_search "" ; set force 0 ; set fr 0 ; set natch "" ; set region ""
      ; set regional ""

      # if we don't want any search results, stop now.
      if {$incith::google::wikimedia_results <= 0} {
        return      
      }

      # make it so people can search their wiki in proper encoding....
      regexp -nocase -- {^\.(.+?)\s(.+?)$} $input - country input
      if {$country == ""} {
        set country "${incith::google::wikimedia_site}"
      }
      regexp -nocase -- {(.*)\@(.*)} $country - country region
      # allow full search if desired
      if {[string match "+" [string range $region 0 0]]} {
        set region [string range $region 1 end]
        set regional $region
      }

      # this is my input encoding hack, this will convert input before it goes
      # out to be queried.
      if {$incith::google::encoding_conversion_input > 0 && $region != ""} {
        set encoding_found [lindex [split [lindex $incith::google::encode_strings [lsearch -glob $incith::google::encode_strings "${region}:*"]] :] 1]
      } elseif {$incith::google::encoding_conversion_input > 0 && $country != ""} {
        set encoding_found [lindex [split [lindex $incith::google::encode_strings [lsearch -glob $incith::google::encode_strings "${country}:*"]] :] 1]
      } else { set encoding_found "" }
      if {$encoding_found != "" && [lsearch -exact [encoding names] $encoding_found] != -1} {
        set input [encoding convertfrom $encoding_found $input]
      } 
      # encoding test
      set input [encoding convertfrom "utf-8" $input]

      regsub -all -- {_} $input { } input
      regexp -- {^(.+?)\#(.+?)$} $input - input results
      regsub -all -- { } $results { } results
      set input [urlencode $input 0]
      set results [string map {.20 _} [urlencode [string trim $results] 1]]

      # force is for those times you want to MAKE
      # it directly go to a location, you use force
      # by making first letter of your search term a .
      set force [regexp -nocase -- {^\.(.+?)$} $input - input]
      if {$force == 1} {
        #set query "http://${country}/index.php?search=${input}&go=Go"
        set query "http://${country}/index.php/${input}"
        #set match "/index.php?search=${input}&go=Go"
        #set match "/index.php/${input}"
      } else {
        set query "http://${country}/index.php?title=Special%3ASearch&search=${input}&fulltext=Search"
      }

# pre-load page to get damn redirects out of the way
# this is stupid i agree, but let's not think about it.

      # beware, changing the useragent will result in differently formatted html from Google.
      set ua "Lynx/2.8.5rel.1 libwww-FM/2.14 SSL-MM/1.4.1 OpenSSL/0.9.7e"
      set http [::http::config -useragent $ua -urlencoding "utf-8"]
      # stole this bit from rosc2112 on egghelp forums
      # borrowed is a better term, all procs eventually need this error handler.
	catch {set http [::http::geturl $query -timeout [expr 1000 * 5]]} error

	if {[string match -nocase "*couldn't open socket*" $error]} {
		return "Socket Error accessing '${query}' .. Does it exist?"
	}
	if { [::http::status $http] == "timeout" } {
		return "Connection has timed out"
	}

      # CHECK CHECK
      upvar #0 $http state
      set incithcharset [string map -nocase {"UTF-" "utf-" "iso-" "iso" "windows-" "cp" "shift_jis" "shiftjis"} $state(charset)]
      set html [::http::data $http]
      # REDIRECT
      if {[string match "*${redir}*" "302|301" ]} {
        foreach {name value} $state(meta) {
	    if {[regexp -nocase ^location$ $name]} {
	      catch {set http [::http::geturl "$value" -query "" -timeout [expr 1000 * 10]]} error
            if { $::incith::google::debug > 0 } { putserv "privmsg $::incith::google::debugnick :\002redirected:\002 $query -> $value" }
	      if {[string match -nocase "*couldn't open socket*" $error]} {
              return "socketerrorabort|${value}"
	      }
	      if { [::http::status $http] == "timeout" } {
		  return "timeouterrorabort"
	      }
            set html [::http::data $http]
            set query $value
            incr red
	    }
        } 
      }
      ::http::cleanup $http

      # are we redirected to another page so soon?
      # usually this is the case, if our original search page wants
      # to search using another method, so let's accomodate it...
      regexp -nocase -- {document has moved.+?<a href="(.+?)">} $html - match
      regexp -nocase -- {Did you mean to type.+?<a href="(.+?)">} $html - match

      # if we are redirected, then we can modify our url
      # to include the redirect as our new destination site.
      if {$match != ""} {
        incr red 1 ; set fr 1
        set query $match
        regsub -all "&amp;" $query {\&} query
        regexp -- {http\:\/\/(.+?)/index.php} $match - country
      } 

# 1st load of webpage - this is the only part which has error control
# this is where we load the search page to find an exact match or most relevant.
# we will also be able to detect bad user input in the form of socket errors.

      # beware, changing the useragent will result in differently formatted html from Google.
      if {$fr == 1} {
        set ua "Lynx/2.8.5rel.1 libwww-FM/2.14 SSL-MM/1.4.1 OpenSSL/0.9.7e"
        set http [::http::config -useragent $ua -urlencoding "utf-8"]
	  set http [::http::geturl $query -timeout [expr 1000 * 15]]
        set html [::http::data $http]
        ::http::cleanup $http
      }

      # generic pre-parsing
      regsub -all "(?:\x91|\x92|&#39;)" $html {'} html
      regsub -all "(?:\x93|\x94|&quot;)" $html {"} html
      regsub -all "&amp;" $html {\&} html
      regsub -all -nocase {<sup>(.+?)</sup>} $html {^\1} html
      regsub -all -nocase {<font.+?>} $html "" html
      regsub -all -nocase {</font>} $html "" html
      regsub -all -nocase {<span.*?>} $html "" html
      regsub -all -nocase {</span>} $html "" html
      regsub -all -nocase {<input.+?>} $html "" html
      regsub -all -nocase {(?:<i>|</i>)} $html "" html
      # this is the "---" line in "population of Japan" searches
      regsub -all "&#8212;" $html "--" html
      regsub -all "&times;" $html {*} html
      regsub -all "&nbsp;" $html { } html
      regsub -all -nocase "&#215;" $html "x" html
      regsub -all -nocase "&lt;" $html "<" html
      regsub -all -nocase "&gt;" $html ">" html
      regsub -all -nocase "&mdash;" $html "--" html
      regsub -all "\t" $html " " html
      regsub -all "\n" $html " " html
      regsub -all "\r" $html " " html
      regsub -all "\v" $html " " html
      regsub -all "</li>" $html ". " html
      regsub -all "&#039;" $html "'" html
      regsub -all "&#160;" $html "'" html
      regsub -all ";;>" $html "" html

      if {$html == ""} { return "\002Wikimedia Error:\002 No html to parse." }

  # this is my kludge, enjoy it
  if {$force == 0} {
      # see if our direct result is available and if so, lets take it
      regexp -- {<div id="contentSub"><p>.*?<a href="((?!#).+?)".*?title} $html - match
      if {[string match -nocase "*action=edit*" $match]} { set match "" }
      # otherwise we only care about top result
      # this is the _only_ way to parse mediawiki, sorry.
      if {$match == ""} {
        regexp -- {<li><a href="((?!http).+?)"} $html - match
        if {![string match -nocase "/" [lindex [split $match ""] 0]]} { set match "" }
        if {$match == ""} { regexp -- {<li style.*?><a href="(.+?)"} $html - match } 
      }
      # this will strip double domain entries from our country if it exists
      # on our anchor.
      if {$incith::google::wiki_domain_detect != 0} {
        if {[string match -nocase [lindex [split $country "/"] end] [lindex [split $match "/"] 1]]} {
          set country [join [lrange [split $country "/"] 0 end-1] "/"]
        }
      } elseif {[string match -nocase "*/wiki*" $country]} {
       regsub -- {/wiki} $country {} country
      }

      # at this point we can tell if there was any match, so let's not even bother
      # going further if there wasn't a match, this pulls the 'no search etc' found.
      # this can be in any language.
      if {$match == ""} {
        # these are for 'no search results' or similar message
        # these can be in any language.
        if {[regexp -- {</form>.*?<p>(.+?)(<p><b>|</p><hr)} $html - match]} { regsub -all -- {<(.+?)>} $match {} match } 
        if {$match == ""} {
          if {[regexp -- {<div id="contentSub">(.+?)<form id=} $html - match]} {
          regsub -- { <a href="/wiki/Special\:Allpages.*?</a>} $match "." match
          regsub -- {<div.*?/div>} $match "" match
          regsub -- {\[Index\]} $match "" match
          regsub -- {<span.*?/span>} $match "" match
          } 
        }
        # this is our last error catch, this can grab the
        # 'wikimedia cannot search at this time' message
        # this can be in any language.
        if {[string len $match] < 3} { regexp -- {<center><b>(.+?)</b>} $html - match }
        if {$match == ""} {
          regsub -all -- { } $results {_} results
          if {$results != ""} { set results "#${results}" } 
          return "\002Wikimedia Error:\002 Unable to parse for: \002${input}\002 @ ${query}${results}"
        }
        # might be tags since we allowed any language here we cut them out
        regsub -all -- {<(.+?)>} $match "" match
        if {$region == ""} {
          return "[utf8encodefix $country [descdecode ${match}]]"
        } else {
          return "[utf8encodefix $region [descdecode ${match}]]"
        }
      }
     
      # this lets us easily change our internal sub redirected wiki link.
      #if {$regional != ""} {
      # regsub -- {/wiki/} $match "/$region/" match
      #}

      # we assume here we found another page to traverse in our search.
      if {![string match "*http*" $match]} { set query "http://${country}${match}" }

# 2nd load of webpage - this has no error checking what-so-ever
# here is where we pluck the link to the exact match, or the most relevant 'top' link.
# or in the case of redirects, to other pages, we will handle that here as well.

      # beware, changing the useragent will result in differently formatted html from Google.
      set ua "Lynx/2.8.5rel.1 libwww-FM/2.14 SSL-MM/1.4.1 OpenSSL/0.9.7e"
      set http [::http::config -useragent $ua -urlencoding "utf-8"]
      set http [::http::geturl $query -timeout [expr 1000 * 15]]
      set html [::http::data $http]
      ::http::cleanup $http
      #correct the html, remove shitty tags
      # generic pre-parsing
      regsub -all "(?:\x91|\x92|&#39;)" $html {'} html
      regsub -all "(?:\x93|\x94|&quot;)" $html {"} html
      regsub -all "&amp;" $html {\&} html
      regsub -all -nocase {<sup>(.+?)</sup>} $html {^\1} html
      regsub -all -nocase {<font.+?>} $html "" html
      regsub -all -nocase {</font>} $html "" html
      regsub -all -nocase {<input.+?>} $html "" html
      regsub -all -nocase {(?:<i>|</i>)} $html "" html
      # this is the "---" line in "population of Japan" searches
      regsub -all "&#8212;" $html "--" html
      regsub -all "&times;" $html {*} html
      regsub -all "&nbsp;" $html { } html
      regsub -all -nocase "&#215;" $html "x" html
      regsub -all -nocase "&lt;" $html "<" html
      regsub -all -nocase "&gt;" $html ">" html
      regsub -all -nocase "&mdash;" $html "--" html
      regsub -all "\t" $html " " html
      regsub -all "\n" $html " " html
      regsub -all "\r" $html " " html
      regsub -all "\v" $html " " html
      regsub -all "</li>" $html ". " html
      regsub -all "&#160;" $html " " html
      regsub -all ";;>" $html "" html
      if {$incith::google::bold_descriptions > 0 && [string match "\002" $incith::google::desc_modes] != 1} {
        regsub -all -nocase {(?:<b>|</b>)} $html "\002" html
      }
      set match ""
   
    # this is where my kludge ends ;)
    # this is if there is no text on a special page.
    } else {
     if {[regexp -nocase -- {<div class="noarticletext">(.+?)</div>} $html - no_search]} {
       regsub -all -- {<(.+?)>} $no_search {} no_search
       while {[string match "*  *" $no_search]} {
         regsub -all -- {  } $no_search " " no_search
       }
       return $no_search
     }
    }

    # are we redirected to another page? if so, let's go there
    regexp -- {alt="#REDIRECT ".+?<a href="(.+?)" title="} $html - match
    if {$match != ""} {
      incr red 1
      set query "http://${country}${match}"

# 3rd load of webpage - this has no error checking what-so-ever
# here is our final webpage, this is hopefully what the user was looking for.

        # beware, changing the useragent will result in differently formatted html from Google.
        set ua "Lynx/2.8.5rel.1 libwww-FM/2.14 SSL-MM/1.4.1 OpenSSL/0.9.7e"
        set http [::http::config -useragent $ua -urlencdoing "utf-8"]
        set http [::http::geturl $query -timeout [expr 1000 * 15]]
        set html [::http::data $http]
        ::http::cleanup $http
        #correct the html, remove shitty tags
        # generic pre-parsing
        regsub -all "(?:\x91|\x92|&#39;)" $html {'} html
        regsub -all "(?:\x93|\x94|&quot;)" $html {"} html
        regsub -all "&amp;" $html {\&} html
        regsub -all -nocase {<sup>(.+?)</sup>} $html {^\1} html
        regsub -all -nocase {<font.+?>} $html "" html
        regsub -all -nocase {</font>} $html "" html
        regsub -all -nocase {<input.+?>} $html "" html
        regsub -all -nocase {(?:<i>|</i>)} $html "" html
        # this is the "---" line in "population of Japan" searches
        regsub -all "&#8212;" $html "--" html
        regsub -all "&times;" $html {*} html
        regsub -all "&nbsp;" $html { } html
        regsub -all -nocase "&#215;" $html "x" html
        regsub -all -nocase "&lt;" $html "<" html
        regsub -all -nocase "&gt;" $html ">" html
        regsub -all -nocase "&mdash;" $html "--" html
        regsub -all "\t" $html " " html
        regsub -all "\n" $html " " html
        regsub -all "\r" $html " " html
        regsub -all "\v" $html " " html
        regsub -all "</li>" $html ". " html
        regsub -all "&#160;" $html " " html
        regsub -all ";;>" $html "" html
        if {$incith::google::bold_descriptions > 0 && [string match "\002" $incith::google::desc_modes] != 1} {
          regsub -all -nocase {(?:<b>|</b>)} $html "\002" html
        }
      }

      # this is the output encoding hack.
      if {$incith::google::encoding_conversion_output > 0} {
        if {$region != ""} {
          set encoding_found [lindex [split [lindex $incith::google::encode_strings [lsearch -glob $incith::google::encode_strings "$region:*"]] :] 1]
        } else {
          set encoding_found [lindex [split [lindex $incith::google::encode_strings [lsearch -glob $incith::google::encode_strings "$country:*"]] :] 1]
        }
        if {$encoding_found != "" && [lsearch -exact [encoding names] $encoding_found] != -1} {
            set html [encoding convertto $encoding_found $html]
        }
      }

      if {$incith::google::debug > 0} {
        putserv "privmsg $incith::google::debugnick :\002url:\002 $query \002charset:\002 [string map -nocase {"iso-" "iso" "windows-" "cp" "shift_jis" "shiftjis"} $incithcharset] \002\037encode_string:\037\002 $encoding_found"
      }

      set match ""
      # give results an output header with result tally.
      regexp -- {<title>(.+?)\s\-\s.+?</title>} $html - match
      # see if page has a redirect to fragment
      regexp -- {redirectToFragment\("\#(.+?)"\)} $html - tresult

      # this is my kludge to allow listing table of contents, to make
      # sub-tag lookups easier to see on irc.
      if {[string tolower $results] == "toc"} {
        set tresult ""
        set subtag [string tolower $results]
        # if the table of contents exists on the page, lets use real world words
        # instead of ugly subtags...
        if {[string match "*<table id=\"toc*" $html]} {
          set loop "" ; set ded "\002ToC\002\:" ; set ebcPR ""
          while {$loop == ""} {
            regexp -- {<li class=.*?toclevel.+?<span class="toctext">(.+?)</span>} $html {} results
            if {$ebcPR == $results} {
              set loop "stop"
            } else {
              regsub -- {<li class=.*?toclevel.+?<span class="toctext">(.+?)</span>} $html {} html
              append ded " ${results};"
              set ebcPR $results
            }
          }
          set ded [string range $ded 0 [expr [string length $ded] - 2]]
          set results ""
        } else {
          # table of contents doesnt exist for the page, so we are manually
          # going to pull them for the user ourselves.
          set loop ""; set ded "\002\(ToC)\002:" ; set ebcPR "" ; set subtag
          while {$loop == ""} {
            regexp -- {<a name="(.+?)".*?>} $html {} results
            if {$ebcPR == $results} {
              set loop "stop"
            } else {
              regsub -- {<a name="(.+?)".*?>} $html {} html
              append ded " [subtagDecode $results];"
              set ebcPR $results
            }
          }
          set ded [string range $ded 0 [expr [string length $ded] - 2]]
          set results ""
        }
      }

      # this is in case an internal redirectToFragment(# ) was found
      if {$tresult != ""} {
        set subtag $tresult
        incr red 1
        set redir "<a name=\"${tresult}.*?>(.+?)(<a name|</table>|\<\!\-)"
        regexp -nocase "$redir" $html - ded
        regsub -all -- {\[<(.*?)>\]} $ded {} ded
        regsub -all -- {\[[[:digit:]]+\]}  $ded {} ded
        regsub -all -- {<table.+?</table>} $ded {} ded
        if {$ded == ""} {
            return "\002Wikimedia Error:\002 redirectToFragment(#${tresult}) not found in body of html @ ${query} .  This Wiki Entry is flawed and should be reported for redirect errors."
        }
      }

      # This is for our manual #sub-tag search..
      if {$results != ""} {
        set ded ""
        regsub -all -- {_} $results " " results
        while {$ded == ""} {
          regexp -- {<div id="toctitle">.*?<a href="#(.+?)">.*?<span class="toctext">(.+?)</span>} $html {} dec titem
          # first priority is our exact match
          if {[string match -nocase "${results}" $titem]} {
            set ded "true"
            incr red 1
            set subtag $dec
          }
          # second priority, begins the tag
          if {$titem == $ebcPR} {
            regsub -all -- { } $results {_} results
            set redir "<a name=\"(${results}.*?)\".*?>"
            if {[regexp -nocase "$redir" $html {} subtag]} {
              regexp -- {^(.+?)">} $subtag - subtag
              incr red 1
              set dec "${results}.*?"
              break
            } else {
              # third priority, anywhere in the tag
              set redir "<a name=\"(\[a-z0-9\._-\]*${results}\[a-z0-9\._-\]*)\""
              if {[regexp -nocase "$redir" $html "" subtag]} {
                regexp -- {^(.+?)">} $subtag - subtag
                incr red 1
                set dec $subtag
                break
              } else {
                return "\002Wikimedia Error:\002 Manual Sub-tag (${results}) not found in body of html @ ${query}#${results} ."
                break
              }
            }
          }
          regsub -- {<li class=".+?"><a href="(.+?)".*?<span class="toctext">(.+?)</span>} $html {} html
          set ebcPR $titem
        }
        set redir "<a name=\"${dec}\".*?>(.+?)(<a name|<div class=\"printfooter\">)"

        regexp -nocase "${redir}" $html - ded
        regsub -all -- {\[<(.*?)>\]} $ded {} ded
        regsub -all -- {\[[[:digit:]]+\]}  $ded {} ded
        regsub -all -- {<table.+?</table>} $ded {} ded
        if {$ded == ""} {
            return "\002Wikimedia Error:\002 Unknown problem with (${results}) found @ ${query} ." 
        }
      }

      # we couldn't chop these earlier because we needed them
      # to easily pull our #sub-tag finder above, need to remove
      # them here before we go further, because it might upset our checks.
      regsub -all -nocase {<span.*?>} $html "" html
      regsub -all -nocase {</span>} $html "" html

      # if we have no pre-cut html, let's start the cutting process.
      if {$ded == ""} {   
        regexp -- {<p>(.+?)<h} $html - ded
        ### - trying to clear out those damned wikipedia tables --
        regsub -all -- {<table.+?</table>} $ded {} ded
        if {[string match "*</table>*" $ded]} {
          regsub -all -- {.+?</table>} $ded {} ded
        } elseif {[string match "*<table*" $ded]} {
          regsub -all -- {<table.*>.+?} $ded {} ded
        }
      }
   
      # if wiki page is non-standard, then this will attempt
      # to get at least something from the webpage to display.
      if {$ded == ""} {
        regexp -- {<p>(.+?)<div class="printfooter">} $html - ded
      }
      #clean up messy parsing.
      regsub -all -- {<br>|<br/>} $ded {. } desc
      #regsub -all -- {">:alpha:\]} $desc {} desc
      regsub -all -- {\[<(.*?)>\]} $desc {} desc
      regsub -all -- {<(.+?)>} $desc {} desc
      while {[string match "*  *" $desc]} {
        regsub -all -- {  } $desc " " desc
      }
      regsub -all -- {\[[[:digit:]]+\]}  $desc {} desc
      regsub -all -- { , } $desc ", " desc
      regsub -all -- { \.} $desc "\." desc
      regsub -all -- {&#(25(\[6-9\])?|2(\[6-9\])?[\d]|(\[3-9\])?[\d]{2}|[\d]{4,5});} $desc "?" desc
      set match [string trim $match]
      # if we have a very short description this will grab more.
      if {[string len $desc] < 3} {
        if {[regexp -- {<p>.+?<p>(.+?)<h} $html - desc]} { set desc [cleans $desc] }
      }
      if {[string len $desc] < 3} {
        if {[regexp -- {<p>(.+?)<p} $html - desc]}  { set desc [cleans $desc] }
      }
      # set our variables so formatting settings work
      if {$subtag != ""} {
        regsub -- {" id="top".*?$} $subtag "" subtag
        set subtag "#${subtag}"
      }
      set link $query
      if {![info exists loop]} { set desc "[descdecode [string range $desc 0 [expr 360 * $incith::google::wiki_lines]]]" }
      if {[info exists desc] == 1 && $incith::google::desc_modes != ""} { set desc "$incith::google::desc_modes[string trim $desc]" }
      if {[info exists link] == 1 && $incith::google::link_modes != ""} { set link "$incith::google::link_modes[string trim $link]" }
      # after stripping excessive tags if our description is
      # reduced to nothing, let's lie and say it was too much to parse :)

      # if we have no description, then let's decide what to do.
      if {$desc == ""} {
        regexp -- {<p>(.+?)</p>} $html - match
        if {$match != ""} { return "\002Wikimedia Error:\002 Unable to parse for: \002${input}\002 @ ${query}${subtag}" }
        if {$match == ""} { return "\002Wikimedia Error:\002 Sorry, no search results found." }
        break
      }

      # regular output displayed.
      if {$match != ""} {
        if {$red > 0} {
          set output "\002${match}\002${incith::google::seperator}${desc} \017\@ ${link}${subtag} \[${red} Redirect\(s\)\]"
        } else {
          set output "\002${match}\002${incith::google::seperator}${desc} \017\@ ${link}${subtag}"
        }
      } else {
        if {$red > 0} {
          set output "${desc} \017\@ ${link}${subtag} \[${red} Redirect\(s\)\]"
        } else {
          set output "${desc} \017\@ ${link}${subtag}"
        }
      }
      return $output
    }

    # wikipedia/wikimedia support
    # CLEANS
    #
    proc cleans {input} {
      # clean up messy parsing.
      # here we try to sanitize the description
      # i'm hoping this works with any language, *crosses fingers*
      set desc [string trim $input]
      regsub -all -- {<br>} $desc {. } desc
      regsub -all -- {\[<(.*?)>\]} $desc {} desc
      regsub -all -- {<(.+?)>} $desc {} desc
      while {[string match "*  *" $desc]} {
        regsub -all -- {  } $desc " " desc
      }
      regsub -all -- {\[[[:digit:]]+\]}  $desc {} desc
      regsub -all -- { , } $desc ", " desc
      regsub -all -- { \.} $desc "\." desc
      regsub -all -- {&#(25(\[6-9\])?|2(\[6-9\])?[\d]|(\[3-9\])?[\d]{2}|[\d]{4,5});} $desc "?" desc
      return $desc
    }

    # EBAY
    # fetches search results from ebay for auctions closest to completion.
    # -speechless supplied
    #
    proc ebay {input} {
      # lots of variables, keeping them clean is important.
      ; set results 0 ; set output "" ; set titem "" ; set tresult "" ; set ebcSP ""
      ; set ebcU "" ; set ebcI "" ; set ebcBid "" ; set ebcPR "" ; set ebcTim "" ; set ebcShpNew ""
      ; set ebcCheck "" ; set no_search "" ; set auctions "" ; set ebcBid2 "" ; set ebcStr ""

      # if we don't want any search results, stop now.
      if {$incith::google::ebay_results <= 0} {
        return      
      }

      # this isn't global, so we need to keep ctry (country) here
      regexp -nocase -- {\.(.+?)\s(.+?)$} $input - titem dummy
      if {$titem == ""} {
        set titem "${incith::google::ebay_country}" 
      }

      # fetch the html
      set html [fetch_html $input 25]
      if {$html == ""} {
        return "\002Ebay Error: No html to parse."
      }

      # user input causing errors?
	if {[string match -nocase "*socketerrorabort*" $html]} {
            regsub {(.+?)\|} $html {} html
            return "Socket Error accessing '${html}' .. Does it exist?"
	}
	if {[string match -nocase "*timeouterrorabort*" $html]} {
		return "Connection has timed out"
	}

      # set up an ebay results header for results to be appended to as $output
      if {![regexp -- {class="sectiontitle">([0-9]+)\002.*?<h2 class="standard ens} $html - tresult]} {
        if {![regexp -- {<div class="count">([0-9]+)\s} $html - tresult]} {
           if {![regexp -- {var.*?getCustomAdConfig.*?,"items=(.+?)"} $html - tresult]} {
             regexp -- {<div id="v.*?" class="fpcc">(.+?)\s(.+?)\s} $html - tresult auctions
           }
        }
      }

      # no_results line in any language.
      if {[regexp -- {<div class="msg msg-alert">(.+?)</div>} $html - no_search]} {
        if {[regexp -- {div class="msg msg-alert.+?</div>.+?"msg msg-alert">(.+?)</div>} $html - more]} {
          append no_search " $more"
        }
        regsub -all {<(.+?)>} $no_search "" no_search
      } else {
        if {![regexp -- {class="sectiontitle">(.+?)</h2><h2 class="standard ens"> } $html - no_search]} {
          if {![regexp -- {<div class="count">(.+?)(?:</script>|</div>)} $html - no_search]} {
            regexp -- {<div id="v.*?" class="fpcc">(.+?)\[} $html - no_search
          }
        }
      }

      # santize our no_search results found error message
      # may need to use it very shortly if we have no results
      if {$no_search != ""} {
        if {[regexp -- {<div class="suggestions".+?<ul><li><div>(.+?)</li>} $html - ebcStr]} {
          regsub -all -- {<(.+?)>} $ebcStr {} ebcStr
          set ebcStr "${ebcStr}. "
        }
        regexp {(^.+?)document.write} $no_search - no_search
        regsub -all -- {<(.+?)>} $no_search {} no_search
        set no_search "${ebcStr}[string trim $no_search]"
      } else {
        if {$tresult == 0 && $no_search == ""} {
          set no_search "eBay error."
        }
      }

      # bids in any language
      if {![regexp -- {<td class="ebcBid">(.+?)</td>} $html {} ebcSP]} {set ebcsp ""}

      # format output according to variables.
      if {$incith::google::total_results != 0} {
        regexp -- {<option value="1" selected="selected">(.+?)</option>} $html - auctions
        set output "\002${tresult}\017 $auctions${incith::google::seperator}"
        if {$incith::google::bold_descriptions == 0} {
          regsub -all -- "\002" $output {} output
        }
      }

      # parse the html
      while {$results < $incith::google::ebay_results} {
        # these CANNOT be tied together, some results appear in different
        # order, so always leave these spread out in a mess...
        if {![regexp {<table class="nol">.*?class="details.*?">(.+?)</table>} $html - line]} {
          if {![regexp -- {<h3 class="ens fontnormal">(.+?)class="ebRight"} $html - line]} { set line "" }
        }
        if {![regsub {<table class="nol">.+?</table>} $html - html]} {
          regsub {<h3 class="ens fontnormal">(.+?)class="ebRight"} $html "" html
        }
        # name & url
        if {![regexp -nocase {<a href=".+?QQitem(.+?)QQ.+?">(.+?)</a>} $line - ebcU ebcI]} {
          regexp -nocase {<a href=".+?QQitem(.+?)QQ.+?">.+?<a href=".*?">(.+?)</a>} $line - ebcU ebcI
        }
        # bid
        if {[regexp -nocase {class="bids.*?">(.+?)</td>} $line - ebcBid]} {
          if {[regexp {<div>(.+?)</div><img src=".*?title="(.+?)"} $ebcBid - ebcBid ebcBid2]} {
            set ebcBid "${ebcBid}/${ebcBid2}"
          }
          if {[string match *<img* $ebcBid]} { regexp {<img src=".*?title="(.+?)"} $ebcBid - ebcBid }
        } else {
          regexp -nocase {class="ebcBid">(.*?)</td} $line - ebcBid
          # trying to parse out the phrase "buy-it-now" in any language
          # this isn't elegant at all, we are chopping 'massive' html tags out
          # it works effectively, but isn't quick at all. We also have to account
          # for multiple bid/buy-it-now possibilities....
          regexp -- {(^[0-9\-]{1,})<} $ebcBid {} ebcBid2
          if {![regexp -- {title="(.+?)"} $ebcBid {} ebcBid]} {
            if {![regexp -- {alt="(.+?)(?:\":\:|-)} $ebcBid {} ebcBid]} {
              regsub -all -- {<(.+?)>} $ebcBid "" ebcBid
              if {$ebcBid == "-"} { set ebcBid "0" }
              if {$ebcBid != ""} {
                regsub -all -- {<(.+?)>} $ebcSP "" ebcSP
                append ebcBid " ${ebcSP}"
              }
              if {$ebcBid == ""} { set ebcBid "??" }
            }
          }
          # if our buy-it-now has a bid too, prepend bid to it.
          if {![string match "*${ebcBid2}*" $ebcBid]} {
             if {$ebcBid2 == "-"} { set ebcBid2 "0" }
             regsub -all -- {<(.+?)>} $ebcSP "" ebcSP
             set ebcBid "${ebcBid2} ${ebcSP}/[string trim $ebcBid]"
          }
        }
        # prices
        if {[regexp -nocase {class="prices.*?">(.+?)</td>} $line - ebcPR]} {
            regsub {</div><div>} $ebcPR "/" ebcPR
            regsub -all {<(.+?)>} $ebcPR "" ebcPR
        } else {
          regexp -nocase {class="ebcPr">(.+?)<br /></td>} $line - ebcPR
          regsub {<br />} $ebcPR "/" ebcPR
          regsub -all -- {<(.+?)>} $ebcPR "" ebcPR
        }
        # shipping
        if {[regexp -nocase {td class=".*?ship.*?">(.+?)</td>} $line - ebcShpNew]} {
          if {[string match "<" [string index $ebcShpNew 0]]} { set ebcShpNew "Calculate" }
        } else {
          regexp -nocase {class="ebcShpNew">(.+?)<} $line - ebcShpNew
          if {[info exists ebcShpNew]} {
            regexp -- {;;">(.+?)} $ebcShpNew {} ebcCheck
            if {$ebcCheck == ""} {
              regexp -- {$(.+?)<} $ebcShpNew {} ebcShpNew
              if {$ebcShpNew == ""} {
                set ebcTim "store"
                regexp -nocase {class="ebcStr">.+?http://stores.ebay.com/.+?">(.+?)</a>} $html - ebcStr
              }
            } else {
              set ebcShpNew "Calculate"
            }
          }
          # remove pesky trailing spaces
          regsub -all " " $ebcShpNew "" ebcShpNew
        }
        # time left
        if {![regexp -nocase {td class="time.*?rt">(.+?)</td>} $line - ebcTim]} {
          regexp -nocase {class="ebcTim">(.+?)<} $line - ebcTim
        }

        # keep ebay Item from becoming too lengthy
        if {[info exists ebcI]} {
          #ebay has these odd tags, removing them cleans up results.
          regsub -all -nocase "<wbr>" $ebcI "" ebcI
          set ebcI [string range $ebcI 0 [expr $incith::google::description_length - 1]]
          set ebcI [string trim $ebcI]
        }
 
        # check results are more than 0, return or stop looping, depending
        if {$tresult < 1 } {
          if {$results == 0} {
            set reply $no_search
            return $reply
          } else {
            break
          }
        }

        # make the link valid because we were only given a partial href result, not a full url
        set link "http://cgi.ebay.${titem}/_W0QQItem${ebcU}"

        # fix up our variables so the output looks purdy.
        if {$ebcPR == ""} { set ebcPR "--" }
        if {$ebcTim == ""} {
          set ebcTim "--"
        } elseif {$ebcTim == "store"} {
          set desc "\037${ebcStr}\037 ${ebcI}\017, ${ebcPR}(${ebcShpNew}), ${ebcBid}"
        } elseif {$ebcI != ""} {
          set desc "${ebcI}\017, ${ebcPR}(${ebcShpNew}), ${ebcBid}, ${ebcTim}"
        } else {
          set link "" ; set desc ""
        }

        # add the search result
        if {$link != ""} {
          if {[info exists desc] == 1 && $ebcI != ""} {
            if {$incith::google::desc_modes != ""} { set desc "$incith::google::desc_modes[string trim $desc]" }
            if {$incith::google::link_modes != ""} { set link "$incith::google::link_modes[string trim $link]" }
            if {$incith::google::link_only == 1} { 
              append output "${link}\017${incith::google::seperator}"
            } else {
              append output [descdecode "${desc}\017 \@ ${link}\017${incith::google::seperator}"]
            }
          }
        }

        # increase the results, clear the variables for the next loop just in case
        unset link ; set ebcCheck "" ; set ebcU "" ; set ebcBid2 ""
        set ebcI "" ; set ebcPR "" ; set ebcShpNew ""
        incr results
      }

      # make sure we have something to send
      if {$tresult < 1} {
        set reply $no_search
        return $reply
      }
      return $output
    }


    # EBAYFIGHT
    # ebay fight !
    #
    proc ebayfight {input} {
      set output ""; set winner 0 ; set match1 0; set match2 0

      # if google_fight is disabled, stop now, don't do ebay fight either.
      if {$incith::google::google_fight <= 0} {
        return
      }
      
      regexp -nocase -- {^(.+?) vs (.+?)$} $input - word1 word2

      # fetch the first result
      set html [fetch_html $word1 25]
      regexp -- {<div id="v.*?" class="fpcc">(.+?)\s} $html - match1

      # fetch the second result
      set html [fetch_html $word2 25]
      regexp -- {<div id="v.*?" class="fpcc">(.+?)\s} $html - match2

      # clean up our matches, so it looks all tidy and neat.
      regsub -all "\002" $match1 " " match1
      regsub -all "\002" $match2 " " match2

      if {![info exists match1]} {
        set match1 "0"
        set match1expr "0"
      } else {
        regsub -all {,} $match1 {} match1expr
      }

      if {![info exists match2]} {
        set match2 "0"
        set match2expr "0"
      } else {
        regsub -all {,} $match2 {} match2expr
      }

      if {[expr $match2expr < $match1expr]} {
        set winner 1
      } else {
        set winner 2
      }

      if {[expr $match2expr == $match1expr]} {
        set winner 1
        set troll1 {
         Pissing Shitting SpillingPez DrippingCum Trolling
        } 
        set troll2 {
         YourFace YourSister YourMama
        } 
        set match1 "[lindex $troll1 [rand [llength $troll1]]]"
        set match2 "[lindex $troll2 [rand [llength $troll2]]]"
      }

      if {$incith::google::bold_descriptions > 0 && $incith::google::desc_modes == ""} {
        set word1 "\002$word1\017"; set word2 "\002$word2\017"
        set match1 "\002 $match1\017"; set match2 "\002 $match2\017"
      } elseif {$incith::google::desc_modes != ""} {
        set word1 "$incith::google::desc_modes$word1\017"; set word2 "$incith::google::desc_modes$word2\017"
        set match1 "$incith::google::desc_modes $match1\017"; set match2 "$incith::google::desc_modes $match2\017"
      } else {
        set match1 " $match1"; set match2 " $match2"
      }

      regsub -all " " $match1 "" match1
      regsub -all " " $match2 "" match2

      if {$winner == 1} {
        set output "By results on ebay: $word1 beats $word2 by $match1 to $match2!"
      } elseif {$winner == 2} {
        set output "By results on ebay: $word2 beats $word1 by $match2 to $match1!"
      } else {
        set output "Could not determine the winner."
      }

      # make sure we have something to send
      if {[info exists output] == 0} {
        set reply "Sorry, no search results were found."
        if {[info exists did_you_mean] == 1} {
          append reply " Did you mean: ${did_you_mean}?"
        }
        return $reply
      }
      return $output
    }

    # Popular
    # fetches games results from gamerankings.
    # -speechless supplied
    #
    proc popular {input} {

      # lots of variables, keeping them clean is important.
      # borrowed mostly from my ebay proc above.
      ; set results 0 ; set output "" ; set tresult ""
      ; set ebcU "" ; set ebcI "" ; set ebcBid "" ; set ebcPR ""
      ; set ebcCheck "" ; set html ""

      # if we don't want any search results, stop now.
      if {$incith::google::popular_results <= 0} {
        return      
      }
      
      # redundant and messy, yes i know.. but it works, k
      # parses the query and reads html according to system desired.

      if {[string match -nocase "gc" $input] == 1} {
        set html [fetch_html "gc" 30]
        set output "\002GameRankings POPULAR GameCube\002"
      }
      if {[string match -nocase "pc" $input] == 1} {
        set html [fetch_html "pc" 31]
        set output "\002GameRankings POPULAR PC\002"
      }
      if {[string match -nocase "ps2" $input] == 1} {
        set html [fetch_html "ps2" 32]
        set output "\002GameRankings POPULAR PlayStation2\002"
      }
      if {[string match -nocase "ps3" $input] == 1} {
        set html [fetch_html "ps3" 33]
        set output "\002GameRankings POPULAR PlayStation3\002"
      }
      if {[string match -nocase "wii" $input] == 1} {
        set html [fetch_html "wii" 34]
        set output "\002GameRankings POPULAR Wii\002"
      }
      if {[string match -nocase "xbox" $input] == 1} {
        set html [fetch_html "xbox" 35]
        set output "\002GameRankings POPULAR Xbox\002"
      }
      if {[string match -nocase "x360" $input] == 1} {
        set html [fetch_html "x360" 36]
        set output "\002GameRankings POPULAR Xbox360\002"
      }
      if {[string match -nocase "ds" $input] == 1} {
        set html [fetch_html "ds" 37]
        set output "\002GameRankings POPULAR NDS\002"
      }
      if {[string match -nocase "gba" $input] == 1} {
        set html [fetch_html "gba" 38]
        set output "\002GameRankings POPULAR GBA\002"
      }
      if {[string match -nocase "psp" $input] == 1} {
        set html [fetch_html "psp" 39]
        set output "\002GameRankings POPULAR PSP\002"
      }
      if {[string match -nocase "mobile" $input] == 1} {
        set html [fetch_html "mobile" 40]
        set output "\002GameRankings POPULAR Mobile\002"
      }
      if {[string match -nocase "ngage" $input] == 1} {
        set html [fetch_html "ngage" 41]
        set output "\002GameRankings POPULAR N-Gage\002"
      }
      if {[string match -nocase "3do" $input] == 1} {
        set html [fetch_html "3do" 42]
        set output "\002GameRankings POPULAR 3DO\002"
      }
      if {[string match -nocase "dc" $input] == 1} {
        set html [fetch_html "dc" 43]
        set output "\002GameRankings POPULAR Dreamcast\002"
      }
      if {[string match -nocase "gen" $input] == 1} {
        set html [fetch_html "gen" 44]
        set output "\002GameRankings POPULAR Genesis\002"
      }
      if {[string match -nocase "jag" $input] == 1} {
        set html [fetch_html "jag" 45]
        set output "\002GameRankings POPULAR Jaguar\002"
      }
      if {[string match -nocase "n64" $input] == 1} {
        set html [fetch_html "n64" 46]
        set output "\002GameRankings POPULAR N64\002"
      }
      if {[string match -nocase "neo" $input] == 1} {
        set html [fetch_html "neo" 47]
        set output "\002GameRankings POPULAR Neo-Geo\002"
      }
      if {[string match -nocase "ps1" $input] == 1} {
        set html [fetch_html "ps1" 48]
        set output "\002GameRankings POPULAR Playstation\002"
      }
      if {[string match -nocase "sat" $input] == 1} {
        set html [fetch_html "sat" 49]
        set output "\002GameRankings POPULAR Saturn\002"
      }
      if {[string match -nocase "snes" $input] == 1} {
        set html [fetch_html "snes" 50]
        set output "\002GameRankings POPULAR Snes\002"
      }

      if {[string match -nocase "*http://www.gamespot.com/gamerankings/offline.html*" $html]} {
        append output "${incith::google::seperator}We're sorry, we are temporarily offline.  We'll be back as soon as possible."
        return $output
      }

      if {$output == ""} {
        return "Sorry, that system is not supported! \[system = gc/pc/ps2/ps3/wii/xbox/x360/ds/gba/psp/mobile/ngage/3d0/dc/gen/jag/n64/neo/ps1/sat/snes\] useage: !popular system"
      }
       
      # remove the bold if it isn't desired.
      if {$incith::google::bold_descriptions == 0} {
        regsub -all -- "\002" $output {} output
      }

      # need to do this before our search to remove duplicate top entry
      regsub {<a target=_top href=.+?id=BLUE(.+?)</tr} $html "" html

      # parse for results and loop until desired amount of results
      # is attempted to be reached if possible.
      while {$results < $incith::google::popular_results && $output != ""} {
      
        # grab date and game title and clear future html of it for looping
        regexp -nocase {<a target=_top href=.+?id=BLUE>(.+?)<.+?align.+?BLUE>(.+?)<} $html {} game date
        regsub {<nobr>} $date "" date
        regsub {<a target=_top href=.+?id=BLUE(.+?)</tr} $html "" html

        # if there's no desc, return or stop looping, depending
        if {![info exists game]} {
          if {$results == 0} {
            set reply "Sorry, no search results were found."
            return $reply
          } else {
            break
          }
        }

        # add the search result
        # add game to output if there is one
        if {[info exists game]} {
          append output "${incith::google::seperator}${game} (${date})"
        }
        # increase the results, clear the variables for the next loop just in case
        unset game; unset date
        incr results
      }
      # if we have nothing to send, we have no results :(
      if {$output == ""} {
        set output "Sorry, found no results! \[system = gc/pc/ps2/ps3/wii/xbox/x360/ds/gba/psp/mobile/ngage/3do/dc/gen/jag/n64/neo/ps1/sat/snes\] useage: !popular system"
      }
      return $output
    }

    # Recent Games
    # fetches games results from Gamerankings.
    # -speechless supplied
    #
    proc recent {input} {

      # lots of variables, keeping them clean is important.
      # borrowed mostly from my ebay proc above.
      ; set results 0 ; set output "" ; set tresult ""
      ; set ebcU "" ; set ebcI "" ; set ebcBid "" ; set ebcPR ""
      ; set ebcCheck "" ; set html ""

      # if we don't want any search results, stop now.
      if {$incith::google::recent_results <= 0} {
        return      
      }
      
      # redundant and messy, yes i know.. but it works, k
      # parses the query and reads html according to system desired.

      if {[string match -nocase "gc" $input] == 1} {
        set html [fetch_html "gc" 30]
        set output "\002GameRankings TOP GAMES GameCube\002"
      }
      if {[string match -nocase "pc" $input] == 1} {
        set html [fetch_html "pc" 31]
        set output "\002GameRankings TOP GAMES PC\002"
      }
      if {[string match -nocase "ps2" $input] == 1} {
        set html [fetch_html "ps2" 32]
        set output "\002GameRankings TOP GAMES PlayStation2\002"
      }
      if {[string match -nocase "ps3" $input] == 1} {
        set html [fetch_html "ps3" 33]
        set output "\002GameRankings TOP GAMES PlayStation3\002"
      }
      if {[string match -nocase "wii" $input] == 1} {
        set html [fetch_html "wii" 34]
        set output "\002GameRankings TOP GAMES Wii\002"
      }
      if {[string match -nocase "xbox" $input] == 1} {
        set html [fetch_html "xbox" 35]
        set output "\002GameRankings TOP GAMES Xbox\002"
      }
      if {[string match -nocase "x360" $input] == 1} {
        set html [fetch_html "x360" 36]
        set output "\002GameRankings TOP GAMES Xbox360\002"
      }
      if {[string match -nocase "ds" $input] == 1} {
        set html [fetch_html "ds" 37]
        set output "\002GameRankings TOP GAMES NDS\002"
      }
      if {[string match -nocase "gba" $input] == 1} {
        set html [fetch_html "gba" 38]
        set output "\002GameRankings TOP GAMES GBA\002"
      }
      if {[string match -nocase "psp" $input] == 1} {
        set html [fetch_html "psp" 39]
        set output "\002GameRankings TOP GAMES PSP\002"
      }
      if {[string match -nocase "mobile" $input] == 1} {
        set html [fetch_html "mobile" 40]
        set output "\002GameRankings TOP GAMES Mobile\002"
      }
      if {[string match -nocase "ngage" $input] == 1} {
        set html [fetch_html "ngage" 41]
        set output "\002GameRankings TOP GAMES N-Gage\002"
      }
      if {[string match -nocase "3do" $input] == 1} {
        set html [fetch_html "3do" 42]
        set output "\002GameRankings TOP GAMES 3D0\002"
      }
      if {[string match -nocase "dc" $input] == 1} {
        set html [fetch_html "dc" 43]
        set output "\002GameRankings TOP GAMES Dreamcast\002"
      }
      if {[string match -nocase "gen" $input] == 1} {
        set html [fetch_html "gen" 44]
        set output "\002GameRankings TOP GAMES Genesis\002"
      }
      if {[string match -nocase "jag" $input] == 1} {
        set html [fetch_html "jag" 45]
        set output "\002GameRankings TOP GAMES Jaguar\002"
      }
      if {[string match -nocase "n64" $input] == 1} {
        set html [fetch_html "n64" 46]
        set output "\002GameRankings TOP GAMES N64\002"
      }
      if {[string match -nocase "neo" $input] == 1} {
        set html [fetch_html "neo" 47]
        set output "\002GameRankings TOP GAMES Neo-Geo\002"
      }
      if {[string match -nocase "ps1" $input] == 1} {
        set html [fetch_html "ps1" 48]
        set output "\002GameRankings TOP GAMES Playstation\002"
      }
      if {[string match -nocase "sat" $input] == 1} {
        set html [fetch_html "sat" 49]
        set output "\002GameRankings TOP GAMES Saturn\002"
      }
      if {[string match -nocase "snes" $input] == 1} {
        set html [fetch_html "snes" 50]
        set output "\002GameRankings TOP GAMES Snes\002"
      }

      if {[string match -nocase "*http://www.gamespot.com/gamerankings/offline.html*" $html]} {
        append output "${incith::google::seperator}We're sorry, we are temporarily offline.  We'll be back as soon as possible."
        return $output
      }

      if {$output == ""} {
        return "Sorry, that system is not supported! \[system = gc/pc/ps2/ps3/wii/xbox/x360/ds/gba/psp/mobile/ngage/3do/dc/gen/jag/n64/neo/ps1/sat/snes\] useage: !top system"
      }
       
      # remove the bold if it isn't desired.
      if {$incith::google::bold_descriptions == 0} {
        regsub -all -- "\002" $output {} output
      }

      # need to do this before our search to remove duplicate top entry
      regexp -- {id=NAVLINKS>.+?RECENT TOP GAMES.+?</a>(.+?)</html>} $html {} html
      regsub {<a target=_top href=.+?id=BLUE(.+?)</tr} $html "" html

      # parse for results and loop until desired amount of results
      # is attempted to be reached if possible.
      while {$results < $incith::google::popular_results && $output != ""} {
      
        # grab date and game title and clear future html of it for looping
        regexp -nocase {<a target=_top href=.+?id=BLUE>(.+?)<.+?align.+?BLUE>(.+?)<} $html {} game date
        regsub {<nobr>} $date "" date
        regsub {<a target=_top href=.+?id=BLUE(.+?)</tr} $html "" html

        # if there's no desc, return or stop looping, depending
        if {![info exists game]} {
          if {$results == 0} {
            set reply "Sorry, no search results were found."
            return $reply
          } else {
            break
          }
        }

        # add the search result
        # add game to output if there is one
        if {[info exists game]} {
          append output "${incith::google::seperator}${game} (${date})"
        }
        # increase the results, clear the variables for the next loop just in case
        unset game; unset date
        incr results
      }
      # if we have nothing to send, we have no results :(
      if {$output == ""} {
        set output "Sorry, found no results! \[system = gc/pc/ps2/ps3/wii/xbox/x360/ds/gba/psp/mobile/ngage/3d0/dc/gen/jag/n64/neo/ps1/sat/snes\] useage: !top system"
      }
      return $output
    }

    # Google Trends
    # fetches top search terms from google
    # -speechless supplied
    #
    proc trends {input} {

      # lots of variables, keeping them clean is important.
      ; set results 0 ; set output "" ; set tresult "" ; set no_results "" ; set no_search ""

      # if we don't want any search results, stop now.
      if {$incith::google::trends_results <= 0} {
        return      
      }
      
      #if {![regexp {(19|20)\d\d([- /.])(0[1-9]|1[012])\2(0[1-9]|[12][0-9]|3[01])} $input {} dummy]} {
      # return "GoogleTrends requires use of YYYY-MM-DD format, your range chosen was invalid."
      #}

      set html [fetch_html $input 13]

      # user input causing errors?
	if {[string match -nocase "*socketerrorabort*" $html]} {
            regsub {(.+?)\|} $html {} html
            return "Socket Error accessing '${html}' .. Does it exist?"
	}
	if {[string match -nocase "*timeouterrorabort*" $html]} {
		return "Connection has timed out"
	}

      # give location results we are displaying.
      regexp -- {<table width=100%  cellpadding=2 cellspacing=0 bgcolor=#E5ECF9><tr><td>(.+?)</td>} $html - tresult
      if {$tresult != ""} { set output "${tresult}${incith::google::seperator}" }

      # get what we call the no_search for any language.
      if {[string match "*system_down.html*" $html]} {
        set no_search "\002Trends Error:\002 System appears to be down, try again later."
      } else {
         if {[regexp -- {<br><br>(.+?)</p>} $html - no_search]} {
          regsub -- {<p>} $no_search { } no_search
        } else {
          if {![regexp -- {<ul><li>(.+?)</ul>} $html - no_search]} {
            regexp -- {</table><p>(.+?)</p>} $html - no_search
          }
        }
      }

      # remove the bold if it isn't desired.
      if {$incith::google::bold_descriptions == 0} {
        regsub -all -- "\002" $output {} output
      }

      # parse for results and loop until desired amount of results
      # is attempted to be reached if possible.
      while {$results < $incith::google::trends_results} {
        set link "\002[expr $results + 1]\002 "
        # grab our trend and cut it out
        regexp -- {<td class=num>.+?<a href=.+?>(.+?)</a>} $html {} desc
        regsub -- {<td class=num>.+?<a href=.+?>(.+?)</a>} $html "" html
        if {[info exists desc]} {
          append link $desc
        } else {
          if {$results == 0} {
            set reply "${no_search}"
            return $reply
          } else {
            break
          }
        }

        # add the search result
        # add game to output if there is one
        if {[info exists desc]} {
          append output "${link}${incith::google::seperator}"
        }
        # increase the results, clear the variables for the next loop just in case
        unset desc; unset link
        incr results
      }
      # if we have nothing to send, we have no results :(
      if {$output == ""} {
        set output "${no_search}"
      }
      return $output
    }

    # Gamespot Game Review
    # fetches review results from gamespot searches.
    # -speechless supplied
    #
    proc rev {input} {
      global incithcookie
      # lots of variables, keeping them clean is important..
      ; set results "" ; set output "" ; set tresult ""; set inputb ""
      ; set ebcU "" ; set ebcI "" ; set ebcPR "" ; set review ""
      ; set us "?" ; set them "?" ; set you "?" ; set stats "" ; set vid ""

      # if we don't want any search results, stop now.
      if {$incith::google::rev_results <= 0} {
        return      
      }

      regexp -nocase -- {^(.+?) @ (.+?)$} $input - input inputb
      
      # fetch the html
      set html [fetch_html $input 12]
      if {[string match "*NO RESULTS RETURNED*" $html]} {
        set reply "Sorry, no search results were found."
        return $reply
      }

      if {$inputb != ""} {
        while {$results == ""} {
          # this could break any second, its cumbersome and long..i know, but for now it works.
          regexp -- {<div class="result_title">.*?<a href="(.+?)\?tag=result.*?">(.+?)</a>} $html - ebcU ebcI
          if {[string match -nocase "*\(${inputb}\)*" $ebcI] == 1} { set results "true" }
          if {$ebcU == $ebcPR} { 
            regsub -all { } $input {%20} input
            return "Sorry, game does not appear for that console when searching first page results. See for yourself @ http://www.gamespot.com/pages/search/index.php?qs=${input}#game"
          }
          regsub -- {<div class="result_title">.*?<a href=".+?">.+?</a>} $html "" html
          set ebcPR $ebcU
        }
      }

      # get url snippet where game review can be pulled
      if {$inputb == ""} { regexp -- {<div class="result_title">.*?<a href="(.+?)\?tag=result.*?">(.+?)</a>} $html - ebcU ebcI }
      # if no snippet there is nothing more to do
      if {$ebcU == "" } { return "Sorry, no search results were found." }
      # grab game review
      set query "${ebcU}"
      set ebcU ""; set ebcI ""; set ebcPR ""
      regexp -- {(.+?)&q=} $query {} query
      regexp -- {(.+?)\?q=} $query {} query
      if {![string match "*http*" $query]} {
        set query "http://www.gamespot.com${query}"
      } 

      # beware, changing the useragent will result in differently formatted html from Google.
      set ua "Lynx/2.8.5rel.1 libwww-FM/2.14 SSL-MM/1.4.1 OpenSSL/0.9.7e"
      set http [::http::config -useragent $ua]
      set http [::http::geturl $query -timeout [expr 1000 * 10]]
      if {$::incith::google::debug > 0 } {
        putserv "privmsg $incith::google::debugnick :\002url \([::http::ncode $http]\):\002 $query"
      }
      set html [::http::data $http]
      ::http::cleanup $http
      # strip the html down
        regsub -all "\t" $html "" html
        regsub -all "\n" $html "" html
        regsub -all "\r" $html "" html
        regsub -all "\v" $html "" html
        regsub -all "<script.*?>.*?</script>" $html "" html

      # DEBUG DEBUG                    
      set junk [open "ig-debug.txt" w]
      puts $junk $html
      close $junk

      regexp -- {<title>(.+?) \- } $html {} name
      # sometimes our game and system cut isn't pretty this cleans it up
      regexp -- {(.+?)<.+?title} $name - name
      set name [string trim $name]

      regexp -- {\&tag=scoresummary;gs-score">(.+?)<} $html - us
      regexp -- {\&tag=scoresummary;critic-score">(.+?)<} $html - them
      regexp -- {\?tag=scoresummary;user-score">(.+?)<} $html - you
      if {[regexp -- {<ul class="stats">(.+?)<div class="actions">} $html - stats]} {
        regsub {<div class="label">Top 5 User Tags\:.+?</ol>} $stats "" stats
        regsub {<div class="desc">.+?</ul>} $stats "" stats
        regsub {<li class="stat universe">.+?</ul>} $stats "" stats
        regsub -all {<.+?>} $stats "" stats
        while {[string match "*  *" $stats]} {
          regsub -all -- {  } $stats " " stats
        }
        regsub {More Info Game Stats} $stats "» «" stats
        regsub {Tracking\:.+?Wish It&raquo;} $stats "» «" stats
        regsub -all {&raquo;} $stats "» «" stats
        regsub -all {/\s»} $stats "»" stats
        regsub -all {«\s/} $stats "«" stats
      }
      if {[regexp {<p class="review deck">(.+?)</p>} $html - review]} {
        set review " « $review »"
      } elseif {[regexp {<p class="product deck">(.+?)</p>} $html - review]} {
        set review " « $review »"
      }
      if {[regexp -- {<ul class="videos">.+?<a href="(.+?)".*?">(.+?)</a>} $html - vurl vid]} {
        regexp -- {^(.+?)?tag=;} $vurl - vurl
        if {[string match "/" [string index $vurl 0]]} { set vurl "http://www.gamespot.com$vurl" }
        set vid " ...... \002Video:\002 $vid @ $vurl"
      }
      set desc "[descdecode "${name} \(us\002$us\002 them\002$them\002 you\002$you\002\) «$stats»$review"]"
      # make sure we have something to send
      set output "${desc} @ ${query}$vid"
      return $output
    }

    # IGN
    # fetches games results from ign searches.
    # -speechless supplied
    #
    proc ign {input} {

      # lots of variables, keeping them clean is important.
      # borrowed mostly from my ebay proc above.
      ; set results 0 ; set output "" ; set tresult ""
      ; set ebcU "" ; set ebcI "" ; set ebcBid "" ; set ebcPR ""
      ; set ebcCheck "" ; set match ""

      # if we don't want any search results, stop now.
      if {$incith::google::ign_results <= 0} {
        return      
      }

      # fetch the html
      set html [fetch_html $input 26]

      if {$html == ""} { return "IGN search page appears to be blank... No results maybe?!" }

      # give results an output header with result tally.
      # regexp -- {All Products \(([,0-9]{1,})\)<br/>} $html - match
      set match "iGN"

      # format output according to variables.
      if {$match != ""} {
        set output "\002${match}\002 results${incith::google::seperator}"
        if {$incith::google::bold_descriptions == 0} {
          regsub -all -- "\002" $output {} output
        }
      } else {
        regexp -- {<p.*?class="searchResultTitle">(.+?)</p>} $html - match
        set output "${match}$::incith::google::seperator"
      }

      if {[regexp -- {<p class="searchResultTitle".+?<strong>(.+?)<br} $html - no_search]} {
        return $no_search
      }

      # parse the html
      while {$results < $incith::google::ign_results} {
        # this could break any second, its cumbersome and long..i know, but for now it works.
        regexp -- {<div class="searchResultTitle"><a href="(.+?)">(.+?)<} $html - ebcU ebcI 
        if {![regexp -- {<div class="searchResultPublisher">(.+?)<script} $html - ebcBid]} {
          regexp -- {<div id="articleType"><strong>(.+?)</strong>} $html - ebcBid
        }
        regsub -- {searchResultTitle(.+?)</td>} $html "" html

        # check results are more than 0, return or stop looping, depending
        if {![info exists ebcU]} {
          if {$results == 0} {
            set reply "Sorry, no search results were found."
            return $reply
          } else {
            break
          }
        }

        # this needs to be done for user formatting of links and descriptions.
        set link "${ebcU}"

        # prevent duplicate results is mostly useless here, but will at least
        # ensure that we don't get the exact same article.
        if {[string match "*$link*" $output] == 1} {
         break
        }

        # ign clutters with excess spacing to make parsing hard
        # this is a quick and dirty way to get through the mud.
 
        #clean up messy parsing.
        regsub -all {<script type=.+?script>} $ebcBid {} ebcBid
        regsub -all -- {<(.+?)>} $ebcBid {} ebcBid
        while {[string match "*  *" $ebcBid]} {
          regsub -all -- {  } $ebcBid " " ebcBid
        }
        set ebcBid [string trim $ebcBid]

        # set formatting.
        set desc "${ebcI}\017 (${ebcBid})"
        if {[info exists link] == 1 && $incith::google::link_modes != ""} { set link "$incith::google::link_modes[string trim $link]" }
        if {[info exists desc] == 1 && $incith::google::desc_modes != ""} { set desc "$incith::google::desc_modes[string trim $desc]" }

        # add the search result
        if {$incith::google::link_only == 1} { 
          append output "${link}\017${incith::google::seperator}"
        } else {
          append output "${desc}\017 \@ ${link}\017${incith::google::seperator}"
        }

        # increase the results, clear the variables for the next loop just in case
        unset link ; set ebcCheck ""
        incr results
      }

      # make sure we have something to send
      if {[info exists output] == 0} {
        set reply "Sorry, no search results were found."
        return $reply
      }
      return $output
    }

    # GameSpot
    # fetches games results from gamespot searches.
    # -speechless supplied
    #
    proc gamespot {input} {
      
      # lots of variables, keeping them clean is important.
      # borrowed mostly from my ebay proc above.
      ; set results 0 ; set output "" ; set tresult ""
      ; set type "" ; set name ""
      ; set details "" ; set deck ""

      # if we don't want any search results, stop now.
      if {$incith::google::gamespot_results <= 0} {
        return      
      }

      # fetch the html
      set html [fetch_html $input 12]

      # set up gamespot results header so results can be appended to it.
      regexp -- {,"num_results".*?"(.+?)"} $html {} tresult
      set tresult [string trim $tresult]
      # format output according to variables.
      if {$incith::google::total_results != 0} {
        set output "\002${tresult}\017 games${incith::google::seperator}"
        if {$incith::google::bold_descriptions == 0} {
          regsub -all -- "\002" $output {} output
        }
      }

      # parse the html
      while {$results < $incith::google::gamespot_results} {
        # this could break any second, its cumbersome and long..i know, but for now it works.
        if {[regexp -- {<div class="result_title">(.*?)<a href="(.+?)">(.*?)</a>.*?<div class="details">(.*?)</div>.+?<div class="deck">(.*?)</div>} $html - type link name details deck]} {
          regexp -- {^(.+?)\?tag=result} $link - link
          if {[string length $deck] > 0} {set deck " - [string trim $deck]"}
        }
        regsub -- {<div class="result_title">.+?<div class="deck">.+?</div>} $html "" html
        set desc "\002[string trim $type] [string trim $name]\002 \([string trim $details]\)$deck"
        # check results are more than 0, return or stop looping, depending
        if {![info exists link]} {
          if {$results == 0} {
            set reply "Sorry, no search results were found."
            return $reply
          } else {
            break
          }
        }
        regsub -all {<.+?>} $desc "" desc
        # prevent duplicate results is mostly useless here, but will at least
        # ensure that we don't get the exact same article.
        if {[string match "*$link*" $output] == 1} {
         break
        }

        if {[info exists link] == 1 && $incith::google::link_modes != ""} { set link "$incith::google::link_modes[string trim $link]" }
        if {[info exists desc] == 1 && $incith::google::desc_modes != ""} { set desc "$incith::google::desc_modes[string trim $desc]" }

        # add the search result
        if {$incith::google::link_only == 1} { 
          append output "${link}\017${incith::google::seperator}"
        } else {
          append output "${desc}\017 \@ ${link}\017${incith::google::seperator}"
        }

        # increase the results, clear the variables for the next loop just in case
        unset link ; set name "" ; set deck "" ; set type "" ; set details ""
        incr results
      }

      # make sure we have something to send
      if {[info exists output] == 0} {
        set reply "Sorry, no search results were found."
        return $reply
      }
      return $output
    }

    # TriggerBot
    # Displays all the triggers this scripts is capable of
    # explaining syntax, and also will let user know if trigger
    # is disabled or how many results are available.
    # -speechless supplied
    #

    proc helpbot {nick input} {
      set temp "" ; set output "" ; set num 0 ; set all 0
      set item "" ; set found ""
      if {[string tolower $input] == [lindex [split $incith::google::helplist " "] 0]} { set all 1 ; set found "all" }
      if {$all == 0} {
        foreach item [split $incith::google::helplist] {
          if {[string tolower $input] == $item} { set found $item }
        }
        if {$found == ""} {
           foreach item [split $incith::google::helplist " "] {
             append temp "${item},"
           }
           set temp [string trimright $temp ","]
           return "${incith::google::helpmsg1} ${temp}"
        }
      }
      puthelp "NOTICE $nick :--> Bot triggers available:"
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 1]} {
        foreach trig [split $incith::google::google_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::search_results > 0} {
          set item "${incith::google::helpmsg3}${incith::google::search_results}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help1} ${item}"
      }
      set temp ""
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 2]} {
        foreach trig [split $incith::google::image_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::image_results > 0} {
          set item "${incith::google::helpmsg3}${incith::google::image_results}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help2} ${item}"
      }
      set temp ""
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 3]} {
        foreach trig [split $incith::google::group_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::group_results > 0} {
          set item "${incith::google::helpmsg3}${incith::google::group_results}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help3} ${item}"
      }
      set temp ""
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 4]} {
        foreach trig [split $incith::google::news_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::news_results > 0} {
          set item "${incith::google::helpmsg3}${incith::google::news_results}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help4} ${item}"
      }
      set temp ""
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 5]} {
        foreach trig [split $incith::google::local_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::local_results > 0} {
          set item "${incith::google::helpmsg3}${incith::google::local_results}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help5} ${item}"
      }
      set temp ""
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 6]} {
        foreach trig [split $incith::google::print_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::print_results > 0} {
          set item "${incith::google::helpmsg3}${incith::google::print_results}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help6} ${item}"
      }
      set temp ""
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 7]} {
        foreach trig [split $incith::google::video_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::video_results > 0} {
          set item "${incith::google::helpmsg3}${incith::google::video_results}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help7} ${item}"
      }
      set temp ""
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 8]} {
        foreach trig [split $incith::google::fight_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::google_fight > 0} {
          set item "${incith::google::helpmsg3}${incith::google::google_fight}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help8} ${item}"
      }
      set temp ""
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 9]} {
        foreach trig [split $incith::google::youtube_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::youtube_results > 0} {
          set item "${incith::google::helpmsg3}${incith::google::youtube_results}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help9} ${item}"
      }
      set temp ""
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 10]} {
        foreach trig [split $incith::google::trans_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::trans_results > 0} {
          set item "${incith::google::helpmsg3}${incith::google::trans_results}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help10} ${item}"
      }
      set temp ""
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 11]} {
        foreach trig [split $incith::google::gamespot_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::gamespot_results > 0} {
          set item "${incith::google::helpmsg3}${incith::google::gamespot_results}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help11} ${item}"
      }
      set temp ""
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 12]} {
        foreach trig [split $incith::google::gamefaq_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::gamefaq_results > 0} {
          set item "${incith::google::helpmsg3}${incith::google::gamefaq_results}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help12} ${item}"
      }
      set temp ""
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 13]} {
        foreach trig [split $incith::google::blog_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::blog_results > 0} {
          set item "${incith::google::helpmsg3}${incith::google::blog_results}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help13} ${item}"
      }
      set temp ""
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 14]} {
        foreach trig [split $incith::google::ebay_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::ebay_results > 0} {
          set item "${incith::google::helpmsg3}${incith::google::ebay_results}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help14} ${item}"
      }
      set temp ""
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 15]} {
        foreach trig [split $incith::google::efight_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::google_fight > 0} {
          set item "${incith::google::helpmsg3}${incith::google::google_fight}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help15} ${item}"
      }
      set temp ""
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 16]} {
        foreach trig [split $incith::google::wiki_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::wiki_results > 0} {
          set item "${incith::google::helpmsg3}${incith::google::wiki_results}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help16} ${item}"
      }
      set temp ""
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 17]} {
        foreach trig [split $incith::google::wikimedia_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::wikimedia_results > 0} {
          set item "${incith::google::helpmsg3}${incith::google::wikimedia_results}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help17} ${item}"
      }
      set temp ""
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 18]} {
        foreach trig [split $incith::google::locate_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::locate_results > 0} {
          set item "${incith::google::helpmsg3}${incith::google::locate_results}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help18} ${item}"
      }
      set temp ""
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 19]} {
        foreach trig [split $incith::google::rev_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::rev_results > 0} {
          set item "${incith::google::helpmsg3}${incith::google::rev_results}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help19} ${item}"
      }
      set temp ""
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 20]} {
        foreach trig [split $incith::google::mininova_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::mininova_results > 0} {
          set item "${incith::google::helpmsg3}${incith::google::mininova_results}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help20} ${item}"
      }
      set temp ""
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 21]} {
        foreach trig [split $incith::google::recent_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::recent_results > 0} {
          set item "${incith::google::helpmsg3}${incith::google::recent_results}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help21} ${item}"
      }
      set temp ""
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 22]} {
        foreach trig [split $incith::google::popular_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::popular_results > 0} {
          set item "${incith::google::helpmsg3}${incith::google::popular_results}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help22} ${item}"
      }
      set temp ""
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 23]} {
        foreach trig [split $incith::google::daily_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::daily_results > 0} {
          set item "${incith::google::helpmsg3}${incith::google::daily_results}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help23} ${item}"
      }
      set temp ""
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 24]} {
        foreach trig [split $incith::google::ign_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::ign_results > 0} {
          set item "${incith::google::helpmsg3}${incith::google::ign_results}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help24} ${item}"
      }
      set temp ""
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 25]} {
        foreach trig [split $incith::google::myspacevids_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::myspacevids_results > 0} {
          set item "${incith::google::helpmsg3}${incith::google::myspacevids_results}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help25} ${item}"
      }
      set temp ""
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 26]} {
        foreach trig [split $incith::google::trends_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::trends_results > 0} {
          set item "${incith::google::helpmsg3}${incith::google::trends_results}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help26} ${item}"
      }
      set temp ""
      if {$found == "all" || $found == [lindex [split $incith::google::helplist " "] 27]} {
        foreach trig [split $incith::google::scholar_binds " "] {
          append temp "${incith::google::command_char}${trig},"
        }
        set temp [string trimright $temp ","]
        if {$incith::google::scholar_results > 0} {
          set item "${incith::google::helpmsg3}${incith::google::image_results}${incith::google::helpmsg4}"
        } else {
          set item "${incith::google::helpmsg2}"
        }
        puthelp "NOTICE $nick :${temp} ${incith::google::help27} ${item}"
      }
    }
      
    # FETCH_HTML
    # fetches html for the various *.google.com sites
    #
    proc fetch_html {input switch} {
    global incithcharset
    global incithcookie
    set country ""
#-->  # Begin urlencoding kludge
      if {($switch < 15) || ($switch > 23) && ($switch != 28) && ($switch !=29)} {
        set helps $input
        regexp -nocase -- {^\.(.+?)\s(.+?)$} $input - country input
        # this is my input encoding hack, this will convert input before it goes
        # out to be queried.
        if {$incith::google::encoding_conversion_input > 0 && $country != "" } {
          set encoding_found [lindex [split [lindex $incith::google::encode_strings [lsearch -glob $incith::google::encode_strings "$country:*"]] :] 1]
          if {$encoding_found != "" && [lsearch -exact [encoding names] $encoding_found] != -1} { set input [encoding convertfrom $encoding_found $input] }
        } else { set encoding_found "" }
        set input [urlencode $input 0]
        set country "" ;#reset country and input
      }
#<--  # End urlencoding kludge
      # encoding test

      # GOOGLE
      if {$switch == 1} {
        # make it so people can search their country
        set country ""
        regexp -nocase -- {^\.(.+?)\s(.+?)$} $helps - country dummy
        if {$country == ""} {
          set country "${incith::google::google_country}" 
        }
        # we don't want 'define:+<search>', so we'll just remove the space if there is one.
        regsub -nocase -- {^define:\s*} $input {define:} input
        # spell after define so 'spell: define: foo' doesn't turn into a define lookup
        if {[string match -nocase "spell:*" $input] == 1} {
          regsub -nocase -- {^spell:\s*} $input {} input
        }
        if {[string match "movie:*" $input] == 1} {
          regsub -nocase -- {^movie:} $input {} input
          set query "http://www.google.${country}/movies/reviews?q=${input}&btnG=Search%20Movies"
        } else {
          set query "http://www.google.${country}/search?q=${input}&safe=${incith::google::safe_search}&lr=lang_${incith::google::language}&num=10"
        }
      # IMAGES
      } elseif {$switch == 2} {
        # make it so people can search their country
        set country ""
        regexp -nocase -- {^\.(.+?)\s(.+?)$} $helps - country dummy
        if {$country == ""} {
          set country "${incith::google::google_country}" 
        }
        set query "http://images.google.${country}/images?q=${input}&safe=${incith::google::safe_search}&btnG=Search+Images"
      # LOCAL
      } elseif {$switch == 3} {
        # make it so people can search their country
        set country ""
        regexp -nocase -- {^\.(.+?)\s(.+?)$} $helps - country helps
        if {$country == ""} {
          set country "${incith::google::google_country}" 
        }
        regexp -nocase -- {^(.+?) near (.+?)$} $helps - search location
        # a + joins words together in the search, so we change +'s to there search-form value
        #regsub -all -- {\+} $search {%2B} search
        #regsub -all -- {\+} $location {%2B} location
        # change spaces to +'s for a properly formatted search string.
        #regsub -all -- { } $search {+} search
        #regsub -all -- { } $location {+} location
        set query "http://maps.google.${country}/maps?f=q&q=${search}&near=${location}&ie=UTF8&filter=0&oi=lwp_thresh&sa=X&view=text&ct=clnk&cd=1"
        #set query "http://maps.google.${country}/maps?f=q&geocode=&time=&date=&ttype=&q=${search}&near=${location}&filter=0&oi=lwp_thresh&sa=X"
      } elseif {$switch == 4} {
        # make it so people can search their country
        set country ""
        regexp -nocase -- {^\.(.+?)\s(.+?)$} $helps - country dummy
        if {$country == ""} {
          set country "${incith::google::google_country}" 
        }
        set query "http://groups.google.${country}/groups/search?ie=UTF-8&q=${input}&qt_s=Search&safe=${incith::google::safe_search}"
      } elseif {$switch == 5} {
        # make it so people can search their country
        set country ""
        regexp -nocase -- {^\.(.+?)\s(.+?)$} $helps - country dummy
        if {$country == ""} {
          set country "${incith::google::google_country}" 
        }
        set query "http://news.google.${country}/news?q=${input}"
      } elseif {$switch == 6} {
        # make it so people can search their country
        set country ""
        regexp -nocase -- {^\.(.+?)\s(.+?)$} $helps - country dummy
        if {$country == ""} {
          set country "${incith::google::google_country}" 
        }
        set query "http://books.google.${country}/books?q=${input}&btnG=Search+Books"
      } elseif {$switch == 7} {
        # make it so people can search their country
        set country ""
        regexp -nocase -- {^\.(.+?)\s(.+?)$} $helps - country dummy
        if {$country == ""} {
          set country "${incith::google::google_country}" 
        }
        set query "http://video.google.${country}/videosearch?q=${input}&btnG=Search+Video"
      } elseif {$switch == 8} {
        # make it so people can search their country
        set country ""
        regexp -nocase -- {^\.(.+?)\s(.+?)$} $helps - country dummy
        if {$country == ""} {
          set country "${incith::google::google_country}" 
        }
        set query "http://www.google.${country}/search?hl=&q=${input}&safe=off&btnG=Search&lr=lang_all&num=1"
      } elseif {$switch == 9} {
        # make it so people can search their country
        set country ""
        regexp -nocase -- {^\.(.+?)\s(.+?)$} $helps - country dummy
        if {$country == ""} {
          set country "${incith::google::youtube_country}"
        }
        if {$country == "com"} {
          set query "http://www.youtube.com/results?search_query=${input}"
        } else {
          set query "http://${country}.youtube.com/results?search_query=${input}"
        }
      } elseif {$switch == 10} {
        # make it so people can search their country
        set country ""
        regexp -nocase -- {^\.(.+?)\s(.+?)$} $helps - country dummy
        if {$country == ""} {
          set country "${incith::google::google_country}" 
        }
        putserv "privmsg speechles :http://scholar.google.${country}/scholar?hl=all&lr=&safe=${incith::google::safe_search}&q=${input}&btnG=Search"
        set query "http://scholar.google.${country}/scholar?hl=all&lr=&safe=${incith::google::safe_search}&q=${input}&btnG=Search"
      } elseif {$switch == 11} {
        #set query "http://vidsearch.myspace.com/index.cfm?fuseaction=vids.fullsearch&searchText=${input}&fullSearch=Search%20Videos"
        set query "http://vids.myspace.com/index.cfm?SearchBoxID=SplashHeader&fuseaction=vids.search&q=${input}&t=tvid"
      } elseif {$switch == 12} {
        #set query "http://www.gamespot.com/search.html?qs=${input}&x=0&y=0"
        #set query "http://www.gamespot.com/pages/search/index.php?qs=${input}&sub=g"
        set query "http://www.gamespot.com/pages/search/search_ajax.php?q=${input}&type=game&offset=0&tags_only=false&sort=rank"
        #set query "http://www.gamespot.com/search.html?tag=search%3Bbutton&om_act=convert&om_clk=search&qs=${input}"
        #set query "http://www.gamespot.com/pages/search/index.php?qs=${input}#game"
        #set query "http://www.gamespot.com/search.html?qs=${input}"
        #set query "http://www.gamespot.com/pages/tags/index.php?type=game&tags=${input}"
      } elseif {$switch == 13} {
        # make it so people can search their country
        set country ""
        regexp -nocase -- {^\.(.+?)\s(.+?)$} $helps - country dummy
        if {$country == ""} {
          set country "${incith::google::google_country}" 
        }
        set query "http://www.google.${country}/trends/hottrends?date=${input}&sa=x&ctab=0&hl=en"
      } elseif {$switch == 14} {
        # make it so people can search their country
        set country ""
        regexp -nocase -- {^\.(.+?)\s(.+?)$} $helps - country dummy
        if {$country == ""} {
          set country "${incith::google::daily_country}" 
        }
        set query "http://www.dailymotion.com/${country}/relevance/search/${input}/1"
      } elseif {$switch == 15} {
        set query "http://www.gamefaqs.com/portable/ds/releases.html${input}"
      } elseif {$switch == 16} {
        set query "http://www.gamefaqs.com/portable/gbadvance/releases.html${input}"
      } elseif {$switch == 17} {
        set query "http://www.gamefaqs.com/portable/psp/releases.html${input}"
      } elseif {$switch == 18} {
        set query "http://www.gamefaqs.com/console/xbox360/releases.html${input}"
      } elseif {$switch == 19} {
        set query "http://www.gamefaqs.com/console/xbox/releases.html${input}"
      } elseif {$switch == 20} {
        set query "http://www.gamefaqs.com/console/gamecube/releases.html${input}"
      } elseif {$switch == 21} {
        set query "http://www.gamefaqs.com/console/ps2/releases.html${input}"
      } elseif {$switch == 22} {
        set query "http://www.gamefaqs.com/computer/doswin/releases.html${input}"
      } elseif {$switch == 23} {
        set query "http://www.gamefaqs.com/console/ps3/releases.html${input}"
      } elseif {$switch == 24} {
        # make it so people can search their country
        set country ""
        regexp -nocase -- {^\.(.+?)\s(.+?)$} $helps - country dummy
        if {$country == ""} {
          set country "${incith::google::google_country}" 
        }
        regsub -all -- {-} $input "%2d" input
        set query "http://blogsearch.google.${country}/blogsearch?q=${input}&lr=&sa=N&tab=gn"
      } elseif {$switch == 25} {
        # make it so people can search their country
        set country ""
        regexp -nocase -- {^\.(.+?)\s(.+?)$} $helps - country dummy
        if {$country == ""} {
          set country "${incith::google::ebay_country}" 
        }

        regsub -all -- {-} $input "%2d" input
        regsub -all -- { } $input "-" input

        #set query "http://search.ebay.com/search/search.dll?sofocus=unknown&sbrftog=1&from=R10&_trksid=m37&satitle=${input}&sacat=-1%26catref%3DC6&sargn=-1%26saslc%3D2&sadis=200&fpos=95482&sabfmts=1&saobfmts=insif&ftrt=1&ftrv=1&saprclo=&saprchi=&fsop=1%26fsoo%3D1&coaction=compare&copagenum=1&coentrypage=search"
        #set query "http://search.ebay.${country}/${input}"
        #set query "http://shop.ebay.${country}/items/_W0QQ_nkwZ${input}QQ_armrsZ1QQ_fromZQQ_mdoZ"
        #set query "http://shop.ebay.${country}/${input}"
        #set query "http://shop.ebay.${country}/items/_W0QQ_nkwZ${input}QQ_armrsZ1QQ_fromZQQ_mdoZ"
        set query "http://search.ebay.${country}/${input}_W0QQpqryZ${input}"

      } elseif {$switch == 26} {
        set query "http://search.ign.com/products?sort=relevance&query=${input}&so=exact&objtName=all&origin=&startat=0&nc=false&ns=false"
        #set query "http://search.ign.com/products?query=${input}"
      } elseif {$switch == 27} {
        # place holder for wikipedia
        # eventually it will get put back into fetch_html
      } elseif {$switch == 28} {
        set query "http://www.gamefaqs.com/console/wii/releases.html${input}"
      } elseif {$switch == 29} {
        set query "http://www.gamefaqs.com/console/dreamcast/releases.html${input}"
      } elseif {$switch == 30} {
        set query "http://www.gamerankings.com/itemrankings/default_gc/11"
      } elseif {$switch == 31} {
        set query "http://www.gamerankings.com/itemrankings/default_PC/5"
      } elseif {$switch == 32} {
        set query "http://www.gamerankings.com/itemrankings/default_PS2/7"
      } elseif {$switch == 33} {
        set query "http://www.gamerankings.com/itemrankings/default_PS3/1028"
      } elseif {$switch == 34} {
        set query "http://www.gamerankings.com/itemrankings/default_wii/1031"
      } elseif {$switch == 35} {
        set query "http://www.gamerankings.com/itemrankings/default_xbox/13"
      } elseif {$switch == 36} {
        set query "http://www.gamerankings.com/itemrankings/default_x360/1029"
      } elseif {$switch == 37} {
        set query "http://www.gamerankings.com/itemrankings/default_ds/1026"
      } elseif {$switch == 38} {
        set query "http://www.gamerankings.com/itemrankings/default_gba/12"
      } elseif {$switch == 39} {
        set query "http://www.gamerankings.com/itemrankings/default_psp/1024"
      } elseif {$switch == 40} {
        set query "http://www.gamerankings.com/itemrankings/default_mobile/1025"
      } elseif {$switch == 41} {
        set query "http://www.gamerankings.com/itemrankings/default_nge/1006"
      } elseif {$switch == 42} {
        set query "http://www.gamerankings.com/itemrankings/default_3DO/15"
      } elseif {$switch == 43} {
        set query "http://www.gamerankings.com/itemrankings/default_DC/1"
      } elseif {$switch == 44} {
        set query "http://www.gamerankings.com/itemrankings/default_GEN/10"
      } elseif {$switch == 45} {
        set query "http://www.gamerankings.com/itemrankings/default_JAG/17"
      } elseif {$switch == 46} {
        set query "http://www.gamerankings.com/itemrankings/default_N64/4"
      } elseif {$switch == 47} {
        set query "http://www.gamerankings.com/itemrankings/default_NEO/18"
      } elseif {$switch == 48} {
        set query "http://www.gamerankings.com/itemrankings/default_PS/6"
      } elseif {$switch == 49} {
        set query "http://www.gamerankings.com/itemrankings/default_SAT/8"
      } elseif {$switch == 50} {
        set query "http://www.gamerankings.com/itemrankings/default_SNES/21"
      } elseif {$switch == 51} {
        set query "http://www.mininova.org/search/${input}/seeds"
      } 
 
      # didnt have this before, this is needed for google parsers to correctly
      # encode the 'do not include' tag, aka the hyphen.. hehe
      if {$switch < 9} {
        regsub -nocase -- {-} $input "%2d" input
      }
      regsub -all -- {\+} $query {%2B} query
      regsub -all -- {\"} $query {%22} query 
      if {$switch != 25} {
        regsub -all -- { } $query {+} query
      }
      
      if {$switch == 12} {
        # grab the ajax data
        set http [::http::geturl $query -query "" -headers "X-Requested-With XMLHttpRequest X-Request JSON Referer $query" -timeout [expr 1000 * 10]]
        set html [string map {"\\n" "" "\\" ""} [::http::data $http]] 
        upvar #0 $http state
        set incithcharset [string map -nocase {"UTF-" "utf-" "iso-" "iso" "windows-" "cp" "shift_jis" "shiftjis"} $state(charset)]
        set redir [::http::ncode $http]
        set cookies ""
      } else {    
        # beware, changing the useragent will result in differently formatted html from Google.
        set ua "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.3) Gecko/2008092417 Firefox/3.0.3"
        set ua "Lynx/2.8.5rel.1 libwww-FM/2.14 SSL-MM/1.4.1 OpenSSL/0.9.7e"
        set http [::http::config -useragent $ua -urlencoding "utf-8"]
        # stole this bit from rosc2112 on egghelp forums
        # borrowed is a better term, all procs eventually need this error handler.
  	
        catch {set http [::http::geturl "$query" -query "" -timeout [expr 1000 * 10]]} error
        if {[string match -nocase "*couldn't open socket*" $error]} {
              return "socketerrorabort|${query}"
        }
        if { [::http::status $http] == "timeout" } {
	    return "timeouterrorabort"
	  }

        set html [::http::data $http]
        set redir [::http::ncode $http]
        # CHECK CHECK
        upvar #0 $http state
        # Are there cookies?
        set cookies ""
        foreach {name2 value2} $state(meta) {
          if {[regexp -nocase ^Set-Cookie$ $name2]} {
            append cookies "$value2; "
          }
        }
        # Re-get the url with proper cookie.
        if {[string length $cookies] > 0} {
          set http [::http::geturl "$query" -query "" -headers "Referer $query Cookie [list [string trimright $cookies "; "]]" -timeout [expr 1000 * 10]]
        }
        set incithcharset [string map -nocase {"UTF-" "utf-" "iso-" "iso" "windows-" "cp" "shift_jis" "shiftjis"} $state(charset)]
        # REDIRECT
        while {[string match "*${redir}*" "302|301" ]} {
          foreach {name value} $state(meta) {
            if {[regexp -nocase ^location$ $name]} {
              set cookies ""
              foreach {name2 value2} $state(meta) {
                if {[regexp -nocase ^Set-Cookie$ $name2]} {
                  append cookies "$value2; "
                }
              }
              set http [::http::geturl "[string map {" " "%20"} $value]" -query "" -headers "Referer $query Cookie [list [string trimright $cookies "; "]]" -timeout [expr 1000 * 10]]
              if { $::incith::google::debug > 0 } { putserv "privmsg $::incith::google::debugnick :\002redirected \($redir\):\002 $query -> $value :: \002cookie:\002 $cookies" }
              if {[string match -nocase "*couldn't open socket*" $error]} {
                return "socketerrorabort|${value}"
              }
              if { [::http::status $http] == "timeout" } {
		    return "timeouterrorabort"
              }
              set html [::http::data $http]
              set redir [::http::ncode $http]
              upvar #0 $http state
              set incithcharset [string map -nocase {"UTF-" "utf-" "iso-" "iso" "windows-" "cp" "shift_jis" "shiftjis"} $state(charset)]
              set query [string map {" " "%20"} $value]
            }
          } 
        }
      }
      ::http::cleanup $http
      set ::incith::google::incithcookie [string trimright $cookies "; "]

      # ---- step 1
      # Determine which encoding to use
      #
      set encoding_found [lindex [split [lindex $incith::google::encode_strings [lsearch -glob $incith::google::encode_strings "$country:*"]] :] 1]
      if {$incith::google::encoding_conversion_output > 0} {
        if {$incith::google::automagic > 0} {
          if {[string match -nocase "utf-8" $incithcharset] && $incith::google::utf8workaround > 0 && $encoding_found != "" && [lsearch -exact [encoding names] $encoding_found] != -1} {
            set new_encoding $encoding_found
          } else {
            set new_encoding $incithcharset
          }
        } else {
          if {$encoding_found != "" } {
            set new_encoding $encoding_found
          } else {
            set new_encoding "NONE"
          }
        }
      } else {
        set new_encoding "DISABLED"
      }

      # ---- step 2
      # Report the conclusion to debugnick
      #
      if {$incith::google::debug > 0} {
        if {[string match -nocase $new_encoding $incithcharset]} {
          if {[lsearch -exact [encoding names] $incithcharset] != -1} {
            putserv "privmsg $incith::google::debugnick :\002url \($redir\):\002 $query \002\037charset:\037\002 $incithcharset \002encode_string:\002 $encoding_found :: \002cookie:\002 [string trimright $cookies "; "]"
          } else {
            putserv "privmsg $incith::google::debugnick :\002url \($redir\):\002 $query \002\037charset:\037\002 $incithcharset \037<--ERROR: Unknown\037 \002encode_string:\002 $encoding_found :: \002cookie:\002 [string trimright $cookies "; "]"
          }
        } elseif {[string match -nocase $new_encoding $encoding_found]} {
          if {$encoding_found != "" && [lsearch -exact [encoding names] $encoding_found] != -1} {
            putserv "privmsg $incith::google::debugnick :\002url \($redir\):\002 $query \002charset:\002 $incithcharset \037\002encode_string:\002\037 $encoding_found :: \002cookie:\002 [string trimright $cookies "; "]"
          } else {
            putserv "privmsg $incith::google::debugnick :\002url \($redir\):\002 $query \002charset:\002 $incithcharset \002\037encode_string:\037\002 $encoding_found \037<--ERROR: Unknown\037 :: \002cookie:\002 [string trimright $cookies "; "]"
          }
        } elseif {[string match -nocase "DISABLED" $new_encoding]} {
          putserv "privmsg $incith::google::debugnick :\002url \($redir\):\002 $query \002charset:\002 $incithcharset \002encode_string:\002 $encoding_found \037DISABLED:\037 Using default charset. :: \002cookie:\002 [string trimright $cookies "; "]"
        } else {
          putserv "privmsg $incith::google::debugnick :\002url \($redir\):\002 $query \002charset:\002 $incithcharset \002encode_string:\002 $encoding_found \037UNKNOWN ERROR:\037 Using default charset. :: \002cookie:\002 [string trimright $cookies "; "]"
        }
      }

      # ---- step 3
      # Apply the encoding
      #
      if {![string match "*$new_encoding*" "DISABLED NONE"] && [lsearch -exact [encoding names] $new_encoding] != -1} {
	  set html [encoding convertto $new_encoding $html]
      }

      # generic pre-parsing
      regsub -all "\n" $html "" html
      regsub -all "(?:\x91|\x92|&#39;)" $html {'} html
      regsub -all "(?:\x93|\x94|&quot;)" $html {"} html
      regsub -all "&amp;" $html {\&} html
      regsub -all -nocase {<sup>(.+?)</sup>} $html {^\1} html
      if {![string match $switch "4"]} {
        regsub -all -nocase {<font.+?>} $html "" html
        regsub -all -nocase {</font>} $html "" html
      }
      if {![string match $switch "9"]} {
         regsub -all -nocase {<span.*?>} $html "" html
         regsub -all -nocase {</span>} $html "" html
      }
      regsub -all -nocase {<input.+?>} $html "" html
      regsub -all -nocase {(?:<i>|</i>)} $html "" html
      # this is the "---" line in "population of Japan" searches
      regsub -all "&#8212;" $html "--" html
      regsub -all "&times;" $html {*} html
      regsub -all "&nbsp;" $html { } html
      regsub -all -nocase "&#215;" $html "x" html
      regsub -all -nocase "&lt;" $html "<" html
      regsub -all -nocase "&gt;" $html ">" html
      regsub -all -nocase "&mdash;" $html "--" html

      # '
      # regexps that should remain seperate go here
      # google specific regexps
      if {$switch == 1} {
        # regexp the rest of the html for a much easier result to parse
        regsub -all -nocase {<b>\[PDF\]</b>\s*} $html "" html
        regsub {<p class=g style="margin-top:0">(.+?)</p>} $html "" html
      } elseif {$switch == 2} {
        # these %2520 codes, I have no idea. But they're supposed to be %20's
        regsub -all {%2520} $html {%20} html
      } elseif {$switch == 3} {
        regsub -all -nocase { - <nobr>Unverified listing</nobr>} $html "" html
        regsub -all -- {&#160;} $html { } html  
      } elseif {$switch == 4} {
      } elseif {$switch == 5} {
      } elseif {$switch == 6} {
      } elseif {$switch == 7} {
      } elseif {$switch == 8} {
      } elseif {$switch == 9} { 
        regsub -all "\t" $html "" html
        regsub -all "\n" $html "" html
        regsub -all "\r" $html "" html
        regsub -all "\v" $html "" html
      } elseif {$switch == 10} {
        regsub -all -nocase { - <nobr>Unverified listing</nobr>} $html "" html
        regsub -all -- {&#160;} $html { } html
      } elseif {$switch == 25} {
        regsub -all {<script.*?>.+?</script>} $html "" html
        regsub -all "\t" $html "" html
        regsub -all "\n" $html "" html
        regsub -all "\r" $html "" html
        regsub -all "\v" $html "" html
        regsub -all "<wbr/>" $html "" html
      } elseif {$switch > 11 && $switch < 31} {
        regsub -all "\t" $html "" html
        regsub -all "\n" $html "" html
        regsub -all "\r" $html "" html
        regsub -all "\v" $html "" html
        regsub -all "&#039;" $html "'" html
      } 

      # no point having it so many times
      if {$incith::google::bold_descriptions > 0 && [string match "\002" $incith::google::desc_modes] != 1} {
        regsub -all -nocase {(?:<b>|</b>|<em>|</em>)} $html "\002" html
      } else {
        regsub -all -nocase {(<b>|</b>|<em>|</em>)} $html "" html
      }
      # DEBUG DEBUG                    
      set junk [open "ig-debug.txt" w]
      puts $junk $html
      close $junk
      return $html
    }

    # PUBLIC_MESSAGE
    # decides what to do with binds that get triggered
    #
    proc public_message {nick uhand hand chan input} {
      if {[lsearch -exact [channel info $chan] +google] != -1} {
        if {$incith::google::chan_user_level == 3} {
          if {[isop $nick $chan] == 0} {
            return
          }
        } elseif {$incith::google::chan_user_level == 2} {
          if {[ishalfop $nick $chan] == 0 && [isop $nick $chan] == 0} {
            return
          }
        } elseif {$incith::google::chan_user_level == 1} {
          if {[isvoice $nick $chan] == 0 && [ishalfop $nick $chan] == 0 && [isop $nick $chan] == 0} {
            return
          }
        }
        send_output "$input" "$chan" "$nick" "$uhand"
      }
    }

    # PRIVATE_MESSAGE
    # decides what to do with binds that get triggered
    #
    proc private_message {nick uhand hand input} {
      if {$incith::google::private_messages >= 1} {
        send_output $input $nick $nick $uhand
      }
    }

    # SEND_OUTPUT
    # no point having two copies of this in public/private_message{}
    #
    proc send_output {input where nick uhand} {

      # this is my input encoding hack, this will convert input before it goes
      # out to be queried.
      if {$incith::google::encoding_conversion_input > 0} {
        if {[encoding system] != "identity" && [lsearch [encoding names] "ascii"]} {
          set command_char [encoding convertfrom ascii ${incith::google::command_char}]
          set input [encoding convertfrom ascii $input]
        } elseif {[encoding system] == "identity"} {
          set command_char [encoding convertfrom identity ${incith::google::command_char}]
          set input [encoding convertfrom identity $input]
        } else {
          set command_char ${incith::google::command_char}
        }
      } else {
        set command_char ${incith::google::command_char}
      }

      #Specifically retrieve only ONE (ascii) character, then check that matches the command_char first
      set trigger_char [string index $input 0]
      if {[encoding system] == "identity"} {
        set trigger_char [encoding convertfrom identity $trigger_char]
      }

      #Sanity check 1 - If no match, stop right here. No need to match every (first word) of
      # every line of channel data against every bind if the command_char doesnt even match.
      if {$trigger_char != $command_char} {
        return
      }

      set trigger [string range [lindex [split $input] 0] 1 end]
      #Sanity check 2 - Stop if theres nothing to search for (quiet)
      if {$incith::google::aversion_vocabulary > 0} {
        set search [vocabaversion [string trim [string range $input [string wordend $input 1] end]]]
      } else {
        set search [string trim [string range $input [string wordend $input 1] end]]
      }
      if {$search == ""} { return }

      if {$incith::google::force_private == 1} { set where $nick }

      # check for !google
      foreach bind [split $incith::google::google_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # channel filter check
          foreach c [split $incith::google::filtered " "] {
            if {[string match -nocase $where $c] == 1} {
              return
            }
          }
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # call google
          foreach line [incith::google::parse_output [google $search]] {
            put_output $where "$incith::google::search_prepend$line"
          }
          break
        }
      }
      # check for !images 
      foreach bind [split $incith::google::image_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # call images
          foreach line [incith::google::parse_output [images $search]] {
            put_output $where "$incith::google::image_prepend$line"
          }
          break
        }
      }
      # check for !local
      foreach bind [split $incith::google::local_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # local requires splitting of the search
          regexp -nocase -- {^(.+?) near (.+?)$} $search - what location
          if {![info exists what] || ![info exists location]} {
            put_output $where "Local searches should be the format of 'pizza near footown, bar'"
            return
          }
          foreach line [incith::google::parse_output [local $search]] {
            put_output $where "$incith::google::local_prepend$line"
          }
          break
        }
      }
      # check for !groups
      foreach bind [split $incith::google::group_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # call groups
          foreach line [incith::google::parse_output [groups $search]] {
            put_output $where "$incith::google::group_prepend$line"
          }
          break
        }
      }
      # check for !news
      foreach bind [split $incith::google::news_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # call news
          foreach line [incith::google::parse_output [news $search]] {
            put_output $where "$incith::google::news_prepend$line"
          }
          break
        }
      }
      # check for !print
      foreach bind [split $incith::google::print_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # call print
          foreach line [incith::google::parse_output [print $search]] {
            put_output $where "$incith::google::print_prepend$line"
          }
          break
        }
      }
      # check for !video
      foreach bind [split $incith::google::video_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # call video
          foreach line [incith::google::parse_output [video $search]] {
            put_output $where "$incith::google::video_prepend$line"
          }
          break
        }
      }
      # check for !scholar
      foreach bind [split $incith::google::scholar_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # call video
          foreach line [incith::google::parse_output [scholar $search]] {
            put_output $where "$incith::google::scholar_prepend$line"
          }
          break
        }
      }
      # check for !fight
      foreach bind [split $incith::google::fight_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # fight requires splitting of the search
          regexp -nocase -- {^(.+?) vs (.+?)$} $search - word1 word2
          if {![info exists word1] || ![info exists word2]} {
            put_output $where "Google fights should be the format of 'word(s) one vs word(s) two'"
            return
          }
          # call fight
          foreach line [incith::google::parse_output [fight $search]] {
            put_output $where "$incith::google::fight_prepend$line"
          }
          break
        }
      }
      # check for !ebayfight
      foreach bind [split $incith::google::efight_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # fight requires splitting of the search
          regexp -nocase -- {^(.+?) vs (.+?)$} $search - word1 word2
          if {![info exists word1] || ![info exists word2]} {
            put_output $where "Ebay fights should be the format of 'word(s) one vs word(s) two'"
            return
          }
          # call ebayfight
          foreach line [incith::google::parse_output [ebayfight $search]] {
            put_output $where "$incith::google::ebayfight_prepend$line"
          }
          break
        }
      }
      # check for !youtube
      foreach bind [split $incith::google::youtube_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # call youtube
          foreach line [incith::google::parse_output [youtube $search]] {
            put_output $where "$incith::google::youtube_prepend$line"
          }
          break
        }
      }
      # check for !helpbot
      foreach bind [split $incith::google::helpbot_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # call helpbot
          foreach line [incith::google::parse_output [helpbot $nick $search]] {
            put_output $where $line
          }
          break
        }
      }
      # check for !myspacevids
      foreach bind [split $incith::google::myspacevids_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # call myspacevids
          foreach line [incith::google::parse_output [myspacevids $search]] {
            put_output $where "$incith::google::myspacevids_prepend$line"
          }
          break
        }
      }
      # check 
      # check for !mininova
      foreach bind [split $incith::google::mininova_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # call mininova
          foreach line [incith::google::parse_output [mininova $search]] {
            put_output $where "$incith::google::mininova_prepend$line"
          }
          break
        }
      }
      # check for !recent
      foreach bind [split $incith::google::recent_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # call recent game lookup
          foreach line [incith::google::parse_output [recent $search]] {
            put_output $where "$incith::google::recent_prepend$line"
          }
          break
        }
      }
      # check for !wiki
      foreach bind [split $incith::google::wiki_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # call wiki
          foreach line [incith::google::parse_output [wiki $search]] {
            put_output $where "$incith::google::wiki_prepend$line"
          }
          break
        }
      }
      # check for !wikimedia
      foreach bind [split $incith::google::wikimedia_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # call wiki
          foreach line [incith::google::parse_output [wikimedia $search]] {
            put_output $where "$incith::google::wikimedia_prepend$line"
          }
          break
        }
      }
      # check for !review
      foreach bind [split $incith::google::rev_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # call review
          foreach line [incith::google::parse_output [rev $search]] {
            put_output $where "$incith::google::rev_prepend$line"
          }
          break
        }
      }
      # check for !ign
      foreach bind [split $incith::google::ign_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # call ign
          foreach line [incith::google::parse_output [ign $search]] {
            put_output $where "$incith::google::ign_prepend$line"
          }
          break
        }
      }
      # check for !trends
      foreach bind [split $incith::google::trends_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # call trends
          foreach line [incith::google::parse_output [trends $search]] {
            put_output $where "$incith::google::trends_prepend$line"
          }
          break
        }
      }
      # check for !gamespot
      foreach bind [split $incith::google::gamespot_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # call gamespot
          foreach line [incith::google::parse_output [gamespot $search]] {
            put_output $where "$incith::google::gamespot_prepend$line"
          }
          break
        }
      }
      # check for !trans
      foreach bind [split $incith::google::trans_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # translation requires splitting of the search
          if {![regexp -nocase -- {^(.+?)@(.+?)\s(.+?)$} $search - word1 word2 word3]} {
            if {[regexp -nocase -- {^@(.+?)\s(.+?)$} $search - word2 word3]} {
              set search [join [lrange [split $search] 1 end]]
            } else {
              regexp -nocase -- {^(.+?)@\s(.+?)$} $search - word1 word3
            }
          }
          if {[info exists word2]} {
            if {[string equal [string index $word2 0] " "]} {
              regexp -nocase -- {^(.+?)@\s(.+?)$} $search - word1 word3
              set word2 $::incith::google::trans
            }
          }
          if {![info exists word1]} { set word1 "auto" }
          if {![info exists word2]} { set word2 $::incith::google::trans }
          if {![info exists word3]} { set word3 $search }
          set search "$word1@$word2 $word3"
          # call translate
          foreach line [incith::google::parse_output [trans $search]] {
            put_output $where "$incith::google::trans_prepend$line"
          }
          break
        }
      }
      # check for !dailymotion
      foreach bind [split $incith::google::daily_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # call dailymotion
          foreach line [incith::google::parse_output [dailymotion $search]] {
            put_output $where "$incith::google::dailymotion_prepend$line"
          }
          break
        }
      }
      # check for !gamefaqs
      foreach bind [split $incith::google::gamefaq_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # gamefaqs requires splitting of the search
          regexp -nocase -- {^(.+?) in (.+?)$} $search - system region
          if {![info exists system] || ![info exists region]} {
            put_output $where "Error! Correct useage: !gamefaqs system in region \[system = nds/gba/gc/wii/ps2/psp/ps3/xbox/x360/pc; region = usa/jap/eur\]"
            return
          }
          # call gamefaqs
          foreach line [incith::google::parse_output [gamefaqs $system $region]] {
            put_output $where "$incith::google::gamefaqs_prepend$line"
          }
          break
        }
      }
      # check for !locate
      foreach bind [split $incith::google::locate_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # call locate
          if {![string match "*.*" $search]} {
            set nsearch [lindex [split [getchanhost $search $where] @] 1]
            if {[string length $nsearch]} { set search $nsearch }
          }
          foreach line [incith::google::parse_output [locate $search]] {
            put_output $where "$incith::google::locate_prepend$line"
          }
          break
        }
      }
      # check for !blog
      foreach bind [split $incith::google::blog_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # call blogsearch.google
          foreach line [incith::google::parse_output [blog $search]] {
            put_output $where "$incith::google::blog_prepend$line"
          }
          break
        }
      }
      # check for customized wiki
      if {$incith::google::wiki_custom > 0} {
        foreach bind $incith::google::wiki_customs {
          if {[string match -nocase [lindex [split $bind :] 0] $trigger] == 1} {
            if {[flood $nick $uhand]} {
              return
            }
            # call customized wikimedia page
            foreach line [incith::google::parse_output [wikimedia ".[lindex [split $bind :] 1] $search"]] {
              put_output $where "$incith::google::wikimedia_prepend$line"
            }
            break
          }
        }
      }
      # check for !ebay
      foreach bind [split $incith::google::ebay_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # call ebay
          foreach line [incith::google::parse_output [ebay $search]] {
            put_output $where "$incith::google::ebay_prepend$line"
          }
          break
        }
      }
      # check for !popular
      foreach bind [split $incith::google::popular_binds " "] {
        if {[string match -nocase $bind $trigger] == 1} {
          # flood protection check
          if {[flood $nick $uhand]} {
            return
          }
          # call popular
          foreach line [incith::google::parse_output [popular $search]] {
            put_output $where "$incith::google::popular_prepend$line"
          }
          break
        }
      }
    }

    # PUT_OUTPUT
    # actually sends the output to the server
    proc put_output {where line} {
      if {$incith::google::notice_reply == 1} {
        putserv "NOTICE $where :$line"
      } else {
        putserv "PRIVMSG $where :$line"
      }
    }

    # PARSE_OUTPUT
    # prepares output for sending to a channel/user, calls line_wrap
    #
    proc parse_output {input} {
      set parsed_output [set parsed_current {}]
      if {[string match "\n" $incith::google::seperator] == 1} {
        regsub {\n\s*$} $input "" input
        foreach newline [split $input "\n"] {
          foreach line [incith::google::line_wrap $newline] {
            lappend parsed_output $line
          }
        }
      } else {
        regsub "(?:${incith::google::seperator}|\\|)\\s*$" $input {} input
        foreach line [incith::google::line_wrap $input] {
          lappend parsed_output $line
        }
      }
      return $parsed_output
    }

    # LINE_WRAP
    # takes a long line in, and chops it before the specified length
    # http://forum.egghelp.org/viewtopic.php?t=6690
    #
    proc line_wrap {str {splitChr { }}} {
      set out [set cur {}]
      set i 0
      set len $incith::google::split_length
      #regsub -all "\002" $str "<ZQ" str
      #regsub -all "\037" $str "<ZX" str
      foreach word [split [set str][set str ""] $splitChr] {
        if {[incr i [string len $word]] > $len} {
          #regsub -all "<ZQ" $cur "\002" cur
          #regsub -all "<ZX" $cur "\037" cur
          lappend out [join $cur $splitChr]
          set cur [list $word]
          set i [string len $word]
        } else {
          lappend cur $word
        }
        incr i
      }
      #regsub -all "<ZQ" $cur "\002" cur
      #regsub -all "<ZX" $cur "\037" cur
      lappend out [join $cur $splitChr]
    }

    # FLOOD_INIT
    # modified from bseen
    #
    variable flood_data
    variable flood_array
    proc flood_init {} {
      if {$incith::google::ignore < 1} {
        return 0
      }
      if {![string match *:* $incith::google::flood]} {
        putlog "$incith::google::version: variable flood not set correctly."
        return 1
      }
      set incith::google::flood_data(flood_num) [lindex [split $incith::google::flood :] 0]
      set incith::google::flood_data(flood_time) [lindex [split $incith::google::flood :] 1]
      set i [expr $incith::google::flood_data(flood_num) - 1]
      while {$i >= 0} {
        set incith::google::flood_array($i) 0
        incr i -1
      }
    }
    ; flood_init

    # FLOOD
    # updates and returns a users flood status
    #
    proc flood {nick uhand} {
      if {$incith::google::ignore < 1} {
        return 0
      }
      if {$incith::google::flood_data(flood_num) == 0} {
        return 0
      }
      set i [expr ${incith::google::flood_data(flood_num)} - 1]
      while {$i >= 1} {
        set incith::google::flood_array($i) $incith::google::flood_array([expr $i - 1])
        incr i -1
      }
      set incith::google::flood_array(0) [unixtime]
      if {[expr [unixtime] - $incith::google::flood_array([expr ${incith::google::flood_data(flood_num)} - 1])] <= ${incith::google::flood_data(flood_time)}} {
        putlog "$incith::google::version: flood detected from ${nick}."
        newignore [join [maskhost *!*[string trimleft $uhand ~]]] $incith::google::version flooding $incith::google::ignore
        return 1
      } else {
        return 0
      }
    }


    # AUTOMAGIC CHARSET ENCODING SUPPORT
    # on the fly encoding support
    #
    proc incithdecode {text} {
      global incithcharset
      if {[lsearch -exact [encoding names] $incithcharset] != -1} {
        set text [encoding convertfrom $incithcharset $text]
      }
      return $text
    }

    proc incithencode {text} {
      global incithcharset
      if {[lsearch -exact [encoding names] $incithcharset] != -1} {
        set text [encoding convertto $incithcharset $text]
      }
      return $text
    }

    # utf-8 sucks for displaying any language using extended ascii, this helps alleviate that.
    # correct utf-8 problems before they even appear.
    proc utf8encodefix {country input} {
      if {[lsearch -exact [encoding names] [set encoding_found [lindex [split [lindex $incith::google::encode_strings [lsearch -glob $incith::google::encode_strings "${country}:*"]] :] 1]]]} {
        if {![string match "" $encoding_found]} { set input [encoding convertto $encoding_found $input] }
      }
      return $input
    }

    # Wikipedia/Wikimedia subtag-decoder...
    # decodes those silly subtags
    #
    proc subtagDecode {text} {
      set url ""
      regsub -all {\.([0-9a-fA-F][0-9a-fA-F])} $text {[format %c 0x\1]} text
      set text [subst $text]
      regsub -all "\r\n" $text "\n" text
      foreach byte [split [encoding convertto "utf-8" $text] ""] {
        scan $byte %c i
        if { $i < 33 } {
          append url [format %%%02X $i]
        } else {
          append url $byte
        }
      }
      return [string map {% .} $url]
    }

    # Vocabulary Aversion
    # This converts swear words into appropriate words for IRC
    # this is rather rudementary, is probably a better way to do this but meh..
    #
    proc vocabaversion {text} {
      set newtext ""
      foreach element [split $text] {
        set violation 0
        foreach vocabulary $incith::google::aversion {
          set swear [lindex [split $vocabulary :] 0]
          set avert [join [lrange [split $vocabulary :] 1 end]]
          if {[string match -nocase "$swear" $element] && $avert != ""} {
            append newtext "$avert "
            set violation 1
            break
          }
        }
        if {$violation == 0} { append newtext "$element " }
      }
      return [string trim $newtext]
    } 

    # Description Decode 
    # convert html codes into characters - credit perplexa (urban dictionary)
    #
    proc descdecode {text} {
      # code below is neccessary to prevent numerous html markups
      # from appearing in the output (ie, &quot;, &#5671;, etc)
      # stolen (borrowed is a better term) from perplexa's urban
      # dictionary script..
 
      if {![string match *&* $text]} {return $text}
      set escapes {
        &ldquo; "\"" &rdquo; "\""
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
      set text [string map $escapes $text]
      # tcl filter required because we are using SUBST command below
      # this will escape any sequence which could potentially trigger
      # the interpreter..
        regsub -all -- \\\\ $text \\\\\\\\ text
        regsub -all -- \\\[ $text \\\\\[ text
        regsub -all -- \\\] $text \\\\\] text
        regsub -all -- \\\} $text \\\\\} text
        regsub -all -- \\\{ $text \\\\\{ text
        regsub -all -- \\\" $text \\\\\" text
        regsub -all -- \\\$ $text \\\\\$ text
      # end tcl filter
  	regsub -all -- {&#([[:digit:]]{1,5});} $text {[format %c [string trimleft "\1" "0"]]} text
 	regsub -all -- {&#x([[:xdigit:]]{1,4});} $text {[format %c [scan "\1" %x]]} text
 	regsub -all -- {&#?[[:alnum:]]{2,7};} $text "?" text
      return [subst $text]
    }

    # URL Decode
    # Decodes all of the %00 strings in a url and returns it
    #
    proc urldecode {text} {
      set url ""
      # tcl filter required because we are using SUBST command below
      # this will escape any sequence which could potentially trigger
      # the interpreter..
        regsub -all -- \\\\ $text \\\\\\\\ text
        regsub -all -- \\\[ $text \\\\\[ text
        regsub -all -- \\\] $text \\\\\] text
        regsub -all -- \\\} $text \\\\\} text
        regsub -all -- \\\{ $text \\\\\{ text
        regsub -all -- \\\" $text \\\\\" text
        regsub -all -- \\\$ $text \\\\\$ text
      # end tcl filter
      regsub -all {\%([0-9a-fA-F][0-9a-fA-F])} $text {[format %c 0x\1]} text
      set text [subst $text]
      foreach byte [split $text ""] {
        scan $byte %c i
        if { $i < 33 || $i > 127 } {
          append url [format %%%02X $i]
        } else {
          append url $byte
        }
      }
      return $url
    }

    # URL Encode
    # Encodes anything not a-zA-Z0-9 into %00 strings...
    #
    proc urlencode {text type} {
      set url ""
      foreach byte [split [encoding convertfrom "utf-8" $text] ""] {
        scan $byte %c i
        if {$i < 65 || $i > 122} {
          append url [format %%%02X $i]
        } else {
          append url $byte
        }
      }
      if {$type == 1} {
        return [string map {%25 . %3A : %2D - %2F / %2E . %30 0 %31 1 %32 2 %33 3 %34 4 %35 5 %36 6 %37 7 %38 8 %39 9 %80 _ % .} $url]
      } else {
        return [string map {%2D - %30 0 %31 1 %32 2 %33 3 %34 4 %35 5 %36 6 %37 7 %38 8 %39 9 \[ %5B \\ %5C \] %5D \^ %5E \_ %5F \` %60} $url]
      }
    }
  }
}

putlog " - UNOFFICIAL $incith::google::version loaded."

# EOF

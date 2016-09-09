#!/usr/bin/perl
require('global_data.pl');
require('res_lib.pl');


################################################################################
#
#   Name:     sat_arrival
#
#   Function: generates page: requestor tried to reserve starting on a Saturday
#             in summer or winter
#
#   Inputs:
#
#   Outputs:
#
#   Caller:   chk_special_days                   res_main.pl
#
#   Calls:
#
#                   MODIFICATION                           DATE           BY
#
# Tradewinds Resort                                      11/12/98       M. Lewis
# Automated system                                       11/28/99       M. Lewis
#
sub no_sat_arrival {

   print "Content-Type: text/html\n\n";

print <<end_of_html;
   <HTML>
   <HEAD>
   <TITLE>Saturday Arrival Restrictions</TITLE>
   </HEAD>
   <BODY BGCOLOR="#ffffff">

   <IMG SRC ="$jpeg2url">

   <P>&nbsp;</P>

   <P><H2><B><FONT COLOR="#0080c0">Because there is a two-day minimum for
   Fridays and Saturdays, $hotel_abbrev will not accept reservations that
   begin on a Saturday.
   </FONT></B></H2></P>

   <P><CENTER><B><FONT COLOR="#8080c0">Please use the Back button to
   return to the selections page to modify your reservation -- or call
   $hotel_abbrev at $hotelTelephone to make arrangements by telephone.</FONT>
   </B></CENTER></P>

   <P><CENTER><B><FONT COLOR="#8080c0">Thank you</FONT></B><HR></CENTER></P>


   </BODY>
   </HTML>
end_of_html

   exit;

} #end no_sat_arrival


################################################################################
#
#   Name:     weekend_restrictions
#
#   Function: generates page: requestor didn't reserve for minimum No. days for
#             Fri/Sat
#
#   Inputs:   minimum No. days for which Fri/Sat reservations can be made
#
#   Outputs:
#
#   Caller:   chk_special_days                      res_main.pl
#
#   Calls:
#
#                  MODIFICATION                               DATE         BY
#
# Lakeside Inn                                              03/12/98    M. Lewis
# Automated system                                          11/28/99    M. Lewis
#
sub weekend_restrictions {

   print "Content-Type: text/html\n\n";

print <<end_of_html;
   <HTML>
   <HEAD>
   <TITLE>Weekend Restrictions</TITLE>
   </HEAD>
   <BODY BGCOLOR="#ffffff">

   <IMG SRC ="$jpeg2url">

   <P>&nbsp;</P>

   <P><H2><B><FONT COLOR="#0080c0">$hotel_abbrev will not accept
   reservations for Fridays and Saturdays unless you reserve for a
   minimum of two days.
   </FONT></B></H2></P>

   <P><CENTER><B><FONT COLOR="#8080c0">Please use the Back button to
   return to the selections page to modify your reservation -- or call $hotel_abbrev
   at $hotelTelephone for more information.</FONT></B></CENTER></P>

   <P><CENTER><B><FONT COLOR="#8080c0">Thank you</FONT></B><HR></CENTER></P>


   </BODY>
   </HTML>
end_of_html

   exit;

} #end weekend_restrictions


################################################################################
#
#   Name:     holiday_restrictions
#
#   Function: generates page: requestor didn't reserve for minimum No. days for
#             the input holiday
#
#   Inputs:   name of holiday
#             No. days in reservation request
#             holiday start day (sec since 1/1/70)
#             holiday end day (sec since 1/1/70)
#             minimum No. days for which reservation can be made for this
#             holiday
#
#   Outputs:
#
#   Caller:   chk_special_days                     res_main.pl
#
#   Calls:
#
#                       MODIFICATION                       DATE           BY
#
#
sub holiday_restrictions {

   my $holidayPtr = shift(@_);
   my $numDays    = shift(@_);
   my $startDay   = shift(@_);
   my $endDay     = shift(@_);
   my $minDays    = shift(@_);

   print "Content-Type: text/html\n\n";

print <<end_of_html;
   <HTML>
   <HEAD>
   <TITLE>Holiday restrictions</TITLE>
   </HEAD>
   <BODY BGCOLOR="#ffffff">

   <IMG SRC ="$jpeg2url">

   <P>&nbsp;</P>

   <P><H2><B><FONT COLOR="#0080c0">Because the
   $holidayPtr holiday is a
   peak-demand time for $hotel_abbrev, we cannot accept
   reservations during the $numDays-day period from $startDay through
   $endDay unless you reserve for a minimum of $minDays days.
   </FONT></B></H2></P>

   <P><CENTER><B><FONT COLOR="#8080c0">Please use the Back button to
   return to the selections page to modify your reservation -- or call $hotel_abbrev
   at $hotelTelephone for more information.</FONT></B></CENTER></P>

   <P><CENTER><B><FONT COLOR="#8080c0">Thank you</FONT></B><HR></CENTER></P>


   </BODY>
   </HTML>
end_of_html

   exit;

} #end holiday_restrictions


################################################################################
#
#   Name:     selections_available
#
#   Function: generates form showing user-requested reservation selections
#
#   Inputs:   password
#             arrive month
#             arrive day
#             arrive year
#             depart month
#             depart day
#             depart year
#             No. guests
#             bed selection
#             pets preference
#             pets rate
#             pets amount
#             rollaway request
#             rollaway rate
#             rollaway amount
#             total amount for reservation
#             reservation deposit amount
#             No. reservation days (for any defined seasons/holidays)
#             room-tax rate                                            #09/12/01
#             room-tax amount                                          #09/12/01
#             other-tax rate                                           #09/12/01
#             other-tax amount                                         #09/12/01
#
#   Outputs:  all inputs are passed through as HTML hidden inputs
#
#   Caller:   res_main                             res_main.pl
#
#   Calls:    res_confirm                          res_confirm.pl
#
#                  MODIFICATION                               DATE        BY
#
#   Lakeside Inn                                            03/12/98    M. Lewis
#   Lakeside Inn   (add seasonal rates)                     06/13/98    M. Lewis
#   Lakeside Inn   (add weekend cruise processing)          06/14/98    M. Lewis
#   Rodeway Inn                                             09/11/98    M. Lewis
# automated system changes                                  06/25/99    M. Lewis
# Removed hidden input, type=password, causes bogus display.12/08/99    M. Lewis
# Pass room attributes and rate data as hidden inputs.      12/09/99    M. Lewis
# Change substitution to permit display of ' in season/h'day05/31/00    M. Lewis
# Delete centuryPrefixes from arrive/depart year displays   07/26/00    M. Lewis
# Enclose string in primes to prevent loss of multiple words08/06/00    M. Lewis
# Add code for subtotal, tax rate and tax amount.           09/12/01    M. Lewis
# Changed "rate per day" to "rate."                         11/11/01    M. Lewis
#
sub selections_available {

#Begin comments at col 50, end at 80:            50                            80

   my $totAmtf  = sprintf ("%.2f", $totAmt);
   my $subTotAmtf  = sprintf ("%.2f", $subTotAmt);                     #09/12/01
   my $petsAmtf = sprintf ("%.2f", $petsAmt);
   my $petRatef = sprintf ("%.2f", $petRate);
   my $rollAmtf = sprintf ("%.2f", $rollAmt);
   my $rollawayRatef = sprintf ("%.2f", $rollawayRate);
   my $depositf = sprintf ("%.2f", $deposit);
   my $taxf = sprintf ("%.2f", $tax);                                  #09/12/01
   my $roomTaxf = sprintf ("%.2f", $roomTax);                          #09/12/01
   my $taxFactorf = sprintf ("%.2f", ($taxFactor * 100));
   my $room_taxFactorf = sprintf ("%.2f",                              #09/12/01
                                  ($room_taxFactor * 100));            #09/12/01
   my $secureConfirmUrl = $secureUrl . 'res_confirm.pl';
   my $openConfirmUrl = $openUrl . 'hotel_res_confirm.pl';
   my $policiesFile = $openHtml . 'ytm_policies.html';
   my $resFormLink = $openUrl . 'res_form.pl';
   my $centuryPrefix = '';

   print "Content-Type: text/html\n\n";

   print "<html><head><title>$form_title</title></head>";
   print "<ENCTYPE=\"x-www-form-urlencoded\">";
   print "<BODY BGCOLOR=\"#ffffff\">";

   print "<IMG SRC =\"$jpeg2url\">";

   if ($FORM{'passwd'} eq '') {                  #If no password, process reser-
      print "<FORM METHOD=\"POST\"";             # vation from online customer
      print " ACTION=\"$secureConfirmUrl\">";
   }
   else {                                        #Password was entered, process
      print "<FORM METHOD=\"POST\"";             # reservation made by hotel
      print " ACTION=\"$openConfirmUrl\">";      # staff
   } #endif

##HOOK: BEGIN SELECTIONS-AVAILABLE DEFINE HIDDEN INPUTS
   print "<INPUT TYPE=\"hidden\" NAME=\"MemorialDayWkDay\" VALUE=$MemorialDayWkDay>\n";
   print "<INPUT TYPE=\"hidden\" NAME=\"MemorialDayFri\" VALUE=$MemorialDayFri>\n";
   print "<INPUT TYPE=\"hidden\" NAME=\"MemorialDaySat\" VALUE=$MemorialDaySat>\n";
   print "<INPUT TYPE=\"hidden\" NAME=\"NewYearsEveWkDay\" VALUE=$NewYearsEveWkDay>\n";
   print "<INPUT TYPE=\"hidden\" NAME=\"NewYearsEveFri\" VALUE=$NewYearsEveFri>\n";
   print "<INPUT TYPE=\"hidden\" NAME=\"NewYearsEveSat\" VALUE=$NewYearsEveSat>\n";
   print "<INPUT TYPE=\"hidden\" NAME=\"LaborDayWkDay\" VALUE=$LaborDayWkDay>\n";
   print "<INPUT TYPE=\"hidden\" NAME=\"LaborDayFri\" VALUE=$LaborDayFri>\n";
   print "<INPUT TYPE=\"hidden\" NAME=\"LaborDaySat\" VALUE=$LaborDaySat>\n";
   print "<INPUT TYPE=\"hidden\" NAME=\"LaborDayWkDay\" VALUE=$LaborDayWkDay>\n";
   print "<INPUT TYPE=\"hidden\" NAME=\"LaborDayFri\" VALUE=$LaborDayFri>\n";
   print "<INPUT TYPE=\"hidden\" NAME=\"LaborDaySat\" VALUE=$LaborDaySat>\n";
   print "<INPUT TYPE=\"hidden\" NAME=\"SkiSeasonWkDay\" VALUE=$SkiSeasonWkDay>\n";
   print "<INPUT TYPE=\"hidden\" NAME=\"SkiSeasonFri\" VALUE=$SkiSeasonFri>\n";
   print "<INPUT TYPE=\"hidden\" NAME=\"SkiSeasonSat\" VALUE=$SkiSeasonSat>\n";
   print "<INPUT TYPE=\"hidden\" NAME=\"NewYearsEveWkDay\" VALUE=$NewYearsEveWkDay>\n";
   print "<INPUT TYPE=\"hidden\" NAME=\"NewYearsEveFri\" VALUE=$NewYearsEveFri>\n";
   print "<INPUT TYPE=\"hidden\" NAME=\"NewYearsEveSat\" VALUE=$NewYearsEveSat>\n";
   print "<INPUT TYPE=\"hidden\" NAME=\"NewYearsEveWkDay\" VALUE=$NewYearsEveWkDay>\n";
   print "<INPUT TYPE=\"hidden\" NAME=\"NewYearsEveFri\" VALUE=$NewYearsEveFri>\n";
   print "<INPUT TYPE=\"hidden\" NAME=\"NewYearsEveSat\" VALUE=$NewYearsEveSat>\n";
   print "<INPUT TYPE=\"hidden\" NAME=\"SkiSeasonWkDay\" VALUE=$SkiSeasonWkDay>\n";
   print "<INPUT TYPE=\"hidden\" NAME=\"SkiSeasonFri\" VALUE=$SkiSeasonFri>\n";
   print "<INPUT TYPE=\"hidden\" NAME=\"SkiSeasonSat\" VALUE=$SkiSeasonSat>\n";
##HOOK: END SELECTIONS-AVAILABLE DEFINE HIDDEN INPUTS
   print "<INPUT TYPE=\"hidden\" NAME=\"depositf\" VALUE=$depositf>";

                                                                      #09/12/01
   print "<INPUT TYPE=\"hidden\" NAME=\"total amountf\" VALUE=$totAmtf>";

   print "<INPUT TYPE=\"hidden\" NAME=\"subTotAmtf\" VALUE=$subTotAmtf>";
   print "<INPUT TYPE=\"hidden\" NAME=\"arrive_month\" VALUE=$FORM{'arrive_month'}>";
   print "<INPUT TYPE=\"hidden\" NAME=\"arrive_day\" VALUE=$FORM{'arrive_day'}>";
   print "<INPUT TYPE=\"hidden\" NAME=\"arrive_year\" VALUE=$FORM{'arrive_year'}>";
   print "<INPUT TYPE=\"hidden\" NAME=\"depart_month\" VALUE=$FORM{'depart_month'}>";
   print "<INPUT TYPE=\"hidden\" NAME=\"depart_day\" VALUE=$FORM{'depart_day'}>";
   print "<INPUT TYPE=\"hidden\" NAME=\"depart_year\" VALUE=$FORM{'depart_year'}>";
   print "<INPUT TYPE=\"hidden\" NAME=\"Person_Cnt\" VALUE=$FORM{'Person_Cnt'}>";
   print "<INPUT TYPE=\"hidden\" NAME=\"select_bed\" VALUE=$FORM{'select_bed'}>";
   print "<INPUT TYPE=\"hidden\" NAME=\"number days\" VALUE=$numDays>";
   print "<INPUT TYPE=\"hidden\" NAME=\"have_pets\" VALUE=$FORM{'pet'}>";
   print "<INPUT TYPE=\"hidden\" NAME=\"petsAmtf\" VALUE=$petsAmtf>";
   print "<INPUT TYPE=\"hidden\" NAME=\"petRatef\" VALUE=$petRatef>";
   print "<INPUT TYPE=\"hidden\" NAME=\"require_rollaway\" VALUE=$FORM{'rollaway'}>";
   print "<INPUT TYPE=\"hidden\" NAME=\"rollAmtf\" VALUE=$rollAmtf>";
   print "<INPUT TYPE=\"hidden\" NAME=\"rollawayRatef\" VALUE=$rollawayRatef>";
   print "<INPUT TYPE=\"hidden\" NAME=\"depositf\" VALUE=$depositf>";
   print "<INPUT TYPE=\"hidden\" NAME=\"taxFactorf\" VALUE=$taxFactorf>";

                                                                        #09/12/01
   print "<INPUT TYPE=\"hidden\" NAME=\"room_taxFactorf\" VALUE=$room_taxFactorf>";
   print "<INPUT TYPE=\"hidden\" NAME=\"taxf\" VALUE=$taxf>";
   print "<INPUT TYPE=\"hidden\" NAME=\"roomTaxf\" VALUE=$roomTaxf>";

   print "<INPUT TYPE=\"hidden\" NAME=\"passwd\" VALUE=$FORM{'passwd'}>";

   print "<FONT SIZE=+1>The accommodations you have selected are available:</FONT>";
   print "<p>Arriving: $FORM{'arrive_month'} $FORM{'arrive_day'}";
   print ", 20$FORM{'arrive_year'}<br>";                                #07/26/00

   print "Departing: $FORM{'depart_month'} $FORM{'depart_day'}";
   print ", 20$FORM{'depart_year'}<br>";                                #07/26/00
   print "<p>No. guests: $FORM{'Person_Cnt'}<br>";

         @temp = split(/\|/, $roomDef{$FORM{'select_bed'}}); #Get rmDef rec in local
   #
   #The purpose of the rest of this block is to isolate room attribute
   # values from room-type definition keys
   #
         $optionVal = $FORM{'select_bed'};
         $optionVal =~ s/\d//g;                   #Keep alpha string only

         unless ($optionVal =~ /NS$/) {           #Set smoking-allowed flag?
                 $smokeFlg = $true}
         else {
                 $smokeFlg = $false}
         # end unless

         $rmFlags = $FORM{'select_bed'};
         $rmFlags =~ s/\'| |[A-Z]//g;             #Keep integer string only
         @rmAttrib = split(//, $rmFlags);         #Array of attribute flags

         $rmDescription = $temp[0];               #Keep rm description string
         $rmDescription =~ s/\'//g;               #Get rid of ' chars

         #Add appropriate attributes to room-description string.
         #
         if ($rmAttrib[$kitchenKey]) {
                 $rmDescription .= ', ' . $displayAttrib[$kitchenKey][0]}
         #endif
         if ($rmAttrib[$spaKey]) {
                 $rmDescription .= ', ' . $displayAttrib[$spaKey][0]}
         #endif
         if ($rmAttrib[$fridgeKey]) {
                 $rmDescription .= ', ' . $displayAttrib[$fridgeKey][0]}
         #endif
         if ($rmAttrib[$microwaveKey]) {
                 $rmDescription .= ', ' . $displayAttrib[$microwaveKey][0]}
         #endif
         if ($rmAttrib[$fireplaceKey]) {
                 $rmDescription .= ', ' . $displayAttrib[$fireplaceKey][0]}
         #endif
         if ($smokeFlg) {
                 $rmDescription .= ', ' . $displayAttrib[$hasSmoking][0]}
         else {
                 $rmDescription .= ', ' . $displayAttrib[$noSmoking][0]}
         #endif

   print "<p>Room: $rmDescription<br>";

   #Pass this string on to subsequent processes.                        #12/09/99
   print                                                                #12/09/99
        "<INPUT TYPE=\"hidden\" NAME=\"rmDescription\" VALUE=\"$rmDescription\">";

        my $dateRates = @dateRates;               #Array defined in
                                                  # res_main.pl
        #Do the actual room charges
        #
        for ($i = 0; $i < $dateRates; $i++) {
          #Since @dateRates is an array of references (see res_main),
          # we have to dereference each item in @dateRates to get at
          # the actual data.  Dereferencing occurs in two steps: first
          # we assign a given item to a scalar:
          #
          my $a = $dateRates[$i];
          #
          #then we dereference the scalar (which contains a reference
          # to an item of real data:
          #
          my @b = @$a;
          #
          #Now we're pointing to a 1-dim array of four items of real
          # data, which look like:
          #  @b = (
          #        'Aug 06, 1999', '37.95', 'weekday (Sun-Thurs)', 'Hot August Nights'
          #       );
          #
          my $date = $b[0];
          $date =~ s/\'//g;
          my $amt = $b[1];
          $amt =~ s/\'//g;
          my $wkDay = $b[2];
          $wkDay =~ s/\'//g;
          my $dayType = $b[3];
          $dayType =~ s/\"//g;                                         #05/31/00
          #
          print "<p>$date: \$$amt ($dayType $wkDay rate) ";            #11/11/01
          #
          #Pass these values on to subsequent processes.               #12/09/99
          #                                                            #12/09/99
          $hideName = 'date' . $i;                                     #12/09/99
          print                                                        #12/09/99
            "<INPUT TYPE=\"hidden\" NAME=$hideName VALUE=\"$date\">";  #12/09/99
          #                                                            #12/09/99
          $hideName = 'amt' . $i;                                      #12/09/99
          print                                                        #12/09/99
            "<INPUT TYPE=\"hidden\" NAME=$hideName VALUE=$amt>";       #12/09/99
          #                                                            #12/09/99
          $hideName = 'wkDay' . $i;                                    #12/09/99
          print                                                        #12/09/99
            "<INPUT TYPE=\"hidden\" NAME=$hideName VALUE=\"$wkDay\">"; #12/09/9
          #                                                            #12/09/99
          $hideName = 'dayType' . $i;                                  #12/09/99
          print                                                        #12/09/99
            "<INPUT TYPE=\"hidden\" NAME=$hideName VALUE=\"$dayType\">";#08/06/00
        }#end for

   if ($FORM{'pet'}) {
      print "<p>Pet is an additional \$$petsAmtf (\$$petRatef per day).</p>"}
   #endif

   if ($FORM{'rollaway'}) {
      print "<p>Rollaway bed is an additional \$$rollAmtf (\$$rollawayRatef per day).</p>"}
   #endif

   print "<p><FONT SIZE=+1>Subtotal for </FONT>$numDays ";             #09/12/01
   print "<FONT SIZE=+1>day(s) is </FONT>\$$subTotAmtf";               #09/12/01

   if ($tax)         {                                                 #09/12/01
     print "<p><FONT SIZE=+1>Tax at </FONT>$taxFactorf\% ";            #09/12/01
     print "<FONT SIZE=+1>is </FONT>\$$taxf";                          #09/12/01
   } #endif                                                            #09/12/01

   if ($roomTax) {                                                     #09/12/01
     print "<p><FONT SIZE=+1>Room tax at </FONT>$room_taxFactorf\% ";  #09/12/01
     print "<FONT SIZE=+1>is </FONT>\$$roomTaxf";                      #09/12/01
   } #endif                                                            #09/12/01

   print "<p><FONT SIZE=+1>Total amount: </FONT>\$$totAmtf";           #09/12/01

   print "<p><FONT SIZE=+1>Deposit for this room is: </FONT>\$$depositf</p>";
   print "<hr>";

   print "<P><CENTER><INPUT TYPE=\"submit\" NAME=\"confirm your reservation\" VALUE=";
   print "\"Click here to confirm your reservation\"></CENTER></P>";

   print "<a href=\"$policiesFile\">";
   print "$hotel_manager policies and restrictions</a>";

   print "<p>Press <b>Back</b> at top left of screen to return to the reservations form";

   print "</body>";
   print "</html>";

   exit;                                         #Important to exit res_main
} #end selections_available                      # here


################################################################################
#
#   Name:     bad_date_entry
#
#   Function: generates page: requestor entered one or more invalid arrive/
#             depart dates
#
#   Inputs:
#
#   Outputs:
#
#   Caller:   chk_arrive_depart_dates                   res_lib.pl
#
#   Calls:
#
sub bad_date_entry {

  my $resFormLink = $openUrl . 'res_form.pl';

   print "Content-Type: text/html\n\n";

print <<end_of_html;
   <html>
   <head>
   <title>$form_title</title></head>

   <BODY BGCOLOR="#ffffff">

   <IMG SRC ="$jpeg2url">

   <H2><B><FONT COLOR="#0080c0">
   One or more of the arrival/departure dates that you entered is
   invalid.  Please correct the dates and reenter the reservation.</FONT>
   </H2>
   <hr>
   <p>Press <b>Back</b> at top left of screen to return to the reservations form

   </body>
   </html>
end_of_html
   exit;
} #end bad_date_entry


################################################################################
#
#   Name:     too_many_days
#
#   Function: generates page: requestor tried to reserve for too many days
#
#   Inputs:
#
#   Outputs:
#
#   Caller:    res_main                 res_main.pl
#
#   Calls:
#
sub too_many_days {

  my $resFormLink = $openUrl . 'res_form.pl';

   print "Content-Type: text/html\n\n";

print <<end_of_html;
   <html>
   <head>
   <title>$form_title</title></head>

   <BODY BGCOLOR="#ffffff">

   <IMG SRC ="$jpeg2url">

   <H2><B><FONT COLOR="#0080c0">
   The maximum number of days for which you can reserve rooms
   through the online reservation system is $maxDays.  Please adjust your
   selection accordingly or contact $hotel_abbrev at $hotelTelephone.</FONT>
   </h2>
   <hr>
   <p>Press <b>Back</b> at top left of screen to return to the reservations form

   </body>
   </html>
end_of_html
   exit;
} #end too_many_days



################################################################################
#
#   Name:     max_occupants
#
#   Function: generates page: requestor tried to reserve for too many occupants
#
#   Inputs:
#
#   Outputs:
#
#   Caller:   res_main                           res_main.pl
#
#   Calls:
#
#                    MODIFICATION                            DATE         BY
#
# autosys revise                                           10/03/99     M. Lewis
#
sub max_occupants {

  my $maxOccupants = shift(@_);
  my $resFormLink = $openUrl . 'res_form.pl';
  print "Content-Type: text/html\n\n";

print <<end_of_html;
   <html>
   <head>
   <title>$form_title</title></head>

   <BODY BGCOLOR="#ffffff">

   <IMG SRC ="$jpeg2url">

   <H2><B><FONT COLOR="#0080c0">
   The maximum number of occupants for this room is $maxOccupants.  If rollaway beds
   are available as an option, a rollaway will be included in your reservation
   and you will be allowed one additional occupant over the maximum.
   If your party is larger than the maximum for the room, please select a larger
   room, make additional
   online reservations or contact $hotel_abbrev at $hotelTelephone.</FONT>
   </h2>
   <hr>
   <p>Press <b>Back</b> at top left of screen to return to the reservations form

   </body>
   </html>
end_of_html
   exit;
} #end max_occupants


################################################################################
#
#   Name:     too_far_ahead
#
#   Function: generates page: requestor tried to reserve too far ahead
#
#   Inputs:
#
#   Outputs:
#
#   Caller:   res_main                 res_main.pl
#
#   Calls:
#
#                 MODIFICATION                               DATE           BY
#
#   Stateline Lodge                                        05/12/98     M. Lewis
#   Inn at Heavenly (max future date = one year)           09/19/98     M. Lewis
#   Rodeway Inn                                            09/19/98     M. Lewis
# autosys revise                                           10/03/99     M. Lewis
#
sub too_far_ahead {

        my $maxDay = shift(@_);
        my $maxMonth = shift(@_);
        my $maxYear = shift(@_);
        my $maxCentury = shift(@_);
  my $resFormLink = $openUrl . 'res_form.pl';
  my $centuryPrefix = '';

  print "Content-Type: text/html\n\n";

print <<end_of_html;
   <html>
   <head>
   <title>$form_title</title></head>

   <BODY BGCOLOR="#ffffff">

   <IMG SRC ="$jpeg2url">

   <H2><B><FONT COLOR="#0080c0">
   You cannot make an online reservation for dates later than $maxMonth $maxDay,
   $maxCentury$maxYear.  Please contact $hotel_abbrev at $hotelTelephone to
   reserve for dates past this limit.</FONT>
   </h2>
   <hr>
   <p>Press <b>Back</b> at top left of screen to return to the reservations form

   </body>
   </html>
end_of_html
   exit;
} #end too_far_ahead


################################################################################
#
#   Name:     undefined_date
#
#   Function: generates page: requestor tried to reserve for a date that is not
#             defined in this reservation system
#
#   Inputs:
#
#   Outputs:
#
#   Caller:   res_main                  res_main.pl
#
#   Calls:    timelocal                 Perl standard library (PP p. 515)
#             format_display_year       res_lib.pl
#
#                  MODIFICATION                             DATE          BY
#
# autosys                                                 10/03/99      M. Lewis
#
sub undefined_date {

  my $resFormLink = $openUrl . 'res_form.pl';
  my $centuryPrefix = '';

  (my $sec, my $min, my $hour, my $day,
   my $month, my $year, my $wDay, my $yDay,
   my $isdst) =
        localtime($maxCalendarDate - $oneDay);

  $outMonth   = $months[$month];                  #Need full spelling for month
                                                  # (three chars)
        ($centuryPrefix, $year) =
                &format_display_year($year);

  print "Content-Type: text/html\n\n";

print <<end_of_html;
   <html>
   <head>
   <title>$form_title</title></head>

   <BODY BGCOLOR="#ffffff">

   <IMG SRC ="$jpeg2url">

   <H2><B><FONT COLOR="#0080c0">
   You cannot make an online reservation for dates later than $outMonth $day,
   $centuryPrefix$year.</FONT>
   </h2>
   <hr>
   <p>Press <b>Back</b> at top left of screen to return to the reservations form

   </body>
   </html>
end_of_html
   exit;
} #end undefined_date


################################################################################
#
#   Name:     room_unavailable
#
#   Function: notify requestor that selected room is unavailable for the period
#             requested
#
#   Inputs:
#
#   Outputs:
#
#   Caller:   res_main                 res_main.pl
#             hotel_res_complete       hotel_res_complete.pl
#
#   Calls:
#
sub room_unavailable {

  my $resFormLink = $openUrl . 'res_form.pl';

   print "Content-Type: text/html\n\n";
print <<end_of_html;
   <html>
   <head>
   <title>$form_title</title></head>
   <BODY BGCOLOR="#ffffff">

   <IMG SRC ="$jpeg2url">

   <H2><B><FONT COLOR="#0080c0">
   The room you have selected is unavailable for one or
   more of the dates you have selected.  Return to the reservations
   form to try another selection -- or call $hotelTelephone to make your
   reservations by telephone.</FONT>
   </h2>
   <hr>
   <p>Press <b>Back</b> at top left of screen to return to the reservations form

   </body>
   </html>
end_of_html

   exit;
} #end room_unavailable


################################################################################
#
#   Name:     get_bed_type
#
#   Function: generates page: user did not select a bed-type option in his
#             reservation request
#
#   Inputs:
#
#   Outputs:
#
#   Caller:   form_key                  res_lib.pl
#
#   Calls:
#
sub get_bed_type {

  my $resFormLink = $openUrl . 'res_form.pl';

   print "Content-Type: text/html\n\n";

print <<end_of_html;
   <html>
   <head>
   <title>$form_title</title></head>
   <BODY BGCOLOR="#ffffff">

   <IMG SRC ="$jpeg2url">

   <H2><B><FONT COLOR="#0080c0">
   You must select a room for your reservation!</FONT>
   </h2>
   <hr>
   <p>Press <b>Back</b> at top left of screen to return to the reservations form

   </body>
   </html>
end_of_html
   exit;
} #end get_bed_type



################################################################################
#
#   Name:     hotel_missing_info
#
#   Function: generates page: user did not enter required information in com-
#             pleting this reservation
#
#   Inputs:
#
#   Outputs:
#
#   Caller:   hotel_res_confirm         hotel_res_confirm.pl
#
#   Calls:
#
sub hotel_missing_info {

   print "Content-Type: text/html\n\n";

print <<end_of_html;
   <html>
   <head>
   <title>$form_title</title></head>
   <BODY BGCOLOR="#ffffff">

   <IMG SRC ="$jpeg2url">

   <H2><B><FONT COLOR="#0080c0">
   You must complete all required fields to process this
   reservation.  Press Back button at top left of screen to return
   to the registration form.</FONT>
   </h2>
   <hr>

   </body>
   </html>
end_of_html

   exit;

} #end hotel_missing_info


################################################################################
#
#   Name:     hotel_reservation_complete
#
#   Function: generates page: reservation complete, show user
#
#   Inputs:   arrive month
#             arrive day
#             arrive year
#             depart month
#             depart day
#             depart year
#             No. guests
#             room description
#             pets preference
#                   pets rate
#                   pets amount
#             rollaway request
#                   rollaway rate
#                   rollaway amount
#             total amount for reservation
#             reservation deposit amount
#             No. reservation days (for any defined seasons/holidays)
#             customer comments
#             reservation transaction No.
#             total No. reservation days
#             email address
#             hotel telephone No.
#             subtotal amount                                          #09/14/01
#             room-tax rate                                            #09/14/01
#             room-tax amount                                          #09/14/01
#             other-tax rate                                           #09/14/01
#             other-tax amount                                         #09/14/01
#
#   Outputs:
#
#   Caller:   hotel_res_complete                 hotel_res_complete.pl
#
#   Calls:
#
#                             MODIFICATION                         DATE         BY
#
#   Lakeside Inn                                           04/10/98     M. Lewis
#   Lakeside Inn   (add seasonal rates)                    06/13/98     M. Lewis
#   Lakeside Inn   (add weekend cruise processing)         06/15/98     M. Lewis
#   Rodeway Inn                                            09/14/98     M. Lewis
# Automated system update                                  08/30/00     M. Lewis
# Add code for subtotal, tax rate and tax amount.           09/13/01    M. Lewis
# Changed "rate per day" to "rate."                         11/11/01    M. Lewis
#
sub hotel_reservation_complete {

#   print "Content-Type: text/html\n\n";

   print "<html><head><title>$form_title</title></head>";
   print "<ENCTYPE=\"x-www-form-urlencoded\">";
   print "<BODY BGCOLOR=\"#ffffff\">";

   print "<IMG SRC =\"$jpeg2url\">";

   print "<h2>This <b>$hotel_abbrev</b> online reservation is complete:</h2>";

   print "Reservation processed by: $passwd{$FORM{'passwd'}}<br><br>";

  print "<p>Arriving: $FORM{'arrive_month'} $FORM{'arrive_day'}";
  print ", 20$FORM{'arrive_year'}<br>";

  print "Departing: $FORM{'depart_month'} $FORM{'depart_day'}";
  print ", 20$FORM{'depart_year'}<br>";

  print "<p>No. guests: $FORM{'Person_Cnt'}<br>";
  print "<p>Room: $FORM{'rmDescription'}<br>";

  #Display the dates and room charges (arrays defined in res_complete.pl).
  #
  for ($i = 0; $i < $FORM{'number days'}; $i++) {
    print "<p>$dispDate[$i]: \$$dispAmt[$i] ($dispDayType[$i] $dispWkDay[$i] ";
    print "rate)";                                                    #11/11/01
  } #end for

  if ($FORM{'have_pets'}) {
    print "<p>Pet is an additional \$$FORM{'petsAmtf'} ";
    print "(\$$FORM{'petRatef'} per day).</p>";
  } #endif

  if ($FORM{'require_rollaway'}) {
    print "<p>Rollaway bed is an additional \$$FORM{'rollAmtf'} ";
    print "(\$$FORM{'rollawayRatef'} per day).</p>";
  } #endif

  if ( $FORM{'Comments'} ){
    print "<p>Comments/requests to the <b>$hotel_abbrev</b> staff:<br>";
    print "$FORM{'Comments'}<br>";
  } #endif

  print "<p>ONLINE RESERVATION NUMBER: $transNum.  Keep this number.";
  print "The <b>$hotel_abbrev</b> will need it to modify or cancel "; #09/13/01
  print "this reservation.<br>";                                      #09/13/01

  print "<p>";

  print "<p><FONT SIZE=+1>Subtotal for </FONT>$FORM{'number days'} ";  #09/12/01
  print "days is \$$FORM{'subTotAmtf'}";                               #09/13/01

  if ($FORM{'taxf'}) {                                                 #09/13/01
    print "<p><FONT SIZE=+1>Tax at </FONT>$FORM{'taxFactorf'}\% ";     #09/13/01
    print "<FONT SIZE=+1>is </FONT>\$$FORM{'taxf'}";                   #09/13/01
  } #endif                                                             #09/13/01

  if ($FORM{'roomTaxf'}) {                                             #09/13/01
    print "<p><FONT SIZE=+1>Room tax at </FONT>";                      #09/13/01
    print "$FORM{'room_taxFactorf'}\% <FONT SIZE=+1>is </FONT>";       #09/13/01
    print "\$$FORM{'roomTaxf'}";                                       #09/13/01
  } #endif                                                             #09/13/01

  print "<p>Total amount for $FORM{'number days'} day(s) is ";
  print "\$$FORM{'total amountf'}<br>";
  print "<p>The deposit for this room is: \$$FORM{'depositf'}";

  print "<hr>";

  print "</body></html>";

  exit;
} #end hotel_reservation_complete


1;

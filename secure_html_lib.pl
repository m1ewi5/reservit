#!/usr/bin/perl


################################################################################
#
#   Name:     missing_info
#
#   Function: generates page: user did not enter required information in com-
#             pleting this reservation
#
#   Inputs:
#
#   Outputs:
#
#   Caller:   res_confirm               res_confirm.pl
#
#   Calls:
#
sub missing_info {

  print "Content-Type: text/html\n\n";
print <<end_of_html;
     <html>
     <head>
   <title>$form_title</title></head>
   <BODY BGCOLOR="#ffffff">

   <IMG SRC ="$jpeg2url">

   <h2>
   You must complete all required fields to complete your
   reservation!  Please press Back button at top left of screen to return
   to the registration form.
   </h2>
   <hr>

   </body>
   </html>
end_of_html

  exit;

} #end missing_info


################################################################################
#
#   Name:     reservation_complete
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
#             pets rate
#             pets amount
#             rollaway request
#             rollaway rate
#             rollaway amount
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
#   Caller:   res_complete                      res_complete.pl
#
#   Calls:
#
#                MODIFICATION                                  DATE       BY
#
# Lakeside Inn                                               04/10/98   M. Lewis
# Lakeside Inn   (add seasonal rates)                        06/13/98   M. Lewis
# Lakeside Inn   (add weekend cruise processing)             06/14/98   M. Lewis
# Rodeway Inn                                                09/14/98   M. Lewis
# Automated system revision                                  12/08/99   M. Lewis
# Fix display for arrive and depart years.  Get rid of     07/21/00     M. Lewis
#  test for century prefix.  It's all 21st century now.
# Add code for subtotal, tax rate and tax amount.           09/13/01    M. Lewis
# Changed "rate per day" to "rate."                         11/11/01    M. Lewis
#
sub reservation_complete {

  my $resFormLink = $openUrl . 'res_form.pl';
  my $centuryPrefix = '';

  print "Content-Type: text/html\n\n";

  print "<html><head><title>$form_title</title></head>\n";
  print "<ENCTYPE=\"x-www-form-urlencoded\">\n";
  print "<BODY BGCOLOR=\"#ffffff\">\n";

  print "<IMG SRC =\"$jpeg2url\">\n";

  print
    "<p><h2>Your <b>$hotel_abbrev</b> online reservation is complete:</h2>\n";

  print "<p>Arriving: $FORM{'arrive_month'} $FORM{'arrive_day'}\n";
  print ", 20$FORM{'arrive_year'}<br>\n";

  print "Departing: $FORM{'depart_month'} $FORM{'depart_day'}\n";
  print ", 20$FORM{'depart_year'}<br>\n";

  print "<p>No. guests: $FORM{'Person_Cnt'}<br>\n";
  print "<p>Room: $FORM{'rmDescription'}<br>\n";

  #Display the dates and room charges (arrays defined in res_complete.pl).
  #
  for ($i = 0; $i < $FORM{'number days'}; $i++) {
    print "<p>$dispDate[$i]: \$$dispAmt[$i] ($dispDayType[$i] $dispWkDay[$i] ";
    print "rate)\n";                                                   #11/11/01
  } #end for

  if ($FORM{'have_pets'}) {
    print "<p>Pet is an additional \$$FORM{'petsAmtf'} ";
    print "(\$$FORM{'petRatef'} per day).</p>\n";
  } #endif

  if ($FORM{'require_rollaway'}) {
    print "<p>Rollaway bed is an additional \$$FORM{'rollAmtf'} ";
    print "(\$$FORM{'rollawayRatef'} per day).</p>\n";
  } #endif

  if ($FORM{'Comments'} ){
    print "<p>Your comments/requests to the <b>$hotel_manager</b> ";
    print "staff:<br>\n";
    print "$FORM{'Comments'}<br>\n";
  } #endif

  print "<p>ONLINE RESERVATION NUMBER: $transNum.  Please keep this ";
  print "number.  \n";
  print "The <b>$hotel_abbrev</b> will need it to modify or cancel ";
  print "your reservation.<br>\n";

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
  print "\$$FORM{'total amountf'} \n";
  print "(includes $FORM{'taxFactorf'}\% tax)<br>\n";
  print "<p>The deposit for this room is: \$$FORM{'depositf'}\n";
  print "(this amount has been charged to your credit card)</p>\n";
  print "<p>An email confirmation of your reservation is being sent to the ";
  print "following \n";
  print "address: <br>$FORM{'Email'}</p>\n";
  print "<p>To contact the <b>$hotel_manager</b> staff by telephone, please ";
  print "call \n";
  print "$hotelTelephone<\p>\n";
  print "<hr>\n";

  print "<a href=\"$resFormLink\">\n";
  print "Back to the reservations form</a>\n";

  print "</body></html>\n";

  exit;                                          #Important to exit
                                                 # reservation_complete here!
} #end reservation_complete



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
#   Caller:   res_complete                       res_complete.pl
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

   <h2>
   The room you have selected is unavailable for one or
   more of the dates you have selected.  Return to the reservations
   form to try another selection -- or call $hotelTelephone to make your
   reservations by telephone.
   </h2>
   <hr>
   <p>Press <b>Back</b> at top left of screen three times to return to the reservations form

   </body>
   </html>
end_of_html

  exit;
} #end room_unavailable


1;

#!/usr/local/bin/perl5
require('global_data.pl');
#Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis


################################################################################
#
#   Name:     res_cancel_email
#
#   Function: emails reservation cancellation data to motel/hotel and system
#             staffs.
#
#   Inputs:   name of user generating cancellation
#             email address(es) of recipient(s)
#             name string of email recipient(s)
#
#   Outputs:
#
#   Caller:   res_cancel                        res_cancel.pl
#
#   Calls:
#
#                               MODIFICATION                         DATE       BY
#
#   Lakeside Inn                                                         04/12/98   M. Lewis
#   Rodeway                                                                  11/25/98   M. Lewis
# Automated system update                                    09/03/00   M. Lewis
#
sub res_cancel_email {

   #variables
   my $canceledBy = shift(@_);
   my $recipient = shift(@_);
   my $to_block = shift(@_);
   my $centuryPrefix = '';

   #constants
   my $inDay = 1;
   my $inMonth = 2;
   my $inYear = 3;
   my $outDay = 5;
   my $outMonth = 6;
   my $outYear = 7;
   my $lastName = 8;
   my $address = 9;
   my $city = 10;
   my $state = 11;
   my $country = 12;
   my $zip = 13;
   my $email = 14;
   my $phone = 15;
   my $selectBed = 16;
   my $firstName = 19;

   open (MAIL, "|$mailprog $recipient") || die
                  "Can't open $mailprog!\n";

   print MAIL
      "Reply-to: $recipient ($hotel_manager)\n";
   print MAIL
      "From: $sys_manager Online Reservation System\n";
   print MAIL "Subject: Online room reservation CANCELLATION for $hotel_abbrev\n\n";
   print MAIL "------------------------------------------------------\n";

   print MAIL "To: $to_block staff(s):\n\n";

   print MAIL "Reservation $FORM{'trans_num'} has been canceled by ";
   print MAIL "$canceledBy\n\n";

   print MAIL "Guest name: $cancelData[$firstName] $cancelData[$lastName]\n\n";

   print MAIL "Email address: <$cancelData[$email]>\n\n";

   print MAIL "Address: $cancelData[$address]\n";

   print MAIL "City: $cancelData[$city]\n";

   print MAIL "State: $cancelData[$state]\n";

   print MAIL "ZIP: $cancelData[$zip]\n";

   print MAIL "Country: $cancelData[$country]\n\n";

   print MAIL "Home telephone: $cancelData[$phone]\n\n";

   print MAIL "Room selection: $roomRec[$roomType]\n\n";

   print MAIL "Reservation dates --\n";
#Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis
   print MAIL "   From: $cancelData[$inMonth] ";
   print MAIL "$cancelData[$inDay], ";

   print MAIL "20$cancelData[$inYear]\n";

   print MAIL "   To:   $cancelData[$outMonth] ";
   print MAIL "$cancelData[$outDay], ";

   print MAIL "20$cancelData[$outYear]\n\n";

   print MAIL " - $date\n";

   print MAIL "------------------------------------------------------\n";

   close (MAIL);

   return;
} #end res_cancel_email


################################################################################
#
#   Name:     hotel_mail_hotel
#
#   Function: email reservation data to motel/hotel staff
#
#   Inputs:   arrive month
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
#             date for each res day
#             rate for each res day
#             day-of-week specifier for each res day
#             season/holiday name associated with each res day
#             total amount for reservation
#             reservation deposit amount
#             reservation transaction No.
#             total No. reservation days
#             email address
#             hotel telephone No.
#             system-manager email address
#             system-manager name
#             hotel abbreviation
#             hotel name
#             guest name
#             guest email address
#             guest company name
#             guest address1
#             guest address2
#             guest city
#             guest state
#             guest ZIP
#             guest country
#             best time to call
#             guest work phone
#             guest fax phone
#             guest home phone
#             guest comments
#             reservation transaction No.
#             room deposit amount
#             user name of hotel-staff employee                        #11/09/01
#
#   Outputs:
#
#   Caller:   hotel_res_complete              hotel_res_complete.pl
#
#   Calls:
#
#                        MODIFICATION                        DATE        BY
#
#   Harvey's Hotel/Casino                                  02/18/98   M. Lewis
#   Lakeside Inn                                           04/11/98   M. Lewis
#   Lakeside Inn   (add seasonal rates)                    06/13/98   M. Lewis
#   Lakeside Inn   (add weekend cruise processing)         06/14/98   M. Lewis
#   Rodeway Inn                                            09/14/98   M. Lewis
# Automated system update                                    08/28/00   M. Lewis
# Add code for subtotal, tax rate and tax amount.           09/13/01    M. Lewis
# Add code to display name of employee who processed the res 11/09/01   M. Lewis
# Changed "rate per day" to "rate."                         11/11/01    M. Lewis
#
sub hotel_mail_hotel {

  my $date =                                                           #12/12/99
    `$date_command +"%A, %B %d, %Y at %T (%Z)"`;                       #12/12/99
  chop($date);                                                         #12/12/99

  open (MAIL, "|$mailprog $hotel_email") ||
    die "Can't open $mailprog!\n";

  print MAIL
    "Reply-to: $hotel_email ($hotel_manager')\n";
  print MAIL
    "From: $hotel_email ($hotel_manager)\n";
  print MAIL
    "Subject: New online room reservation via $sys_manager for $hotel_abbrev\n\n";
  print MAIL "------------------------------------------------------\n";

  print MAIL "To: $hotel_manager staff:\n\n";

  print MAIL "Reservation processed by: $passwd{$FORM{'passwd'}}\n\n"; #11/09/01

  print MAIL "Guest Name: $FORM{'firstName'} $FORM{'lastName'}\n";

  print MAIL "Email address: <$FORM{'Email'}>\n";

  print MAIL "Address: $FORM{'Address1'}\n";


   if ( $FORM{'Company'} ){
    print MAIL "Company: $FORM{'Company'}\n";
  }

  if ( $FORM{'Address2'} ){
    print MAIL "Address: $FORM{'Address2'}\n";
  }

  print MAIL "City: $FORM{'City'}\n";

  print MAIL "State: $FORM{'State'}\n";

  print MAIL "ZIP: $FORM{'Zip'}\n";

  print MAIL "Country: $FORM{'Country'}\n\n";

  if ( $FORM{'CallTime'} ){
    print MAIL "Best time to call: $FORM{'CallTime'}\n";
  }

  if ( $FORM{'Work_Phone'} ){
    print MAIL "Work telephone: $FORM{'Work_Phone'}\n";
  }

  if ( $FORM{'Fax_Number'} ){
    print MAIL "Fax telephone: $FORM{'Fax_Number'}\n";
  }

  print MAIL "Home telephone: $FORM{'Home_Phone'}\n\n";

  print MAIL "No. guests: $FORM{'Person_Cnt'}\n";

  print MAIL "Room selected: $FORM{'rmDescription'}\n";

  print MAIL "\n";

  if ($FORM{'have_pets'}) {
    print MAIL "Permission to have pets in room requested.\n";
  } #endif

  if ($FORM{'require_rollaway'}) {
    print MAIL "Rollaway bed requested.\n";
  } #endif

  print MAIL "\nFrom: $FORM{'arrive_month'} ";
  print MAIL "$FORM{'arrive_day'}, ";

  print MAIL "20$FORM{'arrive_year'}\n";                               #07/23/00

  print MAIL "To: $FORM{'depart_month'} ";
  print MAIL "$FORM{'depart_day'}, ";

  print MAIL "20$FORM{'depart_year'}\n\n";                             #07/23/00

  print MAIL "Charges:\n";

  #Display the dates and room charges (arrays defined in hotel_res_complete.pl).
  #
  for ($i = 0; $i < $FORM{'number days'}; $i++) {
    print MAIL "$dispDate[$i]: \$$dispAmt[$i] ($dispDayType[$i] ";
    print MAIL "$dispWkDay[$i] rate)\n";                               #11/11/01
  } #end for

  if ($FORM{'have_pets'}) {
    print MAIL "\nPet is an additional \$$FORM{'petsAmtf'} ";
    print MAIL "(\$$FORM{'petRatef'} per day).\n";
  } #endif

  if ($FORM{'require_rollaway'}) {
     print MAIL "Rollaway bed is an additional \$$FORM{'rollAmtf'} ";
     print MAIL "(\$$FORM{'rollawayRatef'} per day).\n";
  } #endif

  print MAIL "\nSubtotal: ";                                           #09/13/01
  print MAIL "\$$FORM{'subTotAmtf'}\n";                                #09/13/01

  if ($FORM{'taxf'}) {                                                 #09/13/01
    print MAIL "\nTax at $FORM{'taxFactorf'}\%: ";                     #09/13/01
    print MAIL "\$$FORM{'taxf'}\n";                                    #09/13/01
  } #endif                                                             #09/13/01

  if ($FORM{'roomTaxf'}) {                                             #09/13/01
    print MAIL "\nRoom tax at $FORM{'room_taxFactorf'}\%: ";           #09/13/01
    print MAIL "\$$FORM{'roomTaxf'}\n";                                #09/13/01
  } #endif                                                             #09/13/01

  print MAIL "\nTotal amount for $FORM{'number days'} day(s): ";
  print MAIL "\$$FORM{'total amountf'}\n\n";                           #09/13/01

  if ($FORM{'Comments'}){
    print MAIL "Comments: $FORM{'Comments'}\n\n";
  }

  print MAIL "ONLINE RESERVATION NUMBER: $transNum\n\n";

  print MAIL
    "Reservation deposit: \$$FORM{'depositf'}\n\n";

  print MAIL " - $date\n";

  print MAIL "------------------------------------------------------\n";

  close (MAIL);

  return;
} #end hotel_mail_hotel


1;

#!/usr/bin/perl

#Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis

################################################################################
#
#   Name:     mail_hotel
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
#                   pets rate
#                   pets amount
#             rollaway request
#                   rollaway rate
#                   rollaway amount
#                   date for each res day
#                   rate for each res day
#                   day-of-week specifier for each res day
#                   season/holiday name associated with each res day
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
#             credit-card type
#             credit-card No.
#             credit-card expiration date
#             credit-card name
#             room deposit amount
#
#   Outputs:
#
#   Caller:   res_complete                   res_complete.pl
#
#   Calls:
#
#                   MODIFICATION                              DATE        BY
#
#   Harvey's Hotel/Casino                                   02/18/98    M. Lewis
#   Lakeside Inn                                            04/10/98    M. Lewis
#   Lakeside Inn   (add seasonal rates)                     06/13/98    M. Lewis
#   Lakeside Inn   (add weekend cruise processing)          06/14/98    M. Lewis
#   Rodeway Inn                                             09/14/98    M. Lewis
# Automated system revision                                 12/09/99    M. Lewis
# Move date computation here from res_complete.pl           12/12/99    M. Lewis
# Get rid of century prefixes for arrive/depart year displays07/23/00   M. Lewis
# Add code for subtotal, tax rate and tax amount.           09/13/01    M. Lewis
# Changed "rate per day" to "rate."                         11/11/01    M. Lewis
#
sub mail_hotel {

  my $date =                                                           #12/12/99
    `$date_command +"%A, %B %d, %Y at %T (%Z)"`;                             #12/12/99
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

  #Display the dates and room charges (arrays defined in res_complete.pl).
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

  if ( $FORM{'Comments'} ){
    print MAIL "Comments: $FORM{'Comments'}\n\n";
  }

  print MAIL "ONLINE RESERVATION NUMBER: $transNum\n\n";

  print MAIL "Credit card information:\n";
  print MAIL "   Credit card type: $FORM{'ccdtype'}\n";
  print MAIL "   Credit card number: $FORM{'ccdnum'}\n";
  print MAIL "   Expiration date: $FORM{'expmon'}/$FORM{'expyr'}\n";
  print MAIL "   Name on card: $FORM{'ccdname'}\n\n";

  print MAIL
    "Reservation deposit (charged to card): \$$FORM{'depositf'}\n\n";

   print MAIL " - $date\n";

  print MAIL "------------------------------------------------------\n";

  close (MAIL);

  return;
} #end mail_hotel


################################################################################
#
#   Name:     sub mail_accounting
#
#   Function: email reservation data to system manager accounting
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
#
#   Outputs:
#
#   Caller:   res_complete                   res_complete.pl
#
#   Calls:
#
#       MODIFICATION                                          DATE        BY
#
#   Harvey's Hotel/Casino                                   02/18/98    M. Lewis
#   Lakeside Inn                                            04/10/98    M. Lewis
#   Lakeside Inn   (add seasonal rates)                     06/13/98    M. Lewis
#   Lakeside Inn   (add weekend cruise processing)          06/14/98    M. Lewis
#   Rodeway Inn                                             09/14/98    M. Lewis
# Automated system revision                                 12/12/99    M. Lewis
# Get rid of century prefixes for arrive/depart year displays07/23/00   M. Lewis
# Add code for subtotal, tax rate and tax amount.           09/13/01    M. Lewis
# Changed "rate per day" to "rate."                         11/11/01    M. Lewis
#
sub mail_accounting {

  my $date =
    `$date_command +"%A, %B %d, %Y at %T (%Z)"`;
  chop($date);

  open (MAIL, "|$mailprog $sys_email, $sales,
               $coldCreek") || die
    "Can't open $mailprog!\n";

  print MAIL
    "Reply-to: $sys_email ($sys_manager)\n";
  print MAIL
   "From: $sys_email ($sys_manager)\n";
  print MAIL
    "Subject: New $hotel_abbrev online room reservation\n\n";
  print MAIL
    "------------------------------------------------------\n";

  print MAIL "To: $sys_manager\n\n";

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

  #Display the dates and room charges (arrays defined in res_complete.pl).
  #
  for ($i = 0; $i < $FORM{'number days'}; $i++) {
     print MAIL
      "$dispDate[$i]: \$$dispAmt[$i] ($dispDayType[$i] ";
    print MAIL
      "$dispWkDay[$i] rate)\n";                                        #11/11/01
  } #end for

  if ($FORM{'have_pets'}) {
    print MAIL
      "\nPet is an additional \$$FORM{'petsAmtf'} ";
    print MAIL "(\$$FORM{'petRatef'} per day).\n";
  } #endif

  if ($FORM{'require_rollaway'}) {
    print MAIL
      "Rollaway bed is an additional \$$FORM{'rollAmtf'} ";
    print MAIL
      "(\$$FORM{'rollawayRatef'} per day).\n";
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

  print MAIL
    "ONLINE RESERVATION NUMBER: $transNum\n\n";
 
  print MAIL " - $date\n";
  print MAIL
    "------------------------------------------------------\n";

  close (MAIL);

  return;
} #end mail_accounting



################################################################################
#
#   Name:     sub mail_customer
#
#   Function: email reservation confirmation data to online customer
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
#
#   Outputs:
#
#   Caller:   res_complete                   res_complete.pl
#
#   Calls:
#
#       MODIFICATION                                          DATE        BY
#
#   Harvey's Hotel/Casino                                   02/18/98    M. Lewis
#   Lakeside Inn                                            04/10/98    M. Lewis
#   Lakeside Inn   (add seasonal rates)                     06/13/98    M. Lewis
#   Lakeside Inn   (add weekend cruise processing)          06/14/98    M. Lewis
#   Rodeway Inn                                             09/14/98    M. Lewis
# Automated system revision                                 12/12/99    M. Lewis
# Get rid of century prefixes for arrive/depart year displays07/23/00   M. Lewis
# Add code for subtotal, tax rate and tax amount.           09/13/01    M. Lewis
# Changed "rate per day" to "rate."                         11/11/01    M. Lewis
#
sub mail_customer {

  my $date = `$date_command +"%A, %B %d, %Y at %T (%Z)"`;
  chop($date);

  open (MAIL, "|$mailprog $FORM{'Email'}") || die "Can't open $mailprog!\n";

  print MAIL
    "Reply-to: $sys_email ($sys_manager)\n";
  print MAIL
    "From: $sys_email ($sys_manager)\n";
  print MAIL
    "Subject: Your online reservation at $hotel_manager ";
  print MAIL "via $sys_manager\n\n";
  print MAIL
    "------------------------------------------------------\n";

  print MAIL
    "Guest Name: $FORM{'firstName'} $FORM{'lastName'}\n";

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
    print MAIL
       "Best time to call: $FORM{'CallTime'}\n";
  }

  if ( $FORM{'Work_Phone'} ){
    print MAIL
      "Work telephone: $FORM{'Work_Phone'}\n";
  }

  if ( $FORM{'Fax_Number'} ){
    print MAIL
      "Fax telephone: $FORM{'Fax_Number'}\n";
  }

  print MAIL
    "Home telephone: $FORM{'Home_Phone'}\n\n";

  print MAIL "No. guests: $FORM{'Person_Cnt'}\n";

  print MAIL
    "Room selected: $FORM{'rmDescription'}\n";

  print MAIL "\n";

  if ($FORM{'have_pets'}) {
    print MAIL
      "Permission to have pets in room requested.\n";
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

  #Display the dates and room charges (arrays defined in res_complete.pl).
  #
  for ($i = 0; $i < $FORM{'number days'}; $i++) {
    print MAIL
      "$dispDate[$i]: \$$dispAmt[$i] ($dispDayType[$i] ";
    print MAIL
      "$dispWkDay[$i] rate)\n";                                        #11/11/01
  } #end for

  if ($FORM{'have_pets'}) {
    print MAIL
      "\nPet is an additional \$$FORM{'petsAmtf'} ";
    print MAIL "(\$$FORM{'petRatef'} per day).\n";
  } #endif

  if ($FORM{'require_rollaway'}) {
    print MAIL
      "Rollaway bed is an additional \$$FORM{'rollAmtf'} ";
    print MAIL
      "(\$$FORM{'rollawayRatef'} per day).\n";
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

   if ( $FORM{'Comments'} ){
    print MAIL "Comments: $FORM{'Comments'}\n\n";
  }

  print MAIL
    "ONLINE RESERVATION NUMBER: $transNum\n\n";

  print MAIL
    "Reservation deposit (charged to credit card): ";
  print MAIL "\$$FORM{'depositf'}\n\n";

  print MAIL " - $date\n";
  print MAIL
    "------------------------------------------------------\n";

  close (MAIL);

  return;
} #end mail_customer


1;

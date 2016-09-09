#!/usr/bin/perl
require('res_lib.pl');
require('open_html_lib.pl');
require('open_email_lib.pl');
require('global_data.pl');

################################################################################
#
#   Name:     hotel_res_complete
#
#   Function: processes hotel-generated reservation completion data
#
#   Inputs:   customer name
#             address1
#             customer company
#             address2
#             city
#             state/province
#             ZIP
#             country
#             customer email address
#             customer phone
#             customer work phone
#             customer fax phone
#             best time to call customer
#             customer comments to hotel
#             credit-card type
#             credit-card No.
#             credit-card expiration month
#             credit-card expiration year
#             name on credit card
#             reservation transaction No.
#
#             The following values are passed through from selections_available:
#               arrive month
#               arrive day
#               arrive year
#               depart month
#               depart day
#               depart year
#               No. guests
#               bed selection
#               pets preference
#       `                                                       pets rate
#                                                               pets amount
#               rollaway request
#                                                               rollaway rate
#                                                               rollaway amount
#               total amount for reservation
#               reservation deposit amount
#               No. reservation days (for any defined seasons/holidays)
#
#   Outputs:  record in the reservation transaction hash
#
#   Caller:   hotel_res_confirm           hotel_res_confirm.pl
#
#   Calls:    hotel_missing_info          open_html_lib.pl
#             check_availability          res_lib.pl
#             modify_state_table          res_lib.pl
#             hotel_mail_hotel            open_email_lib.pl
#             hotel_reservation_complete  open_html_lib.pl
#             room_unavailable            open_html_lib.pl
#
#                     MODIFICATION                           DATE        BY
#
#   Harvey's Hotel/Casino                                  02/14/98   M. Lewis
#   Lakeside Inn     (add call to room_unavailable)        06/24/98   M. Lewis
# Automated system update                                    08/27/00   M. Lewis
# Add changeStrng10 to store comments in resChange record.   09/15/01   M. Lewis
# Modify changeStrng9 to concat field rmDescription vs.      09/19/01   M. Lewis
#  field select_bed to allow for storage of room-description
#  strings in resChange database records.
# Removing email from Chk for completion of required fields. 12/08/01   M. Lewis
#
#Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis

#variables

$name = '';
$value = '';
%FORM = ();
$inMonth = '';
$inDay = '';
$inYear = '';
$statePtr = '';
$mode = 0666;                                    #DBM file mode (doesn't work!)
$transNum = '';
$writeNum = '';
%transLst = '';
$hotelRes = $true;

#begin main processing

print "Content-type: text/html\n\n";

################################################################################

# Get the Date for email confirmations
$date = `$date_command +"%A, %B %d, %Y at %T (%Z)"`;
chop($date);

# Get the input
read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});

# Split the name-value pairs
@pairs = split(/&/, $buffer);

foreach $pair (@pairs) {
   ($name, $value) = split(/=/, $pair);
   # Get rid of HTML CGI encoding
   $name =~ tr/+/ /;
   $value =~ tr/+/ /;
   $name =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
   $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
   $name =~ s/<!--(.|\n)*-->//g;
   $value =~ s/<!--(.|\n)*-->//g;

   $FORM{$name} = $value;                        #Name/value pairs -> hash
} #end while/foreach
################################################################################

#Check for completion of required fields
unless ($FORM{'firstName'} &&
        $FORM{'lastName'} &&
        $FORM{'Address1'} &&
        $FORM{'City'} &&
        $FORM{'State'} ne 'Select State' &&
        $FORM{'Zip'} &&                                                #01/30/02
        $FORM{'Home_Phone'}) {
   &hotel_missing_info;                          #User must complete required
   exit;                                         # fields.  Defined in
}                                                # open_html_lib.pl

#Form a date key for index into the state table
$inMonth = $FORM{arrive_month};
$inDay = $FORM{arrive_day};
$inYear = $FORM{arrive_year};

$stateDate = join '|', $inMonth,$inDay,$inYear;

$totAmt = $FORM{'total amount'};

#Check for room availability & update state table or deny reservation

$statePtr = $FORM{'select_bed'};

dbmopen(%stateTab, $outFileName, $mode);

#check room availability for dates requested
# NOTE: have to keep date strings intact because the database keys are
# concatenated date strings (4/99)
#
#First get the end-of-reservation date to pass to check_availability
#
$outMonth = $FORM{depart_month};
$outDay = $FORM{depart_day};
$outYear = $FORM{depart_year};
($roomAvailable, @dummy) =
  &check_availability($FORM{'number days'},      #Def in res_lib.pl   #12/13/99
                      $inDay, $inMonth, $inYear,
                      $outDay, $outMonth,
                      $outYear, $statePtr,
                      $stateDate);

unless ($roomAvailable) {
  #room unavailable, tell user, then error exit.
  &room_unavailable;                             #Defined in open_
  exit}                                          # html_lib
#end unless

$cancelRes = $false;                             #Not a res cancellation.

&modify_state_table($inDay,                      #Defined in res_lib.pl
                    $FORM{'number days'},
                    $stateDate,
                    $statePtr,
                    $inMonth,
                    $inYear,
                    $cancelRes
                   );

dbmclose(%stateTab);

################################################################################
#Open the transaction-number file to assign a new No. for this reservation
#
open(INFILE, "<$numberFileName")
     or die "Can't open trans_number for read.\n";
while (<INFILE>) {
   $transNum = $_;                                   #Grab input line from file
} #endwhile
close (INFILE);

$transNum =~ s/\n//;                           #Change <newline> to null
$transNum++;                                             #Increment the transaction No.
open(OUTFILE, ">$numberFileName")  or die        #Open file for writing (permis-
                                                 # sions must = 666)
                                     "Can't open trans_number for write.\n";
$writeNum = $transNum . "\n";                    #Add back newline to end line
print OUTFILE $writeNum;                         #Write incremented value back
close (OUTFILE);
#################################################50###########################8

#The following lines add a record to the reservation transaction table.  The
#new record contains data for the reservation just completed above.  This
#data will be needed if the reservation has to be canceled.  The reservation
#can always be referenced by the transaction number just retrieved from the
#trans_num file above
$changeStrng1 = "$statePtr|$FORM{'arrive_day'}|";
$changeStrng2 = "$FORM{'arrive_month'}|$FORM{'arrive_year'}|";
$changeStrng3 = "$FORM{'number days'}|";
#NOTE: strings 4, 5, 6, 7, 8, 9 added for res_cancel email notification
$changeStrng4 = "$FORM{'depart_day'}|";
$changeStrng5 = "$FORM{'depart_month'}|$FORM{'depart_year'}|";
$changeStrng6 = "$FORM{'lastName'}|$FORM{'Address1'}|$FORM{'City'}|";
$changeStrng7 = "$FORM{'State'}|$FORM{'Country'}|$FORM{'Zip'}|";
$changeStrng8 = "$FORM{'Email'}|$FORM{'Home_Phone'}|";
$changeStrng9 = "$FORM{'rmDescription'}|$transNum|$hotelRes|";         #09/19/01
$changeStrng10 = "$FORM{'firstName'}|$FORM{'Comments'}";               #09/19/01

dbmopen(%changeTab, $changeFileName, $mode);

#Bind the reservation data to the transaction number index
#
$changeTab{$transNum} = $changeStrng1.$changeStrng2.$changeStrng3.
                        $changeStrng4.$changeStrng5.$changeStrng6.
                        $changeStrng7.$changeStrng8.$changeStrng9.     #09/15/01
                        $changeStrng10;                                #09/15/01

dbmclose(%changeTab);

#Build arrays for dates, amounts, day-of-week, and season/holiday name for
# display by hotel_reservation_complete and email subroutines.
#
for ($i = 0; $i < $FORM{'number days'}; $i++) {
        #
        #Set up hash indexes to hidden inputs passed from res_confirm.pl
        #
        $date = 'date' . $i;
        $amt = 'amt' . $i;
        $wkDay = 'wkDay' . $i;
        $dayType = 'dayType' . $i;

        #For this date (date[i]), create an ele-
        # ment in each of the four display attri-
        # bute arrays.
        #
        $dispDate[$i] = $FORM{$date};
        #
        $dispDate[$i] = $FORM{$date};
        $dispAmt[$i] = $FORM{$amt};
        $dispWkDay[$i] = $FORM{$wkDay};
        $dispDayType[$i] = $FORM{$dayType};
}#end for

#Hotel staff reservation complete - generate hotel email
&hotel_mail_hotel;                               #Defined in open_email_lib.pl

#Then generate the reservation-complete page.
&hotel_reservation_complete;                     #Defined in open_html_lib.pl

exit;

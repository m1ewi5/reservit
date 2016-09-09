#!/usr/bin/perl
require('res_lib.pl');
require('res_utilities_lib.pl');
require('res_utilities_html_lib.pl');
require('global_data.pl');
require('open_email_lib.pl');
require('open_html_lib.pl');

################################################################################
#
#   Name:     res_cancel
#
#   Function: processes reservation-cancellation request from hotel or system
#             staff.  Also deletes all resState and resChange database records
#             whose date keys are older than today's date.
#
#   Inputs:   date
#             reservation transaction No.
#
#   Outputs:  No. deleted resState.db records
#             dates of deleted resState and resChange records
#             dates affected by the cancelled reservation
#             No. deleted resChange.db records
#             transaction numbers of deleted resChange records
#
#   Caller:   cancel_form               res_utilities_html_lib.pl
#
#   Calls:    resState_delete           res_utilities_lib.pl
#             resChange_delete          res_utilities_lib.pl
#             no_trans_rec              res_utilities_html_lib.pl
#             modify_state_table        res_lib.pl
#             purge_data                res_utilities_html_lib.pl
#             res_cancel_email          open_email_lib.pl
#
#Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis

#variables
$rsDeleted = '';
$rcDeleted = '';
$datesDeleted = '';
$transNumDeleted = '';
$datesCancelled = '';
$found = '';
$cancelRes = $true;                                                        #Used in sub modify_state_table
$buffer = '';
@pairs = '';
$pair = '';
$name = '';
$value = '';
%FORM = ('','');
%transLst = ('','');
@transKeys = '';
$numberTransRecs = '';
$statePtr = '';
$inDay = '';
$inMonth = '';
$inYear = '';
$numDays = '';
@cancelData = '';
$recipient = '';
$to_block = '';
$hotelRes = '';


#constants
$mode = 0666;                                    #DBM file mode (doesn't work!)
$statePath = $securePath . 'resState';
$changePath = $securePath . 'resChange';
$hotelResItem = 18;
$roomType = 0;                                   #Index into roomDef hash

#begin main processing

################################################################################
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

  $FORM{$name} = $value;                                                 #Name/value pairs -> hash
} #end while/foreach

# Get the Date for email confirmations
$date = `$date_command +"%A, %B %d, %Y at %T (%Z)"`;
chop($date);

#################################################50############################8
#
#Get rid of all resState records whose stateDate is < today's date
($datesDeleted, $rsDeleted) = &resState_delete;

#Get rid of all resChange records whose depart-date is < today's date
($transNumDeleted, $rcDeleted) = &resChange_delete;

#################################################50############################8
#
#Update each record in the motel state table database whose key/date corresponds
# to a date in the reservation that is being cancelled.

dbmopen(%transLst, $changePath, $mode)
  or die "Can't open transLst\n";

@transKeys = (keys %transLst);                   #Get all the keys in the table
$numberTransRecs = @transKeys;                   #Get the No. recs in the table

$found = $false;

while ($numberTransRecs > 0) {
  if ($transKeys[$numberTransRecs-1] ==          #Find the table key that
      $FORM{'trans_num'}) {                      # matches the input key
     ($statePtr, $inDay, $inMonth, $inYear,      #Extract the table-record
      $numDays) = split (/\|/,                               # data
        $transLst{$transKeys[$numberTransRecs-1]});

     #NOTE: cancelData and roomRec added for res_cancel email notification
     @cancelData = split (/\|/,
       $transLst{$transKeys[$numberTransRecs-1]});
     @roomRec = split (/\|/,
       $roomDef{$cancelData[$selectBed]});

     #Then delete the record so it won't be used again
     delete $transLst{$transKeys[$numberTransRecs-1]};
     $found = $true;
     $hotelRes = $cancelData[$hotelResItem];
     last;
  } #endif
  $numberTransRecs --;
} #end while

dbmclose(%transLst);

#If no transaction record found, display error and exit
unless ($found) {
  &no_trans_rec($FORM{'trans_num'});             #Defined in
  exit;                                          # res_utilities_html_lib.pl
} #endif

dbmopen(%stateTab, $statePath, $mode)
  or die "Can't open resState\n";
#Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis
$stateDate = join '|', $inMonth,$inDay,$inYear;

#Change database records affected by this cancellation
$datesCancelled = &modify_state_table($inDay,    #Defined in res_lib.pl
                                      $numDays,
                                      $stateDate,
                                      $statePtr,
                                      $inMonth,
                                      $inYear,
                                      $cancelRes
                                     );

$datesCancelled =~ s/\|/ /g;                     #Change | to space

dbmclose(%stateTab);

$cancelRes = $false;

#Display the results of the purge/cancellation
&purge_data($rsDeleted, $datesDeleted,           #Defined in
            $datesCancelled, $rcDeleted,         # res_utilities_html_lib.pl
            $transNumDeleted);

$canceledBy = $passwd{$FORM{'passwd'}};          #Name of person doing cancella-
                                                 # tion

#If cancellation results from a hotel-generated reservation, don't notify sys
# manager
if ($hotelRes) {
  $recipient = $hotel_email;
  $to_block = $hotel_manager;
  &res_cancel_email($canceledBy, $recipient, $to_block)}
else {
   $recipient = "$hotel_email, $sys_email";
   $to_block = "$hotel_manager, $sys_manager";
   &res_cancel_email($canceledBy, $recipient, $to_block)}
#endif

exit;

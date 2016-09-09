#!/usr/bin/perl
require('global_data.pl');
require('res_utilities_html_lib.pl');
require('res_utilities_lib.pl');
use Time::Local;                                                       #08/18/01

################################################################################
#
#   Name:     retrieve_room_or_rates_data
#
#   Function: prepares data for display of No. rooms allocated, No.
#             rooms available for reservation, and No. reservations on
#             any date input by the user.  Does the same for room-rate #12/24/00
#             data.  Gets data from global_data.pl & resState.db files #12/24/00
#
#   Inputs:   start month
#             start day
#             start year
#             end month
#             end day
#             end year
#             hash: global_data.pl room-availability presets or
#                   resState.db records (No. rooms available by room
#                   type)
#
#   Outputs:  month
#             day
#             year
#             array: global_data.pl room-availability presets or
#                    resState.db records (No. rooms available by room
#                    type)
#
#
#   Caller:   room_block_form                res_utilities_html_lib.pl
#             room_rates_form                res_utilities_html_lib.pl #12/24/00
#
#   Calls:    print_rooms_header             res_utilities_html_lib.pl
#             print_rates_header             res_utilities_html_lib.pl
#             print_rooms                    res_utilities_html_lib.pl
#             print_footer                   res_utilities_html_lib.pl
#             invalid_date                   res_utilities_html_lib.pl
#             room_update                    room_update.pl (called
#                                            from display subroutines
#                                            to this routine).
#             time                           Perl function
#             invalid_date_range             res_utilities_html_lib.pl
#             display_rates                  res_utilities_html_lib.pl #12/24/00
#             timelocal                      Standard Perl Library     #08/18/01
#
#                         MODIFICATION                       DATE        BY
#
#   Harvey's Hotel/Casino                                  02/24/98   M. Lewis
#   Lakeside Inn                                           03/17/98   M. Lewis
#   Lakeside Inn   (add selective-date room-block update)  07/18/98   M. Lewis
#   Rodeway Inn    (add processing begin/end date limits)  09/23/98   M. Lewis
# Add numRms array for automated system processing         10/14/00   M. Lewis
# New code to complete new stateTab record creation by add-12/05/00   M. Lewis
#  ing stateStrngs that contain room-rate fields.
# Change dbmopen/dbmclose commands to ensure that the db   12/12/00   M. Lewis
#  files are open for the shortest possible time.
# Create subroutine call to, and move code for, date_      12/19/00   M. Lewis
#  seconds to res_utilities_lib.pl.
# Add code to handle room rates and rename file from room_ 12/24/00   M. Lewis
#  block.pl to retrieve_room_or_rates_data.pl.
# Replace call to date_seconds with call to timelocal.     08/18/01   M. Lewis
# Modify rate-calculation code.                            08/23/01   M. Lewis
# Add code for total No. rates ($totRates).                09/07/01   M. Lewis
# Add code to allow for display of one room type or all room 10/07/01   M. Lewis
#  types.
#
$buffer = '';
@pairs = '';
$name = '';
$value = '';
$startMonth = '';
$startDay = '';
$startYear = '';
$endMonth = '';
$endDay = '';
$endYear = '';
$chkMonth = '';
$chkDay = '';
$chkYear = '';
$checkDate = '';
$startSec = '';
$endSec = '';
$chkSec = '';
@roomValues = '';                                #Was roomConstants    #12/23/00
@rateValues = '';
$tmpStrng = '';
$testRec = '';
$xsec = '';
$xmin = '';
$xhours = '';
$now = '';

$i = '';
$j = 0;                                          #Table row counter
$k = '';                                         #Rate identifier.
$totRates = '';                                  #Passed to print_     #09/07/01
                                                 # footer.             #09/07/01
$q = '';
@roomState = '';
@numRms = '';
$rateIDSeed = '';

@rmKeys = keys(%roomTypes);                      #roomTypes def in     #10/07/01
$numRmTypes = @rmKeys;                           # global_data.pl      #10/05/01
$numRateVals = (3 * $sortedByStartDateSize);     #sortedByStartDateSize#10/17/01
                                                 # def in global_data. #10/17/01
print "Content-Type: text/html\n\n";

@numRms = sort(keys(%roomDef));                  #roomDef hash defined #10/14/00
                                                 # in global_data.pl   #10/14/00
$numRms = @numRms;                               #No. items in array   #10/15/00

# Get the input
read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});

# Split the name-value pairs
@pairs = split(/&/, $buffer);

foreach $pair (@pairs) {
   ($name, $value) = split(/=/, $pair);
#print "input pair is $name, $value\n";
   # Get rid of HTML CGI encoding
   $name =~ tr/+/ /;
   $value =~ tr/+/ /;
   $name =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
   $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
   $name =~ s/<!--(.|\n)*-->//g;
   $value =~ s/<!--(.|\n)*-->//g;

   if ($allow_html != 1) {
      $name =~ s/<([^>]|\n)*>//g;
      $value =~ s/<([^>]|\n)*>//g;
   } #endif

   $FORM{$name} = $value;                        #Name/value pairs -> hash
} #end while/foreach

$startMonth = $FORM{'startMonth'};
$startDay = $FORM{'startDay'};
$startYear = $FORM{'startYear'};
$endMonth = $FORM{'endMonth'};
$endDay = $FORM{'endDay'};
$endYear = $FORM{'endYear'};

if (($startMonth =~ /Start/) ||                  #User didn't complete date
    ($startDay =~ /Start/) ||                    # entries
    ($startYear =~ /Start/) ||
    ($endMonth =~ /End/) ||
    ($endDay =~ /End/) ||
    ($endYear =~ /End/)) {
   &invalid_date;
   exit}
#endif


#Get current date in seconds since 1/1/70
$now = time;

#Get start month as int 0-11
$startMonth = ($ordMonth{$startMonth} - 1);

#Get end month as int 0-11
$endMonth = ($ordMonth{$endMonth} - 1);

#Get start and end dates in form of seconds since 1/1/70               #12/19/00
#                                                                      #12/19/00
$startSec = timelocal(0, 0, 0, $startDay,                              #08/18/01
                      $startMonth, $startYear);                        #08/18/01
$endSec = timelocal(0, 0, 0, $endDay,                                  #08/18/01
                      $endMonth, $endYear);                            #08/18/01

if (($startSec < ($now - $oneDay)) ||            #Dates must be between
    ($endSec > ($now + $oneYear))){              # now and one year
   &invalid_date_range;                          # from now.
   exit}
#endif

if ($startSec > $endSec) {                       #End day earlier than
   &invalid_date;                                # begin day.
   exit}
#endif

#Form an initial date key for index into the state table (month must be
# in string form).
#
$checkDate = join '|', $FORM{'startMonth'},
  $startDay, $startYear;
$chkMonth = $startMonth + 1;                     #Need integer month 1 - 12
$chkDay = $startDay;
$chkYear = $startYear;

$chkSec = $startSec;                             #Initialize loop control

#Get a database or a global_data preset record for each date in the begin/
# end range.  NOTE: $endSec will always be >= $startSec (these two variables
# are never changed) unless the user entered an invalid date range to begin
# with (in which case the loop will fail on the first check).
#
while (($chkSec <= $endSec) && ($startSec <= $endSec)){

   if ($chkSec == $startSec) {                   #If this is the first #12/20/00
      if ($FORM{'caller'} eq 'rooms') {          # time through, print #12/20/00
         &print_rooms_header}                    # a header.           #12/20/00
      else {                                                           #12/20/00
         &print_rates_header($FORM{'select_bed'})}                     #10/07/01
      #endif                                                           #12/20/00
   }#endif                                                             #12/20/00

   #Open resState.db and display data from records in the file that fall within
   # the start/end dates supplied by user.
   #
   dbmopen(%stateTab, $outFileName, $mode);

   unless (defined $stateTab{$checkDate}) {      #If no record for
      # this date, build new stateTab record from scratch.             #08/20/01
      for ($q = 0; $q < $numStateStrngs;         #$stateStrngs &       #12/24/00
           $q++) {                               # $numStateStrngs de- #12/24/00
                                                 # fined in global_data#12/24/00
         $tmpStrng = 'stateStrng' . $q;          #Create symbolic ref  #12/24/00
                                                 # to $stateStrngq     #12/24/00
         $testRec .= $$tmpStrng;                 #Dereference it & add #12/24/00
                                                 # to rec.             #12/24/00
      } #end for $q = 0                                                #12/24/00
      #Add the new record to the resState.db file                      #12/24/00
      #                                                                #12/24/00
      $stateTab{$checkDate} = $testRec;                                #08/20/01
      dbmclose(%stateTab);                                             #12/24/00
      #split the hash state values into a local table for examination  #01/20/01
      @roomState = split (/\|/, $testRec);                             #08/21/01
      $testRec = '';                             #Clear temp for next. #08/20/01
   }
   else { #DB record for this date exists, don't update the database.
      #split the hash state values into a local table for examination  #01/20/01
      @roomState = split (/\|/, $stateTab{$checkDate});                #01/20/01
      dbmclose(%stateTab);                                             #01/20/01
   } #end unless                                                       #08/20/01
   $roomState = @roomState;                      #Get array length.    #08/21/01

   if ($FORM{'caller'} eq 'rooms') {                                   #04/22/01
     #Copy the No.-rooms values in roomState into a separate array
     #
     for ($i = 0; $i < ($numRms * 3); $i++) {                          #10/15/00
       $roomValues[$i] = $roomState[$i]}                               #10/15/00
     #end for                                                          #10/15/00

     &print_rooms($j, $chkMonth, $chkDay,        #Print the values     #10/15/00
                  $chkYear, @roomValues);        # for this date.      #10/15/00
     @roomValues = '';                                                 #12/24/00
   }                                                                   #08/21/01
   else { #caller is 'rates'                                           #12/24/00
     $k = 0;
     #                                                                 #10/18/01
     $firstRate = (($numStateStrngs / 2) * 3); #display_rates param.   #10/18/01
     #NOTE: $numStateStrngs is defined in global_data.pl.  As used     #10/18/01
     # here, it points to the first rate value in a resState database  #10/18/01
     # record.                                                         #10/18/01
     #                                                                 #10/18/01
     #Display rates for all room-types.                                #10/07/01
     #                                                                 #10/07/01
     for ($i = $firstRate; $i < $roomState;                            #08/23/01
          $i++) {                                                      #12/24/00
       $rateValues[$k] = $roomState[$i];                               #08/23/01
       $k++;                                     #Increment rate ID.   #08/23/01
     } #end for                                                        #10/15/00
     $rateIDSeed = ($j * $k);                                          #09/04/01
     &display_rates($j, $rateIDSeed, $chkMonth,  #Print the values     #09/04/01
                    $chkDay, $chkYear,           # for this date.      #10/15/00
                    $FORM{'select_bed'},                               #10/06/01
                    $firstRate,                                        #10/11/01
                    @rateValues);                                      #09/04/01
     @rateValues = '';                                                 #12/24/00
   } #endif                                                            #12/24/00

   $j++;                                         #Increment row counter

   #Set up the next day for the next loop-control test by
   # incrementing the date by one day's worth of seconds
   #
   $chkSec += $oneDay;

   #Get the numeric values for this new date
   #
   ($xsec, $xmin, $xhours, $chkDay, $chkMonth, $chkYear) =
      localtime($chkSec);

   if ($chkYear >= 100) {                                              #12/05/00
     $chkYear -= 100;                                                  #12/05/00
     if ($chkYear < 10) {                                              #12/05/00
       $chkYear = '0' . $chkYear}                                      #12/05/00
     #endif                                                            #12/05/00
   } #endif                                                            #12/05/00

   $chkMonth ++;                                 #Integer month 1- 12

   #Convert month from int 1-12 to string
   #
   #Form the date key for index into the next state-table record
   #
   $checkDate = join '|', $monthNum{$chkMonth}, $chkDay, $chkYear;

} #end while (master loop)

#Build the footer unless the header was never built in the first place (hap-
# pens only if user entered an invalid date range).  After building the footer,
# write the whole output file to display ($j is passed because room_
# update.pl and rates_update.pl need to know how many data rows were   #11/01/01
# displayed by #12/30/00 sub print_rooms or sub display_rates).        #12/30/00
#
unless ($chkSec == $startSec) {
  if ($FORM{'caller'} eq 'rooms') {                                    #12/30/00
    &print_footer($j, 'room', 0)}                                      #09/07/01
  else {                                                               #12/30/00
    $totRates = ($j * $k);                       $No.-rows * No.-rates-#09/07/01
    &print_footer($j, 'rate', $totRates)}        # per-row.            #09/07/01
  #endif                                                               #12/30/00
} #end unless

exit;

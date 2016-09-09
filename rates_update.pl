#!/usr/bin/perl
require('global_data.pl');
require('res_utilities_html_lib.pl');
require('res_utilities_lib.pl');

################################################################################
#
#   Name:     rates_update
#
#   Function: Rewrites resState records with user-updated rates.
#
#   Inputs:   Room rates values.
#             resState.db records.
#
#   Outputs:  resState.db records
#
#   Caller:   print_rates_header             res_utilities_html_lib.pl
#
#   Calls:    post_update_rates_header       res_utilities_html_lib.pl
#             post_update_footer             res_utilities_html_lib.pl
#             post_update_rates              res_utilities_html_lib.pl
#             format_date                    res_utilities_lib.pl
#             check_rate                     rates_update.pl            #10/29/01
#
#                        MODIFICATION                          DATE        BY
#
#                                                            08/24/01   M. Lewis
# Add code to allow for rates update of one room type or all 10/09/01   M. Lewis
#  room types.
# Fixed two bugs in database update processing.  Had to move 10/26/01   M. Lewis
#  dbmopen and dbmclose calls because dbupdate was being
#  written incorrectly.
# Create checks for room-type (allRooms) or one rm-type key. 10/29/01   M. Lewis
# check_rate isn't being called.                             11/11/01   M. Lewis
# Room-rate data items are  being written into resState in   11/12/01   M. Lewis
#  the wrong order when the display mode is "all room types."
# check_rate is called for only one roomtype even if there   11/13/01   M. Lewis
#  is more than one roomtype.
#
#variables
$buffer = '';
@pairs = '';
$name = '';
$value = '';
%FORM = ();
$mode = 0666;                                    #DBM file mode (doesn't work!)
$numRows = '';
%stateTab = ();
$i = 0;
$j = 0;
$k = '';
$m = '';                                                               #10/09/01
$n = '';                                                               #11/11/01
$dateKey = '';
$dateMonth = '';
@stateTmp = '';
$stateTmpSiz = '';
$printMonth = '';
$printDay = '';
$printYear = '';
$dateStrng = '';
$firstRate = '';
$numRates = '';
$totRates = '';
$dispRms  = '';                                                        #10/08/01
$ratesPerRow = '';                                                     #10/26/01

print "Content-Type: text/html\n\n";

#keys(%roomTypes) returns the keys in the order in which their data    #11/13/01
# values are stored in the resState database.                          #11/13/01
#                                                                      #11/13/01
@rmKeys = keys(%roomTypes);                      #roomTypes def in     #10/07/01
                                                 # global_data.pl.     #10/07/01
$numRmTypes = @rmKeys;                                                 #11/01/01

$numRateVals =                                                         #11/13/01
  (3 * $numRmTypes * $sortedByStartDateSize);    #sortedByStartDateSize#11/13/01
                                                 # def in global_data. #11/13/01
@rateStrngs = ('WkDayRate', 'FriRate', 'SatRate');                     #10/27/01

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

   if ($allow_html != 1) {
      $name =~ s/<([^>]|\n)*>//g;
      $value =~ s/<([^>]|\n)*>//g;
   } #endif
   $FORM{$name} = $value;                        #Name/value pairs -> hash
   #print "<P>$name  = '$value'</P>";
} #end while/foreach

$numRows = $FORM{'numRows'};                     #No. data rows dis-
                                                 # played by caller.
$totRates = $FORM{'totRates'};                   #No. rates for display#09/07/01
                                                 # and db write.       #09/07/01
#Check rate entries for proper format.                                 #10/31/01
#                                                                      #10/31/01
$n = 0;                                          #Init rates counter.  #11/11/01
for ($j = 0; $j < $numRows; $j++) {                                    #10/26/01
  #Format day, month, and year for printing (input param for check_    #10/31/01
  # rate).                                                             #10/31/01
  #
  ($printMonth, $printDay, $printYear) =                               #09/07/01
    &format_date($FORM{'month' . $j},                                  #09/07/01
                 $FORM{'day' . $j},                                    #09/07/01
                 $FORM{'year' . $j});                                  #09/07/01
  $dateStrng = $printMonth . ' ' . $printDay .                         #09/07/01
               ', 20' . $printYear;                                    #09/07/01
  #                                                                    #11/11/01
  #Check rate entries for proper format.                               #11/11/01
  #                                                                    #11/11/01
  for ($m = $n; $m < ($n + $numRateVals); $m++) {                      #11/11/01
    if (exists ($FORM{'rate' . $m})) {
    $FORM{'rate' . $m} =                                               #09/07/01
      &check_rate($FORM{'rate' . $m}, $dateStrng)}                     #09/07/01
    #endif                                                             #10/31/01
  } #end for                                                           #11/11/01
  #                                                                    #11/11/01
  #Adjust n to point to start of next "row" of rate values.            #11/11/01
  $n += ($numRateVals * $numRmTypes);                                  #11/11/01
} #end for                                                             #10/31/01

#Updated rates have been formatted properly.  Now to update the data-  #10/31/01
# base.                                                                #10/31/01
#                                                                      #10/31/01
#How many room-types are we dealing with?  All or one?  We need this   #10/31/01
# info to figure the No. of rates that go into one database record,    #10/31/01
# i.e., one row.                                                       #10/31/01
#
if ($FORM{'dispRms'} eq 'allRooms') {                                  #10/29/01k
  $ratesPerRow = ($totRates / $numRows)}                               #10/26/01
else { #Get the No. of rates/row contributed by one room-type.         #10/29/01
  $ratesPerRow = (($totRates / $numRows) / $numRmTypes);               #10/29/01
} #endif                                                               #10/29/01

#Find the position (startRate) in the resState record that contains    #10/29/01
# the first rate for the room-type whose rates we want to store.       #10/29/01
#
#First,find the position (n) of the room-type key in the table of keys.#10/29/01
# The position corresponds to the section of the resState record that  #10/29/01
# contains the rates for this room-type.                               #10/29/01
#
for ($n = 0; $n < ($numRmTypes); $n++) {
  if ($rmKeys[$n] =~ /$FORM{'dispRms'}/) {                             #11/13/01
    last}
  #endif
} #end for
#
#Second, use n to compute the position, in the resState record,  for   #11/13/01
# the starting rate.  This block's code repeats for each input row     #11/13/01
# (i.e., each date whose rates are to be written back to the database. #11/13/01
#
$k = 0;                                                                #10/26/01
for ($j = 0; $j < $numRows; $j++) {                                    #10/26/01
  $startRate =                                                         #10/31/01
    (($j * ($numRmTypes * $ratesPerRow)) +                             #10/31/01
     ($n *  $ratesPerRow));                                            #10/31/01
  #                                                                    #10/31/01
  #This block constructs a hash whose structure is the same as the res-
  # State table, i.e.:
  #
  #         key = string of form MM|DD|YY
  #         item value of form nnn|nnn|nnn|...|nnn
  #
  #   where each nnn corresponds to a value defined by the $stateStrng
  #   variables in global_data.pl.  The values used to populate the
  #   hash are the room-data values displayed by room_block.pl sub-
  #   routines.  Each hash record created here will either replace the
  #   corresponding record in resState or will be written to resState
  #   as a new record.
  #
  #First, form a date key
  #
  #NOTE: $j is a unique row designator in the display table generated
  #      by the retrieve_room_or_rates_data.pl subroutines.
  #
  $dateMonth = $monthNum{$FORM{'month'.$j}};     #Convert date from
  $dateKey = join '|', $dateMonth,               # num to string.
                       $FORM{'day'.$j},
                       $FORM{'year'.$j};
  #
  #Open resState.db and update all the records in the file whose date  #10/26/01
  # keys match date keys processed by retrieve_room_or_rates_data.pl.  #10/26/01
  # If a record for a particular date key doesn't exist, create it.    #10/26/01
  #                                                                    #10/26/01
  #Each database record looks like:
  #
  # #res0 #avail0 #alloc0  #res1 #avail1 #alloc1 ... #res(n-1) #avail(n-1) ->
  #   #alloc(n-1)  rate00 rate01 rate02  rate10 rate11 rate12 ... ->
  #   rate(i-1)0  rate(i-1)1  rate(i-1)2
  #
  # where n = No. of room types in this res system
  #       i = No. of seasons/holidays in this res system
  #
  #In the following block, one database record's rates are rewritten:
  # i counts No. of seasons/holiday rates in a database record, start-
  # ing at the first rate value in the record.
  #
  if ($FORM{'dispRms'} eq 'allRooms') {                                #10/11/01
    #                                                                  #10/18/01
    $firstRate = (($numStateStrngs / 2) * 3); #display_rates param.    #10/18/01
    #                                                                  #11/01/01
    #NOTE: $numStateStrngs is defined in global_data.pl.  As used      #10/18/01
    # here, it points to the first rate value in a resState database   #10/18/01
    # record.                                                          #10/18/01
    #                                                                  #10/18/01
    #Display rates for all room-types.                                 #10/07/01
    #                                                                  #10/07/01
    dbmopen(%stateTab, $outFileName, $mode);                           #10/30/01
    @stateTmp = split (/\|/,                     #Copy stateTab record #10/30/01
                       $stateTab{$dateKey});     # to temp.            #10/30/01
    $stateTmpSiz = @stateTmp;                                          #10/30/01
    #                                                                  #11/12/01
    # Have to duplicate (more or less) here the code for indexing res- #11/12/01
    # State for a single roomtype below.  The data items were being    #11/12/01
    # written into resState in the wrong order when the display mode   #11/12/01
    # was "all room types."  But the principle is the same for one room#11/12/01
    # type or all room types.  This fix does nothing to solve the lar- #11/12/01
    # ger problem of the display being way too big when you have say   #11/12/01
    # four roomtypes and 15 seasons/holidays and you're trying to dis- #11/12/01
    # play 30 rows.  Then, the number of data items is 4 * 3 * 15 * 30 #11/12/01
    # = 5400.  Even with only one roomtype to display, the same situa- #11/12/01
    # tion yields 1350 displayed values.                               #11/12/01
    #                                                                  #11/12/01
    $w = ($j * $numRmTypes * $ratesPerRow);                            #11/01/01
    foreach $key(@rmKeys) {                                            #11/12/01
      #                                                                #11/12/01
      #Now use the "keys" in global_data.pl to store the items within
      # the rec to the order in which they existed when the rec was
      # created from stateStrng templates.  This process is the in-
      # verse of the ordering process done on the data items in sub
      # display_rates.
      #                                                                #11/01/01
      #     where j is the current row No.                             #11/01/01
      #                                                                #11/01/01
      #NOTE: w points to the first data item in the group of items for #11/01/01
      # a single roomtype.  These items are passed to rates_update as  #11/01/01
      # html hidden-input data types.  They were displayed to (and pos-#11/01/01
      # sibly modified by) the user in the screen set up by sub dis-   #11/01/01
      # play_rates (res_utilities_html_lib.pl).                        #11/01/01
      #                                                                #11/01/01
      for ($v = 0; $v < $sortedByStartDateSize;                        #10/27/01
           $v++) {                                                     #10/27/01
        #                                                              #11/12/01
        #Each "key" is concatinated from four parts, e.g.              #11/12/01
        #                                                              #11/12/01
        #            QNS00010 Summer FriRate w                         #11/12/01
        #                                                              #11/12/01
        #    where QNS00010 is a room-type key                         #11/12/01
        #          Summer   is a season/holiday                        #11/12/01
        #          FriRate  comes from array rateStrngs                #11/12/01
        #          w        is a sequential integer from 0 - No.       #11/12/01
        #                     values to be displayed                   #11/12/01
        #                                                              #11/12/01
        $fieldPtr =                                                    #10/27/01
          $key . $sortedByStartDate[$v][2];                            #11/12/01
        $fieldHold = $fieldPtr;                                        #10/27/01
        for ($i = 0; $i < 3; $i++) {                                   #10/27/01
          # (Append "WkDayRate," "FriRate," "SatRate" to template.)    #11/01/01
          #                                                            #11/01/01
          $fieldPtr .= $rateStrngs[$i];                                #10/27/01
          #                                                            #10/31/01
          #Dereference fieldPtr & use its value as an index into the   #10/31/01
          # resState rec.  The data item in FORM{rate.$i} should be    #10/31/01
          # written to the loc in the database rec (stateTmp) that cor-#10/31/01
          # responds to the index found with fieldPtr.                 #10/31/01
          #                                                            #10/27/01
          $ptrVal = $$fieldPtr;                                        #10/31/01
          $stateTmp[$ptrVal] = $FORM{'rate' . $w};                     #10/31/01
          $fieldPtr = $fieldHold;                                      #10/27/01
          $w++;                                                        #11/01/01
        } #end for                                                     #10/27/01
      } #end foreach                                                   #10/27/01
    } #end for                                                         #11/12/01
    $stateTab{$dateKey} = join '|', @stateTmp;                         #10/26/01
    dbmclose(%stateTab);                                               #10/26/01
    @stateTmp = '';                                                    #10/26/01
  }                                                                    #10/07/01
  else { #store rates for one room-type only.                          #10/07/01
    #                                                                  #11/01/01
    $firstRate = ((($numStateStrngs / 2) * 3)  +                       #10/18/01
                  $startRate);                                         #10/30/01
    #                                                                  #11/01/01
    #NOTE: $numStateStrngs is defined in global_data.pl.  As used      #10/18/01
    # above, it points to the first rate value in a resState database  #10/18/01
    # record.                                                          #10/18/01
    #                                                                  #10/18/01
    dbmopen(%stateTab, $outFileName, $mode);                           #10/30/01
    @stateTmp = split (/\|/,                     #Copy stateTab record #10/30/01
                       $stateTab{$dateKey});     # to temp.            #10/30/01

    #Now use the "keys" in global_data.pl to store the items within
    # the rec to the order in which they existed when the rec was
    # created from stateStrng templates.  This process is the in-
    # verse of the ordering process done on the data items in sub
    # display_rates.
    #
    $w = ($j * $numRmTypes * $ratesPerRow);                            #11/01/01
    #                                                                  #11/01/01
    #     where j is the current row No.                               #11/01/01
    #                                                                  #11/01/01
    #NOTE: w points to the first data item in the group of items for a #11/01/01
    # single roomtype.  These items are passed to rates_update as html #11/01/01
    # hidden-input data types.  They were displayed to (and possibly   #11/01/01
    # modified by) the user in the screen set up by sub display_rates  #11/01/01
    # (in res_utilities_html_lib.pl.                                   #11/01/01
    #                                                                  #11/01/01
    for ($v = 0; $v < $sortedByStartDateSize;                          #10/27/01
         $v++) {                                                       #10/27/01
      #                                                                #11/12/01
      #Each "key" is concatinated from four parts, e.g.                #11/12/01
      #                                                                #11/12/01
      #            QNS00010 Summer FriRate w                           #11/12/01
      #                                                                #11/12/01
      #    where QNS00010 is a room-type key                           #11/12/01
      #          Summer   is a season/holiday                          #11/12/01
      #          FriRate  comes from array rateStrngs                  #11/12/01
      #          w        is a sequential integer from 0 - No.         #11/12/01
      #                     values to be displayed                     #11/12/01
      #                                                                #11/12/01
      $fieldPtr =                                                      #10/27/01
        $FORM{'dispRms'} . $sortedByStartDate[$v][2];                  #10/27/01
      $fieldHold = $fieldPtr;                                          #10/27/01
      for ($i = 0; $i < 3; $i++) {                                     #10/27/01
        # (Append "WkDayRate," "FriRate," "SatRate" to template.)      #11/01/01
        #                                                              #11/01/01
        $fieldPtr .= $rateStrngs[$i];                                  #10/27/01
        #                                                              #10/31/01
        #Dereference fieldPtr & use its value as an index into the     #10/31/01
        # resState rec.  The data item in FORM{rate.$i} should be      #10/31/01
        # written to the loc in the database rec (stateTmp) that cor-  #10/31/01
        # responds to the index found with fieldPtr.                   #10/31/01
        #                                                              #10/27/01
        $ptrVal = $$fieldPtr;                                          #10/31/01
        $stateTmp[$ptrVal] = $FORM{'rate' . $w};                       #10/31/01
        $fieldPtr = $fieldHold;                                        #10/27/01
        $w++;                                                          #11/01/01
      } #end for                                                       #10/27/01
    } #end for                                                         #10/27/01

    $stateTab{$dateKey} = join '|', @stateTmp;                         #10/26/01

    dbmclose(%stateTab);                                               #10/26/01
    @stateTmp = '';                                                    #10/26/01
  } #endif                                                             #10/07/01
} #end for

#Finished updating DBM, now call the display routines.                 #10/31/01
#First, display the post-update page header                            #10/31/01
#                                                                      #10/31/01
&post_update_rates_header($FORM{'dispRms'});                           #10/31/01
#                                                                      #10/31/01
#Then display the updated rates.                                       #10/31/01
#                                                                      #10/31/01
&post_update_rates($FORM{'dispRms'}, $numRows,   #Print the data rows. #11/01/01
                   $ratesPerRow, $numRmTypes);                         #11/01/01
&post_update_footer;                             #Display footer

exit;


################################################################################
#
#   Name:     check_rate
#
#   Function: Checks format of one rate entry, calls error if invalid
#
#   Inputs:   date string (mmm dd, yy)
#             rate (ddd.cc or abbreviation)
#
#   Outputs:  verified rate or error
#
#   Caller:   main                           rates_update.pl
#             post_update_rates              res_utilities_html_lib.pl
#
#   Calls:    invalid_rate_entry             define_html_lib.pl
#             no_rate_entry                  define_html_lib.pl
#
#               MODIFICATION                                 DATE         BY
#
#                                                          09/07/01     M. Lewis
#
sub check_rate {

  my $rate = shift(@_);
  my $date = shift(@_);

  if ($rate eq '') {                              #If no entry, error
    &no_rate_entry($date)}                        # exit
    #
    #Required format is zero to three digits followed by . followed by two dig-
    # its.  But user can enter the digits for the dollar amt only and the soft-
    # ware will fill in the rest (i.e., ".00").
    #
  else {
    unless ($rate =~ /^\d{1,3}$/) {
      if ($rate !~ /^[ |\d]{1,3}\.\d{2}$/) {
        &invalid_rate_entry($rate, $date)}
      else {}
      #endif
    }
    else {
      $rate .= '.00'}
    #end unless
  } #endif

  return ($rate);

} #end check_rate

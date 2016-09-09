#!/usr/bin/perl
use Time::Local;

##HOOK: BEGIN DEFINE PUBLIC_HTML PATHS                                 #12/14/99
require('/home/groups/r/re/reservit/cgi-bin/global_data.pl');
##HOOK: END DEFINE PUBLIC_HTML PATHS                                   #12/14/99


################################################################################
#
#   Name:     modify_state_table
#
#   Function: adjusts the available-reservations and available-rooms values in
#             the state-table item for a requested room on a requested date
#
#   Inputs:   arrive day
#             No. days in reservation request
#             date key (MMMDDYY) for room-state hash
#             item index (room-type identifier) into room-state table #12/10/99
#             arrive month
#             arrive year
#             cancel-reservation flag
#
#   Outputs:  string of cancelled reservation dates (only if cancel flag set)
#
#   Caller:   res_complete              res_complete.pl
#             hotel_res_complete        hotel_res_complete.pl
#             res_cancel                res_cancel.pl
#
#   Calls:    format_display_year       res_lib.pl
#             timelocal                 Perl std library (PP p. 515)   #12/13/99
#
#                       MODIFICATION                          DATE         BY
#
#   Lakeside Inn (add selective-date room-block update)     07/09/98    M. Lewis
#   Rodeway Inn                                             09/14/98    M. Lewis
# auto system update                                        09/21/99    M. Lewis
# additional auto sys changes   (get rid of stateTabKey)    12/10/99    M. Lewis
# Add code to make date seconds work                        12/13/99    M. Lewis
# Add hook for write_res_lib.pl                             12/14/99    M. Lewis
# Add 'idx' strngs to creation of res & avail index ptrs.   08/13/01    M. Lewis
sub modify_state_table {

  my $inDay     = shift(@_);
  my $numDays   = shift(@_);
  my $stateDate = shift(@_);
  my $statePtr  = shift(@_);
  my $inMonth   = shift(@_);
  my $inYear    = shift(@_);
  my $cancelRes = shift(@_);

  my $datesCancelled = '';
  my $dateSec = '';
  my $ptr = '';
  my $resIndx = '';
  my $availIndx = '';

  $arriveMnth = ($ordMonth{$inMonth} - 1);       #Month as int 0-11    #12/13/99
  $dateSec = timelocal(0, 0, 0, $inDay,                                #12/13/99
                       $arriveMnth, $inYear);                          #12/13/99

  for ($i = 0; $i < $numDays; $i++) {

    #Modify the stateTab record for the current input date.
    if (defined $stateTab{$stateDate}) {         #if res is being cancelled,
                                                 # rec may not exist
      #split the hash state values into a local table for examination
      my @roomState = split (/\|/, $stateTab{$stateDate});

      $ptr = 'res' . $statePtr . 'idx';                                #08/13/01
      $resIndx = $$ptr;                                                #12/13/99
      $ptr = 'avail' . $statePtr . 'idx';                              #08/13/01
      $availIndx = $$ptr;                                              #12/13/99
      if ($cancelRes) {                          #If res is being cancelled,
        $roomState[$resIndx]--;                  # autodecrement the   #12/10/99
                                                 # No.-res-value,      #12/10/99
        $roomState[$availIndx]++;                # autoincrement the   #12/10/99
        $datesCancelled .= "$stateDate<br>";     #Compile dates for return.
      }
      else {                                     #This is a new reservation, so
         $roomState[$resIndx]++;                 # autoincrement the   #12/10/99
                                                 # No.-res value,      #12/10/99
         $roomState[$availIndx]--;               # autodecrement the   #12/10/99
      } #endif                                   # No.-rms-avail val.  #12/10/99

      #now write the modified record back to stateTab
      $stateTab{$stateDate} = join ('|', @roomState);
   } #endif

     #increment the stateDate variable by one day
     $dateSec += $oneDay;                        #Next day in sec since 1/1/70

     ($inDay, $inMonth, $inYear, $centuryPrefix) =
      &date_strings($dateSec);
     $stateDate = join '|',$inMonth, $inDay, $inYear;
  } #endfor

  if ($cancelRes) {                              #If res is being cancelled,
    return($datesCancelled)}                     # return string of dates
  else {                                         # whose records were changed
    return()}
  #endif

} #end modify_state_table


################################################################################
#
#   Name:     check_availability
#
#   Function: examines room state-table for room availability on dates that
#             are input to it.
#
#   Inputs:   No. days requested for reservation
#             arrive day
#             arrive month
#             arrive year
#             depart day
#             depart month
#             depart year
#             room-state table key
#             date in form MMMDDYY
#
#   Outputs:  room-available/unavailable flag
#             @dateRates array
#
#   Caller:   res_main                 res_main.pl
#             res_complete             res_complete.pl
#             hotel_res_complete       hotel_res_complete.pl
#
#   Calls:    date_strings                 res_lib.pl
#
#                      MODIFICATION                           DATE         BY
#
#   Lakeside Inn                                            03/12/98    M. Lewis
#   Lakeside Inn (move digression code to sub check_fields) 06/27/98    M. Lewis
#   Lakeside Inn (add selective-date room-block update)     07/09/98    M. Lewis
#   Rodeway Inn                                             09/14/98    M. Lewis
# autosys rewrite                                           09/09/99    M. Lewis
# Add season/holiday ref to get user-defined display tag    11/09/99    M. Lewis
# Remove call to check_fields -- needs rewrite              12/13/99    M. Lewis
# Change ' delimiter to " in season/holiday name string     05/31/00    M. Lewis
# Delete call to format_display_year, add fixed cent. prefix07/24/00    M. Lewis
# Add 'idx' substring to room-availability index creation.  12/12/00    M. Lewis
# Clear temp before building next resState rec.             08/11/01    M. Lewis
# Pass strtDateSec/endDateSec from res_main rather than re- 10/23/01    M. Lewis
#  calc them here as was done previously.
#
sub check_availability {

  my $numDays  = shift(@_);
  my $inDay    = shift(@_);
  my $inMonth  = shift(@_);
  my $inYear   = shift(@_);
  my $outDay    = shift(@_);
  my $outMonth  = shift(@_);
  my $outYear   = shift(@_);
  my $statePtr = shift(@_);
  my $stateDate = shift(@_);
  my $strtDateSec = shift(@_);                                         #10/23/01
  my $endDateSec = shift(@_);                                          #10/23/01
  my @roomTmp = '';
  my $mnthTmp = '';
  my $dayOfWeek = '';
  my $resDefOffset = '';
  my $resStateRec = '';
  my $tmpStrng = '';
  my $availableRms = '';
  my $dateIndx = '';
  my $found = '';
  my $thisDay = '';
  my $sortedIdex = '';
  my $indxTmp;

  my %dayOfWkDescriptor = (
                           'WkDay' => 'weekday (Sun-Thurs)',
                           'Fri'   => 'Friday',
                           'Sat'   => 'Saturday',
                          );
  my $roomAvailable = $true;

#print "Content-Type: text/html\n\n";

  $inYear = '20' . $inYear;                      #Add century prefix.  #10/23/01

  for ($i = 0; $i < $numDays; $i++) {
    #If a stateTab record for input date exists, use it, else create a new
    # one.
    #
    unless (defined $stateTab{$stateDate}) {
      for ($j = 0; $j < $numStateStrngs; $j++) { #$stateStrngs &
                                                 # $numStateStrngs defined in
                                                 # global_data
        $tmpStrng = 'stateStrng' . $j;           #Create symbolic reference to
                                                 # $stateStrngj
        $resStateRec .= $$tmpStrng;              #Dereference it & add to rec
      } #end for
      $stateTab{$stateDate} = $resStateRec;
      $resStateRec = '';                         #Clear temp before    #08/11/01
    } #end unless                                # building next rec.  #08/11/01

    #split the hash state values into a local table for examination
    #
    my @roomState = split (/\|/, $stateTab{$stateDate});
    #Check for existence of field & update roomState if field doesn't exist.
    #We're checking for an available reservation slot, so we need to form
    # an index to the rooms-available field of roomState -- hence
    # avail . $statePtr (an example index would be 'availKNS00010').
    #
    $tmpStrng = 'avail' . $statePtr . 'idx';                           #12/12/00
    $availableRms = $$tmpStrng;
#
#    Have to check functionality of check_fields 5/8/00
#
#    @roomState = &check_fields($availableRms, @roomState);
#
    unless ($roomState[$availableRms] > 0) {                           #12/13/99
      $stateTab{$stateDate} = join('|', @roomState);
      $roomAvailable = $false;                   #Can't reserve for these dates
      last;
    } #end unless

    #Now get the day of the week as a string: WkDay, Fri, or Sat --
    # see PP p. 185.
    #
    $dayOfWeek =
      ('WkDay', 'WkDay', 'WkDay', 'WkDay',
       'WkDay', 'Fri', 'Sat')
      [(localtime($strtDateSec))[6]];

    #Get an index into %sortDate so we can figure out what kind of date this
    # is.  Find the index to the item in the sorted-ascending date-range
    # table that contains the date for a given reservation day.
    #
    $found = $false;
    for ($thisDay = 1;
      $thisDay <= $numDays; $thisDay++) {
      for ($sortedIdex = 0;
           $sortedIdex < $sortedByStartDateSize;
           $sortedIdex++) {
        #In the following test, subitem [0] contains the beginning date in the
        # season/holiday date range.  Subitem [1] contains the end date
        #
        if (($strtDateSec >=
             $sortedByStartDate[$sortedIdex][0])
             &&
             (($strtDateSec +
               ($thisDay * $oneDay - 1)) <=      #oneDay = 86400 sec
              ($sortedByStartDate[$sortedIdex][1] +
               ($oneDay - 1))
              )
             )
        {
          $found = $true;                        #May be set more than once
          $indxTmp = $sortedIdex;                #Index may be good, save it
        } #endif
      } #end for sortedIdex
      if ($found) {
        $found = $false;
        $dateType =                              #IndxTmp is the index
          $sortedByStartDate[$indxTmp][2];
        last;
      } #endif
    } #end for thisDay

    #Now build the index into @roomState -- e.g. $KNS00000WinterFriRate
    #
    $index = $statePtr . $dateType .             #Create symbolic ref to index
             $dayOfWeek . 'Rate';
    $index = $$index;                            #Dereference it
    $rate = $roomState[$index];

    # Once we have the date (in MMM DD YYYY form), rate, day-of-week,
    # and the season/holiday identifier, we save these values, along with
    # the date in MMM DD YYYY form, as an item in an array: e.g.
    #  @dateRates = (
    #                ['Aug 06, 1999', '37.95', 'weekday (Sun-Thurs)', 'Hot August Nights'],
    #                ['Aug 07, 1999', '65.00', 'Friday', 'Hot August Nights'],
    #                ['Aug 08, 1999', '65.00', 'Saturday', 'Hot August Nights'],
    #                ['Aug 09, 1999', '30.00', 'weekday (Sun-Thurs)', 'summer'],
    #               );
    #  $dateRatesSiz = @dateRates;
    #
    $dateRates[$i][0] = "'" . $inMonth . ' ' .
      $inDay . ', ' . $centuryPrefix .
      $inYear . "'";

    $dateRates[$i][1] = $rate;                   #Big problem when I tried to
                                                 # assign rate as a strng
                                                 # (10/6/99)
    $dateRates[$i][2] = "'" .
      $dayOfWkDescriptor{$dayOfWeek} . "'";


    if (exists $seasnHolidyDisplay{$dateType}) {
      $dateRates[$i][3] = '"' . $seasnHolidyDisplay{$dateType} . '"'}  #05/31/00
    else {
      #Create a reference to the season/holiday tag, then dereference it
      #
      $dateType .= 'Tag';
      $dateRates[$i][3] = '"' . $$dateType . '"'}                      #05/31/00
    #endif

    $stateTab{$stateDate} = join('|', @roomState);

    $strtDateSec +=     $oneDay;                 #Next day in sec since 1/1/70

    #NOTE: $inDay, $inMonth, $inYear are set initially in res_main
    #
    ($inDay, $inMonth, $inYear, $centuryPrefix) =
      &date_strings($strtDateSec);

    #increment the stateDate variable by one day
    $stateDate = join '|',$inMonth, $inDay, $inYear;

  } #endfor

  #This routine does not return the 2-dim array dateRates(i,j).  Instead, it
  #returns an array (@dateRates) of references (symbolic? hard?).  Each ref-
  #erence points to an item in dateRates.  Each item contains four subitems
  #(see dateRates assignments above).  An example of what is returned is:
  #@dateRates = ARRAY(0x139938) ARRAY(0x1341bc) ARRAY(0x770e4) ARRAY(0x16ed08),
  #where each ARRAY is a reference to an item in @daterates[$i][$j].
  #
  return($roomAvailable, @dateRates);

} #end check_availability


################################################################################
#
#   Name:     initial_dates
#
#   Function: prepares current arrive/depart dates, then displays introductory
#             reservation form
#
#   Inputs:
#
#   Outputs:  arrive day
#             arrive month
#             arrive year
#             depart day
#             depart month
#             depart year
#
#   Caller:   res_form.pl
#             hotel_res_form                  res_utilities_html_lib.pl
#
#   Calls:
#
#       MODIFICATION                                        DATE          BY
#
#   Harvey's Hotel/Casino                                  03/1/98      M. Lewis
# Remove test for century -- it's all 21st century now     05/22/00     M. Lewis
#
sub initial_dates {

#  print "Content-Type: text/html\n\n";

  #variables
  $oneDay = 86400;                               #seconds/day

  ($sec,$min,$hour,$arriveDay,$avMonth,
   $arriveYear,$wDay,$yDay,$isdst) = localtime(time);
  $arriveMonth   = $months[$avMonth];            #Need full spelling
  $arriveMnth    = substr($arriveMonth, 0, 3);   # and abbreviation (1st

  $nextDay = time + $oneDay;

  ($sec,$min,$hour,$departDay,$dpMonth,
   $departYear,$wDay,$yDay,$isdst) = localtime($nextDay);

  $departMonth   = $months[$dpMonth];            #Need full spelling
  $departMnth    = substr($departMonth, 0, 3);   # and abbreviation (1st

  return($arriveDay, $arriveMonth, $arriveMnth,
         $arriveYear, $departDay, $departMonth,
         $departMnth, $departYear);                                    #05/22/00

} #end initial_dates


################################################################################
#
#   Name:     date_strings
#
#   Function: returns date formatted as integer day, 3-letter month abbrevia-
#                                                       tion, and 4-digit year.
#
#   Inputs:             date in seconds since 1/1/70
#
#   Outputs:    see above
#
#   Caller:   check_availability                res_lib.pl
#             modify_state_table                res_lib.pl             #12/13/99
#
#   Calls:    localtime                         Perl lib func (see PP, p. 185)
#             format_display_year               res_lib.pl
#
#                 MODIFICATION                                 DATE       BY
#
#   automated system                                         10/16/99   M. Lewis
# Add arbitrary offset to localtime call input to prevent    09/28/01   M. Lewis
#  return of duplicate dates.
# Remove the offset, don't cater to insanity.                10/25/01   M. Lewis
# Introduce a more-logically-derived offset.                 10/25/01   M. Lewis
#
sub date_strings {

  my $dateSec      = shift(@_);

  #********************************************************************#10/25/01
  #                                                                    #10/25/01
  my $sec01_00_70 = 28800;                       #Value returned from  #10/25/01
                                                 # timelocal(0,0,0,1,  #10/25/01
                                                 # 0,70) call.         #10/25/01

  (my $sec, my $min, my $hour, my $day,
   my $month, my $year, my $wday, my $yday,
   my $isdst) =                                                        #10/25/01
     localtime($dateSec + $sec01_00_70);                               #10/25/01
  #                                                                    #10/25/01
  #NOTE: In a recent test reservation with arrive-day = 10/28/01 and   #10/25/01
  # depart-day = 11/02/01, the above localtime call with input $date-  #10/25/01
  # sec resulted in two identical days from consecutive calls with     #10/25/01
  # input values of $dateSec and $dateSec+86400.  This error has oc-   #10/25/01
  # cured at infrequent and random times in the past.  In an attempt   #10/25/01
  # to get around what I consider to be a problem with the library     #10/25/01
  # function localtime, I am adding the constant value of 28800 to     #10/25/01
  # localtime inputs (in this subroutine only).  28800 is the No. of   #10/25/01
  # seconds returned by calling timelocal(0,0,0,1,0,70).  This is the  #10/25/01
  # time in seconds at 00:00:00 on 1 Jan 1970 according to timelocal.  #10/25/01
  # The fix solves the current problem without introducing problems    #10/25/01
  # in subsequent test reservations.  I'm not happy with this bit of   #10/25/01
  # magic, but I have to use it at my present level of understanding.  #10/25/01
  #                                                                    #10/25/01
  #******************************************************************* #10/25/01
  $month = $monthNum{$month + 1};                #Get month as 3-letter
                                                 # string.
  #Format arrive year for display in YYYY form.  NOTE: this check has
  # already been performed in res_main for the arrive and depart years.
  # But it has to be included here to check for each new day computed
  # in this subroutine..
  #
  ($centuryPrefix, $year) =
    &format_display_year($year);

  return ($day, $month, $year, $centuryPrefix);

} #end date_strings


################################################################################
#
#   Name:     format_display_year
#
#   Function: returns two digit century prefix and two-digit year for display.
#
#   Inputs:   integer year (two or three digit)
#
#   Outputs:  two-digit century prefix, two-digit year
#
#   Caller:   date_strings                         res_lib.pl
#             res_main                             res_main.pl
#             modify_state_table                   res_lib.pl
#             undefined_date                       open_html.lib
#
#   Calls:
#
#                  MODIFICATION                                DATE        BY
#
#   automated system                                         11/05/99   M. Lewis
#
sub format_display_year {

  my $year = shift(@_);
  my $centuryPrefix = '';

  if ($year >= 100) {                            #If true, 21st century
    $centuryPrefix = 20;
    $year -= 100;
    if ($year < 10) {
      $year = '0' . $year}
    #endif
  }
  else {                                         #20th century
    $centuryPrefix = 19}
  #endif

  return ($centuryPrefix, $year);

} #end format_display_year




1;

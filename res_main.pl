#!/usr/bin/perl
require('global_data.pl');
require('res_lib.pl');
require('open_html_lib.pl');
use Time::Local;

################################################################################
#
#   Name:     res_main
#
#   Function: controls input and processing of reservation data from user
#
#   Inputs:   arrive day
#             arrive month
#             arrive year
#             depart day
#             depart month
#             depart year
#             No. guests
#             bed type
#             pets preference
#             rollaway request
#             flag: caller is res_utilities (i.e. originates with hotel
#              staff).
#             room-tax rate                                            #09/12/01
#             other-taxes rate                                         #09/12/01
#
#   Outputs:
#
#   Callers:  res_form.html
#             hotel_res_form            res_utilities_html_lib.pl
#
#   Calls:    adjust_year               res_main.pl
#             days_stay                 res_lib.pl
#             too_many_days             open_html_lib.pl
#             too_far_ahead             open_html_lib.pl
#             max_occupants             open_html_lib.pl
#             check_availability        res_lib.pl
#             room_unavailable          open_html_lib.pl
#             chk_special_days          res_main.pl
#             timelocal                 Perl standard library (PP p. 515)
#             initial_dates             res_lib.pl
#             format_display_year       res_lib.pl
#             undefined_date            open_html_lib.pl
#
#             MODIFICATION                                   DATE          BY
#
#   Lakeside Inn                                           03/12/98     M. Lewis
#   Lakeside Inn   (add seasonal rates)                    06/13/98     M. Lewis
#   Lakeside Inn   (add weekend cruise processing)         06/14/98     M. Lewis
#   Rodeway Inn                                            09/13/98     M. Lewis
# revise for automated system build                        08/30/99     M. Lewis
# change auto sys code to not call form_key                09/28/99     M. Lewis
# new routine adjust_year, remove chk_arrive_depart_dates  10/17/99     M. Lewis
# new routine undefined_date                               11/08/99     M. Lewis
# modified too-many-people block & switched with too-      11/09/99     M. Lewis
#  far-ahead block
# Add code to calculate subtotals, room-taxes, other taxes.09/12/01     M. Lewis
# timelocal seems to return incorrect results, add code to 10/23/01     M. Lewis
#  compensate for problem.
# Adding check to guard against someone trying to make a   11/12/01     M. Lewis
#  reservation for a date earlier than today.
#
#################################################5#############################8
#Begin comments at col 50, end at 80:            0                             0

#   Variables

$numDays = '';
$inMonth = '';
$inDay = '';
$inYear = '';
$deposit = '';
$totAmt = '';
$rollsAmt = '';
$tax = 0;
$amtField = 1;
$junk = '';
#$remd = '';                                                           #10/23/01

##HOOK: BEGIN INITIALIZE DATE VARIABLES
$offseasonWkDay = 0;
$offseasonFri = 0;
$offseasonSat = 0;
$offseasonWkDayTotAmt = 0;
$offseasonFriTotAmt = 0;
$offseasonSatTotAmt = 0;

$MemorialDayWkDay = 0;
$MemorialDayFri = 0;
$MemorialDaySat = 0;
$MemorialDayWkDayTotAmt = 0;
$MemorialDayFriTotAmt = 0;
$MemorialDaySatTotAmt = 0;

$SummerWkDay = 0;
$SummerFri = 0;
$SummerSat = 0;
$SummerWkDayTotAmt = 0;
$SummerFriTotAmt = 0;
$SummerSatTotAmt = 0;

$LaborDayWkDay = 0;
$LaborDayFri = 0;
$LaborDaySat = 0;
$LaborDayWkDayTotAmt = 0;
$LaborDayFriTotAmt = 0;
$LaborDaySatTotAmt = 0;

$SkiSeasonWkDay = 0;
$SkiSeasonFri = 0;
$SkiSeasonSat = 0;
$SkiSeasonWkDayTotAmt = 0;
$SkiSeasonFriTotAmt = 0;
$SkiSeasonSatTotAmt = 0;

$ChristmasWkDay = 0;
$ChristmasFri = 0;
$ChristmasSat = 0;
$ChristmasWkDayTotAmt = 0;
$ChristmasFriTotAmt = 0;
$ChristmasSatTotAmt = 0;

$NewYearsWkDay = 0;
$NewYearsFri = 0;
$NewYearsSat = 0;
$NewYearsWkDayTotAmt = 0;
$NewYearsFriTotAmt = 0;
$NewYearsSatTotAmt = 0;

$NewYearsEveWkDay = 0;
$NewYearsEveFri = 0;
$NewYearsEveSat = 0;
$NewYearsEveWkDayTotAmt = 0;
$NewYearsEveFriTotAmt = 0;
$NewYearsEveSatTotAmt = 0;

##HOOK: END INITIALIZE DATE VARIABLES

#begin main processing

#print "Content-Type: text/html\n\n";

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

   $FORM{$name} = $value;                        #Name/value pairs -> hash
} #end while/foreach

#Check for an invalid arrival/departure date
#
$arriveYear = $FORM{'arrive_year'};
if ($arriveYear =~ /^0/) {
    $arriveYear =~ s/^0//}
#endif

$departYear = $FORM{'depart_year'};
if ($departyear =~ /^0/) {
    $departYear =~ s/^0//}
#endif

$arriveMnth = ($ordMonth{$FORM{'arrive_month'}} - 1);  #Month as int
                                                       # 0-11.
$arriveDay = timelocal(0, 0, 0, $FORM{'arrive_day'},
                       $arriveMnth, $arriveYear);

$departMnth = ($ordMonth{$FORM{'depart_month'}} - 1);  #Month as int
                                                       # 0-11.
$departDay = timelocal(0, 0, 0, $FORM{'depart_day'},
                       $departMnth, $departYear);
#
#Note: I am leaving the following commentary intact, although the      #10/26/01
# processing associated with it is disabled & will never be used.  The #10/26/01
# basic problem (localtime returns different outputs given the same in-#10/26/01
# puts) exists and I don't know how to solve it given what I know to-  #10/26/01
# day.  See res_lib.pl:date_strings for a temporary workaround.        #10/26/01
#                                                                      #10/26/01
#What is going on here!  timelocal is returning arriveDay = 1004252400 #10/23/01
# and departDay = 1004342400.  Neither is a multiple of 86400 sec.     #10/23/01
# Which should be impossible given input of 0 for sec, hour, and min.  #10/23/01
# But arriveDay/86400 = 11623.2916667 and departDay/86400 =            #10/23/01
# 11624.3333333.  And departDay - arriveDay = 1.0416666 days.  And     #10/23/01
# 0.0416666 days = 3599.99 sec = just about 1 hour.  So I'm going to   #10/23/01
# include processing here to truncate arriveDay and departDay so that  #10/23/01
# they both have fractional parts = 0.  But why I should have to do    #10/23/01
# this is beyond me.  Unix timelocal isn't working right (on this sys- #10/23/01
# tem anyway).  So I'll have to accommodate the error myself.          #10/23/01
#                                                                      #10/23/01
#$remd = $arriveDay % 86400;                                           #10/23/02
#$arriveDay -= $remd;                                                  #10/23/01
#$remd = $departDay % 86400;                                           #10/23/01
#$departDay -= $remd;                                                  #10/23/01

($sec,$min,$hour,$nowDay,$nowMonth,                                    #11/12/01
 $nowYear,$wDay,$yDay,$isdst) = localtime(time);                       #11/12/01
                                                                       #11/12/01
$thisDay = timelocal(0, 0, 0, $nowDay, $nowMonth, $nowYear);           #11/12/01

if (($arriveDay >= $departDay) ||                                      #11/12/01
    ($arriveDay < $thisDay)                                            #11/12/01
   ) {                                                                 #11/12/01
  &bad_date_entry;                               #Invalid date, notify
} #endif                                         # user.

#Compute the No. of days for which the room will be reserved
#
$numDays = int((($departDay - $arriveDay) / 86400));                   #10/25/01

#Check -- trying to reserve for too many days? (checked for auto sys 5/18/99)
#
if ($maxDays) {
  if (($maxDays - $numDays) < 0) {
    &too_many_days}
  #endif
} #endif

#Check for weekends and holidays
#
#Break reservation days into weekdays, weekend days, holidays, etc.
#
(
##HOOK: BEGIN DEFINE SEASONS & HOLIDAYS
$offseasonWkDay, $offseasonFri, $offseasonSat,    #added 7/4/03
$MemorialDayWkDay, $MemorialDayFri, $MemorialDaySat,
$summerWkDay, $summerFri, $summerSat,             #added 7/4/03
$LaborDayWkDay, $LaborDayFri, $LaborDaySat,
$SkiSeasonWkDay, $SkiSeasonFri, $SkiSeasonSat,
$ChristmasWkDay, $ChristmasFri, $ChristmasSat,    #added 7/4/03
$NewYearsWkDay, $NewYearsFri, $NewYearsSat,       #added 7/4/03
$NewYearsEveWkDay, $NewYearsEveFri, $NewYearsEveSat,
##HOOK: END DEFINE SEASONS & HOLIDAYS
) = &chk_special_days($numDays, $arriveDay);

#Check -- trying to reserve too far ahead? (changed for automated sys 5/18/99)
#
if (($maxCalendarDate - $departDay) < 0) {
  &undefined_date}                               #date > max calander date
else {
  if ($maxFutureDays) {
    $maxFutureSec = $maxFutureDays * 86400;
    $currSec = time;
    $maxSec = $currSec + $maxFutureSec;
    if (($maxSec - $departDay) < 0) {

      ($sec,$min,$hour,$day,$month,
       $year,$wDay,$yDay,$isdst) = localtime($maxSec);

      $outMonth = $months[$month];               #Need full spelling for month
                                                 # (three chars)
      ($centuryPrefix, $year) =
        &format_display_year($year);

      &too_far_ahead($day, $outMonth, $year,     #Call error routine
                                                 $centuryPrefix);
    } #endif
  } #endif
} #endif

#Check -- trying to reserve for too many people? (changed for auto sys 5/18/99)
#
# create array that contains the max No. occupants for this room type
#
if ($FORM{'select_bed'} =~ /Choose your accommodations/) {
  &get_bed_type}                                 #Error exit
else {
  @rmDef = split (/\|/, $roomDef{$FORM{'select_bed'}});
  $maxOcc = 2;                                   #Index into array rmDef
  #
  if ($FORM{'Person_Cnt'} > $rmDef[$maxOcc]) {   #Too many guests for rm type?
    #Rollaways available?  If so add 1 to max-guests
    #
    if (exists($FORM{'rollaway'})) {
      if ($FORM{'Person_Cnt'} > ($rmDef[$maxOcc] + 1)) {
        #Still too many people, error exit
        #
        &max_occupants($rmDef[$maxOcc]);
      }
      else {
        #Accept No. guests as long as they include rollaway
        #
        unless ($FORM{'rollaway'}) {
          $FORM{'rollaway'} = $true}
        #end unless
      #endif
    } #endif
  }
  else {
    &max_occupants($rmDef[$maxOcc])}             #Too many guests, error exit
  }#endif
} #endif

#Form a date key for index into the state table
#
$inMonth = $FORM{arrive_month};
$inDay = $FORM{arrive_day};
$inYear = $FORM{arrive_year};

$stateDate = join '|',$inMonth, $inDay, $inYear;

#Use the room_type key from the user entry to index the state-table "item."
#
$statePtr = $FORM{'select_bed'};
if ($statePtr =~ /Choose your accommodations/) {
  &get_bed_type}                                 #Error exit
#endif

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

($roomAvailable, @dateRates) =
  &check_availability($numDays, $inDay,          #Defined in res_lib.pl
                      $inMonth,  $inYear,
                      $outDay, $outMonth,
                      $outYear, $statePtr,
                      $stateDate, $arriveDay,                          #10/23/01
                      $departDay);                                     #10/23/01

#NOTE: check_availability does not return the 2-dim array dateRates(i,j).  In-
#stead, it returns an array (@dateRates) of references (symbolic? hard?).
#Each reference points to an item in dateRates.  Each item contains four sub-
#items (see dateRates assignments in check_availability).  An example of what
#is returned is:
#@dateRates = ARRAY(0x139938) ARRAY(0x1341bc) ARRAY(0x770e4) ARRAY(0x16ed08),
#where each ARRAY is a reference to an item in @daterates[$i][$j].
#

unless ( $roomAvailable) {
  #room unavailable, tell user
  &room_unavailable;                             #Defined in open_html_lib
  exit}
#end unless

dbmclose(%stateTab);

$dateRates = @dateRates;

#Do the actual room charges
#
for ($i = 0; $i < $dateRates; $i++) {
  #Since @dateRates is an array of references, we have to dereference each
  #item in @dateRates to get at the actual data.  Dereferencing occurs in two
  #steps: first we assign a given item to a scalar:
  #
  $a = $dateRates[$i];
  #
  #then we dereference the scalar (which contains a reference to an item
  #of real data):
  #
  @b = @$a;
  #
  #Now we're pointing to a 1-dim array of four items of real data.  We want
  #to work with the second item here, so:
  #
  $subTotAmt += $b[$amtField];                                         #09/12/01
}#end for

#If there are pets, charge $/day extra
if ($FORM{'pet'}) {
   $petsAmt = ($numDays * $petRate);
   $subTotAmt += $petsAmt}                                             #09/12/01
#endif
#
#If rollaway bed requested, charge $/day extra
if ($FORM{'rollaway'}) {
   $rollAmt = ($numDays * $rollawayRate);
   $subTotAmt += $rollAmt}                                             #09/12/01
#endif

#Compute tax and roomtax                                               #09/12/01
#
$tax = ($taxFactor * $subTotAmt);                                      #09/12/01
$roomTax = ($room_taxFactor * $subTotAmt);                             #09/12/01

$totAmt = ($tax + $roomTax + $subTotAmt);        #This is the total amt#09/12/01
                                                 # for the reservation.
#Deposit is one day's stay
#
$deposit = ($totAmt / $numDays);

#Reservation selections available, notify user
&selections_available;

exit;


################################################################################
#
#   Name:     chk_special_days
#
#   Function: check for weekends and holidays in reservation request
#
#   Inputs:   No. days requested for reservation
#             arrive day (seconds since 1/1/70)
#             for each holiday to be checked: No. days in holiday period
#                                             first day of holiday
#                                             last day of holiday
#                                             minimum No. of days for which res-
#                                             ervation can be requested
#
#   Outputs:
#
#   Caller:   res_main                        res_main.pl
#
#   Calls:    weekends_holidays               res_main.pl
#             holiday_restrictions            open_html_lib.pl
#             weekend_restrictions            open_html_lib.pl
#
#                MODIFICATION                                DATE         BY
#
#   Lakeside Inn                                           03/12/98     M. Lewis
#   Lakeside Inn   (add seasonal rates)                    06/13/98     M. Lewis
#   Inn at Heavenly(make separate chks for Xmas & Newyear) 09/26/98     M. Lewis
# automated system rewrite                                 04/12/99     M. Lewis
#
sub chk_special_days {

  my $numDays    = shift(@_);
  my $inDay      = shift(@_);

##HOOK: BEGIN DEFINE CHK_SPECIAL_DAYS DAYS & SEASONS COUNTERS
   my $offseasonWkDay = 0;
   my $offseasonFri = 0;
   my $offseasonSat = 0;
   my $offseasonNumDays = 0;
   my $MemorialDayWkDay = 0;
   my $MemorialDayFri = 0;
   my $MemorialDaySat = 0;
   my $MemorialDayNumDays = 0;
   my $SummerWkDay = 0;
   my $SummerFri = 0;
   my $SummerSat = 0;
   my $SummerNumDays = 0;
   my $LaborDayWkDay = 0;
   my $LaborDayFri = 0;
   my $LaborDaySat = 0;
   my $LaborDayNumDays = 0;
   my $SkiSeasonWkDay = 0;
   my $SkiSeasonFri = 0;
   my $SkiSeasonSat = 0;
   my $SkiSeasonNumDays = 0;
   my $ChristmasWkDay = 0;
   my $ChristmasFri = 0;
   my $ChristmasSat = 0;
   my $ChristmasNumDays = 0;
   my $NewYearsEveWkDay = 0;
   my $NewYearsEveFri = 0;
   my $NewYearsEveSat = 0;
   my $NewYearsEveNumDays = 0;
   my $NewYearsWkDay = 0;
   my $NewYearsFri = 0;
   my $NewYearsSat = 0;
   my $NewYearsNumDays = 0;
##HOOK: END DEFINE CHK_SPECIAL_DAYS DAYS & SEASONS COUNTERS

  #Get the numbers of days that are weekend days/holidays
  #
  (
##HOOK: BEGIN DEFINE WEEKENDS_HOLIDAYS INPUTS
    $offseasonWkDay, $offseasonFri, $offseasonSat,    #added 7/4/03
    $MemorialDayWkDay, $MemorialDayFri, $MemorialDaySat,
    $summerWkDay, $summerFri, $summerSat,             #added 7/4/03
    $LaborDayWkDay, $LaborDayFri, $LaborDaySat,
    $SkiSeasonWkDay, $SkiSeasonFri, $SkiSeasonSat,
    $ChristmasWkDay, $ChristmasFri, $ChristmasSat,    #added 7/4/03
    $NewYearsWkDay, $NewYearsFri, $NewYearsSat,       #added 7/4/03
    $NewYearsEveWkDay, $NewYearsEveFri, $NewYearsEveSat,
##HOOK: END DEFINE WEEKENDS_HOLIDAYS INPUTS
  ) = &weekends_holidays($numDays, $inDay);

  #If holiday/weekend reservation, make sure reservation is for specified period
  #
##HOOK: BEGIN DEFINE HOLIDAY_RESTRICTIONS INPUTS
   if ((($offseasonWkDay + $offseasonFri + $offseasonSat) > 0) && ($numDays < $offseasonMinDays)) {
     $offseasonNumDays = ((($endoffseason - $startoffseason) / $oneDay) + 1);
   &holiday_restrictions("offseason", $offseasonNumDays,
                              $startoffseasonStrng, $endoffseasonStrng,
                              $offseasonMinDays);
   }

   elsif ($twoDayMin) {
     if ((($offseasonFri + $offseasonSat) > 0) && ($numDays < 2)) {
          &weekend_restrictions}
     elsif ($noSatArrival) {                   #Arriving on a Saturday?
       $sat =                                    #See PP p. 185.
         (0,0,0,0,0,0,1)[(localtime($arriveDay))[6]];
       if ($sat) {
         &no_sat_arrival("offseason")}
       #endif
     }#endif
   }

   else {}
   #endif


   if ((($MemorialDayWkDay + $MemorialDayFri + $MemorialDaySat) > 0) && ($numDays < $MemorialDayMinDays)) {
     $MemorialDayNumDays = ((($endMemorialDay - $startMemorialDay) / $oneDay) + 1);
   &holiday_restrictions("Memorial Day", $MemorialDayNumDays,
                              $startMemorialDayStrng, $endMemorialDayStrng,
                              $MemorialDayMinDays);
   }

   elsif ($twoDayMin) {
     if ((($MemorialDayFri + $MemorialDaySat) > 0) && ($numDays < 2)) {
          &weekend_restrictions}
     elsif ($noSatArrival) {                   #Arriving on a Saturday?
       $sat =                                    #See PP p. 185.
         (0,0,0,0,0,0,1)[(localtime($arriveDay))[6]];
       if ($sat) {
         &no_sat_arrival("Memorial Day")}
       #endif
     }#endif
   }

   else {}
   #endif


   if ((($summerWkDay + $summerFri + $summerSat) > 0) && ($numDays < $summerMinDays)) {
     $summerNumDays = ((($endsummer - $startsummer) / $oneDay) + 1);
   &holiday_restrictions("summer", $summerNumDays,
                              $startsummerStrng, $endsummerStrng,
                              $summerMinDays);
   }

   elsif ($twoDayMin) {
     if ((($summerFri + $summerSat) > 0) && ($numDays < 2)) {
          &weekend_restrictions}
     elsif ($noSatArrival) {                   #Arriving on a Saturday?
       $sat =                                    #See PP p. 185.
         (0,0,0,0,0,0,1)[(localtime($arriveDay))[6]];
       if ($sat) {
         &no_sat_arrival("summer")}
       #endif
     }#endif
   }

   else {}
   #endif


   if ((($LaborDayWkDay + $LaborDayFri + $LaborDaySat) > 0) && ($numDays < $LaborDayMinDays)) {
     $LaborDayNumDays = ((($endLaborDay - $startLaborDay) / $oneDay) + 1);
   &holiday_restrictions("LaborDay", $LaborDayNumDays,
                              $startLaborDayStrng, $endLaborDayStrng,
                              $LaborDayMinDays);
   }

   elsif ($twoDayMin) {
     if ((($LaborDayFri + $LaborDaySat) > 0) && ($numDays < 2)) {
          &weekend_restrictions}
     elsif ($noSatArrival) {                   #Arriving on a Saturday?
       $sat =                                    #See PP p. 185.
         (0,0,0,0,0,0,1)[(localtime($arriveDay))[6]];
       if ($sat) {
         &no_sat_arrival("LaborDay")}
       #endif
     }#endif
   }

   else {}
   #endif


   if ((($SkiSeasonWkDay + $SkiSeasonFri + $SkiSeasonSat) > 0) && ($numDays < $SkiSeasonMinDays)) {
     $SkiSeasonNumDays = ((($endSkiSeason - $startSkiSeason) / $oneDay) + 1);
   &holiday_restrictions("Ski Season", $SkiSeasonNumDays,
                              $startSkiSeasonStrng, $endSkiSeasonStrng,
                              $SkiSeasonMinDays);
   }

   elsif ($twoDayMin) {
     if ((($SkiSeasonFri + $SkiSeasonSat) > 0) && ($numDays < 2)) {
          &weekend_restrictions}
     elsif ($noSatArrival) {                   #Arriving on a Saturday?
       $sat =                                    #See PP p. 185.
         (0,0,0,0,0,0,1)[(localtime($arriveDay))[6]];
       if ($sat) {
         &no_sat_arrival("Ski Season")}
       #endif
     }#endif
   }

   else {}
   #endif

   if ((($ChristmasWkDay + $ChristmasFri + $ChristmasSat) > 0) && ($numDays < $ChristmasMinDays)) {
     $ChristmasNumDays = ((($endChristmas - $startChristmas) / $oneDay) + 1);
   &holiday_restrictions("Christmas", $ChristmasNumDays,
                              $startChristmasStrng, $endChristmasStrng,
                              $ChristmasMinDays);
   }

   elsif ($twoDayMin) {
     if ((($ChristmasFri + $ChristmasSat) > 0) && ($numDays < 2)) {
          &weekend_restrictions}
     elsif ($noSatArrival) {                   #Arriving on a Saturday?
       $sat =                                    #See PP p. 185.
         (0,0,0,0,0,0,1)[(localtime($arriveDay))[6]];
       if ($sat) {
         &no_sat_arrival("Christmas")}
       #endif
     }#endif
   }

   else {}
   #endif


   if ((($NewYearsEveWkDay + $NewYearsEveFri + $NewYearsEveSat) > 0) && ($numDays < $NewYearsEveMinDays)) {
     $NewYearsEveNumDays = ((($endNewYearsEve - $startNewYearsEve) / $oneDay) + 1);
   &holiday_restrictions("New Years Eve", $NewYearsEveNumDays,
                              $startNewYearsEveStrng, $endNewYearsEveStrng,
                              $NewYearsEveMinDays);
   }

   elsif ($twoDayMin) {
     if ((($NewYearsEveFri + $NewYearsEveSat) > 0) && ($numDays < 2)) {
          &weekend_restrictions}
     elsif ($noSatArrival) {                   #Arriving on a Saturday?
       $sat =                                    #See PP p. 185.
         (0,0,0,0,0,0,1)[(localtime($arriveDay))[6]];
       if ($sat) {
         &no_sat_arrival("New Years Eve")}
       #endif
     }#endif
   }

   else {}
   #endif


   if ((($NewYearsWkDay + $NewYearsFri + $NewYearsSat) > 0) && ($numDays < $NewYearsMinDays)) {
     $NewYearsNumDays = ((($endNewYears - $startNewYears) / $oneDay) + 1);
   &holiday_restrictions("NewYears ", $NewYearsNumDays,
                              $startNewYearsStrng, $endNewYearsStrng,
                              $NewYearsMinDays);
   }

   elsif ($twoDayMin) {
     if ((($NewYearsFri + $NewYearsSat) > 0) && ($numDays < 2)) {
          &weekend_restrictions}
     elsif ($noSatArrival) {                   #Arriving on a Saturday?
       $sat =                                    #See PP p. 185.
         (0,0,0,0,0,0,1)[(localtime($arriveDay))[6]];
       if ($sat) {
         &no_sat_arrival("NewYears ")}
       #endif
     }#endif
   }

   else {}
   #endif


   if ((($NewYearsEveWkDay + $NewYearsEveFri + $NewYearsEveSat) > 0) && ($numDays < $NewYearsEveMinDays)) {
     $NewYearsEveNumDays = ((($endNewYearsEve - $startNewYearsEve) / $oneDay) + 1);
   &holiday_restrictions("NewYears Eve", $NewYearsEveNumDays,
                              $startNewYearsEveStrng, $endNewYearsEveStrng,
                              $NewYearsEveMinDays);
   }

   elsif ($twoDayMin) {
     if ((($NewYearsEveFri + $NewYearsEveSat) > 0) && ($numDays < 2)) {
          &weekend_restrictions}
     elsif ($noSatArrival) {                   #Arriving on a Saturday?
       $sat =                                    #See PP p. 185.
         (0,0,0,0,0,0,1)[(localtime($arriveDay))[6]];
       if ($sat) {
         &no_sat_arrival("NewYears Eve")}
       #endif
     }#endif
   }

   else {}
   #endif


##HOOK: END DEFINE HOLIDAY_RESTRICTIONS INPUTS

  return (
##HOOK: BEGIN DEFINE CHK_SPECIAL_DAYS RETURNS
           $offseasonWkDay, $offseasonFri, $offseasonSat,    #added 7/4/03
           $MemorialDayWkDay, $MemorialDayFri, $MemorialDaySat,
           $summerWkDay, $summerFri, $summerSat,             #added 7/4/03
           $LaborDayWkDay, $LaborDayFri, $LaborDaySat,
           $SkiSeasonWkDay, $SkiSeasonFri, $SkiSeasonSat,
           $ChristmasWkDay, $ChristmasFri, $ChristmasSat,    #added 7/4/03
           $NewYearsWkDay, $NewYearsFri, $NewYearsSat,       #added 7/4/03
           $NewYearsEveWkDay, $NewYearsEveFri, $NewYearsEveSat,
##HOOK: END DEFINE CHK_SPECIAL_DAYS RETURNS
         );

} #end chk_special_days


################################################################################
#
#   Name:     weekends_holidays
#
#   Function: calculates No. of weekend, season holiday days in reservation
#             request
#
#   Inputs:   No. days in reservation request
#             arrive day (in sec since 1/1/70)
#
#   Outputs:  No. of weekday days (summer and winter)
#             No. weekend days (summer and winter)
#             No. holiday days for each holiday input
#
#   Caller:   chk_special days                   res_main.pl
#
#   Calls:
#
#       MODIFICATION                                         DATE         BY
#
#   Lakeside Inn                                           04/08/98     M. Lewis
#   Lakeside Inn   (add seasonal rates)                    06/13/98     M. Lewis
#   Rodeway Inn                                            09/13/98     M. Lewis
# automated system rewrite                                 04/12/99     M. Lewis
#
sub weekends_holidays {

  my $numDays    = shift(@_);
  my $arriveSec  = shift(@_);
  my $tag = '';
  my $wkDay = '';
  my $fri = '';
  my $sat = '';
  my $thisDay = '';
  my $sortedIdex = '';
  my $indxTmp = '';

#NOTE: Some of the following auto-generated variables (the ones that accum-
# ulate totals) must be of type local because they are referred to in this
# routine as symbolic references, and declaring them with type my makes them
# unusable as references (10/15/99).
#
##HOOK: BEGIN DEFINE WEEKENDS_HOLIDAYS DAYS & SEASONS COUNTERS
   local $offseasonWkDay = 0;
   local $offseasonFri = 0;
   local $offseasonSat = 0;
   local $MemorialDayWkDay = 0;
   local $MemorialDayFri = 0;
   local $MemorialDaySat = 0;
   local $SummerWkDay = 0;
   local $SummerFri = 0;
   local $SummerSat = 0;
   local $LaborDayWkDay = 0;
   local $LaborDayFri = 0;
   local $LaborDaySat = 0;
   local $SkiSeasonWkDay = 0;
   local $SkiSeasonFri = 0;
   local $SkiSeasonSat = 0;
   local $ChristmasWkDay = 0;
   local $ChristmasFri = 0;
   local $ChristmasSat = 0;
   local $NewYearsWkDay = 0;
   local $NewYearsFri = 0;
   local $NewYearsSat = 0;
   local $NewYearsEveWkDay = 0;
   local $NewYearsEveFri = 0;
   local $NewYearsEveSat = 0;
##HOOK: END DEFINE WEEKENDS_HOLIDAYS DAYS & SEASONS COUNTERS

  for ($i = 0; $i < $numDays; $i++) {
    #
    #Find the holiday/season in which the current day occurs.  First,
    # get an index into %sortDate so we can figure out what kind of date this
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
        if (($arriveSec >=
             $sortedByStartDate[$sortedIdex][0])
             &&
             (($arriveSec +
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

      if ($found) {                              #Current indxTmp is the index
        $found = $false;
        $tag = $sortedByStartDate[$indxTmp][2];  #Get the string
        last;
      } #endif
    } #end for thisDay

    (my $sec, my $min, my $hour, my $avDay, my $avMonth,
     my $avYear, my $wDay, my $yDay, my $isdst) = localtime($arriveSec);

    #Create day-of-week pointers by testing with $wDay from localtime call
    # above, then dereference them & increment corresponding variables (see
    # PP p. 254 for discussion of symbolic references).
    #
    if ($wDay == 5) {
      $fri = $tag . 'Fri';
      $$fri++;
    }
    elsif ($wDay == 6) {
      $sat = $tag . 'Sat';
      $$sat++;
    }
    else {
      $wkDay = $tag . 'WkDay';
      $$wkDay++;
    }
    #endif
    $arriveSec += 86400;                         #Set for next day
  } #end for i

  return (
##HOOK: BEGIN WEEKENDS_HOLIDAYS RETURNS
           $offseasonWkDay, $offseasonFri, $offseasonSat,    #added 7/4/03
           $MemorialDayWkDay, $MemorialDayFri, $MemorialDaySat,
           $summerWkDay, $summerFri, $summerSat,             #added 7/4/03
           $LaborDayWkDay, $LaborDayFri, $LaborDaySat,
           $SkiSeasonWkDay, $SkiSeasonFri, $SkiSeasonSat,
           $ChristmasWkDay, $ChristmasFri, $ChristmasSat,    #added 7/4/03
           $NewYearsWkDay, $NewYearsFri, $NewYearsSat,       #added 7/4/03
           $NewYearsEveWkDay, $NewYearsEveFri, $NewYearsEveSat,
##HOOK: END WEEKENDS_HOLIDAYS RETURNS
          );
} #end weekends_holidays

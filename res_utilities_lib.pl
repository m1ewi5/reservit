#!/usr/bin/perl
require('global_data.pl');
use Time::Local;                                                       #08/15/01


################################################################################
#
#   Name:     resState_delete
#
#   Function: gets rid of all resState.db records whose stateDate key is
#             < today's date
#
#   Inputs:
#
#   Outputs:  No. records deleted
#             list of deleted date keys
#
#   Caller:   res_cancel                res_cancel.pl
#             res_display               res_display.pl
#
#   Calls:    get_date                  res_utilities_lib.pl
#             timelocal                 Standard Perl Library          #08/15/01
#
#                     MODIFICATION                             DATE        BY
#
# Revise code to use Unix time calls.                        08/15/01   M. Lewis
#
sub resState_delete {

  my $chkMnth = '';
  my $chkDay = '';
  my $chkYr = '';
  my $stateTab = '';
  my @sortDate = '';
  my $numberRecs = '';
  my $resMnth = '';
  my $resDay = '';
  my $resYr = '';
  my $recsDeleted = '';
  my $numDeleted = 0;
  my $chkSec = '';                                                     #08/15/01
  my $resSec = '';                                                     #08/15/01

  ($chkMnth, $chkDay, $chkYr) = &get_date;       #Defined in res_lib.pl
  $chkMnth--;                                    #Range must be 0 - 11.#08/15/01
  $chkSec = timelocal(0, 0, 0, $chkDay,          #Today's date at 12AM #08/15/01
                      $chkMnth, $chkYr);         # in sec since 1/1/70.#08/15/01

  dbmopen(%stateTab, $statePath, $mode);

  @sortDate = (sort keys %stateTab);
  $numberRecs = @sortDate;

  while ($numberRecs > 0) {

    ($resMnth, $resDay, $resYr) =
      split(/\|/, $sortDate[$numberRecs-1]);
    $resMnth = $ordMonth{$resMnth} - 1;          #Need integer 0 - 11. #08/15/01
    $resSec = timelocal(0, 0, 0, $resDay,        #Res arrive date in   #08/15/01
                      $resMnth, $resYr);         # sec since 1/1/70.   #08/15/01

    if ($chkSec > ($resSec + $oneYear)) {        #> one year from      #09/25/01
                                                 # 00:00:00 today?     #09/25/01
#    if ($chkSec > $resSec) {                     #> 00:00:00 today?    #08/15/01
      $recsDeleted .= "$sortDate[$numberRecs-1]<BR>";
      delete $stateTab{$sortDate[$numberRecs-1]};
      $numDeleted ++;
    } #endif

    $numberRecs --;

  } #end while

  dbmclose(%stateTab);

  $recsDeleted =~ s/\|/ /g;                      #Change | to space

  return($recsDeleted, $numDeleted);

} #end resState_delete



################################################################################
#
#   Name:     resChange_delete
#
#   Function: deletes all transaction No. records whose depart-date is older
#             than today's date
#
#   Inputs:
#
#   Outputs:  No. records deleted
#             list of deleted transaction-No. keys
#
#   Caller:   res_cancel                res_cancel.pl
#             res_display               res_display.pl
#
#   Calls:    get_date                  res_utilities_lib.pl
#             timelocal                 Standard Perl Library          #08/15/01
#
#                     MODIFICATION                             DATE        BY
#
# Revise code to use Unix time calls.                        08/15/01   M. Lewis
#
sub resChange_delete {

  my $recsDeleted = '';
  my @transKeys = '';
  my $numberTransRecs = '';
  my $statePtr = '';
  my $inDay = '';
  my $inMnth = '';
  my $inYr = '';
  my $numDays = '';
  my $outDay = '';
  my $outMnth = '';
  my $outYr = '';
  my $chkMnth = '';
  my $chkDay = '';
  my $chkYr = '';
  my $numDeleted = 0;
  my $chkSec = '';                                                     #08/15/01
  my $outSec = '';                                                     #08/15/01

  ($chkMnth, $chkDay, $chkYr) = &get_date;       #Defined in res_lib.pl
  $chkMnth--;                                    #Range must be 0 - 11.#08/15/01
  $chkSec = timelocal(0, 0, 0, $chkDay,          #Today's date at 12AM #08/15/01
                      $chkMnth, $chkYr);         # in sec since 1/1/70.#08/15/01

  dbmopen(%transLst, $changePath, $mode);

  @transKeys = (keys %transLst);                 #Get all the keys in the table
  $numberTransRecs = @transKeys;                 #Get the No. recs in the table

  while ($numberTransRecs > 0) {
    ($statePtr, $inDay, $inMnth, $inYr,          #Extract the table-record
     $numDays, $outDay, $outMnth, $outYr) =      # data
    split (/\|/,
           $transLst{$transKeys[$numberTransRecs-1]});

    $outMnth = $ordMonth{$outMnth} - 1;          #Need integer 0 - 11. #08/15/01
    $outSec = timelocal(0, 0, 0, $outDay,        #Res depart date in   #08/15/01
                      $outMnth, $outYr);         # sec since 1/1/70.   #08/15/01

    if ($chkSec > ($outSec + $oneYear)) {        #> one year from       #09/25/01
                                                 # 00:00:00 today?      #09/25/01
#    if ($chkSec > $outSec) {                    #> 00:00:00 today?     #08/15/01
      $recsDeleted .=                            #Compile list of deleted keys
        "$transKeys[$numberTransRecs-1]<br>";
      $numDeleted ++;
      delete $transLst{$transKeys[$numberTransRecs-1]};
    } #endif
    $numberTransRecs --;
  } #end while

  dbmclose(%transLst);

  return($recsDeleted, $numDeleted);

} #end resChange_delete


################################################################################
#
#   Name:     get_date
#
#   Function: returns today's date as integer month, day, year variables
#
#   Inputs:
#
#   Outputs:  integer month (MM)
#             day (DD)
#             year (YY)
#
#   Caller:   resState_delete           res_utilities_lib.pl
#             resChange_delete          res_utilities_lib.pl
#
#   Calls:    Unix date function        /bin/date
#
sub get_date {
   my $shortdate = '';
   my $thisDate = '';
   my $thisMonth = '';
   my $thisDay = '';
   my $thisYear = '';

   $shortdate = `$date_command +"%D %T %Z"`;
   chop($shortdate);

   ($thisDate, $junk) = split(/ /,$shortdate,2);
   ($thisMonth, $thisDay, $thisYear) = split(/\//, $thisDate);

   return($thisMonth, $thisDay, $thisYear);

} #end get_date


################################################################################
#
#   Name:     format_date
#
#   Function: returns inputs as text date string.
#
#   Inputs:   day (dd), month (1-12), year (ddd)
#
#   Outputs:  month (mmm)
#             day (dd)
#             year (yy)
#
#   Caller:   check_rate                rates_update.pl
#             post_update_rates         res_utilities_html_lib.pl
#
#   Calls:
#
#                     MODIFICATION                             DATE        BY
#
#                                                            09/07/01   M. Lewis
#
sub format_date {

  my $month = shift(@_);
  my $day   = shift(@_);
  my $year  = shift(@_);

  if ($day < 10) {
    $day = " " . $day}
  else {}
  #endif

  $month = $monthNum{$month};                    #Convert month from
                                                 # int 1-12 to strng.
  if ($year > 99) {
    $year -= 100}
  #endif

#  if ($year < 10) {                              #Format year for
#      $year = '0' . $year}                       # printing.
  # endif

  return($month, $day, $year);

} #end format_date


1;

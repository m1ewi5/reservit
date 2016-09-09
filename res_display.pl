#!/usr/bin/perl
require('res_utilities_lib.pl');
require('res_utilities_html_lib.pl');
require('global_data.pl');
require('open_html_lib.pl');
use Time::Local;

################################################################################
#
#   Name:     res_display
#
#   Function: controls selection and display of reservation database records
#
#   Inputs:   arrive day
#             arrive month
#             arrive year
#             depart day
#             depart month
#             depart year
#             first name
#             last name
#             address
#             city
#             state
#             country
#             ZIP
#             email address
#             home phone No.
#             reservation transaction No.
#             date string
#             password validity check flag
#             sort sequence (0 to 3 sorts)
#
#   Outputs:
#
#   Caller:   display_res               res_utilities_html_lib.pl
#
#   Calls:    resState_delete           res_utilities_lib.pl
#             build_display             res_display.pl
#             no_matches                res_utilities_html_lib.pl
#
#                       MODIFICATION                           DATE        BY
#
#   Lakeside Inn (add sort on resChange keys)                06/26/98   M. Lewis
#   Rodeway Inn  (add first/last names, sort menus)          10/24/98   M. Lewis
#   Rodeway Inn  (add call to resChange_delete)              12/05/98   M. Lewis
# Add equality condition when searching for matches.         10/01/01   M. Lewis
#

#variables
$recsDeleted = 0;
$datesDeleted = '';
$datesCancelled = '';
$shortdate = '';
$date = '';
$chkDate = '';
$chkMonth = '';
$chkDay = '';
$chkYear = '';
$buf = '';
$numPrntRecs = 0;
$centuryPrefix = '';
$numFirst  = 0;                                  #Primary-sort-exists ctr/flag
$numSecond = 0;                                  #Second-sort exists ctr/flag
$numThird  = 0;                                  #etc...
$name = '';
$value = '';
$resKey = '';
$numCriteria = 0;
$FORMVal = '';
$FORMKey = '';
$resKey = '';
$rKey = '';
$numMatch = '';
$item = '';
$pattern = '';
$string = '';
$resNumItems = '';
$numSorts = '';
$ptr = '';
$ptr1 = '';
$ptr2 = '';
$ptr3 = '';
$fieldType = '';
$fieldType1 = '';
$fieldType2 = '';
$fieldType3 = '';
$retVal = '';
$printItem = '';
$thisRec = '';


#arrays
@pairs = '';
@resData = '';
@dispBuf = '';
@resMatch = '';
@resNum = '';
%resLst = ('','');
%FORM = ('','');
%firstSort  = ('','');
%secondSort = ('','');
%thirdSort  = ('','');
@resTmp = '';


#constants - also see "resChange fields" in global_data.pl.
#
$numDays = 4;
$unused = 18;                                                          #09/16/01
$comments = 20;                                                        #09/15/01
$mode = 0666;                                    #DBM file mode (doesn't work!)
$statePath = $securePath . 'resState';
$changePath = $securePath . 'resChange';
$numResItems = 21;                                                     #09/15/01
$key = 0;                                        #Column 0
$fName = 1;                                      #Column 1

@fieldName = (['unused',''], ['Arv_Day','Arrive Day: '],
              ['Arv_Mnth','Arrive Month: '],
              ['Arv_Year','Arrive Year: $centuryPrefix'],
              ['unused',''], ['Dpt_Day','Depart Day: '],
              ['Dpt_Mnth','Depart Month: '],
              ['Dpt_Year','Depart Year: $centuryPrefix'],
              ['Last_Name','Last Name: '], ['Address','Address: '],
              ['City','City: '], ['State','State: '],
              ['Country','Country: '], ['Zip','ZIP: '], ['Email','Email: '],
              ['Home_Phone','Telephone: '], ['selectBed','Room Type: '],
              ['Res_Num','Reservation Number: '], ['unused',''],
              ['First_Name','First Name: '],
              ['Comments', 'Comments: ']);                             #09/15/01

%fieldNum = ('Arv_Day'    =>  1,
             'Arv_Mnth'   =>  2,
             'Arv_Year'   =>  3,
             'Dpt_Day'    =>  5,
             'Dpt_Mnth'   =>  6,
             'Dpt_Year'   =>  7,
             'lastName'   =>  8,
             'Address'    =>  9,
             'City'       => 10,
             'State'      => 11,
             'Country'    => 12,
             'Zip'        => 13,
             'Email'      => 14,
             'Home_Phone' => 15,
             'selectBed'  => 16,
             'Res_Num'    => 17,
             'firstName'  => 19,
             'comments'   => 20,                                       #09/15/01
            );

%srtAry = (                                      #Hash of sort-value arrays
   '1' => \%firstSort,
   '2' => \%secondSort,
   '3' => \%thirdSort,
);

#Hash %sortPtrs contains pointers to each of the six sort routines.
# $FORM{$nSrt} is either arvDay, dptDay, lastName, firstName,
# roomType, or rNum.  Constants used in the following assignments are
# defined in global_data.pl.
#
%sortPtrs = (                                    #Vals are ptrs to srt routnes.
   $arvDay   => 'date',
   $dptDay   => 'date',
   $lastName  => 'strng',
   $firstName => 'strng',
   $roomType  => 'strng',
   $rNum      => 'num',
   $Zip       => 'num',                                                #09/15/01
);


#begin main processing

#print "Content-Type: text/html\n\n";

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

   $FORM{$name} = $value;                        #Name/value pairs -> hash
#print "<p>FORM{$name} is '$value'</p>";
} #end while/foreach

#################################################50############################8
#
#Get rid of all resState.db records whose stateDate key is < today's date
($dummy1, $dummy2) = &resState_delete;           #Defined in res_utilities_lib.pl
#
#Get rid of all resChange records whose depart-date is < today's date
($dummy1, $dummy2) = &resChange_delete;          #Defined in res_utilities_lib.pl

#Find all reservations (records) that contain values specified in the search
#criteria.  Display the found records.

dbmopen(%resLst, $changePath, $mode);

@resNum = sort (keys(%resLst));

if ($FORM{'display_all'}) {
   foreach $resKey (@resNum) {
      @resData = split (/\|/, $resLst{$resKey});
      for ($i = 0; $i < $numResItems; $i++) {
         $dispBuf[$numPrntRecs][$i] = $resData[$i]; #Save record for sort
      } #end for $i
      $numPrntRecs++}
   #end foreach
}
else {
   #You want to put each incoming search value into a table whose item No.
   #matches the No. of the resData item whose value you're trying to match.
   $numCriteria = 0;
   while (($FORMKey, $FORMVal) = each (%FORM)) {
      if ((exists($fieldNum{$FORMKey})) and ($FORMVal ne '')) {
         $resMatch[$fieldNum{$FORMKey}] = $FORMVal;
         $numCriteria++}
      #end if
   } #end while
   $k = 0;
   $newMatch = $false;
   foreach $rKey (@resNum) {
      $numMatch = 0;
      @resData = split (/\|/, $resLst{$rKey});
      for ($item = 1; $item < $numResItems; $item ++) {
         unless ($resData[$item] eq "") {
            $pattern = lc($resMatch[$item]);
            $strng  = lc($resData[$item]);
            unless ($pattern eq '') {
               if (($strng =~ /$pattern/) ||                           #10/01/01
                   ($strng eq $pattern)) {                             #10/01/01
                  $numMatch++;
                  $newMatch = $true;
                  $resTmp[$k] = $rKey;
               } #endif
            } #end unless
         } #end unless
      } #end for
      if ($newMatch) {
         $k++;
         $newMatch= $false}
      #endif
      if ($numMatch == $numCriteria) {
         for ($i = 0; $i < $numResItems; $i++) {
            $dispBuf[$numPrntRecs][$i] = $resData[$i]} #Save record for sort
         #end for $i
         $numPrntRecs++}
      # endif
   } #end foreach
   @resNum = @resTmp}
#endif

dbmclose(%resLst);

#Don't call main sort routine unless primary sort is specified
#
unless ($FORM{'firstSrt'} =~ /-/) {
   &sort_recs;

   #Now rebuild dispBuf with the same records, but in sorted order.
   #
   $numPrntRecs = 0;
   $resNumItems = @resNum;
   dbmopen(%resLst, $changePath, $mode);
   for ($i = 0; $i < $resNumItems; $i++) {
      @resData = split (/\|/, $resLst{$resNum[$i]});
      for ($j = 0; $j < $numResItems; $j++) {
         $dispBuf[$numPrntRecs][$j] = $resData[$j]} #Save record for display
      #end for $j
      $numPrntRecs++}
   #end for $i

   dbmclose(%resLst)}
#end unless

if ($numPrntRecs > 0) {
   &build_display;                               #Write records to buffer

   close (INFILE);

   #Open link file to output for reading
   #
   open (OUTFILE, "<res_report.txt") || die
                                  "Can't open res_report.txt!\n";
   while (<OUTFILE>) {
      print}
   # end while
   close (OUTFILE)}
else {
   &no_matches}                                  #In res_utilities_html_lib.pl
#endif

exit;



################################################################################
#
#   Name:     sort_recs
#
#   Function: Controls sorting of reservation records.  0 to 3 sorts allowed.
#             Builds array of sort values for each sort.  Associates a pointer
#             for each sort number with its correct input sort-value hash.
#
#   Inputs:   Do-sort flags (1 to 3)
#             Array of reservation numbers as primary sort keys
#             Buffer of all reservation records in resChange database
#             Pointers to hashes of values to be sorted (1 to 3 hashes)
#
#   Outputs:
#
#   Caller:   res_display                 res_display.pl
#
#   Calls:    sort1n                      all calls are in res_display.pl
#             sort1s
#             sort2nn
#             sort2ns
#             sort2sn
#             sort2ss
#             sort3nnn
#             sort3nns
#             sort3nsn
#             sort3nss
#             sort3snn
#             sort3sns
#             sort3ssn
#             sort3sss
#
#                           MODIFICATION                      DATE         BY
#
#   Rodeway Inn  (add first/last names, sort menus)         11/06/98    M. Lewis
#   Tradewinds Resort                                       11/11/98    M. Lewis
#
#
sub sort_recs {

   #Collect like sort criteria into separate arrays -- one array for each sort.
   #
   unless ($FORM{'firstSrt'} =~ /-/) {
      $item = 0;
      foreach $resKey (@resNum) {
         $firstSort{$resKey} = $dispBuf[$item][$FORM{'firstSrt'}];
         $item++;
         $numFirst++}
      #end foreach
   }
   else {
      $numFirst = 0}                             #Use default sort (by res No.).
   #end unless first
   unless ($numFirst == 0) {
      $numSorts = 1}
      $ptr = \%srtAry;
      $ptr1 = $$ptr{1};
   #end unless

   unless ($FORM{"secondSrt"} =~ /-/) {
      $item = 0;
      foreach $resKey (@resNum) {
         $secondSort{$resKey} = $dispBuf[$item][$FORM{'secondSrt'}];
         $item++;
         $numSecond++}
      #end foreach
   }
   else {
      $numSecond = 0}
   #end unless second
   unless ($numSecond == 0) {
      $numSorts = 2}
      $ptr2 = $$ptr{2};
   #end unless

   unless ($FORM{"thirdSrt"} =~ /-/) {
      $item = 0;
      foreach $resKey (@resNum) {
         $thirdSort{$resKey} = $dispBuf[$item][$FORM{'thirdSrt'}];
         $item++;
         $numThird++}
      #end foreach
   }
   else {
      $numThird = 0}
   #end unless third
   unless ($numThird == 0) {
      $numSorts = 3}
      $ptr3 = $$ptr{3};
   #end unless

   if ($numSorts == 1) {
      $fieldType = $sortPtrs{$FORM{"firstSrt"}};
      if (($fieldType eq "date") or ($fieldType eq "num")) {
         &sort1n($fieldType)}
      else {
         &sort1s}
      #endif
   } #endif

   if ($numSorts == 2) {
      $fieldType1 = $sortPtrs{$FORM{"firstSrt"}};
      $fieldType2 = $sortPtrs{$FORM{"secondSrt"}};
      if ((($fieldType1 eq "date") or ($fieldType1 eq "num")) &&
         (($fieldType2 eq "date") or ($fieldType2 eq "num"))) {
         &sort2nn($fieldType1, $fieldType2)}
      elsif ((($fieldType1 eq "date") or ($fieldType1 eq "num")) &&
             ($fieldType2 eq "strng")) {
         &sort2ns($fieldType1)}
      elsif (($fieldType1 eq "strng") &&
             (($fieldType2 eq "date") or ($fieldType2 eq "num"))) {
         &sort2sn($fieldType2)}
      elsif (($fieldType1 eq "strng") &&
             ($fieldType2 eq "strng")) {
         &sort2ss}
      #endif
   } #endif

   if ($numSorts == 3) {
      $fieldType1 = $sortPtrs{$FORM{"firstSrt"}};
      $fieldType2 = $sortPtrs{$FORM{"secondSrt"}};
      $fieldType3 = $sortPtrs{$FORM{"thirdSrt"}};
      if ((($fieldType1 eq "date") or ($fieldType1 eq "num")) &&
          (($fieldType2 eq "date") or ($fieldType2 eq "num")) &&
          (($fieldType3 eq "date") or ($fieldType3 eq "num"))) {
         &sort3nnn($fieldType1, $fieldType2, $fieldType3)}
      elsif ((($fieldType1 eq "date") or ($fieldType1 eq "num")) &&
             (($fieldType2 eq "date") or ($fieldType2 eq "num")) &&
              ($fieldType3 eq "strng")) {
         &sort3nns($fieldType1, $fieldType2)}
      elsif ((($fieldType1 eq "date") or ($fieldType1 eq "num")) &&
             ($fieldType2 eq "strng") &&
             (($fieldType3 eq "date") or ($fieldType3 eq "num"))) {
         &sort3nsn($fieldType1, $fieldType3)}
      elsif ((($fieldType1 eq "date") or ($fieldType1 eq "num")) &&
             ($fieldType2 eq "strng") &&
             ($fieldType3 eq "strng")) {
         &sort3nss($fieldType1)}
      elsif (($fieldType1 eq "strng") &&
             (($fieldType2 eq "date") or ($fieldType2 eq "num")) &&
             (($fieldType3 eq "date") or ($fieldType3 eq "num"))) {
         &sort3snn($fieldType2, $fieldType3)}
      elsif  (($fieldType1 eq "strng") &&
              (($fieldType2 eq "date") or ($fieldType2 eq "num")) &&
              ($fieldType3 eq "strng")) {
         &sort3sns($fieldType2)}
      elsif  (($fieldType1 eq "strng") &&
              ($fieldType2 eq "strng") &&
              (($fieldType3 eq "date") or ($fieldType3 eq "num"))) {
         &sort3ssn($fieldType3)}
      elsif  (($fieldType1 eq "strng") &&
              ($fieldType2 eq "strng") &&
              ($fieldType3 eq "strng")) {
         &sort3sss}
      #endif
   } #endif

   return;
} #end sort_recs


################################################################################
#
#   Name:     sort-sequence preparation routines:
#                  sort1n
#                  sort1s
#                  sort2nn
#                  sort2ns
#                  sort2sn
#                  sort2ss
#                  sort3nnn
#                  sort3nns
#                  sort3nsn
#                  sort3nss
#                  sort3snn
#                  sort3sns
#                  sort3ssn
#                  sort3sss
#
#   Function: Each routine prepares one type of sort sequence.  For example,
#                 sort3nsn prepares a 3rd-order sort whose 1st sort criterion is
#                 a number, 2nd criterion is a string, and 3rd criterion is a
#                 number.  In general:
#                       1,2,3 in a routine name refers to 1st, 2nd, 3rd sorts.
#                       n = numeric compare
#                       s = string compare
#
#   Inputs:   Sort field type: date, string, or number
#             Array of reservation numbers as primary sort keys
#             Buffer of all reservation records in resChange database
#             Pointers to hashes of values to be sorted (1 to 3 hashes)
#
#   Outputs:
#
#   Caller:   sort_recs                     res_display.pl
#
#   Calls:    get_seconds                   all calls are in res_display.pl
#             do_sort1n
#             do_sort1s
#             do_sort2nn
#             do_sort2ns
#             do_sort2sn
#             do_sort2ss
#             do_sort3nnn
#             do_sort3nns
#             do_sort3nsn
#             do_sort3nss
#             do_sort3snn
#             do_sort3sns
#             do_sort3ssn
#             do_sort3sss
#
#  NOTE: a few of these sort prep routines use the "short-circuit" op-
#        erator( || ).  See PC, pp. 117-120 for a description and exam-
#        ples.
#
#                          MODIFICATION                       DATE         BY
#
#   Rodeway Inn  (add first/last names, sort menus)         11/06/98    M. Lewis
#   Tradewinds Resort                                       11/11/98    M. Lewis
#
#
sub sort1n {
   my $fType = shift(@_);
   if ($fType eq 'date') {
      #Replace dates in $$ptr1 fields with dates in sec since 1/1/70
      # for sort comparisons.
      #
      &get_seconds($ptr1, $FORM{'firstSrt'})}
   #endif

   @resNum = sort do_sort1n @resNum;

   return;
} #end sort1n


sub sort1s {

   @resNum = sort do_sort1s @resNum;

   return;
} #end sort1n


sub sort2nn {
   my $fieldType1 = shift(@_);
   my $fieldType2 = shift(@_);

   if ($fieldType1 eq 'date') {
      #Replace dates in $$ptr1 fields with dates in sec since 1/1/70
      # for sort comparisons.
      #
      &get_seconds($ptr1, $FORM{'firstSrt'})}
   #endif

   if ($fieldType2 eq 'date') {
      #Replace dates in $$ptr2 fields with dates in sec since 1/1/70
      # for sort comparisons.
      #
      &get_seconds($ptr2, $FORM{'secondSrt'})}
   #endif

   @resNum = sort do_sort2nn @resNum;

   return;
} #end sort2nn


sub sort2ns {
   my $fieldType1 = shift(@_);

   if ($fieldType1 eq 'date') {
      #Replace dates in $$ptr1 fields with dates in sec since 1/1/70
      # for sort comparisons.
      #
      &get_seconds($ptr1, $FORM{'firstSrt'})}
   #endif

   @resNum = sort do_sort2ns @resNum;

   return;
} #end sort2ns


sub sort2sn {
   my $fieldType2 = shift(@_);

   if ($fieldType2 eq 'date') {
      #Replace dates in $$ptr2 fields with dates in sec since 1/1/70
      # for sort comparisons.
      #
      &get_seconds($ptr2, $FORM{'secondSrt'})}
   #endif

   @resNum = sort do_sort2sn @resNum;

   return;
} #end sort2ns


sub sort2ss {

   @resNum = sort {
                 lc($$ptr1{$a}) cmp lc($$ptr1{$b})
                                        ||
                 lc($$ptr2{$a}) cmp lc($$ptr2{$b}) }  @resNum;

   return;
} #end sort2ss


sub sort3nnn {
   my $fieldType1 = shift(@_);
   my $fieldType2 = shift(@_);
   my $fieldType3 = shift(@_);

   if ($fieldType1 eq 'date') {
      #Replace dates in $$ptr1 fields with dates in sec since 1/1/70
      # for sort comparisons.
      #
      &get_seconds($ptr1, $FORM{'firstSrt'})}
   #endif

   if ($fieldType2 eq 'date') {
      #Replace dates in $$ptr2 fields with dates in sec since 1/1/70
      # for sort comparisons.
      #
      &get_seconds($ptr2, $FORM{'secondSrt'})}
   #endif

   if ($fieldType3 eq 'date') {
      #Replace dates in $$ptr3 fields with dates in sec since 1/1/70
      # for sort comparisons.
      #
      &get_seconds($ptr3, $FORM{'thirdSrt'})}
   #endif

   @resNum = sort do_sort3nnn @resNum;

   return;
} #end sort3nnn


sub sort3nsn {
   my $fieldType1 = shift(@_);
   my $fieldType3 = shift(@_);

   if ($fieldType1 eq 'date') {
      #Replace dates in $$ptr1 fields with dates in sec since 1/1/70
      # for sort comparisons.
      #
      &get_seconds($ptr1, $FORM{'firstSrt'})}
   #endif

   if ($fieldType3 eq 'date') {
      #Replace dates in $$ptr3 fields with dates in sec since 1/1/70
      # for sort comparisons.
      #
      &get_seconds($ptr3, $FORM{'thirdSrt'})}
   #endif

   @resNum = sort do_sort3nsn @resNum;

   return;
} #end sort3nsn


sub sort3nns {
   my $fieldType1 = shift(@_);
   my $fieldType2 = shift(@_);

   if ($fieldType1 eq 'date') {
      #Replace dates in $$ptr1 fields with dates in sec since 1/1/70
      # for sort comparisons.
      #
      &get_seconds($ptr1, $FORM{'firstSrt'})}
   #endif

   if ($fieldType2 eq 'date') {
      #Replace dates in $$ptr2 fields with dates in sec since 1/1/70
      # for sort comparisons.
      #
      &get_seconds($ptr2, $FORM{'secondSrt'})}
   #endif

   @resNum = sort do_sort3nns @resNum;

   return;
} #end sort3nns


sub sort3nss {
   my $fieldType1 = shift(@_);

   if ($fieldType1 eq 'date') {
      #Replace dates in $$ptr1 fields with dates in sec since 1/1/70
      # for sort comparisons.
      #
      &get_seconds($ptr1, $FORM{'firstSrt'})}
   #endif

   @resNum = sort do_sort3nss @resNum;

   return;
} #end sort3nss


sub sort3snn {
   my $fieldType2 = shift(@_);
   my $fieldType3 = shift(@_);

   if ($fieldType2 eq 'date') {
      #Replace dates in $$ptr2 fields with dates in sec since 1/1/70
      # for sort comparisons.
      #
      &get_seconds($ptr2, $FORM{'secondSrt'})}
   #endif

   if ($fieldType3 eq 'date') {
      #Replace dates in $$ptr3 fields with dates in sec since 1/1/70
      # for sort comparisons.
      #
      &get_seconds($ptr3, $FORM{'thirdSrt'})}
   #endif

   @resNum = sort do_sort3snn @resNum;

   return;
} #end sort3snn


sub sort3sns {
   my $fieldType2 = shift(@_);

   if ($fieldType2 eq 'date') {
      #Replace dates in $$ptr2 fields with dates in sec since 1/1/70
      # for sort comparisons.
      #
      &get_seconds($ptr2, $FORM{'secondSrt'})}
   #endif

   @resNum = sort do_sort3sns @resNum;

   return;
} #end sort3sns


sub sort3ssn {
   my $fieldType3 = shift(@_);

   if ($fieldType3 eq 'date') {
      #Replace dates in $$ptr3 fields with dates in sec since 1/1/70
      # for sort comparisons.
      #
      &get_seconds($ptr3, $FORM{'thirdSrt'})}
   #endif

   @resNum = sort do_sort3ssn @resNum;

   return;
} #end sort3ssn


sub sort3sss {

   @resNum = sort {
                        lc($$ptr1{$a}) cmp lc($$ptr1{$b})
                                ||
                        lc($$ptr2{$a}) cmp lc($$ptr2{$b})
                                ||
                        lc($$ptr3{$a}) cmp lc($$ptr3{$b}) }  @resNum;

   return;
} #end sort3sss


################################################################################
#
#   Name:     Comparison routines:
#                                               do_sort1n
#                                               do_sort1s
#                                               do_sort2nn
#                                               do_sort2ns
#                                               do_sort2sn
#                                               do_sort2ss
#                                               do_sort3nnn
#                                               do_sort3nns
#                                               do_sort3nsn
#                                               do_sort3nss
#                                               do_sort3snn
#                                               do_sort3sns
#                                               do_sort3ssn
#                                               do_sort3sss
#
#                 NOTE: a most of these comparison routines use the "short-circuit" op-
#                             erator( || ).  See PC, pp. 117-120 for its description and exam-
#                             ples.
#
#   Function: Each routine prepares one sequence of sort comparison(s).  For
#                         example, sort3nsn performs a 3rd-order sort whose 1st compari-
#                         son is numeric, 2nd comparison isstring, and 3rd criterion is
#                         numeric.  In general:
#                                 1,2,3 in a routine name refers to 1st, 2nd, 3rd sorts.
#                                 n = numeric compare (<=>)
#                                 s = string compare  (cmp)
#
#   Inputs:   Two comparison values for each compare (1 to 3 compares)
#
#   Outputs:  -1 = first values sorts before second
#                          0 = both values are equal
#                          1 = second value sorts before first
#
#   Caller:   sort-preparation routines                     res_display.pl
#
#   Calls:    lc function
#
#                                  MODIFICATION                                                         DATE                BY
#
#   Rodeway Inn  (add first/last names, sort menus)         11/06/98    M. Lewis
#   Tradewinds Resort                                                                 11/11/98    M. Lewis
#
#
sub do_sort1n {
   $retVal = $$ptr1{$a} <=> $$ptr1{$b}
} #end do_sort1n


sub do_sort1s {
   $retVal = lc($$ptr1{$a}) cmp lc($$ptr1{$b})
} #end do_sort1s


sub do_sort2nn {
   $retVal = $$ptr1{$a} <=> $$ptr1{$b}
                                ||
                 $$ptr2{$a} <=> $$ptr2{$b}
} #end do_sort2nn


sub do_sort2ns {
   $retVal = $$ptr1{$a} <=> $$ptr1{$b}
                                ||
             lc($$ptr2{$a}) cmp lc($$ptr2{$b})
} #end do_sort2ns


sub do_sort2sn {
   $retVal = lc($$ptr1{$a}) cmp lc($$ptr1{$b})
                                ||
                 $$ptr2{$a} <=> $$ptr2{$b}
} #end do_sort2sn


sub do_sort3nnn {
   $retVal = $$ptr1{$a} <=> $$ptr1{$b}
                                ||
                 $$ptr2{$a} <=> $$ptr2{$b}
                                ||
                 $$ptr3{$a} <=> $$ptr3{$b}
} #end do_sort3nnn


sub do_sort3nns {
   $retVal = $$ptr1{$a} <=> $$ptr1{$b}
                                ||
                 $$ptr2{$a} <=> $$ptr2{$b}
                                ||
                 lc($$ptr3{$a}) cmp lc($$ptr3{$b})
} #end do_sort3nns


sub do_sort3nsn {
   $retVal = $$ptr1{$a} <=> $$ptr1{$b}
                                ||
                 lc($$ptr2{$a}) cmp lc($$ptr2{$b})
                                ||
                 $$ptr3{$a} <=> $$ptr3{$b}
} #end do_sort3nsn


sub do_sort3nss {
   $retVal = $$ptr1{$a} <=> $$ptr1{$b}
                                ||
                 lc($$ptr2{$a}) cmp lc($$ptr2{$b})
                                ||
                 lc($$ptr3{$a}) cmp lc($$ptr3{$b})
} #end do_sort3nss


sub do_sort3snn {
   $retVal = lc($$ptr1{$a}) cmp lc($$ptr1{$b})
                                ||
                 $$ptr2{$a} <=> $$ptr2{$b}
                                ||
                 $$ptr3{$a} <=> $$ptr3{$b}
} #end do_sort3snn


sub do_sort3sns {
   $retVal = lc($$ptr1{$a}) cmp lc($$ptr1{$b})
                                ||
                 $$ptr2{$a} <=> $$ptr2{$b}
                                ||
                 lc($$ptr3{$a}) cmp lc($$ptr3{$b})
} #end do_sort3sns


sub do_sort3ssn {
   $retVal = lc($$ptr1{$a}) cmp lc($$ptr1{$b})
                                ||
                 lc($$ptr2{$a}) cmp lc($$ptr2{$b})
                                ||
                 $$ptr3{$a} <=> $$ptr3{$b}
} #end do_sort3ssn


################################################################################
#
#   Name:     get_seconds:
#
#   Function: Converts an input date (arrive/depart) in form mmm-dd-yy
#                         to No. seconds since 1/1/70
#
#   Inputs:   mmm, dd, yy
#                         Date type (arrive or depart)
#
#   Outputs:  Date as integer No. of seconds since 1/1/70
#
#   Caller:   sort-preparation routines                     res_display.pl
#
#   Calls:    timelocal                                     Perl standard library
#
#                                MODIFICATION                                                             DATE              BY
#
#   Rodeway Inn  (add first/last names, sort menus)         11/06/98    M. Lewis
#
#
sub get_seconds {
   my $srtAry = shift(@_);
   my $dateType = shift(@_);
   my $month = '';
   my $item = 0;
   foreach $resKey (@resNum) {
      #Set $month to value in either $dispBuf[$item][arrive month] or
      # $dispBuf[$item][depart month], depending on input parameter.
      # $month is integer 0 - 11.
      #
      $month = ($ordMonth{$dispBuf[$item][$dateType+1]} - 1);

      #Get date in seconds since 1/1/70 (%ptr2 defined in caller).
      #
      $$srtAry{$resKey} = timelocal(0, 0, 0, $dispBuf[$item][$dateType],
                               $month, $dispBuf[$item][$dateType+2]);
      $item++}
   #end foreach
} #end get_seconds


################################################################################
#
#   Name:     build_display:
#
#   Function: Creates display buffer of all reservation records to be displayed.
#
#   Inputs:   array of records to be prepared for display
#
#   Outputs:  display buffer to screen
#
#   Caller:   res_display                                                     res_display.pl
#
#   Calls:
#
#                                 MODIFICATION                                                          DATE                BY
#
#   Rodeway Inn  (add first/last names, sort menus)         11/06/98    M. Lewis
#   Tradewinds Resort                                                                 11/11/98    M. Lewis
# Automated system update                                   09/04/00    M. Lewis
#
sub build_display {

   my $roomType = 0;                             #Index into room-type field of
                                                 # roomDef hash.
   my @roomRec = '';                             #Local table for roomDef hash.

   # Open link file to output for writing
   open (INFILE, ">res_report.txt") || die
      "Can't open res_report.txt!\n";

   print "Content-type: text/plain\n\n";

print INFILE <<end_of_html;


     ****************************************
     *  ONLINE RESERVATIONS SEARCH RESULTS  *
     ****************************************


   Your search criteria have retrieved the following Online
   Reservation System records:

end_of_html

   for ($thisRec = 0; $thisRec < $numPrntRecs; $thisRec++) {

      $printItem = $thisRec + 1;
      print INFILE "\n$printItem.\n";            #No. of the current record

      #This block displays print items 1, 2, and 3 on one output line in form
      # DD MMM YYYY
      $buf = '   Arrive Date:';
      for ($printItem = 1; $printItem < 5; $printItem++) {
         if ($printItem == 4) {next}
         else {
            if ($printItem == 3) {

                           #If true, 21st century
               #
               if ($dispBuf[$thisRec][$printItem] < 10) {
                  $centuryPrefix = 20}
               else {                            #20th century
                  $centuryPrefix = 19}
               #endif
               $buf .= ' ' . $centuryPrefix;
               $buf .= $dispBuf[$thisRec][$printItem]}
            else {
               $buf .= " " . $dispBuf[$thisRec][$printItem]}
            #endif
         } #endif
      } #end for
      print INFILE "$buf\n";

      #This block displays print items 5, 6, and 7 on one output line in form
      # DD MMM YYYY
      $buf = '   Depart Date:';
      for ($printItem=5; $printItem<8; $printItem ++) {
         if ($printItem == 7) {
            if ($dispBuf[$thisRec][$printItem] < 10) {
                     #If true, 21st century
                           #
               $centuryPrefix = 20}
            else {                               #20th century
               $centuryPrefix = 19}
            #endif
            $buf .= ' ' . $centuryPrefix;
            $buf .= $dispBuf[$thisRec][$printItem]}
         else {
            $buf .= " " . $dispBuf[$thisRec][$printItem]}
         #endif
      } #end for (printItem=5
      print INFILE "$buf\n";

      #This block displays the rest of the print items, one per line
      #
      for ($printItem = 8; $printItem < $numResItems; $printItem++) {  #09/16/01
         if ($printItem == $lastName) {
            print INFILE
               "   Name: $dispBuf[$thisRec][$firstName] $dispBuf[$thisRec][$printItem]\n"}
         elsif ($printItem == $roomType) {                             #09/19/01

            print INFILE
               "   $fieldName[$printItem][$fName]$roomRec[$roomType]\n";#9/19/01
         }
         elsif ($printItem == $firstName) {
            next}
         elsif ($printItem == $unused) {         #Null item, skip.     #09/16/01
            next}                                                      #09/16/01
         else {
            print INFILE
               "   $fieldName[$printItem][$fName]$dispBuf[$thisRec][$printItem]\n"}
         #endif
      } #end for
   } #end for ($i
} #end build_display

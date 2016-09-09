#!/usr/bin/perl
require('global_data.pl');
require('res_lib.pl');


################################################################################
#
#   Name:     res_form
#
#   Function: generates form that prompts user to enter lodging preferences
#
#   Inputs:
#
#   Outputs:  arrive month
#             arrive day
#             arrive year
#             depart month
#             depart day
#             depart year
#             No. adults
#             No. children
#             bed type
#             smoking preference
#             handicapped access preference                    #             pets preference
#             rollaway bed request
#             vacation-package choice
#
#   Caller:
#
#   Calls:    initial_dates                      res_lib.pl    #
#                     MODIFICATION                            DATE       BY
#
#   Harvey's Hotel/Casino                                   03/01/98   M. Lewis
#   Lakeside Inn                                            03/12/98   M. Lewis
#   Stateline Lodge  (remove Spring Fling, add M.S. Dixie)  06/13/98   M. Lewis
#   Rodeway Inn                                             09/11/98   M. Lewis
#   (add changes for autoconfig system)                     01/02/99   M. Lewis
# Removed <FORM METHOD="POST" ACTION="$completePath">         12/19/99   M. Lewis
# Remove centuryprefixes from initial_dates call            07/23/00   M. Lewis
# Replaced reshead.jpeg reference with $jpeg1url             08/11/00   M. Lewis
#

print "Content-Type: text/html\n\n";

#Get initial arrive/depart dates
($arriveDay, $arriveMnth, $arriveMnthVal, $arriveYear,
 $departDay, $departMnth, $departMnthVal, $departYear,
) = &initial_dates;

$arriveYear -= 100;                              #Need 0 <= year < 100 #07/23/00
if ($arriveYear < 10) {                                                #07/23/00
  $arriveYear = '0' . $arriveYear}                                     #07/23/00
#endif                                                                 #07/21/00

$departYear -= 100;                              #Need 0 <= year < 100 #07/23/00
if ($departYear < 10) {                                                #07/23/00
  $departYear = '0' . $departYear}                                     #07/23/00
#endif                                                                 #07/21/00

print <<end_of_html;
   <HEAD>
     <TITLE>$form_title</TITLE>
   </HEAD>
   <BODY>

   <!--
##HOOK: BEGIN PATHS
   -->

<!--
<FORM METHOD="POST" ACTION="res_main.pl">
-->

<FORM METHOD="POST" ACTION="http://reservit.sourceforge.net/cgi-bin/res_main.pl">

<!--
##HOOK: END PATHS
   -->


   <ENCTYPE="x-www-form-urlencoded">

   <P>
   <INPUT TYPE="hidden" NAME="return_link_url" VALUE="http://tahoemall.com/">
   <INPUT TYPE="hidden" NAME="return_link_title"
    VALUE="Go Back to the Home Page">
   </P>

   <P><CENTER><B><FONT COLOR="#0000ff" SIZE=+1>Thank you</FONT> for choosing
   <BR>
   </B></CENTER></P>

   <P><CENTER><B><IMG SRC="$jpeg1url" WIDTH="210" HEIGHT=
   "120"><P>To check the availability of a room,<BR>
   please use the form below.</B></CENTER></P>

   <P><CENTER>&nbsp;</CENTER></P>
   <BR CLEAR="ALL">
   <P><CENTER><BR CLEAR="ALL"><TABLE WIDTH="450" HEIGHT="150" BORDER="1"
    CELLSPACING="2" CELLPADDING="0">
   <TR>
   <TD WIDTH="33%" VALIGN="BOTTOM" HEIGHT="75">&nbsp;<B>Arrival:<BR></B>
   <SELECT NAME="arrive_month">
   <OPTION SELECTED VALUE=$arriveMnthVal>$arriveMnth
   <OPTION VALUE="Jan">January
   <OPTION VALUE="Feb">February
   <OPTION VALUE="Mar">March
   <OPTION VALUE="Apr">April
   <OPTION VALUE="May">May
   <OPTION VALUE="Jun">June
   <OPTION VALUE="Jul">July
   <OPTION VALUE="Aug">August
   <OPTION VALUE="Sep">September
   <OPTION VALUE="Oct">October
   <OPTION VALUE="Nov">November
   <OPTION VALUE="Dec">December
   </SELECT> </TD>
   <TD WIDTH="33%" VALIGN="BOTTOM">&nbsp;<SELECT NAME="arrive_day">
   <OPTION SELECTED>$arriveDay
   <OPTION VALUE="1">1
   <OPTION VALUE="2">2
   <OPTION VALUE="3">3
   <OPTION VALUE="4">4
   <OPTION VALUE="5">5
   <OPTION VALUE="6">6
   <OPTION VALUE="7">7
   <OPTION VALUE="8">8
   <OPTION VALUE="9">9
   <OPTION VALUE="10">10
   <OPTION VALUE="11">11
   <OPTION VALUE="12">12
   <OPTION VALUE="13">13
   <OPTION VALUE="14">14
   <OPTION VALUE="15">15
   <OPTION VALUE="16">16
    <OPTION VALUE="17">17
   <OPTION VALUE="18">18
   <OPTION VALUE="19">19
   <OPTION VALUE="20">20
   <OPTION VALUE="21">21
   <OPTION VALUE="22">22
   <OPTION VALUE="23">23
   <OPTION VALUE="24">24
   <OPTION VALUE="25">25
   <OPTION VALUE="26">26
   <OPTION VALUE="27">27
   <OPTION VALUE="28">28
   <OPTION VALUE="29">29
   <OPTION VALUE="30">30
   <OPTION VALUE="31">31
   </SELECT> </TD>

   <TD WIDTH="34%" VALIGN="BOTTOM">&nbsp;<SELECT NAME="arrive_year">
   <OPTION SELECTED VALUE="$arriveYear">20$arriveYear
   <!--
##HOOK: BEGIN ARRIVE YEAR
   -->
<OPTION VALUE="03">2003
<OPTION VALUE="04">2004
<OPTION VALUE="05">2005
<OPTION VALUE="06">2006
<OPTION VALUE="07">2007
<OPTION VALUE="08">2008
   <!--
##HOOK: END ARRIVE YEAR
          -->
   </SELECT></TD></TR>
   <TR>
   <TD WIDTH="33%" VALIGN="BOTTOM" HEIGHT="75">&nbsp;<B>Departure:
   </B><SELECT NAME="depart_month">
   <OPTION SELECTED VALUE=$departMnthVal>$departMnth
   <OPTION VALUE="Jan">January
   <OPTION VALUE="Feb">February
   <OPTION VALUE="Mar">March
   <OPTION VALUE="Apr">April
   <OPTION VALUE="May">May
    <OPTION VALUE="Jun">June
   <OPTION VALUE="Jul">July
   <OPTION VALUE="Aug">August
   <OPTION VALUE="Sep">September
   <OPTION VALUE="Oct">October
   <OPTION VALUE="Nov">November
   <OPTION VALUE="Dec">December
   </SELECT> </TD>
   <TD WIDTH="33%" VALIGN="BOTTOM">&nbsp;<SELECT NAME="depart_day">
   <OPTION SELECTED>$departDay
   <OPTION VALUE="1">1
   <OPTION VALUE="2">2
   <OPTION VALUE="3">3
   <OPTION VALUE="4">4
   <OPTION VALUE="5">5
   <OPTION VALUE="6">6
   <OPTION VALUE="7">7
   <OPTION VALUE="8">8
   <OPTION VALUE="9">9
   <OPTION VALUE="10">10
   <OPTION VALUE="11">11
   <OPTION VALUE="12">12
   <OPTION VALUE="13">13
   <OPTION VALUE="14">14
   <OPTION VALUE="15">15
   <OPTION VALUE="16">16
   <OPTION VALUE="17">17
   <OPTION VALUE="18">18
   <OPTION VALUE="19">19
   <OPTION VALUE="20">20
   <OPTION VALUE="21">21
   <OPTION VALUE="22">22
   <OPTION VALUE="23">23
   <OPTION VALUE="24">24
   <OPTION VALUE="25">25
   <OPTION VALUE="26">26
   <OPTION VALUE="27">27
   <OPTION VALUE="28">28
   <OPTION VALUE="29">29
   <OPTION VALUE="30">30
   <OPTION VALUE="31">31
   </SELECT> </TD>
   <TD WIDTH="34%" VALIGN="BOTTOM">&nbsp;<SELECT NAME="depart_year">
   <OPTION SELECTED VALUE="$departYear">20$departYear
   <!--
##HOOK: BEGIN DEPART YEAR
   -->
<OPTION VALUE="03">2003
<OPTION VALUE="04">2004
<OPTION VALUE="05">2005
<OPTION VALUE="06">2006
<OPTION VALUE="07">2007
<OPTION VALUE="08">2008
   <!--
##HOOK: END DEPART YEAR
          -->
   </SELECT></TD></TR>
   </TABLE>
   <TABLE WIDTH="450" HEIGHT="75" BORDER="1" CELLSPACING="2" CELLPADDING="0">
   <TR>
   <TD WIDTH="100%" HEIGHT="75" ALIGN="CENTER">
   <B>&nbsp;Number of guests (adults and children):</B><BR>
   <SELECT NAME="Person_Cnt">
   <!--
##HOOK: BEGIN SELECT GUESTS
   -->
<OPTION VALUE="1" SELECTED>1
<OPTION VALUE="2">2
<OPTION VALUE="3">3
   <!--
##HOOK: END SELECT GUESTS
         -->
   </SELECT></TD></TR>
   </TABLE>
   </CENTER>


   <P><CENTER>
   <SELECT NAME="select_bed">
   <OPTION SELECTED>Choose your accommodations
   <!--
##HOOK: BEGIN CREATE ROOMS MENU
   -->
 <OPTION VALUE="KS00110">Single King, Refrigerator, Microwave, (Smoking Allowed)
<OPTION VALUE="QNS00110">Single Queen, Refrigerator, Microwave, (No Smoking)
<OPTION VALUE="QS00110">Single Queen, Refrigerator, Microwave, (Smoking Allowed)
<OPTION VALUE="KNS00110">Single King, Refrigerator, Microwave, (No Smoking)
   <!--
##HOOK: END CREATE ROOMS MENU
         -->
   </SELECT></CENTER></P>

   <!--
##HOOK: BEGIN CREATE ATTRIBUTES
   -->
<P><CENTER>Select room preferences from items below:</P>
<P><CENTER>Rollaway bed needed
<INPUT TYPE="radio" VALUE="0" NAME="rollaway" CHECKED>No
<INPUT TYPE="radio" VALUE="1" NAME="rollaway">Yes</CENTER></P>
<P><CENTER>Pets allowed in room
<INPUT TYPE="radio" VALUE="0" NAME="pet" CHECKED>No
<INPUT TYPE="radio" VALUE="1" NAME="pet">Yes</CENTER></P>
   <!--
##HOOK: END CREATE ATTRIBUTES
         -->

   <P><TT><FONT COLOR="#400000"><pre>
             Multiple room reservations cannot be made with this form. If you wish to
             reserve more than one accommodation, reset the form or reload the page and
             submit it again.</FONT></TT><HR></P>

   <PRE><CENTER>  <INPUT TYPE="submit" VALUE="Click here to check Availability/Rates">

   <INPUT TYPE="reset" VALUE="Reset this Form"></CENTER></PRE>
   </FORM>

   <!--
##HOOK: BEGIN CREATE COUNTER
   -->
  <P><IMG SRC="/cgi-sys/Count.cgi?df=tm123-SourceForgeInn_res_sys.cnt">
   <!--
##HOOK: END CREATE COUNTER
         -->

   </BODY>
   </HTML>

end_of_html

exit;


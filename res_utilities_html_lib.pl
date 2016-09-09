#!/usr/bin/perl
require('global_data.pl');
require('res_lib.pl');


################################################################################
#
#   Name:     passwd_form
#
#   Function: generates form that allows user to select a password-utility
#             function.
#
#   Inputs:
#
#   Outputs:

#   Caller:   res_utilities2.pl
#
#   Calls:    passwd_utilities.pl
#
#
#               MODIFICATION                                   DATE        BY
#
#                                                            06/19/99   M. Lewis
# Add hooks for dynamic path assignments.                    08/22/00   M. Lewis
#
sub passwd_form {

  my $actionFile = $openUrl . 'passwd_utilities.pl';

print "Content-Type: text/html\n\n";

print <<end_of_html;

<HTML>

<HEAD>

<script language="JavaScript">

<!-- //hide script from old browsers
var passWdMsg =
  "You must enter a system privileges password to use these utilities";
var oldPswd;

// Use this function to save a cookie.
function setCookie(name, value, expires) {
document.cookie = name + "=" + escape(value) + "; path=/" +
((expires == null) ? "" : "; expires=" + expires.toGMTString());
}

function makeCookie() {
var exp = new Date();                     // make new date object
exp.setTime(exp.getTime() + (1000 * 60 * 60 * 24 * 31)); // set it 31
                                                         // days ahead
setCookie("sysxwd", "true", exp);         // save the cookie
return true;
}

function chk_submit(passwd, oldPW)
{
   if (passwd.value == "") {
      alert(passWdMsg);
      return false}
   else {
      if (passwd.value != oldPW) {
         alert("Please reenter password");
         passwd.value = "";
         return false}
      else {
         makeCookie();
         return true}
      //endif
   }//endif
} //end chk_submit

//end hide script -->
</script>

  <TITLE>$form_title: Password Utilities</TITLE>
</HEAD>

<BODY>

   <!--
##HOOK: BEGIN PASSWD_FORM PATHS                                        #08/12/00
   -->

<!--
<FORM METHOD="POST" ACTION="passwd_utilities.pl"
onSubmit = "return chk_submit(sysxwd, oldPswd)">
-->

<FORM METHOD="POST" ACTION="http://reservit.sourceforge.net/cgi-bin/passwd_utilities.pl">
<!--onSubmit = "return chk_submit(sysxwd, oldPswd)"> -->

<!--
##HOOK: END PASSWD_FORM PATHS                                          #08/12/00
   -->

<ENCTYPE="x-www-form-urlencoded">
<INPUT TYPE="hidden" NAME="return_link_title" VALUE="Go Back to the Home Page">
</P>

<P><CENTER><FONT SIZE=+2><b>$form_title: Password Utilities</CENTER>
<br><br></p>

<P><CENTER><B><BR>
<BR>
</B><TABLE WIDTH="81%" BORDER="1" CELLSPACING="2" CELLPADDING="0">
<TR>
<TD WIDTH="33%"><P>&nbsp;<B><INPUT TYPE="radio" VALUE="change" NAME="password"
CHECKED>Change Existing Password</B></TD>
<TD WIDTH="33%"><P>&nbsp;<B><INPUT TYPE="radio" VALUE="add_new" NAME="password">
Add New User</B></TD>
<TD WIDTH="34%"><P>&nbsp;<B><INPUT TYPE="radio" VALUE="delete" NAME="password">
Delete User </B></TD>
</TR>
</TABLE>
</CENTER></P>

<P><CENTER><FONT SIZE=+1><B>Enter password: </B><INPUT TYPE="password" NAME="sysxwd" SIZE="20"
MAXLENGTH="20" onFocus="sysxwd.value=''"; onBlur="oldPswd=sysxwd.value";></CENTER></P>

<PRE><CENTER>
  <INPUT TYPE="submit" VALUE="Select Password Utility">

  <INPUT TYPE="reset" VALUE="Clear this Form">
</CENTER></PRE><BR><BR><BR>
</FORM>

</BODY>
</HTML>
end_of_html

return;                                                                #11/19/00

} #end passwd_form


################################################################################
#
#   Name:     hotel_res_form
#
#   Function: generates form that prompts hotel staff to enter lodging
#             preferences
#
#   Inputs:   password
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
#             handicapped access preference
#             pets preference
#             rollaway bed request
#
#   Caller:   res_utilities2.pl
#
#   Calls:    res_main.pl
#             initial_dates                      res_lib.pl
#
#   NOTE: Do not move the code for this subroutine.  write_res_        #10/08/00
#         utilities_html_lib.pl contains code that makes use of this   #10/08/00
#         subroutine's position within the res_utilities_html_lib.pl   #10/08/00
#         file.                                                        #10/08/00
#
#                                  MODIFICATION                                                          DATE               BY
#
#   Harvey's Hotel/Casino                                    03/01/98   M. Lewis
#   Lakeside Inn                                                         04/12/98   M. Lewis
#   Lakeside Inn                                                         05/08/98   M. Lewis
#   Stateline Lodge  (remove Spring Fling, add M.S. Dixie)   06/13/98   M. Lewis
#   Rodeway Inn                                              09/15/98   M. Lewis
# Add hooks for dynamic path assignments.                    08/22/00   M. Lewis
# Use res_form.pl as model for general changes to this       08/12/00   M. Lewis
#
sub hotel_res_form {
   #
   #############################################################################
   #Begin comments at col 50, end at 80:         50                            80

  my $passWord = shift(@_);
  my $passWordForm = $openHtml . "res_utilities.pl";

  #Get initial arrive/depart dates                                     #08/12/00
  ($arriveDay, $arriveMnth, $arriveMnthVal, $arriveYear,               #08/12/00
   $departDay, $departMnth, $departMnthVal, $departYear,               #08/12/00
  ) = &initial_dates;                                                  #08/12/00

  $arriveYear -= 100;                            #Need 0 <= year < 100 #08/12/00
  if ($arriveYear < 10) {                                              #08/12/00
    $arriveYear = '0' . $arriveYear}                                   #08/12/00
  #endif                                                               #08/12/00

  $departYear -= 100;                            #Need 0 <= year < 100 #08/12/00
  if ($departYear < 10) {                                              #08/12/00
    $departYear = '0' . $departYear}                                   #08/12/00
  #endif                                                               #08/12/00

  print "Content-Type: text/html\n\n";

print <<end_of_html;

<HTML>

<HEAD>

<script language="JavaScript">

<!-- //hide script from old browsers

// Use this function to retrieve a cookie.
function getCookie(name){
   var cname = name + "=";
   var dc = document.cookie;

   if (dc.length > 0) {
      begin = dc.indexOf(cname);                 //Get starting pos of name
      if (begin != -1) {
         begin += cname.length;
         end = dc.indexOf(";", begin);           //Start at begin and return
         if (end == -1) {                        // pos of first ; encountered
            end = dc.length;
            return unescape(dc.substring(begin, end))}
         //endif
      }//endif
   }
   else {
      alert("You must reenter your password\\nto process this reservation");
      return false}
   //endif
}//end getCookie

// Use this function to delete a cookie.  Deletion is automatic when expiration
// date is set to anytime before current time.
function delCookie(name) {
document.cookie = name + "=; expires=Thu, 01-Jan-70 00:00:01 GMT" + "; path=/";
return null;
}

function chkStatus(name) {

   if (getCookie(name)) {
      delCookie(name)}                          //If cookie exists, delete it
                                                // to force user to reenter
                                                // password next time
   else {
      return false}                             //No cookie means user didn't
   //endif                                      // enter password, get out.

} //end chkStatus

//end hide script -->
</script>

  <META NAME="GENERATOR" CONTENT="Adobe PageMill 2.0 Win">
  <TITLE>$form_title: Hotel Staff Reservation Form</TITLE>
</HEAD>

<BODY BGCOLOR="#ffffff">

   <!--
##HOOK: BEGIN HOTEL_RES_FORM PATHS                                     #08/12/00
   -->

<!--
<FORM METHOD="POST" ACTION="res_main.pl"
onSubmit = "return chkStatus($passWord)">
-->

<FORM METHOD="POST" ACTION="http://reservit.sourceforge.net/cgi-bin/res_main.pl"
onSubmit = "return chkStatus($passWord)">

<!--
##HOOK: END HOTEL_RES_FORM PATHS                                       #08/12/00
   -->

<ENCTYPE="x-www-form-urlencoded">

<P>
<INPUT TYPE="hidden" NAME="return_link_url" VALUE="http://tahoemall.com/">
<INPUT TYPE="hidden" NAME="return_link_title" VALUE="Go Back to the Home Page">
<INPUT TYPE="hidden" NAME="bgcolor" VALUE="#FFFFFF">
<INPUT TYPE="hidden" NAME="text_color" VALUE="#FFOOOO">
<INPUT TYPE="hidden" NAME="link_color" VALUE="#OOOOOO">
<INPUT TYPE="hidden" NAME="passwd" VALUE=$passWord>
</P>

<P><B><CENTER><H2>$form_title: Hotel Staff Reservation Form<BR><BR>
Complete the fields below to check the availability of an accommodation.</H2>
</B></CENTER></P>

<P><CENTER>&nbsp;</CENTER></P>
<BR CLEAR="ALL">
<P><CENTER><BR CLEAR="ALL"><TABLE WIDTH="450" HEIGHT="150" BORDER="1" CELLSPACING=
"2" CELLPADDING="0">
<TR>
<TD WIDTH="33%" VALIGN="BOTTOM" HEIGHT="75">&nbsp;<B>Arrival:<BR></B>
<SELECT NAME="arrive_month">
>
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
<TD WIDTH="33%" VALIGN="BOTTOM">&nbsp;
<SELECT NAME="arrive_day">
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
<TD WIDTH="34%" VALIGN="BOTTOM">&nbsp;
<SELECT NAME="arrive_year">
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
<TD WIDTH="33%" VALIGN="BOTTOM" HEIGHT="75">&nbsp;<B>Departure: </B>
<SELECT NAME="depart_month">
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
</SELECT></TD>
<TD WIDTH="33%" VALIGN="BOTTOM">&nbsp;
<SELECT NAME="depart_day">
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
<TD WIDTH="34%" VALIGN="BOTTOM">&nbsp;
<SELECT NAME="depart_year">
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
   <!-- 09/17/01
##HOOK: BEGIN CREATE RES_FORM ROOMS MENU
   -->
<OPTION VALUE="KS00110">Single King, Refrigerator, Microwave, (Smoking Allowed)
<OPTION VALUE="QNS00110">Single Queen, Refrigerator, Microwave, (No Smoking)
<OPTION VALUE="QS00110">Single Queen, Refrigerator, Microwave, (Smoking Allowed)
<OPTION VALUE="KNS00110">Single King, Refrigerator, Microwave, (No Smoking)
<!--
##HOOK: END CREATE RES_FORM ROOMS MENU
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
             Multiple room reservations cannot be made with this form. To
             reserve more than one accommodation, reset the form or reload the page and use it
             again.</FONT></TT><HR></P>

<PRE><CENTER>  <INPUT TYPE="submit" VALUE="Click here to check availability/rates">

<P><CENTER>
<A HREF= $passWordForm>
Return to password entry</A></CENTER><BR><BR><BR><BR></P>

<INPUT TYPE="reset" VALUE="Reset this Form"></CENTER></PRE>
</FORM>

</BODY>
</HTML>
end_of_html

   exit;

} #end hotel_res_form


################################################################################
#
#   Name:     display_res
#
#   Function: generates form that prompts hotel staff to specify database
#             record display keys
#
#   Inputs:   password
#
#   Outputs:  reservation transaction No.
#             address
#             city
#             state
#             ZIP
#             country
#             email address
#             home phone No.
#             arrive month
#             arrive day
#             arrive year
#             depart month
#             depart day
#             depart year
#
#   Caller:   res_utilities2.pl
#
#   Calls:    res_display.pl
#
#                      MODIFICATION                             DATE       BY
#
# Rodeway Inn  (add first/last names & sorting options)       10/14/98  M. Lewis
# Add hooks for dynamic path definitions                      08/12/00  M. Lewis
# Add hooks for creation of room-type dropdown menu.          09/16/01  M. Lewis
#
################################################################################
#Begin comments at col 50, end at 80:            50                            80
#
sub display_res {

   #   Constants
   my $completePath = $openUrl . 'res_display.pl';

   print "Content-Type: text/html\n\n";

print <<end_of_html;
<HTML>
<HEAD>
<script language="JavaScript">

<!-- //hide script from old browsers

// Use this function to save a cookie.
function setCookie(name, value, expires) {
document.cookie = name + "=" + escape(value) + "; path=/" +
((expires == null) ? "" : "; expires=" + expires.toGMTString());
}

function makeCookie() {
var exp = new Date();                     // make new date object
exp.setTime(exp.getTime() + (1000 * 60 * 60 * 24 * 31)); // set it 31
                                                         // days ahead
setCookie("xwd", "true", exp);            // save the cookie
return true;
}

//Don't honor a display request unless user has specified at least one
// search criterion.
//
function chk_submit(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p)
{
   if ( a.checked == false &&
        b.value == "" &&
        c.value == "" &&
        d.value == "" &&
        e.value == "" &&
        f.options[0].selected &&
        g.value == "" &&
        h.options[0].selected &&
        i.value == "" &&
        j.value == "" &&
        k.value == "" &&
        l.value == "" &&
        m.value == "" &&
        n.value == "" &&
        o.value == "" &&
        p.value == "") {
      alert("Resubmit request -- either check the display-all checkbox\\nor select one or more criteria to proceed");
      makeCookie();                              //Allow user to try again
      return false}                              // without having to reenter
   else {                                        // password
      return true}
   //endif
} //end chk_submit

// Use this function to retrieve a cookie.
function getCookie(name){
   var cname = name + "=";
   var dc = document.cookie;

   if (dc.length > 0) {
      begin = dc.indexOf(cname);                 //Get starting pos of name
      if (begin != -1) {
         begin += cname.length;
         end = dc.indexOf(";", begin);           //Start at begin and return
         if (end == -1) {                        // pos of first ; encountered
            end = dc.length;
            return unescape(dc.substring(begin, end))}
         //endif
      }//endif
   }
   else {
      alert("You must reenter your password to\\nprocess this display request");
      return false}
   //endif
}//end getCookie

// Use this function to delete a cookie.  Deletion is automatic when expiration
// date is set to anytime before current time.
function delCookie(name) {
document.cookie = name + "=; expires=Thu, 01-Jan-70 00:00:01 GMT" + "; path=/";
return null;
}

function chkStatus(name, display_all, Res_Num, Name,
                   Address, City, State, Zip, Country,
                   Email, Home_Phone, Arv_Day, Arv_Mnth,
                   Arv_Year, Dpt_Day, Dpt_Mnth, Dpt_Year) {

   if (getCookie(name)) {
      delCookie(name);                          //If cookie exists, delete it
                                                // to force user to reenter
                                                // password next time
      //If chk_submit returns a good status, proceed with display
      return chk_submit(display_all, Res_Num, Name,
                        Address, City, State, Zip, Country,
                        Email, Home_Phone, Arv_Day, Arv_Mnth,
                        Arv_Year, Dpt_Day, Dpt_Mnth, Dpt_Year) }
   else {
      return false}                             //No cookie means user didn't
   //endif                                      // enter password, get out.

} //end chkStatus

//end hide script -->
</script>

  <TITLE>Selection Form for Online Reservation System Database Display</TITLE>
</HEAD>

<BODY>

   <!--
##HOOK: BEGIN DISPLAY_RES PATHS                                        #08/12/00
   -->

<!--
<FORM METHOD="POST" ACTION="res_display.pl">
-->

<FORM METHOD="POST" ACTION="http://reservit.sourceforge.net/cgi-bin/res_display.pl"
>
<!--
##HOOK: END DISPLAY_RES PATHS                                          #08/12/00
   -->

<!--
 onSubmit="return chkStatus('xwd')";
onSubmit = "return chkStatus('xwd', display_all, firstName, Res_Num, lastName,
                        Address, City, State, Zip, Country,
                        Email, Home_Phone, Arv_Day, Arv_Mnth,
                        Arv_Year, Dpt_Day, Dpt_Mnth, Dpt_Year);">
onSubmit = "getCookie('xwd'); delCookie('xwd');
            return chk_submit(display_all, firstName, Res_Num, lastName, Address,
                              City, State, Zip, Country, Email, Home_Phone,
                              Arv_Day, Arv_Mnth, Arv_Year,
                              Dpt_Day, Dpt_Mnth, Dpt_Year)">
-->

<P><CENTER><ENCTYPE="x-www-form-urlencoded">

<P><CENTER><B><FONT COLOR="#400080" SIZE=+1>To select reservation records for
display, complete any or all of the following fields and submit.  Database
records whose fields match any of your criteria will be displayed.</FONT></B>
</CENTER></P>

<P><B><INPUT TYPE="CHECKBOX" VALUE="yes" NAME="display_all"
>Display all reservations in the reservations database<BR>
(If you check this box, do not select any of the criteria below)
</P>

<TABLE WIDTH="75%" BORDER="1" CELLSPACING="2" CELLPADDING="0">

<TR>
<TD WIDTH="50%">&nbsp;<TT>First Name: <INPUT NAME="firstName" SIZE="15"
 MAXLENGTH="100"
TYPE="text" VALUE=""></TT></TD>
<TD WIDTH="50%">&nbsp;<TT>Reservation Number: <INPUT NAME="Res_Num"
 SIZE="6" MAXLENGTH="6"
TYPE="text" VALUE="">
</TT></TD></TR>
<TR>
<TD WIDTH="50%">&nbsp;<TT>Last Name: &nbsp;<INPUT NAME="lastName" SIZE="15"
MAXLENGTH="100" TYPE="text" VALUE=""></TT></TD>
<TD WIDTH="50%">&nbsp;<TT>Address:<INPUT NAME="Address" SIZE="30"
 MAXLENGTH="100" TYPE="text" VALUE=""></TT></TD></TR>
<TR>
<TD WIDTH="50%">&nbsp;<TT>City: <br><INPUT NAME="City" SIZE="20" MAXLENGTH="100"
TYPE="text" VALUE=""></TT></TD>
<TD WIDTH="50%">&nbsp;<TT>State/Province:<BR>
<SELECT NAME="State">
<option name="dummy" value="" SELECTED>
<option value="none">Non-USA/Canada
<option value="AL">Alabama
<option value="AK">Alaska
<option value="AZ">Arizona
<option value="AR">Arkansas
<option value="CA">California
<option value="CO">Colorado
<option value="CT">Connecticut
<option value="DE">Delaware
<option value="DC">District of Columbia
<option value="FL">Florida
<option value="GA">Georgia
<option value="HI">Hawaii
<option value="ID">Idaho
<option value="IL">Illinois
<option value="IN">Indiana
<option value="IA">Iowa
<option value="KS">Kansas
<option value="KY">Kentucky
<option value="LA">Louisiana
<option value="ME">Maine
<option value="MD">Maryland
<option value="MA">Massachusetts
<option value="MI">Michigan
<option value="MN">Minnesota
<option value="MS">Mississippi
<option value="MO">Missouri
<option value="MT">Montana
<option value="NE">Nebraska
<option value="NH">New Hampshire
<option value="NJ">New Jersey
<option value="NM">New Mexico
<option value="NY">New York
<option value="NV">Nevada
<option value="NC">North Carolina
<option value="ND">North Dakota
<option value="OH">Ohio
<option value="OK">Oklahoma
<option value="OR">Oregon
<option value="PA">Pennsylvania
<option value="PR">Puerto Rico
<option value="RI">Rhode Island
<option value="SC">South Carolina
<option value="SD">South Dakota
<option value="TN">Tennessee
<option value="TX">Texas
<option value="UT">Utah
<option value="VT">Vermont
<option value="VA">Virginia
<option value="WA">Washington
<option value="WV">West Virginia
<option value="WI">Wisconsin
<option value="WY">Wyoming
<option value="AB">Alberta
<option value="BC">British Columbia
<option value="MB">Manitoba
<option value="NB">New Brunswick
<option value="NF">Newfoundland
<option value="NT">Northwest Territories
<option value="NS">Nova Scotia
<option value="ON">Ontario
<option value="PE">Prince Edward Island
<option value="QC">Quebec
<option value="SK">Saskatchewan
<option value="YT">Yukon Territory
</SELECT></TT></TD></TR>
<TR>
<TD WIDTH="50%">&nbsp;<TT>Zip/Postal Code:<br><INPUT NAME="Zip" SIZE="10"
 MAXLENGTH="10" TYPE="text" VALUE=""></TT></TD>
<TD WIDTH="50%">&nbsp;<TT>Country:<BR>
<SELECT NAME="Country">
<option name="dummy" value="" SELECTED>
<OPTION>Afghanistan
<OPTION>Albania
<OPTION>Algeria
<OPTION>American Samoa
<OPTION>Andorra
<OPTION>Angola
<OPTION>Anguilla
<OPTION>Antarctica
<OPTION>Antigua and Barbuda
<OPTION>Argentina
<OPTION>Armenia
<OPTION>Aruba
<OPTION>Australia
<OPTION>Austria
<OPTION>Azerbaijan
<OPTION>Bahamas
<OPTION>Bahrain
<OPTION>Bangladesh
<OPTION>Barbados
<OPTION>Belarus
<OPTION>Belgium
<OPTION>Belize
<OPTION>Benin
<OPTION>Bermuda
<OPTION>Bhutan
<OPTION>Bolivia
<OPTION>Bosnia-Herzegovina
<OPTION>Botswana
<OPTION>Bouvet Island
<OPTION>Brazil
<OPTION>Brunei Darussalam
<OPTION>Bulgaria
<OPTION>Burkina Faso
<OPTION>Burundi
<OPTION>Cambodia
<OPTION>Cameroon
<OPTION>Canada
<OPTION>Cape Verde
<OPTION>Cayman Islands
<OPTION>Central African Republic
<OPTION>Chad
<OPTION>Chile
<OPTION>China
<OPTION>Christmas Island
<OPTION>Cocos Islands
<OPTION>Colombia
<OPTION>Comoros
<OPTION>Congo
<OPTION>Cook Islands
<OPTION>Costa Rica
<OPTION>Cote dIvoire
<OPTION>Croatia
<OPTION>Cuba
<OPTION>Cyprus
<OPTION>Czech Republic
<OPTION>Denmark
<OPTION>Djibouti
<OPTION>Dominica
<OPTION>Dominican Republic
<OPTION>East Timor
<OPTION>Ecuador
<OPTION>Egypt
<OPTION>El Salvador
<OPTION>Equatorial Guinea
<OPTION>Eritrea
<OPTION>Estonia
<OPTION>Ethiopia
<OPTION>Falkland Islands
<OPTION>Faroe Islands
<OPTION>Fiji
<OPTION>Finland
<OPTION>France
<OPTION>French Guiana
<OPTION>French Polynesia
<OPTION>Gabon
<OPTION>Gambia
<OPTION>Georgia
<OPTION>Germany
<OPTION>Ghana
<OPTION>Gibraltar
<OPTION>Greece
<OPTION>Greenland
<OPTION>Grenada
<OPTION>Guadeloupe
<OPTION>Guam
<OPTION>Guatemala
<OPTION>Guinea
<OPTION>Guinea-Bissau
<OPTION>Guyana
<OPTION>Haiti
<OPTION>Honduras
<OPTION>Hong Kong
<OPTION>Hungary
<OPTION>Iceland
<OPTION>India
<OPTION>Indonesia
<OPTION>Iran
<OPTION>Iraq
<OPTION>Ireland
<OPTION>Israel
<OPTION>Italy
<OPTION>Jamaica
<OPTION>Japan
<OPTION>Jordan
<OPTION>Kazakhstan
<OPTION>Kenya
<OPTION>Kiribati
<OPTION>Korea
<OPTION>Korea
<OPTION>Kuwait
<OPTION>Kyrgyz Republic
<OPTION>Latvia
<OPTION>Lebanon
<OPTION>Lesotho
<OPTION>Liberia
<OPTION>Liechtenstein
<OPTION>Lithuania
<OPTION>Luxembourg
<OPTION>Macau
<OPTION>Macedonia
<OPTION>Madagascar
<OPTION>Malawi
<OPTION>Malaysia
<OPTION>Maldives
<OPTION>Mali
<OPTION>Malta
<OPTION>Marshall Islands
<OPTION>Martinique
<OPTION>Mauritania
<OPTION>Mauritius
<OPTION>Mayotte
<OPTION>Mexico
<OPTION>Micronesia
<OPTION>Moldova
<OPTION>Monaco
<OPTION>Mongolia
<OPTION>Montserrat
<OPTION>Morocco
<OPTION>Mozambique
<OPTION>Myanmar
<OPTION>Namibia
<OPTION>Nauru
<OPTION>Nepal
<OPTION>Netherlands
<OPTION>Netherlands Antilles
<OPTION>Neutral Zone
<OPTION>New Caledonia
<OPTION>New Zealand
<OPTION>Nicaragua
<OPTION>Niger
<OPTION>Nigeria
<OPTION>Niue
<OPTION>Norfolk Island
<OPTION>No. Mariana Islands
<OPTION>Norway
<OPTION>Oman
<OPTION>Pakistan
<OPTION>Palau
<OPTION>Panama
<OPTION>Papua New Guinea
<OPTION>Paraguay
<OPTION>Peru
<OPTION>Philippines
<OPTION>Pitcairn
<OPTION>Poland
<OPTION>Portugal
<OPTION>Puerto Rico
<OPTION>Qatar
<OPTION>Reunion
<OPTION>Romania
<OPTION>Russian Federation
<OPTION>Rwanda
<OPTION>Samoa
<OPTION>San Marino
<OPTION>Saudi Arabia
<OPTION>Senegal
<OPTION>Seychelles
<OPTION>Sierra Leone
<OPTION>Singapore
<OPTION>Slovakia
<OPTION>Slovenia
<OPTION>Solomon Islands
<OPTION>Somalia
<OPTION>South Africa
<OPTION>Soviet Union (former)
<OPTION>Spain
<OPTION>Sri Lanka
<OPTION>Sudan
<OPTION>Suriname
<OPTION>Swaziland
<OPTION>Sweden
<OPTION>Switzerland
<OPTION>Syria
<OPTION>Taiwan
<OPTION>Tajikistan
<OPTION>Tanzania
<OPTION>Thailand
<OPTION>Togo
<OPTION>Tokelau
<OPTION>Tonga
<OPTION>Trinidad and Tobago
<OPTION>Tunisia
<OPTION>Turkey
<OPTION>Turkmenistan
<OPTION>Turks and Caicos Islands
<OPTION>Tuvalu
<OPTION>Uganda
<OPTION>Ukraine
<OPTION>United Arab Emirates
<OPTION>United Kingdom
<OPTION>United States
<OPTION>U.S.Minor Outlying Islands
<OPTION>Uruguay
<OPTION>Uzbekistan
<OPTION>Vanuatu
<OPTION>Vatican City State
<OPTION>Venezuela
<OPTION>Vietnam
<OPTION>Virgin Islands
<OPTION>Virgin Islands
<OPTION>Wallis and Futuna Islands
<OPTION>Western Sahara
<OPTION>Yemen
<OPTION>Yugoslavia
<OPTION>Zaire
<OPTION>Zambia
<OPTION>Zimbabwe
</SELECT></TT></TD></TR>
<TR>
<TD WIDTH="50%">&nbsp;<TT>Email Address:<br><INPUT NAME="Email"
 SIZE="15" MAXLENGTH="100" TYPE="text" VALUE=""> </TT></TD>
<TD WIDTH="50%">&nbsp;<TT>Home Phone:<br><INPUT NAME="Home_Phone"
 SIZE="14" MAXLENGTH= "14" TYPE="text" VALUE=""></TT></TD>
<TR>
<TD WIDTH="50%">&nbsp;<TT>Comments:<br><INPUT NAME="comments"
 SIZE="40" MAXLENGTH="100" TYPE="text" VALUE=""> </TT></TD>

<!--begin 09/17/01-->
<TD WIDTH="50%">&nbsp;<TT>Room Type:<BR>
<SELECT NAME="selectBed">
<option name="dummy" value="" SELECTED>
<!--
##HOOK: BEGIN CREATE RES_DISPLAY ROOMS MENU
   -->
<OPTION VALUE="Single King, Refrigerator, Microwave, (Smoking Allowed)">Single King, Refrigerator, Microwave, (Smoking Allowed)
<OPTION VALUE="Single Queen, Refrigerator, Microwave, (No Smoking)">Single Queen, Refrigerator, Microwave, (No Smoking)
<OPTION VALUE="Single Queen, Refrigerator, Microwave, (Smoking Allowed)">Single Queen, Refrigerator, Microwave, (Smoking Allowed)
<OPTION VALUE="Single King, Refrigerator, Microwave, (No Smoking)">Single King, Refrigerator, Microwave, (No Smoking)
<!--
##HOOK: END CREATE RES_DISPLAY ROOMS MENU
 -->
</SELECT></TT></TD>

</TR></TABLE>
<!--end 09/17/01-->

<TABLE WIDTH="450" BORDER="1" CELLSPACING="2" CELLPADDING="0"><TD WIDTH="33%"><TR>
<TD WIDTH="33%">&nbsp;<TT>Arrive Month:<BR><INPUT NAME="Arv_Mnth" SIZE="3" MAXLENGTH="3"
TYPE="text" VALUE=""></TT></TD>
&nbsp;<TD WIDTH="33%"><TT>Arrive Day:<BR><INPUT NAME="Arv_Day" SIZE="2" MAXLENGTH="2"
TYPE="text" VALUE=""></TT></TD>
<TD WIDTH="33%">&nbsp;<TT>Arrive Year:<BR><INPUT NAME="Arv_Year" SIZE="2" MAXLENGTH="2"
TYPE="text" VALUE=""></TT></TD></TR>
<TR>
<TD WIDTH="33%">&nbsp;<TT>Depart Month:<BR><INPUT NAME="Dpt_Mnth" SIZE="3" MAXLENGTH="3"
TYPE="text" VALUE=""></TT></TD>
<TD WIDTH="33%">&nbsp;<TT>Depart Day:<BR><INPUT NAME="Dpt_Day" SIZE="2" MAXLENGTH="2"
TYPE="text" VALUE=""></TT></TD>
<TD WIDTH="33%">&nbsp;<TT>Depart Year:<BR><INPUT NAME="Dpt_Year" SIZE="2" MAXLENGTH="2"
TYPE="text" VALUE=""></TT></TD></TR>
</TABLE>

<P>
<TABLE WIDTH="75%" COLS="1" BORDER="1" CELLSPACING="2" CELLPADDING="0">
<TR>
<TD COLSPAN="1"><TT>
By default, displayed records are sorted in ascending order by
reservation number.  If you want your displayed records to be sorted
differently, you can choose up to three different sort orders from the
dropdown menus below, but these sorts are entirely optional.  You can
choose one of eight categories for each of the three sorts.  "Most
important sort" is the 1st sort, next most important is 2nd sort,
least important is 3rd sort.
</TD>
</TR>
</TABLE>

<!--                                                                   #09/21/01
     #################******************#################**************#09/21/01
NOTE: all constants used in the following "value=" assignments are de- #09/21/01
      fined in global_data.pl.                                         #09/21/01
     #################******************#################**************#09/21/01
-->

<TABLE WIDTH="75%" COLS="3" BORDER="1" CELLSPACING="2" CELLPADDING="0">
<TR>
<TD COLSPAN="1"><TT>
<SELECT NAME="firstSrt">
<option SELECTED>1st-order sort, by:
<option value=$arvDay>Arrive date
<option value=$dptDay>Depart date
<option value=$lastName>Last name
<option value=$firstName>First name
<option value=$rNum>Reservation No.
<option value=$selectBed>Room type
<option value=$State>State                                       <!--09/17/01-->
<option value=$Zip>ZIP code                                      <!--09/17/01-->
</SELECT></TT></TD>

<TD COLSPAN="1"><TT>
<SELECT NAME="secondSrt">
<option SELECTED>2nd-order sort, by:
<option value=$arvDay>Arrive date
<option value=$dptDay>Depart date
<option value=$lastName>Last name
<option value=$firstName>First name
<option value=$rNum>Reservation No.
<option value=$selectBed>Room type
<option value=$State>State                                       <!--09/17/01-->
<option value=$Zip>ZIP code                                      <!--09/17/01-->
</SELECT></TT></TD>

<TD COLSPAN="1"><TT>
<SELECT NAME="thirdSrt">
<option SELECTED>3rd-order sort, by:
<option value=$arvDay>Arrive date
<option value=$dptDay>Depart date
<option value=$lastName>Last name
<option value=$firstName>First name
<option value=$rNum>Reservation No.
<option value=$selectBed>Room type
<option value=$State>State                                       <!--09/17/01-->
<option value=$Zip>ZIP code                                      <!--09/17/01-->
</SELECT></TT></TD>
</TR>
</TABLE>


</P>

<p><CENTER><INPUT TYPE="submit" VALUE="Click here to display selected records"></p>

<p><center><INPUT TYPE="reset" VALUE="Clear this Form">

</FORM>

</BODY>
</HTML>

end_of_html

   exit(0);
} #end display_res


################################################################################
#
#   Name:     cancel_form
#
#   Function: generates form that prompts user to specify reservation
#             transaction No. as key for reservation cancellation
#
#   Inputs:   password
#
#   Outputs:  reservation transaction No.
#
#   Caller:   res_utilities2.pl
#
#   Calls:    res_cancel.pl
#
#                                MODIFICATION                        DATE      BY
#
#   Lakeside Inn                                                         04/12/98   M. Lewis
# Add hooks for dynamic path generation                      08/13/00   M. Lewis
#
sub cancel_form {

  my $passwd = shift (@_);
  my $passWordForm = $openHtml . "res_utilities.pl";

  print "Content-Type: text/html\n\n";

print <<end_of_html;
<HTML>
<HEAD>

<script language="JavaScript">

<!-- //hide script from old browsers

// Use this function to retrieve a cookie.
function getCookie(name){
   var cname = name + "=";
   var dc = document.cookie;

   if (dc.length > 0) {
      begin = dc.indexOf(cname);                 //Get starting pos of name
      if (begin != -1) {
         begin += cname.length;
         end = dc.indexOf(";", begin);           //Start at begin and return
         if (end == -1) {                        // pos of first ; encountered
            end = dc.length;
            return unescape(dc.substring(begin, end))}
         //endif
      }//endif
   }
   else {
      alert("You must reenter your password\\nto process this cancellation");
      return false}
   //endif
}//end getCookie

// Use this function to delete a cookie.  Deletion is automatic when expiration
// date is set to anytime before current time.
function delCookie(name) {
document.cookie = name + "=; expires=Thu, 01-Jan-70 00:00:01 GMT" + "; path=/";
return null;
}

function chkStatus(name) {

   if (getCookie(name)) {
      delCookie(name)}                          //If cookie exists, delete it
                                                // to force user to reenter
                                                // password next time
   else {
      return false}                             //No cookie means user didn't
   //endif                                      // enter password, get out.

} //end chkStatus

//end hide script -->
</script>

  <META NAME="GENERATOR" CONTENT="Adobe PageMill 2.0 Win">
  <TITLE>$hotel_manager Online Reservations: Cancel reservation</TITLE>
</HEAD>

<BODY BGCOLOR="#ffffff">

   <!--
##HOOK: BEGIN CANCEL_FORM PATHS                                        #08/13/00
   -->

<!--
<FORM METHOD="POST" ACTION="res_cancel.pl">
onSubmit = "return chkStatus($passwd)">
-->

<FORM METHOD="POST" ACTION="http://reservit.sourceforge.net/cgi-bin/res_cancel.pl">
<!--onSubmit = "return chkStatus($passwd)"> -->

<!--
##HOOK: END CANCEL_FORM PATHS                                          #08/13/00
   -->

<ENCTYPE="x-www-form-urlencoded">

<INPUT TYPE="hidden" NAME="bgcolor" VALUE="#FFFFFF">
<INPUT TYPE="hidden" NAME="text_color" VALUE="#FFOOOO">
<INPUT TYPE="hidden" NAME="link_color" VALUE="#OOOOOO">
<INPUT TYPE="hidden" NAME="passwd" VALUE="$passwd">
</P>

<P><CENTER><FONT SIZE=+2><b>
$hotel_manager Online Reservations: Reservation Cancellation Form
</CENTER><br><br></p>

<P><font size +1><CENTER><B>Enter reservation transaction number: </B>
<INPUT NAME="trans_num" SIZE="6" MAXLENGTH="6" TYPE="text">
</CENTER><BR><BR></P>

<PRE><CENTER>
  <INPUT TYPE="submit" VALUE="Cancel Reservation"><BR><BR>
<INPUT TYPE="reset" VALUE="Clear this Form">
</CENTER></PRE>
<BR><BR></FORM>

<P><CENTER><FONT SIZE=-1>
<A HREF= $passWordForm>
Return to password entry</A></FONT></CENTER><BR><BR><BR><BR><BR></P>

</BODY>
</HTML>
end_of_html

   exit;

} #end cancel_form


################################################################################
#
#   Name:     no_matches
#
#   Function: generates form: no reservation database records match user-entered
#             criteria
#
#   Inputs:
#
#   Outputs:
#
#   Caller:   res_display                res_display.pl
#
#   Calls:
#
sub no_matches {

  print "Content-Type: text/html\n\n";

print <<end_of_html;
   <html>
   <head>
   <title>ColdCreek Software Reservations System</title></head>

   <BODY BGCOLOR="#ffffff">

   <IMG SRC ="$jpeg2url">

   <H2>No records match the search criteria you entered.</H2>

   <hr>
   <p>Press <b>Back</b> at top left of screen to return to the selection form

   </body>
   </html>
end_of_html
   exit;
} #end no_matches


################################################################################
#
#   Name:     no_trans_rec
#
#   Function: generates form: can't find a transaction record for this
#             reservation
#
#   Inputs:   reservation transaction No.
#
#   Outputs:
#
#   Caller:   res_cancel                res_cancel.pl
#
#   Calls:
#
sub no_trans_rec {

   my $transNum = shift (@_);


   print "Content-Type: text/html\n\n";

print <<end_of_html;
   <html>
   <head>
   <title>ColdCreek Software Reservations System</title></head>
   <ENCTYPE=\"x-www-form-urlencoded\">
   <BODY BGCOLOR="#ffffff">

   <IMG SRC ="$jpeg2url">

   <h2>There is no transaction number = $transNum</h2>
   <p>The number is either incorrect or this reservation has<br>
   already been cancelled.  Go back to the previous form if you<br>
   wish to reenter the transaction number</p>

   </body>
   </html>
end_of_html
   return;

} #end no_trans_rec


################################################################################
#
#   Name:     purge_data
#
#   Function: generates page that displays:
#                1. number of deleted obsolete reservation-history (resChange)
#                   database records
#                2. transaction-No. keys of deleted obsolete reservation-history
#                   database records
#                3. number of deleted obsolete room-state (resState) database
#                   records
#                4. date-keys of deleted obsolete room-state database records
#                5. date-keys of modified (due to cancelled reservation) room-
#                   state database records
#
#   Inputs:   No. deleted resState.db records
#             dates of deleted resState and resChange records
#             dates affected by the cancelled reservation
#             No. deleted resChange.db records
#             transaction numbers of deleted resChange records
#
#   Outputs:
#
#   Caller:   res_cancel                res_cancel.pl
#
#   Calls:
#
sub purge_data {

   my $rsDeleted    = shift(@_);
   my $datesDeleted   = shift(@_);
   my $datesCancelled = shift(@_);
   my $rcDeleted = shift(@_);
   my $transNumDeleted = shift(@_);

   print "Content-Type: text/html\n\n";

print <<end_of_html;
   <html>
   <head>
   <title>ColdCreek Software Online Reservations -- Cancellation Confirmation</title></head>
   <BODY BGCOLOR="#ffffff">

   <IMG SRC ="$jpeg2url">

   <h2>The motel state database has been updated (check email confirmation for details)</h2>
   <p>No. of obsolete resChange records deleted: $rcDeleted<br>
   resChange records with the following keys have been deleted:<br>$transNumDeleted</p>
   <p>No. of obsolete resState records deleted: $rsDeleted<br>
   resState records with the following keys have been deleted:<br>$datesDeleted</p>
   <p>resState records with the following keys have been updated:<br>$datesCancelled</p>

   </body>
   </html>
end_of_html
   return;

} #end purge_data


################################################################################
#
#   Name:     passwd_err
#
#   Function: generates page: user entered an invalid password
#
#   Inputs:
#
#   Outputs:
#
#   Caller:   res_utilities              res_utilities2.pl
#
#   Calls:
#
sub passwd_err {

   print "Content-Type: text/html\n\n";

print <<end_of_html;
   <html>
   <head>
   <title>ColdCreek Software Reservations System</title></head>
   <ENCTYPE=\"x-www-form-urlencoded\">
   <BODY BGCOLOR="#ffffff">

   <IMG SRC ="$jpeg2url">
   <CENTER>
   <h2>The password you entered is invalid</h2>
   <p>Go back to the previous form to reenter</p>
   </CENTER>
   </body>
   </html>
end_of_html
   exit(0);
} #end passwd_err


################################################################################
#
#   Name:     print_rooms_header                                       #12/22/00
#
#   Function: prints a buffer containing a fixed header for the display of rooms
#             available/used/allocated for a date range input by user
#
#   Inputs:
#
#   Outputs:
#
#   Caller:   retrieve_room_or_rates_data.pl                           #10/13/01
#
#   Calls:
#
#                        MODIFICATION                          DATE        BY
#
#   Lakeside Inn   (add selective-date room-block update)    07/19/98   M. Lewis
#   Rodeway Inn                                              09/24/98   M. Lewis
# Add hooks for dynamic path generation                      08/13/00   M. Lewis
# Add hook for PRINT_ROOM_HEADER_DESCRIPTIONS and code to    10/08/00   M. Lewis
#  dynamically generate correct number of room-description
#  fields.
# Remove all references to array @printOrderKeys             10/14/00   M. Lewis
# Move @numRms to room_block.pl                              11/18/00   M. Lewis
# Changed name from print_header to print_rooms_header.      12/22/00   M. Lewis
#
sub print_rooms_header {                                               #12/22/00

#        1         2         3         4         5         6         7         8         9
#23456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123

  my $numCols = 6 + (3 * $numRms);                                     #10/08/00

#  print "Content-Type: text/html\n\n";

print <<end_of_html;
   <HTML>

   <HEAD>

   <script language="JavaScript">
   <!-- //hide script from old browsers

   // Use this function to retrieve a cookie.
   function getCookie(name){
      var cname = name + "=";
      var dc = document.cookie;

      if (dc.length > 0) {
         begin = dc.indexOf(cname);              //Get starting pos of name
         if (begin != -1) {
            begin += cname.length;
            end = dc.indexOf(";", begin);        //Start at begin and return
            if (end == -1) {                     // pos of first ; encountered
               end = dc.length;
               return unescape(dc.substring(begin, end))}
            //endif
         }//endif
      }
      else {
         return false}
      //endif
   }//end getCookie


   // Use this function to delete a cookie.  Deletion is automatic when expira-
   // tion date is set to anytime before current time.
   function delCookie(name) {
   document.cookie = name + "=; expires=Thu, 01-Jan-70 00:00:01 GMT" + "; path=/";
   return null;
   }


   function chkStatus(name) {

      if (getCookie(name)) {
         delCookie(name);                       //If cookie exists, delete it
                                                // to force user to resubmit
                                                // date form next time
         return true}
      else {
         alert("You must go back to the date-entry form (previous screen)\\nand regenerate this table by resubmitting the dates");
         return false}                          //No cookie means user didn't
      //endif                                   // get here through date entry,
                                                // get out.

   } //end chkStatus

   //end hide script -->
   </script>

     <TITLE>ColdCreek Software Online Reservation System</TITLE>
   </HEAD>

   <BODY>

   <!--
##HOOK: BEGIN PRINT_ROOMS_HEADER PATHS                                 #12/22/00
   -->

<!--
<FORM METHOD="POST" ACTION="room_update.pl"
onSubmit = "return chkStatus('upDateRm')">
-->

<FORM METHOD="POST" ACTION="http://reservit.sourceforge.net/cgi-bin/room_update.pl"
>
<!--
onSubmit = "return chkStatus('upDateRm')">
-->


<!--
##HOOK: END PRINT_ROOMS_HEADER PATHS                                   #12/22/00
   -->

<ENCTYPE="x-www-form-urlencoded">

<INPUT TYPE="hidden" NAME="startMonth" VALUE=$FORM{'startMonth'}>
<INPUT TYPE="hidden" NAME="startDay" VALUE=$startDay>
<INPUT TYPE="hidden" NAME="startYear" VALUE=$startYear>
<INPUT TYPE="hidden" NAME="endMonth" VALUE=$FORM{'endMonth'}>
<INPUT TYPE="hidden" NAME="endDay" VALUE=$endDay>
<INPUT TYPE="hidden" NAME="endYear" VALUE=$endYear>

<pre>
           ***************************************************
           *  RESERVATIONS, ROOM AVAILABILITY AND ROOM ALLOCATION  *
           ***************************************************

Col          For This Date
---          -------------
A  = No. reservations outstanding
B  = No. rooms available
C  = No. rooms allocated

NOTE: You can change the No. of rooms allocated (col. C) in this table.  When you
      submit one or more new values in col. C, the corresponding No. of rooms
      available values (col. B) will be adjusted automatically.  A negative value
      in any col. B means that more rooms of that type have been reserved than
      there are rooms available.  To change the negative value to at least 0, in-
      crease the No. of rooms allocated value by at least the number of reserva-
      tions in col. A.
</pre>

   <P><TABLE WIDTH="61%" COLS="18" BORDER="1" CELLSPACING="0" CELLPADDING="0">
   <TR ALIGN="RIGHT" VALIGN="MIDDLE">
   <TD COLSPAN="3" ALIGN="CENTER"><TT><B>
      <INPUT TYPE="checkbox" VALUE=$true NAME="blackout">
      Black-out All Rooms</B></TD>
   <TD COLSPAN="15" ALIGN="LEFT" VALIGN="MIDDLE"><TT><B><PRE>

 If you choose the "blackout" option, ALL No.-rooms-available (col. B)
 values will be set to 0 for every date displayed in the table below
 so that no rooms can be reserved for those dates.</PRE></B></TD>
   </TR></TABLE>

   <P>&nbsp;<P>
   <TABLE WIDTH="81%" COLS="18" BORDER="1" CELLSPACING="0" CELLPADDING="0">

   <!--This print block displays header with form:

        |    KS     |    KNS    |    DDS    |    DDNS   |   TOTALS
  DATE  | A | B | C | A | B | C | A | B | C | A | B | C | A | B | C

    -->

   <TR ALIGN="CENTER">
   <TD COLSPAN="3"></TD>

<!--
##HOOK: BEGIN PRINT_ROOMS_HEADER_ROOM_DESCRIPTIONS                     #12/22/00
   -->
   <TD COLSPAN="3">Single King, Refrigerator, Microwave, (Smoking Allowed)</TD>
   <TD COLSPAN="3">Single Queen, Refrigerator, Microwave, (No Smoking)</TD>
   <TD COLSPAN="3">Single Queen, Refrigerator, Microwave, (Smoking Allowed)</TD>
   <TD COLSPAN="3">Single King, Refrigerator, Microwave, (No Smoking)</TD>

<!--
##HOOK: END PRINT_ROOMS HEADER_ROOM_DESCRIPTIONS                       #12/22/00
-->

   <TD COLSPAN="3">TOTALS</TD></TR>
   <TR ALIGN="CENTER">
   <TD COLSPAN="3">DATE</TD>
end_of_html

  #Print three subcolumn headings for each room column                 #10/08/00
  foreach $room (@numRms) {                      #numRms def in caller.#10/08/00
print <<end_of_html;
   <TD COLSPAN="1">A</TD>
   <TD COLSPAN="1">B</TD>
   <TD COLSPAN="1">C</TD>
end_of_html
  } #end foreach                                                       #10/08/00

#Print the three subcolumn headings for the TOTALS column.             #10/12/00
#                                                                      #10/12/00
print <<end_of_html;
   <TD COLSPAN="1">A</TD>
   <TD COLSPAN="1">B</TD>
   <TD COLSPAN="1">C</TD>
   </TR>
end_of_html

return;                                                                #11/19/00

} #end print_rooms_header                                              #12/22/00


################################################################################
#
#   Name:     print_rooms
#
#   Function: Builds display for one row of rooms allocated/available/reserved
#             data table.  Each row corresponds to one date.  No. rooms allo-
#             cated may then be changed by the user.
#
#   Inputs:   table row counter
#             month
#             day
#             year
#             buffer: global_data.pl room-availability presets or
#                     resState.db records (No. rooms available by room type)
#
#   Outputs:
#
#   Caller:   retrieve_room_or_rates_data.pl
#
#   Calls:    display_roomtype               res_utilities_html_lib.pl
#             display_roomtotals             res_utilities_html_lib.pl
#
#
#                    MODIFICATION                            DATE        BY
#
#   Harvey's Hotel/Casino                                  02/24/98   M. Lewis
#   Lakeside Inn                                           03/17/98   M. Lewis
#   Lakeside Inn   (add selective-date room-block update)  07/19/98   M. Lewis
#   Rodeway Inn                                            09/24/98   M. Lewis
#   Rodeway Inn                                                                                10/09/98   M. Lewis
# Add hook for PRINT_ROOM_HEADER_DESCRIPTIONS2 and code to   10/08/00   M. Lewis
#  dynamically generate correct number of room-description
#  fields.
# Add hook for PRINT_ROOMS_TOT_VALUES                        10/08/00   M. Lewis
# Remove all references to array @printOrderKeys             10/14/00   M. Lewis
#
sub print_rooms {

#print "Content-Type: text/html\n\n";

   my $j = shift(@_);
   my $month = shift(@_);
   my $day   = shift(@_);
   my $year  = shift(@_);
   local @roomValues = @_;

##HOOK: BEGIN PRINT_ROOMS_TOT_VALUES                                   #10/09/00
my $totRes = $roomValues[0] + $roomValues[3] + $roomValues[6] + $roomValues[9];
my $totAvail = $roomValues[1] + $roomValues[4] + $roomValues[7] + $roomValues[10];
my $totAlloc = $roomValues[2] + $roomValues[5] + $roomValues[8] + $roomValues[11];
##HOOK: END PRINT_ROOMS_TOT_VALUES                                     #10/09/00

   #Format day and year for printing
   if ($day < 10) {
      $printDay = " " . $day}
   else {
      $printDay = $day}
   #endif

   #Display table header every time 20 rows have been displayed
   #
   if ($j > 0) {                                 #$j is set in caller
      $rem = $j % 20;
      if ($rem == 0) {

print <<end_of_html;
   <!--This print block displays header of form:

        |    KS     |    KNS    |    DDS    |    DDNS   |   TOTALS
  DATE  | A | B | C | A | B | C | A | B | C | A | B | C | A | B | C

    -->

   <TR ALIGN="CENTER">
   <TD COLSPAN="3"></TD>

<!--
##HOOK: BEGIN PRINT_ROOMS_ROOM_DESCRIPTIONS                            #10/18/00
   -->
   <TD COLSPAN="3">Single King, Refrigerator, Microwave, (No Smoking)</TD>
   <TD COLSPAN="3">Single Queen, Refrigerator, Microwave, (No Smoking)</TD>
   <TD COLSPAN="3">Single Queen, Refrigerator, Microwave, (Smoking Allowed)</TD>
   <TD COLSPAN="3">Single King, Refrigerator, Microwave, (Smoking Allowed)</TD>

<!--
##HOOK: END PRINT_ROOMS_ROOM_DESCRIPTIONS                              #10/18/00
-->

   <TD COLSPAN="3">TOTALS</TD></TR>
   <TR ALIGN="CENTER">
   <TD COLSPAN="3">DATE</TD>
end_of_html

        #Print three subcolumn headings for each room column           #10/08/00
        foreach $room (@numRms) {
print <<end_of_html;
   <TD COLSPAN="1">A</TD>
   <TD COLSPAN="1">B</TD>
   <TD COLSPAN="1">C</TD>
end_of_html
        } #end foreach                                                 #10/08/00

#Print the three subcolumn headings for the TOTALS column.             #10/12/00
#                                                                      #10/12/00
print <<end_of_html;
   <TD COLSPAN="1">A</TD>
   <TD COLSPAN="1">B</TD>
   <TD COLSPAN="1">C</TD>
   </TR>
end_of_html

    } #endif
  } #endif

  $printMonth = $monthNum{$month};               #Convert month from
                                                 # num to strng
  if ($year > 99) {                                                    #10/18/00
    $year -= 100;                                                      #10/14/00
    if ($year < 10) {                            #Format year for      #10/14/00
      $year = '0' . $year}                       # printing.           #10/14/00
    # endif                                                            #10/14/00
  } #endif                                                             #10/18/00

print <<end_of_html;
   <TR ALIGN="RIGHT">
   <TD COLSPAN="3" ALIGN="CENTER" >
     <FONT SIZE="-1">$printMonth $printDay $year</TD>
   <INPUT TYPE="HIDDEN" NAME="month$j" VALUE=$month>
   <INPUT TYPE="HIDDEN" NAME="day$j" VALUE=$printDay>
   <INPUT TYPE="HIDDEN" NAME="year$j" VALUE=$year>
end_of_html

  $k = 0;
  foreach $room (@numRms) {                                            #10/09/00
    &display_roomtype($room,  $j,  $k);                                #10/09/00
    $k += 3;                                    #Pnt to next rm values #10/14/00
  } #end foreach                                                       #10/08/00
  &display_roomtotals($totRes, $totAvail, $totAlloc);

  print "</TR>";

  return;

} #end print_rooms


################################################################################
#
#   Name:     display_roomtype
#
#   Function: formats and displays three values for an input room type.
#
#   Inputs:   room-type string
#             No. of current display row
#             No.-rooms-reserved/available/allocated data array (defined in
#              caller)
#             Index into the data array                                #10/14/00
#
#   Outputs:
#
#   Caller:   print_rooms                                      res_utilities_html_lib.pl
#
#   Calls:    display_rooms_available        res_utilities_html_lib.pl
#             pad_allocation_value           res_utilities_html_lib.pl
#
#                              MODIFICATION                          DATE      BY
#
#   Lakeside Inn   (add selective-date room-block update)    08/14/98   M. Lewis
# Revise for automated system                                10/14/00   M. Lewis
# Remove all references to array @printOrderKeys             10/14/00   M. Lewis
#
sub display_roomtype {

#print "Content-Type: text/html\n\n";

   my $seedName = shift(@_);
   my $j = shift(@_);                            #Display row counter
   my $k = shift(@_);                            #Index into roomValues

   $seedName = $seedName . $j;
   $name = $seedName . "A";

print <<end_of_html;
   <TD COLSPAN="1"><FONT SIZE="-1">$roomValues[$k]</TD>
   <INPUT TYPE="HIDDEN" NAME=$name VALUE=$roomValues[$k]>
end_of_html

   #Display No. rooms available value
   #
   &display_rooms_available($roomValues[$k+1]);

   $name = $seedName . "B";
print <<end_of_html;
   <INPUT TYPE="HIDDEN" NAME=$name VALUE=$roomValues[$k+1]>
end_of_html

   #Right-justify next display value
   #
#NOTE: this call disabled because padding the value with &nbsp; causes problems when
# room_update.pl tries to retrieve the values later
#
#      $roomValues[$k+2] =
#         &pad_allocation_value($roomValues[$k+2]);

   $name = $seedName . "C";
print <<end_of_html;
   <TD COLSPAN="1"><INPUT TYPE="text" NAME=$name SIZE="3" MAXLENGTH="3"
         VALUE=$roomValues[$k+2]>
   </TD>
end_of_html

   return;
} #end display_roomtype


################################################################################
#
#   Name:     display_roomtotals
#
#   Function: formats and displays three room-totals values for a single date.
#
#   Inputs:   total rooms reserved
#             total rooms available
#             total rooms allocated
#
#   Outputs:
#
#   Caller:   print_rooms                              res_utilities_html_lib.pl
#             post_update_rooms            res_utilities_html_lib.pl
#
#   Calls:
#
#                             MODIFICATION                           DATE      BY
#
#   Rodeway Inn                                                                                  10/09/98   M. Lewis
#

sub display_roomtotals {

   my $totalRes = shift(@_);
   my $totalAvail = shift(@_);
   my $totalAlloc = shift(@_);

print <<end_of_html;
   <TD COLSPAN="1"><FONT SIZE="-1"><B>$totalRes</B></TD>
end_of_html

   #The following if block displays total No. rooms available in red if value
   # is negative, else displays the value in black.
   #
   if ($totalAvail < 0) {
print <<end_of_html;
      <TD COLSPAN="1"><FONT COLOR="#FF0000" SIZE="-1"><B>$totalAvail</B></TD>
end_of_html
   }
   else {
print <<end_of_html;
      <TD COLSPAN="1"><FONT SIZE="-1"><B>$totalAvail</B></TD>
end_of_html
   }
   #endif

print <<end_of_html;
      <TD COLSPAN="1"><FONT SIZE="-1"><B>$totalAlloc</B></TD>
end_of_html

   return;

} #end display_roomtotals


#   Calls:
#
#                             MODIFICATION                           DATE      BY
#
#   Rodeway Inn                                                                                  10/09/98   M. Lewis
#

sub display_roomtotals {

   my $totalRes = shift(@_);
   my $totalAvail = shift(@_);
   my $totalAlloc = shift(@_);

print <<end_of_html;
   <TD COLSPAN="1"><FONT SIZE="-1"><B>$totalRes</B></TD>
end_of_html

   #The following if block displays total No. rooms available in red if value
   # is negative, else displays the value in black.
   #
   if ($totalAvail < 0) {
print <<end_of_html;
      <TD COLSPAN="1"><FONT COLOR="#FF0000" SIZE="-1"><B>$totalAvail</B></TD>
end_of_html
   }
   else {
print <<end_of_html;
      <TD COLSPAN="1"><FONT SIZE="-1"><B>$totalAvail</B></TD>
end_of_html
   }
   #endif

print <<end_of_html;
      <TD COLSPAN="1"><FONT SIZE="-1"><B>$totalAlloc</B></TD>
end_of_html

   return;

} #end display_roomtotals


################################################################################
#
#   Name:     display_rooms_available
#
#   Function: prints a No.-rooms-available value for an input room type.  Neg-
#             ative values are displayed in red
#
#   Inputs:   No. rooms available for a particular room type
#
#   Outputs:  one display value
#
#   Caller:   display_roomtype                         res_utilities_html_lib.pl
#             post_display_roomtype                        res_utilities_html_lib.pl
#
#   Calls:
#
#                        MODIFICATION                                                                DATE      BY
#
#   Lakeside Inn   (add selective-date room-block update)    08/07/98   M. Lewis
#
sub display_rooms_available {

#print "Content-Type: text/html\n\n";

   my $roomsAvail = shift(@_);

   #The following if block displays No. rooms available in red if value is nega-
   # tive, else displays the value in black.
   #
   if ($roomsAvail < 0) {
print <<end_of_html;
      <TD COLSPAN="1"><FONT COLOR="#FF0000" SIZE="-1">$roomsAvail</TD>
end_of_html
   }
   else {
print <<end_of_html;
      <TD COLSPAN="1"><FONT SIZE="-1">$roomsAvail</TD>
end_of_html
   }
   #endif

   return;
} #end display_rooms_available


################################################################################
#
#   Name:     pad_allocation_value
#
#   Function: pads display value with ASCII blanks to force right-justification
#
#   Inputs:   No.-rooms allocated value
#
#   Outputs:
#
#   Caller:   display_roomtype                     res_utilities_html_lib.pl
#
#   Calls:
#
#                            MODIFICATION                            DATE                  BY
#
#   Lakeside Inn   (add selective-date room-block update)    08/12/98   M. Lewis
#
sub pad_allocation_value {

   my $roomsAlloc = shift(@_);
   if ($roomsAlloc < 10) {
      $roomsAlloc = "&nbsp;&nbsp;" . $roomsAlloc}
   elsif (($roomsAlloc >= 10) &&
          ($roomsAlloc < 100)) {
      $roomsAlloc = "&nbsp;" . $roomsAlloc}
   #endif

   return($roomsAlloc);
} #end pad_allocation_value


################################################################################
#
#   Name:     print_footer
#
#   Function: prints a buffer containing a fixed footer for the dis-   #12/30/00
#             play of rooms available/used/allocated or room rates for #12/30/00
#             a date range input by user.                              #12/30/00
#
#   Inputs:   No. data rows processed by print_rooms or display_rates. #12/30/00
#
#   Outputs:  No. data rows processed by print_rooms or display_rates. #12/30/00
#
#   Caller:   retrieve_room_or_rates_data.pl                           #12/30/00
#
#   Calls:    room_update.pl or write_rates.pl is called indirectly as #12/30/00
#             a result of the form of which this footer is part.       #12/30/00
#
#                               MODIFICATION                                                               DATE             BY
#
#   Lakeside Inn   (add selective-date room-block update)    07/19/98   M. Lewis
# Add input $caller to display proper string for room or     12/30/00   M. Lewis
#  rate displays
# Add code to pass $totRates.                                09/07/01   M. Lewis
#
sub print_footer {

#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890

  my $numRows = shift(@_);
  my $caller = shift(@_);
  my $totRates = shift(@_);                                           #09/07/01

print <<end_of_html;
   </TABLE>
end_of_html

  if ($totRates > 0) {
    print "<INPUT TYPE=\"HIDDEN\" NAME=\"totRates\" VALUE=$totRates>"}
  #endif

print <<end_of_html;
   <INPUT TYPE="HIDDEN" NAME="numRows" VALUE=$numRows>

   <P>
   <PRE><CENTER>
   <INPUT TYPE="submit" VALUE="Click here to set new $caller parameters">

   <INPUT TYPE="reset" VALUE="Reset this Form"></CENTER></PRE>
   </FORM>


   <!--
   <p><IMG SRC="/cgi-sys/Count.cgi?df=tm123-rodeway_res_sys.cnt">
   -->

   </BODY>
   </HTML>
end_of_html

  return;
} #end print_footer


################################################################################
#
#   Name:     post_update_header
#
#   Function: prints a buffer containing a fixed header for the updated display
#             of rooms available/used/allocated for a date range input by user
#
#   Inputs:
#
#   Outputs:
#
#   Caller:   room_update                    room_update.pl
#
#   Calls:    build_header                   res_utilities_html_lib.pl #10/22/01
#
#                       MODIFICATION                           DATE        BY
#
#   Lakeside Inn   (add selective-date room-block update)    08/22/98   M. Lewis
#   Rodeway Inn                                              09/24/98   M. Lewis
# Add hooks for dynamic path generation & revise for auto-   08/17/00   M. Lewis
#  mated system
# Strip build_header code and create call to build_header.   10/22/01   M. Lewis
#
sub post_update_header {
#        1         2         3         4         5         6         7         8         9
#23456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123

  my @numRms = sort(keys(%roomDef));             #roomDef hash defined #10/14/00
                                                 # in global_data.pl   #10/14/00
  my $numRms = @numRms;                          #No. items in array   #10/15/00

  my $numCols = 6 + (3 * $numRms);                                     #10/19/00

  print "Content-Type: text/html\n\n";

print <<end_of_html;
   <HTML>

   <HEAD>
     <TITLE>ColdCreek Software Online Reservation System</TITLE>
   </HEAD>

   <BODY>

<pre>
       ***********************************************************
       *  UPDATED RESERVATIONS, ROOM AVAILABILITY AND ROOM ALLOCATION  *
       ***********************************************************

Col          For This Date
---          -------------
A  = No. reservations outstanding
B  = No. rooms available
C  = No. rooms allocated

NOTE: A negative value in any col. B means that more rooms of that type have been
      reserved than there are rooms available.  To change the negative value to at
      least 0, return to the previous form and increase the No.-of-rooms-allocated
      value (col. C) by at least the amount of the negative value in col. B.

</pre>

   <P>&nbsp;<P>
   <TABLE WIDTH="81%" COLS="18" BORDER="1" CELLSPACING="0" CELLPADDING="0">

   <!--This print block displays header with form:

        |    KS     |    KNS    |    DDS    |    DDNS   |   TOTALS
  DATE  | A | B | C | A | B | C | A | B | C | A | B | C | A | B | C

    -->

   <TR ALIGN="CENTER">
   <TD COLSPAN="3"></TD>

<!--
##HOOK: BEGIN POST_UPDATE_HEADER_ROOM_DESCRIPTIONS                     #10/17/00
   -->
   <TD COLSPAN="3">Single King, Refrigerator, Microwave, (Smoking Allowed)</TD>
   <TD COLSPAN="3">Single Queen, Refrigerator, Microwave, (No Smoking)</TD>
   <TD COLSPAN="3">Single Queen, Refrigerator, Microwave, (Smoking Allowed)</TD>
   <TD COLSPAN="3">Single King, Refrigerator, Microwave, (No Smoking)</TD>

<!--
##HOOK: END POST_UPDATE_HEADER_ROOM_DESCRIPTIONS                       #10/17/00
-->

   <TD COLSPAN="3">TOTALS</TD></TR>
   <TR ALIGN="CENTER">
   <TD COLSPAN="3">DATE</TD>
end_of_html

  #Print three subcolumn headings for each room column                 #10/17/00
  foreach $room (@numRms) {                                            #10/17/00
print <<end_of_html;
   <TD COLSPAN="1">A</TD>
   <TD COLSPAN="1">B</TD>
   <TD COLSPAN="1">C</TD>
end_of_html
  } #end foreach                                                       #10/17/00

#Print the three subcolumn headings for the TOTALS column.             #10/17/00
#                                                                      #10/17/00
print <<end_of_html;
   <TD COLSPAN="1">A</TD>
   <TD COLSPAN="1">B</TD>
   <TD COLSPAN="1">C</TD>
   </TR>
end_of_html

return;                                                                #11/19/00

} #end post_update_header


################################################################################
#
#   Name:     post_update_rooms
#
#   Function: Builds display for one row of an updated rooms reserved/avail-
#             able/allocated data table.  Each row corresponds to one date.
#
#   Inputs:   table row counter
#             month
#             day
#             year
#             buffer: new resState.db record (No. rooms reserved/available/allo-
#             cated by room type)
#
#   Outputs:
#
#   Caller:   room_update                    room_update.pl
#
#   Calls:    post_display_roomtype          res_utilities_html_lib.pl
#             display_roomtotals             res_utilities_html_lib.pl
#
#
#                         MODIFICATION                         DATE        BY
#
#   Harvey's Hotel/Casino                                    02/24/98   M. Lewis
#   Lakeside Inn                                             03/17/98   M. Lewis
#   Lakeside Inn   (add selective-date room-block update)    08/24/98   M. Lewis
#   Rodeway Inn                                              09/24/98   M. Lewis
# Automated system rev (duplicates PRINT_ROOMS_TOT_VALUES    10/18/00   M. Lewis
#  block in sub print_rooms)
#
sub post_update_rooms {

#print "Content-Type: text/html\n\n";

   my $j = shift(@_);
   my $month = shift(@_);
   my $day   = shift(@_);
   my $year  = shift(@_);
   local @roomValues = @_;

##HOOK: BEGIN POST_UPDATE_ROOMS_TOT_VALUES                             #10/18/00
my $totRes = $roomValues[0] + $roomValues[3] + $roomValues[6] + $roomValues[9];
my $totAvail = $roomValues[1] + $roomValues[4] + $roomValues[7] + $roomValues[10];
my $totAlloc = $roomValues[2] + $roomValues[5] + $roomValues[8] + $roomValues[11];
##HOOK: END POST-UPDATE_ROOMS_TOT_VALUES                               #10/18/00

  #Format day and year for printing
  if ($day < 10) {
    $printDay = " " . $day}
  else {
    $printDay = $day}
  #endif

  #Display table header every time 20 rows have been displayed
  #
  if ($j > 0) {                                 #$j is set in caller
    $rem = $j % 20;
    if ($rem == 0) {

print <<end_of_html;
   <!--This print block displays header of form:

        |    KS     |    KNS    |    DDS    |    DDNS   |   TOTALS
  DATE  | A | B | C | A | B | C | A | B | C | A | B | C | A | B | C

    -->

   <TR ALIGN="CENTER">
   <TD COLSPAN="3"></TD>

<!--
##HOOK: BEGIN PRINT_ROOMS_ROOM_DESCRIPTIONS                            #10/18/00
   -->
   <TD COLSPAN="3">Single King, Refrigerator, Microwave, (Smoking Allowed)</TD>
   <TD COLSPAN="3">Single Queen, Refrigerator, Microwave, (No Smoking)</TD>
   <TD COLSPAN="3">Single Queen, Refrigerator, Microwave, (Smoking Allowed)</TD>
   <TD COLSPAN="3">Single King, Refrigerator, Microwave, (No Smoking)</TD>

<!--
##HOOK: END PRINT_ROOMS_ROOM_DESCRIPTIONS                              #10/18/00
-->

   <TD COLSPAN="3">TOTALS</TD></TR>
   <TR ALIGN="CENTER">
   <TD COLSPAN="3">DATE</TD>
end_of_html

        #Print three subcolumn headings for each room column           #10/18/00
        foreach $room (@numRms) {
print <<end_of_html;
   <TD COLSPAN="1">A</TD>
   <TD COLSPAN="1">B</TD>
   <TD COLSPAN="1">C</TD>
end_of_html
        } #end foreach                                                 #10/18/00

#Print the three subcolumn headings for the TOTALS column.             #10/18/00
#                                                                      #10/18/00
print <<end_of_html;
   <TD COLSPAN="1">A</TD>
   <TD COLSPAN="1">B</TD>
   <TD COLSPAN="1">C</TD>
   </TR>
end_of_html

    } #endif
  } #endif

  $printMonth = $monthNum{$month};               #Convert month from
                                                 # num to strng
  if ($year > 99) {                                                    #10/18/00
    $year -= 100;                                                      #10/18/00
    if ($year < 10) {                            #Format year for      #10/18/00
      $year = '0' . $year}                       # printing.           #10/18/00
    # endif                                                            #10/18/00
  } #endif                                                             #10/18/00

print <<end_of_html;
   <TR ALIGN="RIGHT">
   <TD COLSPAN="3" ALIGN="CENTER" >
     <FONT SIZE="-1">$printMonth $printDay $year</TD>
   <INPUT TYPE="HIDDEN" NAME="month$j" VALUE=$month>
   <INPUT TYPE="HIDDEN" NAME="day$j" VALUE=$printDay>
   <INPUT TYPE="HIDDEN" NAME="year$j" VALUE=$year>
end_of_html

  $k = 0;
  foreach $room (@numRms) {                                            #10/18/00
    &post_display_roomtype($k);                                        #10/18/00
    $k += 3;                                    #Pnt to next rm values #10/18/00
  } #end foreach                                                       #10/18/00
  &display_roomtotals($totRes, $totAvail, $totAlloc);

  print "</TR>";

  return;

} #end post_update_rooms


################################################################################
#
#   Name:     post_update_rates
#
#   Function: Builds display for one row of an updated rates data table.  Each
#             displayed row corresponds to one date and has layout like:
#
#     mon day yr  rate00 rate01 rate02  rate10 rate11 rate12 ... ->
#       rate(i-1)0 rate(i-1)1 rate(i-1)2
#
#     where i = No. of seasons/holidays in this res system
#
#
#   Inputs:   Total No. of rates (in all rows)                          #10/29/01
#             "Display all rooms" indicator or one room key             #10/29/01
#             No. of rows for display.                                  #10/29/01
#             No. rate values per row.                                  #10/29/01
#
#   Outputs:
#
#   Caller:   rates_update.pl
#
#   Calls:    format_date                    res_utilities_lib.pl      #09/07/01
#
#
#                         MODIFICATION                         DATE        BY
#
#                                                            08/30/01   M. Lewis
# Modify header-display code to generate display for any No. 10/22/01   M. Lewis
#  of room-types/seasons/holidays.
# Strip build_header code and create call to build_header.   10/22/01   M. Lewis
#
sub post_update_rates {

#print "Content-Type: text/html\n\n";

  my $dispRms = shift(@_);                       #All rms or 1 rm key  #10/11/01
  my $numRows = shift (@_);                                            #10/29/01
  my $ratesPerRow = shift (@_);                                        #10/29/01
  my $numRmTypes = shift (@_);                                         #10/31/01

  my $i = '';
  my $j = '';
  my $rem = '';
  my $printMonth = '';                                                 #09/07/01
  my $printDay = '';                                                   #09/07/01
  my $printYear = '';                                                  #09/07/01
  my $rateNum = 0;                               #Init rate-name suffix
  my $numCols = (3 * $sortedByStartDateSize);                          #10/13/01
  my $numRmTypes = @rmKeys;                      #rmKeys def in caller.#10/13/01
  my @numRms = '';                                                     #10/21/01
  my $i = '';                                                          #10/13/01

  for ($j = 0; $j < $numRows; $j++) {
    unless ($dispRms eq 'allRooms') {
      #Next rate No. for this roomtype occurs after skipping interven- #10/31/01
      # ing rate numbers for the other roomtypes.  In general the be   #10/31/01
      # ginning rate No. on row j is:                                  #10/31/01
      #                                                                #10/31/01
      $rateNum = ($j * $numRmTypes * $ratesPerRow);                    #10/31/01
    } #end unless                                                      #10/31/01

    #Display table header every time 20 rows have been displayed
    #
    if ($j > 0) {                                 #$j is set in caller
      $rem = $j % 20;
      if ($rem == 0) {
        $i = $false;                              #Init flag to display#10/13/01
                                                  # header for one rm. #10/01/01
print <<end_of_html;
   <!--This print block displays header with form:


        |               Room Type A               |               Room Type B               |...
  DATE  |  Season/Holiday A  |  Season/Holiday B  |  Season/Holiday A  |  Season/Holiday B  |...
        | Wday | Fri  | Sat  | Wday | Fri  | Sat  | Wday | Fri  | Sat  | Wday | Fri  | Sat  |...
    -->

   <TR ALIGN="CENTER">
   <TD COLSPAN="3"></TD>
end_of_html

        &build_header($dispRms, $numCols);                             #10/22/01

      } #endif
    } #endif

    #Format day, month, and year for printing.
    #
    ($printMonth, $printDay, $printYear) =                             #09/07/01
      &format_date($FORM{'month' . $j},                                #09/07/01
                  $FORM{'day' . $j},                                   #09/07/01
                  $FORM{'year' . $j});                                 #09/07/01

print <<end_of_html;
   <TR ALIGN="RIGHT">
   <TD COLSPAN="3" ALIGN="CENTER" >
     <FONT SIZE="-1">$printMonth $printDay, $printYear</TD>
end_of_html

    #Display all rates for current row.
    #
    for ($i = 0; $i < ($ratesPerRow);
         $i++) {

print <<end_of_html;
   <TD><TT>\$$FORM{'rate' . $rateNum}</TD>
end_of_html

    $rateNum++;
    } #end for
  print "</TR>";
  } #end for

  return;

} #end post_update_rates


################################################################################
#
#   Name:     post_display_roomtype
#
#   Function: formats and displays three values for an input room type.
#
#   Inputs:   No.-rooms-reserved/available/allocated data array (defined in
#              caller)
#             Index into the data array
#
#
#   Outputs:
#
#   Caller:   post_update_rooms                    res_utilities_html_lib.pl
#
#   Calls:    display_rooms_available        res_utilities_html_lib.pl
#
#                               MODIFICATION                         DATE                  BY
#
#   Lakeside Inn   (add selective-date room-block update)    08/24/98   M. Lewis
#
sub post_display_roomtype {

   my $k = shift(@_);                            #Index into roomValues

   #Display No. rooms reserved value
print <<end_of_html;
   <TD><TT>$roomValues[$k]</TD>
end_of_html

   #Display No. rooms available value
   #
   &display_rooms_available($roomValues[$k+1]);

   #Display No. rooms allocated value
print <<end_of_html;
   <TD><TT>$roomValues[$k+2]</TD>
end_of_html

   return;
} #end post_display_roomtype


################################################################################
#
#   Name:     post_update_footer
#
#   Function: prints a buffer containing a fixed footer for the updated display
#             of rooms reserved/available/allocated for a date range input by
#             user
#
#   Inputs:
#
#   Outputs:
#
#   Caller:   room_update.pl
#             rates_update.pl                                           08/30/01
#
#   Calls:
#
#                        MODIFICATION                        DATE        BY
#
#   Lakeside Inn   (add selective-date room-block update)  08/24/98   M. Lewis
#
sub post_update_footer {

#        1         2         3         4         5         6         7         8
#23456789012345678901234567890123456789012345678901234567890123456789012345678901

print <<end_of_html;
   </TABLE>


   </BODY>
   </HTML>
end_of_html

   return;
} #end post_update_footer


################################################################################
#
#   Name:     room_block_form
#
#   Function: generates form that prompts user to enter a date range for display
#             of reserved/available/allocated rooms
#
#   Inputs:
#
#   Outputs:  start month
#             start day
#             start year
#             end month
#             end day
#             end year
#
#   Caller:   res_utilities                 res_utilities2.pl
#
#   Calls:    retrieve_room_or_rates_data.pl                           #12/24/00
#
#                               MODIFICATION                         DATE      BY
#
#   Harvey's Hotel/Casino                                    02/24/98   M. Lewis
#   Lakeside Inn                                                         04/12/98   M. Lewis
#   Lakeside Inn   (add selective-date room-block update)    07/19/98   M. Lewis
# Add dynamic path specification hooks                       08/13/00   M. Lewis
# Add hidden input "caller".                                 12/20/00   M. Lewis
#
sub room_block_form {

   print "Content-Type: text/html\n\n";

print <<end_of_html;
   <HTML>
   <HEAD>

   <script language="JavaScript">
   <!-- //hide script from old browsers

   // Use this function to retrieve a cookie.
   function getCookie(name){
      var cname = name + "=";
      var dc = document.cookie;
      if (dc.length > 0) {
         begin = dc.indexOf(cname);              //Get starting pos of name
         if (begin != -1) {
            begin += cname.length;
            end = dc.indexOf(";", begin);        //Start at begin and return
            if (end == -1) {                     // pos of first ; encountered
               end = dc.length;
               return unescape(dc.substring(begin, end))}
            //endif
         }//endif
      }
      else {
         alert("You must reenter your password\\nto process this rate request");
         return false}
      //endif
   }//end getCookie

   // Use this function to delete a cookie.  Deletion is automatic when expira-
   // tion date is set to anytime before current time.
   function delCookie(name) {
   document.cookie = name + "=; expires=Thu, 01-Jan-70 00:00:01 GMT" + "; path=/";
   return null;
   }

   function chkStatus(name) {

      if (getCookie(name)) {
         delCookie(name)}                       //If cookie exists, delete it
                                                // to force user to reenter
                                                // password next time
      else {
         return false}                          //No cookie means user didn't
      //endif                                   // enter password, get out.

   } //end chkStatus

   //end hide script -->
   </script>

   <TITLE>$form_title</TITLE>

   </HEAD>

   <BODY BGCOLOR="#ffffff">

   <!--
##HOOK: BEGIN ROOM_BLOCK_FORM PATHS                                    #08/13/00
   -->

<!--
<FORM METHOD="POST" ACTION="retrieve_room_or_rates_data.pl"
onSubmit = "return chkStatus('xwd')">
-->

<FORM METHOD="POST" ACTION="http://reservit.sourceforge.net/cgi-bin/retrieve_room_or_rates_data.pl">
<!--onSubmit = "return chkStatus('xwd')">-->

<!--
<!--
##HOOK: END ROOM_BLOCK_FORM PATHS                                      #08/13/00
   -->
   <ENCTYPE="x-www-form-urlencoded">

   <INPUT TYPE="hidden" NAME="caller" VALUE="rooms">

   <TT><FONT COLOR="#400000"><pre>
             Enter a date range.  When you "click here," you will get a table
             with one row for each date in the range you specify.  Rooms will be
             displayed by room type.  For each room type, you will see the
             number of reservations made for that date, the No. of rooms
             available for that date, and the number of rooms allocated for that
             date</PRE></FONT></TT>

<P>&nbsp;</P>
<P><CENTER><BR CLEAR="ALL">
<TABLE WIDTH="450" HEIGHT="50" BORDER="1" CELLSPACING="2" CELLPADDING="0">
<TR>
<TD WIDTH="33%" VALIGN="BOTTOM" HEIGHT="75">&nbsp;<SELECT NAME="startMonth">
<OPTION SELECTED>Start Month
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
<TD WIDTH="33%" VALIGN="BOTTOM">&nbsp;<SELECT NAME="startDay">
<OPTION SELECTED>Start Day
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
<TD WIDTH="34%" VALIGN="BOTTOM">&nbsp;<SELECT NAME="startYear">
<OPTION SELECTED >Start Year
<OPTION VALUE="03">2003
<OPTION VALUE="04">2004
<OPTION VALUE="05">2005
<OPTION VALUE="06">2006
<OPTION VALUE="07">2007
<OPTION VALUE="08">2008
</SELECT></TD></TR>

<TR>
<TD WIDTH="33%" VALIGN="BOTTOM" HEIGHT="75">&nbsp;<SELECT NAME="endMonth">
<OPTION SELECTED>End Month
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
<TD WIDTH="33%" VALIGN="BOTTOM">&nbsp;<SELECT NAME="endDay">
<OPTION SELECTED>End Day
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
<TD WIDTH="34%" VALIGN="BOTTOM">&nbsp;<SELECT NAME="endYear">
<OPTION SELECTED >End Year
<OPTION VALUE="03">2003
<OPTION VALUE="04">2004
<OPTION VALUE="05">2005
<OPTION VALUE="06">2006
<OPTION VALUE="07">2007
<OPTION VALUE="08">2008
</SELECT></TD></TR>
</TABLE>

<P>&nbsp;</CENTER></P>

   <PRE><CENTER><INPUT TYPE="submit" VALUE="Click here to display available rooms">

   <INPUT TYPE="reset" VALUE="Reset this Form"></CENTER></PRE>
   </FORM>


   <!--
   <p><IMG SRC="/cgi-sys/Count.cgi?df=tm123-harveys_res_sys.cnt">
   -->
   </BODY>
   </HTML>
end_of_html

return;
} #end room_block_form


################################################################################
#
#   Name:     print_rates_header
#
#   Function: prints a buffer containing a fixed header for the display of room
#             rates for a date range input by user
#
#   Inputs:
#
#   Outputs:
#
#   Caller:   retrieve_room_or_rates_data.pl
#
#   Calls:    build_header           res_utilities_html_lib.pl         #10/22/01
#
#                        MODIFICATION                          DATE        BY
#
# Routine based on sub print_rooms_header.                   12/22/00   M. Lewis
# Modify $numCols var & use to set COLS                      04/22/01   M. Lewis
# Major revision after not working on this for 4 months.     08/22/01   M. Lewis
# Add code to allow for display of one room type or all room 10/07/01   M. Lewis
#  types.
# Strip build_header code and create call to build_header.   10/22/01   M. Lewis
#
sub print_rates_header {

#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890

  my $dispRms = shift(@_);                       #All rms or 1 rm key  #10/07/01

  my $numCols = (3 * $sortedByStartDateSize);                          #10/07/01
  my $numRmTypes = @rmKeys;                      #rmKeys def in caller.#10/22/01
  my $tableWidth = (($numRmtypes * $numCols) + 1);                     #10/21/01
  my $i = '';                                                          #10/13/01
  my $rem = '';                                                        #10/13/01
  my $printMonth = '';                                                 #10/13/01

#  print "Content-Type: text/html\n\n";

print <<end_of_html;
   <HTML>

   <HEAD>

   <script language="JavaScript">
   <!-- //hide script from old browsers

   // Use this function to retrieve a cookie.
   function getCookie(name){
      var cname = name + "=";
      var dc = document.cookie;

      if (dc.length > 0) {
         begin = dc.indexOf(cname);              //Get starting pos of name
         if (begin != -1) {
            begin += cname.length;
            end = dc.indexOf(";", begin);        //Start at begin and return
            if (end == -1) {                     // pos of first ; encountered
               end = dc.length;
               return unescape(dc.substring(begin, end))}
            //endif
         }//endif
      }
      else {
         return false}
      //endif
   }//end getCookie


   // Use this function to delete a cookie.  Deletion is automatic when expira-
   // tion date is set to anytime before current time.
   function delCookie(name) {
   document.cookie = name + "=; expires=Thu, 01-Jan-70 00:00:01 GMT" + "; path=/";
   return null;
   }


   function chkStatus(name) {

      if (getCookie(name)) {
         delCookie(name);                       //If cookie exists, delete it
                                                // to force user to resubmit
                                                // date form next time
         return true}
      else {
         alert("You must go back to the date-entry form (previous screen)\\nand regenerate this table by resubmitting the dates");
         return false}                          //No cookie means user didn't
      //endif                                   // get here through date entry,
                                                // get out.

   } //end chkStatus

   //end hide script -->
   </script>

     <TITLE>ColdCreek Software Online Reservation System</TITLE>
   </HEAD>

   <BODY>

   <!--
##HOOK: BEGIN PRINT_RATES_HEADER PATHS
   -->

<!--
<FORM METHOD="POST" ACTION="rates_update.pl"
onSubmit = "return chkStatus('upDateRates')">
-->

<FORM METHOD="POST" ACTION="http://reservit.sourceforge.net/cgi-bin/rates_update.pl">
<!--
onSubmit = "return chkStatus('upDateRates')">
-->

<!--
##HOOK: END PRINT_RATES_HEADER PATHS
   -->

<ENCTYPE="x-www-form-urlencoded">

<INPUT TYPE="hidden" NAME="startMonth" VALUE=$FORM{'startMonth'}>
<INPUT TYPE="hidden" NAME="startDay" VALUE=$startDay>
<INPUT TYPE="hidden" NAME="startYear" VALUE=$startYear>
<INPUT TYPE="hidden" NAME="endMonth" VALUE=$FORM{'endMonth'}>
<INPUT TYPE="hidden" NAME="endDay" VALUE=$endDay>
<INPUT TYPE="hidden" NAME="endYear" VALUE=$endYear>
<INPUT TYPE="hidden" NAME="dispRms" VALUE=$dispRms>              <!--10/08/01-->

<pre>
           ***************************************************
           *                       ROOM RATES                  *
           ***************************************************

NOTE: You can change any of the rates in this table.  Enter room rates in
      dollars and cents, with no \$.  For example 345.85 (not \$345.85).
      If the rate is dollars only (e.g. 50.00), you may omit the decimal
      point and the cents digits (e.g., an entry of 50 is OK).
</pre>
   <P>&nbsp;<P>

   <TABLE WIDTH="81%" COLS="$tableWidth" BORDER="1"
    CELLSPACING="0" CELLPADDING="0">

end_of_html

  &build_header($dispRms, $numCols);                                   #10/22/01

  return;

} #end print_rates_header


################################################################################
#
#   Name:     room_rates_form
#
#   Function: generates form that prompts user to enter a date range for room-
#             rate display.
#
#   Inputs:   password
#
#   Outputs:
#
#   Caller:   res_utilities2.pl
#
#   Calls:    retrieve_room_or_rates_data.pl                           #12/24/00
#
#                           MODIFICATION                       DATE      BY
#
#   Harvey's Hotel/Casino                                    03/08/98   M. Lewis
#   Lakeside Inn                                             04/12/98   M. Lewis
#   Rodeway Inn                                              09/24/98   M. Lewis
# Add hooks for dynamic path specification                   08/13/00   M. Lewis
# Rewrite subroutine by essentially duplicating sub room_    12/18/00   M. Lewis
#  block_form code.
# Add code to display room-types dropdown menu               10/17/01   M. Lewis
# Add def of rmKeys table for generation of dropdown menu    10/21/01   M. Lewis
#
sub room_rates_form {

   my @rmKeys = keys(%roomTypes);                                      #10/21/01
   my $key = '';                                                       #10/21/01

   print "Content-Type: text/html\n\n";

print <<end_of_html;
   <HTML>
   <HEAD>

   <script language="JavaScript">
   <!-- //hide script from old browsers

   // Use this function to retrieve a cookie.
   function getCookie(name){
      var cname = name + "=";
      var dc = document.cookie;

      if (dc.length > 0) {
         begin = dc.indexOf(cname);              //Get starting pos of name
         if (begin != -1) {
            begin += cname.length;
            end = dc.indexOf(";", begin);        //Start at begin and return
            if (end == -1) {                     // pos of first ; encountered
               end = dc.length;
               return unescape(dc.substring(begin, end))}
            //endif
         }//endif
      }
      else {
         alert("You must reenter your password\\nto process this rate request");
         return false}
      //endif
   }//end getCookie

   // Use this function to delete a cookie.  Deletion is automatic when expira-
   // tion date is set to anytime before current time.
   function delCookie(name) {
   document.cookie = name + "=; expires=Thu, 01-Jan-70 00:00:01 GMT" + "; path=/";
   return null;
   }

   function chkStatus(name) {

      if (getCookie(name)) {
         delCookie(name)}                       //If cookie exists, delete it
                                                // to force user to reenter
                                                // password next time
      else {
         return false}                          //No cookie means user didn't
      //endif                                   // enter password, get out.

   } //end chkStatus

   //end hide script -->
   </script>

     <TITLE>$form_title: Display Room Rates</TITLE>
   </HEAD>
   <BODY BGCOLOR="#ffffff">
   <BODY>

   <!--
##HOOK: BEGIN ROOM_RATES_FORM PATHS                                    #08/13/00
   -->

<!--
<FORM METHOD="POST" ACTION="retrieve_room_or_rates_data.pl"
onSubmit = "return chkStatus('xwd')">
-->

<FORM METHOD="POST" ACTION="http://reservit.sourceforge.net/cgi-bin/retrieve_room_or_rates_data.pl">
<!--onSubmit = "return chkStatus('xwd')">-->

<!--
<!--
##HOOK: END ROOM_RATES_FORM PATHS                                      #08/13/00
   -->

   <ENCTYPE="x-www-form-urlencoded">

   <INPUT TYPE="hidden" NAME="caller" VALUE="rates">

   <P><CENTER><FONT SIZE=+2><b>
   $hotel_abbrev Online Reservation System: Retrieve Room Rates
   </CENTER><br><br></p>

   <TT><FONT COLOR="#400000"><pre>
             Enter a date range and select one or all rooms for
             display. When you "click here," you will get a table
             with one row for each date in the range you specify.
             The row entries are room rates for each selected
             room type.
   </PRE></FONT></TT>

<P>&nbsp;</P>
<P><CENTER><BR CLEAR="ALL">
<TABLE WIDTH="450" HEIGHT="50" BORDER="1" CELLSPACING="2" CELLPADDING="0">
<TR>
<TD WIDTH="25%" VALIGN="BOTTOM" HEIGHT="75">&nbsp;<SELECT NAME="startMonth">
<OPTION SELECTED>Start Month
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
<TD WIDTH="25%" VALIGN="BOTTOM">&nbsp;<SELECT NAME="startDay">
<OPTION SELECTED>Start Day
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

<TD WIDTH="25%" VALIGN="BOTTOM">&nbsp;<SELECT NAME="startYear">
<OPTION SELECTED >Start Year
<OPTION VALUE="03">2003
<OPTION VALUE="04">2004
<OPTION VALUE="05">2005
<OPTION VALUE="06">2006
<OPTION VALUE="07">2007
<OPTION VALUE="08">2008
</SELECT></TD>                                                   <!--10/04/01-->

<TD WIDTH="25%" VALIGN="BOTTOM"><center><BR>                     <!--10/06/01-->
  Select Room Type(s) for Display</center>&nbsp;                 <!--10/06/01-->
  <SELECT NAME="select_bed">                                     <!--10/04/01-->

<!-- disabled 11/12/01 because of problem in rates_update.pl

<OPTION VALUE="allRooms" SELECTED>                               <!--10/04/01-->
  All Room Types (display may be very large)                     <!--10/04/01-->
-->

end_of_html

#NOTE: lines with date 11/12/01 added because of disabled option above #11/12/01
#                                                                      #11/12/01
$tmpFlg = 0;                                                           #11/12/01
  foreach $key(@rmKeys) {                                              #10/17/01

    unless ($tmpFlg) {                                                 #11/12/01
      print "<OPTION VALUE=\"$key\" SELECTED>$roomTypes{$key}\n";      #11/12/01
      $tmpFlg = 1;                                                     #11/12/01
    } #end unless                                                      #11/12/01

    print "<OPTION VALUE=\"$key\">$roomTypes{$key}\n";                 #10/17/01
  } #end foreach

print <<end_of_html;
</SELECT></TD></TR>                                              <!--10/04/01-->
<TR>
<TD WIDTH="25%" VALIGN="BOTTOM" HEIGHT="75">&nbsp;<SELECT NAME="endMonth">
<OPTION SELECTED>End Month
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
<TD WIDTH="25%" VALIGN="BOTTOM">&nbsp;<SELECT NAME="endDay">
<OPTION SELECTED>End Day
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
<TD WIDTH="25%" VALIGN="BOTTOM">&nbsp;<SELECT NAME="endYear">
<OPTION SELECTED >End Year
<OPTION VALUE="03">2003
<OPTION VALUE="04">2004
<OPTION VALUE="05">2005
<OPTION VALUE="06">2006
<OPTION VALUE="07">2007
<OPTION VALUE="08">2008
</SELECT></TD></TR>
</TABLE>

<P>&nbsp;</CENTER></P>

   <PRE><CENTER><INPUT TYPE="submit" VALUE="Click here to display room rates">

   <INPUT TYPE="reset" VALUE="Reset this Form"></CENTER></PRE>
   </FORM>


   <!--
   <p><IMG SRC="/cgi-sys/Count.cgi?df=tm123-harveys_res_sys.cnt">
   -->
   </BODY>
   </HTML>
end_of_html

return;

} #end room_rates_form


################################################################################
#
#   Name:     display_rates
#
#   Function: Builds display for one row of room-rates data table.  Each row
#             corresponds to one date.  Displayed room rate(s) may then be
#             changed by the user.
#
#   Inputs:   table row counter
#             month
#             day
#             year
#             indicator: display data for all rms or one specific rm.  #09/30/01
#             buffer: global_data.pl rate presets or resState.db items
#                     (room rates).
#
#   Outputs:
#
#   Caller:   retrieve_room_or_rates_data.pl
#
#   Calls:
#
#
#                   MODIFICATION                               DATE        BY
#
#   Harvey's Hotel/Casino                                    03/08/98   M. Lewis
#   Lakeside Inn                                             04/12/98   M. Lewis
#   Lakeside Inn   (add seasonal rates)                      06/13/98   M. Lewis
#   Rodeway Inn                                              09/24/98   M. Lewis
# Add hooks for dynamic path specification                   08/13/00   M. Lewis
# Rewrite (based on sub print_rooms) for new functionality   12/19/00   M. Lewis
# Add condition to display data for all rooms or one spe-    09/30/01   M. Lewis
#  cific room.
# Add code to allow for display of one room type or all room 10/06/01   M. Lewis
#  types.
# Strip build_header code and create call to build_header.   10/22/01   M. Lewis
# Display of season/holiday header text fields follows the   10/27/01   M. Lewis
#  order of items in array sortedByStartDate (global_data.pl).
#  But the data items are retrieved from the resState table
#  record in the order in which they are stored in the rec-
#  ord, which is dictated solely by order in which the
#  seasons/holidays are defined when this reservation system
#  was built.  The retrieval code here has been changed to
#  fetch data items in sortedByStartDate order.
#
sub display_rates {
  my $j = shift(@_);                             #Row counter

  my @numRms = '';                                                     #10/22/01
  my $rateIDSeed = shift(@_);
  my $month = shift(@_);
  my $day   = shift(@_);
  my $year  = shift(@_);
  my $dispRms = shift(@_);                       #All rms or 1 rm key  #09/30/01
  my $firstRate = shift(@_);                     #rates_update.pl param#10/11/01
  local @rateValues = @_;
  my $k = '';
  my $rate = '';
  my $key = '';                                                        #10/27/01
  my $i = '';                                                          #10/27/00
  my $v ='';                                                           #10/27/01
  my $fieldPtr = '';                                                   #10/27/01
  my $fieldHold = '';                                                  #10/27/01
  my @dispKeys = '';                                                   #10/27/01

  my @rateStrngs = ('WkDayRate', 'FriRate', 'SatRate');                #10/27/01

  my $numCols = (3 * $sortedByStartDateSize);                          #10/13/01

#print "Content-Type: text/html\n\n";

  #Format day and year for printing
  if ($day < 10) {
    $printDay = " " . $day}
  else {
    $printDay = $day}
  #endif

  #Display table header every time 20 rows have been displayed
  #
  if ($j > 0) {                                 #$j is set in caller
    $rem = $j % 20;
    if ($rem == 0) {
      $i = $false;                              #Init flag to display  #10/13/01
                                                # header for one room. #10/01/01
      print <<end_of_html;
   <!--This print block displays header with form:

        |               Room Type A               |               Room Type B               |...
  DATE  |  Season/Holiday A  |  Season/Holiday B  |  Season/Holiday A  |  Season/Holiday B  |...
        | Wday | Fri  | Sat  | Wday | Fri  | Sat  | Wday | Fri  | Sat  | Wday | Fri  | Sat  |...

    -->

   <TR ALIGN="CENTER">
   <TD COLSPAN="3"></TD>
end_of_html

  &build_header($dispRms, $numCols);                                   #10/22/01

    } #endif
  } #endif

  $printMonth = $monthNum{$month};               #Convert month from
                                                 # num to strng
  if ($year > 99) {
    $year -= 100;
    if ($year < 10) {                            #Format year for
      $year = '0' . $year}                       # printing.
    # endif
  } #endif

print <<end_of_html;
   <TR ALIGN="RIGHT">
   <TD COLSPAN="3" ALIGN="CENTER" >
     <FONT SIZE="-1">$printMonth $printDay $year</TD>
   <INPUT TYPE="HIDDEN" NAME="month$j" VALUE=$month>
   <INPUT TYPE="HIDDEN" NAME="day$j" VALUE=$printDay>
   <INPUT TYPE="HIDDEN" NAME="year$j" VALUE=$year>
end_of_html

  #Retrieve data items one at a time and display them one at a time.   #10/27/01
  # If 'allRooms' is specified, display entire buffer.  Else display   #10/28/01
  # rates for the room-type whose key is in dispRms.                   #10/28/01
  #                                                                    #10/27/01
  if ($dispRms eq 'allRooms') {                                        #10/28/01
    @dispKeys = @rmKeys}                                               #10/28/01
  else {                                                               #10/28/01
    @dispKeys = $dispRms}                       #dispKeys contains only#10/27/01
  #endif                                        # a single key.        #10/27/01
  foreach $key (@dispKeys) {                                           #10/27/01
    for ($v = 0; $v < $sortedByStartDateSize;                          #10/27/01
         $v++) {                                                       #10/27/01
      $fieldPtr =                                                      #10/27/01
        $key . $sortedByStartDate[$v][2];                              #10/27/01
      $fieldHold = $fieldPtr;                                          #10/27/01
      for ($i = 0; $i < 3; $i++) {                                     #10/27/01
        $fieldPtr .= $rateStrngs[$i];                                  #10/27/01
        #Dereference fieldPtr and subtract firstRate columns from the  #10/27/01
        # result to get the item in rateValues.                        #10/27/01
        #                                                              #10/27/01
print <<end_of_html;
   <TD COLSPAN="1"><INPUT TYPE="text" NAME="rate$rateIDSeed"  SIZE="6"
         MAXLENGTH="6" VALUE=$rateValues[$$fieldPtr - $firstRate]>
   </TD>
end_of_html
        $rateIDSeed++;                           #For unique rate dis- #10/27/01
        $fieldPtr = $fieldHold;                  # play-name.          #10/27/01
      } #end for                                                       #10/27/01
    } #end foreach                                                     #10/27/01
  } #end foreach                                                       #10/27/01

print <<end_of_html;
   </TR>
   <INPUT TYPE="HIDDEN" NAME="dispRms" VALUE=$dispRms>           <!--10/11/01-->
   <INPUT TYPE="HIDDEN" NAME="firstRate" VALUE=$firstRate>       <!--10/11/01-->
end_of_html

  return;

} #end display_rates


################################################################################
#
#   Name:     post_update_rates_header
#
#   Function: generates page that displays HTML header info for updated room
#             rates from global database file
#
#   Inputs:   Date (month, day, year) strings.
#             Updated room rates (array).
#
#   Outputs:
#
#   Caller:   rates_update.pl
#
#   Calls:    build_header             res_utilities_html_lib.pl       #10/22/01
#
#                        MODIFICATION                        DATE         BY
#
#   Harvey's Hotel/Casino                                  03/09/98    M. Lewis
#   Lakeside Inn                                           04/12/98    M. Lewis
#   Lakeside Inn   (add seasonal rates)                    06/13/98    M. Lewis
#   Rodeway Inn                                            09/24/98    M. Lewis
#   Major revision for rates-maintenance utility.          08/24/01    M. Lewis
# Add code to allow for display of one room type or all room 10/08/01   M. Lewis
#  types.
# Strip build_header code and create call to build_header.   10/22/01   M. Lewis
#
sub post_update_rates_header {

#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890

  my $dispRms = shift(@_);                       #All rms or 1 rm key  #10/07/01

  my @numRms = '';                                                     #10/21/01
  my $numCols = (3 * $sortedByStartDateSize);                          #10/07/01
  my $numRmTypes = @rmKeys;                      #rmKeys def in caller.#10/22/01
  my $tableWidth = (($numRmtypess * $numCols) + 1);                    #10/21/01
  my $i = '';                                                          #10/13/01

#  print "Content-Type: text/html\n\n";

print <<end_of_html;
   <HTML>
   <HEAD>
     <TITLE>$hotel_manager Online Reservations: Updated Room Rates</TITLE>
   </HEAD>

   <BODY>

<pre>
           ***************************************************
           *                       UPDATED ROOM RATES                  *
           ***************************************************
</pre>

<ENCTYPE="x-www-form-urlencoded">
   <P>&nbsp;<P>

   <TABLE WIDTH="81%" COLS="$tableWidth" BORDER="1" CELLSPACING="0"
    CELLPADDING="0">
end_of_html

  &build_header($dispRms, $numCols);                                   #10/22/01

  return;

} #end post_update_rates_header


################################################################################
#
#   Name:     build_header
#
#   Function: generates fixed HTML room_rates header.
#
#   Inputs:   Key to No. room types (all rooms or one room) to be
#             displayed.
#
#   Outputs:
#
#   Caller:   print_rates_header        res_utilities_html_lib.pl
#             display_rates             res_utilities_html_lib.pl
#             post_update_rates_header  res_utilities_html_lib.pl
#             post_update_rates         res_utilities_html_lib.pl
#
#   Calls:
#
#                        MODIFICATION                        DATE         BY
#
#                                                          10/22/01    M. Lewis
#
sub build_header {

  my $dispRms = shift(@_);                       #All rms or 1 rm key
  my $numCols = shift(@_);

  my @numRms = '';
  my $numRmTypes = @rmKeys;                      #rmKeys def in caller.

#  print "Content-Type: text/html\n\n";

print <<end_of_html;
   <!--This print block displays header with form:

        |               Room Type A               |               Room Type B               |...
  DATE  |  Season/Holiday A  |  Season/Holiday B  |  Season/Holiday A  |  Season/Holiday B  |...
        | Wday | Fri  | Sat  | Wday | Fri  | Sat  | Wday | Fri  | Sat  | Wday | Fri  | Sat  |...
    -->

   <TR ALIGN="CENTER">
   <TD COLSPAN="3"></TD>
end_of_html

  #How many room types are requested for this display (will be
  # either all room types or one room type)?
  #
  if ($dispRms eq "allRooms") {
    for ($i = 0; $i < $numRmTypes; $i++) {
      #Generate header for each room type to be displayed.
      #
      print "<TD COLSPAN=\"$numCols\">";
      print "$roomTypes{$rmKeys[$i]}</TD>";     #$rmKeys def in caller.
    } # end for
    $numRms = $numRmTypes;
  }
  else { #dispRms contains one room-type key, use it.
    print "<TD COLSPAN=\"$numCols\">";
    print "$roomTypes{$dispRms}</TD>";
    $numRms = 1;
  } #endif

  print <<end_of_html;
</TR><BR>
<TR ALIGN="CENTER">
<TD COLSPAN="3">DATE</TD>
end_of_html

  for ($i = 0; $i < $numRms; $i++) {
    print <<end_of_html;
<!--
##HOOK: BEGIN PRINT_RATES_ROOM_DESCRIPTIONS1
   -->
   <TD COLSPAN="3">MemorialDay: 5/28/03 to 5/28/03</TD>
   <TD COLSPAN="3">MemorialDay: 5/28/03 to 5/28/03</TD>
   <TD COLSPAN="3">Summer: 6/25/03 to 9/1/03</TD>
   <TD COLSPAN="3">LaborDay: 8/29/03 to 9/1/03</TD>
   <TD COLSPAN="3">off season: 9/2/03 to 11/26/03</TD>
   <TD COLSPAN="3">Ski Season: 11/27/03 to 4/30/04</TD>
   <TD COLSPAN="3">New Year: 12/26/03 to 1/1/04</TD>
   <TD COLSPAN="3">New Years Eve: 12/31/03 to 12/31/03</TD>
   <TD COLSPAN="3">off season: 5/1/04 to 5/27/04</TD>
   <TD COLSPAN="3">MemorialDay: 5/28/04 to 5/31/04</TD>
   <TD COLSPAN="3">Summer: 6/1/04 to 9/6/04</TD>
   <TD COLSPAN="3">LaborDay: 9/3/04 to 9/6/04</TD>
   <TD COLSPAN="3">off season: 9/7/04 to 11/24/04</TD>
   <TD COLSPAN="3">Ski Season: 11/25/04 to 4/30/05</TD>
   <TD COLSPAN="3">New Year: 12/26/04 to 1/1/05</TD>
   <TD COLSPAN="3">New Years Eve: 12/31/04 to 12/31/04</TD>
   <TD COLSPAN="3">off season: 5/1/05 to 5/26/05</TD>
   <TD COLSPAN="3">MemorialDay: 5/27/05 to 5/30/05</TD>
   <TD COLSPAN="3">Summer: 5/31/05 to 9/5/05</TD>
   <TD COLSPAN="3">LaborDay: 9/2/05 to 9/5/05</TD>
   <TD COLSPAN="3">off season: 9/6/05 to 11/23/05</TD>
   <TD COLSPAN="3">Ski Season: 11/24/05 to 4/30/06</TD>
   <TD COLSPAN="3">New Year: 12/26/05 to 1/1/06</TD>
   <TD COLSPAN="3">NewYears Eve: 12/31/05 to 12/31/05</TD>
   <TD COLSPAN="3">off season: 5/1/06 to 5/25/06</TD>
   <TD COLSPAN="3">MemorialDay: 5/26/06 to 5/29/06</TD>
   <TD COLSPAN="3">Summer: 5/30/06 to 9/4/06</TD>
   <TD COLSPAN="3">LaborDay: 9/1/06 to 9/4/06</TD>
   <TD COLSPAN="3">off season: 9/5/06 to 11/22/06</TD>
   <TD COLSPAN="3">Ski Season: 11/23/06 to 4/30/07</TD>
   <TD COLSPAN="3">New Year: 12/26/06 to 1/1/07</TD>
   <TD COLSPAN="3">NewYears Eve: 12/31/06 to 12/31/06</TD>
   <TD COLSPAN="3">off season: 5/1/07 to 5/24/07</TD>
   <TD COLSPAN="3">MemorialDay: 5/25/07 to 5/28/07</TD>
   <TD COLSPAN="3">Summer: 5/28/07 to 9/3/07</TD>
   <TD COLSPAN="3">LaborDay: 8/31/07 to 9/3/07</TD>
   <TD COLSPAN="3">off season: 9/4/07 to 11/21/07</TD>
   <TD COLSPAN="3">Ski Season: 11/22/07 to 4/30/08</TD>
   <TD COLSPAN="3">New Year: 12/26/07 to 1/1/08</TD>
   <TD COLSPAN="3">NewYears Eve: 12/31/07 to 12/31/07</TD>
  <!--
##HOOK: END PRINT_RATES_ROOM_DESCRIPTIONS1
-->
end_of_html
  } #end for

  print <<end_of_html;
</TR><BR>
<TR ALIGN="CENTER">
<TD COLSPAN="3"></TD>
end_of_html

  for ($i = 0;
       $i < ($numRms *
             $sortedByStartDateSize);
       $i++) {
    print <<end_of_html;
<!--
##HOOK: BEGIN PRINT_RATES_ROOM_DESCRIPTIONS2
   -->
<TD COLSPAN="1">Weekdays</TD>
<TD COLSPAN="1">Fri</TD>
<TD COLSPAN="1">Sat</TD>
  <!--
##HOOK: END PRINT_RATES_ROOM_DESCRIPTIONS2
-->
end_of_html
  } #end for
  print "</TR>";

  return;

} #end build_header


################################################################################
#
#   Name:     invalid_date
#
#   Function: generates page: requestor entered one or more invalid start/
#             end dates
#
#   Inputs:
#
#   Outputs:
#
#   Caller:   room_block                                   room_block.pl
#
#   Calls:
#
#                                  MODIFICATION                      DATE      BY
#
#   Lakeside Inn   (add selective-date room-block update)    07/26/98   M. Lewis
#
sub invalid_date {

   print "Content-Type: text/html\n\n";

print <<end_of_html;
   <html>
   <head>
   <title>ColdCreek Software Reservations System</title></head>

   <BODY BGCOLOR="#ffffff">

   <IMG SRC ="$jpeg2url">

   <H2><B><FONT COLOR="#0080c0">
   One or more of the start/end dates that you entered is
   invalid.  Please correct and reenter.</FONT>
   </H2>
   <hr>

   </body>
   </html>
end_of_html
   return;
} #end invalid_date


################################################################################
#
#   Name:     invalid_date_range
#
#   Function: generates page: requestor entered one or more dates outside the
#             permissible date range.
#
#   Inputs:
#
#   Outputs:
#
#   Caller:   room_block                                   room_block.pl
#
#   Calls:
#
#                                   MODIFICATION                    DATE       BY
#
#   Rodeway Inn                                             09/23/98    M. Lewis
#
sub invalid_date_range {

#  print "Content-Type: text/html\n\n";

print <<end_of_html;
   <html>
   <head>
   <title>ColdCreek Software Reservations System</title></head>

   <BODY BGCOLOR="#ffffff">

   <IMG SRC ="$jpeg2url">

   <H2><B><FONT COLOR="#0080c0">
   The start date cannot be earlier than today's date.  The end date must not
   be later than one year from today's date.</FONT>
   </H2>
   <hr>

   </body>
   </html>
end_of_html
   return;
} #end invalid_date_range


################################################################################
#
#   Name:     invalid_rate_entry
#
#   Function: displays page: user entered a rate with an invalid format
#
#   Inputs:   date string (mmm dd, yy).
#             invalid rate value
#
#   Outputs:
#
#   Caller:   check_rate                          rates_update.pl
#
#   Calls:
#
#              MODIFICATION                                  DATE         BY
#
#                                                          09/07/01    M. Lewis
#
sub invalid_rate_entry {

   my $rate = shift(@_);
   my $date = shift(@_);

print "Content-Type: text/html\n\n";

print <<end_of_html;
  <HTML>
  <HEAD>
  <title>ColdCreek Software Reservations System</title>
  </HEAD>

  <BODY>
  <IMG SRC ="$jpeg2url">

  <H2><FONT COLOR="#0080c0">
  Your rate entry: $rate for $date is invalid.  The required format
  is one to three digits followed by decimal point followed by two digits,
  e.g. 123.45.  Please correct and reenter.
  </H2>
  <HR>
  <P>Press <B>Back</B> at top left of screen to return to the previous form.

        </BODY>
        </HTML>
end_of_html
  exit;
} #end invalid_rate_entry


################################################################################
#
#   Name:     no_rate_entry
#
#   Function: displays page: user didn't enter a rate value
#
#   Inputs:   date string (mmm dd, yy)
#
#   Outputs:
#
#   Caller:   check_rate                      rates_update.pl
#
#   Calls:
#
#            MODIFICATION                                    DATE        BY
#
#                                                          09/07/01   M. Lewis
#
sub no_rate_entry {

  my $date = shift(@_);

print "Content-Type: text/html\n\n";

print <<end_of_html;
        <HTML>
  <HEAD>
  <title>ColdCreek Software Reservations System</title>
  </HEAD>

  <BODY>
  <IMG SRC ="$jpeg2url">

  <H2><FONT COLOR="#0080c0">
  You didn't enter a rate for $date.  The required format
  is one to three digits followed by decimal point followed by two digits,
  e.g. 123.45.  Please go back and enter a valid rate.
  </H2>
  <HR>
  <P>Press <B>Back</B> at top left of screen to return to the previous form.

        </BODY>
        </HTML>
end_of_html
  exit;
} #end no_rate_entry


1;

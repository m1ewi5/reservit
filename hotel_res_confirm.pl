#!/usr/bin/perl
require('global_data.pl');

################################################################################
#
#   Name:     hotel_res_confirm
#
#   Function: HTML form accepts reservation completion entries from hotel staff
#
#   Inputs:   The following values are passed through from selections_available:
#               password
#               arrive month
#               arrive day
#               arrive year
#               depart month
#               depart day
#               depart year
#               No. guests
#               bed selection
#               pets preference
#               pets rate
#               pets amount
#               rollaway request
#               rollaway rate
#               rollaway amount
#               total amount for reservation
#               reservation deposit amount
#               No. reservation days (for any defined seasons/holidays)
#               subtotal amount                                        #09/14/01
#               room-tax rate                                          #09/14/01
#               room-tax amount                                        #09/14/01
#               other-tax rate                                         #09/14/01
#               other-tax amount                                       #09/14/01
#
#   Outputs:  customer name
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
#
#   Caller:   selections_available      open_html_lib.pl
#
#   Calls:    hotel_res_complete        hotel_res_complete.pl
#
#                          MODIFICATION                      DATE        BY
#
#   Lakeside Inn                                           04/11/98   M. Lewis
#   Lakeside Inn   (add seasonal rates)                    06/13/98   M. Lewis
#   Lakeside Inn   (add weekend cruise flag)               06/15/98   M. Lewis
#   Rodeway Inn                                            09/15/98   M. Lewis
# Automated system update (mostly from res_confirm.pl)       08/27/00   M. Lewis
# Add code for subtotal, tax rate and tax amount.            09/13/01   M. Lewis
#
#################################################5#############################8
#Begin comments at col 50, end at 80:            0                             0

#   Variables

#   Constants
$completePath = $openUrl . 'hotel_res_complete.pl';

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

} #end while/foreach

print "Content-Type: text/html\n\n";

print <<end_of_html;

<FORM METHOD="POST" ACTION="$completePath">

<!--
<FORM METHOD="POST" ACTION="/cgi-sys/cgiwrapd/tm123/lakeside/hotel_res_complete.pl">
-->

<HTML>
<HEAD>
  <TITLE>$sys_manager Online Reservations System: Hotel Staff Reservation Confirm
  Form</TITLE>
</HEAD>
<BODY BGCOLOR="#ffffff">

<P><CENTER><ENCTYPE="x-www-form-urlencoded">

<!--
##HOOK: BEGIN DEFINE HIDDEN INPUTS-->
   <INPUT TYPE="hidden" NAME="MemorialDayWkDay" VALUE=$FORM{'MemorialDayWkDay'}>
   <INPUT TYPE="hidden" NAME="MemorialDayFri" VALUE=$FORM{'MemorialDayFri'}>
   <INPUT TYPE="hidden" NAME="MemorialDaySat" VALUE=$FORM{'MemorialDaySat'}>
   <INPUT TYPE="hidden" NAME="NewYearsEveWkDay" VALUE=$FORM{'NewYearsEveWkDay'}>
   <INPUT TYPE="hidden" NAME="NewYearsEveFri" VALUE=$FORM{'NewYearsEveFri'}>
   <INPUT TYPE="hidden" NAME="NewYearsEveSat" VALUE=$FORM{'NewYearsEveSat'}>
   <INPUT TYPE="hidden" NAME="LaborDayWkDay" VALUE=$FORM{'LaborDayWkDay'}>
   <INPUT TYPE="hidden" NAME="LaborDayFri" VALUE=$FORM{'LaborDayFri'}>
   <INPUT TYPE="hidden" NAME="LaborDaySat" VALUE=$FORM{'LaborDaySat'}>
   <INPUT TYPE="hidden" NAME="LaborDayWkDay" VALUE=$FORM{'LaborDayWkDay'}>
   <INPUT TYPE="hidden" NAME="LaborDayFri" VALUE=$FORM{'LaborDayFri'}>
   <INPUT TYPE="hidden" NAME="LaborDaySat" VALUE=$FORM{'LaborDaySat'}>
   <INPUT TYPE="hidden" NAME="SkiSeasonWkDay" VALUE=$FORM{'SkiSeasonWkDay'}>
   <INPUT TYPE="hidden" NAME="SkiSeasonFri" VALUE=$FORM{'SkiSeasonFri'}>
   <INPUT TYPE="hidden" NAME="SkiSeasonSat" VALUE=$FORM{'SkiSeasonSat'}>
   <INPUT TYPE="hidden" NAME="NewYearsEveWkDay" VALUE=$FORM{'NewYearsEveWkDay'}>
   <INPUT TYPE="hidden" NAME="NewYearsEveFri" VALUE=$FORM{'NewYearsEveFri'}>
   <INPUT TYPE="hidden" NAME="NewYearsEveSat" VALUE=$FORM{'NewYearsEveSat'}>
   <INPUT TYPE="hidden" NAME="NewYearsEveWkDay" VALUE=$FORM{'NewYearsEveWkDay'}>
   <INPUT TYPE="hidden" NAME="NewYearsEveFri" VALUE=$FORM{'NewYearsEveFri'}>
   <INPUT TYPE="hidden" NAME="NewYearsEveSat" VALUE=$FORM{'NewYearsEveSat'}>
   <INPUT TYPE="hidden" NAME="SkiSeasonWkDay" VALUE=$FORM{'SkiSeasonWkDay'}>
   <INPUT TYPE="hidden" NAME="SkiSeasonFri" VALUE=$FORM{'SkiSeasonFri'}>
   <INPUT TYPE="hidden" NAME="SkiSeasonSat" VALUE=$FORM{'SkiSeasonSat'}>
<!--
##HOOK: END DEFINE HIDDEN INPUTS
-->
                                                                 <!--09/13/01-->
<INPUT TYPE="hidden" NAME="subTotAmtf" VALUE=$FORM{'subTotAmtf'}>

<INPUT TYPE="hidden" NAME="total amountf" VALUE=$FORM{'total amountf'}>
<INPUT TYPE="hidden" NAME="arrive_month" VALUE=$FORM{'arrive_month'}>
<INPUT TYPE="hidden" NAME="arrive_day" VALUE=$FORM{'arrive_day'}>
<INPUT TYPE="hidden" NAME="arrive_year" VALUE=$FORM{'arrive_year'}>
<INPUT TYPE="hidden" NAME="depart_month" VALUE=$FORM{'depart_month'}>
<INPUT TYPE="hidden" NAME="depart_day" VALUE=$FORM{'depart_day'}>
<INPUT TYPE="hidden" NAME="depart_year" VALUE=$FORM{'depart_year'}>
<INPUT TYPE="hidden" NAME="Person_Cnt" VALUE=$FORM{'Person_Cnt'}>
<INPUT TYPE="hidden" NAME="select_bed" VALUE=$FORM{select_bed}>
<INPUT TYPE="hidden" NAME="number days" VALUE=$FORM{'number days'}>
<INPUT TYPE="hidden" NAME="have_pets" VALUE=$FORM{'have_pets'}>
<INPUT TYPE="hidden" NAME="petsAmtf" VALUE=$FORM{'petsAmtf'}>
<INPUT TYPE="hidden" NAME="petRatef" VALUE=$FORM{'petRatef'}>
<INPUT TYPE="hidden" NAME="require_rollaway" VALUE=$FORM{'require_rollaway'}>
<INPUT TYPE="hidden" NAME="rollAmtf" VALUE=$FORM{'rollAmtf'}>
<INPUT TYPE="hidden" NAME="rollawayRatef" VALUE=$FORM{'rollawayRatef'}>
<INPUT TYPE="hidden" NAME="depositf" VALUE=$FORM{'depositf'}>
<!--12/09/99-->
<INPUT TYPE="hidden" NAME="taxFactorf" VALUE=$FORM{'taxFactorf'}>
<!--12/09/99-->
<INPUT TYPE="hidden" NAME="rmDescription" VALUE="$FORM{'rmDescription'}">
<INPUT TYPE="hidden" NAME="passwd" VALUE="$FORM{'passwd'}">
<INPUT TYPE="hidden" NAME="room_taxFactorf"
  VALUE=$FORM{'room_taxFactorf'}>                                <!--09/13/01-->
<INPUT TYPE="hidden" NAME="taxf" VALUE=$FORM{'taxf'}>            <!--09/13/01-->
<INPUT TYPE="hidden" NAME="roomTaxf" VALUE=$FORM{'roomTaxf'}>    <!--09/13/01-->
end_of_html

#Pass room rate & date values on to subsequent processes.              #12/09/99
#                                                                      #12/09/99
for ($i = 0; $i < $FORM{'number days'}; $i++) {                        #12/09/99
  $hideName = 'date' . $i;                                             #12/09/99
  print "<INPUT TYPE=\"hidden\" NAME=$hideName \n";                    #12/09/99
  print "VALUE=\"$FORM{$hideName}\">\n";                               #12/09/99
  #                                                                    #12/09/99
  $hideName = 'amt' . $i;                                              #12/09/99
  print "<INPUT TYPE=\"hidden\" NAME=$hideName \n";                    #12/09/99
  print "VALUE=$FORM{$hideName}>\n";                                   #12/09/99
  #                                                                    #12/09/99
  $hideName = 'wkDay' . $i;                                            #12/09/99
  print "<INPUT TYPE=\"hidden\" NAME=$hideName \n";                    #12/09/99
  print "VALUE=\"$FORM{$hideName}\">\n";                               #12/09/99
  #                                                                    #12/09/99
  $hideName = 'dayType' . $i;                                          #12/09/99
  print "<INPUT TYPE=\"hidden\" NAME=$hideName \n";                    #12/09/99
  print "VALUE=\"$FORM{$hideName}\">\n";                               #08/06/00
}#end for

print <<end_of_html;

</CENTER></P>

<P><CENTER><B><FONT SIZE=+1>
Hotel Staff Reservation Confirmation Form<BR>
To confirm this reservation at $hotel_manager, complete all required
fields plus optional fields of your choice and submit form
using the button at the bottom of the page:</FONT></B></CENTER></P>

<P>
<B>
<TABLE WIDTH="450" BORDER="1" CELLSPACING="2" CELLPADDING="0">
<TR>
<TD WIDTH="50%">&nbsp;<TT>First Name (Required): <INPUT NAME="firstName"
SIZE="30" MAXLENGTH="100" TYPE="text"></TT></TD>
<TR>
<TD WIDTH="50%">&nbsp;<TT>Last Name (Required): <INPUT NAME="lastName" SIZE="30"
MAXLENGTH="100" TYPE="text"></TT></TD>
<TD WIDTH="50%">&nbsp;<TT>Address (Required):<INPUT NAME="Address1" SIZE="35"
MAXLENGTH="100" TYPE="text"></TT></TD></TR>
<TR>
<TD WIDTH="50%">&nbsp;<TT>Company: <br><INPUT NAME="Company" SIZE="30"
MAXLENGTH="100" TYPE="text"> </TT></TD>
<TD WIDTH="50%">&nbsp;<TT>Address: <br><INPUT NAME="Address2" SIZE="35"
MAXLENGTH="100" TYPE="text"></TT></TD></TR>
<TR>
<TD WIDTH="50%">&nbsp;<TT>City (Required): <br><INPUT NAME="City" SIZE="20"
MAXLENGTH="100" TYPE="text"></TT></TD>
<TD COLSPAN="1">&nbsp;<TT>State/Province (Required):<BR>
<SELECT NAME="State">
<OPTION SELECTED>Select State
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
<TD COLSPAN="1">&nbsp;<TT>Zip/Postal Code (Required):<br><INPUT NAME="Zip" SIZE="10" MAXLENGTH=
"10" TYPE="text"></TT></TD>
<TD COLSPAN="1">&nbsp;<TT>Country:<BR>
<SELECT NAME="Country">
<OPTION SELECTED>United States
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
<TD COLSPAN="1">&nbsp;<TT>Email:<br><INPUT NAME="Email" SIZE="15" MAXLENGTH="100"
TYPE="text"> </TT></TD>
<TD COLSPAN="1">&nbsp;<TT>Home Phone (Required):<br><INPUT NAME="Home_Phone" SIZE="14" MAXLENGTH=
"14" TYPE="text"></TT></TD></TR>
<TD COLSPAN="1">&nbsp;<TT>Work Phone: <BR>
<INPUT NAME="Work_Phone" SIZE="14" MAXLENGTH="14" TYPE="text"></TT></TD>
<TD COLSPAN="1">&nbsp;<TT>Fax Number: <BR>
<INPUT NAME="Fax_Number" SIZE="14" MAXLENGTH="14" TYPE="text"></TT></TD></TR>
<TR>
<TD COLSPAN="1"><P >&nbsp;<TT>Best Time to Call: <br></TT><INPUT NAME=
"CallTime" SIZE="15" MAXLENGTH="50" TYPE="text"></TD></TR>
</TABLE></CENTER>
</P>

<P><CENTER>Comments or requests: <BR>
<TEXTAREA NAME="Comments" ROWS="5" COLS="60" wrap="soft"
>
</TEXTAREA></CENTER></P>

<p><CENTER><INPUT TYPE="submit" VALUE="Click here to confirm this reservation"></p>
<p><center><INPUT TYPE="reset" VALUE="Clear this Form"><BR>

</FORM>
</BODY>
</HTML>

end_of_html

exit;

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

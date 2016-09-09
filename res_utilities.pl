#!/usr/bin/perl

################################################################################
#
#   Name:     res_utilities.pl
#
#   Function: generates form that prompts user to choose a function and enter a
#             password.
#
#   Inputs:
#
#   Outputs:  password
#             function specifier
#
#   Caller:
#
#   Calls:    res_utilities2.pl
#
#                        MODIFICATION                              DATE       BY
#
#   Harvey's Hotel/Casino                                  03/09/98   M. Lewis
#   Lakeside Inn   (add selective-date room-block update)  08/29/98   M. Lewis
#   Rodeway Inn                                            09/11/98   M. Lewis
#   automated system revision (update passwords)           05/24/99   M. Lewis
# Changed from standalone html file to Perl script           08/09/00   M. Lewis
# Add HOOK delimiters for pathnames                          08/11/00   M. Lewis
# Removed option to select updates of global room presets    12/1/00    M. Lewis
#
#Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis

print "Content-Type: text/html\n\n";

print <<end_of_html;
<HTML>
<HEAD>
<script language="JavaScript">

<!-- //hide script from old browsers
passWdMsg = 'You must enter a password to use these utilities';
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
setCookie(xwd, "true", exp);            // save the cookie
return true;
}

function chk_submit(passwd, oldPW)
{
   if (passwd.value == "") {
      alert(passWdMsg);
      return false}
   else {
      if (passwd.value != oldPW) {
         alert('Please reenter password');
         passwd.value = "";
         return false}
      else {
         if (makeCookie(passwd.value)) {
           return true}}
         //endif
      //endif
   }//endif
} //end chk_submit

//end hide script -->
</script>

  <TITLE>ColdCreek Software Online Reservations: System Utilities</TITLE>
</HEAD>

<BODY>

   <!--
##HOOK: BEGIN PATHS
   -->

<!--
<FORM METHOD="POST" ACTION="res_utilities2.pl"
onSubmit = "return chk_submit(xwd, oldPswd)">
-->

<FORM METHOD="POST" ACTION="http://reservit.sourceforge.net/cgi-bin/res_utilities2.pl"
onSubmit = "return chk_submit(xwd, oldPswd)">

<!--
##HOOK: END PATHS
   -->

<ENCTYPE="x-www-form-urlencoded">

<P><CENTER><FONT SIZE=+2><b>Online Reservations: System Utilities</CENTER>
<br><br></p>

<P><CENTER><B><BR>
<BR>
</B><TABLE WIDTH="750" BORDER="1" CELLSPACING="2" CELLPADDING="0">
<TR>
<TD WIDTH="25%"><P>&nbsp;<B><INPUT TYPE="radio" VALUE="reserve" NAME="utility"
CHECKED>Enter New Reservation</B></TD>
<TD WIDTH="25%"><P>&nbsp;<B><INPUT TYPE="radio" VALUE="cancel" NAME="utility">
Cancel Reservation</B></TD>
<TD WIDTH="25%"><P>&nbsp;<B><INPUT TYPE="radio" VALUE="display" NAME="utility">
Display Reservations </B></TD>
</TR>

<TR>
<TD WIDTH="25%"><P>&nbsp;<B><INPUT TYPE="radio" VALUE="block" NAME="utility">
View/Update Room Data</B></TD>
<TD WIDTH="25%"><P>&nbsp;<B><INPUT TYPE="radio" VALUE="rates" NAME="utility">
Update Room Rates</B></TD>
<TD WIDTH="25%"><P>&nbsp;<B><INPUT TYPE="radio" VALUE="passwd" NAME="utility">
Update Passwords</B></TD>
</TR>
</TABLE>
</CENTER></P>

<P><CENTER><FONT SIZE=+1><B>Enter password: </B><INPUT TYPE="password" NAME="xwd" SIZE="20"
MAXLENGTH="20" onFocus="xwd.value=''"; onBlur="oldPswd=xwd.value";></CENTER></P>

<PRE><CENTER>
  <INPUT TYPE="submit" VALUE="Select Utility">

  <INPUT TYPE="reset" VALUE="Clear this Form">
</CENTER></PRE><BR><BR><BR>
</FORM>

<!--
Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis
-->
</BODY>
</HTML>
end_of_html

exit;

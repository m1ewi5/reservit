#!/usr/bin/perl
require('global_data.pl');


################################################################################
#
#   Name:     change_passwd_form
#
#   Function: generates form that allows user to change an existing password
#
#   Inputs:
#
#   Outputs:    Existing user name and new password for that user name

#   Caller:   password_utilities.pl
#
#   Calls:    password_utilities_processing.pl
#
#                                                                                       MODIFICATION                                                                                                     DATE                            BY
#
#                                                                                                                                                                                                                        05/24/99   M. Lewis
#
#Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis
#
sub change_passwd_form {

  my $actionFile = $openUrl . "passwd_utilities_processing.pl";

  print "Content-Type: text/html\n\n";

print <<end_of_html;
  <HTML>
  <!--
  Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis
  -->
  <HEAD>
    <TITLE>$form_title: Modify Password</TITLE>
  </HEAD>
  <BODY>

  <!--
  <FORM METHOD="POST"
   ACTION="/cgi-sys/cgiwrapd/tm123/automated_sys/passwd_utilities_processing.pl">
  -->

  <FORM METHOD="POST" ACTION="$actionFile" >

  <ENCTYPE="x-www-form-urlencoded">

        <P><CENTER>
        Enter a new password and its existing user name in the fields below.  Maximum
        password length is 20 characters (any combination of letters, spaces, digits,
        special characters).  Then click the submit button.  NOTE: your password entry will
        not be echoed back to you,
        so be sure to enter the new password EXACTLY as you intend to use it.

        <P><CENTER>
  <TABLE WIDTH="81%" COLS="2" BORDER="1" CELLSPACING="1" CELLPADDING="1">

  <TR>
  <TD COLSPAN="1"><CENTER><B>New Password</TD>
  <TD COLSPAN="1"><CENTER><B>Current User Name</TD>
  </TR>

        <TR>
        <TD COLSPAN="1"><CENTER><INPUT NAME="chgPassWd" SIZE="20" MAXLENGTH="20"
         TYPE="password" VALUE=""></TD>
        <TD COLSPAN="1"><CENTER><INPUT NAME="usrName" SIZE="20"
         MAXLENGTH="20" TYPE="text" VALUE=""></TD>
        </TR>

        </TABLE>
        </CENTER></P>

        <P><PRE><CENTER>
  <INPUT TYPE="submit" VALUE="Click to change">

  <INPUT TYPE="reset" VALUE="Clear this Form"><BR>
        </CENTER><BR>
        </FORM>

        <!--
        Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis
        -->
        </BODY>
        </HTML>
end_of_html

} #end change_passwd_form


################################################################################
#
#   Name:     add_passwd_form
#
#   Function: generates form that allows user to add new password/username
#
#   Inputs:
#
#   Outputs:

#   Caller:   password_utilities.pl
#
#   Calls:    password_utilities_processing.pl
#
#                                                                                       MODIFICATION                                                                                                     DATE                            BY
#
#                                                                                                                                                                                                                        06/16/99   M. Lewis
#
#Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis
#
sub add_passwd_form {

  my $actionFile = $openUrl . "passwd_utilities_processing.pl";

  print "Content-Type: text/html\n\n";

print <<end_of_html;
  <HTML>
  <!--
  Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis
   -->
  <HEAD>
    <TITLE>$form_title: Modify Password</TITLE>
  </HEAD>
  <BODY>

  <!--
  <FORM METHOD="POST"
   ACTION="/cgi-sys/cgiwrapd/tm123/automated_sys/passwd_utilities_processing.pl">
  -->

  <FORM METHOD="POST" ACTION="$actionFile" >

  <ENCTYPE="x-www-form-urlencoded">

        <P><CENTER>
        Enter a new password and new user name in the fields below.  Maximum
        password length is 20 characters (any combination of letters, spaces, digits,
        special characters).  Then click the submit button.  NOTE: your password entry will
        not be echoed back to you,
        so be sure to enter the new password EXACTLY as you intend to use it.

        <P><CENTER>
  <TABLE WIDTH="81%" COLS="2" BORDER="1" CELLSPACING="1" CELLPADDING="1">

  <TR>
  <TD COLSPAN="1"><CENTER><B>New Password</TD>
  <TD COLSPAN="1"><CENTER><B>New User Name</TD>
  </TR>

        <TR>
        <TD COLSPAN="1"><CENTER><INPUT NAME="newPassWd" SIZE="20" MAXLENGTH="20"
         TYPE="password" VALUE=""></TD>
        <TD COLSPAN="1"><CENTER><INPUT NAME="usrName" SIZE="20"
         MAXLENGTH="20" TYPE="text" VALUE=""></TD>
        </TR>

        </TABLE>
        </CENTER></P>

        <P><PRE><CENTER>
  <INPUT TYPE="submit" VALUE="Click to add">

  <INPUT TYPE="reset" VALUE="Clear this Form"><BR>
        </CENTER><BR>
        </FORM>

        <!--
        Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis
        -->
        </BODY>
        </HTML>
end_of_html

return;
} #end add_passwd_form


################################################################################
#
#   Name:     delete_passwd_form
#
#   Function: generates form that prompts user to delete a password/username
#
#   Inputs:
#
#   Outputs:

#   Caller:   password_utilities.pl
#
#   Calls:    password_utilities_processing.pl
#
#                                                                                       MODIFICATION                                                                                                     DATE                            BY
#
#                                                                                                                                                                                                                        06/16/99   M. Lewis
#
#Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis
#
sub delete_passwd_form {

  my $actionFile = $openUrl . "passwd_utilities_processing.pl";

  print "Content-Type: text/html\n\n";

print <<end_of_html;
  <HTML>
  <!--
  Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis
  -->
  <HEAD>
    <TITLE>$form_title: Modify Password</TITLE>
  </HEAD>
  <BODY>

  <!--
  <FORM METHOD="POST"
   ACTION="/cgi-sys/cgiwrapd/tm123/automated_sys/passwd_utilities_processing.pl">
  -->

  <FORM METHOD="POST" ACTION="$actionFile" >

  <ENCTYPE="x-www-form-urlencoded">

        <P><CENTER>
        Enter the user-name that you want to have removed from access to reservation
        system utilities.

        <P><CENTER>
  <TABLE WIDTH="40%" COLS="1" BORDER="1" CELLSPACING="1" CELLPADDING="1">

  <TR>
  <TD COLSPAN="1"><CENTER><B>User Name to be Deleted</TD>
  </TR>

        <TR>
        <TD COLSPAN="1"><CENTER><INPUT NAME="delUsrName" SIZE="20"
         MAXLENGTH="20" TYPE="text" VALUE=""></TD>
        </TR>

        </TABLE>
        </CENTER></P>

        <P><PRE><CENTER>
  <INPUT TYPE="submit" VALUE="Click to delete">

  <INPUT TYPE="reset" VALUE="Clear this Form"><BR>
        </CENTER><BR>
        </FORM>

        <!--
        Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis
        -->
        </BODY>
        </HTML>
end_of_html

return;
} #end delete_passwd_form


################################################################################
#
#   Name:     post_change_passwd
#
#   Function: Acknowledges password change to user
#
#   Inputs:   User name associated with changed password
#
#   Outputs:
#
#   Caller:   change_passwd                                                                                     passwd_utilities_processing.pl
#
#   Calls:
#
#                                                                                       MODIFICATION                                                                                                            DATE                     BY
#
#                                                                                                                                                                                                                        06/16/99   M. Lewis
#
#Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis

sub post_change_passwd {

   my $userName = shift(@_);

print "Content-Type: text/html\n\n";

print <<end_of_html;
        <HTML>
  <HEAD>
  <title>ColdCreek Software Reservations System</title>
  </HEAD>

  <BODY>
  <IMG SRC ="$jpeg2url">

  <H2><FONT COLOR="#0080c0">
  Password change for user $userName accepted.
  </H2>
  <HR>
  <P>Press <B>Back</B> at top left of screen to return to the previous form.

        <!--
        Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis
        -->
        </BODY>
        </HTML>
end_of_html

return;
} #end post_change_passwd


################################################################################
#
#   Name:     bad_username
#
#   Function: Displays invalid user name to user
#
#   Inputs:   User name associated with changed password
#
#   Outputs:
#
#   Caller:   change_passwd                                                                                     passwd_utilities_processing.pl
#
#   Calls:
#
#                                                                                       MODIFICATION                                                                                                            DATE                     BY
#
#                                                                                                                                                                                                                        06/16/99   M. Lewis
#
#Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis

sub bad_username {

   my $userName = shift(@_);

print "Content-Type: text/html\n\n";

print <<end_of_html;
        <HTML>
  <HEAD>
  <title>ColdCreek Software Reservations System</title>
  </HEAD>

  <BODY>
  <IMG SRC ="$jpeg2url">

  <H2><FONT COLOR="#0080c0">
  $userName does not exist.  Please go back to previous form and correct.
  </H2>
  <HR>

        <!--
        Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis
        -->
        </BODY>
        </HTML>
end_of_html

return;

} #end bad_username


################################################################################
#
#   Name:     dup_username
#
#   Function: Displays message: username already exists
#
#   Inputs:   User name
#
#   Outputs:
#
#   Caller:   new_passwd                                                                                        passwd_utilities_processing.pl
#
#   Calls:
#
#                                                                                       MODIFICATION                                                                                                            DATE                     BY
#
#                                                                                                                                                                                                                        06/21/99   M. Lewis
#
#Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis

sub dup_username {

   my $userName = shift(@_);

print "Content-Type: text/html\n\n";

print <<end_of_html;
        <HTML>
  <HEAD>
  <title>ColdCreek Software Reservations System</title>
  </HEAD>

  <BODY>
  <IMG SRC ="$jpeg2url">

  <H2><FONT COLOR="#0080c0">
  $userName already exists.  Please go back to previous form and enter a new name.
  </H2>
  <HR>

        <!--
        Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis
        -->
        </BODY>
        </HTML>
end_of_html

return;

} #end dup_username


################################################################################
#
#   Name:     duplicate_passwd
#
#   Function: Displays message: this password already used
#
#   Inputs:
#
#   Outputs:
#
#   Caller:   change_passwd                                                                                     passwd_utilities_processing.pl
#             new_passwd                                                                                                passwd_utilities_processing.pl
#
#   Calls:
#
#                                                                                       MODIFICATION                                                                                                            DATE                     BY
#
#
#                                                                                                                                                                                                                        06/16/99   M. Lewis
#
#Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis

sub duplicate_passwd {

print "Content-Type: text/html\n\n";

print <<end_of_html;
        <HTML>
  <HEAD>
  <title>ColdCreek Software Reservations System</title>
  </HEAD>

  <BODY>
  <IMG SRC ="$jpeg2url">

  <H2><FONT COLOR="#0080c0">
  The password you have selected has already been used.  Please go back to
  the previous form and change your entry.
  </H2>
  <HR>

        <!--
        Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis
        -->
        </BODY>
        </HTML>
end_of_html

return;

} #end duplicate_passwd


################################################################################
#
#   Name:     post_new_passwd
#
#   Function: Acknowledges password/username creation
#
#   Inputs:   User name associated with new password
#
#   Outputs:
#
#   Caller:   new_passwd                                                                                        passwd_utilities_processing.pl
#
#   Calls:
#
#                                                                                       MODIFICATION                                                                                                            DATE                     BY
#
#                                                                                                                                                                                                                        06/16/99   M. Lewis
#
#Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis

sub post_new_passwd {

   my $userName = shift(@_);

print "Content-Type: text/html\n\n";

print <<end_of_html;
        <HTML>
  <HEAD>
  <title>ColdCreek Software Reservations System</title>
  </HEAD>

  <BODY>
  <IMG SRC ="$jpeg2url">

  <H2><FONT COLOR="#0080c0">
  Password/username for new user $userName created.
  </H2>
  <HR>
  <P>Press <B>Back</B> at top left of screen to return to the previous form.

        <!--
        Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis
        -->
        </BODY>
        </HTML>
end_of_html

return;
} #end post_new_passwd


################################################################################
#
#   Name:     post_delete_user
#
#   Function: Acknowledges user-name deletion from access list
#
#   Inputs:   User name to be deleted
#
#   Outputs:
#
#   Caller:   delete_user                                                                                       passwd_utilities_processing.pl
#
#   Calls:
#
#                                                                                       MODIFICATION                                                                                                            DATE                     BY
#
#                                                                                                                                                                                                                        06/17/99   M. Lewis
#
#Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis

sub post_delete_user {

   my $userName = shift(@_);

print "Content-Type: text/html\n\n";

print <<end_of_html;
        <HTML>
  <HEAD>
  <title>ColdCreek Software Reservations System</title>
  </HEAD>

  <BODY>
  <IMG SRC ="$jpeg2url">

  <H2><FONT COLOR="#0080c0">
  User $userName removed from reservation system utilities access list.
  </H2>
  <HR>
  <P>Press <B>Back</B> at top left of screen to return to the previous form.

        <!--
        Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis
        -->
        </BODY>
        </HTML>
end_of_html

return;
} #end post_delete_user


1;

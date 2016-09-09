#!/usr/bin/perl
require('global_data.pl');
require('passwd_utilities_html_lib.pl');
use File::Copy;

################################################################################
#
#   Name:     passwd_utilities_processing
#
#   Function: Calls password-utility function based on user input
#
#   Inputs:   function specifier
#
#   Outputs:
#
#   Caller:   password_utilities.pl
#
#   Calls:    change_passwd                passwd_utilities_processing.pl
#             new_passwd                   passwd_utilities_processing.pl
#             delete_user                  passwd_utilities_processing.pl
#
#               MODIFICATION                               DATE        BY
#
#                                                        05/25/99   M. Lewis
#
################################################################################

#Variables

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
} #end while/foreach

#Process selected function
#
if (exists($FORM{'chgPassWd'})) {                #Modify existing password
  &change_passwd}
elsif (exists($FORM{'newPassWd'})) {             #Add new passwd/username
  &new_passwd}
elsif (exists($FORM{'delUsrName'})) {            #Delete passwd/username
  &delete_user}
else {}
#endif

exit;


################################################################################
#
#   Name:     change_passwd
#
#   Function: validates user-entered password modification, rewrites password
#             hash if valid, generates error if not.
#
#   Inputs:   Password/user-name pair (via %FORM hash in caller)
#             Array of existing passwds/user-names (%passwd) from
#              global_data.pl
#
#   Outputs:
#
#   Caller:   passwd_utilities_processing.pl
#
#   Calls:    duplicate_passwd                 passwd_utilities_processing.pl
#             post_change_passwd               passwd_utilities_processing.pl
#             bad_username                     passwd_utilities_processing.pl
#             write_passwd                     passwd_utilities_processing.pl
#
#                 MODIFICATION                                 DATE        BY
#
#                                                            05/25/99   M. Lewis
#
#Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis

sub change_passwd {

  unless ($FORM{'chgPassWd'} eq $sysPassWd) {    #Input passwd same as system
    foreach $oldPasswd (keys %passwd)  {         # passwd not allowed
      if ($FORM{'chgPassWd'} eq $oldPasswd) {    #Check for passwd dup
        &duplicate_passwd;                       #Error - choose new password
        return;
      } #endif
    } #end foreach
    $foundUser = $false;
    foreach $userName (keys(%passwd)) {          #Find username for this passwd
      if ($passwd{$userName} eq $FORM{'usrName'}) {
        $foundUser = $true;
        delete $passwd{$userName};               #delete old passwd/name pair
        $passwd{$FORM{'chgPassWd'}} =            #Assign new password
          $FORM{'usrName'};
      } #endif
    } #end foreach
    unless ($foundUser) {
      &bad_username($FORM{'usrName'});
      return;
    }
    else {
      &write_passwd;                             #Rewrite password hash
      &post_change_passwd($FORM{'usrName'});     #Acknowledge change to user
    } #end unless
    return;
  }
  else {                                         #User entered sys password
    &duplicate_passwd;
    return;
  } #end unless

} #end change_passwd


################################################################################
#
#   Name:     write_passwd
#
#   Function: rewrites global_data.pl file, updating password hash in the
#             process.
#
#   Inputs:   current password/user-name pair hash
#             entire global_data.pl file, read line-by-line
#
#   Outputs:    New global_data.pl file
#
#   Caller:   change_passwd                     passwd_utilities_processing.pl
#             new_passwd                        passwd_utilities_processing.pl
#
#   Calls:    sys_err                           passwd_utilities_processing.pl
#
#               MODIFICATION                                   DATE        BY
#
#                                                            06/16/99   M. Lewis
# Add permission-change code & call to sys_err               08/30/00   M. Lewis
#
sub write_passwd {

  my $foundHash = $false;
  my $chmod_err = 600;
  my $opendir_err = 100;
  my $closedir_err = 700;

#print "Content-Type: text/html\n\n";

  #Open the global_data.pl file
  #
  open(DATA_IN, "<global_data.pl")
    or die "Can't open global_data for read.\n";

  open(TEMP_OUT, ">temp.txt")                    #Write to a temp, then copy
    or die                                       # temp to global_data.pl
      "Can't open temp for write.\n";

  while (<DATA_IN>) {
    $thisLine = $_;                              #Grab input line from file

    if ($thisLine =~ /^##HOOK: BEGIN PASSWORD HASH/) {
      print TEMP_OUT $thisLine;                  #Print the ##HOOK: line
      $foundHash = $true;
      foreach $key (keys(%passwd)) {             #Rewrite whole array
        $buf =
          "            '$key' => '$passwd{$key}',";
        print TEMP_OUT "$buf\n";
      } #end foreach
    }
    else {
      if ($foundHash) {
        unless ($thisLine =~ /^##HOOK: END PASSWORD HASH/) {
        }
        else {
          print TEMP_OUT "$thisLine";            #Echo the END line
          $foundHash = $false;                   #Old hash lines have been
        } #end unless                            # skipped, reset flag
      }
      else {
        print TEMP_OUT "$thisLine"}              #Just echo the line
      #endif
    }#endif
  } #end while

  close (DATA_IN);
  close (TEMP_OUT);

  copy("temp.txt", "global_data.pl");            #public_html-side file

  return;

} #end write_passwd


###############################################################################
#
#   Name:     sys_err
#
#   Function: generates page giving an error code associated with a file-system
#             operation and possibly an amplifying string.  Current error codes
#             defined in start_build.pl are:
#
#                                        $opendir_err = 100;
#                                        $unlink_err = 200;
#                                        $mkdir_err = 300;
#                                        $copy_err = 400;
#                                        $chdir_err = 500;
#                                        $chmod_err = 600;
#                                        $closedir_err = 700;
#
#   Inputs:   error code
#             descriptive string
#
#   Outputs:
#
#   Caller:   write_passwd                     passwd_utilities_processing.pl
#
#   Calls:
#
#                MODIFICATION                                   DATE       BY
#
# Adapted from routine in start_build.pl                      08/30/00  M. Lewis
#
#
sub sys_err {

  my $errorCode = shift(@_);
  my $string1 = shift(@_);


print "Content-Type: text/html\n\n";

print <<end_of_html;
   <HEAD>
     <TITLE>File Operation Error</TITLE>
   </HEAD>
   <BODY>

<P><CENTER>File operation error $errorCode
end_of_html

  unless ($string1 eq "") {
print <<end_of_html;
, $string1. Execution halted.</P>
end_of_html
  }
  else {
print <<end_of_html;
. Execution halted.
end_of_html
  } #end unless

print <<end_of_html;
   </BODY>
   </HTML>
end_of_html

return;

} #end sys_err


################################################################################
#
#   Name:     new_passwd
#
#   Function: validates user-entered password modification, rewrites password
#             hash if valid, generates error if not.
#
#   Inputs:   Password/user-name pair (via %FORM hash in caller)
#             Array of existing passwds/user-names (%passwd) from
#             global_data.pl
#
#   Outputs:
#
#   Caller:   passwd_utilities_processing.pl
#
#   Calls:    duplicate_passwd                 passwd_utilities_html_lib.pl
#             post_new_passwd                  passwd_utilities_processing.pl
#             dup_username                     passwd_utilities_html_lib.pl
#             write_passwd                     passwd_utilities_processing.pl
#
#                  MODIFICATION                                DATE        BY
#
#                                                            06/16/99   M. Lewis
#
sub new_passwd {

  unless ($FORM{'newPassWd'} eq $sysPassWd) {    #Input passwd same as system
    foreach $oldPasswd (keys(%passwd)) {         # passwd not allowed
      if ($FORM{'newPassWd'} eq $oldPasswd) {    #Check for passwd dup
        &duplicate_passwd;                       #Error - choose new password
        return;
      } #endif
    } #end foreach
    foreach $userName (keys(%passwd)) {          #Username already exist?
      if ($passwd{$userName} eq
        $FORM{'usrName'}) {
        &dup_username($FORM{'usrName'});
        return;
      } #endif
    } #end foreach
    $passwd{$FORM{'newPassWd'}} =                #Add new username/password
      $FORM{'usrName'};
    &write_passwd;                               #Rewrite password hash
    &post_new_passwd($FORM{'usrName'});          #Acknowledge change to user
    return;
  }
  else {                                         #User entered sys password
    &duplicate_passwd;
    return}
  #end unless

} #end new_passwd


################################################################################
#
#   Name:     delete_user
#
#   Function: Checks username input for existance, deletes it and its corres-
#             ponding password from passwd hash.  Generates error if username
#             isn't found in passwd hash.
#
#   Inputs:   user-name (via %FORM hash in caller)
#             Array of existing passwds/user-names (%passwd) from
#              global_data.pl
#
#   Outputs:
#
#   Caller:   passwd_utilities_processing.pl
#
#   Calls:    post_delete_passwd              passwd_utilities_processing.pl
#             bad_username                    passwd_utilities_processing.pl
#             write_passwd                    passwd_utilities_processing.pl
#
#                    MODIFICATION                              DATE        BY
#
#                                                            06/16/99   M. Lewis
#
sub delete_user {

  $foundUser = $false;

  foreach $userName (keys(%passwd)) {            #Find username for this passwd
    if ($passwd{$userName} eq
      $FORM{'delUsrName'}) {
      $foundUser = $true;
      delete $passwd{$userName};                 #delete passwd/name pair
      last;
    } #endif
  } #end foreach
  unless ($foundUser) {
    &bad_username($FORM{'delUsrName'})}
  else {
    &write_passwd;                               #Rewrite password hash
    &post_delete_user($FORM{'delUsrName'});      #Acknowledge change to user
  } #end unless
  return;

} #end delete_user

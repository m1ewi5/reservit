#!/usr/bin/perl
require('passwd_utilities_html_lib.pl');
require('res_utilities_html_lib.pl');
require('global_data.pl');


################################################################################
#
#   Name:     password_utilities
#
#   Function: Starts routine to modify/add/delete a password
#
#   Inputs:   password
#             password utility selection
#
#   Outputs:
#
#   Caller:   passwd_form                         res_utilities_html_lib.pl
#
#   Calls:    change_passwd_form                  passwd_utilities_html_lib.pl
#             add_passwd_form                     passwd_utilities_html_lib.pl
#             delete_passwd_form                  passwd_utilities_html_lib.pl
#             passwd_err                          res_utilities_html_lib.pl
#
#                       MODIFICATION                           DATE        BY
#
#                                                            05/24/99   M. Lewis
#
#

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

   $FORM{$name} = $value;                          #Name/value pairs -> hash
} #end while/foreach

if ($FORM{'sysxwd'} eq $sysPassWd) {
        if ($FORM{'password'} eq 'change') {
          &change_passwd_form}                     #Change existing password
        elsif ($FORM{'password'} eq 'add_new') {
          &add_passwd_form}                        #Add new password
        elsif ($FORM{'password'} eq 'delete') {
          &delete_passwd_form}                     #Delete existing password
        else {}
}
else {
        &passwd_err}
#endif

exit;

#!/usr/bin/perl
require('res_utilities_html_lib.pl');
require('res_utilities_lib.pl');
require('global_data.pl');

################################################################################
#
#   Name:     res_utilities
#
#   Function: validates user-entered password, then calls specified function
#
#   Inputs:   password
#             function specifier
#
#   Outputs:  password
#
#   Caller:   res_utilities.html
#
#   Calls:    passwd_err                res_utilities2.pl
#             choose_utility            res_utilities2.pl
#
#                                 MODIFICATION                       DATE      BY
#
#   Harvey's Hotel/Casino                                    03/02/98   M. Lewis
#   Harvey's Hotel/Casino                                    03/09/98   M. Lewis
#   automated system revision (update passwords)             05/24/99   M. Lewis
# Add system password as acceptable choice                   08/15/00   M. Lewis
#
#Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis

################################################################################

#Variables
$fromUtilities = $false;
$foundPasswd = $false;


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

   $FORM{$name} = $value;                                                #Name/value pairs -> hash
} #end while/foreach

#print "Content-Type: text/html\n\n";

if ($FORM{'xwd'} eq $sysPassWd) {                                      #08/16/00
  &choose_utility}                                                     #08/16/00
else {                                                                 #08/16/00
  while (($key, $value) = each(%passwd)) {                             #08/16/00
    if ($key eq $FORM{'xwd'}) {                                        #08/16/00
      &choose_utility;                                                 #08/16/00
          last;                                                            #08/16/00
    } #endif                                                           #08/16/00
  } #end while                                                         #08/16/00
} #endif                                                               #08/16/00

#If passwd_err is called, password was invalid
unless ($foundPasswd) {
        &passwd_err}
#end unless

exit;


################################################################################
#
#   Name:     choose_utility
#
#   Function: calls specified function
#
#   Inputs:   function specifier
#
#   Outputs:
#
#   Caller:   res_utilities             res_utilities2.pl
#
#   Calls:    cancel_form               res_utilities_html_lib.pl
#             display_res               res_utilities_html_lib.pl
#             hotel_res_form            res_utilities_html_lib.pl
#             room_block_form           res_utilities_html_lib.pl
#             room_rates_form           res_utilities_html_lib.pl
#             passwd_form               res_utilities_html_lib.pl
#
#                                 MODIFICATION                        DATE      BY
#
#                                                             08/16/00  M. Lewis
# Removed all references to subroutine pre_update             12/19/00  M. Lewis
#
#Copyright 2000 by Daniel J. Klahn, Rick C. Langford & Michael Lewis

################################################################################
sub choose_utility {

  if ($FORM{'utility'} eq 'cancel') {
          $foundPasswd = $true;
    &cancel_form($FORM{'xwd'})}                    #Cancel a reservation
  elsif ($FORM{'utility'} eq 'display') {
                $foundPasswd = $true;
    &display_res}                                  #Display database record(s)
  elsif ($FORM{'utility'} eq 'reserve') {
    $foundPasswd = $true;
          &hotel_res_form($FORM{'xwd'})}                   #Enter a new reservation
  elsif ($FORM{'utility'} eq 'block') {
                $foundPasswd = $true;
    &room_block_form}                              #Display available-rooms block
  elsif ($FORM{'utility'} eq 'rates') {
                $foundPasswd = $true;
    &room_rates_form}                              #Display room-rates screen
  elsif ($FORM{'utility'} eq 'passwd') {
                $foundPasswd = $true;
    &passwd_form}                                            #Display password-update form
  #endif

  return;
} #end choose_utility

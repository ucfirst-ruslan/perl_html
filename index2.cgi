#!/usr/bin/perl

use CGI qw(:cgi-lib :escapeHTML :unescapeHTML);
use CGI::Carp qw(fatalsToBrowser);
use File::Basename qw(dirname);
use lib dirname(__FILE__) . '/libs';
use Data::Dumper;

$|=1;
ReadParse();

print "Content-type: text/html; charset=utf-8\n\n"; 
print "Hello!";
print "<pre>" . Dumper(\%ENV) . "</pre>";

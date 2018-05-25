#!/usr/bin/perl

use CGI qw(:cgi-lib :escapeHTML :unescapeHTML);
use CGI::Carp qw(fatalsToBrowser);
use File::Basename qw(dirname);
use lib dirname(__FILE__) . '/libs';
use Data::Dumper;
use Tools::FileSystem;

$|=1;
ReadParse();

print "Content-type: text/html; charset=utf-8\n\n"; 
#print "Hello!";
#print "<pre>" . Dumper(\%ENV) . "</pre>";
#

my $fs = Tools::FileSystem->new();

my $page = $fs->getFileContent("html/index.html");

my %nav = (
    '0'=>'home',
    '1'=>'Articles',
    '2'=>'Archives',
    '3'=>'Pages',
    '4'=>'Categories',
    '5'=>'Documentation',
    '6'=>'About',
    '7'=>'Links',
    '8'=>'Email'
);


$page =~s/{{(\d+)}}/$nav{$1}/gie;

print $page;


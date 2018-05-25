#!/usr/bin/perl

package Interfaces::db;

use strict;
use warnings;
use Data::Dumper;
use DBI;


my $self;
my $db;
my $user_db;
my $pass_db;
my $dbh;

my $where_glob;
my $limit_glob;


sub new
{

    my $class = ref($_[0]) || $_[0];
    shift @_;
    my ($db, $user_db, $pass_db) = @_;

    my $self = {};
    bless($self, $class);

    #($db, $user, $pass) = @_;
     $self->connect();

    return $self;
}

sub connect
{
    my $host = "DBI:mysql:$db:localhost";

    $dbh = DBI->connect($host, $user_db, $pass_db, {
        PrintError => 1,
        AutoCommit => 0
    }) || die "Connect failed: $DBI::errstr\n";

    #print "connect /n";
    return $dbh;
}


sub insert ($$)
{
    $self->connect();

    my ($self, $table, %values) = @_;

    my ($col, $cols, $values, $value, $placeholder);

    while(($col, $value) = each %values) {

              $cols .= ", `$col`";

        $placeholder .= ", ?";

        $dbh->quote($value);
        $values .= ", '$value'";
    };

    $cols = substr($cols, 2);
    $values = substr($values, 2);
    $placeholder = substr($placeholder, 2);

    my $sth = $dbh->prepare("INSERT INTO $table ($cols) VALUES ($placeholder)");
    $sth->execute($values);

    $sth->finish();

    return ($dbh->{mysql_insertid});
}


sub delete ($)
{
    $self->connect();

    my ($self, $table) = @_;

    $dbh->do("DELETE from '$table' WHERE $where_glob");

    print Dumper($dbh);
}


sub update
{
    $self->connect();

    my ($self, $table, %set, %where) = @_;

    my ($key_s, $value_s, $set);

    while(($key_s, $value_s) = each %set) {

        $dbh->quote($value_s);

        $set .= ", `$key_s`=`$value_s`";
        };

    $set = substr($set, 2);


    $dbh->do("UPDATE $table SET $set WHERE $where_glob");

    print Dumper($dbh);
}



sub where ($;$)
{
    my ($self, %where, $operator) = @_;

    my ($key, $value, $where);

    while(($key, $value) = each %where) {

        $dbh->quote($key);
        $dbh->quote($value);

        if ($operator) {

            $where .= " $operator `$key`='$value'";

        } else {

            $where_glob = "`$key`='$value'";
        }
    };

    if ($operator) {
        my $len = (length $operator) + 2;
        $where_glob = substr($where, $len);
    }

    return $where_glob;

}

sub limit ($;$)
{
    my ($self, $start, $end) = @_;

    if ($end) {
        $limit_glob = "$start, $end";

    } else {
        $limit_glob = "$start";
    }

}


sub select
{

#  SELECT column_name(s)
#  #FROM table1
#  #LEFT JOIN table2 ON table1.column_name = table2.column_name;


}



sub DESTROY {

    $dbh->disconnect();
}

1;

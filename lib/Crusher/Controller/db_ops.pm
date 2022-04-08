package db_ops;

use DBI;
use strict;
use Data::Dumper;

sub new() {
    my $class = shift;
    my $self  = {};
    bless $self;
    return $self;
}

sub exec_sql {

# This method supports:
# 1. ins - to insert rows
# 2. all - return full dataset
# 3. singles - returns single row
# Support can be added for fetchrow_array or fetchrow_arrayref or fetchrow_hashref etc.
# Or better yet, DBIx or other lite ORM can be used to avoid working directly with the database.

    shift;
    my %param = @_;
    my $dbh;
    my $res = {};

    # print $param{'sql'};

    $dbh = DBI->connect( "DBI:mysql:crushers", "usr", "a" );
    $res = $dbh->selectall_arrayref( $param{'sql'}, { Slice => {} } )
      if ( $param{'out'} eq 'all' );

    if ( $param{'out'} eq 'ins' ) {
        my $sth = $dbh->prepare( $param{'sql'} );
        $sth->execute() or die $dbh->errstr;
    }

    if ( $param{'out'} eq 'single' ) {
        my $sth = $dbh->prepare( $param{'sql'} );
        $sth->execute() or die $dbh->errstr;
        $res = $sth->fetchrow_hashref();
    }

    return $res;
}

1;

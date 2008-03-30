use Test::More;
use Test::Exception;

use DBI;
use DBIx::Coro;

use strict;
use warnings;

my ($dsn,$user,$pass) = @ENV{map { "DBIXCORO_PG_${_}" } qw/DSN USER PASS/};

plan skip_all => 'Please set the environment variables DBIXCORO_PG_(DSN|USER|PASS)' unless $dsn;
 
plan tests => 9;

SKIP: {
  eval "require DBD::SQLite";

  skip 'DBD::SQLite required',1 if $@;

  throws_ok { DBI->connect ('dbi:SQLite:dbname=/tmp/dbixcoro.db',undef,undef,{ RootClass => 'DBIx::Coro' }) } qr/only supports DBD::Pg/;
}

my $dbh = DBI->connect ($dsn,$user,$pass,{ RootClass => 'DBIx::Coro' });

isa_ok $dbh,'DBIx::Coro::db';

ok $dbh->do ('select max(42)'),'do';

is $dbh->{private_DBIx_Coro_mutex}->count,1,'mutex count';

my $sth = $dbh->prepare ('select max(42)');

isa_ok $sth,'DBIx::Coro::st';

$sth->execute;

is $sth->fetchrow_arrayref->[0],42,'fetchrow_arrayref';

is $dbh->{private_DBIx_Coro_mutex}->count,1,'mutex count';

ok $dbh->prepare ('select max(42)',{}),'prepare attr';

ok $dbh->do ('select max(42)',{}),'do attr';


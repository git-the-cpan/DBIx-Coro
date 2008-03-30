use inc::Module::Install;

name 'DBIx-Coro';

all_from 'lib/DBIx/Coro.pm';

build_requires 'Test::Exception' => '0.27';
build_requires 'Test::More'      => '0.72';

requires 'AnyEvent'     => '2.9';
requires 'Coro'         => '4.45';
requires 'DBI'          => '1.604';
requires 'DBD::Pg'      => '2.5.0';
requires 'Scope::Guard' => '0.03';

auto_install;

WriteAll;


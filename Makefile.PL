use inc::Module::Install;

name 'DBIx-Coro';

all_from 'lib/DBIx/Coro.pm';

requires 'Coro'    => '4.45';
requires 'DBI'     => '1.604';
requires 'DBD::Pg' => '2.5.0';
requires 'EV'      => '3.1';

auto_install;

WriteAll;


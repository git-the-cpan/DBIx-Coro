package DBIx::Coro;

use DBIx::Coro::db;
use DBIx::Coro::st;

use base qw/DBI/;

use strict;
use warnings;

our $VERSION = '0.00_04';

1;

=pod

=head1 NAME

DBIx::Coro - Coroutine compatible DBI

=head1 SYNOPSIS

  use AnyEvent;
  use Coro;
  use Coro::Timer;
  use DBI;
  use DBIx::Coro;

  my $c = AnyEvent->condvar;

  async {
    my $dbh = DBI->connect ($dsn,$username,$password,{ RootClass => 'DBIx::Coro' });

    print "Starting\n";

    $dbh->do ($long_running_statement);

    print "Finished\n";

    $c->broadcast;
  };

  async {
    while (1) {
      print "Waiting...\n";

      Coro::Timer::sleep 1;
    }
  };

  $c->wait;

  ### This should hopefully display something similar this...
  
  Starting
  Waiting...
  Waiting...
  Waiting...
  Finished

=head1 DESCRIPTION

L<DBIx::Coro> is a module that  subclasses L<DBI> in  order to provide
asynchronous DBI queries. The way it  works should be fairly stable, I
haven't used  any  ugly hacks to achieve  this functionality,  but the
number of supported drivers is at the moment fairly limited. See below
for more information about that.

From a programming  perspective, this  module should  behave just like
L<DBI>. If your program doesn't use  coroutines, it will behave mostly
like L<DBI>  usually  does (But that would  of course make this module
kind of pointless). However, if run from a coroutine, other coroutines
will be  given a  chance to  run until  the query has  completed. This
module  should also  be  safe for  multiple coroutines  using the same
database handle, but beware that only one query is run at a time. If a
coroutine tries  to use a database  handle currently in use by another
coroutine, it  will block  until the previous  coroutine has finished.

One important point  to emphasis here is that it's B<queries> that are
asynchronous, not all communication with the database.

Another important  point is that since this  module  provides the same
interface as L<DBI> does, you can use it with L<DBI> abstractions such
as L<DBIx::Class> and it should just work.

=head1 SUPPORTED DRIVERS

Currently,  this module  will only  work  with L<DBD::Pg>. Why?  Well,
because  PostgreSQL  is  the  only database  I've  found  that  allows
asynchronous  queries. This module is  really just  some clever wiring
between L<Coro> and L<DBD::Pg>.

=head1 ACKNOWLEDGEMENTS

=over 4

=item Marc Lehmann for writing L<Coro>.

=item Matt S. Trout for help on DBI subclassing.

=item Sam Vilain for solving the descriptor problem.

=back

=head1 SEE ALSO

=over 4

=item L<Coro>

=item L<DBI>

=back

=head1 BUGS

Most software has bugs. This module probably isn't an exception. 
If you find a bug please either email me, or add the bug to cpan-RT.

=head1 AUTHOR

Anders Nor Berle E<lt>berle@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2008 by Anders Nor Berle.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut


package DBIx::Coro;

use DBIx::Coro::db;
use DBIx::Coro::st;

use base qw/DBI/;

use strict;
use warnings;

our $VERSION = '0.00_01';

1;

=pod

=head1 NAME

DBIx::Coro - Coroutine compatible DBI

=head1 SYNOPSIS

  use Coro;
  use Coro::EV;
  use Coro::Timer;
  use DBI;
  use DBIx::Coro;

  my $running = 1;

  async {
    my $dbh = DBI->connect ($dsr,$username,$password,{ RootClass => 'DBIx::Coro' });

    print "Starting\n";

    $dbh->do ($long_running_statement);

    print "Finished\n";

    $running = 0;
  };

  async {
    while ($running) {
      print "Waiting...\n";

      Coro::Timer::sleep 1;
    }
  };

  EV::loop while $running;

  ### This should hopefully display something similar this...
  
  Starting
  Waiting...
  Waiting...
  Waiting...
  Finished

=head1 DESCRIPTION

L<DBIx::Coro> is a module that subclasses DBI in order to provide
asynchronous DBI queries. The way it works should be fairly stable, I
haven't used any ugly hacks to achieve this functionality, but the
number of supported drivers is at the moment fairly limited. See below
for more information about that.

From a programming perspective, this module should behave just like
DBI. If your program doesn't use coroutines, it will behave mostly like
DBI usually does (But that would of course make this module kind of
pointless). However, if run from a coroutine, other coroutines will
be given a chance to run until the query has completed. This module
should also be safe for multiple coroutines using the same database
handle, but beware that only one query is run at a time. If a
coroutine tries to use a database handle currently in use by another
coroutine, it will block until the previous coroutine has finished.

One important point to emphasis here is that it's B<queries> that are
asynchronous, not all communication with the database.

Another important point is that since this module uses the same
interface as DBI does, you can use it with DBI abstractions such as
L<DBIx::Class> and it should just work.

=head1 SUPPORTED DRIVERS

Currently, this module will only work with L<DBD::Pg>. Why? Well,
because PostgreSQL is the only database I've found that allows
asynchronous queries. This module is really just some clever wiring
between L<Coro> and L<DBD::Pg>.

=head1 CAVEATS

Aside from only supporting L<DBD::Pg>, there is another serious gotcha
which seems fairly trivial but I've not been able to work around yet.
Currently, you must use L<Coro::EV> as your loop, EV is hardcoded into
this module because the L<AnyEvent> abstraction does not support the
functionality needed.

To be more specific, this module needs to be able to watch a file
descriptor number. L<AnyEvent> only supports watching filehandles.
I've tried turning a file descriptor into a filehandle in perl, but so
far been unsuccessfull. Any attempt to use say open or L<IO::Handle>
results in the connection being destroyed. I would greatly appreciate
help on how to fix this problem, but *please* try your solution before
submitting it to me.

=head1 ACKNOWLEDGEMENTS

=over 4

=item Marc Lehmann for writing L<Coro>.

=item Matt S Trout for letting me know about RootClass.

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


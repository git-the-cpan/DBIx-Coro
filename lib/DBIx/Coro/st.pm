package DBIx::Coro::st;

use Coro;
use Coro::EV;
use DBI;

use base qw/DBI::st/;

use strict;
use warnings;

sub execute {
  my ($self,@bind_values) = @_;

  my $guard = $self->{Database}->_coro_guard;

  $self->SUPER::execute (@bind_values);

  return $self->{Database}->_coro_wait_result;
}

1;


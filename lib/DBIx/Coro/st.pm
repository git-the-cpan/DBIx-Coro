package DBIx::Coro::st;

use Coro;
use Coro::EV;
use DBI;

use base qw/DBI::st/;

use strict;
use warnings;

sub execute {
  my ($self,@bind_values) = @_;

  my $current = $Coro::current;

  $self->{Database}->{private_DBIx_Coro_mutex}->down;

  $self->SUPER::execute (@bind_values);

  my $w = EV::io $self->{Database}->{pg_socket},EV::READ,sub {
    if ($self->{Database}->pg_ready) {
      $current->ready;

      undef $current;
    }
  };

  Coro::schedule while $current;

  $self->{Database}->{private_DBIx_Coro_mutex}->up;

  return $self->{Database}->pg_result;
}

1;


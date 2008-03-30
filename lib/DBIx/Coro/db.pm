package DBIx::Coro::db;

use Carp;
use Coro;
use Coro::EV;
use Coro::Semaphore;
use DBI;
use DBD::Pg;
use Scope::Guard;

use base qw/DBI::db/;

use strict;
use warnings;

sub do {
  my ($self,$statement,$attr,@bind_values) = @_;

  $attr ||= {};

  $attr->{pg_async} = DBD::Pg::PG_ASYNC;

  my $guard = $self->_coro_guard;

  $self->SUPER::do ($statement,$attr,@bind_values);

  return $self->_coro_wait_result;
}

sub prepare {
  my ($self,$statement,$attr) = @_;

  $attr ||= {};

  $attr->{pg_async} = DBD::Pg::PG_ASYNC;

  my $guard = $self->_coro_guard;

  my $sth = $self->SUPER::prepare ($statement,$attr);

  return $sth;
}

sub connected {
  my ($self) = shift;

  Carp::confess "DBIx::Coro only supports DBD::Pg currently"
    unless $_[0] =~ /^dbi:Pg:/i;

  $self->{private_DBIx_Coro_mutex} = Coro::Semaphore->new (1);

  return $self->SUPER::connected (@_);
}

# Because Coro::Semaphore::guard is unreliable

sub _coro_guard {
  my ($self) = @_;

  $self->{private_DBIx_Coro_mutex}->down;

  return Scope::Guard->new (sub { $self->{private_DBIx_Coro_mutex}->up });
}

sub _coro_wait_result {
  my ($self) = @_;

  my $current = $Coro::current;

  my $w = EV::io $self->{pg_socket},EV::READ,sub {
    if ($self->pg_ready) {
      $current->ready;

      undef $current;
    }
  };

  Coro::schedule while $current;

  return $self->pg_result;
}

1;


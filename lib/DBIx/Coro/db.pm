package DBIx::Coro::db;

use Carp;
use Coro;
use Coro::EV;
use Coro::Semaphore;
use DBI;
use DBD::Pg;

use base qw/DBI::db/;

use strict;
use warnings;

sub do {
  my ($self,$statement,$attr,@bind_values) = @_;

  my $current = $Coro::current;

  $attr ||= {};

  $attr->{pg_async} = DBD::Pg::PG_ASYNC;

  $self->{private_DBIx_Coro_mutex}->down;

  $self->SUPER::do ($statement,$attr,@bind_values);

  my $w = EV::io $self->{pg_socket},EV::READ,sub {
    if ($self->pg_ready) {
      $current->ready;

      undef $current;
    }
  };

  Coro::schedule while $current;

  $self->{private_DBIx_Coro_mutex}->up;

  return $self->pg_result;
}

sub prepare {
  my ($self,$statement,$attr) = @_;

  $attr ||= {};

  $attr->{pg_async} = DBD::Pg::PG_ASYNC;

  $self->{private_DBIx_Coro_mutex}->down;

  my $sth = $self->SUPER::prepare ($statement,$attr);

  $self->{private_DBIx_Coro_mutex}->up;

  return $sth;
}

sub connected {
  my ($self) = shift;

  Carp::confess "DBIx::Coro only supports DBD::Pg currently"
    unless $_[0] =~ /^dbi:Pg:/i;

  $self->{private_DBIx_Coro_mutex} ||= Coro::Semaphore->new (1);

  return $self->SUPER::connected (@_);
}

1;


package Lingua::JA::WebIDF::Driver::TokyoTyrant;

use 5.008_001;
use strict;
use warnings;

use Carp ();
use TokyoTyrant;

our $VERSION = '0.10';
push(@Lingua::JA::WebIDF::NETWORK_INTERFACE_PLUGIN, 'TokyoTyrant');


sub fetch_df
{
    my ($self, $word) = @_;

    Carp::croak('TokyoTyrant DB connection is not opened') unless $self->{db};

    return $self->{db}->get($word);
}

sub save_df
{
    my ($self, $word, $df_and_time) = @_;

    my $hdb = $self->{db} || Carp::croak('TokyoTyrant DB connection is not opened');

    # If a record with the same key exists in the database, it is overwritten.
    $hdb->put($word, $df_and_time) or Carp::carp( 'TokyoTyrant put: ' . $hdb->errmsg($hdb->ecode) );
}

sub purge
{
    my ($self, $days) = @_;

    my $hdb = $self->{db} || Carp::croak('TokyoTyrant DB connection is not opened');

    $hdb->iterinit;

    while( defined( my $key = $hdb->iternext ) )
    {
        my ($df, $time) = split( /\t/, $hdb->get($key) );

        if (time - $time > 60 * 60 * 24 * $days)
        {
            $hdb->out($key);
        }
    }
}

sub db_open
{
    my $self = shift;

    Carp::croak('Something wrong with df_file name format!') if $self->{df_file} !~ /^[^:]+:[^:]+$/;

    my ($host, $port) = split(/:/, $self->{df_file});

    my $hdb = TokyoTyrant::RDB->new;

    $hdb->open($host, $port) or Carp::croak( 'TokyoTyrant open: ' . $hdb->errmsg($hdb->ecode) );

    $self->{db} = $hdb;
}

sub db_close
{
    my $hdb = shift->{db};
    $hdb->close if defined $hdb;
}

1;

__END__

=encoding utf8

=head1 NAME

Lingua::JA::WebIDF::Driver::TokyoTyrant - TokyoTyrant plugin for Lingua::JA::WebIDF

=head1 SYNOPSIS

  use Lingua::JA::WebIDF;

  my $webidf = Lingua::JA::WebIDF->new(
      driver   => 'TokyoTyrant',
      df_file  => 'localhost:1978',
  );

  $webidf->db_open;
  print $webidf->idf("東京"); # low
  print $webidf->idf("スリジャヤワルダナプラコッテ"); # high
  $webidf->db_close;

=head1 DESCRIPTION

Lingua::JA::WebIDF::Driver::TokyoTyrant is a TokyoTyrant plugin for Lingua::JA::WebIDF.

=head1 AUTHOR

pawa E<lt>pawapawa@cpan.orgE<gt>

=head1 SEE ALSO

L<Lingua::JA::TermExtractor>

L<Lingua::JA::TFWebIDF>

L<Lingua::JA::WebIDF>

Tokyo Tyrant: L<http://fallabs.com/tokyotyrant/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

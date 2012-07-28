use strict;
use warnings;
use Lingua::JA::WebIDF;
use File::Spec;
use Test::More;
use Test::Fatal;
use Test::ttserver;
use lib './lib/'; # load TokyoTyrant.pm


my %config = (
    appid    => 'test',
    driver   => 'TokyoTyrant',
    fetch_df => 0,
    df_file  => 'example.com:1978',
);

my $webidf = Lingua::JA::WebIDF->new(\%config);

my $exception = exception { $webidf->df('test'); };
like($exception, qr/TokyoTyrant DB connection is not opened/);

push(@Test::ttserver::SearchPaths, File::Spec->path);
my $ttserver = Test::ttserver->new or die $Test::ttserver::errstr;
$config{df_file} = join(':', $ttserver->socket);

$webidf = Lingua::JA::WebIDF->new(\%config);
$webidf->db_open;
$webidf->db_close;
$webidf->db_close; # don't die

done_testing;

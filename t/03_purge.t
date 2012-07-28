use strict;
use warnings;
use utf8;
use Encode qw/decode_utf8/;
use Lingua::JA::WebIDF;
use TokyoTyrant;
use Test::More;
use Test::ttserver;
use File::Spec;

binmode Test::More->builder->$_ => ':utf8'
    for qw/output failure_output todo_output/;


push(@Test::ttserver::SearchPaths, File::Spec->path);
my $ttserver = Test::ttserver->new('./test.tch') or die $Test::ttserver::errstr;

my $expires_in    = 365;
my ($host, $port) = preparation();

my $webidf = Lingua::JA::WebIDF->new(
    appid      => 'test',
    fetch_df   => 0,
    driver     => 'TokyoTyrant',
    df_file    => "$host:$port",
    expires_in => $expires_in,
);

$webidf->db_open;
$webidf->purge($expires_in);
$webidf->db_close;

my $hdb = TokyoTyrant::RDB->new;

$hdb->open($host, $port) or die $hdb->errmsg($hdb->ecode);

$hdb->iterinit;

while( defined(my $key = $hdb->iternext) )
{
    $key = decode_utf8($key);
    like($key, qr/^(?:新鮮|賞味期限切れる１日前)$/);
}

$hdb->close or die $hdb->errmsg($hdb->ecode);

done_testing;


sub preparation
{
    my ($host, $port) = $ttserver->socket;

    my $hdb = TokyoTyrant::RDB->new;
    $hdb->open($host, $port) or die $hdb->errmsg($hdb->ecode);

    my $prev_day_time = time - 60 * 60 * 24 * ($expires_in - 1);
    my $next_day_time = time - 60 * 60 * 24 * ($expires_in + 1);

    my %data = (
        '賞味期限切れ'         => "1000\t0",
        '新鮮'                 => "100\t" . time,
        '賞味期限切れる１日前' => "10\t$prev_day_time",
        '賞味期限切れて１日後' => "1\t$next_day_time",
    );

    for my $key (keys %data)
    {
        $hdb->put($key, $data{$key}) or warn $hdb->errmsg($hdb->ecode);
    }

    $hdb->close or die $hdb->errmsg($hdb->ecode);

    return ($host, $port)
}

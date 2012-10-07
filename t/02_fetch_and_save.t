use strict;
use warnings;
use Lingua::JA::WebIDF;
use Test::More;
use Test::TCP;
use Test::ttserver;
use File::Spec;
use Test::Requires qw/Plack::Loader/;


my $app = sub {

    my $env = shift;

    return [
        200,
        [ 'Content-Type' => 'application/xml' ],
        [
            qw|
                <?xml version="1.0" encoding="UTF-8"?>
                <ResultSet firstResultPosition="1" totalResultsAvailable="1234567" totalResultsReturned="1" xmlns="urn:yahoo:jp:srch" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:yahoo:jp:srch http://search.yahooapis.jp/PremiumWebSearchService/V1/WebSearchResponse.xsd">
                    <Result>
                        <Title></Title>
                        <Summary></Summary>
                        <Url></Url>
                        <ClickUrl></ClickUrl>
                        <ModificationDate />
                        <Cache></Cache>
                    </Result>
                </ResultSet>
            |
        ]
    ];
};

test_tcp(
    server => sub {

        my $port   = shift;
        my $server = Plack::Loader->auto(
            port => $port,
            host => '127.0.0.1',
        );
        $server->run($app);
    },
    client => sub {

        my $port = shift;

        my %config = (
            api      => 'YahooPremium',
            appid    => 'test',
            fetch_df => 0,
            driver   => 'TokyoTyrant',
            verbose  => 0,
        );

        push(@Test::ttserver::SearchPaths, File::Spec->path);
        my $ttserver = Test::ttserver->new('./test.tch') or die $Test::ttserver::errstr;
        $config{df_file} = join(':', $ttserver->socket);

        my $webidf = Lingua::JA::WebIDF->new(\%config);

        {
            no warnings 'once';
            $Lingua::JA::WebIDF::API::YahooPremium::BASE_URL = "http://127.0.0.1:$port/yahoo_premium/";
        }

        $webidf->db_open;
        is($webidf->df('test'), undef, 'fetch_df: 0');
        $webidf->db_close;

        $config{fetch_df} = 1;

        $webidf = Lingua::JA::WebIDF->new(\%config);
        $webidf->db_open;
        is($webidf->df('test'), 1234567, 'fetch_df: 1');
        $webidf->db_close;

        $config{fetch_df} = 0;

        $webidf = Lingua::JA::WebIDF->new(\%config);

        {
            no warnings 'once';
            $Lingua::JA::WebIDF::API::YahooPremium::BASE_URL = "http://example.com/";
        }

        $webidf->db_open;
        is($webidf->df('test'), 1234567, 'fetch_df_from_db');
        $webidf->db_close;
    },
);

done_testing;

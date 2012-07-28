use inc::Module::Install;

name     'Lingua-JA-WebIDF-Driver-TokyoTyrant';
all_from 'lib/Lingua/JA/WebIDF/Driver/TokyoTyrant.pm';

requires 'Carp';
requires 'TokyoTyrant';
requires 'Lingua::JA::WebIDF' => 0.32;

test_requires 'Test::More'     => 0.88; # done_testing
test_requires 'Test::Fatal';
test_requires 'Test::TCP'      => 1.15;
test_requires 'Test::ttserver' => 0.003;
test_requires 'Test::Requires';
test_requires 'File::Spec';

tests 't/*.t';
author_tests 'xt';

readme_from 'lib/Lingua/JA/WebIDF/Driver/TokyoTyrant.pm';

resources(
    license    => 'http://dev.perl.org/licenses',
    repository => 'https://github.com/pawa-/Lingua-JA-WebIDF-Driver-TokyoTyrant',
    bugtracker => 'https://github.com/pawa-/Lingua-JA-WebIDF-Driver-TokyoTyrant/issues',
);

WriteAll;

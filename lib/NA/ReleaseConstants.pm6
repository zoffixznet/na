unit module NA::ReleaseConstants;
use NA::Config;

# constant $user          is export = 'cpan';
# constant $host          is export = '104.196.145.160';
# constant $cores         is export = (12 * 1.3).Int; # mult is for TEST_JOBS
constant $user          is export = 'zoffix';
constant $host          is export = 'perl6.party';
constant $cores         is export = (2 * 1.3).Int;
constant $moar-ver      is export = '2016.08-35-g5108035';
constant $nqp-ver       is export = '2016.08.1-38-g67b6836';
constant $rakudo-ver    is export = '2016.09';
constant $rakudo-rver   is export = '103';
constant $rakudo-backends is export = 'moar'; # 'ALL'
constant $nqp-repo      is export = 'https://github.com/zoffixznet/nqp';
constant $rakudo-repo   is export = 'https://github.com/zoffixznet/rakudo';
constant $doc-repo      is export = 'https://github.com/perl6/doc';
constant $moar-repo     is export = 'https://github.com/MoarVM/MoarVM';
constant $roast-repo    is export = 'https://github.com/perl6/roast';
constant $release-dir   is export = '/tmp/release/';
constant $tag-email     is export = 'cpan@zoffix.com';
constant $perl5-source  is export = 'source ~/perl5/perlbrew/etc/bashrc';
constant $perl6-source  is export = 'export PATH=~/.rakudobrew/bin'
    ~ ':~/.rakudobrew/moar-nom/install/share/perl6/site/bin:$PATH';
constant $gpg-keyphrase is export = conf<gpg-keyphrase>
                                  // die 'Missing gpg-keyphrase in config.json';
constant $github-user   is export = conf<github-user>
                                  // die 'Missing github-user in config.json';
constant $github-pass   is export = conf<github-pass>
                                  // die 'Missing github-pass in config.json';
constant $dir-temp      is export = $release-dir ~ 'temp';
constant $dir-nqp       is export = $release-dir ~ 'nqp';
constant $dir-rakudo    is export = $release-dir ~ 'rakudo';
constant $dir-tarballs  is export = $release-dir ~ 'tarballs';
constant $na-msg        is export = 'NeuralAnomaly RELEASE STATUS:';
constant $na-fail       is export = 'NeuralAnomaly FAILURE MESSAGE:';

constant $with-github-credentials is export
    = "(sleep 6; echo -e '$github-user\\n';"
    ~ " sleep 6; echo -e '$github-pass\\n'; sleep 12) | unbuffer -p";

constant $with-gpg-passphrase     is export
    = "(sleep 6; echo '$gpg-keyphrase'; sleep 12) | unbuffer -p";

unit module NA::ReleaseConstants;
use NA::Config;

# constant $user          is export = 'zoffix';
# constant $host          is export = 'localhost';
# constant $cores         is export = (4 * 1.6).Int; # mult is for TEST_JOBS

constant $user          is export = 'cpan';
constant $host          is export = '104.196.178.76';
constant $cores         is export = 28;

# constant $user          is export = 'zoffix';
# constant $host          is export = 'perl6.party';
# constant $cores         is export = (4 * 1.6).Int;

## Volatiles -- TEST
constant $moar-ver      is export = '2016.10';
constant $nqp-ver       is export = '2016.09-135-g298e228';
constant $rakudo-ver    is export = '2016.10';
constant $rakudo-rver   is export = '104';
constant $nqp-repo      is export = 'https://github.com/zoffixznet/nqp';
constant $rakudo-repo   is export = 'https://github.com/zoffixznet/rakudo';
constant $nqp-scp       is export = 'zoffix@perl6.party:~/temp/rel/nqp/';
constant $rakudo-scp    is export = 'zoffix@perl6.party:~/temp/rel/rakudo/';

# ## Volatiles -- PRODUCTION
# constant $moar-ver      is export = '2016.10';
# constant $nqp-ver       is export = '2016.10';
# constant $rakudo-ver    is export = '2016.10';
# constant $rakudo-rver   is export = '104';
# constant $nqp-repo      is export = 'https://github.com/perl6/nqp';
# constant $rakudo-repo   is export = 'https://github.com/rakudo/rakudo';
# constant $nqp-scp       is export
#    = 'rakudo@rakudo.org:~/public_html/downloads/nqp/';
# constant $rakudo-scp    is export
#    = 'rakudo@rakudo.org:~/public_html/downloads/rakudo/';



## Stables
constant $rakudo-backends is export = 'moar'; # 'ALL'
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

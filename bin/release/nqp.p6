use lib <lib>;
use NA::RemoteShell;
use Config::From;

constant $user = 'cpan'; #'zoffix';
constant $host = '104.196.143.15'; #'perl6.party';
constant $nqp-repo = 'https://github.com/zoffixznet/nqp';
constant $release-dir = '/tmp/release/';
constant $moar-ver    = '2016.08-32-ge52414d';
constant $nqp-ver     = '2016.10';
constant $tag-email   = 'cpan@zoffix.com';
my $gpg-keyphrase is from-config;
my $github-user is from-config;
my $github-pass is from-config;

constant $dir-temp     = $release-dir ~ 'temp';
constant $dir-nqp      = $release-dir ~ 'nqp';
constant $dir-tarballs = $release-dir ~ 'tarballs';

constant $na-msg = 'NeuralAnomaly RELEASE STATUS:';
constant $with-github-credentials = qq{(sleep 6; echo -e '$github-user\n'; }
    ~ qq{sleep 6; echo -e '$github-pass\n'; sleep 10) | unbuffer -p};
constant $with-gpg-passphrase
    = "(sleep 6; echo '$gpg-keyphrase'; sleep 10) | unbuffer -p";

my NA::RemoteShell $shell .= new;
$shell.launch: :&out, :err(&out), :$user, :$host;
$shell.send: qq:to/SHELL_SCRIPT_END/;
    set -x
    unset HISTFILE
    hostname

    # Start with a blank slate:
    rm -fr $release-dir                                             &&
    mkdir $release-dir                                              &&
    cd $release-dir                                                 &&
    mkdir $dir-temp                                                 &&
    mkdir $dir-nqp                                                  &&
    mkdir $dir-tarballs                                             || exit 1

    git clone $nqp-repo nqp                                         &&
    cd nqp                                                          || exit 1

    # Bump MoarVM version:
    echo '$moar-ver' > tools/build/MOAR_REVISION                    &&
    git commit -m 'bump MoarVM version to $moar-ver' \\
        tools/build/MOAR_REVISION                                   || exit 1

    # Bump nqp version:
    echo '$nqp-ver' > VERSION                                       &&
    git commit -m 'bump VERSION to $nqp-ver' VERSION                &&
    $with-github-credentials git push                               || exit 1

    # Build and test:
    perl Configure.pl --gen-moar --backend=moar,jvm                 &&
        make                                                        &&
        make m-test                                                 &&
        make j-test                                                 &&
        echo "$na-msg nqp tests OK"                                 || exit 1

    # Make release and copy over the tarball to testing area
    make release VERSION=$nqp-ver                                   &&
        cp nqp-$nqp-ver.tar.gz $dir-temp                            &&
        cd $dir-temp                                                &&
        tar -xvvf nqp-$nqp-ver.tar.gz                               &&
        cd nqp-$nqp-ver                                             || exit 1

    # Build and test the release tarball
    perl Configure.pl --gen-moar --backend=moar,jvm                 &&
        make                                                        &&
        make m-test                                                 &&
        make j-test                                                 &&
        echo "$na-msg nqp release tarball tests OK"                 || exit 1

    # Go back to nqp dir so we could sign stuff
    cd $dir-nqp                                                     || exit 1

    # Tags:
    $with-gpg-passphrase git tag -u $tag-email \\
        -s -a -m 'tag release $nqp-ver' $nqp-ver                    &&
    $with-github-credentials git push --tags                        || exit 1

    # Tarball:
    gpg --batch --no-tty --passphrase-fd 0 -b \\
        --armor nqp-$nqp-ver.tar.gz                                 || exit 1
    $gpg-keyphrase

    cp nqp-$nqp-ver.tar.gz* $dir-tarballs                           &&
    cd $release-dir                                                 || exit 1

    # Indicate release succeeded:
    echo '$na-msg nqp release DONE'                                 || exit 1
SHELL_SCRIPT_END
$shell.end;

sub out {
    # Scrub sensitive info from output
    my $mes = $^v.subst(:g, $gpg-keyphrase, '*****')
                 .subst(:g, $github-user,   '*****')
                 .subst(:g, $github-pass,   '*****');

    "Remote shell: $mes".print;
    say "#### THIS IS WHERE WE SEND MESSSAGE $<msg>"
        if $mes ~~ /'NeuralAnomaly RELEASE STATUS: ' $<msg>=\N+/;
}

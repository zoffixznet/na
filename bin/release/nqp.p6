use lib <lib>;
use NA::RemoteShell;
use Config::From;

constant $user = 'cpan'; #'zoffix';
constant $host = '104.196.101.176'; #'perl6.party';
constant $nqp-repo = 'https://github.com/zoffixznet/nqp';
constant $release-dir = '/tmp/release/';
constant $moarvm-ver  = '2016.08';
constant $nqp-ver     = '2016.09';
constant $tag-email   = 'cpan@zoffix.com';
my $gpg-keyphrase is from-config;

constant $dir-temp     = $release-dir ~ 'temp';
constant $dir-nqp      = $release-dir ~ 'nqp';
constant $dir-tarballs = $release-dir ~ 'tarballs';

given NA::RemoteShell.new -> $shell {
    $shell.launch: :&out, :err(&out), :$user, :$host;
    $shell.send: $_
        for
            'set -x',
            'hostname',
            "source /home/$user/.bashrc",

            # Start with a blank slate:
            "rm -fr $release-dir", "mkdir $release-dir", "cd $release-dir",
            "mkdir $dir-temp", "mkdir $dir-nqp", "mkdir $dir-tarballs",

            # NQP
                "git clone $nqp-repo nqp",
                "cd nqp",

                # Bump MoarVM version:
                    "echo '$moarvm-ver' > tools/build/MOAR_REVISION",
                    "echo '$moarvm-ver' > tools/build/MOAR_REVISION",
                    "git commit -m 'bump MoarVM version to $moarvm-ver'"
                        ~ ' tools/build/MOAR_REVISION',

                # Bump nqp version:
                    "echo '$nqp-ver' > VERSION",
                    "git commit -m 'bump VERSION to $nqp-ver' VERSION",
                    'git push',

                # Build and test:
                'perl Configure.pl --gen-moar --backend=moar &&'
                    ~ 'make && ' #make m-test && make j-test &&'
                    ~ 'echo "NeuralAnomaly RELEASE STATUS: nqp tests OK"',

                # Make release and copy over the tarball to testing area
                "make release VERSION=$nqp-ver",
                    # "cp nqp-$nqp-ver.tar.gz $dir-temp",
                    # "cd $dir-temp",
                    # "tar -xvvf nqp-$nqp-ver.tar.gz",
                    # "cd nqp-$nqp-ver",
                    #
                    # # Build and test the release tarball
                    # 'perl Configure.pl --gen-moar --backend=moar,jvm &&'
                    #     ~ 'make && make m-test && make j-test &&'
                    #     ~ 'echo "NeuralAnomaly RELEASE STATUS: nqp'
                    #     ~ ' release tarball tests OK"',
                    #
                    # # Go back to nqp dir so we could sign stuff
                    # "cd $dir-nqp",

                # Tags:
                q{echo '/usr/bin/gpg --passphrase-fd 0 --batch --no-tty}
                    ~ q{ "$@"' > na-gpg},
                'chmod +x na-gpg',
                q{git config gpg.program './na-gpg'},
                "git tag -u $tag-email -s -a -m"
                    ~ " 'tag release $nqp-ver' $nqp-ver || exit 1",
                [$gpg-keyphrase],
                'git push --tags',

                # Tarball:
                'gpg --batch --no-tty --passphrase-fd 0 -b'
                    ~ " --armor nqp-$nqp-ver.tar.gz || exit 1",
                [$gpg-keyphrase],
                "cp nqp-$nqp-ver.tar.gz* $dir-tarballs",

                "cd $release-dir",

                # Indicate release succeeded:
                'echo "NeuralAnomaly RELEASE STATUS: nqp'
                    ~ ' release DONE"',
            ;
    $shell.end;
}

sub out {
    # Should never happen, but if we somehow manage to splurge gpg pass into
    # the output, scrub it.
    my $mes = $^v.subst: :g, $gpg-keyphrase, '*****';
    # /<{$gpg-keyphrase.comb.map({$_ eq "'" ?? "\\'" !! qq{'$_'}}).join('\s*')}>/, '*********';

    "Remote shell: $mes".print;
    say "#### THIS IS WHERE WE SEND MESSSAGE $<msg>"
        if $mes ~~ /'NeuralAnomaly RELEASE STATUS: ' $<msg>=\N+/;
}

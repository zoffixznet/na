unit class NA::ReleaseScript::Rakudo;
use NA::ReleaseConstants;

method script {
    return qq:to/SHELL_SCRIPT_END/;
    # {$*SCRIPT_STAGE = 'Rakudo: generate release announcement'}
    if [ ! -e docs/announce/$rakudo-ver.md ] ; then
        git clone $doc-repo $dir-doc                                &&
        $*EXECUTABLE tools/create-release-announcement.pl       \\
            > docs/announce/$rakudo-ver.md                          &&
        git commit -m 'Generate release announcement for        \\
            $rakudo-ver' docs/announce/$rakudo-ver.md               || exit 1
    fi

    # {$*SCRIPT_STAGE = 'Rakudo: bump NQP and Rakudo versions'}
    echo $nqp-ver > tools/build/NQP_REVISION                        &&
    git commit -m '[release] bump NQP revision'                 \\
        tools/build/NQP_REVISION                                    &&

    echo $rakudo-ver > VERSION                                      &&
    git commit -m '[release] bump VERSION to $rakudo-ver' VERSION   &&
    git pull --rebase                                               &&
    $with-github-credentials git push                               || exit 1

    # {$*SCRIPT_STAGE = 'Rakudo: build and make test'}
    perl Configure.pl --gen-moar --backends=$rakudo-backends        &&
    make                                                            &&
    make install                                                    &&
    make test                                                       || exit 1

    # {$*SCRIPT_STAGE = 'Rakudo: install Inline::Perl5'}
    git clone https://github.com/tadzik/panda                       &&
    export PATH=`pwd`/install/bin:\$PATH                            &&
    cd panda                                                        &&
    perl6 bootstrap.pl                                              &&
    cd ..                                                           &&
    export PATH=`pwd`/install/share/perl6/site/bin:\$PATH           &&
    panda install Inline::Perl5                                     || exit 1

    # {$*SCRIPT_STAGE = 'Rakudo: make stresstest (master)'}
    TEST_JOBS=$cores make stresstest                                &&
    echo "$na-msg Rakudo stresstest (master) OK"                    || exit 1

    # {$*SCRIPT_STAGE = 'Rakudo: make stresstest (6.c-errata)'}
    cd t/spec                                                       &&
    git checkout 6.c-errata                                         &&
    cd ../..                                                        &&
    TEST_JOBS=$cores make stresstest                                &&
    echo "$na-msg Rakudo stresstest (6.c-errata) OK"                || exit 1

    # {$*SCRIPT_STAGE = 'Rakudo: make release tarball and copy to test area'}
    make release VERSION=$rakudo-ver                                &&
    cp rakudo-$rakudo-ver.tar.gz $dir-temp                          &&
    cd $dir-temp                                                    &&
    tar -xvvf rakudo-$rakudo-ver.tar.gz                             &&
    cd rakudo-$rakudo-ver                                           || exit 1

    # {$*SCRIPT_STAGE = 'Rakudo: (tarball testing) install Inline::Perl5'}
    git clone https://github.com/tadzik/panda                       &&
    export PATH=`pwd`/install/bin:\$PATH                            &&
    cd panda                                                        &&
    perl6 bootstrap.pl                                              &&
    cd ..                                                           &&
    export PATH=`pwd`/install/share/perl6/site/bin:\$PATH           &&
    panda install Inline::Perl5                                     || exit 1

    # {$*SCRIPT_STAGE = 'Rakudo: make stresstest (tarball testing)'}
    TEST_JOBS=$cores make stresstest                                || exit 1

    # {$*SCRIPT_STAGE = 'Rakudo: tag release'}
    cd $dir-rakudo                                                  &&
    $with-gpg-passphrase git tag -u $tag-email                  \\
        -s -a -m "tag release #$rakudo-rver" $rakudo-ver            &&
    $with-github-credentials git push --tags                        || exit 1

    # {$*SCRIPT_STAGE = 'Rakudo: Sign the tarball'}
    gpg -b --armor rakudo-YYYY.MM.tar.gz
    SHELL_SCRIPT_END
}

    $with-gpg-passphrase git tag -u $tag-email \\
        -s -a -m 'tag release $nqp-ver' $nqp-ver                    &&
    $with-github-credentials git push --tags                        || exit 1

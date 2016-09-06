unit class NA::ReleaseScript::NQP;
use NA::ReleaseConstants;

method script {
    return qq:to/SHELL_SCRIPT_END/;
    # {$*SCRIPT_STAGE = 'NQP: Clone repo'}
    git clone $nqp-repo nqp                                         &&
    cd nqp                                                          || exit 1

    # {$*SCRIPT_STAGE = 'NQP: Bump MoarVM version'}
    echo '$moar-ver' > tools/build/MOAR_REVISION                    &&
    git commit -m 'bump MoarVM version to $moar-ver' \\
        tools/build/MOAR_REVISION                                   || exit 1

    # {$*SCRIPT_STAGE = 'NQP: Bump nqp version'}
    echo '$nqp-ver' > VERSION                                       &&
    git commit -m 'bump VERSION to $nqp-ver' VERSION                &&
    $with-github-credentials git push                               || exit 1

    # {$*SCRIPT_STAGE = 'NQP: Build and test'}
    perl Configure.pl --gen-moar --backend=moar,jvm                 &&
        make                                                        &&
        make m-test                                                 &&
        make j-test                                                 &&
        echo "$na-msg nqp tests OK"                                 || exit 1

    # {$*SCRIPT_STAGE
        = 'NQP: Make release and copy over the tarball to testing area'}
    make release VERSION=$nqp-ver                                   &&
        cp nqp-$nqp-ver.tar.gz $dir-temp                            &&
        cd $dir-temp                                                &&
        tar -xvvf nqp-$nqp-ver.tar.gz                               &&
        cd nqp-$nqp-ver                                             || exit 1

    # {$*SCRIPT_STAGE = 'NQP: Build and test the release tarball'}
    perl Configure.pl --gen-moar --backend=moar,jvm                 &&
        make                                                        &&
        make m-test                                                 &&
        make j-test                                                 &&
        echo "$na-msg nqp release tarball tests OK"                 || exit 1

    # {$*SCRIPT_STAGE = 'NQP: Go back to nqp dir so we could sign stuff'}
    cd $dir-nqp                                                     || exit 1

    # {$*SCRIPT_STAGE = 'NQP: Tag nqp'}
    $with-gpg-passphrase git tag -u $tag-email \\
        -s -a -m 'tag release $nqp-ver' $nqp-ver                    &&
    $with-github-credentials git push --tags                        || exit 1

    # {$*SCRIPT_STAGE = 'NQP: Sign the tarball'}
    gpg --batch --no-tty --passphrase-fd 0 -b \\
        --armor nqp-$nqp-ver.tar.gz                                 || exit 1
    $gpg-keyphrase

    cp nqp-$nqp-ver.tar.gz* $dir-tarballs                           &&
    cd $release-dir                                                 || exit 1

    # {$*SCRIPT_STAGE = 'NQP: indicate release succeeded'}
    echo '$na-msg nqp release DONE'                                 || exit 1
    SHELL_SCRIPT_END
}

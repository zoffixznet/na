use NA::ReleaseScript;
use NA::ReleaseConstants;

unit class NA::ReleaseScript::NQP does NA::ReleaseScript;

method prefix { 'nqp-' }
method steps {
    return  clone       => step1-clone,
            bump-vers   => step2-bump-versions,
            build       => step3-build,
            test        => step4-test,
            tar         => step5-tar,
            tar-build   => step6-tar-build,
            tag         => step7-tag,
            tar-sign    => step8-tar-sign,
            tar-copy    => step9-tar-copy,
}

sub step1-clone {
    return qq:to/SHELL_SCRIPT_END/;
    git clone $nqp-repo $dir-nqp                                        ||
    \{ echo '$na-fail NQP: Clone repo'; exit 1; \}
    SHELL_SCRIPT_END
}

sub step2-bump-versions {
    return qq:to/SHELL_SCRIPT_END/;
    cd $dir-nqp                                                         ||
    \{ echo '$na-fail NQP: Bump versions'; exit 1; \}

    if grep -Fxq '$moar-ver' tools/build/MOAR_REVISION
    then
        echo '$na-msg NQP: MoarVM version appears to be already bumped';
    else
        echo '$moar-ver' > tools/build/MOAR_REVISION                    &&
        git commit -m 'bump MoarVM version to $moar-ver' \\
            tools/build/MOAR_REVISION                                   ||
        \{ echo '$na-fail NQP: Bump MoarVM version'; exit 1; \}
    fi

    if grep -Fxq '$nqp-ver' VERSION
    then
        echo '$na-msg NQP: NQP version appears to be already bumped';
    else
        echo '$nqp-ver' > VERSION                                       &&
        git commit -m 'bump VERSION to $nqp-ver' VERSION                &&
        $with-github-credentials git push                               ||
        \{ echo '$na-fail NQP: Bump nqp version'; exit 1; \}
    fi
    SHELL_SCRIPT_END
}

sub step3-build {
    return qq:to/SHELL_SCRIPT_END/;
    cd $dir-nqp                                                     &&
    perl Configure.pl --gen-moar \\
            --backend=moar{',jvm' unless %*ENV<NA_NO_JVM> }         &&
    make -j$cores                                                   ||
    \{ echo '$na-fail NQP: build'; exit 1; \}
    SHELL_SCRIPT_END
}

sub step4-test {
    return qq:to/SHELL_SCRIPT_END/;
    cd $dir-nqp                                                      &&
    make m-test                                                      &&
    {'make j-test &&' unless %*ENV<NA_NO_JVM> }
    echo "$na-msg nqp tests OK"                                      ||
    \{ echo '$na-fail NQP: test'; exit 1; \}
    SHELL_SCRIPT_END
}

sub step5-tar {
    return qq:to/SHELL_SCRIPT_END/;
    cd $dir-nqp                                                     &&
    make release VERSION=$nqp-ver                                   &&
    cp nqp-$nqp-ver.tar.gz $dir-temp                                &&
    cd $dir-temp                                                    &&
    tar -xvvf nqp-$nqp-ver.tar.gz                                   &&
    cd nqp-$nqp-ver                                                 ||
    \{
        echo '$na-fail NQP: Make release tarball and copy testing area';
        exit 1;
    \}
    SHELL_SCRIPT_END
}

sub step6-tar-build {
    return qq:to/SHELL_SCRIPT_END/;
    cd $dir-temp                                                    &&
    cd nqp-$nqp-ver                                                 &&
    perl Configure.pl --gen-moar \\
        --backend=moar{',jvm' unless %*ENV<NA_NO_JVM> }             &&
    make -j$cores                                                   &&
    make m-test                                                     &&
    {'make j-test &&' unless %*ENV<NA_NO_JVM> }
    echo "$na-msg nqp release tarball tests OK"                     ||
    \{ echo '$na-fail NQP: Build and test the release tarball'; exit 1; \}
    SHELL_SCRIPT_END
}

sub step7-tag {
    return qq:to/SHELL_SCRIPT_END/;
    cd $dir-nqp                                                     &&
    $with-gpg-passphrase git tag -u $tag-email \\
        -s -a -m 'tag release $nqp-ver' $nqp-ver                    &&
    $with-github-credentials git push --tags                        ||
    \{ echo '$na-fail NQP: Tag nqp'; exit 1; \}
    SHELL_SCRIPT_END
}

sub step8-tar-sign {
    return qq:to/SHELL_SCRIPT_END/;
    cd $dir-nqp                                                     &&
    gpg --batch --no-tty --passphrase-fd 0 -b \\
        --armor nqp-$nqp-ver.tar.gz                                 ||
    \{ echo '$na-fail NQP: Sign the tarball'; exit 1; \}
    $gpg-keyphrase
    SHELL_SCRIPT_END
}

sub step9-tar-copy {
    return qq:to/SHELL_SCRIPT_END/;
    cd $dir-nqp                                                     &&
    cp nqp-$nqp-ver.tar.gz* $dir-tarballs                           &&
    cd $release-dir                                                 &&
    echo '$na-msg nqp release DONE'                                 ||
    \{ echo '$na-fail NQP: copy tarball to release dir'; exit 1; \}
    SHELL_SCRIPT_END
}

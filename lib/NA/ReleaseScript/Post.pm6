use NA::ReleaseScript;
use NA::ReleaseConstants;
use NA::R6;

unit class NA::ReleaseScript::Post does NA::ReleaseScript;

method prefix { 'post-' }
method steps {
    return (scp => step1-scp,);
}

sub step1-scp {
    return qq:to/SHELL_SCRIPT_END/;
    cd $dir-tarballs                                                        &&
    scp nqp-$nqp-ver.tar.gz* $nqp-scp                                       &&
    scp rakudo-$rakudo-ver.tar.gz* $rakudo-scp                              &&
    scp nqp-$nqp-ver.tar.gz* $nqp-scp-p6                                    &&
    scp rakudo-$rakudo-ver.tar.gz* $rakudo-scp-p6                           &&
    echo '$na-msg Post: upload tarballs to rakudo.org and rakudo.perl6.org' ||
    \{ echo '$na-fail Post: upload tarballs'; exit 1; \}
    SHELL_SCRIPT_END
}

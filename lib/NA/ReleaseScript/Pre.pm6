use NA::ReleaseScript;
use NA::ReleaseConstants;

unit class NA::ReleaseScript::Pre does NA::ReleaseScript;

method prefix { 'pre-' }
method steps {
    return (blank-slate => step1-blank-slate,);
}

sub step1-blank-slate {
    return qq:to/SHELL_SCRIPT_END/;
    rm -fr $release-dir                                             &&
    mkdir $release-dir                                              &&
    cd $release-dir                                                 &&
    mkdir $dir-temp                                                 &&
    mkdir $dir-nqp                                                  &&
    mkdir $dir-rakudo                                               &&
    mkdir $dir-tarballs                                             ||
    \{ echo '$na-fail Start with a blank slate'; exit 1; \}
    SHELL_SCRIPT_END
}

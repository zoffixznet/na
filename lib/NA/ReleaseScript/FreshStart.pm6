unit class NA::ReleaseScript::FreshStart;
use NA::ReleaseConstants;

method script {
    return qq:to/SHELL_SCRIPT_END/;
    # {$*SCRIPT_STAGE = 'Fresh start: Start with a blank slate'}
    rm -fr $release-dir                                             &&
    mkdir $release-dir                                              &&
    cd $release-dir                                                 &&
    mkdir $dir-temp                                                 &&
    mkdir $dir-nqp                                                  &&
    mkdir $dir-rakudo                                               &&
    mkdir $dir-doc                                                  &&
    mkdir $dir-tarballs                                             || exit 1
    SHELL_SCRIPT_END
}

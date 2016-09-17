use NA::Config;
use NA::ReleaseScript;
use NA::ReleaseConstants;
use NA::R6;

unit class NA::ReleaseScript::Pre does NA::ReleaseScript;

method prefix { 'pre-' }
method steps {
    return  r6 => step1-r6,
            blank-slate => step2-blank-slate;
}

sub step1-r6 {
    my $res = NA::R6.new.stats
        or return "echo '$na-fail Failed to access R6 API'; exit 1";

    return "echo '$na-fail R6 status is not clean. Cannot proceed'; exit 1"
        if $res<unreviewed_tickets> or $res<blockers>
            or $res<unreviewed_commits>;

    return "echo 'R6 status is clean'";
}

sub step2-blank-slate {
    return qq:to/SHELL_SCRIPT_END/;
    rm -fr $release-dir                                             &&
    mkdir $release-dir                                              &&
    cd $release-dir                                                 &&
    mkdir $dir-temp                                                 &&
    mkdir $dir-nqp                                                  &&
    mkdir $dir-rakudo                                               &&
    mkdir $dir-tarballs                                             &&
    echo '$na-msg Prep done'                                        ||
    \{ echo '$na-fail Start with a blank slate'; exit 1; \}
    SHELL_SCRIPT_END
}

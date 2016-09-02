unit class NA::Releaser;

use NA::RemoteShell;
use NA::ReleaseScript::NQP;
use NA::ReleaseConstants;

has NA::RemoteShell $!shell;
has Supplier        $!messenger       = Supplier.new;
has Supplier        $!shell-messenger = Supplier.new;
has Supply          $.messages        = $!messenger.Supply;
has Supply          $.shell-out       = $!shell-messenger.Supply;

submethod BUILD {
    $!shell .= new; END { $!shell.end }
    $!shell.launch: :out{ self!in: $^v }, :err{ self!in: $^v }, :$user, :$host;
}

method release ($what) {
    given $what {
        when 'nqp' { $!shell.send: NA::ReleaseScript::NQP.script; }
        default    { die "I don't know how to release `$what`";   }
    }
}

method !in ($in) {
    # Scrub sensitive info from output
    my $mes = $in.subst(:g, $gpg-keyphrase, '*****')
                 .subst(:g, $github-user,   '*****')
                 .subst(:g, $github-pass,   '*****');

    say "Got stuff: $mes";

    $!shell-messenger.emit: $mes;
    $!messenger.emit: ~$<msg> if $mes ~~ /$na-msg \s* $<msg>=\N+/;
}

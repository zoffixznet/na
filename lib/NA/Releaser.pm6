unit class NA::Releaser;

use NA::RemoteShell;
use NA::ReleaseConstants;
use NA::ReleaseScript::FreshStart;
use NA::ReleaseScript::NQP;
use NA::ReleaseScript::Rakudo;

has NA::RemoteShell $!shell;
has Channel         $.messages = Channel.new;
has Channel         $.out      = Channel.new;
has Channel         $.err      = Channel.new;

submethod BUILD {
    $!shell .= new;
    $!shell.launch: :out{ self!in: $^v }, :err{ self!in: $^v, :err },
                    :$user, :$host;
    # This is important to send at the start so we don't accidentally shove
    # sensitive stuff into history file. Let's not rely on release scripts
    # to take care of this.
    $!sell.send: qq:to/END/;
        set -x
        unset HISTFILE
        hostname
        END
}

method end {
    given $!shell.end {
        $!out.close;
        $!err.close;
        $!messages.close;
        .return;
    }
}

method run ($what) {
    $!shell.send: do given $what {
        when 'fresh-start' { NA::ReleaseScript::FreshStart.script;      }
        when 'nqp-full'    { NA::ReleaseScript::NQP       .script;      }
        when 'rakudo-full' { NA::ReleaseScript::Rakudo    .script;      }
        default            { die "I don't know how to release `$what`"; }
    }
}

method !in ($in, Bool :$err) {
    # Scrub sensitive info from output
    my $mes = $in.subst(:g, $gpg-keyphrase, '*****')
                 .subst(:g, $github-user,   '*****')
                 .subst(:g, $github-pass,   '*****');

    if $err { $!err.send: $_ for $mes.lines }
    else    { $!out.send: $_ for $mes.lines }
    $!messages.send: ~$<msg>
        if not $err and $mes ~~ /$na-msg \s* $<msg>=\N+/;
}

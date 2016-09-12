unit class NA::Releaser;

use NA::RemoteShell;
use NA::ReleaseConstants;
use NA::ReleaseScript::Pre;
use NA::ReleaseScript::NQP;
use NA::ReleaseScript::Rakudo;

constant %Cats = %(
    pre => NA::ReleaseScript::Pre,
    nqp => NA::ReleaseScript::NQP,
    r   => NA::ReleaseScript::Rakudo
);

has NA::RemoteShell $!shell;
has Channel         $.messages = Channel.new;
has Channel         $.failures = Channel.new;
has Channel         $.out      = Channel.new;
has Channel         $.err      = Channel.new;


submethod BUILD {
    $!shell .= new;
    $!shell.launch: :out{ self!in: $^v }, :err{ self!in: $^v, :err },
                    :$user, :$host;
    # This is important to send at the start so we don't accidentally shove
    # sensitive stuff into history file. Let's not rely on release scripts
    # to take care of this.
    $!shell.send: qq:to/END/;
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
        $!failures.close;
        .return;
    }
}

method run ($what) {
    my @steps = flat do given $what {
        when 'pre-full' { NA::ReleaseScript::Pre.steps».value;   }
        when 'nqp-full' { NA::ReleaseScript::NQP.steps».value;   }
        when 'r-full'   { NA::ReleaseScript::Rakudo.steps».value;}
        when /^ $<cat>=[@(%Cats.keys)] '-' $<step>=.+ / {
            %Cats{~$<cat>}.step: ~$<step> or return "No such step: $<step>";
        }
        default { return "I don't know how to execute `$what`"; }
    }
    $!shell.send: $_ for @steps;
}

method !in ($in, Bool :$err) {
    # Scrub sensitive info from output
    my $mes = $in.subst(:g, $gpg-keyphrase, '*****')
                 .subst(:g, $github-user,   '*****')
                 .subst(:g, $github-pass,   '*****');

    if $err { $!err.send: $_ for $mes.lines }
    else    { $!out.send: $_ for $mes.lines }
    $!messages.send: ~$<msg>
        if not $err and $mes ~~ /$na-msg  \s* $<msg>=\N+/;
    $!failures.send: ~$<msg>
        if not $err and $mes ~~ /$na-fail \s* $<msg>=\N+/;
}

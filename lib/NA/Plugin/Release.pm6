unit class NA::Plugin::Release;
use NA::Releaser;
use NA::UA;
use IRC::Client::Message;
use URI::Escape;
use Terminal::ANSIColor;

subset BotAdmin of IRC::Client::Message
    where .host eq any <unaffiliated/zoffix  localhost  127.0.0.1>;

has $.r6-url = %*ENV<NA_R6_HOST> || 'http://perl6.fail/';

multi method irc-to-me ($e where /:i ^ ['status' | 'stats'] $ /) {
    my $res = try {
        ua-get-json $!r6-url ~ "release/stats.json"
    } or return 'Error accessing R6 API';

    my $status = '✔';
    $status    = '✘'
        if $res<unreviewed_tickets> or $res<blockers>
            or $res<unreviewed_commits>;

    return "[$status] Next release $res<when_release>."
        ~ " Since last release, there are $res<total_tickets> new"
        ~ " still-open tickets ($res<unreviewed_tickets> unreviewed"
        ~ " and $res<blockers> blockers) and $res<unreviewed_commits>"
        ~ " unreviewed commits. See $res<url> for details";
}

multi method irc-to-me ($e where /:i ^ 'blockers' $ /) {
    my $res = try {
        ua-get-json $!r6-url ~ "release/blockers.json"
    } or return 'Error accessing R6 API';

    return 'There are no release blockers' unless $res<tickets>.elems;

    my $n = $res<total_blockers>;
    $e.reply: "There {$n > 1 ?? 'are' !! 'is'} $n release "
        ~ "blocker{'s' if $n > 1}. See $res<url>";

    # Avoid too much spam; print only the four
    unless $n > 4 {
        $e.reply: "{.<url>} : {.<subject>}" for |$res<tickets>;
    };

    Nil;
}

multi method irc-to-me (BotAdmin $e where /:i ^ 'steps'           $/ ) {
    join ' ', NA::Releaser.available-steps;
}
multi method irc-to-me (BotAdmin $e where /:i ^ 'run' $<steps>=.+ $/ ) {
    my @steps = $<steps>.words;
    $_ eq NA::Releaser.available-steps.any or return "`$_` is not a valid step"
        for @steps;

    start {
        my $rel = NA::Releaser.new;
        start { react {
            whenever $rel.messages { $e.reply: "♥♥♥♥♥♥ $^mes"    }
            whenever $rel.failures { $e.reply: "☠☠☠☠☠☠ $^mes"    }
            whenever $rel.err      { say colored $^mes, 'yellow' }
            whenever $rel.out      { say colored $^mes, 'white'  }
        }}

        $rel.run: $_ for @steps;

        sleep 2; # give the other messages a chance to be sent out
        with $rel.end {
            # Abnormal exit
            say colored $_, 'bold white on_red';
            $e.reply: "☠☠☠☠☠☠☠☠☠☠ $_";
        }
        else {
            $e.reply: "♥♥♥ All Done! ♥♥♥";
        }

        Nil;
    }
}

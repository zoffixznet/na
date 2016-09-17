unit class NA::Plugin::Release;
use NA::Config;
use NA::Releaser;
use NA::R6;
use IRC::Client::Message;
use URI::Escape;
use Terminal::ANSIColor;

has $!r6 = NA::R6.new;
subset BotAdmin of IRC::Client::Message where .host eq conf<bot-admins>.any;

multi method irc-to-me ($e where /:i ^ ['status' | 'stats'] $ /) {
    my $res = $!r6.stats or return 'Error accessing R6 API';

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
    my $res = $!r6.blockers or return 'Error accessing R6 API';
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
    say "Starting steps run: $<steps>.words()";
    spurt conf<release-log>, ''
        if $<steps>.words.any eq any <pre pre-blank-slate all>;
    self!run-steps: $e, $<steps>.words;
}

multi method irc-to-me (
    BotAdmin $e where /:i ^ 'cut ' ['a'|'the'] ' release' $/
) {
    note "Starting a release";
    spurt conf<release-log>, '';
    $e.reply: ｢Will do! If you're feeling particularly naughty, you can watch ｣
        ~ ｢me at http://perl6.fail/release/progress or go look ｣
        ~ ｢at some cats http://www.lolcats.com/｣;
    self!run-steps: $e, 'all';
}

method !run-steps ($e, *@steps) {
    $_ eq NA::Releaser.available-steps.any or return "`$_` is not a valid step"
        for @steps;

    start {
        my $rel = NA::Releaser.new;
        start { react {
            whenever $rel.messages {
                given "♥♥♥♥♥♥ $^mes" {
                    $e.reply: $_;
                    send-to-log "MSGOUT: $_";
                }
            }
            whenever $rel.failures {
                given "☠☠☠☠☠☠ $^mes" {
                    $e.reply: $_;
                    send-to-log "MSGERR: $_";
                };
            }
            whenever $rel.err {
                say colored $^mes, 'yellow';
                send-to-log "STDERR: $^mes";
            }
            whenever $rel.out {
                say colored $^mes, 'white';
                send-to-log "STDOUT: $^mes";
            }
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

sub send-to-log ($what) { spurt :append, conf<release-log>, "$what\n"; }

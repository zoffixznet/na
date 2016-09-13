use lib <lib>;
use NA::Releaser;
use Terminal::ANSIColor;

subset ValidSteps where {
    my @steps = NA::Releaser.available-steps;
    $_ eq @steps.any
        or note "Step `{colored $_, 'red'}` is not one of valid steps:\n    "
                ~ colored @steps.join("\n    "), 'white'
        and exit;
};

multi MAIN (:$help!) { help }
multi MAIN ( *@steps where { .all ~~ ValidSteps } ) {
    my $rel = NA::Releaser.new;
    start { react {
        whenever $rel.messages { say colored "♥♥♥♥♥♥ $^mes", 'white on_blue' }
        whenever $rel.failures { say colored "☠☠☠☠☠☠ $^mes", 'white on_red'  }
        whenever $rel.err      { say colored $^mes,          'yellow'        }
        whenever $rel.out      { say colored $^mes,          'white'         }
    }}

    $rel.run: $_ for @steps;
    with $rel.end { #`(Abnormal exit) say colored $_, 'bold white on_red'; }
}

sub help {
    say qq:to/END/
    Run without arguments to iterate over all the steps.

    Specifify individual steps to run:

        {colored 'cli-runner.p6 pre nqp', 'green'}

    Use {colored '--from', 'white'}/{colored '--to', 'white'} to specify
    starting/ending steps (inclusive). Default start is from the first step
    and default end is to the last available step.

    Available steps:
        {colored join("\n    ", NA::Releaser.available-steps), 'white'}

    END
}

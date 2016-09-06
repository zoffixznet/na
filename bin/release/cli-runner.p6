use lib <lib>;
use NA::Releaser;
use Terminal::ANSIColor;

my $rel = NA::Releaser.new;
start {
    react {
        whenever $rel.messages { say colored "♥♥♥♥♥♥ $^mes", 'white on_blue' }
        whenever $rel.err      { say colored $^mes,          'yellow'        }
        whenever $rel.out      { say colored $^mes,          'white'         }
    }
}

with $rel {
    my $*SCRIPT_STAGE = 'unset';
    for <fresh-start  nqp-full  rakudo-full> {
        .run: $^step;
    }
    with .end { say colored $_, 'bold white on_red' }
};

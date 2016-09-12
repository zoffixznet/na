use lib <lib>;
use NA::Releaser;
use Terminal::ANSIColor;

my $rel = NA::Releaser.new;
start {
    react {
        whenever $rel.messages { say colored "♥♥♥♥♥♥ $^mes", 'white on_blue' }
        whenever $rel.failures { say colored "☠☠☠☠☠☠ $^mes", 'white on_red'  }
        whenever $rel.err      { say colored $^mes,          'yellow'        }
        whenever $rel.out      { say colored $^mes,          'white'         }
    }
}

with $rel {
    for <pre-full  nqp-full  r-full> -> $step {
        .run: $step;
    }
    with .end { say colored $_, 'bold white on_red' }
};

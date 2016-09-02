use lib <lib>;
use NA::Releaser;

react {
    with NA::Releaser.new {
        whenever .messages  { "♥♥♥♥♥♥ $mess".put; }
        whenever .shell-out { "SHELL: $mess".put; }

        .release: 'nqp';
    }
    done;
}

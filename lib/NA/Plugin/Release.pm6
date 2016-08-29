unit class NA::Plugin::Release;
use NA::UA;
use URI::Escape;

has $.r6-url = %*ENV<NA_R6_HOST> || 'http://perl6.fail/';

multi method irc-to-me ($e where /:i ^ 'status' $ /) {
    my $res = try {
        ua-get-json $!r6-url ~ "release/stats.json"
    } or return 'Error accessing R6 API';

    my $status = $res<unreviewed> || $res<blockers> ?? '✘' !! '✔';

    return "[$status] Next release $res<when_release>."
        ~ " Since last release, there are $res<total_tickets> new"
        ~ " still-open tickets ($res<unreviewed> unreviewed"
        ~ " and $res<blockers> blockers). See $res<url> for details";
}

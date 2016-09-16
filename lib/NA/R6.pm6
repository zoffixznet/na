unit class NA::R6;
use NA::UA;

has $.r6-url = %*ENV<NA_R6_HOST> || 'http://perl6.fail/';

method stats    { self!fetch: "release/stats.json"    }
method blockers { self!fetch: "release/blockers.json" }
method !fetch ($path) { try ua-get-json $!r6-url ~ $path }

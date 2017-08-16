#!/usr/bin/env perl6
use lib <
    /home/zoffix/CPANPRC/IRC-Client/lib
    /home/zoffix/services/lib/IRC-Client/lib
    lib
>;

use IRC::Client;
use NA::Config;
use NA::Plugin::Release;
use NA::Plugin::Babble;

class NA::Info {
    multi method irc-to-me ($ where /^\s* help \s*$/) {
        "stats | blockers";
    }
    multi method irc-to-me ($ where /^\s* source \s*$/) {
        "See: https://github.com/zoffixznet/na";
    }
  
    multi method irc-to-me ($ where /'bot' \s* 'snack'/) { "om nom nom nom"; }
    multi method irc-to-me ($) { "Use releasable6 bot instead. e.g. try: releasable6: status" }
}

.run with IRC::Client.new:
    :nick<NeuralAnomaly>,
    :username<zofbot-na>,
    :host(%*ENV<NA_IRC_HOST> // 'irc.freenode.net'),
    :channels( %*ENV<NA_DEBUG> ?? '#zofbot' !! |<#perl6  #perl6-dev  #zofbot>),
#    |(:password(conf<irc-pass>) if conf<irc-pass>),
    :debug,
    :plugins(
        NA::Info.new,
#        NA::Plugin::Release.new,
 #       NA::Plugin::Babble.new,
    );

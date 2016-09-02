unit class NA::Releaser;

use NA::RemoteShell;
use NA::ReleaseScript::NQP;
use NA::ReleaseConstants;

has Supplier $!messenger       = Supplier.new;
has Supplier $!shell-messenger = Supplier.new;
has Supply   $.messages        = $!messender.Supply;
has Supply   $.shell-out       = $!shell-messenger.Supply;

method !in {
    # Scrub sensitive info from output
    my $mes = $^v.subst(:g, $gpg-keyphrase, '*****')
                 .subst(:g, $github-user,   '*****')
                 .subst(:g, $github-pass,   '*****');

    $!shell-messenger.emit: $mes;
    $!messenger.emit: ~$<msg> if $mes ~~ /$na-msg \s* $<msg>=\N+/;
}

my NA::RemoteShell $shell .= new;
$shell.launch: :out{ self.in: $^v }, :err{ self.in: $^v }, :$user, :$host;
$shell.send: NA::ReleaseScript::NQP.script;
$shell.end;

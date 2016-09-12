unit class NA::RemoteShell;
has $!proc;
has Promise $!prom;

method launch (
    :$host = 'localhost', :$user,
    :&out, :&err
) {
    $!proc = Proc::Async.new: :out, :err, :w,
        'ssh', '-o', 'StrictHostKeyChecking no',
            "{"$user@" if $user}$host", '-T';

    $!proc.stdout.tap: &out if &out;
    $!proc.stderr.tap: &err if &err;
    $!prom = $!proc.start;
}

method send (Str $what) {
    CATCH { default { say 'Remote shell exploded. Aborting release'; } }
    await $!proc.write: "$what\n".encode;
}

method end {
    self.send: "\nexit;";
    my $result-proc = await $!prom;
    return "ABNORMAL EXIT!"
        if $result-proc.exitcode != 0;
    return Nil;
}

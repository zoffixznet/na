use lib <lib>;
use NA::RemoteShell;

constant $user = 'zoffix';
constant $host = 'perl6.party';
constant $nqp-repo = 'https://github.com/zoffixznet/nqp';
constant $release-dir = '/tmp/release/';

given NA::RemoteShell.new {
    $^s.launch: :&out, :$user, :$host;
    $^s.send: $_
        for 'hostname',
            "source /home/$user/.bashrc",
            "rm -fr $release-dir", "mkdir $release-dir", "cd $release-dir",

            # NQP
                "git clone $nqp-repo nqp",
                "cd nqp",
                'perl Configure.pl --gen-moar --backend=moar,jvm &&'
                    ~ 'make && make m-test && make j-test &&'
                    ~ 'echo "NeuralAnomaly RELEASE STATUS: OK"',
                "cd $release-dir",
            ;
    $^s.end;
}

sub out {
    say "#### THIS IS WHERE WE LAUNCH THE RELEASE!"
        if $^v ~~ /'RELEASE STATUS: OK'/;

    "Remote shell: $^v".print;
}

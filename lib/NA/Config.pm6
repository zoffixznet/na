unit module NA::Config;
use JSON::Fast;
state $config = from-json 'config.json'.IO.slurp;
sub conf is export { $config }

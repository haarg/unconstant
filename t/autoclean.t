use strict;
use warnings;
use Test::Needs 'namespace::autoclean';
use Test::More;

use Data::Dumper;

{
  eval q{
    package WithUnconstant;
    use unconstant;
    use constant FOO => 1;
    use namespace::autoclean;
    1;
  } or die $@;
  ok defined &WithUnconstant::FOO,
    'namespace::autoclean does not remove unconstants';
}

done_testing;

use strict;
use warnings;
use Test::More;

use Data::Dumper;

{
  my $sub = eval q{
    package WithUnconstant;
    use unconstant;
    use constant FOO => 1;

    sub {
      return FOO;
    };
  };
  local $Data::Dumper::Deparse = 1;
  like Dumper($sub), qr/FOO/,
    'constant optimization defeated';
}

{
  my $sub = eval q{
    package WithoutUnconstant;
    no unconstant;
    use constant FOO => 1;

    sub {
      return FOO;
    };
  };
  local $Data::Dumper::Deparse = 1;
  unlike Dumper($sub), qr/FOO/,
    'constant optimization can be re-enabled';
}

done_testing;

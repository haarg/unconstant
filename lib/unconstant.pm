package unconstant;
use strict;
use warnings;

our $VERSION = '0.001000';
$VERSION =~ tr/_//d;

use constant;

my $const_import = \&constant::import;
my $installed;
sub import {
    return if $installed;
    my %import_wrappers;
    no warnings 'redefine';
    *constant::import = sub {
        my $caller = caller;
        return if @_ < 2;
        my $real_import = $const_import;
        my $import = $import_wrappers{$caller} ||= do {
            my $e;
            my $sub;
            {
                local $@;
                eval qq{
                    \$sub = sub {
                        package $caller;
                        &\$real_import;
                    };
                    1;
                } or $e = $@;
            }
            die $e if defined $e;
            $sub;
        };
        my @names = ref $_[1] ? keys %{$_[1]} : $_[1];
        &$import;
        for my $constant (@names) {
            no strict 'refs';
            my $full_name = $constant =~ /::/ ? $constant : $caller.'::'.$constant;
            my $const_sub = \&$full_name;
            # lie about package because some things check sub names
            package #hide
                constant;
            *$full_name = sub () { &$const_sub };
        }
    };
    $installed = 1;
}

sub unimport {
    return unless $installed;
    no warnings 'redefine';
    *constant::import = $const_import;
    $installed = 0;
}

1;
__END__

=head1 NAME

unconstant - Prevent constant optimizations

=head1 SYNOPSIS

  use unconstant;

  use constant FOO => 0;

  if (FOO) { # won't be contant optimized
    print "hi\n";
  }

=head1 DESCRIPTION

Prevents constants from being optimized, but instead to be called every time
they are used.

=head1 AUTHOR

haarg - Graham Knop (cpan:HAARG) <haarg@haarg.org>

=head1 CONTRIBUTORS

None so far.

=head1 COPYRIGHT

Copyright (c) 2019 the unconstant L</AUTHOR> and L</CONTRIBUTORS>
as listed above.

=head1 LICENSE

This library is free software and may be distributed under the same terms
as perl itself. See L<https://dev.perl.org/licenses/>.

=cut

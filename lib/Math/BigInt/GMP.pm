###############################################################################
# core math lib for BigInt, representing big numbers by the GMP library

package Math::BigInt::GMP;

use strict;
use 5.005;
# use warnings; # dont use warnings for older Perls

require Exporter;
require DynaLoader;

use vars qw/@ISA $VERSION/;
@ISA = qw(Exporter DynaLoader);
$VERSION = '1.16';

bootstrap Math::BigInt::GMP $VERSION;

sub import { }			# catch and throw away
sub api_version() { 1; }	# we are compatible with MBI v1.70 and up

BEGIN
  {
  # both _num and _str just return a string
  *_str = \&_num;
  }

# Routines not present here are in GMP.xs

##############################################################################
# testing

sub _len
  {
  # return length, aka digits in decmial, costly!!
  length( Math::BigInt::GMP::_num(@_) );
  }

sub _digit
  {
  # return the nth digit, negative values count backward; this is costly!
  my ($c,$x,$n) = @_;

  $n++; substr( Math::BigInt::GMP::_num($c,$x), -$n, 1 );
  }

###############################################################################
# check routine to test internal state of corruptions

sub _check
  {
  # no checks yet, pull it out from the test suite
  my ($x) = $_[1];
  return "$x is not a reference to Math::BigInt::GMP"
   if ref($x) ne 'Math::BigInt::GMP';
  0;
  }

sub _log_int
  {
  my ($c,$x,$base) = @_;

  # X == 0 => NaN
  return if _is_zero($c,$x);
  # BASE 0 or 1 => NaN
  return if _is_zero($c,$base) || _is_one($c,$base);

  my $cmp = _acmp($c,$x,$base); 	# X == BASE => 1
  if ($cmp == 0)
    {
    # return one
    return (_one($c), 1);
    }
  # X < BASE
  if ($cmp < 0)
    {
    return (_zero($c),undef);
    }

  my $trial = _copy($c,$base);
  my $x_org = _copy($c,$x);
  $x = _one($c);

  my $a;
  my $base_mul = _mul($c, _copy($c,$base), $base);
  my $two = _two($c);

  while (($a = _acmp($c, $trial, $x_org)) < 0)
    {
    _mul($c,$trial,$base_mul); _add($c, $x, $two);
    }

  my $exact = 1;
  if ($a > 0)
    {
    # overstepped the result
    _dec($c, $x);
    _div($c,$trial,$base);
    $a = _acmp($c,$trial,$x_org);
    if ($a > 0)
      {
      _dec($c, $x);
      }
    $exact = 0 if $a != 0;
    }

  ($x,$exact);
  }

1;
__END__

=pod

=head1 NAME

Math::BigInt::GMP - Use the GMP library for Math::BigInt routines

=head1 SYNOPSIS

Provides support for big integer calculations via means of the GMP c-library.

Math::BigInt::GMP now no longer uses Math::GMP, but provides it's own XS layer
to access the GMP c-library. This cut's out another (perl sub routine) layer
and also reduces the memory footprint by not loading Math::GMP and Carp at
all.

=head1 LICENSE
 
This program is free software; you may redistribute it and/or modify it under
the same terms as Perl itself. 

=head1 AUTHOR

Tels <http://bloodgate.com/> in 2001-2004.

Thanx to Chip Turner for providing Math::GMP, which was inspiring my work.

=head1 SEE ALSO

L<Math::BigInt>, L<Math::BigInt::Calc>.

=cut

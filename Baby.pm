package Acme::Time::Baby;

#
# $Id: Baby.pm,v 1.6 2002/05/13 23:06:23 abigail Exp abigail $
#
# $Log: Baby.pm,v $
# Revision 1.6  2002/05/13 23:06:23  abigail
# Added support for the following languages:
#     German (de)   (Tim Heaney)
#     French (fr)   (Tim Heaney)
#     Norwegian (no) (Peter J. Acklam)
#     Italian (it)  (Andrea Spinelli)
#
# Revision 1.5  2002/04/26 16:10:49  abigail
# Added INSTALLATION topic to the POD, so we can do
# pod2text Baby.pm > README
#
# Revision 1.4  2002/04/26 12:28:56  abigail
# Added support for 'Swedish chef' and 'Warez' languages.
#
# Revision 1.3  2002/04/25 23:35:24  abigail
# Added a check to see whether at least 12 numbers have been passed.
#
# Revision 1.2  2002/04/25 23:32:06  abigail
# Get rid of Exporter.
# Support for Dutch.
# Customizable format and numbers.
# PODdified.
#
# Revision 1.1  2002/04/25 22:14:39  abigail
# Initial revision
#
#

use strict;
use warnings qw /all/;

use vars qw /$VERSION/;

($VERSION)  = q $Revision: 1.6 $ =~ /([\d.+])/;

my %languages = (
    'en'      => {numbers => [qw /one two three four five six seven
                                      eight nine ten eleven twelve/],
                  format  => "The big hand is on the %s " .
                             "and the little hand is on the %s"},

    'de'      => {numbers => [qw /eins zwei drie vier f�nf sechs sieben
                                       acht neun zehn elf zw�lf/],
                  format  => "Der grosse Zeiger ist auf die %s " .
                             "und der kleine Zeiger ist auf die %s"},

    'du'      => {numbers => [qw /een twee drie vier vijf zes zeven
                                      acht negen tien elf twaalf/],
                  format  => "De grote wijzer is op de %s " .
                             "en de kleine wijzer is op de %s"},

    'fr'      => {numbers => [qw /un deux trois quatre cinq six sept
                                     huit neuf dix onze douze/],
                  format  => "La grande aiguille est sur le %s " .
                             "et la petite aiguille est sur le %s"},

    'it'      => {numbers => ['a una', 'e due', 'e tre', 'e quattro',
                                       'e cinque', 'e sei', 'e sette',
                                       'e otto', 'e nove', 'e dieci',
                                       'e undici', 'e dodici'],
                  format  => "La lancetta lunga e' sull%s " .
                             "e quella corta e' sull%s"},

    'no'      => {numbers => [qw /en to tre fire fem seks syv
                                     �tte ni ti elleve tolv/],
                  format  => "Den store viseren er p� %s " .
                             "og den lille viseren er p� %s"},

    'swedish chef'
              => {numbers => [qw /one tvu three ffuoor ffeefe six
                                  sefen eight nine ten elefen tvelfe/],
                  format  => "Zee beeg hund is un zee %s und zee little " .
                             "hund is un zee %s. Bork, bork, bork!"},

    'warez'   => {numbers => [qw {()nE TW0 7HR3e f0uR f|ve 5ix 
                                  ZE\/3n E|6hT n1nE TeN 3L3v3gn 7wELv3}],
                  format  => 'T|-|3 bIG h4|\||) Yz 0n thE %s ' .
                             'and 7|-|3 lIttlE |-|aND |S 0|\| Th3 %s'},

);

my @numbers = @{$languages {en} {numbers}};
my $format  =   $languages {en} {format};

sub import {
    my $class  = shift;
    my $pkg    = __PACKAGE__;
    my $caller = caller;

    my %args   = @_;

    if ($args {language}) {
        if (exists $languages {$args {language}}) {
            @numbers = @{$languages {$args {language}} {numbers}};
            $format  =   $languages {$args {language}} {format};
        }
        else {
            warn "There is no support for language `$args{language}'\n" if $^W;
        }
    }

    @numbers   = @{$args {numbers}} if exists $args {numbers};
    $format    =   $args {format}   if exists $args {format};

    if (@numbers < 12) {die "You didn't pass in twelve numbers.\n";}

    no strict 'refs';
    *{$caller . '::babytime'} = \&{__PACKAGE__ . '::babytime'}
         unless $args {noimport};
}

sub babytime {
    my ($hours, $minutes);
    if (@_) {
        ($hours, $minutes) = $_ [0] =~ /^(\d+):(\d+)$/
                  or die "$_[0] is not of the form hh:mm\n";
    }
    else {
        ($hours, $minutes) = (localtime) [2, 1];
    }

    $hours ++ if $minutes > 30;

    # Turn $hours into 1 .. 12 format.
    $hours  %= 12;
    $hours ||= 12;

    die "There are just 60 minutes in an hour\n" if $minutes >= 60;

    # Round minutes to nearest 5 minute.
    $minutes   = sprintf "%.0f" => $minutes / 5;
    $minutes ||= 12;

    local $[ = 1;
    sprintf $format => @numbers [$minutes, $hours];
}


1;

__END__

=pod

=head1 NAME

Acme::Time::Baby -- Tell time little children can understand

=head1 SYNOPSIS

    use Acme::Time::Baby;
    print babytime;           #  Prints current time.

    use Acme::Time::Baby language => 'du';
    print babytime "10:15";   #  Prints a quarter past ten in a way
                              #  little Dutch children can understand.

=head1 DESCRIPTION

Using this module gives you the function C<babytime>, which will return
the time in the form B<The big hand is on the ten and the little
hand is on the three>. If no argument to C<babytime> is given, the 
current time is used, otherwise a time of the form I<hh:mm> can be
passed. Both 12 and 24 hour clocks are supported.

When using the module, various options can be given. The following
options can be passed:

=over 4

=item language LANG

The language the time should be told in. The following languages are
currently supported: C<en> (for English), C<de> (for German), C<du>
(for Dutch), C<fr> (for French), C<it> (for Italian), C<no> (for
Norwegian), C<swedish chef> (for Swedish Chef like time) and C<warez>
(for l44+ babies).  If no language argument is given, English is used.

Note that German and Norwegian use accented letters. The returned 
sentences are correct for an ISO 8859-1 platform.

=item format STRING

This is the format used to represent the time. It will be passed to
C<sprintf>, and it should have two C<%s> formatting codes. The other
two arguments to C<sprintf> are the position of the minute hand (the
big hand) and the hour hand (the little hand). If you have perl 5.8
or above, you could use C<%2$s> and C<%1$s> to reverse the order.

=item number ARRAYREF

An array with the names of the numbers one to twelve, to be used in
the formatted time.

=item noimport EXPR

By default, the sub C<babytime> will be exported to the calling package.
If for some reason the calling package does not want to import the sub,
there are two ways to prevent this. Either use C<use Acme::Time::Baby ()>,
which will prevent C<Acme::Time::Baby::import> to be called, or pass
C<noimport> followed by a true value as arguments to the C<use> statement.

=back

=head1 PACKAGE NAME

It has been said this package should be named 'Acme::Time::Toddler',
because it's the language toddlers speak, and not babies.

However, the idea of this package is based on an X application the author
saw more than 10 years before this package was written. It would display
a clock, telling the current time, in a myriad of languages. One of the
languages was I<babytalk>, and used a language very similar to the one
in this package. Hence the name of this package.

=head1 TODO

Support for more languages.

=head1 AUTHOR

Abigail, I<abigail@foad.org>.

=head1 HISTORY

    $Log: Baby.pm,v $
    Revision 1.6  2002/05/13 23:06:23  abigail
    Added support for the following languages:
        German (de)   (Tim Heaney)
        French (fr)   (Tim Heaney)
        Norwegian (no) (Peter J. Acklam)
        Italian (it)  (Andrea Spinelli)

    Revision 1.5  2002/04/26 16:10:49  abigail
    Added INSTALLATION topic to the POD, so we can do
    pod2text Baby.pm > README

    Revision 1.4  2002/04/26 12:28:56  abigail
    Added support for 'Swedish chef' and 'Warez' languages.

    Revision 1.3  2002/04/25 23:35:24  abigail
    Added a check to see whether at least 12 numbers have been passed.

    Revision 1.2  2002/04/25 23:32:06  abigail
    Get rid of Exporter.
    Support for Dutch.
    Customizable format and numbers.
    PODdified.

    Revision 1.1  2002/04/25 22:14:39  abigail
    Initial revision

=head1 LICENSE

This program is copyright 2002 by Abigail.
 
Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:
     
The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHOR BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE. 

=head1 INSTALLATION

To install this module type the following:

   perl Makefile.PL
   make
   make test
   make install

=cut

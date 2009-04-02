# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
use strict;
BEGIN { plan tests => 1 + 24 * 60 };
use Acme::Time::Baby language => 'de';
ok(1); # If we made it this far, we're ok.

#########################

my $i = 0;
my %numbers = map {$_ => ++$i} qw /Eins Zwei Drei Vier F�nf Sechs Sieben
                                   Acht Neun Zehn Elf Zw�lf/;

foreach my $hours (1 .. 24) {
    foreach my $minutes (0 .. 59) {
        my $r = babytime "$hours:$minutes";
        my ($big)    = $r =~ /gro\xDFe Zeiger ist auf der (\S+)/;
        my ($little) = $r =~ /kleine Zeiger ist auf der (\S+)/;

        if (!defined $big || !defined $little) {
            ok (0);
            print "# $hours:$minutes -> $r\n";
            next
        }

        my $ok = 1;

        $big    = $numbers {$big}    and
        $little = $numbers {$little} or do {
            ok (0);
            print "# $hours:$minutes -> $r\n";
            next
        };

           if ($minutes < 3)            {$ok = 0 unless $big == 12;}
        elsif ($minutes < $big * 5 - 2) {$ok = 0;}
        elsif ($minutes > $big * 5 + 2) {$ok = 0;}

        my $h   = $hours;
           $h  += 1 if $minutes > 30;
           $h  %= 12;
           $h ||= 12;

        $ok = 0 if $h != $little;

        ok ($ok);
        unless ($ok) {
            print "# $hours:$minutes -> $r\n";
        }
    }
}

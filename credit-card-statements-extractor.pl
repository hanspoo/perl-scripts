#!/usr/bin/perl

=pod
Extract movements of Credit card account statements in PDF and generate csv file. 

Requires the command pdftotext. It's in debian it is available in the package poppler-utils.
So, before use do:
sudo apt install poppler-utils

Note: Uses dot as thousands separator.

Usage:
credit-card-statements-extractor.pl *.pdf

LICENCE: Apache2

=cut

sub limpiaNum {

my $n = shift;
$n =~ s/\.//g;

return $n;

}

my @lines = ();

foreach (@ARGV) {
    &processFile($_);
}

my @h = ("Date", "Item", "Extra", "Country", "Amount");
print join ("\t", @h), "\n";

foreach (@lines) {

    print $_, "\n";
}

sub processFile {

    my $file = shift;
    $file || die "Must give pdf with card movements";

    my $pdftotext = "/usr/bin/pdftotext";
    die "pdftotext not found" unless -e $pdftotext;
    my $plain = "/tmp/pdf-to-text-$$.txt";

    @command =($pdftotext, "-f", 1,  "-l",  2,  "-layout", $file, $plain);
    # print join " ", @command, "\n";

    system(@command) == 0 || die $!;

    open IN, $plain or die $!;

    while(<IN>) {

        if (($fecha, $glosa, $ciudad, $pais, $monto1, $monto2) = m:^(\d\d/\d\d/\d\d)\s+(\S+)\s*(.*?)\s+(\w\w)\s+([0-9,.]+)\s+([0-9,.]+)$:) {

            my @l = ($fecha, $glosa, $ciudad, $pais, &limpiaNum($monto2));

            push @lines, join ("\t", @l);

        }

    }

}
    




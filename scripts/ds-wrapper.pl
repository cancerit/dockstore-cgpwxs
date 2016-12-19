#!/usr/bin/perl

use strict;
use Getopt::Long;
use File::Path qw(make_path);
use Pod::Usage qw(pod2usage);
use Data::Dumper;
use autodie qw(:all);
use warnings FATAL => 'all';

pod2usage(-verbose => 1, -exitval => 1) if(@ARGV == 0);

# set defaults
my %opts = ('c'=>0,
            'sc' => q{},
            'b' => q{}
            ,);

GetOptions( 'h|help' => \$opts{'h'},
            'm|man' => \$opts{'m'},
            'r|reference=s' => \$opts{'r'},
            'a|annot=s' => \$opts{'a'},
            'si|snv_indel=s' => \$opts{'si'},
            't|tumour=s' => \$opts{'t'},
            'n|normal=s' => \$opts{'n'},
            'e|exclude=s' => \$opts{'e'},
            'sp|species=s' => \$opts{'sp'},
            'as|assembly=s' => \$opts{'as'},
) or pod2usage(2);

pod2usage(-verbose => 1, -exitval => 0) if(defined $opts{'h'});
pod2usage(-verbose => 2, -exitval => 0) if(defined $opts{'m'});

delete $opts{'h'};
delete $opts{'m'};

printf "Options loaded: \n%s\n",Dumper(\%opts);

## unpack the reference area:
my $ref_area = $ENV{HOME}.'/reference_files';

ref_unpack($ref_area, $opts{'r'});
ref_unpack($ref_area, $opts{'a'});
ref_unpack($ref_area, $opts{'si'});

my $run_file = $ENV{HOME}.'/run.params';
open my $FH,'>',$run_file or die "Failed to write to $run_file: $!";
# hard-coded
printf $FH "PROTOCOL=WXS";
# required options
printf $FH "OUTPUT_DIR='%s'\n", $ENV{HOME};
printf $FH "REF_BASE='%s'\n", $ref_area;
printf $FH "BAM_MT='%s'\n", $opts{'t'};
printf $FH "BAM_WT='%s'\n", $opts{'n'};
printf $FH "PINDEL_EXCLUDE='%s'\n", $opts{'e'};
# optional
printf $FH "SPECIES='%s'\n", $opts{'sp'} if(defined $opts{'sp'});
printf $FH "ASSEMBLY='%s'\n", $opts{'sp'} if(defined $opts{'as'});
close $FH;

exec('analysisWXS.sh'); # I will never return to the perl code

sub ref_unpack {
  my ($ref_area, $item) = @_;
  make_path($ref_area) unless(-d $ref_area);
  my $untar = sprintf 'tar --strip-components 1 -C %s -zxvf %s', $ref_area, $item;
  system($untar) && die $!;
  return 1;
}

__END__


=head1 NAME

dh-wrapper.pl - Generate the param file and execute analysisWXS.sh (for dockstore)

=head1 SYNOPSIS

dh-wrapper.pl [options] [file(s)...]

  Required parameters:
    -reference   -r   Path to core reference tar.gz
    -annot       -a   Path to VAGrENT*.tar.gz
    -snv_indel   -si  Path to SNV_INDEL*.tar.gz
    -tumour      -t   Tumour [CR|B]AM file
    -normal      -n   Normal [CR|B]AM file
    -exclude     -e   Exclude these contigs from pindel analysis
                        e.g. NC_007605,hs37d5,GL%

  Optional parameters (if not found in BAM headers):
    -species     -sp  Species name (may require quoting)
    -assembly    -a   Reference assembly

  Other:
    -help        -h   Brief help message.
    -man         -m   Full documentation.

=head1 DESCRIPTION

Wrapper script to map dockstore cwl inputs to PARAMS file used by underlying code.

=head1 OPTION DETAILS

=over 4

=item B<-reference>

Path to mapping tar.gz reference files

=item B<-annot>

Path to VAGrENT*.tar.gz

=item B<-snv_indel>

Path to Path to SNV_INDEL*.tar.gz

=item B<-tumour>

Path to tumour BAM or CRAM file with co-located index and BAS file.

=item B<-normal>

Path to normal BAM or CRAM file with co-located index and BAS file.

=back

=cut

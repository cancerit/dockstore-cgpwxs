# Expected results

<!-- TOC depthFrom:2 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Structure](#structure)
	- [Files of 1 byte](#files-of-1-byte)
- [How to verify results](#how-to-verify-results)
	- [cgpwxs](#cgpwxs)
- [Why not a tar.gz file?](#why-not-a-targz-file)

<!-- /TOC -->

## Structure

This area reflects the structure of the examples tree.

Where a `*.json` file resides in examples you will find a corresponding folder here containing the
unpacked result for executing the relevant workflow with that json example.

e.g.

`examples/cgpwxs/bam_bai.json` generates `result_WXS_bam_bai.tar.gz`, the content of which can be compared to `expected/cgpwxs/bam_bai`.

### Files of 1 byte

We include all files in this area but those that are not considered useful for verification
purposes have been truncated to a size of 1 (newline char only).

## How to verify results

### cgpwxs

The primary files to compare are:

1. `/COLO-829_vs_COLO-829-BL/caveman/COLO-829_vs_COLO-829-BL.annot.muts.vcf.gz`
  * Annotated substitutions, `muts.ids.vcf.gz` and `flagged.muts.vcf.gz` are precursors, data only being added.
1. `/COLO-829_vs_COLO-829-BL/pindel/COLO-829_vs_COLO-829-BL.annot.vcf.gz`
  * Annotated indels, `flagged.vcf.gz` is a precursor, data only being added.

To compare files you need to strip the ID column as it is populated with UUIDs.

<!-- indent (1 space) comments to prevent corruption of TOC -->

```
$ export DS_CGPWXS_TAG=X.X.X
$ export TOOL=cgpwxs
$ export EXJS=bam_bai
 # the following can be looped for different vcf/algs
$ export ALG=caveman
$ export VCF=COLO-829_vs_COLO-829-BL.annot.muts.vcf.gz
$ export ALG_VCF=COLO-829_vs_COLO-829-BL/$ALG/$VCF
$ export YOUR_UNPACKED=.../$ALG_VCF
$ wget https://raw.githubusercontent.com/cancerit/dockstore-cgpwxs/$DS_CGPWXS_TAG/expected/$TOOL/$EXJS/$ALG_VCF
$ zgrep -v '##contig' $VCF | cut --complement -f 3 > expected_${EXJS}_${ALG}.noid
$ zgrep -v '##contig' $YOUR_UNPACKED | cut --complement -f 3 > mine_${EXJS}_${ALG}.noid
$ diff -y --suppress-common-lines expected_${EXJS}.noid mine_${EXJS}.noid
 ##vcfProcessLog=<InputVCF=<.>,InputVCFSource=<CaVEMan>,InputV |	##vcfProcessLog=<InputVCF=<.>,InputVCFSource=<CaVEMan>,InputV
 ##vcfProcessLog_20180307.1=<InputVCF=<COLO-829_vs_COLO-829-BL |	##vcfProcessLog_20180307.1=<InputVCF=<COLO-829_vs_COLO-829-BL
 ##vcfProcessLog_20180307.2=<InputVCF=<>,InputVCFSource=<Annot |	##vcfProcessLog_20180307.2=<InputVCF=<>,InputVCFSource=<Annot
```

You expect to see some diferences in the `##vcfProcessLog` lines due to dates and paths being different.

## Why not a tar.gz file?

1. It's easier to see what files should be found in the result archive.
1. We truncate many of the files that don't aid in verification.

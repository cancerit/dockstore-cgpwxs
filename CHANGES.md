# CHANGES

## 3.1.4

* Update VAGrENT to v3.3.4 specifically to fix https://github.com/cancerit/VAGrENT/issues/33

## 3.1.3

* Update base image to dockstore-cgpmap:3.1.4

## 3.1.2

* Add security updates to image build
* Update base image to dockstore-cgpmap:3.1.2
* Update caveman related versions to pick up hotfix to protect against corrupt index files
  * CaVEMan 1.13.15
  * cgpCaVEManWrapper 1.13.13 (just to keep in sync)

## 3.1.1

* Update to dockstore-cgpmap:3.1.1 for base image
* Bump vcftools to 0.1.16 - security
* Allow jobs to resume when process scripts exist, long since proven double run doesn't occur
* Ensure that ENA server is never used for CRAM processing
* New versio of cgpCaVEManPostProcessing to solve memory problems in flagging when using BED files, also bumps vcftools

## 3.1.0

* Update to dockstore-cgpmap:3.1.0 for base image
* Update dependencies to support fragment based read counts (and other fixes):
  * cancerit/cgpPindel - v3.1.2
  * cancerit/cgpCaVEManPostProcessing - 1.8.6
  * cancerit/cgpCaVEManWrapper - 1.13.12
  * cancerit/CaVEMan - 1.13.14
  * cancerit/VAGrENT - v3.3.3
* Drop `expected` tree, will be revising how verification of container is achieved.

## 3.0.3

Bumps dockstore-cgpmap to include new version of dockstore-cgpbigwig for GRCh38
support on generation of bigwig files.

## 3.0.2

Bumps versions of dependencies to bring in

* Official release of Bio-DB_HTS
* Alternate use of tabix query to allow contigs with names containing colon.

## 3.0.1

Updates to relating to:

* PCAP-core
  * Add threaded processing to `bam_stats` to reduce overall runtime.
* CaVEMan
  * Fix bug in error handling and exit codes.

## 3.0.0

* See dockstore-cgpmap v3.0.0 (primarily adds mismatchQc)
* CaVEMan and cgpPindel updated to use fragment based counting.
  * You will need to update the reference pack to include the new flagging rules, see example `json`
  files
* VAGrENT update to v3.3.0, only affects generation of annotation cache not use of existing ones.
* Using build stages to shrink images.
* remove legacy PRE/POST-EXEC from cgpbox days, use dockstore if you want file provisioning.

## 2.1.0

* Fixes various sort order issues in CaVEMan, cgpPindel and VAGrENT affecting
comparison of results from same inputs.

## 2.0.7

* Bumps cgpPindel to [v2.2.3](https://github.com/cancerit/cgpPindel/releases/tag/v2.2.3) to fix bug in DI event collation.

## 2.0.6

* Update base image to dockstore-cgpmap:2.0.3 (new PCAP-core for load management)
* Bump cgpCaVEManWrapper to gain access to split size tuning (not used here)

## 2.0.5

Very minor modifications to reduce potential issues from CPU oversubscription.

## 2.0.4

Large reduction in temp space and I/O for cgpPindel.  See [cgpPindel-v2.2.0](https://github.com/cancerit/cgpPindel/releases/tag/v2.2.0)

## 2.0.3

* Fixed cgpPindel

## 2.0.2

* Update cgpPindel to reduce usage of Capture::Tiny apparent cause of some failures.

## 2.0.1

* Test data in `examples/analysis_config.local.json` moved to a non-expiring location.

## 2.0.0

* See [dockstore-cgpmap:2.0.0](https://github.com/cancerit/dockstore-cgpmap/releases/tag/2.0.0)
* Streamlined install process to reduce build time and size of image.
* Fix to SNV flagging - was not being applied previously.

## 1.0.4

* Updates base image to add load management facilities via ENV variables.

## 1.0.3

* Add params file to output bindings

## 1.0.2

* Fix up output files slightly
* Update base image for dependency (PCAP-core etc)

## 1.0.1

* Fixes handling of species/assembly
* Update base image (PCAP-core etc)

## 1.0.0

Initial release of flow

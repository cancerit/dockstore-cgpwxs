# CHANGES

## NEXT

* See dockstore-cgpmap v3.0.0 (primarily adds mismatchQc)
* CaVEMan and cgpPindel updated to use fragment based counting.
  * You will need to update the reference pack to include the new flagging rules, see example `json`
  files
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

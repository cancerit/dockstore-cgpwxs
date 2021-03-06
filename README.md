# dockstore-cgpwxs

`dockstore-cgpwxs` provides a complete multi threaded WXS analysis for SNV and INDEL variants with
associated annotation of VCF files.  This has been packaged specifically for use with the
[Dockstore.org](https://dockstore.org/) framework.

[![Gitter Badge][gitter-svg]][gitter-badge]

[![Quay Badge][quay-status]][quay-repo]

| Master                                        | Develop                                         |
| --------------------------------------------- | ----------------------------------------------- |
| [![Master Badge][travis-master]][travis-base] | [![Develop Badge][travis-develop]][travis-base] |

<!-- TOC depthFrom:2 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

* [Supported input formats](#supported-input-formats)
* [Usable Cores](#usable-cores)
* [Other uses](#other-uses)
  * [Native docker](#native-docker)
  * [Singularity](#singularity)
* [Verifying your deployment](#verifying-your-deployment)
* [Development environment](#development-environment)
* [Release process](#release-process)
* [LICENCE](#licence)

<!-- /TOC -->

## Supported input formats

Required input files are

Note: cram and csi/crai will not work via Dockstore/CWL yet but direct exec of `scripts/ds-cgpwxs.pl`
will allow use of these.

1. Tumour BAM/CRAM file (plus bai/csi/crai + bas)
1. Normal BAM/CRAM file (plus bai/csi/crai + bas)
1. Core reference archive (e.g. [core_ref_GRCh37d5.tar.gz][ftp-ref])
1. WXS reference archive (e.g. [SNV_INDEL_ref_GRCh37d5.tar.gz][ftp-ref])
1. VAGrENT (annotation) reference archive (e.g. [VAGrENT_ref_GRCh37d5_ensembl_75.tar.gz][ftp-ref])

Inputs 1&2 are expected to have been mapped using [dockstore-cgpmap][dockstore-cgpmap]

The data linked in the 'examples' area is a tiny section of chr21 from the cell line COLO-829.  This
will generate a small number of INDEL and SNV variants. All the SNV variants do not pass filtering
(several only fail as not in a gene footprint, 'F009').

Please check the Wiki then raise an issue if you require additional information on how to generate
your own reference files.  Much of this information is available on the individual algorithm pages.

* [cgpCaVEManWrapper][caveman-wiki]
* [cgpPindel][cgppindel-wiki]
* [VAGrENT][vagrent-wiki]

## Usable Cores

When running outside of a docker container you can set the number of CPUs via:

* `export CPU=N`
* `-cores|-c` option of `ds-cgpwxs.pl`

If not set detects available cores on system.

## Other uses

### Native docker

All of the tools installed as part of [dockstore-cgpmap][dockstore-cgpmap] and the above packages
are available for direct use.

```
export CGPWXS_VER=X.X.X
docker pull quay.io/wtsicgp/dockstore-cgpwxs:$CGPWXS_VER
docker --rm -ti [--volume ...] quay.io/wtsicgp/dockstore-cgpwxs:$CGPWXS_VER bash
```

### Singularity

The resulting docker container has been tested with Singularity.  The command to exec is:

```
ds-cgpwxs.pl -h
```

Expected use would be along the lines of:

```
export CGPWXS_VER=X.X.X
singularity pull docker://quay.io/wtsicgp/dockstore-cgpwxs:$CGPWXS_VER

singularity exec\
 --workdir /.../workspace  \
 --home /.../workspace:/home  \
 --bind /.../ref/human:/var/spool/ref:ro  \
 --bind /.../example_data/cgpwxs:/var/spool/data:ro  \
 dockstore-cgpwxs-${CGPWXS_VER}.simg  \
  ds-cgpwxs.pl \
   -reference /var/spool/ref/core_ref_GRCh37d5.tar.gz \
   -annot /var/spool/ref/VAGrENT_ref_GRCh37d5_ensembl_75.tar.gz \
   -snv_indel /var/spool/ref/SNV_INDEL_ref_GRCh37d5-fragment.tar.gz \
   -tumour /var/spool/data/COLO-829_ex.cram \
   -tidx /var/spool/data/COLO-829_ex.cram.crai \
   -normal /var/spool/data/COLO-829-BL_ex.cram \
   -nidx /var/spool/data/COLO-829-BL_ex.cram.crai \
   -exclude NC_007605,hs37d5,GL%
```

For a system automatically attaching _all local mount points_ (not default singularity behaviour)
you need not specify any `exec` params (workdir, home, bind) but you should specify the `-outdir`
option for `ds-cgpwxs.pl` to prevent data being written to your home directory.

By default results are written to the home directory of the container so ensure you bind
a large volume and set the `-home` variable.  As indicated above the location can be overridden
via the options of `ds-cgpwxs.pl`

## Verifying your deployment

The `examples/` tree contains test json files populated with data that can be used to verify the
tool.  More details can be found [here](examples/README.md).

## Development environment

This project uses git pre-commit hooks.  Please enable them to prevent inappropriate large files
being included.  Any pull request found not to have adhered to this will be rejected and the branch
will need to be manually cleaned to keep the repo size down.

Activate the hooks with

```
git config core.hooksPath git-hooks
```

## Release process

This project is maintained using HubFlow.

1. Make appropriate changes
2. Build image locally
3. Run all example inputs and verify any changes are acceptable
4. Update `expected/` tree with output of last step
5. Bump version in `Dockerfile` and `Dockstore.cwl`
6. Push changes
7. Check state on Travis
8. Generate the release (add notes to GitHub)
9. Confirm that image has been built on [quay.io][quay-builds]
10. Update the [dockstore][dockstore-cgpwgs] entry, see [their docs][dockstore-get-started].

## LICENCE

```
Copyright (c) 2016-2018 Genome Research Ltd.

Author: CASM/Cancer IT <cgphelp@sanger.ac.uk>

This file is part of dockstore-cgpwxs.

dockstore-cgpwxs is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation; either version 3 of the License, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.

1. The usage of a range of years within a copyright statement contained within
this distribution should be interpreted as being equivalent to a list of years
including the first and last year specified and all consecutive years between
them. For example, a copyright statement that reads ‘Copyright (c) 2005, 2007-
2009, 2011-2012’ should be interpreted as being identical to a statement that
reads ‘Copyright (c) 2005, 2007, 2008, 2009, 2011, 2012’ and a copyright
statement that reads ‘Copyright (c) 2005-2012’ should be interpreted as being
identical to a statement that reads ‘Copyright (c) 2005, 2006, 2007, 2008,
2009, 2010, 2011, 2012’."
```

<!-- links -->
[ftp-ref]: ftp://ftp.sanger.ac.uk/pub/cancer/dockstore/human
[ftp-exp]: ftp://ftp.sanger.ac.uk/pub/cancer/dockstore/expected
[cgppindel-wiki]: https://github.com/cancerit/cgpPindel/wiki
[caveman-wiki]: https://github.com/cancerit/cgpCaVEManWrapper/wiki
[vagrent-wiki]: https://github.com/cancerit/VAGrENT/wiki

<!-- Travis -->
[travis-base]: https://travis-ci.org/cancerit/dockstore-cgpwxs
[travis-master]: https://travis-ci.org/cancerit/dockstore-cgpwxs.svg?branch=master
[travis-develop]: https://travis-ci.org/cancerit/dockstore-cgpwxs.svg?branch=develop

<!-- Gitter -->
[gitter-svg]: https://badges.gitter.im/dockstore-cgp/Lobby.svg
[gitter-badge]: https://gitter.im/dockstore-cgp/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge

<!-- Quay.io -->
[quay-status]: https://quay.io/repository/wtsicgp/dockstore-cgpwxs/status
[quay-repo]: https://quay.io/repository/wtsicgp/dockstore-cgpwxs
[quay-builds]: https://quay.io/repository/wtsicgp/dockstore-cgpwxs?tab=builds

<!-- dockstore -->
[dockstore-cgpwxs]: https://dockstore.org/containers/quay.io/wtsicgp/dockstore-cgpwxs
[dockstore-cgpmap]: https://dockstore.org/containers/quay.io/wtsicgp/dockstore-cgpwxs
[dockstore-get-started]: https://dockstore.org/docs/getting-started-with-dockstore

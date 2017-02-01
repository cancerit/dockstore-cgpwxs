#!/bin/bash

set -xe

if [[ -z "${TMPDIR}" ]]; then
  TMPDIR=/tmp
fi

set -u

mkdir -p $TMPDIR/downloads

cd $TMPDIR/downloads

# cgpVcf
curl -sSL -o distro.zip --retry 10 https://github.com/cancerit/cgpVcf/archive/v2.1.1.zip
mkdir $TMPDIR/downloads/distro
bsdtar -C $TMPDIR/downloads/distro --strip-components 1 -xf distro.zip
cd $TMPDIR/downloads/distro
./setup.sh $OPT
cd $TMPDIR/downloads
rm -rf distro.zip $TMPDIR/downloads/distro /tmp/hts_cache

# cgpPindel
curl -sSL -o distro.zip --retry 10 https://github.com/cancerit/cgpPindel/archive/v2.1.0.zip
mkdir $TMPDIR/downloads/distro
bsdtar -C $TMPDIR/downloads/distro --strip-components 1 -xf distro.zip
cd $TMPDIR/downloads/distro
./setup.sh $OPT
cd $TMPDIR/downloads
rm -rf distro.zip $TMPDIR/downloads/distro /tmp/hts_cache

# cgpCaVEManPostProcessing
curl -sSL -o distro.zip --retry 10 https://github.com/cancerit/cgpCaVEManPostProcessing/archive/1.6.6.zip
mkdir $TMPDIR/downloads/distro
bsdtar -C $TMPDIR/downloads/distro --strip-components 1 -xf distro.zip
cd $TMPDIR/downloads/distro
./setup.sh $OPT
cd $TMPDIR/downloads
rm -rf distro.zip $TMPDIR/downloads/distro /tmp/hts_cache

# cgpCaVEManWrapper
curl -sSL -o distro.zip --retry 10 https://github.com/cancerit/cgpCaVEManWrapper/archive/1.10.3.zip
mkdir $TMPDIR/downloads/distro
bsdtar -C $TMPDIR/downloads/distro --strip-components 1 -xf distro.zip
cd $TMPDIR/downloads/distro
./setup.sh $OPT
cd $TMPDIR/downloads
rm -rf distro.zip $TMPDIR/downloads/distro /tmp/hts_cache

# VAGrENT
curl -sSL -o distro.zip --retry 10 https://github.com/cancerit/VAGrENT/archive/v3.2.1.zip
mkdir $TMPDIR/downloads/distro
bsdtar -C $TMPDIR/downloads/distro --strip-components 1 -xf distro.zip
cd $TMPDIR/downloads/distro
./setup.sh $OPT
cd $TMPDIR/downloads
rm -rf distro.zip $TMPDIR/downloads/distro /tmp/hts_cache

rm -rf $TMPDIR/downloads

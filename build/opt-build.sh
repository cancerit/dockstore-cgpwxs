#!/bin/bash

set -uxe

mkdir -p /tmp/downloads

cd /tmp/downloads

# cgpVcf
curl -sSL -o distro.zip --retry 10 https://github.com/cancerit/cgpVcf/archive/v2.1.1.zip
mkdir /tmp/downloads/distro
bsdtar -C /tmp/downloads/distro --strip-components 1 -xf distro.zip
cd /tmp/downloads/distro
./setup.sh $OPT
cd /tmp/downloads
rm -rf distro.zip /tmp/downloads/distro /tmp/hts_cache

# cgpPindel
curl -sSL -o distro.zip --retry 10 https://github.com/cancerit/cgpPindel/archive/v2.0.10.zip
mkdir /tmp/downloads/distro
bsdtar -C /tmp/downloads/distro --strip-components 1 -xf distro.zip
cd /tmp/downloads/distro
./setup.sh $OPT
cd /tmp/downloads
rm -rf distro.zip /tmp/downloads/distro /tmp/hts_cache

# cgpCaVEManPostProcessing
curl -sSL -o distro.zip --retry 10 https://github.com/cancerit/cgpCaVEManPostProcessing/archive/1.6.6.zip
mkdir /tmp/downloads/distro
bsdtar -C /tmp/downloads/distro --strip-components 1 -xf distro.zip
cd /tmp/downloads/distro
./setup.sh $OPT
cd /tmp/downloads
rm -rf distro.zip /tmp/downloads/distro /tmp/hts_cache

# cgpCaVEManWrapper
curl -sSL -o distro.zip --retry 10 https://github.com/cancerit/cgpCaVEManWrapper/archive/1.10.1.zip
mkdir /tmp/downloads/distro
bsdtar -C /tmp/downloads/distro --strip-components 1 -xf distro.zip
cd /tmp/downloads/distro
./setup.sh $OPT
cd /tmp/downloads
rm -rf distro.zip /tmp/downloads/distro /tmp/hts_cache

# VAGrENT
curl -sSL -o distro.zip --retry 10 https://github.com/cancerit/VAGrENT/archive/v3.2.0.zip
mkdir /tmp/downloads/distro
bsdtar -C /tmp/downloads/distro --strip-components 1 -xf distro.zip
cd /tmp/downloads/distro
./setup.sh $OPT
cd /tmp/downloads
rm -rf distro.zip /tmp/downloads/distro /tmp/hts_cache

rm -rf /tmp/downloads

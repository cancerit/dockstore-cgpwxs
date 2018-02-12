#!/bin/bash

set -xe

if [[ -z "${TMPDIR}" ]]; then
  TMPDIR=/tmp
fi

set -u

# cgpVcf
VER_CGPVCF="v2.2.1"
VER_VCFTOOLS="0.1.15"

# cgpPindel
VER_CGPPINDEL="feature/readsVsFragments"

# cgpCaVEManPostProcessing
VER_CGPCAVEPOSTPROC="feature/overlapping_reads"
# if issues found downgrade to 2.23.0 but can't find any use of bedtools coverage
VER_BEDTOOLS="2.27.1"

# cgpCaVEManWrapper
VER_CGPCAVEWRAP="feature/overlapping_reads"
VER_CAVEMAN="1.13.0-rc1"

# VAGrENT
VER_VAGRENT="v3.2.3"

if [ "$#" -lt "1" ] ; then
  echo "Please provide an installation path such as /opt/ICGC"
  exit 1
fi


# get path to this script
SCRIPT_PATH=`dirname $0`;
SCRIPT_PATH=`(cd $SCRIPT_PATH && pwd)`

# get the location to install to
INST_PATH=$1
mkdir -p $1
INST_PATH=`(cd $1 && pwd)`
echo $INST_PATH

# get current directory
INIT_DIR=`pwd`

CPU=`grep -c ^processor /proc/cpuinfo`
if [ $? -eq 0 ]; then
  if [ "$CPU" -gt "6" ]; then
    CPU=6
  fi
else
  CPU=1
fi
echo "Max compilation CPUs set to $CPU"


SETUP_DIR=$INIT_DIR/install_tmp
mkdir -p $SETUP_DIR/distro # don't delete the actual distro directory until the very end
mkdir -p $INST_PATH/bin
cd $SETUP_DIR

# make sure tools installed can see the install loc of libraries
set +u
export LD_LIBRARY_PATH=`echo $INST_PATH/lib:$LD_LIBRARY_PATH | perl -pe 's/:\$//;'`
export PATH=`echo $INST_PATH/bin:$PATH | perl -pe 's/:\$//;'`
export MANPATH=`echo $INST_PATH/man:$INST_PATH/share/man:$MANPATH | perl -pe 's/:\$//;'`
export PERL5LIB=`echo $INST_PATH/lib/perl5:$PERL5LIB | perl -pe 's/:\$//;'`
set -u

## vcftools
if [ ! -e $SETUP_DIR/vcftools.success ]; then
  curl -sSL --retry 10 https://github.com/vcftools/vcftools/releases/download/v${VER_VCFTOOLS}/vcftools-${VER_VCFTOOLS}.tar.gz > distro.tar.gz
  rm -rf distro/*
  tar --strip-components 2 -C distro -xzf distro.tar.gz
  cd distro
  ./configure --prefix=$INST_PATH --with-pmdir=lib/perl5
  make -j$CPU
  make install
  cd $SETUP_DIR
  rm -rf distro.* distro/*
  touch $SETUP_DIR/vcftools.success
fi

### cgpVcf
if [ ! -e $SETUP_DIR/cgpVcf.success ]; then
  curl -sSL --retry 10 https://github.com/cancerit/cgpVcf/archive/${VER_CGPVCF}.tar.gz > distro.tar.gz
  rm -rf distro/*
  tar --strip-components 1 -C distro -xzf distro.tar.gz
  cd distro
  cpanm --no-interactive --notest --mirror http://cpan.metacpan.org --notest -l $INST_PATH --installdeps .
  cpanm -v --no-interactive --mirror http://cpan.metacpan.org -l $INST_PATH .
  cd $SETUP_DIR
  rm -rf distro.* distro/*
  touch $SETUP_DIR/cgpVcf.success
fi

### cgpPindel
if [ ! -e $SETUP_DIR/cgpPindel.success ]; then
  curl -sSL --retry 10 https://github.com/cancerit/cgpPindel/archive/${VER_CGPPINDEL}.tar.gz > distro.tar.gz
  rm -rf distro/*
  tar --strip-components 1 -C distro -xzf distro.tar.gz
  cd distro
  if [ ! -e $SETUP_DIR/cgpPindel_c.success ]; then
    g++ -O3 -o $INST_PATH/bin/pindel c++/pindel.cpp
    g++ -O3 -o $INST_PATH/bin/filter_pindel_reads c++/filter_pindel_reads.cpp
    touch $SETUP_DIR/cgpPindel_c.success
  fi
  cd perl
  cpanm --no-interactive --notest --mirror http://cpan.metacpan.org --notest -l $INST_PATH --installdeps .
  cpanm -v --no-interactive --mirror http://cpan.metacpan.org -l $INST_PATH .
  cd $SETUP_DIR
  rm -rf distro.* distro/*
  touch $SETUP_DIR/cgpPindel.success
fi

### bedtools for cgpCaVEManPostProcessing
if [ ! -e $SETUP_DIR/bedtools.success ]; then
  curl -sSL --retry 10 https://github.com/arq5x/bedtools2/releases/download/v${VER_BEDTOOLS}/bedtools-${VER_BEDTOOLS}.tar.gz > distro.tar.gz
  rm -rf distro/*
  tar --strip-components 1 -C distro -xzf distro.tar.gz
  make -C distro -j$CPU
  cp distro/bin/* $INST_PATH/bin/.
  cd $SETUP_DIR
  rm -rf distro.* distro/*
  touch $SETUP_DIR/bedtools.success
fi

### cgpCaVEManPostProcessing
if [ ! -e $SETUP_DIR/cgpCaVEManPostProcessing.success ]; then
  cpanm --no-interactive --notest --mirror http://cpan.metacpan.org --notest -l $INST_PATH File::ShareDir::Install
  curl -sSL --retry 10 https://github.com/cancerit/cgpCaVEManPostProcessing/archive/${VER_CGPCAVEPOSTPROC}.tar.gz > distro.tar.gz
  rm -rf distro/*
  tar --strip-components 1 -C distro -xzf distro.tar.gz
  cd distro
  cpanm --no-interactive --notest --mirror http://cpan.metacpan.org --notest -l $INST_PATH --installdeps .
  cpanm -v --no-interactive --mirror http://cpan.metacpan.org -l $INST_PATH .
  cd $SETUP_DIR
  rm -rf distro.* distro/*
  touch $SETUP_DIR/cgpCaVEManPostProcessing.success
fi

### CaVEMan for cgpCaVEManWrapper
if [ ! -e $SETUP_DIR/CaVEMan.success ]; then
  curl -sSL --retry 10 https://github.com/cancerit/CaVEMan/archive/${VER_CAVEMAN}.tar.gz > distro.tar.gz
  rm -rf distro/*
  tar --strip-components 1 -C distro -xzf distro.tar.gz
  cd distro
  mkdir -p c/bin

  make clean
  make -j$CPU prefix=$INST_PATH
  cp bin/caveman $INST_PATH/bin/.
  cp bin/mergeCavemanResults $INST_PATH/bin/.
  cd $SETUP_DIR
  rm -rf distro.* distro/*
  touch $SETUP_DIR/CaVEMan.success
fi

### cgpCaVEManWrapper
if [ ! -e $SETUP_DIR/cgpCaVEManWrapper.success ]; then
  curl -sSL --retry 10 https://github.com/cancerit/cgpCaVEManWrapper/archive/${VER_CGPCAVEWRAP}.tar.gz > distro.tar.gz
  rm -rf distro/*
  tar --strip-components 1 -C distro -xzf distro.tar.gz
  cd distro
  cpanm --no-interactive --notest --mirror http://cpan.metacpan.org --notest -l $INST_PATH --installdeps .
  cpanm -v --no-interactive --mirror http://cpan.metacpan.org -l $INST_PATH .
  cd $SETUP_DIR
  rm -rf distro.* distro/*
  touch $SETUP_DIR/cgpCaVEManWrapper.success
fi

### VAGrENT
if [ ! -e $SETUP_DIR/VAGrENT.success ]; then
  curl -sSL --retry 10 https://github.com/cancerit/VAGrENT/archive/${VER_VAGRENT}.tar.gz > distro.tar.gz
  rm -rf distro/*
  tar --strip-components 1 -C distro -xzf distro.tar.gz
  cd distro
  cpanm --no-interactive --notest --mirror http://cpan.metacpan.org --notest -l $INST_PATH --installdeps .
  cpanm -v --no-interactive --mirror http://cpan.metacpan.org -l $INST_PATH .
  cd $SETUP_DIR
  rm -rf distro.* distro/*
  touch $SETUP_DIR/VAGrENT.success
fi

cd $HOME
rm -rf $SETUP_DIR

set +x

echo "
################################################################

  To use the non-central tools you need to set the following
    export LD_LIBRARY_PATH=$INST_PATH/lib:\$LD_LIBRARY_PATH
    export PATH=$INST_PATH/bin:\$PATH
    export MANPATH=$INST_PATH/man:$INST_PATH/share/man:\$MANPATH
    export PERL5LIB=$INST_PATH/lib/perl5:\$PERL5LIB

################################################################
"

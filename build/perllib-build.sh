#!/bin/bash

set -eux

apt-get -yq update
# install all perl libs, identify by grep of build "grep 'Successfully installed' build.log"
# much faster, items needing later versions will still upgrade
# still install those that get an upgrade though as dependancies will be resolved

apt-get -yq install libdist-checkconflicts-perl
apt-get -yq install libeval-closure-perl
apt-get -yq install libclass-singleton-perl
apt-get -yq install libscalar-list-utils-perl
apt-get -yq install libdatetime-locale-perl
apt-get -yq install libdatetime-perl
apt-get -yq install liblog-log4perl-perl
apt-get -yq install libfile-type-perl
apt-get -yq install libsort-key-perl

FROM  quay.io/wtsicgp/dockstore-cgpmap:3.0.0 as builder

USER  root

RUN apt-get -yq update
RUN apt-get install -yq --no-install-recommends\
  locales\
  g++\
  make\
  gcc\
  pkg-config\
  zlib1g-dev\
  python

# python only for building bedtools, not needed to use

RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

ENV OPT /opt/wtsi-cgp
ENV PATH $OPT/bin:$OPT/biobambam2/bin:$PATH
ENV PERL5LIB $OPT/lib/perl5
ENV LD_LIBRARY_PATH $OPT/lib
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

ADD build/opt-build.sh build/
RUN bash build/opt-build.sh $OPT

FROM  ubuntu:16.04

MAINTAINER  keiranmraine@gmail.com

LABEL vendor="Cancer Genome Project, Wellcome Trust Sanger Institute"
LABEL uk.ac.sanger.cgp.description="CGP WXS pipeline for dockstore.org"
LABEL uk.ac.sanger.cgp.version="3.0.0-rc1"

RUN apt-get -yq update
RUN apt-get install -yq --no-install-recommends\
  apt-transport-https\
  locales\
  curl\
  ca-certificates\
  libperlio-gzip-perl\
  bzip2\
  psmisc\
  time\
  zlib1g\
  liblzma5\
  libncurses5\
  p11-kit

RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

ENV OPT /opt/wtsi-cgp
ENV PATH $OPT/bin:$OPT/biobambam2/bin:$PATH
ENV PERL5LIB $OPT/lib/perl5
ENV LD_LIBRARY_PATH $OPT/lib
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

RUN mkdir -p $OPT
COPY --from=builder $OPT $OPT

ADD scripts/analysisWXS.sh $OPT/bin/analysisWXS.sh
ADD scripts/ds-cgpwxs.pl $OPT/bin/ds-cgpwxs.pl
RUN chmod a+x $OPT/bin/analysisWXS.sh $OPT/bin/ds-cgpwxs.pl

## USER CONFIGURATION
RUN adduser --disabled-password --gecos '' ubuntu && chsh -s /bin/bash && mkdir -p /home/ubuntu

USER    ubuntu
WORKDIR /home/ubuntu

CMD ["/bin/bash"]

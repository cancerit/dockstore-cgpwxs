FROM  quay.io/wtsicgp/dockstore-cgpmap:3.0.0-rc5 as builder

USER  root

ENV OPT /opt/wtsi-cgp
ENV PATH $OPT/bin:$PATH
ENV PERL5LIB $OPT/lib/perl5
ENV LD_LIBRARY_PATH $OPT/lib
ENV LC_ALL C

RUN apt-get -yq update
RUN apt-get install -yq --no-install-recommends\
  g++\
  make\
  gcc\
  pkg-config\
  zlib1g-dev\
  python

# python only for building bedtools, not needed to use

ADD build/opt-build.sh build/
RUN bash build/opt-build.sh $OPT

ADD scripts/analysisWXS.sh $OPT/bin/analysisWXS.sh
ADD scripts/ds-cgpwxs.pl $OPT/bin/ds-cgpwxs.pl
RUN chmod a+x $OPT/bin/analysisWXS.sh $OPT/bin/ds-cgpwxs.pl


FROM  ubuntu:16.04

MAINTAINER  keiranmraine@gmail.com

LABEL uk.ac.sanger.cgp="Cancer Genome Project, Wellcome Trust Sanger Institute" \
      version="3.0.0-rc1" \
      description="The CGP WXS pipeline for dockstore.org"

ENV OPT /opt/wtsi-cgp
ENV PATH $OPT/bin:$PATH
ENV PERL5LIB $OPT/lib/perl5
ENV LD_LIBRARY_PATH $OPT/lib
ENV LC_ALL C

RUN apt-get -yq update
RUN apt-get install -yq --no-install-recommends\
  apt-transport-https\
  curl\
  ca-certificates\
  libperlio-gzip-perl\
  bzip2\
  psmisc\
  time\
  zlib1g\
  liblzma5\
  libncurses5

RUN mkdir -p $OPT
COPY --from=builder $OPT $OPT

## USER CONFIGURATION
RUN adduser --disabled-password --gecos '' ubuntu && chsh -s /bin/bash && mkdir -p /home/ubuntu

USER    ubuntu
WORKDIR /home/ubuntu

CMD ["/bin/bash"]

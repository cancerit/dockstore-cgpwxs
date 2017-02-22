FROM  quay.io/wtsicgp/dockstore-cgpmap:2.0.0

MAINTAINER  keiranmraine@gmail.com

LABEL uk.ac.sanger.cgp="Cancer Genome Project, Wellcome Trust Sanger Institute" \
      version="2.0.0" \
      description="The CGP WXS pipeline for dockstore.org"

USER  root

ENV OPT /opt/wtsi-cgp
ENV PATH $OPT/bin:$PATH
ENV PERL5LIB $OPT/lib/perl5
ENV LD_LIBRARY_PATH $OPT/lib

ADD build/apt-build.sh build/
RUN bash build/apt-build.sh

ADD build/perllib-build.sh build/
RUN bash build/perllib-build.sh

ADD build/opt-build.sh build/
RUN bash build/opt-build.sh $OPT

ADD scripts/analysisWXS.sh $OPT/bin/analysisWXS.sh
ADD scripts/ds-wrapper.pl $OPT/bin/ds-wrapper.pl
RUN chmod a+x $OPT/bin/analysisWXS.sh $OPT/bin/ds-wrapper.pl

USER    ubuntu
WORKDIR /home/ubuntu

CMD ["/bin/bash"]

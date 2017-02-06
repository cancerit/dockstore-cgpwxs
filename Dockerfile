FROM  quay.io/wtsicgp/dockstore-cgpmap:1.0.8

MAINTAINER  keiranmraine@gmail.com

LABEL uk.ac.sanger.cgp="Cancer Genome Project, Wellcome Trust Sanger Institute" \
      version="1.0.4" \
      description="The CGP WXS pipeline for dockstore.org"

USER  root

ENV OPT /opt/wtsi-cgp
ENV PATH $OPT/bin:$PATH
ENV PERL5LIB $OPT/lib/perl5

ADD build/apt-build.sh build/
RUN bash build/apt-build.sh

ADD build/perllib-build.sh build/
RUN bash build/perllib-build.sh

ADD build/opt-build.sh build/
RUN bash build/opt-build.sh

ADD scripts/analysisWXS.sh $OPT/bin/analysisWXS.sh
ADD scripts/ds-wrapper.pl $OPT/bin/ds-wrapper.pl
RUN chmod a+x $OPT/bin/analysisWXS.sh $OPT/bin/ds-wrapper.pl

USER    ubuntu
WORKDIR /home/ubuntu

CMD ["/bin/bash"]

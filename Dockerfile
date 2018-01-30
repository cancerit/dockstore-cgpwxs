FROM  quay.io/wtsicgp/dockstore-cgpmap:3.0.0-rc1 as builder

USER  root

ADD build/opt-build.sh build/
RUN bash build/opt-build.sh $OPT

ADD scripts/analysisWXS.sh $OPT/bin/analysisWXS.sh
ADD scripts/ds-wrapper.pl $OPT/bin/ds-wrapper.pl
RUN chmod a+x $OPT/bin/analysisWXS.sh $OPT/bin/ds-wrapper.pl


FROM  quay.io/wtsicgp/dockstore-cgpmap:3.0.0-rc1

MAINTAINER  keiranmraine@gmail.com

LABEL uk.ac.sanger.cgp="Cancer Genome Project, Wellcome Trust Sanger Institute" \
      version="2.1.1" \
      description="The CGP WXS pipeline for dockstore.org"

USER    ubuntu
WORKDIR /home/ubuntu

CMD ["/bin/bash"]

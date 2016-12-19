FROM  quay.io/wtsicgp/dockstore-cgpmap:1.0.5

MAINTAINER  keiranmraine@gmail.com

LABEL uk.ac.sanger.cgp="Cancer Genome Project, Wellcome Trust Sanger Institute" \
      version="1.0.0" \
      description="The CGP WXS pipeline for dockstore.org"

USER  root

ENV OPT /opt/wtsi-cgp
ENV PATH $OPT/bin:$PATH
ENV PERL5LIB $OPT/lib/perl5

#ADD scripts/mapping.sh $OPT/bin/mapping.sh
#ADD scripts/ds-wrapper.pl $OPT/bin/ds-wrapper.pl
#RUN chmod a+x $OPT/bin/mapping.sh $OPT/bin/ds-wrapper.pl

ADD build/apt-build.sh build/
ADD build/perllib-build.sh build/
ADD build/opt-build.sh build/

RUN bash build/apt-build.sh
RUN bash build/perllib-build.sh
RUN bash build/opt-build.sh

USER    ubuntu
WORKDIR /home/ubuntu

CMD ["/bin/bash"]

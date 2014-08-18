######################################################
# Base image with all of Grappa's dependencies
######################################################
FROM ubuntu
MAINTAINER Grappa Team <grappa@cs.washington.edu>

ADD setup.sh /setup.sh
RUN bash /setup.sh && rm /setup.sh

ENV LD_LIBRARY_PATH           $LD_LIBRARY_PATH:/usr/local/lib
ENV CC                        /usr/bin/gcc
ENV CXX                       /usr/bin/g++
ENV GRAPPA_THIRD_PARTY        /grappa-third-party
ENV GRAPPA_ALLOW_RUN_AS_ROOT  1

# expose the source code directory for mounting in other containers (such as sharing with the host)
VOLUME /grappa

WORKDIR /grappa

ENTRYPOINT ["/bin/bash"]
CMD ["--login"]

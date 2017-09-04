# © Copyright IBM Corporation 2015, 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:16.04

LABEL maintainer "Sam Massey <smassey@uk.ibm.com>"

COPY *.deb /
COPY mqlicense.sh /
COPY lap /lap

RUN export DEBIAN_FRONTEND=noninteractive \
  # Install additional packages - do we need/want them all
  && apt-get update -y \
  && apt-get install -y --no-install-recommends \
    bash \
    bc \
    ca-certificates \
    coreutils \
    curl \
    debianutils \
    file \
    findutils \
    gawk \
    grep \
    libc-bin \
    lsb-release \
    mount \
    passwd \
    procps \
    sed \
    tar \
    util-linux \
  # Apply any bug fixes not included in base Ubuntu or MQ image.
  # Don't upgrade everything based on Docker best practices https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/#run
  && apt-get upgrade -y libkrb5-26-heimdal \
  && apt-get upgrade -y libexpat1 \
  # End of bug fixes
  && rm -rf /var/lib/apt/lists/* \
  # Optional: Update the command prompt with the MQ version
  && echo "cph" > /etc/debian_chroot \
  && sed -i 's/password\t\[success=1 default=ignore\]\tpam_unix\.so obscure sha512/password\t[success=1 default=ignore]\tpam_unix.so obscure sha512 minlen=8/' /etc/pam.d/common-password \
  && groupadd --gid 1000 mqm \
  && useradd mqperf -G mqm \
  && echo mqperf:orland02 | chpasswd \
  && mkdir -p /home/mqperf/cph \
  && chown -R mqperf /home/mqperf/cph \
  && echo "cd ~/cph" >> /home/mqperf/.bashrc

RUN export DEBIAN_FRONTEND=noninteractive \
  && ./mqlicense.sh -accept \
  && dpkg -i ibmmq-runtime_9.0.3.0_amd64.deb \
  && dpkg -i ibmmq-client_9.0.3.0_amd64.deb 


COPY cph/* /home/mqperf/cph/
COPY *.sh /home/mqperf/cph/
COPY *.mqsc /home/mqperf/cph/
USER mqperf
WORKDIR /home/mqperf/cph
#RUN chmod +x /usr/local/bin/*.sh

#ENTRYPOINT ["/bin/bash"]
ENTRYPOINT ["./cphTest.sh"]

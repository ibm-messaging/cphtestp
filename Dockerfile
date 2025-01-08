# © Copyright IBM Corporation 2015, 2019
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

# See Dockerfile.ubuntu for an image based on Ubuntu 22.04
FROM registry.access.redhat.com/ubi9/ubi:latest

LABEL maintainer "Sam Massey <smassey@uk.ibm.com>"

# Copy MQ install files
COPY *.rpm /
COPY mqlicense.sh /
COPY lap /lap

# Add centos Appstream repo and import keys
COPY centos.repo /etc/yum.repos.d
RUN rpm --import https://www.centos.org/keys/RPM-GPG-KEY-CentOS-Official-SHA256

# Add extra packages and setup user/group and shell config
RUN dnf install -y wget bc file procps procps iputils vim file procps vim sysstat pcp pcp-system-tools \
  && dnf update -y \
  && dnf clean all \
  && groupadd --system --gid 30000 mqm \
  && useradd --system --uid 900 --gid mqm mqm \
  && useradd --uid 30000 --gid mqm mqperf \
  && mkdir -p /home/mqperf/cph \
  # Update the command prompt with the container name, login and cwd
  && echo "export PS1='cphtestp:\u@\h:\w\$ '" >> /home/mqperf/.bashrc \
  && echo "cd ~/cph" >> /home/mqperf/.bashrc

# By running script, you accept the MQ client license, run ./mqlicense.sh -view to view license
ENV MQLICENSE=accept
RUN ./mqlicense.sh -accept \
  && rpm -Uvh MQSeriesRuntime-9.4.1-0.x86_64.rpm \
  && rpm -Uvh MQSeriesGSKit-9.4.1-0.x86_64.rpm \
  && rpm -Uvh MQSeriesClient-9.4.1-0.x86_64.rpm

# Copy files for QM config and scripts
USER mqperf
COPY ssl/* /opt/mqm/ssl/
COPY cph/* /home/mqperf/cph/
COPY *.sh /home/mqperf/cph/
COPY *.mqsc /home/mqperf/cph/
COPY qmmonitor2 /home/mqperf/cph/

# Update ownership of files
USER root
RUN chown -R mqperf:mqm /opt/mqm/ssl \
  && chown -R mqperf:mqm /home/mqperf/cph

USER mqperf
WORKDIR /home/mqperf/cph
ENV MQ_QMGR_NAME=PERF0
ENV MQ_QMGR_PORT=1420
ENV MQ_QMGR_CHANNEL=SYSTEM.DEF.SVRCONN
ENV MQ_QMGR_QREQUEST_PREFIX=REQUEST
ENV MQ_QMGR_QREPLY_PREFIX=REPLY
ENV MQ_NON_PERSISTENT=
ENV MQ_CPH_EXTRA=
ENV MQ_USERID=
ENV MQ_COMPRESS=

ENTRYPOINT ["./cphTest.sh"]

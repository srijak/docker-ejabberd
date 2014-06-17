# Ejabberd 14.05 and otp 17.0

FROM ubuntu:12.04

MAINTAINER Rafael Römhild <rafael@roemhild.de>

RUN apt-get update
RUN apt-get -y dist-upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install curl build-essential m4 git libncurses5-dev libssh-dev libyaml-dev libexpat-dev

# user & group
RUN addgroup ejabberd
RUN adduser --system --ingroup ejabberd --home /opt/ejabberd --disabled-login ejabberd

# erlang
RUN mkdir -p /src/erlang \
&& cd /src/erlang \
&& curl http://erlang.org/download/otp_src_17.0.tar.gz > otp_src_17.0.tar.gz \
&& tar xf otp_src_17.0.tar.gz \
&& cd otp_src_17.0 \
&& ./configure \
&& make \
&& make install

# ejabberd
RUN mkdir -p /src/ejabberd \
&& cd /src/ejabberd \
&& curl -L "http://www.process-one.net/downloads/downloads-action.php?file=/ejabberd/14.05/ejabberd-14.05.tgz" > ejabberd-14.05.tgz \
&& tar xf ejabberd-14.05.tgz \
&& cd ejabberd-14.05 \
&& ./configure --enable-user=ejabberd \
&& make \
&& make install

# cleanup
#RUN cd / && rm -rf /src
#RUN DEBIAN_FRONTEND=noninteractive apt-get -y autoremove
#RUN sync

# copy config
RUN rm /etc/ejabberd/ejabberd.yml
ADD ./ejabberd.yml /etc/ejabberd/
ADD ./ejabberdctl.cfg /etc/ejabberd/

USER ejabberd
EXPOSE 5222 5269 5280
CMD ["live"]
ENTRYPOINT ["ejabberdctl"]

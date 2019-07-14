FROM registry.redhat.io/ubi8/ruby-25

ARG OTW_WEB_PORT=7143

# Dependencies
USER root
RUN yum -y install \
      openssl \
      readline \
      libevent \
      libyaml \
      libxml2 \
      zlib \
  && gem install bundler

# OTS
RUN mkdir -p /var/log/onetime /var/run/onetime /var/lib/onetime /etc/onetime /source/onetime
COPY . /source/onetime

# Entrypoint
COPY entrypoint.sh /entrypoint.sh

# Permissions
RUN chown -R 0 /entrypoint.sh /var/log/onetime /var/run/onetime /var/lib/onetime /etc/onetime /source/onetime \
  && chmod -R g=u /entrypoint.sh /var/log/onetime /var/run/onetime /var/lib/onetime /etc/onetime /source/onetime \
  && chmod -R 770 /entrypoint.sh /source/onetime/bin

USER 1001
RUN cd /source/onetime \
  && bundle install --frozen --deployment --without=dev \
  && gem update \
  && bin/ots init \
  && cp -R etc/* /etc/onetime

EXPOSE ${OTW_WEB_PORT}

WORKDIR /source/onetime

ENTRYPOINT ["/entrypoint.sh"]

FROM debian:stable

ENV HOME /root

RUN \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get -y install --no-install-recommends \
    make m4 \
    lua5.1 lua-check \
    && \
  apt-get clean

COPY feeds.conf /feeds.conf

CMD [ "bash" ]

# vim: ft=dockerfile

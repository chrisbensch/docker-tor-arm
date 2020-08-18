# Dockerfile for Tor Relay Server with obfs4proxy (Multi-Stage build)
#FROM raspbian/stretch
FROM balenalib/raspberrypi4-64-debian

LABEL maintainer="chris.bensch@gmail.com"

ARG DEBIAN_FRONTEND=noninteractive

# Set a default Nickname
ENV TOR_NICKNAME=tordefnick
ENV TOR_USER=tord
ENV TERM=xterm

# Install prerequisites
RUN apt-get update \
 && apt-get install --no-install-recommends --no-install-suggests -y \
        apt-transport-https \
        ca-certificates \
        dirmngr \
        apt-utils \
        gnupg \
        curl \
 # Install tor with GeoIP and obfs4proxy & backup torrc \
 && apt-get update \
 && apt-get install --no-install-recommends --no-install-suggests -y \
        pwgen \
        iputils-ping \
        tor \
        tor-geoipdb \
        obfs4proxy \
 && mkdir -pv /usr/local/etc/tor/ \
 && mv -v /etc/tor/torrc /usr/local/etc/tor/torrc.sample \
 && apt-get purge --auto-remove -y --allow-remove-essential \
        apt-transport-https \
        dirmngr \
        apt-utils \
        gnupg \
 #&& apt-get clean \
 #&& rm -rf /var/lib/apt/lists/* \
 # Rename Debian unprivileged user to tord \
 && usermod -l tord debian-tor \
 && groupmod -n tord debian-tor

# Copy Tor configuration file
COPY ./torrc /etc/tor/torrc

# Copy docker-entrypoint
COPY ./scripts/ /usr/local/bin/

# Persist data
VOLUME /etc/tor /var/lib/tor

# ORPort, DirPort, SocksPort, ObfsproxyPort, MeekPort
EXPOSE 9001 9030 9050 54444 7002

ENTRYPOINT ["docker-entrypoint"]
CMD ["tor", "-f", "/etc/tor/torrc"]

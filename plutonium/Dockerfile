# ---------------------------------------
# Wine+SteamCMD for Plutonium Server 
# This is a combination of Parker's Wine and SteamCMD yolks, plus extras for the Plutonium COD Servers
# ---------------------------------------
FROM ghcr.io/parkervcp/yolks:debian

LABEL author="Fuko.dev" maintainer="fuko@fuko.dev"

# Install required packages
RUN dpkg --add-architecture i386 \
    && apt update -y \
    && apt install -y --no-install-recommends gnupg2 numactl tzdata software-properties-common libntlm0 winbind xvfb xauth python3 libncurses5:i386 libncurses6:i386 libsdl2-2.0-0 libsdl2-2.0-0:i386 \
    && apt install -y --no-install-recommends wget iproute2 libncurses5-dev:i386 libncurses6 dbus libgdiplus lib32gcc-s1 \
    && apt install -y alsa-tools libpulse0 pulseaudio libpulse-dev libasound2 libao-common gnutls-bin gnupg locales cabextract curl python3-pip python3-setuptools tini file pipx

# Check if user exists before creating
RUN id -u container &>/dev/null || useradd -d /home/container -m container

# Install Wine and its dependencies
RUN mkdir -pm755 /etc/apt/keyrings \
    && wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
    && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources \
    && apt update \
    && apt install --install-recommends winehq-stable cabextract wine-binfmt -y \
    && echo -e 'export WINEPREFIX=~/.wine\nexport WINEDEBUG=fixme-all\nexport WINEARCH=win64' >> /etc/profile.d/wine.sh

# Set up Winetricks
RUN wget -q -O /usr/sbin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    && chmod +x /usr/sbin/winetricks

# Download and extract Proton GE
RUN curl -sLOJ "$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | egrep .tar.gz)" \
    && tar -xzf GE-Proton*.tar.gz -C /usr/local/bin/ --strip-components=1 \
    && rm GE-Proton*.*

# Fix machine-id for Proton
RUN rm -f /etc/machine-id \
    && dbus-uuidgen --ensure=/etc/machine-id \
    && rm /var/lib/dbus/machine-id \
    && dbus-uuidgen --ensure

# Setup Protontricks
RUN pipx install protontricks

# Install rcon
RUN cd /tmp/ \
    && curl -sSL https://github.com/gorcon/rcon-cli/releases/download/v0.10.3/rcon-0.10.3-amd64_linux.tar.gz > rcon.tar.gz \
    && tar xvf rcon.tar.gz \
    && mv rcon-0.10.3-amd64_linux/rcon /usr/local/bin/

# Plutonium Server Setup
RUN cd ~ \
    && wget https://cdn.plutonium.pw/updater/plutonium.exe -O plutonium \
    && chmod +x ./plutonium

# Manually install SteamCMD
RUN mkdir -p /home/container/steamcmd \
    && cd /home/container/steamcmd \
    && curl -sSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar -xzv \
    && chmod +x /home/container/steamcmd/steamcmd.sh \
    && chown -R container:container /home/container/steamcmd

# Switch to container user
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

RUN winecfg

ENV HOME=/home/container
ENV WINEPREFIX=/home/container/.wine
ENV WINEDLLOVERRIDES="mscoree,mshtml="
ENV DISPLAY=:0
ENV DISPLAY_WIDTH=1024
ENV DISPLAY_HEIGHT=768
ENV DISPLAY_DEPTH=16
ENV AUTO_UPDATE=1
ENV XVFB=1

STOPSIGNAL SIGINT

COPY --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/bin/bash", "/entrypoint.sh"]

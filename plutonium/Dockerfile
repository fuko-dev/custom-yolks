# ---------------------------------------
# Wine+SteamCMD for Plutonium Server 
# This is just a combination of Parker's Wine and SteamCMD yolks, plus some extras for the Plutonium COD Servers
# ---------------------------------------
FROM            ghcr.io/parkervcp/yolks:debian

LABEL           author="Fuko.dev" maintainer="fuko@fuko.dev"

# Install required packages
RUN             dpkg --add-architecture i386 \
                && apt update -y \
                && apt install -y --no-install-recommends gnupg2 numactl tzdata software-properties-common libntlm0 winbind xvfb xauth python3 libncurses5:i386 libncurses6:i386 libsdl2-2.0-0 libsdl2-2.0-0:i386
RUN             apt install -y --no-install-recommends wget iproute2 libncurses5-dev:i386 libncurses6 dbus libgdiplus lib32gcc-s1
RUN             apt install -y alsa-tools libpulse0 pulseaudio libpulse-dev libasound2 libao-common gnutls-bin gnupg locales cabextract curl python3-pip python3-setuptools tini file pipx

# Check if user exists before creating
RUN             id -u container &>/dev/null || useradd -d /home/container -m container


# Install wine and with recommends
RUN             mkdir -pm755 /etc/apt/keyrings
RUN             wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
RUN             wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources
RUN             apt update
RUN             apt install --install-recommends winehq-stable cabextract wine-binfmt -y
# Add Variables to the environment at the end of ~/.bashrc
RUN             echo -e 'export WINEPREFIX=~/.wine\nexport WINEDEBUG=fixme-all\nexport WINEARCH=win64' >> ~/.bashrc
RUN             . ~/.bashrc

USER            container
ENV             USER=container HOME=/home/container
WORKDIR         /home/container

RUN             winecfg

# Set up Winetricks
RUN	            wget -q -O /usr/sbin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
                && chmod +x /usr/sbin/winetricks

# Download Proton GE
RUN             curl -sLOJ "$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | egrep .tar.gz)"
RUN             tar -xzf GE-Proton*.tar.gz -C /usr/local/bin/ --strip-components=1
RUN             rm GE-Proton*.*

# Proton Fix machine-id
RUN             rm -f /etc/machine-id
RUN             dbus-uuidgen --ensure=/etc/machine-id
RUN             rm /var/lib/dbus/machine-id
RUN             dbus-uuidgen --ensure

# Setup Protontricks
RUN             pipx install protontricks

# Install rcon
RUN             cd /tmp/ \
                && curl -sSL https://github.com/gorcon/rcon-cli/releases/download/v0.10.3/rcon-0.10.3-amd64_linux.tar.gz > rcon.tar.gz \
                && tar xvf rcon.tar.gz \
                && mv rcon-0.10.3-amd64_linux/rcon /usr/local/bin/

# Plutonium Server Setup
RUN             cd ~/
RUN             wget https://cdn.plutonium.pw/updater/plutonium.exe -O plutonium
RUN             chmod +x ./plutonium
RUN             ./plutonium -install-dir ./pluto
# Install SteamCMD
RUN             add-apt-repository multiverse
RUN             apt update
RUN             apt install lib32gcc1 steamcmd -y
# Install the server files into ~/server e.g. /root/server
RUN             steamcmd +@sSteamCmdForcePlatformType windows +login anonymous +force_install_dir ~/server +app_update 42750 validate +quit
# Delete steam_api.dll from the directory
RUN             rm ~/server/steam_api.dll


ENV             HOME=/home/container
ENV             WINEPREFIX=/home/container/.wine
ENV             WINEDLLOVERRIDES="mscoree,mshtml="
ENV             DISPLAY=:0
ENV             DISPLAY_WIDTH=1024
ENV             DISPLAY_HEIGHT=768
ENV             DISPLAY_DEPTH=16
ENV             AUTO_UPDATE=1
ENV             XVFB=1

STOPSIGNAL      SIGINT

COPY            --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN             chmod +x /entrypoint.sh
ENTRYPOINT      ["/usr/bin/tini", "-g", "--"]
CMD             [ "/bin/bash", "/entrypoint.sh" ]
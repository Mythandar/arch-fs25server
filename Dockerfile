FROM binhex/arch-int-gui:2025122001
LABEL org.opencontainers.image.authors="Toetje585"
LABEL org.opencontainers.image.source="https://github.com/Mythandar/arch-fs25server"
LABEL org.opencontainers.image.revision="84f0a6a07ee3036366f309ea60cc83c2f5e48313"

# release tag name from buildx arg
ARG RELEASETAG

# arch from buildx --platform, e.g. amd64
ARG TARGETARCH

# add install bash script
ADD build/root/*.sh /root/

# add bash script to run app
ADD run/nobody/*.sh /usr/local/bin/

# add js script to run app
ADD run/nobody/*.mjs /usr/local/bin/

# add pre-configured config files for nobody
ADD config/nobody/ /home/nobody/.build/

# add rootfs files

COPY build/rootfs /

# install app
#############

# make executable and run bash scripts to install app
RUN chmod +x /root/*.sh && \
	/bin/bash /root/install.sh "${RELEASETAG}" "${TARGETARCH}"

# Fix websockify trying to run on wrong python version
RUN pip install --break-system-packages --force-reinstall websockify

# docker settings
#################

# env
#####

# set environment variables for user nobody
ENV HOME=/home/nobody

# set environment variable for terminal
ENV TERM=xterm

# set environment variables for language
ENV LANG=en_GB.UTF-8

HEALTHCHECK --interval=30s --timeout=5s --start-period=3m --retries=5 \
  CMD ["/usr/local/bin/healthcheck_fs25.sh"]

# set permissions
#################

# run script to set uid, gid and permissions
CMD ["/bin/bash", "/usr/bin/init.sh"]

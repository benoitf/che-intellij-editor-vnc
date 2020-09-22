FROM debian:10.5

RUN echo "deb http://ftp.debian.org/debian/ testing main contrib non-free" >> /etc/apt/sources.list && \
    apt-get update && apt-get install -y git xvfb supervisor x11vnc novnc wget openjdk-11-jdk icewm ttf-mscorefonts-installer && apt-get clean
RUN mkdir /ideaIC-2020.2.1 && wget -qO- https://download.jetbrains.com/idea/ideaIC-2020.2.1.tar.gz | tar -zxv --strip-components=1 -C /ideaIC-2020.2.1 && \
    mkdir /intellij-config && \
    for f in "/intellij-config" "/ideaIC-2020.2.1" "/etc/passwd"; do \
      echo "Changing permissions on ${f}" && chgrp -R 0 ${f} && \
      chmod -R g+rwX ${f}; \
    done

COPY --chown=0:0 entrypoint.sh /entrypoint.sh
# Set permissions on /etc/passwd and /home to allow arbitrary users to write
COPY entrypoint.sh /
COPY supervisord.conf /etc/supervisord.conf
RUN mkdir -p /home/user && chgrp -R 0 /home && chmod -R g=u /etc/passwd /etc/group /home && chmod +x /entrypoint.sh
USER 10001
ENV HOME=/home/user
WORKDIR /projects
ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["tail", "-f", "/dev/null"]

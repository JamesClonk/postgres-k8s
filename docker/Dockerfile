FROM postgres:12
EXPOSE 5432

RUN useradd -ms /bin/bash stolon

COPY bin/ /usr/local/bin
RUN chmod u+x /usr/local/bin/stolon-keeper /usr/local/bin/stolon-sentinel /usr/local/bin/stolon-proxy /usr/local/bin/stolonctl

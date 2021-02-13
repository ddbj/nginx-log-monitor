FROM centos:7

ENV LANG=ja_JP.UTF-8
RUN localedef -v -c -i ja_JP -f UTF-8 ja_JP.UTF-8; echo"";

RUN mkdir -p /opt/filebeat_support
COPY bin /opt/filebeat_support/bin
RUN chmod a+x /opt/filebeat_support/bin/*.sh

CMD ["/opt/filebeat_support/bin/setup_kibana.sh"]

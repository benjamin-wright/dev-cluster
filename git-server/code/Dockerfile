FROM alpine:3.6

RUN apk add --no-cache openssh git

RUN apk add --no-cache --virtual config_editing sed \
    && sed -i /etc/ssh/sshd_config \
        -e 's/#PasswordAuthentication yes/PasswordAuthentication no/g' \
        -e 's/#AllowAgentForwarding yes/AllowAgentForwarding no/g' \
        -e 's/#AllowTcpForwarding yes/AllowTcpForwarding no/g' \
        -e 's|#HostKey /etc/ssh/|HostKey /git/data/keys/|g' \
    && apk del config_editing

RUN mkdir -p /git/data \
    && mkdir -p /git/data/keys \
    && mkdir -p /git/data/users \
    && git config --system uploadpack.allowReachableSHA1InWant true

WORKDIR /git

COPY skel /etc/skel
COPY entrypoint.sh ./

RUN touch /var/log/messages

EXPOSE 22
VOLUME /git/data

ENTRYPOINT ["/git/entrypoint.sh"]
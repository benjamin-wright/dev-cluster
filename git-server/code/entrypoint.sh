#!/bin/sh

maybe_build_key(){
    if [ -f "/git/data/keys/ssh_host_$1_key" ]
    then
        echo "Found $1 Key...Done"
    else
        echo "Generating $1 Key..."
        ssh-keygen -q -N '' -t $1 -f /git/data/keys/ssh_host_$1_key
        cat /git/data/keys/ssh_host_$1_key.pub
        echo "Generating $1 Key...Done"
    fi
}

echo "Checking for Keys..."
for t in rsa dsa ecdsa ed25519; do
    maybe_build_key $t
done
echo "Checking for Keys...Completed"

link_file(){
    echo "Linking /git/data/users/git_$1..."
    if [ ! -f "/git/data/users/git_$1" ]
    then
        cp /etc/$1 /git/data/users/git_$1
    fi
    ln -sf /git/data/users/git_$1 /etc/$1
    echo "Linking /git/data/users/git_$1...Complete"
}

echo "Setup userdata..."
for f in passwd group shadow; do
    link_file $f
done
echo "Setup userdata...Complete"

add_user(){
    adduser -h /git/data/users/$1 -g "" -D -s /usr/bin/git-shell $1 &&
        echo "$1:*" | chpasswd 2> /dev/null &&
        mkdir -p /git/data/users/$1/.ssh &&
        echo "$2" | base64 -d >> /git/data/users/$1/.ssh/authorized_keys &&
        chown -R $1:$1 /git/data/users/$1 &&
        chmod 700 /git/data/users/$1/.ssh &&
        chmod -R 600 /git/data/users/$1/.ssh/* &&
        logger -p info -t git Added user $1
}

echo "Add base user..."
add_user $BASE_USER $BASE_KEY
echo "Base user...Complete"

echo "Starting syslogd..."
/sbin/syslogd &

echo "Starting sshd..."
/usr/sbin/sshd &&
    tail -F /var/log/*

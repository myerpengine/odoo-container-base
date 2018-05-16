#! /bin/sh

if test ! -e /inited; then
    echo "Initializing container"
    echo root:`pwgen -cnsN 1 12` | chpasswd
    if [ "$PUBLIC_AUTH_KEY" != "" ]; then
        mkdir -p /root/.ssh
        echo $PUBLIC_AUTH_KEY >> /root/.ssh/authorized_keys2
    fi
    echo user:`pwgen -cnsN 1 12` | chpasswd
    usermod -u $USER_UID user
    service sshd start
    service sshd stop
    touch /inited
fi

if test ! -e /home/user/virtualenv; then
    su user -c "/usr/local/bin/virtualenv --system-site-packages /home/user/virtualenv"
fi

exec "$@"

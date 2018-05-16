#! /bin/sh

if test ! -e /inited; then
    echo "Initializing container"
    echo user:`pwgen -cnsN 1 12` | chpasswd
    service sshd start
    service sshd stop
    usermod -u $USER_UID user
    touch /inited
fi

if test ! -e /home/user/virtualenv; then
    su user -c "/usr/local/bin/virtualenv --system-site-packages /home/user/virtualenv"
fi

exec "$@"

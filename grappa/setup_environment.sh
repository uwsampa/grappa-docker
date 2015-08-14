#!/bin/bash

profile=/root/.bashrc

cd /

# have to make sure we re-set shmmax before running any Grappa programs
echo "sudo sysctl -w kernel.shmmax=$((1<<30)) >/dev/null 2>/dev/null" >> $profile

# set prompt colors because I'm a bit vain about that
echo "export PS1='\[\e[0;34m\]docker \[\e[m\]\[\e[0;32m\]\w\[\e[m\] \[\e[0;33m\]> \[\e[m\]'" >> $profile
# and common aliases
echo "alias ls='ls --color=auto'" >> $profile
echo "alias ll='ls -lah'" >> $profile

# enable tab completion
echo "source /etc/bash_completion" >> $profile

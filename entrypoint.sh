#!/bin/bash
# Copyright (c) 2012-2017 Red Hat, Inc.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Contributors:
# Red Hat, Inc. - initial implementation

set -e

export USER_ID=$(id -u)
export GROUP_ID=$(id -g)

write_key() {
        mkdir -p "${JENKINS_AGENT_HOME}/.ssh"
        echo "$1" > "${JENKINS_AGENT_HOME}/.ssh/authorized_keys"
        chown -Rf user:user "${JENKINS_AGENT_HOME}/.ssh"
        chmod 0700 -R "${JENKINS_AGENT_HOME}/.ssh"
}

if [[ $JENKINS_SLAVE_SSH_PUBKEY == ssh-* ]]; then
  write_key "${JENKINS_SLAVE_SSH_PUBKEY}"
fi
if [[ $# -gt 0 ]]; then
  if [[ $1 == ssh-* ]]; then
    write_key "$1"
    shift 1
  else
    exec "$@"
  fi
fi

if ! grep -Fq "${USER_ID}" /etc/passwd; then
    # current user is an arbitrary 
    # user (its uid is not in the 
    # container /etc/passwd). Let's fix that    
    cat ${HOME}/passwd.template | \
    sed "s/\${USER_ID}/${USER_ID}/g" | \
    sed "s/\${GROUP_ID}/${GROUP_ID}/g" | \
    sed "s/\${HOME}/\/home\/user/g" > /etc/passwd
    
    cat ${HOME}/group.template | \
    sed "s/\${USER_ID}/${USER_ID}/g" | \
    sed "s/\${GROUP_ID}/${GROUP_ID}/g" | \
    sed "s/\${HOME}/\/home\/user/g" > /etc/group
fi

if test "${USER_ID}" = 0; then
    # current user is root
    /usr/sbin/sshd -D &
elif sudo -n true > /dev/null 2>&1; then
    # current user is a suoder
    sudo /usr/sbin/sshd -D &
fi

exec "$@"

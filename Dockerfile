FROM jenkinsci/ssh-slave

ENV GIT_SSL_NO_VERIFY TRUE

RUN apt-get update -qq && apt-get install -y -qq --no-install-recommends \
    make curl wget vim python-pip s3cmd \
    libssl-dev apt-transport-https ca-certificates curl gnupg2 \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
    && echo "deb [arch=amd64] https://download.docker.com/linux/debian stretch stable" > /etc/apt/sources.list.d/docker-ce.list \
    && apt-get update && apt-get -y dist-upgrade && apt-get install -y maven docker-ce \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN usermod -a -G root jenkins
RUN echo 'jenkins ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

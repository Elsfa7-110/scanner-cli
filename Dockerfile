FROM centos:7
MAINTAINER Karl Stoney <me@karlstoney.com>

RUN yum -y -q update && \
    yum -y -q remove iputils && \
    yum -y -q install wget epel-release openssl openssl-devel tar unzip \
							libffi-devel python-devel redhat-rpm-config git-core \
							gcc gcc-c++ make zlib-devel pcre-devel ca-certificates \
              ruby rubygems && \
    yum -y -q clean all

# Git-crypt
RUN cd /tmp && \
    wget --quiet https://www.agwa.name/projects/git-crypt/downloads/git-crypt-0.5.0.tar.gz && \
    tar xzf git-crypt* && \
    cd git-crypt* && \
    make && \
    make install && \
    rm -rf /tmp/git-crypt*

ENV NODE_VERSION=8.1.4
ENV NPM_VERSION=5.3.0

# Get nodejs repos
RUN curl --silent --location https://rpm.nodesource.com/setup_8.x | bash -

RUN dnf -y install nodejs-$NODE_VERSION gcc-c++ make git && \
    dnf -y clean all

RUN rm -rf /usr/lib/node_modules/npm && \
    mkdir /usr/lib/node_modules/npm && \
    curl -sL https://github.com/npm/npm/archive/v$NPM_VERSION.tar.gz | tar xz -C /usr/lib/node_modules/npm --strip-components=1

RUN node --version && \
    npm --version

# If we ever change the hawkeye version, redo everything below
ARG HE_VERSION=

# If we have changed the hawkeye version, do an update
RUN yum -y -q update && \
    yum -y -q clean all

# Add bundler-audit
RUN gem install bundler-audit
RUN bundle-audit update

# Install hawkeye
RUN mkdir -p /hawkeye
COPY package.json /hawkeye

RUN cd /hawkeye && \
    npm install --production --quiet
COPY ./ /hawkeye

WORKDIR /target

ENV PATH=/hawkeye/bin:$PATH
ENTRYPOINT ["hawkeye"]
CMD ["scan", "/target"]

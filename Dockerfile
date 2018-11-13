FROM centos:7

MAINTAINER Naftuli Kay <me@naftuli.wtf>

ENV JUPYTER_USER=jupyter

# create user
RUN useradd -m ${JUPYTER_USER} && chown -R ${JUPYTER_USER}:${JUPYTER_USER} /srv

# Install pyenv and the given Python version in one fell swoop
ENV PYTHON_VERSION=3.7.1
ENV PYENV_INSTALLER_URL=https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer

RUN yum install -y epel-release >/dev/null && \
  yum install -y libffi-devel libxml2-devel libxslt-devel libyaml-devel python python-devel python34 python34-devel \
    make gcc python2-pip python3-pip zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel xz \
    xz-devel git patch czmq-devel bash-completion man-pages which sudo rsync curl openssh-clients >/dev/null && \
  curl -sSL ${PYENV_INSTALLER_URL} | sudo -Hu ${JUPYTER_USER} bash -ls - -y && \
  echo '$HOME/.pyenv/bin/pyenv install' ${PYTHON_VERSION} | sudo -Hu ${JUPYTER_USER} bash -ls - && \
  echo '$HOME/.pyenv/bin/pyenv global' ${PYTHON_VERSION} | sudo -Hu ${JUPYTER_USER} bash -ls - && \
  yum clean all >/dev/null && rm -rf /var/cache/yum

ADD etc/profile.d/pyenv.sh /etc/profile.d/

# Install Latest Rust
ENV RUST_TOOLCHAIN=stable
ENV RUSTUP_INSTALLER_URL=https://sh.rustup.rs

RUN curl -fsSL ${RUSTUP_INSTALLER_URL} | sudo -Hu ${JUPYTER_USER} bash -ls - -y && \
  echo '$HOME/.cargo/bin/rustup default' ${RUST_TOOLCHAIN} | sudo -Hu ${JUPYTER_USER} bash -ls - && \
  sudo -Hu ${JUPYTER_USER} bash -lc '$HOME/.cargo/bin/rustup completions bash' > /etc/bash_completion.d/rustup && \
  sudo -Hu ${JUPYTER_USER} bash -lc '$HOME/.cargo/bin/rustup component add rls-preview rust-analysis rust-src' && \
  mkdir -p /usr/local/man/man1/ && \
  rsync -a /home/${JUPYTER_USER}/.rustup/toolchains/${RUST_TOOLCHAIN}-$(uname -m)-unknown-linux-gnu/share/man/man1/ \
    /usr/local/man/man1/

ADD etc/profile.d/rust.sh /etc/profile.d/

USER ${JUPYTER_USER}
WORKDIR /srv

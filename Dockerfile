FROM centos:7

MAINTAINER Naftuli Kay <me@naftuli.wtf>

ENV JUPYTER_USER=jupyter
ENV HOME=/home/${JUPYTER_USER}
ENV PATH=$HOME/.cargo/bin:$HOME/.pyenv/shims:$HOME/.pyenv/bin:$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# create user
RUN useradd -m ${JUPYTER_USER}

# add PATH modifications to profile
ADD etc/profile.d/*.sh /etc/profile.d/

# install build dependencies
RUN yum install -y epel-release >/dev/null && \
  yum install -y libffi-devel libxml2-devel libxslt-devel libyaml-devel python python-devel python34 python34-devel \
    make gcc python2-pip python3-pip zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel xz \
    xz-devel git patch czmq-devel bash-completion man-pages which sudo rsync curl openssh-clients >/dev/null && \
  yum clean all >/dev/null && rm -rf /var/cache/yum

# Install Python
ENV PYTHON_VERSION=3.7.1
ENV PYENV_INSTALLER_URL=https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer

RUN curl -sSL ${PYENV_INSTALLER_URL} | sudo -Hu ${JUPYTER_USER} bash -ls - -y && \
  sudo -Hiu ${JUPYTER_USER} pyenv install ${PYTHON_VERSION} && \
  sudo -Hiu ${JUPYTER_USER} pyenv global ${PYTHON_VERSION}

# Install Rust
ENV RUST_TOOLCHAIN=stable
ENV RUSTUP_INSTALLER_URL=https://sh.rustup.rs

RUN curl -fsSL ${RUSTUP_INSTALLER_URL} | sudo -Hu ${JUPYTER_USER} bash -ls - -y && \
  sudo -Hiu ${JUPYTER_USER} rustup default ${RUST_TOOLCHAIN} && \
  sudo -Hiu ${JUPYTER_USER} rustup completions bash > /etc/bash_completion.d/rustup && \
  sudo -Hiu ${JUPYTER_USER} rustup component add rls-preview rust-analysis rust-src && \
  mkdir -p /usr/local/man/man1/ && \
  rsync -a $HOME/.rustup/toolchains/${RUST_TOOLCHAIN}-$(uname -m)-unknown-linux-gnu/share/man/man1/ \
    /usr/local/man/man1/

# drop privileges
USER ${JUPYTER_USER}
WORKDIR ${HOME}
EXPOSE 8888

# install python packages
ADD --chown=jupyter:jupyter requirements.txt $HOME/requirements.txt
RUN pip install --user -r $HOME/requirements.txt && rm $HOME/requirements.txt

# install rust evaluation context for jupyter
RUN cargo install evcxr_jupyter && evcxr_jupyter --install

# add files
ADD --chown=jupyter:jupyter index.ipynb $HOME/
ADD --chown=jupyter:jupyter notebooks/ $HOME/notebooks/

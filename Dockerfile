FROM naftulikay/joop-base:latest

MAINTAINER Naftuli Kay <me@naftuli.wtf>

# add files
ADD --chown=jupyter:jupyter index.ipynb $HOME/
ADD --chown=jupyter:jupyter notebooks/ $HOME/notebooks/

#!/usr/bin/make -f

DOCKER:=$(shell if ! id -G -n | grep -qP 'docker' ; then echo -n 'sudo ' ; fi && echo -n 'docker')

build:
	@$(DOCKER) build -t naftulikay/joop:latest .

serve:
	@$(DOCKER) run -it --rm \
		-p 8888:8888 \
		-v "$(PWD)/index.ipynb:/home/jupyter/index.ipynb" \
		-v "$(PWD)/notebooks:/home/jupyter/notebooks" \
		naftulikay/joop:latest \
			jupyter notebook --ip=0.0.0.0

DOCKER_IMAGE_NAEME ?= docker-golang-whispercpp:latest

tidy:
	go mod tidy

build: tidy
	docker build -t $(DOCKER_IMAGE_NAEME) -f Dockerfile .

build-no-cache: tidy
	docker build --progress plain -t $(DOCKER_IMAGE_NAEME) -f Dockerfile --no-cache .

build-and-run: build
	docker run --rm $(DOCKER_IMAGE_NAEME)

build-and-shell: build
	docker run -it --rm -v $(shell pwd)/tmp:/tmp $(DOCKER_IMAGE_NAEME) bash

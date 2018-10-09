DOCKER?= docker
VERSION?= 1.0
NAME?= stoned/ebug
all: build
build: FORCE
	$(DOCKER) build -t $(NAME):$(VERSION) .
	$(DOCKER) tag $(NAME):$(VERSION) $(NAME):latest
FORCE:

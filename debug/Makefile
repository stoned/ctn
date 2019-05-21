NAME?= stoned/ebug
VERSION?= 1.2
all: build
build: FORCE
	buildah unshare sh build.sh $(NAME):$(VERSION)
push2docker: FORCE
	buildah push localhost/$(NAME):$(VERSION) docker-daemon:$(NAME):$(VERSION)
push2hub: FORCE
	buildah push localhost/$(NAME):$(VERSION) docker://$(NAME):$(VERSION)
	buildah push localhost/$(NAME):$(VERSION) docker://$(NAME):latest
FORCE:

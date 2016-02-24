REPO=mikz/transmission

all: build

build:
	docker build -t $(REPO) .
push:
	docker push $(REPO)
sh:
	docker run -P -t -i -v $(PWD)/storage:/mnt/storage $(REPO) sh
run:
	docker run --detach --publish 22 --publish 51413:51413 --expose 9091 --volume $(PWD)/storage:/mnt/storage $(REPO)

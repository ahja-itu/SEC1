.PHONY: gen-certs clean dev run build setup run-remote build-and-push

gen-certs:
	./scripts/gen_certs.sh

clean:
	docker-compose rm -f

build:
	docker-compose build

dev:
	docker-compose -f docker-compose-dev.yaml up --build --remove-orphans

run:
	docker-compose up

run-remote:
	docker-compose -f docker-compose.remote.yaml up

setup: gen-certs build

build-and-push:
	docker build -t itu.sec1.ma2 -f dockerfiles/release.Dockerfile .
	docker tag itu.sec1.ma2 andreaswachs/itu.sec1.ma2:latest
	docker push andreaswachs/itu.sec1.ma2:latest

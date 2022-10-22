.PHONY: gen-certs clean dev run build setup

gen-certs:
	./scripts/gen_certs.sh

clean:
	docker-compose rm -f

build:
	docker-compose build

dev:
	docker-compose up --build

run:
	docker-compose up


setup: gen-certs dev

# Generates certificates for Alice and Bob
.PHONY: gen-certs
gen-certs:
	./scripts/gen_certs.sh

.PHONY: clean
clean:
	docker-compose rm -f

.PHONY: build
build:
	docker-compose build

.PHONY: dev
dev:
	docker-compose up --build


.PHONY: run
run:
	docker-compose up
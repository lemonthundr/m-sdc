include make_env

NS ?= lemonthundr
VERSION ?= latest

IMAGE_NAME ?= hugo-builder
CONTAINER_NAME ?= hugo-builder
CONTAINER_INSTANCE ?= default

.PHONY: analyze clean build build-static-assets push shell start stop rm release health-check inspect-labels

analyze: Dockerfile
		@echo "Linting Dockerfile..."
		@docker run --rm -i hadolint/hadolint:v1.17.5-alpine \
				hadolint --ignore DL3018 - < Dockerfile
		@echo "No violations found. "

clean:
		@echo "removing $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)"
		@docker rm -f $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) 2> /dev/null || true

build:
		@echo "Building container $(NS)/$(IMAGE_NAME):$(VERSION)"
		@docker build -t $(NS)/$(IMAGE_NAME):$(VERSION) -f Dockerfile .
		@docker images $(NS)/$(IMAGE_NAME):$(VERSION) --format "table {{.Size}}\t{{.Repository}}\t{{.Tag}}\t{{.ID}}"

build-static-assets:
		@echo "Building static assets..."
		@docker run --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) -i -t $(PORTS) $(VOLUMES) $(ENV) -u hugo $(NS)/$(IMAGE_NAME):$(VERSION) hugo

push:
		@docker push $(NS)/$(IMAGE_NAME):$(VERSION)

shell:
		@docker run --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) -i -t $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION) /bin/ash

start:
		@docker run -d --rm -it --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) -u hugo $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION) hugo server -w --bind=0.0.0.0

stop:
		@docker stop $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

rm:
		@docker rm $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) 2> /dev/null || true
		@echo "container $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) removed"

release: build
		make push -e VERSION=$(VERSION)

health-check:
	@docker inspect --format='{{json .State.Health.Status}}' $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

inspect-labels:
	@echo "maintainer set to.."
	@docker inspect --format '{{ index .Config.Labels "maintainer" }}' $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

all: analyze build

default: all

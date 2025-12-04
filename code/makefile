# Basic config
IMAGE_NAME = gsea_container
IMAGE_TAG  = latest
DOCKER_IMAGE = $(IMAGE_NAME):$(IMAGE_TAG)

# Singularity outputs
SIF_FILE      = $(IMAGE_NAME).sif
SANDBOX_DIR   = $(IMAGE_NAME)_sandbox

.PHONY: all docker-build docker-run singularity-sif singularity-sandbox clean

all: docker-build

## Build Docker image from Dockerfile
docker-build:
	docker build -t $(DOCKER_IMAGE) .

## Run an interactive R session in the container
docker-run:
	docker run --rm -it \
		-v $(PWD):/work \
		-w /work \
		$(DOCKER_IMAGE)

## Build a Singularity SIF image from the local Docker image
## Requires Singularity/Apptainer on the host
singularity-sif: docker-build
	singularity build $(SIF_FILE) docker-daemon://$(DOCKER_IMAGE)

## Build a Singularity sandbox directory (writable dir format)
singularity-sandbox: docker-build
	singularity build --sandbox $(SANDBOX_DIR) docker-daemon://$(DOCKER_IMAGE)

## Clean up locally built Singularity artifacts
clean:
	rm -rf $(SIF_FILE) $(SANDBOX_DIR)

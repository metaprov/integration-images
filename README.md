## Integration Images

This repository defines Docker images for Kubernetes-in-docker containers that run Modela ephemerally. These images are intended for use with CI/CD and benchmarking systems to instantly access a functional instance of Modela on an docker-embedded Kubernetes cluster.

`docker run -it --privileged -p 8080:8080 ghcr.io/metaprov/kind-modela:latest`

Note that the size of the container is very large (17GB) as it embeds every Modela image.
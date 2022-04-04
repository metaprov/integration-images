## Integration Images

This repository defines Docker images for Kubernetes-in-docker containers that run Modela ephemerally. These images are intended for use with CI/CD and benchmarking systems to instantly access a functional instance of Modela on an docker-embedded Kubernetes cluster.

`docker run -it --cpus="2" --memory="8g" -p 8443:8443 -p 8080:8080 -p 8081:8081 -p 9001:9001 -p 8095:8095 -p 9000:9000 --privileged ghcr.io/metaprov/kind-modela`

Note that the size of the container is large (17GB) as it embeds every Modela image. Modela takes about 3-5 to initialize, after which it will be accessible at localhost:8081
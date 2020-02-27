## Container Microservice with CodeBuild & Code Pipeline for K8s

This code covers the creation of a basic Pull,Build,Deploy pipeline for a container based Go microservice. This repo gives the following

* CodePipeline to cover the three steps along with IAM role.
* CodeBuild "units" for Build and Deploy

This code is designed to deploy the following sample microservice: [go-microservice](https://github.com/photosojourn/go-microservice).

If you need a Docker image for the helm deploy an example can also be found here: [eks-helm-deploy](https://github.com/photosojourn/eks-helm-docker)
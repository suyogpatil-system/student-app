# For pre-requisites run this command
  Using that command following things install:
  1)Maven
  2)Java
  3)Docker
>  make install-all

# Run this command for jar file build and run locally
>  make build

# Run this command for launch application on docker
>  make docker-app-run

# Deploy application using docker-compose
>  make docker-compose-start

# For multi-node kubernetes creation
>  make launch-cluster

# Install kubectl command
>  make install-kubectl

# Deploy application using manifest file
>  make k8s-deployment

# Deploy application using helm
  Using that command following things done:
  1) Install vault
  2) Install External Secret Operator
  3) Fecth secret form vault and store on k8s secret
  4) Deploy database application
  5) Deploy student application
>  make helm-all


# For pre-requisites run this command
  Using that command following things install:
  
  1) Maven
  2) Java
  3) Docker
```
 make install-all
```
# Run this command for jar file build and run locally
>  make build

# Run this command for launch application on docker
  Using that command following things create:
  1) Create network so that launch container inside that network
  2) Launch mysql container
  3) Lanch student-app container
>  make docker-app-run

# Deploy application using docker-compose
>  make docker-compose-start

# Install kubectl command
>  make install-kubectl

# For multi-node kubernetes cluster creation
>  make launch-cluster

# Deploy application on kubernetes using manifest file
  1) Deploy mysql application
  2) Create configmap for to migrate mysql data into student-app
  3) Deploy student-app with init container
>  make k8s-deployment

# Deploy application on kubernetes using helm
  Using that command following things done:
  1) Install vault
  2) Install External Secret Operator
  3) Fecth secret form vault and store on k8s secret
  4) Deploy database application
  5) Deploy student application
>  make helm-all

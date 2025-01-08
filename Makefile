run:
	mvn spring-boot:run

build:
	mvn clean package

test:
	mvn test

docker-app-build:
	#echo "Building Docker image for the Spring Boot application..."
	docker build -t student-app:v1 .

docker-network-create:
	#echo "Creating Docker Private Network..."
	docker network create app-network

docker-db-run:
	#echo "Running MySQL Docker container..."
        docker run --net=app-network -d --name mysql-container   -e MYSQL_ROOT_PASSWORD=rootpassword   -e MYSQL_DATABASE=studentdb   -e MYSQL_USER=studentuser   -e MYSQL_PASSWORD=password   -p 3306:3306   mysql:latest

docker-app-run:
	#echo "Running Spring Boot application in Docker...
        docker run --net=app-network -it -P -e DB_URL=jdbc:mysql://127.0.0.1:3306/studentdb -e DB_USERNAME=studentuser -e DB_PASSWORD=password student-app:v1

docker-compose-start:
	#docker-compose up --build

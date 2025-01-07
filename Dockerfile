# First stage: Build the Spring Boot application with Maven and Java 17
FROM maven:latest as build

# Set the working directory
WORKDIR /app

# Copy pom.xml and the src directory to the container
COPY pom.xml .
COPY src ./src

# Build the Spring Boot application
RUN mvn clean package -DskipTests

# Second stage: Create the runtime image with OpenJDK 17
FROM openjdk:latest as runtime

# Set the working directory
WORKDIR /app

# Copy the built jar from the build stage to the runtime stage
COPY --from=build /app/target/student-api-0.0.1-SNAPSHOT.jar app.jar

# Expose the port (default is 8080, can be overridden with SERVER_PORT env variable)
EXPOSE 8282

# Run the Spring Boot application
ENTRYPOINT ["java -jar /app/app.jar"]


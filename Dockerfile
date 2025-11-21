# ===========================
# 1. BUILD STAGE (Maven)
# ===========================
FROM ubuntu:latest

FROM maven:3.9.6-eclipse-temurin-17 AS build

WORKDIR /app

# Copy pom.xml first (layer caching)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy full project and build
COPY . .
RUN mvn clean package -DskipTests

# ===========================
# 2. RUNTIME STAGE (JDK image)
# ===========================
FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

# Copy only the jar from the build stage
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

# Production entry point
ENTRYPOINT ["java", "-jar", "app.jar"]

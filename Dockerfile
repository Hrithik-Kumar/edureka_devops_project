# Stage 1: Define the runtime environment
# Use an official Tomcat image. Using a specific version is a best practice.
FROM tomcat:9.0-jdk11-temurin

# Set a label for maintainer information (good practice)
LABEL maintainer="Hrithik Kumar Advani"

# Remove the default ROOT webapp that comes with Tomcat
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Copy the .war file from the build context into Tomcat's webapps directory
# We rename it to ROOT.war so it deploys as the default application (at http://host:port/)
# 'target/*.war' is a temporary name; our Jenkinsfile will place the artifact here.
COPY target/XYZtechnologies-1.0.war /usr/local/tomcat/webapps/ROOT.war

# Expose the default Tomcat port
EXPOSE 8080

# The default command from the base image is already 'catalina.sh run',
# so we don't need to specify it again. This keeps the Dockerfile clean.
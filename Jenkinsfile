// Jenkinsfile - Syntactically Correct, Portable, and Self-Contained
pipeline {
    agent any

    tools {
        maven 'maven_3.9.9'
    }

    environment {
        // Define static variables for the whole pipeline
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-credentials'
        DOCKERHUB_USERNAME     = 'kumaradv'
        IMAGE_NAME             = "${env.DOCKERHUB_USERNAME}/xyz-tech-webapp"



    }

    stages {

		stage('Code Checkout') {
            steps {
				echo "Cloning the repository..."
                checkout scm
                echo "Code checked out from main branch."
            }
        }

          stage('Build & Test Application') {
            steps {


                    echo "Compiling, testing, and packaging..."
                    sh 'mvn clean package'

            }
        }

        stage('Build Docker Image') {
            steps {

                    script {
						def imageWithTag = "${env.IMAGE_NAME}:v${env.BUILD_NUMBER}"
                        echo "Building Docker image: ${imageWithTag}"

                        sh "docker buildx create --use || true"
                        sh "docker buildx build --platform linux/amd64 -t ${imageWithTag} --push ."
                        echo "Docker image built and pushed for linux/amd64 platform."
                    }

            }
        }

        stage('Push Docker Image to Hub') {
            steps {


                    script {

							def imageWithTag = "${env.IMAGE_NAME}:v${env.BUILD_NUMBER}"

                        	withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {

								echo "Logging in to Docker Hub..."
								// Use --password-stdin for security, it prevents the password from appearing in process lists
                            	sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'

                            	}

                            echo "Pushing versioned image: ${imageWithTag}"
                            # Already pushed with buildx above

                            echo "Tagging image as 'latest'..."
                            sh "docker tag ${imageWithTag} ${env.IMAGE_NAME}:latest"

                            echo "Pushing 'latest' tag..."
                            sh "docker push ${env.IMAGE_NAME}:latest"

                            // Always logout after push
                            sh "docker logout"
                        }

                }
            }


        stage('Deploy as Container') {

			steps{

				script{
					def containerName="xyz-webapp-container"
					def imageToDeploy="${env.IMAGE_NAME}:v${env.BUILD_NUMBER}"

					echo "Deploying container: ${containerName} from image: ${imageToDeploy}"

					sh "docker stop ${containerName} || true"
                    sh "docker rm ${containerName} || true"

                    echo "Starting new container..."

                    sh "docker run -d -p 8090:8080 --name ${containerName} --pull always ${imageToDeploy}"
                    echo "Deployment successful."
				}
			}

		}
    }

    post {
        success {
            echo "Pipeline finished successfully."
            archiveArtifacts artifacts: 'target/*.war', fingerprint: true
        }
        failure {
            echo "Pipeline failed."
        }
        always {
            echo "Pipeline execution finished."
        }
    }
}

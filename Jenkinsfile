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
                    sh "docker buildx build --platform linux/amd64 -t ${imageWithTag} --load ."
                    echo "Docker image built for linux/amd64 platform and loaded into local Docker daemon."

                    // Clean up old buildkit containers
                    sh "docker ps -a --filter 'ancestor=moby/buildkit:buildx-stable-1' --format '{{.ID}}' | xargs -r docker rm -f || true"
                }
            }
        }


        stage('Push Docker Image to Hub') {
            steps {
                script {
                    def imageWithTag = "${env.IMAGE_NAME}:v${env.BUILD_NUMBER}"
                    withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        echo "Logging in to Docker Hub..."
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    }
                    echo "Pushing versioned image: ${imageWithTag}"
                    sh "docker push ${imageWithTag}"

                    echo "Tagging image as 'latest'..."
                    sh "docker tag ${imageWithTag} ${env.IMAGE_NAME}:latest"

                    echo "Pushing 'latest' tag..."
                    sh "docker push ${env.IMAGE_NAME}:latest"

                    // Always logout after push
                    sh "docker logout"
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    echo "Deploying to AWS EKS cluster using kubectl..."

                    // Update kubeconfig (optional, if not already set)
                    // sh 'aws eks --region us-east-1 update-kubeconfig --name devops-eks-cluster'

                    // Apply Kubernetes manifests
                    sh 'kubectl apply -f k8s/deployment.yaml'
                    sh 'kubectl apply -f k8s/service.yaml'

                    // Wait for pods to be ready
                    sh 'kubectl rollout status deployment/xyz-tech-deployment --timeout=120s'

                    // Show service info
                    sh 'kubectl get svc xyz-tech-service'

                    echo "EKS deployment complete."
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

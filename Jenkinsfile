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
        IMAGE_TAG              = "v${env.BUILD_NUMBER}"

        // Pre-define the required PATH. This makes the pipeline self-documenting.
        REQUIRED_PATH          = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
       
    }

    stages {

        stage('Build Docker Image') {
            steps {
                // Apply the environment wrapper to this specific stage
                    script {
						def imageWithTag = "${env.IMAGE_NAME}:v${env.BUILD_NUMBER}"
                        echo "Building Docker image: ${imageWithTag}"
                        
                        sh "docker build -t ${imageWithTag} ."
                        echo "Docker image built successfully."
                    }
                
            }
        }

        stage('Push Docker Image to Hub') {
            steps {
				
				withEnv(["PATH+EXTRA=${env.REQUIRED_PATH}"]) {
                
                    script {
						
							def imageWithTag = "${env.IMAGE_NAME}:v${env.BUILD_NUMBER}"
						
                        	withDockerRegistry([credentialsId: "${env.DOCKERHUB_CREDENTIALS_ID}", url:"" ]) {
							
							
	                            echo "Pushing versioned image: ${imageWithTag}"
	                        	sh "docker push ${imageWithTag}"
	
	                            echo "Tagging image as 'latest'..."
	                        	sh "docker tag ${imageWithTag} ${env.IMAGE_NAME}:latest"
	                        	
	                        	echo "Pushing 'latest' tag..."
	                        	sh "docker push ${env.IMAGE_NAME}:latest"
                        }
                    }
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
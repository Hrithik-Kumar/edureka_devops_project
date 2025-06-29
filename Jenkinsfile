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
        REQUIRED_PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
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
                // Apply the environment wrapper to this specific stage
                withEnv(["PATH+EXTRA=${env.REQUIRED_PATH}"]) {
                    echo "Compiling, testing, and packaging..."
                    sh 'mvn clean package'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                // Apply the environment wrapper to this specific stage
                withEnv(["PATH+EXTRA=${env.REQUIRED_PATH}"]) {
                    script {
                        echo "Building Docker image: ${env.IMAGE_NAME}"
                        def customImage = docker.build(env.IMAGE_NAME, ".")
                        echo "Docker image built successfully."
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                // Apply the environment wrapper to this specific stage
                withEnv(["PATH+EXTRA=${env.REQUIRED_PATH}"]) {
                    script {
                        docker.withRegistry('https://index.docker.io/v1/', env.DOCKERHUB_CREDENTIALS_ID) {
                            echo "Pushing versioned image: ${env.IMAGE_NAME}:${env.IMAGE_TAG}"
                            docker.image(env.IMAGE_NAME).push(env.IMAGE_TAG)

                            echo "Pushing 'latest' tag..."
                            docker.image(env.IMAGE_NAME).push('latest')
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
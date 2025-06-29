// Jenkinsfile - Final, Portable, and Self-Contained Version
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
        // NOTE: Jenkins automatically prepends the paths for the configured JDK and Maven tools to this.
        REQUIRED_PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    }

    triggers {
        cron('H 2 * * *')
    }

    stages {
        // Wrap all execution stages in a withEnv block to ensure the PATH is correct
        stage('Main Execution') {
            steps {
                withEnv(["PATH+MAVEN=${tool 'maven_3.9.9'}/bin", "PATH+EXTRA=${env.REQUIRED_PATH}"]) {
                    // --- All subsequent stages will now run inside this block ---

                
                    stage('Code Checkout') {
                        checkout scm
                        echo "Code checked out from main branch."
                    }

                    stage('Build & Test Application') {
                        sh 'mvn clean package'
                        echo "Application packaged successfully."
                    }

                    stage('Build Docker Image') {
                        script {
                            echo "Building Docker image: ${env.IMAGE_NAME}"
                            def customImage = docker.build(env.IMAGE_NAME, ".")
                            echo "Docker image built successfully."
                        }
                    }

                    stage('Push Docker Image') {
                        script {
                            docker.withRegistry('https://index.docker.io/v1/', env.DOCKERHUB_CREDENTIALS_ID) {
                                echo "Pushing versioned image: ${env.IMAGE_NAME}:${env.IMAGE_TAG}"
                                docker.image(env.IMAGE_NAME).push(env.IMAGE_TAG)

                                echo "Pushing 'latest' tag..."
                                docker.image(env.IMAGE_NAME).push('latest')
                            }
                        }
                    }
                } // --- End of withEnv block ---
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
    }
}
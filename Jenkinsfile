pipeline {
    agent any
   	
   	tools {
        maven 'maven_3.9.9'
    	}
    	
    // Define environment variables used throughout the pipeline
    environment {
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-credentials'
        DOCKERHUB_USERNAME     = 'kumaradv' // Your Docker Hub username
        IMAGE_NAME             = "${env.DOCKERHUB_USERNAME}/xyz-tech-webapp"
        IMAGE_TAG              = "v${env.BUILD_NUMBER}"
        
        REQUIRED_PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    }
    	
    	
    triggers {
        // Build periodically (daily at 2 AM)
        cron('H 2 * * *')
    }
    
    
    
    stages {
		
		stage('Main Execution'){
			
			steps {
				withEnv(["PATH+MAVEN=${tool 'maven_3.9.9'}/bin","PATH+EXTRA=${env.REQUIRED_PATH}"]) {
			
		
	        stage('Code Checkout') {
	            steps {     
	                echo "Cloning the repository..."
	                checkout scm
	                echo "Code checked out from main branch"
	                                    
	            }
	        }
	        
	        stage('Code Compile') {
	            steps {
	                    echo "Compiling the application..."                       	    
	                    sh 'mvn clean compile'                             
	            }
	        }
	        
	        
	        stage('Unit Test') {
	            steps {         
	                    echo "Running unit tests..."
	                    sh 'mvn test'          
	            }
	       }
	           
	        
	        stage('Code Packaging') {
	            steps {
	                
	                    echo "Packaging the application..."
	                    sh 'mvn package'
	                
	            }
	       
	        }
	        
	        stage('Build Docker Image') {
	            steps {
	                script {
	                    echo "Building Docker image: ${env.IMAGE_NAME}:${env.IMAGE_TAG}"
	                    def customImage = docker.build("${env.IMAGE_NAME}:${env.IMAGE_TAG}", ".")
	                    echo "Docker image built successfully: ${env.IMAGE_NAME}:${env.IMAGE_TAG}"
	                }
	            }
	        }
	        
	        stage('Push Docker Image') {
	            steps {
	                script {
	                    docker.withRegistry('https://index.docker.io/v1/', env.DOCKERHUB_CREDENTIALS_ID) {
	                        echo "Pushing versioned image: ${env.IMAGE_NAME}:${env.IMAGE_TAG}"
	                        def customImage = docker.image("${env.IMAGE_NAME}:${env.IMAGE_TAG}")
	                        
	                        // Push the versioned tag
	                        customImage.push()
	                        
	                        // Push the same image with 'latest' tag
	                        customImage.push('latest')
	                        
	                        echo "Successfully pushed both ${env.IMAGE_NAME}:${env.IMAGE_TAG} and ${env.IMAGE_NAME}:latest"
	                    }
	                }
	            }
	        }
	    }
	    }
	    }
	    }
	    
    post {
			success{
				echo "Pipeline finished successfully. Artifacts archived and image pushed."
            	archiveArtifacts artifacts: 'target/*.war', fingerprint: true
			}
			
			failure {
				echo "Pipeline failed. Check the console output for errors."
			}
			
		always {
				echo "Pipeline execution Finished"
			}
		}
}

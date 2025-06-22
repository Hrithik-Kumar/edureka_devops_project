pipeline {
    agent any
    
    tools {
        maven 'maven_3.9.9' // Make sure this matches your Jenkins Maven installation name
        jdk 'jdk11'          // Make sure this matches your Jenkins JDK installation name
    }
    
    
    triggers {
        // Build periodically (daily at 2 AM)
        cron('H 2 * * *')
    }
    
    stages {
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
       
            post {
                success {
                    // Archive the WAR file
                    echo "Pipeline finished successfully. Archiving artifacts..."
                    archiveArtifacts artifacts: 'target/*.war', fingerprint: true
                }
                
                failure {
					 echo "Pipeline failed. Check the console output for errors."
				}
				
				 always {
            		 echo "Pipeline execution finished."
       			}
            }
        }
        
        }    
        

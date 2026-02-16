pipeline {
    agent any

    parameters {
        booleanParam(name: 'RELEASE', defaultValue: false, description: 'Check to make a release build')
    }

    environment {
        // Optimization: Enable modern BuildKit engine for faster caching
        DOCKER_BUILDKIT = '1'
        IMAGE_NAME = 'c-gcc-demo'
        // Optimization: Determine binary name once to remove repetitive if/else blocks
        BINARY_NAME = "${params.RELEASE ? 'app_release' : 'app_linux'}"
    }

    stages {
        stage('Initialize') {
            steps {
                script {
                    echo "Starting Econolite Build for ${BINARY_NAME}..."
                    // Optimization: Capture Git version once to reuse in build
                    env.GIT_VER = sh(script: 'git describe --tags --dirty --always', returnStdout: true).trim()
                }
                sh 'docker version' 
            }
        }
        
        stage('Checkout Source') {
            steps {
                checkout scm
            }
        }
        
        stage('Build Docker') {
            parallel {
                stage('Build Image') {
                    steps {
                        // Optimization: Simplified build command using environment variables
                        sh """
                            docker build -t ${IMAGE_NAME} \
                            --build-arg RELEASE=${params.RELEASE} \
                            --build-arg GIT_VERSION=${env.GIT_VER} .
                        """
                    }
                }
                
                stage('Health Check') {
                    steps {
                        echo "System status check..."
                        sh 'docker info | grep "Kernel Version"' 
                    }
                }
            }
        }
        
        stage('Verify') {
            steps {
                sh "docker images | grep ${IMAGE_NAME}" 
            }
        }
        
        stage('Run & Deploy') {
            steps {
                echo "Running build test for: ${BINARY_NAME}"
                sh "docker run --rm ${IMAGE_NAME} 'Testing ${BINARY_NAME} build'"

                script {
                    echo "Deploying ${BINARY_NAME} to remote target..."
                    
                    // Optimization: Clean, Create, and Copy using variables
                    sh """
                        docker rm -f tmp_app || true
                        docker create --name tmp_app ${IMAGE_NAME}
                        docker cp tmp_app:/app/repos/${BINARY_NAME} /tmp/${BINARY_NAME}
                        docker rm tmp_app
                        
                        sshpass -p 'MyLabPass123!' scp -o StrictHostKeyChecking=no \
                        /tmp/${BINARY_NAME} labadmin@192.168.86.229:C:/wipro/
                    """
                }
            }    
        }
    }

    post {
        always {
            // Optimization: Clean up local temp files and workspace
            sh "rm -f /tmp/${BINARY_NAME} || true"
            cleanWs()
        }
        success {
            echo "Build and Deployment of ${BINARY_NAME} successful."
        }
    }
}
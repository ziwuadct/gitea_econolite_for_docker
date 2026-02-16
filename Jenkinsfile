pipeline {
    agent any

    parameters {
        // This creates the RELEASE toggle
        booleanParam(name: 'RELEASE', defaultValue: false, description: 'Check to make a release build')
    }

    stages {
        stage('Initialize') {
            steps {
                echo 'Starting Econolite Build...'
                sh 'docker version' 
            }
        }
        
        stage('Checkout Source') {
            steps {
                // This automatically uses the URL and credentials defined in the Jenkins Job settings
                checkout scm
            }
        }
      
//        stage('Checkout Source') {
//                    steps {
//                        checkout([$class: 'GitSCM', 
//                           branches: [[name: '*/main']], // Check for the double ]] here
//                            userRemoteConfigs: [[
//                                url: 'http://192.168.86.229:3000/david/gitea_econolite_for_docker.git', 
//                                credentialsId: 'gitea_david_password'
//                            ]]
//                        ])
//                    }
//                }
                
                
        
        stage('build docker') {
            parallel {
                stage('Build Docker Image linux + release') {
                    steps {
                        script {
                            // Builds the Dockerfile using shell commands [cite: 6, 7]
                            if (params.RELEASE) {
                                sh "docker build -t c-gcc-demo --build-arg RELEASE=${params.RELEASE} --build-arg GIT_VERSION=\$(git describe --tags --dirty --always) ."
                            } else {
                                sh "docker build -t c-gcc-demo --build-arg RELEASE=${params.RELEASE} --build-arg GIT_VERSION=\$(git describe --tags --dirty --always) ."
                            }
                        }
                    }
                }
                
                stage('Health Check') {
                    steps {
                        echo "Checking system status while building..."
                        sh 'docker version' 
                    }
                }
            }
        }
        
        stage('Verify') {
            steps {
                // 'grep' replaces the Windows 'findstr' command 
                sh 'docker images | grep c-gcc-demo' 
            }
        }
        
        stage('run build') {
            steps {
                echo "-----11--Is this a release build: ${params.RELEASE}"
                script {
                    if (params.RELEASE) {
                        sh 'docker run --rm c-gcc-demo "This is release build"'
                    } else {
                        sh 'docker run --rm c-gcc-demo "This is a linux build"'
                    }
                }
            }
        }
        
        stage('Deploy PPC Binary') {
            steps {
                echo "-------22-------------"
                sh 'docker rm -f tmp_app || true' 
                echo "-------33-------------"
                sh 'docker create --name tmp_app c-gcc-demo'
                echo "-------44-------------"
                echo "DEBUG: Checking file list inside container..."
                sh 'docker run c-gcc-demo ls -al /app/repos'

                script {
                    // Use /tmp (Linux) instead of c:/temp (Windows) 
                    // Use 'sshpass' and 'scp' instead of 'pscp' 
                    if (params.RELEASE) {
                        echo "-------55-------------docker cp tmp_app:/app/repos/app_release /tmp"
                        sh 'docker cp tmp_app:/app/repos/app_release /tmp/app_release' 
                        echo "-----------scp /tmp/app_release to remote"
                        sh 'sshpass -p "MyLabPass123!" scp -o StrictHostKeyChecking=no /tmp/app_release labadmin@192.168.86.229:C:/wipro/' 
                    } else {
                        echo "--------66------------docker cp tmp_app:/app/repos/app_linux /tmp"
                        sh 'docker cp tmp_app:/app/repos/app_linux /tmp/app_linux' 
                        echo "--------77-------scp /tmp/app_linux to remote"
                        sh 'sshpass -p "MyLabPass123!" scp -o StrictHostKeyChecking=no /tmp/app_linux labadmin@192.168.86.229:C:/wipro/' 
                    }
                }
            }    
        }
    }
}
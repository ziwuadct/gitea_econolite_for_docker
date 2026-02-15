pipeline {
    agent any

    parameters {
        // This creates the RELEASE toggle [cite: 1]
        booleanParam(name: 'RELEASE', defaultValue: false, description: 'Check to make a release build') [cite: 1]
    }

    stages {
        stage('Initialize') {
            steps {
                echo 'Starting Econolite Build...' [cite: 2]
                sh 'docker version' 
            }
        }
        
        stage('Checkout Source') {
            steps {
                // This pulls the code from your Gitea repo [cite: 3]
                checkout([$class: 'GitSCM', 
                    branches: [[name: '*/main']], [cite: 3]
                    userRemoteConfigs: [[
                        url: 'http://192.168.86.229:3000/david/gitea_econolite.git', [cite: 3]
                        credentialsId: 'gitea_david_password' [cite: 4]
                    ]]
                ])
            }
        }   
        
        stage('build docker') {
            parallel {
                stage('Build Docker Image linux + release') {
                    steps {
                        script {
                            // Builds the Dockerfile using shell commands [cite: 6, 7]
                            if (params.RELEASE) { [cite: 7]
                                sh "docker build -t c-gcc-demo --build-arg RELEASE=${params.RELEASE} --build-arg GIT_VERSION=\$(git describe --tags --dirty --always) ." [cite: 7]
                            } else { [cite: 8]
                                sh "docker build -t c-gcc-demo --build-arg RELEASE=${params.RELEASE} --build-arg GIT_VERSION=\$(git describe --tags --dirty --always) ." [cite: 8]
                            }
                        }
                    }
                }
                
                stage('Health Check') {
                    steps {
                        echo "Checking system status while building..." [cite: 10]
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
                echo "-----11--Is this a release build: ${params.RELEASE}" [cite: 13]
                script {
                    if (params.RELEASE) { [cite: 14]
                        sh 'docker run --rm c-gcc-demo "This is release build"' [cite: 14]
                    } else { [cite: 15]
                        sh 'docker run --rm c-gcc-demo "This is a linux build"' [cite: 15]
                    }
                }
            }
        }
        
        stage('Deploy PPC Binary') {
            steps {
                echo "-------22-------------" [cite: 16]
                sh 'docker rm -f tmp_app || true' 
                echo "-------33-------------" [cite: 16]
                sh 'docker create --name tmp_app c-gcc-demo' [cite: 16]
                echo "-------44-------------" [cite: 17]
                echo "DEBUG: Checking file list inside container..." [cite: 17]
                sh 'docker run c-gcc-demo ls -al /app/repos' [cite: 17]

                script {
                    // Use /tmp (Linux) instead of c:/temp (Windows) 
                    // Use 'sshpass' and 'scp' instead of 'pscp' 
                    if (params.RELEASE) { [cite: 18]
                        echo "-------55-------------docker cp tmp_app:/app/repos/app_release /tmp" [cite: 18]
                        sh 'docker cp tmp_app:/app/repos/app_release /tmp/app_release' 
                        echo "-----------scp /tmp/app_release to remote" [cite: 18]
                        sh 'sshpass -p "MyLabPass123!" scp -o StrictHostKeyChecking=no /tmp/app_release labadmin@192.168.86.229:C:/wipro/' 
                    } else { [cite: 19]
                        echo "--------66------------docker cp tmp_app:/app/repos/app_linux /tmp" [cite: 19]
                        sh 'docker cp tmp_app:/app/repos/app_linux /tmp/app_linux' 
                        echo "--------77-------scp /tmp/app_linux to remote" [cite: 20]
                        sh 'sshpass -p "MyLabPass123!" scp -o StrictHostKeyChecking=no /tmp/app_linux labadmin@192.168.86.229:C:/wipro/' 
                    }
                }
            }    
        }
    }
}
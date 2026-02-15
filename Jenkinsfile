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
                powershell 'docker version'
            }
        }
        
        stage('Checkout Source') {
            steps {
                // This pulls the code from your GitHub repo using the token
                checkout([$class: 'GitSCM', 
                    branches: [[name: '*/main']], 
                    userRemoteConfigs: [[
                        url: 'http://192.168.86.229:3000/david/gitea_econolite.git', 
//                        credentialsId: 'econolite-github-token' // Must match the ID from Step 1
                        credentialsId: 'gitea_david_password' // Must match the ID from Step 1
                    ]]
                ])
            }
        }   
        
        stage('build docker') {
        
            parallel {
                stage('Build Docker Image linux + release') {
                    steps {
                        // This builds your main Dockerfile
                
                        script {
                            if (params.RELEASE) {
                                // If the checkbox was checked
                                powershell "docker build -t c-gcc-demo --build-arg RELEASE=${params.RELEASE} --build-arg GIT_VERSION=\$(git describe --tags --dirty --always) ."
                            } else {
                                // If the checkbox was NOT checked
                                powershell "docker build -t c-gcc-demo --build-arg RELEASE=${params.RELEASE} --build-arg GIT_VERSION=\$(git describe --tags --dirty --always) ."
                            }
                        }
                        
                    }
                }
                
                stage('Health Check') {
                    steps {
                        echo "Checking system status while building..."
                        powershell 'docker version'
                    }
                }
            }
        }
        
        stage('Verify') {
            steps {
                powershell 'docker images | findstr c-gcc-demo'
            }
        }
        
        stage('run build') {
            steps {
//                powershell 'docker run --rm c-gcc-demo This is a test'
                
                echo "-------Is this a release build: ${params.RELEASE}"
                
                script {
                    if (params.RELEASE) {
                        // If the checkbox was checked
                        powershell 'docker run --rm c-gcc-demo "This is release build"'
                    } else {
                        // If the checkbox was NOT checked
                        powershell 'docker run --rm c-gcc-demo "This is a linux build"'
                    }
                }
            }
        }
        
        stage('Deploy PPC Binary') {
            steps {
            
                powershell '''
                if (docker ps -a --format '{{.Names}}' | findstr "tmp_app") 
                {
                    docker rm -f tmp_app
                }
                '''
                
                powershell 'docker create --name tmp_app c-gcc-demo'

                script {
                    // Check if the RELEASE parameter is true
                    if (params.RELEASE) {
                        echo "--------------------docker cp tmp_app:/app/repos/app_release c:/temp"
                        powershell 'docker cp tmp_app:/app/repos/app_release c:/temp'
                        echo "-----------pscp -batch -hostkey c:\\temp\\app_release"
                        powershell 'pscp -batch -hostkey "SHA256:MremSl0rKC8Ae92G8DNXIvGVEVGPuaaeDn52/W21bUo" -pw MyLabPass123! c:\\temp\\app_release labadmin@192.168.86.229:C:\\wipro\\'
                    } else {
                        echo "--------------------docker cp tmp_app:/app/repos/app_linux c:/temp"
                        powershell 'docker cp tmp_app:/app/repos/app_linux c:/temp'
                        echo "-----------pscp -batch -hostkey c:\\temp\\app_linux"
                        powershell 'pscp -batch -hostkey "SHA256:MremSl0rKC8Ae92G8DNXIvGVEVGPuaaeDn52/W21bUo" -pw MyLabPass123! c:\\temp\\app_linux labadmin@192.168.86.229:C:\\wipro\\'
                    }
                }
            }    

        }

    }
}
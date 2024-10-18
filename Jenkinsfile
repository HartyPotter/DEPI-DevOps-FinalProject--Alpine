pipeline {
    agent any
    
    environment {
        DOCKER_HUB_CREDS = credentials('DOCKER_HUB_CREDS')
        APP_NAME = "node-app"
        APP_PORT = 9090
    }

    stages {
        stage('Building a docker image') {
            steps {
                script {
                    echo "Buidling the image...."
                    sh 'docker build . -t node-app'
                }
            }
        }

        stage('Pushing to Docker Hub') {
            steps {
                script {
                    echo 'Pushing to Docker Hub...'
                        sh 'echo ${DOCKER_HUB_CREDS_PSW} | docker login -u ${DOCKER_HUB_CREDS_USR} --password-stdin docker.io; docker tag ${APP_NAME}:latest ${DOCKER_HUB_CREDS_USR}/${APP_NAME}:latest; docker push ${DOCKER_HUB_CREDS_USR}/${APP_NAME}:latest'
                    }
                }
            }
         

        stage('Pull image on agent') {
            agent {
                label 'docker-agent'
            }
            steps {
                script {
                    echo 'Pulling docker image on another agent...'
                    sh 'docker pull ${DOCKER_HUB_CREDS_USR}/${APP_NAME}:latest'
                }
            }
        }

        stage('Run docker image') {
            agent {
                label 'docker-agent'
            }
            steps {
                script {
                    echo 'Running Docker container...'
                    sh 'docker run --rm -d --name ${APP_NAME} -p ${APP_PORT}:${APP_PORT} ${DOCKER_HUB_CREDS_USR}/${APP_NAME}:latest'
                }
            }
        }

        stage('Check connection') {
            // agent {
            //     label 'docker-agent'
            // }
            steps {
                script {
                    echo 'Checking connectivity using curl...'
                    sh 'sleep 10; curl --fail http://localhost:${APP_PORT} || exit 1'
                }
            }
        }
    }
}

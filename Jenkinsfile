pipeline {
    agent any
    
    environment {
        DOCKER-HUB-CREDS = credentials('DOCKER-HUB-CREDS')
        // DOCKER_HUB_USERNAME = "joebeanzz123"
        // DOCKER_HUB_PASS = "fightitasdf@1234"
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
                        sh 'echo ${DOCKER-HUB-CREDS_PSW} | docker login -u ${DOCKER-HUB-CREDS_USR} --password-stdin docker.io; docker tag ${APP_NAME}:latest ${DOCKER-HUB-CREDS_USR}/${APP_NAME}:latest; docker push ${DOCKER-HUB-CREDS_USR}/${APP_NAME}:latest'
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
                    sh 'docker pull ${DOCKER_HUB_USERNAME}/${APP_NAME}:latest'
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
                    sh 'docker run --rm -d --name ${APP_NAME} -p ${APP_PORT}:${APP_PORT} ${DOCKER_HUB_USERNAME}/${APP_NAME}:latest'
                }
            }
        }

        stage('Check connection') {
            agent {
                label 'docker-agent'
            }
            steps {
                script {
                    echo 'Checking connectivity using curl...'
                    sh 'sleep 10; curl --fail http://localhost:${APP_PORT} || exit 1'
                }
            }
        }
    }
}

pipeline {
    agent any
    
    environment {
        DOCKER_HUB_USERNAME = "joebeanzz123"
        DOCKER_HUB_PASS = "fightitasdf@1234"
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
                    // withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh 'echo ${DOCKER_HUB_PASS} | docker login -u ${DOCKER_HUB_USERNAME} --password-stdin docker.io; docker tag ${APP_NAME}:latest ${DOCKER_HUB_USERNAME}/${APP_NAME}:latest; docker push ${DOCKER_HUB_USERNAME}/${APP_NAME}:latest'
                    }
                }
            }
         

        stage('Pull image on agent') {
            agent {
                label 'remote-agent'
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
                label 'remote-agent'
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
                label 'remote-agent'
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

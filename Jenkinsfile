pipeline {
    agent any

    environment {
        REGION = "us-east-1"
        REPOSITORY_URI = "779846799257.dkr.ecr.us-east-1.amazonaws.com/react-app-repo"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/<your-username>/<your-repo>.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t $REPOSITORY_URI:$IMAGE_TAG .
                docker tag $REPOSITORY_URI:$IMAGE_TAG $REPOSITORY_URI:latest
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                sh """
                aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $REPOSITORY_URI
                docker push $REPOSITORY_URI:$IMAGE_TAG
                docker push $REPOSITORY_URI:latest
                """
            }
        }

        stage('Deploy via Ansible') {
            steps {
                sh 'ansible-playbook -i ansible/inventory ansible/deploy.yml'
            }
        }
    }
}
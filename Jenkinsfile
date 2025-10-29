pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '779846799257'
        REPO_NAME = 'react-app-repo'
        BUILD_TAG = "${env.BUILD_NUMBER}"
        IMAGE_LATEST = "latest"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh '''
                    echo "Building Docker image using local Dockerfile..."
                    docker build -t $REPO_NAME:$BUILD_TAG -t $REPO_NAME:$IMAGE_LATEST -f Dockerfile .
                    '''
                }
            }
        }

        stage('Login to ECR') {
            steps {
                script {
                    sh '''
                    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                    '''
                }
            }
        }

        stage('Tag & Push Image') {
            steps {
                script {
                    sh '''
                    docker tag $REPO_NAME:$BUILD_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$BUILD_TAG
                    docker tag $REPO_NAME:$IMAGE_LATEST $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$IMAGE_LATEST

                    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$BUILD_TAG
                    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$IMAGE_LATEST
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline execution completed! Image tags pushed: $BUILD_TAG and latest"
        }
    }
}

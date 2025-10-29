pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '779846799257'
        REPO_NAME = 'react-app-repo'
        IMAGE_TAG = "latest"
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
                    // Use Jenkins BUILD_ID as a unique tag and disable cache
                    def uniqueTag = "${BUILD_ID}"

                    sh '''
                    echo "Building Docker image without cache..."
                    docker build --no-cache -t $REPO_NAME:${BUILD_ID} -t $REPO_NAME:$IMAGE_TAG -f Dockerfile .
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
                    echo "Tagging and pushing image to ECR..."
                    docker tag $REPO_NAME:${BUILD_ID} $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:${BUILD_ID}
                    docker tag $REPO_NAME:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$IMAGE_TAG

                    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:${BUILD_ID}
                    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$IMAGE_TAG
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline execution completed!"
            echo "✅ Image pushed to ECR with tags: ${BUILD_ID} and latest"
        }
    }
}

pipeline {
    agent any
    
    stages {
        stage('Install sam-cli') {
            steps {
                sh 'python3 -m venv venv && venv/bin/pip install aws-sam-cli'
                stash includes: '**/venv/**/*', name: 'venv'
            }
        }
        stage('Build and Package') {
            steps {
                unstash 'venv'
                sh 'venv/bin/sam build'
                stash includes: '**/.aws-sam/**/*', name: 'aws-sam'
            }
        }
        
        stage('Run Tests') {
            environment {
                STACK_NAME = 'sam-app-beta-stage'
                S3_BUCKET = 'sam-jenkins-test-cradlewise'
            }
            steps {
                withAWS(credentials: 'Main', region: 'ap-south-1') {
                    unstash 'venv'
                    unstash 'aws-sam'
                    sh 'venv/bin/sam deploy --stack-name $STACK_NAME -t template.yaml --s3-bucket $S3_BUCKET --capabilities CAPABILITY_IAM'
                    dir ('aws-sam') {
                        sh 'python -m unittest python/test_lambda_handler.py'
                    }
                }
            }
        }
        
        stage('Deploy to Dev') {
            environment {
                STACK_NAME = 'sam-app-dev-stage'
                S3_BUCKET = 'sam-jenkins-dev-cradlewise'
            }
            steps {
                withAWS(credentials: 'Main', region: 'ap-south-1') {
                    unstash 'venv'
                    unstash 'aws-sam'
                    sh 'venv/bin/sam deploy --stack-name $STACK_NAME -t template.yaml --s3-bucket $S3_BUCKET --capabilities CAPABILITY_IAM'
                }
            }
        }
    }
}

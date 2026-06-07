properties(
    [
        githubProjectProperty(
            displayName: 'hassio-image-databasus',
            projectUrlStr: 'https://github.com/ruepp-jenkins/hassio-image-databasus'
        ),
        disableConcurrentBuilds()
    ]
)

pipeline {
    agent {
        label 'docker'
    }

    environment {
        IMAGE_FULLNAME = 'ruepp/hassio-image-databasus'
        DOCKER_API_PASSWORD = credentials('DOCKER_API_PASSWORD')
    }

    triggers {
        cron('H/30 * * * *')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: env.BRANCH_NAME,
                url: 'git@github.com:ruepp-jenkins/hassio-image-databasus.git',
                credentialsId: 'github.com-ssh'
            }
        }
        stage('Build') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'github.com-ssh', keyFileVariable: 'SSH_KEY_FILE')]) {
                    withEnv(['GIT_SSH_COMMAND=ssh -i $SSH_KEY_FILE -o StrictHostKeyChecking=no']) {
                        sh 'chmod +x scripts/*.sh'
                        sh './scripts/start.sh'
                    }
                }
            }
        }
    }

    post {
        always {
            discordSend result: currentBuild.currentResult,
                description: env.GIT_URL,
                link: env.BUILD_URL,
                title: JOB_NAME,
                webhookURL: DISCORD_WEBHOOK
            script {
                try {
                } catch (e) {
                    echo "Workspace cleanup skipped: no workspace was allocated"
                }
            }
        }
    }
}

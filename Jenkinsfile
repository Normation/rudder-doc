@Library('slack-notification')
import org.gradiant.jenkins.slack.SlackNotifier

// uid of the jenkins user of the docker runners
def user_id = "1007"

pipeline {
    agent none

    stages {
        stage('Tests') {
            parallel {
                stage('typos') {
                    agent { label 'script' }
                    steps {
                        sh script: 'typos --exclude "*.svg" --exclude "rudder-theme"', label: 'check typos'
                    }
                    post {
                        always {
                            script {
                                new SlackNotifier().notifyResult("docs-team")
                            }
                        }
                    }
                }
                stage('docs') {
                    agent {
                        dockerfile {
                            filename 'Dockerfile'
                            additionalBuildArgs  '--build-arg USER_ID='+user_id
                        }
                    }
                    steps {
                        sh script: 'make site', label: 'build docs'
                    }
                    post {
                        always {
                            script {
                                new SlackNotifier().notifyResult("docs-team")
                            }
                        }
                    }
                }
            }
        }
    }
}

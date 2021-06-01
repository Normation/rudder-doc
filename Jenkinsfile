@Library('slack-notification')
import org.gradiant.jenkins.slack.SlackNotifier

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
            }
        }
    }
}

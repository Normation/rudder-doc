@Library('slack-notification')
import org.gradiant.jenkins.slack.SlackNotifier

pipeline {
    agent none

    stages {
        stage('Tests') {
            parallel {
                stage('typos') {
                    agent {
                        dockerfile {
                            label 'generic-docker'
                            additionalBuildArgs '-f https://raw.githubusercontent.com/Normation/rudder-tools/refs/heads/master/ci/typos.Dockerfile'
                            args '-u 0:0'
                        }
                    }
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

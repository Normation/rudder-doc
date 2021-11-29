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
                stage('docs') {
                    agent {
                        dockerfile {
                            filename 'Dockerfile'
                            additionalBuildArgs "--build-arg USER_ID=${env.JENKINS_UID}"
                        }
                    }
                    steps {
                        sh script: 'make site-local', label: 'build docs'
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

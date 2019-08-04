pipeline {
    agent { label 'windows' }
    stages {
        stage('Configure') {
            steps {
                dir('build') {
                    bat 'cmake ..'
                }
            }
        }
        stage('Build') {
            steps {
                dir('build') {
                    bat 'cmake --build .'
                }
            }
        }
        stage('Test') {
            steps {
                dir('build') {
                    bat 'ctest -C Debug'
                    junit 'reports/**_report*.xml'
                }
            }
        }
    }
}

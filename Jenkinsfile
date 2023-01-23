pipeline {
    agent any
    stages {
        stage('mvn build') {
            steps {
                sh 'mvn -B -DskipTest clean package'
            }
        }
        stage('mvn test') {
            steps {
                sh 'mvn test'
                junit 'target/surefire-reports/*.xml'
            }
        }
        stage('checkstyle') {
            steps {
                sh 'mvn checkstyle:checkstyle'
                recordIssues(tools: [checkStyle(pattern: '**/checkstyle-result.xml')])
            }
        }
        stage('code coverage') {
            steps {
                jacoco()
            }
        }
        stage("Sonar Testing"){
            steps{
                withSonarQubeEnv('sonarqube-9') {
                sh ' mvn clean verify sonar:sonar -Dsonar.projectKey=testapp'
              }
            }
        }
        stage("Quality gate") {
            steps {
              retry (5) {
                timeout(time: 30, unit: 'SECONDS') {
                    waitForQualityGate abortPipeline: true
                }
              }
            }
        }
        stage("Upload To Nexus"){
            steps{
                script {
                 pom = readMavenPom file: "pom.xml";
                filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                    echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                    artifactPath = filesByGlob[0].path;
                    }  
                nexusArtifactUploader artifacts: [[artifactId:pom.artifactId, classifier: '', file: artifactPath, type: pom.packaging]], credentialsId: 'nexus-cred', groupId: pom.artifactId, nexusUrl: '170.187.252.6:8081', nexusVersion: 'nexus3', protocol: 'http', repository: 'maven-snapshots', version: pom.version
            }
        }
        stage('acr login'){
            steps{
                sh 'az acr login --name capstoneprojectdemoacr'
            }
        }
        stage('docker build') {
            steps {
                sh 'docker build -t capstoneprojectdemoacr.azurecr.io/chatapp:latest .'
            }
        }
        stage('Scan Image'){
            steps{
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh 'docker scan --accept-license --severity low capstoneprojectdemoacr.azurecr.io/chatapp:latest'
                }
            }
        }
        stage('docker push') {
            steps {
                sh 'docker push capstoneprojectdemoacr.azurecr.io/chatapp:latest'
            }
        }
    }
}

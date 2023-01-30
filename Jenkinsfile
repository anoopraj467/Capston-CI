pipeline {
    agent any
    tools{
        maven "maven3"
    }

    stages {
        stage('Poll SCM') {
            steps {
              git credentialsId: 'git-token', url: 'git@github.com:anoopraj467/Capston-CI.git'
            }
        }
        stage('mvn build'){
            steps{
                sh 'mvn -B -DskipTest clean package'
            }
        }
        stage('mvn test'){
            steps{
                sh 'mvn test'
                junit 'target/surefire-reports/*.xml'
            }
        }
        stage('CheckStyle'){
            steps{
                sh 'mvn checkstyle:checkstyle'
                recordIssues(tools: [checkStyle(pattern: '**/checkstyle-result.xml')])
            }
        }
        stage('Code Coverage'){
            steps{
                jacoco()
            }
        }
        stage('SonarQube Analysis'){
            steps{
                script{
                withSonarQubeEnv(credentialsId: 'sonarqube-token') {
                    sh 'mvn clean package sonar:sonar'
                    }
                }
            }
        }
        stage('Quality Gate Status'){
            steps{
                script{
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonarqube-token'
                }
            }
        }
        stage('Nexus'){
            steps{
            script{
                pom = readMavenPom file: "pom.xml";
                filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                    echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                    artifactPath = filesByGlob[0].path;
            }
                nexusArtifactUploader artifacts: [[artifactId: 'websocket-demo', classifier: '', file: 'target/websocket-demo-0.0.1-SNAPSHOT.jar', type: 'jar']], credentialsId: 'nexus-cred', groupId: 'demo', nexusUrl: '4.246.148.46:8081', nexusVersion: 'nexus3', protocol: 'http', repository: 'maven-snapshots', version: '0.0.1-SNAPSHOT'
            }
        }
        stage('Login to ACR'){
            steps{
                sh 'az acr login --name capstonacr'
            }
        }
        stage('Build Docker Image'){
            steps{
                sh ' docker build -t capstonacr.azurecr.io/chatapp:latest .'
            }
        }
        stage('Push to ACR'){
            steps{
                sh 'docker push capstonacr.azurecr.io/chatapp:latest'
            }
        }
        // stage('Configure Http-Routing'){
        //     steps{
        //         sh 'az aks enable-addons --resource-group capston-res --name capston-aks --addons http_application_routing'
        //     }
        // }
        
        
        // stage('Kubernetes'){
        //     steps{
        //         withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'K8S', namespace: '', restrictKubeConfigAccess: false, serverUrl: '') {
        //               sh "kubectl apply -f deploy1.yml"
        //         }
        //     }
        // }
        
        // stage("Clean up"){
        //     steps{
        //         sh 'rm /var/lib/jenkins/.kube/config'
        //     }
        // }
        
        // stage('Kubernetes'){
        //     steps{
        //         sh 'kubectl apply -f deploy1.yml'
        //     }
        // }

    }
}

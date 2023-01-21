pipeline{
    agent any
     stages{
//         stage("poll scm"){
//             steps{
//                git credentialsId: 'git-key', url: 'git@github.com:shubhamghavas/chat-app-sapient.git'
//             }
//         }
        stage("mvn Build"){
            steps{
                 sh 'mvn -B -Dmaven.test.skip=true -DskipTests  clean package'
            }
        }
        stage("Testing"){
          steps{
              sh 'mvn test'
                 junit 'target/surefire-reports/*.xml'
              sh 'mvn checkstyle:checkstyle'
                recordIssues(tools: [checkStyle(pattern: '**/checkstyle-result.xml')])
              jacoco()    
          }
        }
        stage("Sonar Testing"){
            steps{
                withSonarQubeEnv('sonarqube-9') {
                sh ' mvn clean verify sonar:sonar -Dsonar.projectKey=sapient-chat-app'
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
        stage('docker build') {
            steps {
                  script {
              app = sh 'mvn compile jib:dockerBuild'
                }
            }
        }
         stage('docker push') {
            steps {
                script {
                    // This step should not normally be used in your script. Consult the inline help for details.
                       withDockerRegistry(credentialsId: 'nexus-cred', url: 'http://170.187.252.6:8085') {
                         // some block
                        sh 'mvn compile jib:build -Djib.allowInsecureRegistries=true -DsendCredentialsOverHttp'


                       }
                  
                }
            }
        }
     }
}

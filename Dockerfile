FROM adoptopenjdk:11-jre-hotspot as builder
WORKDIR application
COPY  target/websocket-demo-0.0.1-SNAPSHOT.jar chatapp.jar
RUN java -Djarmode=layertools -jar chatapp.jar extract

FROM adoptopenjdk:11-jre-hotspot
WORKDIR application
COPY --from=builder application/dependencies/ ./
COPY --from=builder application/spring-boot-loader ./
COPY --from=builder application/snapshot-dependencies/ ./
COPY --from=builder application/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
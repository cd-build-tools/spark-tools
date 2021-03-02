FROM python:3.7.9-slim

ARG SPARK_VERSION=3.0.1
ARG HADOOP_VERSION_SHORT=3.2
ARG HADOOP_VERSION=3.2.0
ARG AWS_SDK_VERSION=1.11.375

ARG COMMONS_POOL2_VERSION=2.9.0
ARG KAFKA_CLIENTS_VERSION=2.7.0
ARG SNOWFLAKE_JDBC_VERSION=3.12.17
ARG SPARK_SNOWFLAKE_VERSION=2.8.4-spark_3.0
ARG SPARK_XML_VERSION=0.11.0

RUN mkdir -p /usr/share/man/man1

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y wget openjdk-11-jre maven \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*  

# Download and extract Spark
RUN wget -qO- https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION_SHORT}.tgz | tar zx -C /opt && \
    mv /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION_SHORT} /opt/spark

ENV PATH="/opt/spark/bin:${PATH}"
ENV PYSPARK_PYTHON=python
ENV PYSPARK_DRIVER_PYTHON=python
ENV SPARK_HOME=/opt/spark

# Download dependencies from maven
RUN mvn dependency:copy -Dartifact=org.apache.hadoop:hadoop-aws:${HADOOP_VERSION} -DexcludeTransitive=true -DoutputDirectory=/opt/spark/jars/
RUN mvn dependency:copy -Dartifact=com.amazonaws:aws-java-sdk-bundle:${AWS_SDK_VERSION} -DexcludeTransitive=true -DoutputDirectory=/opt/spark/jars/
RUN mvn dependency:copy -Dartifact=org.apache.commons:commons-pool2:${COMMONS_POOL2_VERSION} -DexcludeTransitive=true -DoutputDirectory=/opt/spark/jars/
RUN mvn dependency:copy -Dartifact=org.apache.kafka:kafka-clients:${KAFKA_CLIENTS_VERSION} -DexcludeTransitive=true -DoutputDirectory=/opt/spark/jars/
RUN mvn dependency:copy -Dartifact=net.snowflake:snowflake-jdbc:${SNOWFLAKE_JDBC_VERSION} -DexcludeTransitive=true -DoutputDirectory=/opt/spark/jars/
RUN mvn dependency:copy -Dartifact=net.snowflake:spark-snowflake_2.12:${SPARK_SNOWFLAKE_VERSION} -DexcludeTransitive=true -DoutputDirectory=/opt/spark/jars/
RUN mvn dependency:copy -Dartifact=org.apache.spark:spark-sql-kafka-0-10_2.12:${SPARK_VERSION} -DexcludeTransitive=true -DoutputDirectory=/opt/spark/jars/
RUN mvn dependency:copy -Dartifact=org.apache.spark:spark-token-provider-kafka-0-10_2.12:${SPARK_VERSION} -DexcludeTransitive=true -DoutputDirectory=/opt/spark/jars/
RUN mvn dependency:copy -Dartifact=com.databricks:spark-xml_2.12:${SPARK_XML_VERSION} -DexcludeTransitive=true -DoutputDirectory=/opt/spark/jars/
# RUN mvn dependency:copy -Dartifact=org.apache.spark:spark-streaming-kafka-0-10_2.12:${SPARK_VERSION} -DexcludeTransitive=true -DoutputDirectory=/opt/spark/jars/
# RUN mvn dependency:copy -Dartifact=org.apache.spark:spark-streaming_2.12:${SPARK_VERSION} -DexcludeTransitive=true -DoutputDirectory=/opt/spark/jars/

# Remove maven cached
RUN rm -rf /root/.m2/repository

EXPOSE 4040 6066 7077 8080

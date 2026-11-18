# ==============================================================================
# Multi-stage Dockerfile cho Delivery Service (QuickBite Microservices)
# Stage 1: Build mã nguồn với Gradle và Temurin JDK 17
# Stage 2: Đóng gói runtime siêu gọn nhẹ với Temurin JRE 17 Alpine
# ==============================================================================

# Stage 1: Build
FROM eclipse-temurin:17-jdk-alpine AS builder
WORKDIR /app

# Sao chép file cấu hình gradle để tận dụng layer caching
COPY gradlew settings.gradle build.gradle ./
COPY gradle ./gradle
RUN chmod +x gradlew

# Sao chép toàn bộ mã nguồn và đóng gói JAR
COPY src ./src
RUN ./gradlew bootJar --no-daemon

# Stage 2: Runtime
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Tạo non-root user vì mục tiêu bảo mật production
RUN addgroup -S quickbite && adduser -S quickbite -G quickbite
USER quickbite:quickbite

COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8084
ENV PORT=8084
ENV JAVA_OPTS="-Xms128m -Xmx256m"

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -q --spider http://localhost:8084/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]

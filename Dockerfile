# Base image
FROM ubuntu:22.04
#FROM alpine:3.18

# Build arg
ARG LINUX_CC=gcc
ARG PPC_CC=gcc

ARG RELEASE=false


RUN echo "---1----The RELEASE build argument is set to: $RELEASE"


ARG GIT_VERSION=unknown

# Install compilers + git
RUN apt-get update && \
    apt-get install -y build-essential git clang && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY init.sh /app/init.sh
RUN sed -i 's/\r$//' /app/init.sh
RUN chmod +x /app/init.sh

# Copy source + Makefile
#COPY ./repos/main.c .
#COPY ./repos/Makefile .
COPY ./repos ./repos
WORKDIR /app/repos

RUN echo "---1----The RELEASE build argument is set to: $RELEASE"


# 1.Use Makefile to build, pass RELEASE and select compiler
RUN if [ "$RELEASE" = "true" ]; then \
        echo "Release build: using gcc"; \
        echo "---1----The RELEASE build argument is set to: $RELEASE"; \
        make CC="$PPC_CC" RELEASE=true GIT_VERSION="$GIT_VERSION"; \
    else \
        echo "Debug build: using gcc"; \
        echo "---1----The RELEASE build argument is set to: $RELEASE"; \
        make CC="$LINUX_CC" GIT_VERSION="$GIT_VERSION"; \
    fi
    

WORKDIR /app

# 2. Use the RUN block to create a symbolic link (shortcut)
RUN if [ "$RELEASE" = "true" ]; then \
        echo "Setting up Release build link"; \
        ln -sf /app/repos/app_release /app/app_run; \
    else \
        echo "Setting up Linux build link"; \
        ln -sf /app/repos/app_linux /app/app_run; \
    fi

# 3. Set the ENTRYPOINT to the shortcut (Outside the IF block)
ENTRYPOINT ["./app_run"]


#docker build -t c-gcc-demo:release --build-arg RELEASE=true --build-arg GIT_VERSION=aaa .
#docker build -t c-gcc-demo:release --build-arg RELEASE=true .
#docker build -t c-gcc-demo:release --build-arg RELEASE=true --build-arg GIT_VERSION=$(git describe --tags --dirty --always) .
#docker build -t c-gcc-demo:linux --build-arg RELEASE=false --build-arg GIT_VERSION=$(git describe --tags --dirty --always) .
#docker build -t c-gcc-demo:linux --build-arg GIT_VERSION=$(git describe --tags --dirty --always) .

#docker run --rm c-gcc-demo:release This is a test
#docker run --rm c-gcc-demo:linux This is a test


#docker run c-gcc-demo "This is a test"
#docker run --rm c-gcc-demo This is a test
#docker run --rm -it --entrypoint bash c-gcc-demo


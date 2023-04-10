ARG WHISPER_MODEL_URL=https://huggingface.co/datasets/ggerganov/whisper.cpp/resolve/main/
# ARG WHISPER_MODEL=ggml-medium.bin
# ARG WHISPER_MODEL=ggml-small.bin
ARG WHISPER_MODEL=ggml-tiny.bin
ARG WHISPER_CPP_DIR=/go/src/github.com/ggerganov/whisper.cpp
ARG WORK_DIR=/go/src/github.com/sters/docker-golang-whispercpp
ARG GO_VERSION=1.20

# Whisper related resource
FROM golang:${GO_VERSION} as whisper-builder

ARG WHISPER_MODEL
ARG WHISPER_MODEL_URL
ARG WHISPER_CPP_DIR

RUN mkdir -p ${WHISPER_CPP_DIR}
RUN cd /go/src/ && \
    git clone https://github.com/ggerganov/whisper.cpp/ && \
    mv whisper.cpp github.com/ggerganov/
RUN cd ${WHISPER_CPP_DIR}/bindings/go/ && make whisper
RUN curl -L -o /tmp/${WHISPER_MODEL} ${WHISPER_MODEL_URL}${WHISPER_MODEL}


# Organize app
FROM golang:${GO_VERSION}

ARG WHISPER_MODEL
ARG WHISPER_CPP_DIR
ARG WORK_DIR

ENV C_INCLUDE_PATH ${WORK_DIR}
ENV LIBRARY_PATH ${WORK_DIR}

COPY . ${WORK_DIR}
WORKDIR ${WORK_DIR}

RUN go mod tidy

COPY --from=whisper-builder ${WHISPER_CPP_DIR}/libwhisper.a ${WORK_DIR}/libwhisper.a
COPY --from=whisper-builder ${WHISPER_CPP_DIR}/whisper.h ${WORK_DIR}/whisper.h
COPY --from=whisper-builder ${WHISPER_CPP_DIR}/whisper.o ${WORK_DIR}/whisper.o
COPY --from=whisper-builder /tmp/${WHISPER_MODEL} ${WORK_DIR}/${WHISPER_MODEL}

RUN mkdir -p tmp

CMD go run main.go

FROM golang:1.10

RUN apt-get update && apt-get install -y inotify-tools

ENV ROOT_PATH /go/src/github.com/caitlin615/go_hello_world
WORKDIR $ROOT_PATH
ADD . $ROOT_PATH

ENTRYPOINT ["./autoreload.sh"]
CMD ["go_hello_world"]

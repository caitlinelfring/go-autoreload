#!/bin/bash
# Autoreloads go application on file changes

# This is based on a script written by Ford Hurley (@fordhurley)

# Requires inotifywait, therefore should be run from within docker
# 1. Add the following to your Dockerfile
#    RUN apt-get update && apt-get install -y inotify-tools

# 2. You should run this script either as your `CMD` or `ENTRYPOINT` in the Dockerfile
#    For example: ENTRYPOINT ["./autoreload.sh"]
#    Then you can run `docker run my_docker_image myApp`
#       * where `my_docker_image` is the docker image of your app
#       * myApp is the name of the static binary that should be rebuilt on file changes (you probably want this to be gitignore'd)

TARGET=${1:-"app"}
FILES_TO_WATCH=${2:-"./*.go"}

wait_for_changes() {
  echo "Waiting for changes"
  # FILES_TO_WATCH can be something like: ./*.go ./**/*.go ./**/**/*.go
  # depending on how long the folder structure is.
  # unfortunately, inotifywait can't recursively watch specific file types
  inotifywait -e modify -e create -e delete -e move $FILES_TO_WATCH
}

build() {
  echo "Rebuilding..."
  rm -vf $TARGET
  go build -v -o $TARGET
}

kill_server() {
  if [[ -n $SERVER_PID ]]; then
    echo
    echo "Stopping server (PID: $SERVER_PID)"
    kill $SERVER_PID
  fi
}

serve() {
  echo "Starting server"
  ./$TARGET &
  SERVER_PID=$!
}

# Exit on ctrl-c (without this, ctrl-c would go to inotifywait, causing it to
# reload instead of exit):
trap "exit 0" SIGINT SIGTERM
trap kill_server "EXIT"

build
serve
while wait_for_changes; do
  kill_server
  if ! build; then
    echo "Error building server"
    continue
  fi
  serve
done

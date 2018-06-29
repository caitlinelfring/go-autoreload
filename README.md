go_hello_world
---

"hello world" web server application in go for show autoreload functionality within Docker.

A script is installed in the Docker container that utilizes
[`inotifywait`](https://linux.die.net/man/1/inotifywait) and watches
for the specified file changes. The example in this repo watches for `*.go` file changes.
If you want to watch files in subdirectories, you'll need to configure for something like:
`./*.go ./**/*.go ./**/**/*.go`. Sadly, `inotifywait` can't recursively watch
specific file extensions.

Build the docker image:
```
make build
```

Run the go webserver:
```
make start
```

Autoreload script takes the following parameters:
```
./autoreload.sh [output_filename] [files to watch]
```

build:
	@docker build -t go_hello_world .

start:
	@docker run -it --rm \
		-v `pwd`:/go/src/github.com/caitlin615/go_hello_world \
		-p 8080:8080 \
		go_hello_world

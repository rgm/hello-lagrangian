hello: main.m
	clang -F . -framework Foundation -framework Lagrangian -o hello main.m

test: hello
	DYLD_FRAMEWORK_PATH=. ./lagrangian-test-runner -command hello

clean:
	rm hello

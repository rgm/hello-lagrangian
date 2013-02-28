hello: main.m
	clang -fobjc-arc -F . -framework Foundation -framework Lagrangian -o hello -DDEBUG=1 main.m

test: hello
	DYLD_FRAMEWORK_PATH=. ./lagrangian-test-runner -command hello

clean:
	rm hello

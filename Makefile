hello: main.m
	clang -fobjc-arc -framework Foundation -o hello main.m

clean:
	rm hello

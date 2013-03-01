# Hello, Lagrangian.

You should be testing your code. As should you be flossing. [Rob
Rix](https://twitter.com/robrix) is seeking to give you one less excuse on the
testing front, anyway. The theory: writing your tests inline with the code that
is being tested reduces the drag and encourages you to write more tests. 

His [Lagrangian][lagrangian] test framework (L3 for short) brings this to Objective-C.

If, like me, you washed out of physics before getting to Lagrangian mechanics,
the name is a reference to << SOMETHING I DON'T ACTUALLY UNDERSTAND >>. Using
some clever preprocessor hacks, the inline tests (which 'summarize the dynamics
of the system,' amirite?) are stripped out of production builds. Set the
`-DDEBUG=1` compiler flag, and some even <i>more</i> clever preprocessor hacks
will turn the test macros into a web of test objects and blocks, lying latent
in the binary. Shine a black light on it by handing the binary to the test
runner, and you'll know if this specific binary is passing its tests.

You have no separate test classes (that you generated, anyway), no separate
test files, and no separate test bundle.[^3]

We'll walk through testing "Hello World," so you can get the flavour of how to
get started.[^1] You'll need Mac OS X 10.8, Xcode and git.[^2] Here are the steps
we'll follow from the shell:

1. Clone the github project and build the executable.
2. Add inline tests.
3. Add L3 framework.
4. Show a test failure.
5. Get to green.

## 1. Clone the github project and build the executable.

Our test application is a Foundation command-line tool that looks like this:

    #import <Foundation/Foundation.h>

    int main(int argc, const char * argv[])
    {
      @autoreleasepool {
        NSLog(@"Hello, Lagrangian");
      }
      return 0;
    }

Ok, so. Not the most technically-challenging program for modern hardware. Start
by cloning the [sample project][hello], building and running:

    $ git clone -b start git://github.com/rgm/hello-lagrangian
    Cloning into 'hello-lagrangian'...
    remote: Counting objects: 52, done.
    remote: Compressing objects: 100% (45/45), done.
    remote: Total 52 (delta 3), reused 51 (delta 2)
    Receiving objects: 100% (52/52), 152.34 KiB, done.
    Resolving deltas: 100% (3/3), done.
    $ cd hello-lagrangian
    $ make
    clang -fobjc-arc -framework Foundation -o hello main.m
    $ ./hello
    2013-03-01 09:43:15.349 hello[36100:707] Hello, Lagrangian

(Note that this checks out the `start` branch. You can switch to the `master`
branch to see what the project should look like when you're done).[^4]

## 2. Add inline tests.

You'll need to define at least (a) a single *suite*, and (b) a single *test* within
that suite. These are defined at the top. You'll also need to add (c) a hook for
the test runner within the top-level autorelease pool.

For religious reasons, of course, the test we've added must first fail, then
we'll fix it.

    #import <Foundation/Foundation.h>

    @l3_suite("main");                       // (a) suite declaration
    @l3_test("this test should succeed") {   // (b) test case
      l3_assert(YES, l3_equals(NO));
    }

    int main(int argc, const char * argv[])
    {
      @autoreleasepool {
        l3_main(argc, argv);                 // (c) test runner hook
        NSLog(@"Hello, Lagrangian");
      }
      return 0;
    }

As it stands, of course, we've broken `make`. Let's fix it.

## 3. Add L3 framework.

We need to tell the compiler about `@l3_suite()`, `@l3_test()` and `l3_main()`
syntax by including a header file, and linking against the L3 library.  It can
currently be built as an iOS static framework, OS X dylib or OS X framework. I
prefer the OS X framework for our purposes: it includes the headers and it's
easy for the compiler to find them.

Add this line to `main.m` below the Foundation include:

    #import <Lagrangian/Lagrangian.h>

You can either build your own framework from the L3 [source][lagrangian] and
copy it into the project folder, or pull a prebuilt one from the project repo:

    $ curl -O https://github.com/rgm/hello-lagrangian/raw/master/Lagrangian.tgz && tar zxf Lagrangian.tgz

Edit the executable target in `Makefile` to add the framework and enable DEBUG:

    hello: main.m
      clang -fobjc-arc -F . -framework Foundation -framework Lagrangian -DDEBUG=1 -o hello main.m

Now make and run the executable. If all went well, you should see the same
output as step 1.

We haven't actually run the tests yet. But, because we set the DEBUG flag,
they're in the executable, lying in wait.

## 4. Show a test failure.

To see test results, we'll run our executable within the test runner. Things
are a little different when your app is a full Cocoa app (ie. passes off to
`NSApplicationMain()`), and hopefully a future tutorial will show that. 

Like the library, you can either build the test runner from the L3
[source][lagrangian] and copy it into the project folder, or pull a prebuilt
one from the project repo:

    $ curl -O https://github.com/rgm/hello-lagrangian/raw/master/lagrangian-test-runner.tgz && tar zxf lagrangian-test-runner.tgz

Add a test target to `Makefile`. This tells the test runner where to find the
L3 library and executes it, passing it the command-line invocation needed to
run our executable:

    test: hello
      DYLD_FRAMEWORK_PATH=. ./lagrangian-test-runner -command hello

And now, run the test target:

    % make test
    DYLD_FRAMEWORK_PATH=. ./lagrangian-test-runner -command hello
    Test Suite 'hello_lagrangian' started at 2013-03-01 22:58:54 +0000

    Test Suite 'main' started at 2013-03-01 22:58:54 +0000

    Test Case '-[main this_test_should_succeed]' started.
    main.m:7: error: -[main this_test_should_succeed] : 'YES' was '1' but should have matched 'l3_equals(NO)'
    Test Case '-[main this_test_should_succeed]' failed (0.000 seconds).

    Test Suite 'main' finished at 2013-03-01 22:58:54 +0000.
    Executed 1 test, with 1 failure (0 unexpected) in 0.000 (0.003) seconds

    Test Suite 'hello_lagrangian' finished at 2013-03-01 22:58:54 +0000.
    Executed 1 test, with 1 failure (0 unexpected) in 0.000 (0.007) seconds

If all went well, you'll see a log of the test run with our (expected) failure.

## 5. Get to green.

And now, make the test pass by changing the assertion in `main.m` from

    l3_assert(YES, l3_equals(NO));

to

    l3_assert(YES, l3_equals(YES));

Back at the shell, rebuild the executable and start a test run:

    % make clean test
    rm hello
    clang -fobjc-arc -F . -framework Foundation -framework Lagrangian -o hello -DDEBUG=1 main.m
    DYLD_FRAMEWORK_PATH=. ./lagrangian-test-runner -command hello
    Test Suite 'hello_lagrangian' started at 2013-03-01 23:04:31 +0000

    Test Suite 'main' started at 2013-03-01 23:04:31 +0000

    Test Case '-[main this_test_should_succeed]' started.
    Test Case '-[main this_test_should_succeed]' passed (0.000 seconds).

    Test Suite 'main' finished at 2013-03-01 23:04:31 +0000.
    Executed 1 test, with 0 failures (0 unexpected) in 0.000 (0.003) seconds

    Test Suite 'hello_lagrangian' finished at 2013-03-01 23:04:31 +0000.
    Executed 1 test, with 0 failures (0 unexpected) in 0.000 (0.007) seconds

And with that--assuming you agree there's not much to refactor here--we've
completed one full TDD cycle using Lagrangian.

---

I hope this has piqued your interest to learn more. As of this writing, L3 is
barely four months old yet it's already achieved that neat test-framework
tail-swallowing trick, and so the best place for learning more about using L3
is to look over the extensive tests in its own [source][lagrangian].

[hello]: https://github.com/rgm/hello-lagrangian
[lagrangian]: https://github.com/robrix/lagrangian

[^3]: Well, sort-of true. Yes, there's a `octest` bundle target in Xcode, but
that's mainly to trick Xcode's test machinery. This project won't have one.

[^1]: Note that you wouldn't normally do all this at the shell. I'm reducing
the number of moving parts for learning purposes. Lagrangian has extensive
Xcode integration, and Rob is performing yeoman's work in keeping it working.
Frustrating and mounting evidence suggests that Apple may not rely on its own
unit-testing tools as much as one would hope.

[^2]: You could make this work with older versions of OS X or even Linux /
GNUStep. For convenience, the project uses binaries pre-built against 10.8
using Xcode 4.6. You could build your own. The real prerequisite is a
relatively recent version of `clang`, since L3 makes heavy use of blocks and ARC.

[^4]: `git checkout master` 

#import <Foundation/Foundation.h>
#import <Lagrangian/Lagrangian.h>

@l3_suite("main");                       // test suite declaration

@l3_test("this test should succeed") {   // test case
  l3_assert(YES, l3_equals(NO));
}

int main(int argc, const char * argv[])
{
  @autoreleasepool {
    l3_main(argc, argv);                // test runner hook
    NSLog(@"Hello, Lagrangian");
  }
  return 0;
}

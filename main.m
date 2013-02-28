#import <Foundation/Foundation.h>
#import <Lagrangian/Lagrangian.h>

@l3_suite("main");

@l3_test("this test should fail") {
  l3_assert(YES, l3_equals(NO));
}

@l3_test("this test should succeed") {
  l3_assert(NO, l3_equals(NO));
}

int main(int argc, const char * argv[])
{
  @autoreleasepool {
    l3_main(argc, argv);
    NSLog(@"Hello, Lagrangian");
  }
  return 0;
}

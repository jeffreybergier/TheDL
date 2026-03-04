#import "TDLDownloadTests.h"
#import "TDLDownload.h"

@implementation TDLDownloadTests

- (void)testInitialization {
  NSData *data = [@"Hello World" dataUsingEncoding:NSUTF8StringEncoding];
  NSString *filename = @"test.txt";
  NSString *contentType = @"text/plain";
  
  TDLDownload *wrapper = [[TDLDownload alloc] initWithData:data 
                                                  filename:filename 
                                               contentType:contentType];
  
  XCTAssertNotNil(wrapper, @"Wrapper should not be nil.");
  XCTAssertEqualObjects([wrapper filename], filename, @"Filename should match.");
  XCTAssertEqualObjects([wrapper contentType], contentType, @"Content-type should match.");
  XCTAssertEqualObjects([wrapper regularFileContents], data, @"Data contents should match.");
  
  [wrapper release];
}

@end

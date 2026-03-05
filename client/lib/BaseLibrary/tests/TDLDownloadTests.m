#import <XCTest/XCTest.h>
#import "TDLDownload.h"

@interface TDLDownloadTests : XCTestCase
@end

@implementation TDLDownloadTests

- (void)testSerialization {
  TDLDownload *download = [[TDLDownload alloc] init];
  [download setDisplayName:@"Ubuntu ISO"];
  [download setFilePath:@"/path/to/ubuntu.iso"];
  [download setContentType:@"application/octet-stream"];
  [download setRequestURL:@"http://example.com/ubuntu.iso"];
  [download setResponseURL:@"http://mirror.example.com/ubuntu.iso"];
  [download setActualSize:1024];
  [download setContentSize:2048];
  
  NSDictionary *dict = [download dictionaryRepresentation];
  XCTAssertNotNil(dict, @"Dictionary representation should not be nil.");
  XCTAssertEqualObjects([dict objectForKey:@"displayName"], @"Ubuntu ISO");
  XCTAssertEqualObjects([dict objectForKey:@"actualSize"], [NSNumber numberWithLongLong:1024]);
  
  TDLDownload *newDownload = [[TDLDownload alloc] initWithDictionary:dict];
  XCTAssertEqualObjects([newDownload displayName], [download displayName]);
  XCTAssertEqual([newDownload actualSize], [download actualSize]);
  XCTAssertEqual([newDownload contentSize], [download contentSize]);
  
  [download release];
  [newDownload release];
}

@end

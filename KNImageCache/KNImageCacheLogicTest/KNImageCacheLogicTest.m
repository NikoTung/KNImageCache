//
//  KNImageCacheLogicTest.m
//  KNImageCacheLogicTest
//
//  Created by Niko on 13-7-18.
//  Copyright (c) 2013年 NK. All rights reserved.
//

#import "KNImageCacheLogicTest.h"
#import "NKImageCaches.h"

@interface KNImageCacheLogicTest ()
{
    NKImageCaches *imageCache;
}
#define  Test_URL @"http://f.hiphotos.baidu.com/album/w%3D2048/sign=62c6670f06082838680ddb148ca1a801/08f790529822720e494a2eea7acb0a46f21fab1e.jpg"
@end

@implementation KNImageCacheLogicTest

- (void)setUp
{
    [super setUp];
    NSLog(@"name :%@",self.name);
    imageCache  = [[NKImageCaches alloc] initWithName:@"ImageCacheLogicTest"];
    STAssertNotNil(imageCache, @"create image cache instance fail.");
    NSInteger count = imageCache.totalCachesCount;
    STAssertFalse(count, @"it should be empty when ");
    
    NSString *name = imageCache.name;
    
    STAssertEquals(name, @"ImageCacheLogicTest", @"the really direction name not equal to the name init ");
    
    // Set-up code here.
}

- (void)testFilePathExist
{
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL tt = YES;
    bool result = [fm fileExistsAtPath:imageCache.cachePath isDirectory:&tt];
    NSLog(@"name %@",self.name);
    STAssertTrue(result, @"create image cache path fail");
}


- (void)testOperation
{
    NSLog(@"name :%@",self.name);
    BOOL result = [imageCache hasImageForPath:Test_URL];
    STAssertFalse(result, @"there should no image ");
    
    NSURL *url = [imageCache imageURLforPath:Test_URL];
    STAssertNil(url, @"should no image");
    
    [imageCache fetchRemoteImageWith:Test_URL block:^(BOOL result) {
        
        CFRunLoopRef runloop = CFRunLoopGetCurrent();
        CFRunLoopStop(runloop);
    }];
    
    CFRunLoopRun();
    
    
    BOOL result2 = [imageCache hasImageForPath:Test_URL];
    STAssertTrue(result2, @"there should have image ");
    
    NSURL *url2 = [imageCache imageURLforPath:Test_URL];
    STAssertNotNil(url2, @"should have image");
    
    BOOL result3 = [imageCache removeImageForPath:Test_URL];
    
    STAssertTrue(result3, @"shold remove the image");
    
}


- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
}

@end

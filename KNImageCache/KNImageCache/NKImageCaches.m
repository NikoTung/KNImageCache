//
//  NKImageCaches.m
//  EReader
//
//  Created by Niko on 13-7-17.
//  Copyright (c) 2013年 NK. All rights reserved.
//


static        NSString* kDefaultCacheName       = @"DownloadedBookCover";


#import "NKImageCaches.h"
#import <CommonCrypto/CommonDigest.h>

@interface NKImageCaches()
{
    NSString *_name;
    NSString *_cachePath;
    NSInteger _totalCachesCount;
    
    NSMutableSet *_cacheList;
}

//The key of the image path ,hash with md5,indeed it is the file name store to disk
- (NSString *)keyForURL:(NSString*)URL;

- (void)getExistImageCache;

@end

@implementation NKImageCaches

@synthesize name = _name;
@synthesize cachePath = _cachePath;
@synthesize totalCachesCount = _totalCachesCount;

//get the singleton cache
+ (NKImageCaches *)sharedNKImageCache
{
    static NKImageCaches *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[self alloc] init];
    });
    return cache;
}

- (id)init
{
    self = [self initWithName:kDefaultCacheName];
	if (self)
    {
        
	}
	return self;
}

- (NSString *)cachePath
{
    return _cachePath;
}

- (NSInteger )totalCachesCount
{
    return _totalCachesCount;
}

- (id)initWithName:(NSString*)aName
{
    self = [super init];
	if (self) {
		_name             = aName;
		_cachePath        = [NKImageCaches cachePathWithName:_name] ;
        
        _cacheList        = [NSMutableSet setWithCapacity:30];
        [self getExistImageCache];
		
	}
    return self;
}

- (BOOL)hasImageForPath:(NSString *)aPath
{
    NSString *key = [self keyForURL:aPath];
    return [_cacheList containsObject:key];
}

- (NSURL *)imageURLforPath:(NSString *)aPath
{
    if (![self hasImageForPath:aPath]) {
        return nil;
    }
    
    NSString *path = [_cachePath stringByAppendingPathComponent:[self keyForURL:aPath]];
    
    return [NSURL fileURLWithPath:path];
}

- (BOOL)storeImage:(UIImage *)aImage imagePath:(NSString *)aPath
{
    return [self storeData:UIImageJPEGRepresentation(aImage, 1.0) dataPath:aPath];
}


- (BOOL)storeData:(NSData *)aData dataPath:(NSString *)aPath
{
	return  [self storeData:aData forPath:aPath];
}



- (BOOL)storeData:(NSData*)aData forPath:(NSString*)aPath {
    NSString *key = [self keyForURL:aPath];
    NSString* filePath = [self cachePathForKey:key];
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL result =[fm createFileAtPath:filePath contents:aData attributes:nil];
    if (result) {
        [_cacheList addObject:key];
        _totalCachesCount = [_cacheList count];
    }
    return result;
}

- (BOOL)removeImageForPath:(NSString *)aPath
{
    NSString *key = [self keyForURL:aPath];
    NSFileManager* fm = [NSFileManager defaultManager];
    if ([_cacheList containsObject:key]) {
        NSString *path = [_cachePath stringByAppendingPathComponent:key];
        [_cacheList removeObject:key];
        _totalCachesCount = [_cacheList count];
        if ([fm fileExistsAtPath:path]) {
            return [fm removeItemAtPath:path error:nil];
        }
        else
            return NO;
    }
    return NO;
}

- (void)fetchRemoteImageWith:(NSString *)url tag:(NSInteger )aTag block:(cacheResultBlock )aBlock
{
    __block NKImageCaches *cache = self;
    NSInteger tag = aTag;
    NSURL *URL = [NSURL URLWithString:url];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NKImageCaches *blockInside = cache;
        NSData *data = [NSData dataWithContentsOfURL:URL];
        if (data) {
            BOOL restult = [blockInside storeData:data dataPath:url];
            dispatch_async(dispatch_get_main_queue(), ^{
                aBlock(restult,tag);
            });
        }
    });

}


//file path for a image to store on disk
- (NSString*)cachePathForKey:(NSString*)key {
	return [_cachePath stringByAppendingPathComponent:key];
}

- (NSString *)keyForURL:(NSString*)URL {
    
    NSData *keyData = [URL dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5([keyData bytes], [keyData length], result);
	
	NSString* key = [NSString stringWithFormat:
                     @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                     result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
                     result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
                     ];
    

	return key;
}


- (void)getExistImageCache
{
    if (_cachePath) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSFileManager* fm = [NSFileManager defaultManager];
            NSArray *subPaths = [fm contentsOfDirectoryAtPath:_cachePath error:nil];
            for (NSString *name in subPaths) {
                NSString *path = [_cachePath stringByAppendingPathComponent:name];
                    if ([fm fileExistsAtPath:path]) {
                        [_cacheList addObject:name];
                    }
                }
            _totalCachesCount = [_cacheList count];
        });
    }
}

+ (BOOL)createPathIfNecessary:(NSString*)path {
	BOOL succeeded = YES;
	
	NSFileManager* fm = [NSFileManager defaultManager];
	if (![fm fileExistsAtPath:path]) {
		succeeded = [fm createDirectoryAtPath: path
				  withIntermediateDirectories: YES
								   attributes: nil
										error: nil];
	}
	
	return succeeded;
}



+ (NSString*)cachePathWithName:(NSString*)name {
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString* cachesPath = [paths objectAtIndex:0];
	NSString* cachePath = [cachesPath stringByAppendingPathComponent:name];
	
	[self createPathIfNecessary:cachesPath];
	[self createPathIfNecessary:cachePath];
	
    
	return cachePath;
}



@end

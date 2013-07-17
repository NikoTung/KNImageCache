//
//  NKImageCaches.h
//  EReader
//
//  Created by Lizhang Dong on 13-7-17.
//  Copyright (c) 2013年 along. All rights reserved.
//

/**
 * @brief   this is a simple image cache,if you use the other framework which is easy to get remote image e.g AFNetworking,this class may help you.It stores the image data to local disk,keep the local file path ,you can use this path to request image asynchronously. 
 */

#import <Foundation/Foundation.h>

@interface NKImageCaches : NSObject

//the name of cache path :var://documents/name/
@property (nonatomic, strong) NSString *name;

//the path of cache 
@property (nonatomic, readonly) NSString *cachePath;

//total images cache on local disk
@property (nonatomic, readonly) NSInteger totalCachesCount;

//get the singleton cache
+ (NKImageCaches *)sharedNKImageCache;


//initialize the cache with file path name
- (id)initWithName:(NSString*)aName;

//whether there is a cache image for a specify path
/*
 * @param   aPath:the path of the image got from remote server or local ,this path distinguish a unique image
 *
 * @return: return yes if exist otherwise no
 */
- (BOOL)hasImageForPath:(NSString *)aPath;

//get the local image path for a specify path
/*
 * @param aPath:the path of the image got from remote server or local ,this path distinguish a unique image
 *
 * @return: return the image's local file path if exist otherwise nil
 */
- (NSURL *)imageURLforPath:(NSString *)aPath;

//cache the image to local disk with it's image path
/*
 * @param :aImage ,the image to be stored
 *
 * @param :aPath ,the path of image ,which you get this image from
 * 
 * @return: return yes if store succeed otherwise no
 */
- (BOOL)storeImage:(UIImage *)aImage imagePath:(NSString *)aPath;

//the same as storeImage:imagePath:
- (BOOL)storeData:(NSData *)aData dataPath:(NSString *)aPath;

//remove the cache from local disk if exist
- (BOOL)removeImageForPath:(NSString *)aPath;


//fetch a remote image from server ,if succeed cache it
- (void)fetchRemoteImageWith:(NSString *)url;


@end

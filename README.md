KNImageCache
===========================

This is a simple class to help you cache images to local disk if you use some other framework (e.g [AFNetworking](https://github.com/AFNetworking/AFNetworking)) to
request image which does't provide disk cache but memory cache.You use the key (the url of image) to distinguish 
whether the image exist on the disk.

Unlike other cache ,KNImageCache only caches the image's key not the image data in memory.When you detect that the image
cached on disk,you can get the file path and request the image with the framework .

 ARC Compatibility
===================
 * KNImageCache support ARC,
 
Usage 
===============
It is easy to use.
* For request local cache ,you should get the file URL.
* For cache ,you just pass the url of the image the KNImageCache

    - (BOOL)hasImageForPath:(NSString *)aPath;
    - (NSURL *)imageURLforPath:(NSString *)aPath;
    - (BOOL)storeImage:(UIImage *)aImage imagePath:(NSString *)aPath;

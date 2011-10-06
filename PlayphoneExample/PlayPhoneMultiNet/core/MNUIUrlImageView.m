//
//  MNUIUrlImageView.m
//  MultiNet client
//
//  Created by Vladislav Ogol on 13.01.10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import "MNUIUrlImageView.h"

#define MNUIUrlImageViewDownloadTimeout (30)

@interface MNUIUrlImageView()

-(void)       cancelDownloading;
-(void)       releaseResources;

-(void)       connection     : (NSURLConnection*)          aConnection
      didReceiveResponse     : (NSURLResponse*)            aResponse;

-(void)       connection     : (NSURLConnection*)          aConnection
          didReceiveData     : (NSData*)                   aData;

-(void)       connectionDidFinishLoading
                             : (NSURLConnection*)          aConnection;

-(void)       connection     : (NSURLConnection*)          aConnection
        didFailWithError     : (NSError*)                  aError;

-(NSCachedURLResponse*)
                  connection : (NSURLConnection*)          aConnection
           willCacheResponse : (NSCachedURLResponse*)      aCachedResponse;

@property (nonatomic,retain)   NSURLConnection  *downloadConnection;
@property (nonatomic,retain)   NSMutableData    *imageData;

@end


@implementation MNUIUrlImageView

@synthesize imageData;
@synthesize downloadConnection;

-(void)       dealloc
 {
  [self releaseResources];
  
  [super dealloc];
 }

-(void)       loadImageWithUrl    : (NSURL*)          aImageUrl
 {
  if (self.downloadConnection != nil)
   {
    [self cancelDownloading];
   }
  
  self.imageData = [[NSMutableData alloc] init];
  self.downloadConnection = [[NSURLConnection alloc]
                 initWithRequest: [NSURLRequest requestWithURL: aImageUrl
                                                   cachePolicy: NSURLRequestUseProtocolCachePolicy
                                               timeoutInterval: MNUIUrlImageViewDownloadTimeout]
                 delegate: self];
  
 }

-(void)       cancelDownloading
 {
  [self releaseResources];
 }

-(void)       releaseResources
 {
  [self.downloadConnection cancel];
  self.downloadConnection = nil;
  
  self.imageData = nil;
 }

-(void)       connection     : (NSURLConnection*)     aConnection
      didReceiveResponse     : (NSURLResponse*)       aResponse
 {
  [self.imageData setLength: 0];
 }

-(void)       connection     : (NSURLConnection*)     aConnection
          didReceiveData     : (NSData*)              aData
 {
  [self.imageData appendData: aData];
 }

-(void)       connectionDidFinishLoading
                             : (NSURLConnection*)     aConnection
 {
  NSData* data = [self.imageData retain];
  
  [self releaseResources];

  UIImage *downloadedImage = [UIImage imageWithData:data];
  
  if (downloadedImage != nil)
   {
    self.image = downloadedImage;
   }
  
  [data release];
 }

-(void)       connection     : (NSURLConnection*)     aConnection
        didFailWithError     : (NSError*)             aError
 {
  [self releaseResources];
 }

-(NSCachedURLResponse*) 
              connection     : (NSURLConnection*)     aConnection
       willCacheResponse     : (NSCachedURLResponse*) aCachedResponse
 {
  return nil;
 }

@end

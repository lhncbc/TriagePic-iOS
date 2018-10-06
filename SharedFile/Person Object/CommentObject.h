//
//  CommentObject.h
//  ReUnite + TriagePic
//
//  Created by Krittach on 7/17/13.
//  Copyright (c) 2013 Krittach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationObject.h"
#import "ImageObject.h"
#define COMMENT_KEY_COMMENTER @"note_written_by_name"
#define COMMENT_KEY_TEXT @"note"
#define COMMENT_KEY_TIME_STAMP @"when"
#define COMMENT_KEY_STATUS @"suggested_status"
#define COMMENT_KEY_LOCATION @"suggested_location"
#define COMMENT_KEY_IMAGE_URL @"imageURL"
#define COMMENT_KEY_IMAGE_PATH @"imagePath"
#define COMMENT_KEY_IMAGE @"image"
#define COMMENT_KEY_UUID @"uuid"

@protocol CommentObjectDelegate;

@interface CommentObject : NSObject

@property (assign, nonatomic) int rank;
@property (strong, nonatomic) NSString *uuid;
@property (strong, nonatomic) NSString *commenterName;
@property (strong, nonatomic) NSDate *timeStamp;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) LocationObject *location;
@property (weak, nonatomic) id<CommentObjectDelegate> delegate;

@property (assign, nonatomic) BOOL hasImage;

+ (CommentObject *)commentObjectFromDicitonary:(NSDictionary *)commentDictionary rank:(int)rank statusCodeDict:(NSDictionary *)statusCodeDict uuid:(NSString *)uuid;
+ (CommentObject *)testCommentObject;
+ (NSDictionary *)dictionaryFromCommentObject:(CommentObject *)commentObject personID:(int)personID;

- (BOOL)hasLocation;
- (BOOL)hasStatus;

- (void)showInLog;
@end

@protocol CommentObjectDelegate <NSObject>
- (void)didFinishLoadingImage:(UIImage *)image;
- (void)didFailedLoadingImage;

@end
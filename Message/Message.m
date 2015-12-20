//
//  Message.m
//  ChatApp
//
//  Created by Ghanshyam on 9/2/15.
//  Copyright (c) 2015 Ghanshyam. All rights reserved.
//

#import "Message.h"
#import "XMPPMessageArchiving_Message_CoreDataObject.h"
#import "XMPPFunctions.h"
#import "NSXMLElement+XEP_0203.h"
#import "Media.h"
#import "Notification.h"

@implementation Message

-(void)dealloc{
    self.ID = nil;
    self.message = nil;
    self.uuid = nil;
    self.timeStamp = nil;
    self.reference = nil;
    self.bokuXMPPJID = nil;
}


/**
 *  Used to populate itself with Message Core Object
 *
 *  @param coreObject : Message Core Object
 */
-(void)populateMeWithMessageArchiveCoreObject:(XMPPMessageArchiving_Message_CoreDataObject *)coreObject{
    
//    NSLog(@"core object == %@",coreObject);
//    
//    NSLog(@"unique ID == %@",coreObject.uniqueID);
    
    self.ID = @([coreObject.uniqueID integerValue]);
    
    //We are checking if Message is Media and Status is MESSAGE_NOT_SENT then we are looking for shared media which may be uploading so relevant changes can be reflected.
    if (coreObject.status && coreObject.status.length>0
        && [coreObject.status intValue] == MESSAGE_NOT_SENT
        && coreObject.type && coreObject.type.length>0) {
        Media *media = [APPDELEGATE lookForSharedUploadingMediaWithMediaIdentifier:coreObject.uuid];
        
        if (media) {
            NSLog(@"found share media");
        }
        
        self.media = media;
    }
    
    if (coreObject.status && coreObject.status.length>0) {
        NSString *messageStatus = coreObject.status;
        self.status = [XMPPFunctions getXMPPMessageStatusEnumValueWithIntValue:[messageStatus intValue]];
        
        if (self.status == MESSAGE_NOT_SENT) {
            //If we get Message_NOT_SENT Here , then this is case that media was failed during uploaded.
            self.status = MEDIA_UPLOADING_FAILURE;
        }
        
    }else{
        self.status = MESSAGE_SENT;
    }
    
    
    self.xmppMessage = coreObject.message;
    
    self.isOutgoing = coreObject.isOutgoing;
    
    
    if (coreObject.type && ![coreObject.type isEqualToString:@"group_notification"] && coreObject.type.length>0
        && !self.media) {
        //Message is of media type
        
        
        Media *media = [[Media alloc] init];
        
        media.chatType = self.chatType;
        
        media.mediaPriority = LOW_LEVEL_MEDIA;
        
        if ([coreObject.type isEqualToString:@"image"]) {
            media.mediaType = IMAGE_MEDIA;
            
            NSNumber *width = coreObject.width;
            NSNumber *height = coreObject.height;
            
            NSDictionary *dictLocationMetaData = [[NSDictionary alloc] initWithObjectsAndKeys:width,@"width",height,@"height", nil];
            
            media.mediaMetaData = dictLocationMetaData;
            
        }else if ([coreObject.type isEqualToString:@"video"]){
            media.mediaType = VIDEO_MEDIA;
            
            NSNumber *width = coreObject.width;
            NSNumber *height = coreObject.height;
            
            NSDictionary *dictLocationMetaData = [[NSDictionary alloc] initWithObjectsAndKeys:width,@"width",height,@"height", nil];
            
            media.mediaMetaData = dictLocationMetaData;
            
        }else if ([coreObject.type isEqualToString:@"audio"]){
            media.mediaType = AUDIO_MEDIA;
            
            
        }else if ([coreObject.type isEqualToString:@"location"]){
            media.mediaType = LOCATION_MEDIA;
            
            NSNumber *lat = coreObject.lat;
            NSNumber *lng = coreObject.lng;
            
            NSNumber *width = coreObject.width;
            NSNumber *height = coreObject.height;
            
            NSDictionary *dictLocationMetaData = [[NSDictionary alloc] initWithObjectsAndKeys:lat,@"lat",lng,@"lng",width,@"width",height,@"height", nil];
            
            media.mediaMetaData = dictLocationMetaData;
        }
        
        media.mediaIdentifier = coreObject.uuid;
        
        if (coreObject.furl && coreObject.furl.length>0) {
            
            //Indicating remote url
            media.mediaURL = coreObject.furl;
        }else{
            
            //Indicating local Media file Name
             NSString *localMediaFileName = coreObject.localFileName;
            
            //Creating Local Media File URL, basis on MediaIdentifier
            NSString *path = [CommonFunctions getMediaDirectoryPathForOfflineFilesForBokuUser:self.bokuXMPPJID];
            
            NSLog(@"saving offline media url is == %@",path);
            
            //Appending FileName
            NSString *offlineMediaURL = [path stringByAppendingPathComponent:localMediaFileName];
            media.localMediaURL = offlineMediaURL;
            
            media.mediaData = [NSData dataWithContentsOfFile:media.localMediaURL];
        }
        
        if (coreObject.turl) {
            media.thumbURL = coreObject.turl;
        }
        
        
        self.media = media;
        
    }else{
        
        NSString *messageBody = coreObject.body;
        if (messageBody) {
            
            NSData *messageData = [messageBody dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dictJson = [NSJSONSerialization JSONObjectWithData:messageData options:NSJSONReadingMutableContainers error:NULL];
            if (dictJson && [[dictJson objectForKey:@"type"] isEqualToString:@"group_notification"]) {
                
                NSString *fromJID = [dictJson objectForKey:@"fromJID"];
                NSString *toJID = [dictJson objectForKey:@"toJID"];
                NSString *message = @"";
                
                if (fromJID) {
                    NSString *fromJIDDIsplayName = [CommonFunctions groupJIDDisplayName:fromJID];
                    message = [NSString stringWithFormat:@"%@ %@",fromJIDDIsplayName,[dictJson objectForKey:@"message"]];
                }else{
                    message = [dictJson objectForKey:@"message"];
                }
                
                if (toJID) {
                    NSString *toJIDDIsplayName = [CommonFunctions groupJIDDisplayName:toJID];
                    message = [NSString stringWithFormat:@"%@ %@",message,toJIDDIsplayName];
                }
                
                self.message = message;
                
                self.notification = [[Notification alloc] init];
                self.notification.message = message;
                
                
            }else{
                self.message = coreObject.body;
            }
            
            
        }else{
            self.message = coreObject.body;
        }
        
    }
    
    
    if (self.media) {
        
        self.message = @"";
        
        if (self.media.mediaType == AUDIO_MEDIA) {
            NSNumber *duration = coreObject.duration;
            [self metaDataForAudioWithDuration:[duration intValue]];
        }
        
        if (self.media.mediaType == IMAGE_MEDIA||
            self.media.mediaType == LOCATION_MEDIA||
            self.media.mediaType == VIDEO_MEDIA ||
            self.media.mediaType == AUDIO_MEDIA) {
            
            _requireDownloading = ![self.media isMediaCachedForChatType:_chatType bokuXmppUserName:_bokuXMPPJID];
            
        }
    }
    
    self.uuid = coreObject.uuid;
    
    self.timeStamp = coreObject.timestamp;
    
    //DateFormater to display Creation date
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"dd/MM/yyyy"];
    [dateFormater setDateStyle:NSDateFormatterShortStyle];
    [dateFormater setTimeStyle:NSDateFormatterNoStyle];
    [dateFormater setDoesRelativeDateFormatting:YES];
    self.displayDate = [dateFormater stringFromDate:self.timeStamp];
    
    [dateFormater setDateFormat:@"hh:mm a"];
    [dateFormater setDateStyle:NSDateFormatterNoStyle];
    [dateFormater setTimeStyle:NSDateFormatterShortStyle];
    [dateFormater setDoesRelativeDateFormatting:YES];
    self.displayTime = [dateFormater stringFromDate:self.timeStamp];
    
    
    if (coreObject.isOutgoing) {
        self.creatorJID = [APPDELEGATE.xmppStream myJID];
    }else{
        self.creatorJID = coreObject.bareJid;
    }
    
    
    if (coreObject.isOffline) {
        //we are getting XMPPMessage Object , so that xmppObject can be sent again to server when ever we get network connectivity, we add one attribut "isOffline" to "yes" .
        self.xmppMessage = coreObject.message;
        
        [self.xmppMessage addAttributeWithName:@"isOffline" stringValue:@"yes"];
        
        
        NSLog(@"xmpp message is == %@",self.xmppMessage);
    }
    
    if (!self.media) {
        //Defining message frame
        [CommonFunctions defineMessageFrame:self];
    }
    
}

-(void)calculateAudioDuration{
    BOOL isMediaCached = [_media isMediaCachedForChatType:_chatType bokuXmppUserName:_bokuXMPPJID];
    if (isMediaCached) {
        
        NSString *localAudioPath = [CommonFunctions getMediaDirectoryPathForBokuUser:_bokuXMPPJID chatType:_chatType needThumbnailPath:NO];
        NSString *localAudioURL = [localAudioPath stringByAppendingPathComponent:[[self.media.mediaURL componentsSeparatedByString:@"/"] lastObject]];
        AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:localAudioURL] options:nil];
        CMTime audioDuration = audioAsset.duration;
        float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
        
        int audioSeconds = audioDurationSeconds;
        [self metaDataForAudioWithDuration:audioSeconds];
        
    }
}

/**
 *  Used to create meta data for audio
 */
-(void)metaDataForAudioWithDuration:(int)audioSeconds{
    
    int minutes = audioSeconds/60;
    int seconds = audioSeconds%60;
    NSString *strMinute = [NSString stringWithFormat:@"0%d",minutes];
    if (minutes>9) {
        strMinute = [NSString stringWithFormat:@"%d",minutes];
    }
    
    NSString *strSeconds = [NSString stringWithFormat:@"0%d",seconds];
    if (seconds>9) {
        strSeconds = [NSString stringWithFormat:@"%d",seconds];
    }
    
    NSDictionary *dictMeta = [NSDictionary dictionaryWithObjectsAndKeys:strMinute,@"min",strSeconds,@"sec",[NSString stringWithFormat:@"%d",audioSeconds],@"duration", nil];
    self.reference = dictMeta;
    
}

/**
 *  Used to get audio duration
 *
 *  @return duration
 */
-(int)getAudioDuration{
    
    BOOL isMediaCached = [_media isMediaCachedForChatType:_chatType bokuXmppUserName:_bokuXMPPJID];
    if (isMediaCached) {
        
        NSString *localAudioPath = [CommonFunctions getMediaDirectoryPathForBokuUser:_bokuXMPPJID chatType:_chatType needThumbnailPath:NO];
        NSString *localAudioURL = [localAudioPath stringByAppendingPathComponent:[[self.media.mediaURL componentsSeparatedByString:@"/"] lastObject]];
        AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:localAudioURL] options:nil];
        CMTime audioDuration = audioAsset.duration;
        float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
        
        int audioSeconds = audioDurationSeconds;
        return audioSeconds;
    }
    return 0;
    
}

/**
 *  Used to get audio file duration , which is locally stored
 *
 *  @return audio duration
 */
-(int)getAudioDurationWithMetaData{
    
    if (self.media.mediaData) {
        
        NSString *localAudioPath = [CommonFunctions getMediaDirectoryPathForBokuUser:_bokuXMPPJID chatType:_chatType needThumbnailPath:NO];
        NSString *localAudioFileName = [NSString stringWithFormat:@"Temp_%@",[[self.media.localMediaURL componentsSeparatedByString:@"/"] lastObject]];
        
        NSString *localTempAudioURL = [localAudioPath stringByAppendingPathComponent:localAudioFileName];
        
        [self.media.mediaData writeToFile:localTempAudioURL atomically:YES];
        
        AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:localTempAudioURL] options:nil];
        CMTime audioDuration = audioAsset.duration;
        float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
        
        int audioSeconds = audioDurationSeconds;
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if ([fileManager fileExistsAtPath:localTempAudioURL]) {
            [fileManager removeItemAtPath:localTempAudioURL error:NULL];
        }
        
        return audioSeconds;
        
    }
    
    return 0;

}

/**
 *  Used to populate current context with XMPPMessage Object
 *
 *  @param messageObj : XMPPMessage Object
 */
-(void)populateMeWithXMPPMessageObject:(XMPPMessage *)messageObj{
    /*<message xmlns="jabber:client" from="8386837120@46.101.62.191/35600460261441257244494646" to="9414440765@46.101.62.191" type="chat" id="40699DD6-27CB-4213-9762-29DC738F5074"><archived xmlns="urn:xmpp:mam:tmp" by="46.101.62.191" id="1441257319325499"></archived><body>Morning</body><request xmlns="urn:xmpp:receipts"></request></message>*/
    
    
    if ([messageObj attributeForName:@"id"]) {
        self.uuid = [messageObj attributeStringValueForName:@"id"];
       
    }
    
    
    if ([messageObj elementForName:@"body"]) {
        NSXMLElement *body = [messageObj elementForName:@"body"];
        
        //Identifiying message
        NSString *messageBody = body.stringValue;
        
        NSData *dataMessage = [messageBody dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        id messageCheck = [NSJSONSerialization JSONObjectWithData:dataMessage options:NSJSONReadingMutableContainers error:&error];
        
        self.status = MESSAGE_SENT;
        
        if ([messageCheck isKindOfClass:[NSDictionary class]]) {
            //Message is of media type
            NSDictionary *dictMediaMessage = (NSDictionary *)messageCheck;
            if ([[dictMediaMessage objectForKey:@"type"] isEqualToString:@"acknowledge"]) {
                
                self.message = body.stringValue;
                
            }else if([[dictMediaMessage objectForKey:@"type"] isEqualToString:@"group_notification"]){
            
                NSString *fromJID = [dictMediaMessage objectForKey:@"fromJID"];
                NSString *toJID = [dictMediaMessage objectForKey:@"toJID"];
                NSString *message = @"";
                
                if (fromJID) {
                    NSString *fromJIDDIsplayName = [CommonFunctions groupJIDDisplayName:fromJID];
                    message = [NSString stringWithFormat:@"%@ %@",fromJIDDIsplayName,[dictMediaMessage objectForKey:@"message"]];
                }else{
                    message = [dictMediaMessage objectForKey:@"message"];
                }
                
                if (toJID) {
                    NSString *toJIDDIsplayName = [CommonFunctions groupJIDDisplayName:toJID];
                    message = [NSString stringWithFormat:@"%@ %@",message,toJIDDIsplayName];
                }
                
                self.message = message;
                
                self.notification = [[Notification alloc] init];
                self.notification.message = message;
                
            }else{
                Media *media = [[Media alloc] init];
                
                media.chatType = self.chatType;
                
                media.mediaPriority = LOW_LEVEL_MEDIA;
                
                if ([[dictMediaMessage objectForKey:@"type"] isEqualToString:@"image"]) {
                    media.mediaType = IMAGE_MEDIA;
                    
                    NSNumber *width = @(0);
                    if ([dictMediaMessage objectForKey:@"width"]) {
                        width = @([[dictMediaMessage objectForKey:@"width"] floatValue]);
                    }
                    
                    
                    NSNumber *height = @(0);
                    if ([dictMediaMessage objectForKey:@"height"]) {
                        height = @([[dictMediaMessage objectForKey:@"height"] floatValue]);
                    }
                    
                    
                    NSDictionary *dictLocationMetaData = [[NSDictionary alloc] initWithObjectsAndKeys:width,@"width",height,@"height", nil];
                    
                    media.mediaMetaData = dictLocationMetaData;
                    
                }else if ([[dictMediaMessage objectForKey:@"type"] isEqualToString:@"video"]){
                    media.mediaType = VIDEO_MEDIA;
                    
                    NSNumber *width = @(0);
                    if ([dictMediaMessage objectForKey:@"width"]) {
                        width = @([[dictMediaMessage objectForKey:@"width"] floatValue]);
                    }
                    
                    
                    NSNumber *height = @(0);
                    if ([dictMediaMessage objectForKey:@"height"]) {
                        height = @([[dictMediaMessage objectForKey:@"height"] floatValue]);
                    }
                    
                    
                    NSDictionary *dictLocationMetaData = [[NSDictionary alloc] initWithObjectsAndKeys:width,@"width",height,@"height", nil];
                    
                    media.mediaMetaData = dictLocationMetaData;
                    
                }else if ([[dictMediaMessage objectForKey:@"type"] isEqualToString:@"audio"]){
                    media.mediaType = AUDIO_MEDIA;
                }else if ([[dictMediaMessage objectForKey:@"type"] isEqualToString:@"location"]){
                    media.mediaType = LOCATION_MEDIA;
                    
                    NSNumber *lat = @(0);
                    if ([dictMediaMessage objectForKey:@"lat"]) {
                        lat = @([[dictMediaMessage objectForKey:@"lat"] floatValue]);
                    }
                    
                    
                    NSNumber *lng = @(0);
                    if ([dictMediaMessage objectForKey:@"lng"]) {
                        lng = @([[dictMediaMessage objectForKey:@"lng"] floatValue]);
                    }
                    
                    NSNumber *width = @(0);
                    if ([dictMediaMessage objectForKey:@"width"]) {
                        width = @([[dictMediaMessage objectForKey:@"width"] floatValue]);
                    }
                    
                    
                    NSNumber *height = @(0);
                    if ([dictMediaMessage objectForKey:@"height"]) {
                        height = @([[dictMediaMessage objectForKey:@"height"] floatValue]);
                    }
                    
                    
                    NSDictionary *dictLocationMetaData = [[NSDictionary alloc] initWithObjectsAndKeys:lat,@"lat",lng,@"lng",width,@"width",height,@"height", nil];
                    
                    media.mediaMetaData = dictLocationMetaData;
                    
                }
                
                media.mediaIdentifier = self.uuid;
                
                //Default downloading for recent coming message is YES
                self.requireDownloading = YES;
                
                
                if ([dictMediaMessage objectForKey:@"furl"]) {
                    media.mediaURL = [CommonFunctions urlEncode:[dictMediaMessage objectForKey:@"furl"]];
                }
                
                if ([dictMediaMessage objectForKey:@"turl"]) {
                    media.thumbURL = [CommonFunctions urlEncode:[dictMediaMessage objectForKey:@"turl"]];
                }
                
                self.media = media;
                
                if (media.mediaType == AUDIO_MEDIA) {
                    
                    NSNumber *duration = @([[dictMediaMessage objectForKey:@"duration"] intValue]);
                    
                    [self metaDataForAudioWithDuration:[duration intValue]];

                }
                self.message = @"";
            }
            
        }else{
            //Message is normal text message
            
            self.message = body.stringValue;
        }
        
    }
    
    
    NSDate *timeStamp = [messageObj delayedDeliveryDate];
    if (timeStamp) {
        self.timeStamp = timeStamp;
    }else{
        self.timeStamp = [NSDate date];
    }
    
    
    //DateFormater to display Creation date
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"dd/MM/yyyy"];
    [dateFormater setDateStyle:NSDateFormatterShortStyle];
    [dateFormater setTimeStyle:NSDateFormatterNoStyle];
    [dateFormater setDoesRelativeDateFormatting:YES];
    self.displayDate = [dateFormater stringFromDate:self.timeStamp];
    
    
    [dateFormater setDateFormat:@"hh:mm a"];
    [dateFormater setDateStyle:NSDateFormatterNoStyle];
    [dateFormater setTimeStyle:NSDateFormatterShortStyle];
    [dateFormater setDoesRelativeDateFormatting:YES];
    self.displayTime = [dateFormater stringFromDate:self.timeStamp];
    
    
    self.creatorJID = messageObj.from;
    
    self.status = MESSAGE_STATUS_NOT_CONSIDERED;
    
    if (!self.media) {
        //Defining message frame
        [CommonFunctions defineMessageFrame:self];
    }
    
    
}




/**
 *  Used to say whether this message is Media message or not
 *
 *  @return YES/NO
 */
-(BOOL)isMediaMessage{
    if (_media.mediaType == AUDIO_MEDIA||
        _media.mediaType == VIDEO_MEDIA||
        _media.mediaType == IMAGE_MEDIA) {
        return YES;
    }
    return NO;
}

@end

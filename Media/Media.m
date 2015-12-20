//
//  Media.m
//  Boku
//
//  Created by Ghanshyam on 9/23/15.
//  Copyright (c) 2015 Plural Voice. All rights reserved.
//

#import "Media.h"


@implementation Media

@synthesize mediaIdentifier = _mediaIdentifier;


/**
 *  Media File Type
 *
 *  @return file
 */
-(NSString *)fileType{
    if (_mediaType == IMAGE_MEDIA) {
       return  @"image";
    }else if (_mediaType == AUDIO_MEDIA){
        return @"audio";
    }else if (_mediaType == VIDEO_MEDIA){
        return @"video";
    }else if (_mediaType == LOCATION_MEDIA){
        return @"image";
    }
    return @"";
}


/**
 *  Media File Extension
 *
 *  @return extension
 */
-(NSString *)fileExtension{
    if (_mediaType == IMAGE_MEDIA) {
        return  @"jpg";
    }else if (_mediaType == AUDIO_MEDIA){
        return @"wav";
    }else if (_mediaType == VIDEO_MEDIA){
        return @"mp4";
    }else if (_mediaType == LOCATION_MEDIA){
        return @"jpg";
    }
    return @"";
}


-(void)setMediaIdentifier:(NSString *)mediaIdentifier{
    if (_mediaIdentifier) {
        _mediaIdentifier = nil;
    }
    _mediaIdentifier = mediaIdentifier;
    
    
    //Creating Local Media File URL, basis on MediaIdentifier
    NSString *path = [CommonFunctions getMediaDirectoryPathForOfflineFilesForBokuUser:self.bokuXMPPJID];
    
    NSLog(@"saving offline media url is == %@",path);
    
    //Appending FileName
    NSString *offlineMediaURL = [path stringByAppendingPathComponent:self.mediaIdentifier];
    
    //Appending FileExtension
    offlineMediaURL = [offlineMediaURL stringByAppendingString:[NSString stringWithFormat:@".%@",self.fileExtension]];
    _localMediaURL = offlineMediaURL;
    
}


-(NSString *)mediaIdentifier{
    return _mediaIdentifier;
}

/**
 *  Media Action to be called
 *
 *  @return media action
 */
-(NSString *)mediaAction{
    if (_mediaType == IMAGE_MEDIA) {
        return  @"###upload_media###";
    }else if (_mediaType == AUDIO_MEDIA){
        return @"###upload_media###";
    }else if (_mediaType == VIDEO_MEDIA){
        return @"###upload_media###";
    }else if (_mediaType == LOCATION_MEDIA){
        return @"###upload_media###";
    }
    return @"###upload_media###";
}

-(BOOL)isMediaCachedForChatType:(XMPP_CHAT_TYPE)chatType bokuXmppUserName:(NSString *)bokuXmppUserName{
    
    NSString* mediaURL = [self localMediaURLPath:chatType bokuXmppUserName:bokuXmppUserName];
    
    BOOL isFileCached = [CommonFunctions doesFileCachedWithFilePath:mediaURL];
    
    return isFileCached;
    
}

-(NSString *)localMediaURLPath:(XMPP_CHAT_TYPE)chatType bokuXmppUserName:(NSString *)bokuXmppUserName{
    NSString *mediaPath = [CommonFunctions getMediaDirectoryPathForBokuUser:bokuXmppUserName chatType:chatType needThumbnailPath:NO];
    NSString *mediaURL = [mediaPath stringByAppendingPathComponent:[[_mediaURL componentsSeparatedByString:@"/"] lastObject]];
    return mediaURL;
}


-(NSString *)localMediaVideoSnapShotURLPath:(XMPP_CHAT_TYPE)chatType bokuXmppUserName:(NSString *)bokuXmppUserName{
    NSString *mediaPath = [CommonFunctions getMediaDirectoryPathForBokuUser:bokuXmppUserName chatType:chatType needThumbnailPath:NO];
    
    NSString *mediaName = [[_thumbURL componentsSeparatedByString:@"/"] lastObject];
    
    NSString *mediaThumbURL = [mediaPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Thumb_%@",mediaName]];
    
    
    return mediaThumbURL;
}


-(BOOL)isMediaThumbCachedForChatType:(XMPP_CHAT_TYPE)chatType bokuXmppUserName:(NSString *)bokuXmppUserName{
    
    NSString *mediatThumbURL = [self localMediaThumbURLPath:chatType bokuXmppUserName:bokuXmppUserName];
    
    BOOL isFileCached = [CommonFunctions doesFileCachedWithFilePath:mediatThumbURL];
    
    return isFileCached;
    
}

-(NSString *)localMediaThumbURLPath:(XMPP_CHAT_TYPE)chatType bokuXmppUserName:(NSString *)bokuXmppUserName{
    NSString *mediaThumbPath = [CommonFunctions getMediaDirectoryPathForBokuUser:bokuXmppUserName chatType:chatType needThumbnailPath:YES];
    NSString *mediaThumbURL = [mediaThumbPath stringByAppendingPathComponent:[[_thumbURL componentsSeparatedByString:@"/"] lastObject]];
    return mediaThumbURL;
}

-(NSString *)mediaTypeStringValue{
    if (_mediaType == IMAGE_MEDIA) {
        return @"image";
    }else if (_mediaType == VIDEO_MEDIA){
        return @"video";
    }else if (_mediaType == AUDIO_MEDIA){
        return @"audio";
    }else if (_mediaType == LOCATION_MEDIA){
        return @"location";
    }
    return @"";
}


/**
 *  Used to process for audio meta data . it calculate min:sec of audio and assign in mediaMetaData
 */
-(void)processForAudioMetaData{
    if (_mediaType == AUDIO_MEDIA) {
        
        AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:_mediaURL] options:nil];
        CMTime audioDuration = audioAsset.duration;
        float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
        
        int audioSeconds = audioDurationSeconds;
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
        
        _mediaMetaData = dictMeta;
        
    }
}

/**
 *  Used to calculate Audio meta data which is stored temporarily in system
 *
 *  @param fileURL : Temporary Audion file URL
 */
-(void)processForAudioMetaDataWithTempURL:(NSURL *)fileURL{
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    
    int audioSeconds = audioDurationSeconds;
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
    
    _mediaMetaData = dictMeta;
}

/**
 *  Used to say whether this media will be part of gallery or not
 *
 *  @return YES/NO
 */
-(BOOL)isGalleryMedia{
    if (_mediaType == AUDIO_MEDIA||
        _mediaType == VIDEO_MEDIA||
        _mediaType == IMAGE_MEDIA) {
        return YES;
    }
    return NO;
}


@end

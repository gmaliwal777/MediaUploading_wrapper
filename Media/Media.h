//
//  Media.h
//  Boku
//
//  Created by Ghanshyam on 9/23/15.
//  Copyright (c) 2015 Plural Voice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Macros.h"


@interface Media : NSObject


/**
 *  Reference to Media Data
 */
@property (nonatomic, strong)   NSData  *mediaData;


/**
 *  Usually i use to have Media Thumb Image data
 */
@property (nonatomic, strong)   NSData  *mediaSubData;


/**
 *  Reference to media meta data ,i use lat , lng for location in dictionary.
  min, sec in dictionary for audio .
 */
@property (nonatomic, strong)   id  mediaMetaData;


@property (nonatomic, assign)   MEDIA_TYPE  mediaType;

/**
 *  Indicate whether media is being processed like uploading .
 */
@property (nonatomic, assign)   BOOL    isProcessing;


/**
 *  Define media priority , which is either LOW_LEVEL_MEDIA or HIGH_LEVEL_MEDIA, basis on priority we decide its place in MeidaUploading Class.
 */
@property (nonatomic, assign)   MEDIA_PRIORITY  mediaPriority;


/**
 *  Reference to media identifier
 */
@property (nonatomic, strong)   NSString    *mediaIdentifier;

/**
 *  Reference to thumbURL 
 */
@property (nonatomic, strong)   NSString    *thumbURL;


/**
 *  Reference to local Media , stored in OfflineFiles directory. it's to be considered when Media is still stored and not shared with recepient.
 */
@property (nonatomic, strong)   NSString    *localMediaURL;

/**
 *  Reference to actual media URL
 */
@property (nonatomic, strong)   NSString    *mediaURL;

/**
 *  Reference to xmppMessage , this is reference to Message stanza that is to be sent
 */
@property (nonatomic, strong)   XMPPMessage *xmppMessage;


/**
 *  Reference to xmppID , it indicate next party entity JID in case of one to one and . it indicate group_jid in case of group conversation.
 */
@property (nonatomic,strong)        NSString    *bokuXMPPJID;


/**
 *  Indicating chat type (single / group etc)
 */
@property (nonatomic, assign)   XMPP_CHAT_TYPE  chatType;

/**
 *  Media File Extension
 *
 *  @return extension
 */
-(NSString *)fileExtension;


/**
 *  Media File Type
 *
 *  @return file
 */
-(NSString *)fileType;


/**
 *  Media Action to be called
 *
 *  @return media action
 */
-(NSString *)mediaAction;


-(BOOL)isMediaCachedForChatType:(XMPP_CHAT_TYPE)chatType bokuXmppUserName:(NSString *)bokuXmppUserName;


-(BOOL)isMediaThumbCachedForChatType:(XMPP_CHAT_TYPE)chatType bokuXmppUserName:(NSString *)bokuXmppUserName;

-(NSString *)localMediaURLPath:(XMPP_CHAT_TYPE)chatType bokuXmppUserName:(NSString *)bokuXmppUserName;

-(NSString *)localMediaThumbURLPath:(XMPP_CHAT_TYPE)chatType bokuXmppUserName:(NSString *)bokuXmppUserName;

-(NSString *)localMediaVideoSnapShotURLPath:(XMPP_CHAT_TYPE)chatType bokuXmppUserName:(NSString *)bokuXmppUserName;

-(NSString *)mediaTypeStringValue;


/**
 *  Used to process for audio meta data . it calculate min:sec of audio and assign in mediaMetaData
 */
-(void)processForAudioMetaData;

/**
 *  Used to calculate Audio meta data which is stored temporarily in system
 *
 *  @param fileURL : Temporary Audion file URL
 */
-(void)processForAudioMetaDataWithTempURL:(NSURL *)fileURL;

@end

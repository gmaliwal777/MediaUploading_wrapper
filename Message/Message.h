//
//  Message.h
//  ChatApp
//
//  Created by Ghanshyam on 9/2/15.
//  Copyright (c) 2015 Ghanshyam. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Media;
@class Notification;

@interface Message : NSObject


/**
 *  It can be used to keep any dynamic value . I will use it to have text message frame for text message , audio time frame for Audio
 */
@property (nonatomic, strong)   id      reference;

/**
 *  Used to identify whether this message require any downloading or not
 */
@property (nonatomic, assign)   BOOL    requireDownloading;


/**
 *  UI Reuse identifer
 */
@property (nonatomic, strong)   NSString    *UIReuseIdentifier;


///Reference to User name from whom message is received
@property (nonatomic, strong)   NSString    *messageFrom;


/**
 *  Message ID
 */
@property (nonatomic, strong)    NSNumber    *ID;


/**
 *  Message content
 */
@property (nonatomic, strong)    NSString    *message;

/**
 *  Reference to xmppID
 */
@property (nonatomic,strong)        NSString    *bokuXMPPJID;


/**
 *  Reference to chatType
 */
@property (nonatomic, assign)   XMPP_CHAT_TYPE  chatType;


@property (nonatomic, strong)   NSString    *type;

@property (nonatomic, strong)   NSString    *furl;

@property (nonatomic, strong)   NSString    *trul;


/**
 *  Reference to media model , this is optional . it will have reference if Message is indicating to Media (Image , Audio , Video , Location).
 */
@property (nonatomic, strong)   Media       *media;


/**
 *  Reference to notification model
 */

@property (nonatomic, strong)   Notification       *notification;

@property (nonatomic, strong)   XMPPMessage  *xmppMessage;


@property (nonatomic, assign)   BOOL    isOutgoing;

/**
 *  Message unique identifier
 */
@property (nonatomic, strong)    NSString    *uuid;

/**
 *  Message creation timestamp
 */
@property (nonatomic, strong)    NSDate      *timeStamp;


/**
 *  Message creation date string value
 */
@property (nonatomic, strong)   NSString    *displayDate;

/**
 *  Message Creation time string value
 */
@property (nonatomic, strong)   NSString    *displayTime;


/**
 *  Message status (NOT_SENT:0 , SENT:1 , DELIVERED:2 , READ:3)
 */
@property (nonatomic, assign)    XMPP_MESSAGE_STATUS    status;
@property (nonatomic, assign)    BOOL                   statusChanged;



/**
 *  Weak reference to message creator JID
 */
@property (nonatomic, strong)      XMPPJID     *creatorJID;


/**
 *  Used to populate itself with Message Core Object
 *
 *  @param coreObject : Message Core Object
 */
-(void)populateMeWithMessageArchiveCoreObject:(XMPPMessageArchiving_Message_CoreDataObject *)coreObject;


/**
 *  Used to populate current context with XMPPMessage Object
 *
 *  @param messageObj : XMPPMessage Object
 */
-(void)populateMeWithXMPPMessageObject:(XMPPMessage *)messageObj;


/**
 *  Used to create meta data for audio
 */
-(void)calculateAudioDuration;

/**
 *  Used to get audio duration
 *
 *  @return duration
 */
-(int)getAudioDuration;






/**
 *  Used to get audio file duration , which is locally stored
 *
 *  @return audio duration
 */
-(int)getAudioDurationWithMetaData;

/**
 *  Used to say whether this message is Media message or not
 *
 *  @return YES/NO
 */
//-(BOOL)isMediaMessage;

@end

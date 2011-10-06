//
//  MNAchievementsProvider.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 4/7/10.
//  Copyright 2010 PlayPhone. All rights reserved.
//

#import "TouchXML.h"

#import "MNTools.h"
#import "MNGameVocabulary.h"
#import "MNWSXmlTools.h"
#import "MNAchievementsProvider.h"

static NSString* MNAchievementsProviderPluginName = @"com.playphone.mn.at";
static NSString* MNAchievementsProviderMessageFieldSeparator = @"\t";
static NSString* MNAchievementsProviderMessageLineSeparator  = @"\n";
static NSString* MNAchievementsProviderVocabularyFileName = @"MNAchievementsProvider.xml";
static NSString* MNAchievementsProviderImageUrlFormat = @"%@/data_game_achievement_image.php?game_id=%d&game_achievement_id=%d";

#define PLUGIN_MESSAGE_CMD_PREFIX_LEN   (1)

static NSString* getServerUnlockedAchievementsVarNameByUserId (MNUserId userId) {
    return [NSString stringWithFormat: @"offline.%lld.achievement_saved_list",(long long)userId];
}

static BOOL parseLeadingAchievementField (int* achievementId, NSString* message, NSUInteger startPos) {
    NSRange   separatorRange = [message rangeOfString: MNAchievementsProviderMessageFieldSeparator];
    NSString* idStr;

    if (separatorRange.location != NSNotFound) {
        idStr = [message substringWithRange: NSMakeRange(startPos,separatorRange.location - startPos)];
    }
    else {
        idStr = [message substringFromIndex: startPos];
    }

    return MNStringScanInteger(achievementId,idStr);
}

static BOOL parseUserAddAchievementMessage (int *achievementId, NSString* message) {
    return parseLeadingAchievementField(achievementId,message,PLUGIN_MESSAGE_CMD_PREFIX_LEN);
}

static NSMutableArray* parseUserAchievementListMessage (NSString* message) {
    NSArray* achievementsInfoArray = [message componentsSeparatedByString: MNAchievementsProviderMessageLineSeparator];
    NSUInteger index = 0;
    NSUInteger count = [achievementsInfoArray count];

    BOOL            ok     = YES;
    NSMutableArray* result = [NSMutableArray arrayWithCapacity: count];

    while (index < count && ok) {
        NSString* info = [achievementsInfoArray objectAtIndex: index];

        if ([info length] > 0) {
            int achievementId;

            if (parseLeadingAchievementField(&achievementId,info,0)) {
                [result addObject: [[[MNPlayerAchievementInfo alloc] initWithId: achievementId] autorelease]];
            }
            else {
                ok = NO;
            }
        }

        index++;
    }

    if (ok) {
        return result;
    }
    else {
        return nil;
    }
}

static BOOL playerAchievementListContainsAchievementById (NSArray* achievementList, int achievementId) {
    NSUInteger index;
    NSUInteger count = [achievementList count];
    BOOL       found = NO;

    for (index = 0; index < count && !found; index++) {
        if (((MNPlayerAchievementInfo*)[achievementList objectAtIndex: index]).achievementId == achievementId) {
            found = YES;
        }
    }

    return found;
}

static BOOL playerAchievementListAddUniqueAchievement (NSMutableArray* achievementList, int achievementId) {
    if (!playerAchievementListContainsAchievementById(achievementList,achievementId)) {
        [achievementList addObject: [[[MNPlayerAchievementInfo alloc] initWithId: achievementId] autorelease]];

        return YES;
    }
    else {
        return NO;
    }
}

static NSString* stringWithCommaSeparatedAchievementIds (NSArray* achievementList) {
    NSMutableString* result = [[NSMutableString alloc] init];
    BOOL first = YES;

    for (MNPlayerAchievementInfo* achievementInfo in achievementList) {
        if (first) {
            [result appendFormat: @"%d",achievementInfo.achievementId];
            first = NO;
        }
        else {
            [result appendFormat: @",%d",achievementInfo.achievementId];
        }
    }

    return [result autorelease];
}


@implementation MNGameAchievementInfo

@synthesize achievementId = _id;
@synthesize name          = _name;
@synthesize flags         = _flags;
@synthesize description   = _description;
@synthesize params        = _params;
@synthesize points        = _points;

-(id) initWithId:(int) achievementId name:(NSString*) name andFlags:(NSUInteger) flags {
    self = [super init];

    if (self != nil) {
        _id          = achievementId;
        _name        = [name retain];
        _flags       = flags;
        _description = [[NSString alloc] init];
        _params      = [[NSString alloc] init];
        _points      = 0;
    }

    return self;
}

-(void) dealloc {
    [_name release];
    [_description release];
    [_params release];

    [super dealloc];
}

@end


@implementation MNPlayerAchievementInfo

@synthesize achievementId = _id;

-(id) initWithId:(int) achievementId {
    self = [super init];

    if (self != nil) {
        _id = achievementId;
    }

    return self;
}

@end


@implementation MNAchievementsProvider

-(void) fillUnlockedAchievementsArray:(NSMutableArray*) unlockedAchievements forSession:(MNSession*) session {
    [unlockedAchievements removeAllObjects];

    MNUserId userId = [session getMyUserId];

    if (userId == MNUserIdUndefined) {
        return;
    }

    /* load achievements confirmed by server */
    NSString* serverAchievementsList = [session varStorageGetValueForVariable: getServerUnlockedAchievementsVarNameByUserId(userId)];
    NSArray*  serverAchievements = [serverAchievementsList componentsSeparatedByString: @","];
    int       achievementId;

    for (NSString* str in serverAchievements) {
        if (MNStringScanInteger(&achievementId,str)) {
            playerAchievementListAddUniqueAchievement(unlockedAchievements,achievementId);
        }
    }

    /* load achievements achieved in offline mode */

    NSDictionary* offlineAchievements = [session varStorageGetValuesByMasks: [NSArray arrayWithObject: [NSString stringWithFormat: @"offline.%lld.achievement_pending.*",userId]]];

    for (NSString* varName in offlineAchievements) {
        NSArray* varNameComponents = [varName componentsSeparatedByString: @"."];

        if ([varNameComponents count] > 3) {
            if (MNStringScanInteger(&achievementId,[varNameComponents objectAtIndex: 3])) {
                playerAchievementListAddUniqueAchievement(unlockedAchievements,achievementId);
            }
        }
    }
}

-(id) initWithSession: (MNSession*) session {
    self = [super init];

    if (self != nil) {
        _session              = session;
        _delegates            = [[MNDelegateArray alloc] init];
        _unlockedAchievements = [[NSMutableArray alloc] init];

        [_session addDelegate: self];

        [self fillUnlockedAchievementsArray: _unlockedAchievements forSession: session];

        [[_session getGameVocabulary] addDelegate: self];
    }

    return self;
}

-(void) dealloc {
    [[_session getGameVocabulary] removeDelegate: self];
    [_session removeDelegate: self];

    [_unlockedAchievements release];
    [_delegates release];

    [super dealloc];
}

-(NSArray*) getGameAchievementList {
    NSMutableArray* achievements = [NSMutableArray array];
    NSData*         fileData     = [[_session getGameVocabulary] getFileData: MNAchievementsProviderVocabularyFileName];

    if (fileData != nil) {
        NSError *error;
        CXMLDocument *document;

        document = [[CXMLDocument alloc] initWithData: fileData options: 0 error: &error];

        CXMLElement* listElement = MNWSXmlDocumentGetElementByPath(document,[NSArray arrayWithObjects: @"GameVocabulary", @"MNAchievementsProvider", @"Achievements", nil]);

        if (listElement != nil) {
            NSArray* items = MNWSXmlNodeParseItemList(listElement,@"entry");

            for (NSDictionary* itemData in items) {
                NSInteger itemId;

                if (MNStringScanInteger(&itemId,[itemData valueForKey: @"id"])) {
                    NSString* name = [itemData valueForKey: @"name"];
                    NSInteger flags = MNStringScanIntegerWithDefValue([itemData valueForKey: @"flags"],0);
                    NSString* desc = [itemData valueForKey: @"desc"];
                    NSString* params = [itemData valueForKey: @"params"];
                    NSInteger points = MNStringScanIntegerWithDefValue([itemData valueForKey: @"points"],0);

                    MNGameAchievementInfo* achievement = [[[MNGameAchievementInfo alloc] initWithId: itemId
                                                                                               name: name != nil ? name : @""
                                                                                           andFlags: flags] autorelease];

                    achievement.description = desc != nil ? desc : @"";
                    achievement.params      = params != nil ? params : @"";
                    achievement.points      = points;

                    [achievements addObject: achievement];
                }
                else {
                    NSLog(@"warning: achievement data with invalid or absent achievement id ignored");
                }
            }
        }
        else {
            NSLog(@"warning: cannot find \"Achievements\" element in game vocabulary");
        }

        [document release];
    }

    return achievements;
}

-(MNGameAchievementInfo*) findGameAchievementById:(int) achievementId {
    MNGameAchievementInfo* achievement;

    NSArray*   achievements = [self getGameAchievementList];
    BOOL       found        = NO;
    NSUInteger index        = 0;
    NSUInteger count        = [achievements count];

    while (!found && index < count) {
        achievement = [achievements objectAtIndex: index];

        if (achievement.achievementId == achievementId) {
            found = YES;
        }
        else {
            index++;
        }
    }

    return found ? achievement : nil;
}

-(BOOL) isGameAchievementListNeedUpdate {
    return [[_session getGameVocabulary] getVocabularyStatus] > 0;
}

-(void) doGameAchievementListUpdate {
    MNGameVocabulary* gameVocabulary = [_session getGameVocabulary];

    if ([gameVocabulary getVocabularyStatus] != MN_GV_UPDATE_STATUS_DOWNLOAD_IN_PROGRESS) {
        [gameVocabulary startDownload];
    }
}

-(void) unlockPlayerAchievement:(int) achievementId {
    if ([_session isUserLoggedIn]) {
        playerAchievementListAddUniqueAchievement(_unlockedAchievements,achievementId);

        if ([_session isOnline]) {
            [_session sendPlugin: MNAchievementsProviderPluginName
                         message: [NSString stringWithFormat: @"A%d", achievementId]];
        }
        else {
            [_session varStorageSetValue: [NSString stringWithFormat: @"%lld",(long long)time(NULL)]
                             forVariable: [NSString stringWithFormat: @"offline.%lld.achievement_pending.%d.date",(long long)[_session getMyUserId],achievementId]];

            [_delegates beginCall];

            for (id<MNAchievementsProviderDelegate> delegate in _delegates) {
                if ([delegate respondsToSelector: @selector(onPlayerAchievementUnlocked:)]) {
                    [delegate onPlayerAchievementUnlocked: achievementId];
                }
            }

            [_delegates endCall];
        }
    }
}

-(NSArray*) getPlayerAchievementList {
    return _unlockedAchievements;
}

-(BOOL) isPlayerAchievementUnlocked:(int) achievementId {
    return playerAchievementListContainsAchievementById(_unlockedAchievements,achievementId);
}

-(void) addDelegate:(id<MNAchievementsProviderDelegate>) delegate {
    [_delegates addDelegate: delegate];
}

-(void) removeDelegate:(id<MNAchievementsProviderDelegate>) delegate {
    [_delegates removeDelegate: delegate];
}

-(NSURL*) getAchievementImageURL:(int) achievementId {
    NSString* webServerUrl = [_session getWebServerURL];
    
    if (webServerUrl != nil) {
        return [NSURL URLWithString:
                [NSString stringWithFormat: MNAchievementsProviderImageUrlFormat,webServerUrl,[_session getGameId],achievementId]];
    }
    else {
        return nil;
    }
}

/* MNGameVocabularyDelegate protocol */
-(void) mnGameVocabularyDownloadFinished:(int) downloadStatus {
    if (downloadStatus > 0) {
        [_delegates beginCall];

        for (id<MNAchievementsProviderDelegate> delegate in _delegates) {
            if ([delegate respondsToSelector: @selector(onGameAchievementListUpdated)]) {
                [delegate onGameAchievementListUpdated];
            }
        }

        [_delegates endCall];
    }
}

/* MNSessionDelegate protocol */
-(void) mnSessionPlugin:(NSString*) pluginName messageReceived:(NSString*) message from:(MNUserInfo*) sender {
    if (sender != nil || ![pluginName isEqualToString: MNAchievementsProviderPluginName]) {
        return;
    }

    NSUInteger messageLen = [message length];

    if (messageLen == 0) {
        return;
    }

    unichar cmdChar = [message characterAtIndex: 0];

    switch (cmdChar) {
        case 'g': {
            // ignore this message, it was used in pre-1.4.0 to get latest available data version
        } break;

        case 'p': {
            NSMutableArray* newUserAchievementsArray = parseUserAchievementListMessage([message substringFromIndex: PLUGIN_MESSAGE_CMD_PREFIX_LEN]);

            if (newUserAchievementsArray != nil) {
                for (MNPlayerAchievementInfo* achievementInfo in newUserAchievementsArray) {
                    playerAchievementListAddUniqueAchievement(_unlockedAchievements,achievementInfo.achievementId);
                }

                [_session varStorageSetValue: stringWithCommaSeparatedAchievementIds(newUserAchievementsArray)
                                 forVariable: getServerUnlockedAchievementsVarNameByUserId([_session getMyUserId])];
            }
        } break;

        case 'a': {
            int achievementId;

            if (parseUserAddAchievementMessage(&achievementId,message)) {
                if (playerAchievementListAddUniqueAchievement(_unlockedAchievements,achievementId)) {
                    [_session varStorageSetValue: stringWithCommaSeparatedAchievementIds(_unlockedAchievements)
                                     forVariable: getServerUnlockedAchievementsVarNameByUserId([_session getMyUserId])];
                }

                [_delegates beginCall];

                for (id<MNAchievementsProviderDelegate> delegate in _delegates) {
                    if ([delegate respondsToSelector: @selector(onPlayerAchievementUnlocked:)]) {
                        [delegate onPlayerAchievementUnlocked: achievementId];
                    }
                }

                [_delegates endCall];
            }
        } break;

        default: {
        }break;
    }
}

-(void) mnSessionUserChangedTo:(MNUserId) userId {
    if (userId == MNUserIdUndefined) {
        [_unlockedAchievements removeAllObjects];
    }
    else {
        [self fillUnlockedAchievementsArray: _unlockedAchievements forSession: _session];
    }
}

@end

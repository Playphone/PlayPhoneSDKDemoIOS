//
//  MNGameSettingsProvider.m
//  MultiNet client
//
//  Copyright 2011 PlayPhone. All rights reserved.
//

#import "TouchXML.h"

#import "MNGameVocabulary.h"
#import "MNTools.h"
#import "MNWSXmlTools.h"
#import "MNGameSettingsProvider.h"

static NSString* MNGameSettingsProviderVocabularyFileName = @"MNGameSettingsProvider.xml";

static BOOL MNGameSettingsProviderStrToBoolean (NSString* s) {
    return [s isEqualToString: @"true"];
}

@implementation MNGameSettingInfo

@synthesize gameSetId = _id;
@synthesize name      = _name;
@synthesize params    = _flags;
@synthesize sysParams = _sysParams;
@synthesize isMultiplayerEnabled = _multiplayerEnabled;
@synthesize isLeaderboardVisible = _leaderboardVisible;

-(id) initWithId:(int) gameSetId andName:(NSString*) name {
    self = [super init];

    if (self != nil) {
        _id          = gameSetId;
        _name        = [name retain];
        _params      = nil;
        _sysParams   = nil;
        _multiplayerEnabled = NO;
        _leaderboardVisible = NO;
    }

    return self;
}

-(void) dealloc {
    [_name release];
    [_params release];
    [_sysParams release];

    [super dealloc];
}

@end


@implementation MNGameSettingsProvider

-(id) initWithSession: (MNSession*) session {
    self = [super init];

    if (self != nil) {
        _session              = session;
        _delegates            = [[MNDelegateArray alloc] init];

        [[_session getGameVocabulary] addDelegate: self];
    }

    return self;
}

-(void) dealloc {
    [[_session getGameVocabulary] removeDelegate: self];

    [_delegates release];

    [super dealloc];
}

-(NSArray*) getGameSettingList {
    NSMutableArray* gameSettings = [NSMutableArray array];
    NSData*         fileData     = [[_session getGameVocabulary] getFileData: MNGameSettingsProviderVocabularyFileName];

    if (fileData != nil) {
        NSError *error;
        CXMLDocument *document;

        document = [[CXMLDocument alloc] initWithData: fileData options: 0 error: &error];

        CXMLElement* listElement = MNWSXmlDocumentGetElementByPath(document,[NSArray arrayWithObjects: @"GameVocabulary", @"MNGameSettingsProvider", @"GameSettings", nil]);

        if (listElement != nil) {
            NSArray* items = MNWSXmlNodeParseItemList(listElement,@"entry");

            for (NSDictionary* itemData in items) {
                NSInteger itemId;

                if (MNStringScanInteger(&itemId,[itemData valueForKey: @"id"])) {
                    NSString* name      = [itemData valueForKey: @"name"];
                    NSString* params    = [itemData valueForKey: @"params"];
                    NSString* sysParams = [itemData valueForKey: @"sysParams"];

                    MNGameSettingInfo* gameSetting = [[[MNGameSettingInfo alloc] initWithId: itemId andName: name != nil ? name : @""] autorelease];

                    gameSetting.params    = params != nil ? params : @"";
                    gameSetting.sysParams = sysParams != nil ? sysParams : @"";
                    gameSetting.isMultiplayerEnabled = MNGameSettingsProviderStrToBoolean([itemData valueForKey: @"isMultiplayerEnabled"]);
                    gameSetting.isLeaderboardVisible = MNGameSettingsProviderStrToBoolean([itemData valueForKey: @"isLeaderboardVisible"]);

                    [gameSettings addObject: gameSetting];
                }
                else {
                    NSLog(@"warning: game settings data with invalid or absent game setting id ignored");
                }
            }
        }
        else {
            NSLog(@"warning: cannot find \"GameSettings\" element in game vocabulary");
        }

        [document release];
    }

    return gameSettings;
}

-(MNGameSettingInfo*) findGameSettingById:(int) gameSetId {
    MNGameSettingInfo* gameSetting;

    NSArray*   gameSettings = [self getGameSettingList];
    BOOL       found        = NO;
    NSUInteger index        = 0;
    NSUInteger count        = [gameSettings count];

    while (!found && index < count) {
        gameSetting = [gameSettings objectAtIndex: index];

        if (gameSetting.gameSetId == gameSetId) {
            found = YES;
        }
        else {
            index++;
        }
    }

    return found ? gameSetting : nil;
}

-(BOOL) isGameSettingListNeedUpdate {
    return [[_session getGameVocabulary] getVocabularyStatus] > 0;
}

-(void) doGameSettingListUpdate {
    MNGameVocabulary* gameVocabulary = [_session getGameVocabulary];

    if ([gameVocabulary getVocabularyStatus] != MN_GV_UPDATE_STATUS_DOWNLOAD_IN_PROGRESS) {
        [gameVocabulary startDownload];
    }
}

-(void) addDelegate:(id<MNGameSettingsProviderDelegate>) delegate {
    [_delegates addDelegate: delegate];
}

-(void) removeDelegate:(id<MNGameSettingsProviderDelegate>) delegate {
    [_delegates removeDelegate: delegate];
}

/* MNGameVocabularyDelegate protocol */
-(void) mnGameVocabularyDownloadFinished:(int) downloadStatus {
    if (downloadStatus >= 0) {
        [_delegates beginCall];

        for (id<MNGameSettingsProviderDelegate> delegate in _delegates) {
            if ([delegate respondsToSelector: @selector(onGameSettingListUpdated)]) {
                [delegate onGameSettingListUpdated];
            }
        }

        [_delegates endCall];
    }
}

@end

/*
 *  MNMessageCodes.h
 *  MultiNet client
 *
 *  Created by Sergey Prokhorchuk on 7/13/09.
 *  Copyright 2009 PlayPhone. All rights reserved.
 *
 */

#define MNMessageCodeLowBound              (1000)
#define MNMessageCodeOfflineDomainLowBound (MNMessageCodeLowBound + 50)

enum {
    MNMessageCodeMultiNetConfigFileBrokenError = MNMessageCodeLowBound,
    MNMessageCodeRoomIsNotReadyToStartAGameError,
    MNMessageCodeInvalidPlayerStatusValueError,
    MNMessageCodeYouMustNotBeInGamePlayToUseFacebookConnectError,
    MNMessageCodeFacebookAPIKeyOrSessionProxyURLIsInvalidOrNotSetError,
    MNMessageCodeUndefinedActionURLErrorFormat,
    MNMessageCodeInvalidUserIdInLoginMultiNetUserIdAndPhashModeInternalError,
    MNMessageCodeUserPasswordHashNotSetInLoginMultiNetUserIdAndPhashModeInternalError,
    MNMessageCodeInvalidUserIdInLoginMultiNetUserIdAndAuthSignModeInternalError,
    MNMessageCodeUserAuthSignNotSetInLoginMultiNetUserIdAndAuthSignModeInternalError,
    MNMessageCodeUserLoginNotSetInLoginMultiNetModeInternalError,
    MNMessageCodeUserPasswordNotSetInLoginMultiNetModeInternalError,
    MNMessageCodeInvalidConnectModeInternalError,
    MNMessageCodeConnectModeIsNotSetInternalError,
    MNMessageCodeUserIdNotSetInPvtMessageSendingRequestInternalError,
    MNMessageCodeMessageTextIsNotSetInPvtMessageSendingRequestInternalError,
    MNMessageCodeUserIdIsInvalidInPvtMessageSendingRequestInternalError,
    MNMessageCodeMessageTextIsNotSetInPubMessageSendingRequestInternalError,
    MNMessageCodeInvalidRoomIdInJoinBuddyRoomRequestInternalError,
    MNMessageCodeRoomIdNotSetInJoinBuddyRoomRequestInternalError,

    MNMessageCodeYouMustBeConnectedToImportYourPhotoError,
    MNMessageCodeNoAvailableImagesSourceFoundError,
    MNMessageCodeInvalidUserStatusInSetUserStatusRequestInternalError,
    MNMessageCodeUserStatusNotSetInSetUserStatusRequestInternalError,
    MNMessageCodeImageConversionToPNGFormatFailedError,
    MNMessageCodeMustBeInLobbyRoomToJoinRandomRoomError,
    MNMessageCodeGameSetIdNotSetInAutoJoinRequestInternalError,
    MNMessageCodeInvalidGameSetIdOrGameSeedInPlayGameRequestInternalError,
    MNMessageCodeGameSetIdOrGameSetParamsNotSetInPlayGameRequestInternalError,
    MNMessageCodeMustBeConnectedToImportContactsError,
    MNMessageCodeInvalidGameSetIdInNewBuddyRoomRequestInternalError,
    MNMessageCodeOneOfRequiredParametersNotSetInNewBuddyRoomRequestInternalError,

    MNMessageCodeLoginExtensionRequiredParametersNotSetError,
    MNMessageCodeLoginExtensionInvalidUserIdOrLobbyRoomSFIdReceivedError,
    MNMessageCodeFacebookConnectionAlreadyInitiatedError,
    MNMessageCodeFacebookConnectionAlreadyActiveError,
    MNMessageCodeFacebookConnectionResumeFailedError,

    MNMessageCodeHttpSystemError,
    MNMessageCodeFacebookLoginError,
    MNMessageCodeInternetConnectionNotAvailableError,
    MNMessageCodeOutOfMemoryError,
    MNMessageCodeReconnectFailedError,
    MNMessageCodeCannotGetContactListError,
    MNMessageCodeCannonOpenApplicationURLError, //43

    MNMessageCodeOfflineNeedOnlineModeError = MNMessageCodeOfflineDomainLowBound, //50
    MNMessageCodeOfflineCannotLoginOfflineWhileConnectedToServerError,
    MNMessageCodeOfflineInvalidAuthSignError,
};

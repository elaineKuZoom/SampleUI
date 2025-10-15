//
//  NSObject+ErrorMessage.m
//  ZoomVideoSample
//
//  Created by Zoom Communications on 2019/11/29.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import "NSObject+ErrorMessage.h"

@implementation NSObject (ErrorMessage)

- (NSString *)formatErrorString:(ZoomVideoSDKError)errorCode {
    switch (errorCode) {
        case Errors_Wrong_Usage:
            return @"Incorrect use";
        case Errors_Internal_Error:
            return @"Internal error";
        case Errors_Uninitialize:
            return @"Uninitialized";
        case Errors_Memory_Error:
            return @"Memory error";
        case Errors_Load_Module_Error:
            return @"Load module failed";
        case Errors_UnLoad_Module_Error:
            return @"Unload module failed";
        case Errors_Invalid_Parameter:
            return @"Parameter error";
        case Errors_Call_Too_Frequently:
            return @"interface called super frequency";
        case Errors_No_Impl:
            return @"Not implement";
        case Errors_Dont_Support_Feature:
            return @"Don't support this feature yet";
        case Errors_Unknown:
            return @"Unknown error";
        case Errors_Remove_Folder_Fail:
            return @"remove the folder fail";
        case Errors_Auth_Error:
            return @"Authentication error";
        case Errors_Auth_Empty_Key_or_Secret:
            return @"Empty key or secret";
        case Errors_Auth_Wrong_Key_or_Secret:
            return @"Incorrect key or secret";
        case Errors_Auth_DoesNot_Support_SDK:
            return @"Authenticated key or secret does not support SDK";
        case Errors_Auth_Disable_SDK:
            return @"Disabled SDK with authenticated key or secret";
        case Errors_JoinSession_NoSessionName:
            return @"Join session with no session name";
        case Errors_JoinSession_NoSessionToken:
            return @"Join session with no session token";
        case Errors_JoinSession_NoUserName:
            return @"Join session with no user name";
        case Errors_JoinSession_Invalid_SessionName:
            return @"Join session with invalid session name";
        case Errors_JoinSession_Invalid_Password:
            return @"Join session with invalid password";
        case Errors_JoinSession_Invalid_SessionToken:
            return @"Join session with invalid session token";
        case Errors_JoinSession_SessionName_TooLong:
            return @"Join session with too long session name";
        case Errors_JoinSession_Token_MismatchedSessionName:
            return @"Token session name mismatched the input session name";
        case Errors_JoinSession_Token_NoSessionName:
            return @"Token miss the session name";
        case Errors_JoinSession_Token_RoleType_EmptyOrWrong:
            return @"Token role type empty or wrong";
        case Errors_JoinSession_Token_UserIdentity_TooLong:
            return @"Token user identity too long";
        case Errors_Session_Module_Not_Found:
            return @"Module not found";
        case Errors_Session_Service_Invalid:
            return @"The service is invalid";
        case Errors_Session_Join_Failed:
            return @"Join session failed";
        case Errors_Session_No_Rights:
            return @"You don’t have permission to join this session";
        case Errors_Session_Already_In_Progress:
            return @"Joining session…";
        case Errors_Session_Dont_Support_SessionType:
            return @"Unsupported session type";
        case Errors_Session_You_Have_No_Share:
            return @"Interal no share module";
        case Errors_Session_Reconnecting:
            return @"Reconnecting session…";
        case Errors_Session_Disconnecting:
            return @"Disconnecting session…";
        case Errors_Session_Not_Started:
            return @"This session has not started";
        case Errors_Session_Need_Password:
            return @"This session requires password";
        case Errors_Session_Password_Wrong:
            return @"Incorrect password";
        case Errors_Session_Remote_DB_Error:
            return @"Error received from remote database";
        case Errors_Session_Invalid_Param:
            return @"Parameter error when joining the session";
        case Errors_Session_Client_Incompatible:
            return @"Session client incompatible, check the version";
        case Errors_Session_Account_FreeMinutesExceeded:
            return @"10,000 session minutes used up";
        case Errors_Session_Audio_Error:
            return @"Session audio module error";
        case Errors_Session_Audio_No_Microphone:
            return @"Session audio no microphone";
        case Errors_Session_Audio_No_Speaker:
            return @"Session audio no speaker";
        case Errors_Session_Video_Error:
            return @"Session video module error";
        case Errors_Session_Video_Device_Error:
            return @"Session video device module error";
        case Errors_Session_Live_Stream_Error:
            return @"Live stream error";
        case Errors_Session_Phone_Error:
            return @"Session phone feature error";
        case Errors_Dont_Support_Multi_Stream_Video_User:
            return @"Session multi stream video user not support";
        case Errors_Fail_Assign_User_Privilege:
            return @"Fail to assign the user's privilege";
        case Errors_No_Recording_In_Process:
            return @"Session not in recording";
        case Errors_Set_Virtual_Background_Fail:
            return @"Set virtual background fail";
        case Errors_Malloc_Failed:
            return @"Raw data memory allocation error";
        case Errors_Not_In_Session:
            return @"Not in session when subscribing to raw data";
        case Errors_No_License:
            return @"License without raw data";
        case Errors_Video_Module_Not_Ready:
            return @"Video module is not ready";
        case Errors_Video_Module_Error:
            return @"Video module error";
        case Errors_Video_device_error:
            return @"Video device error";
        case Errors_No_Video_Data:
            return @"No video data";
        case Errors_Share_Module_Not_Ready:
            return @"Share module is not ready";
        case Errors_Share_Module_Error:
            return @"Share module error";
        case Errors_No_Share_Data:
            return @"No sharing data";
        case Errors_Audio_Module_Not_Ready:
            return @"Audio module is not ready";
        case Errors_Audio_Module_Error:
            return @"Audio module error";
        case Errors_No_Audio_Data:
            return @"No audio data";
        case Errors_Preprocess_Rawdata_Error:
            return @"Video raw data preprocess error";
        case Errors_Rawdata_No_Device_Running:
            return @"Raw data error of no device running";
        case Errors_Rawdata_Init_Device:
            return @"Raw data init device error";
        case Errors_Rawdata_Virtual_Device:
            return @"Raw data virtural device error";
        case Errors_Rawdata_Cannot_Change_Virtual_Device_In_Preview:
            return @"Raw data preview virtrual device error";
        case Errors_Rawdata_Internal_Error:
            return @"Raw data internal error";
        case Errors_Rawdata_Send_Too_Much_Data_In_Single_Time:
            return @"Raw data too much data in single time";
        case Errors_Rawdata_Send_Too_Frequently:
            return @"Raw data send to frequency";
        case Errors_Rawdata_Virtual_Mic_Is_Terminate:
            return @"Raw data virtual micphone terminate";
        case Errors_Rawdata_Invalid_Share_Preprocessing_Data_Object:
            return @"invalid preprocessing raw data";
        case Errors_Rawdata_Share_Preprocessing_Is_Stopped:
            return @"proprocessing is stopped";
        case Errors_Session_Share_Error:
            return @"Session share error";
        case Errors_Session_Share_Module_Not_Ready:
            return @"Session share module not ready";
        case Errors_Session_Share_You_Are_Not_Sharing:
            return @"Session share you not in sharing";
        case Errors_Session_Share_Type_Is_Not_Support:
            return @"Session not support share";
        case Errors_Session_Share_Internal_Error:
            return @"Session share internal error";
        case Errors_Session_Filetransfer_UnknownError:
            return @"Session filetransfer error";
        case Errors_Session_Filetransfer_FileTypeBlocked:
            return @"Session filetransfer fail by file type be blocked";
        case Errors_Session_Filetransfer_FileSizelimited:
            return @"Session filetransfer fail by file size limited";
        case Errors_Spotlight_NotEnoughUsers:
            return @"Spotlight NotEnoughUsers for sport > 3";
        case Errors_Spotlight_ToMuchSpotlightedUsers:
            return @"Spotlight ToMuchSpotlightedUsers <= 9";
        case Errors_Spotlight_UserCannotBeSpotlighted:
            return @"Spotlight user cannot be spotlighted";
        case Errors_Spotlight_UserWithoutVideo:
            return @"Spotlight user without video";
        case Errors_Spotlight_UserNotSpotlighted:
            return @"Spotlight user not be spotlight currently";
        default:
            return [NSString stringWithFormat:@"NOT Mapping now. %s %@", __FUNCTION__, @(errorCode)];
    }
    
    return nil;
}

@end

//
//  DemoTestView.m
//  ZoomVideoSample
//
//  Created by ZOOM  on 2025/5/19.
//  Copyright © 2025 Zoom. All rights reserved.
//

#import "DemoTestSubsessionView.h"

#define  ACTION  @"action"

@interface DemoTestSubsessionView()<UITableViewDelegate,UITableViewDataSource,UIPickerViewDataSource,UIPickerViewDelegate>
{
    ZoomVideoSDKUser *_myUser ;
    NSArray* _remoteUsers;
    NSArray *_action;
    NSMutableDictionary *_acitonUser;
    NSMutableArray *_acitonUsers;
    NSMutableArray *_mAcitons;

    ZoomVideoSDKSubSessionKit *_selectSessionKit;
}
@property (nonatomic,strong) UIPickerView *pickView;
@end

@implementation DemoTestSubsessionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame style:UITableViewStylePlain]) {
        _myUser = [[[ZoomVideoSDK shareInstance]getSession]getMySelf];
        _remoteUsers = [[[ZoomVideoSDK shareInstance] getSession ]getRemoteUsers];
        _action = @[@"Join",@"Leave"];
//        [self addSubview:self.pickView];
        _acitonUsers = [NSMutableArray array];
        _mAcitons = [NSMutableArray array];
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}



- (void)setSessionManager:(ZoomVideoSDKSubSessionManager *)sessionManager {
    if (sessionManager) {
        [_mAcitons addObjectsFromArray:@[@"addSubSessionToPreList",@"removeSubSessionFromPreList",@"clearSubSessionPreList",@"getSubSessionPreList",@"commitSubSessionList",@"getCommittedSubSessionList",@"startSubSession",@"stopSubSession",@"broadcastMessage"]];
    }
    else {
        [_mAcitons removeObjectsInArray:@[@"addSubSessionToPreList",@"removeSubSessionFromPreList",@"clearSubSessionPreList",@"getSubSessionPreList",@"commitSubSessionList",@"getCommittedSubSessionList",@"startSubSession",@"stopSubSession",@"broadcastMessage"]];
    }
    _sessionManager = sessionManager;
}

- (void)setPParticipant:(ZoomVideoSDKSubSessionParticipant *)pParticipant {
    if(pParticipant) {
        [_mAcitons addObjectsFromArray:@[@"returnToMainSession",@"requestForHelp"]];
    }
    else {
        [_mAcitons removeObjectsInArray:@[@"returnToMainSession",@"requestForHelp"]];
    }
    _pParticipant = pParticipant;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger num = 0;
    switch (component) {
        case 0:
            num = 2;
            break;
        case 1:
            num = _remoteUsers.count;
            break;
        case 2:
            num = _pSubSessionKitList.count;
            break;
    }
    return num;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *name = @"";
    switch (component) {
        case 0:
            name =_action[row];
            break;
        case 1:
        {
            ZoomVideoSDKUser *user = _remoteUsers[row];
            name = [user getUserName];
        }
            break;
        case 2:
        {
            ZoomVideoSDKSubSessionKit* kit = _pSubSessionKitList[row];
            name = [kit getSubSessionName];
        }
            break;
    }
    return name;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 150;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 150;
}

    //Called when selecting a specific row in a specific column
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"component = %ld-----row = %ld",component,row);
    switch (component) {
        case 0:
            [_acitonUser setObject:_action[row] forKey:@"action"];
            break;
        case 1:
        {
            ZoomVideoSDKUser *user = _remoteUsers[row];
            [_acitonUser setObject:user forKey:@"user"];
        }
            break;
        case 2:
        {
            ZoomVideoSDKSubSessionKit* kit = _pSubSessionKitList[row];
            [_acitonUser setObject:kit forKey:@"kit"];
        }
            break;
    }
    
    [_acitonUsers addObject:_acitonUser];
    [self reloadData];
}

- (UIPickerView *)pickerView {
    if (!_pickView) {
        _pickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds)/2, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)/2)];
        _pickView.delegate = self;
        _pickView.dataSource = self;
    }
    return _pickView;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2+self.pSubSessionKitList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
        {
            return _acitonUsers.count;
        }
            break;
        case 1:
        {
            return _mAcitons.count;
        }
    }
    if (section > 1) {
        ZoomVideoSDKSubSessionKit *kit = _pSubSessionKitList[section -2];
        return [kit getSubSessionUserList].count;
    }
    return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            static NSString *cellID = @"SECTION1";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            }
            NSDictionary *tmpD =  _acitonUsers[indexPath.row];
            cell.textLabel.text = tmpD.description;
            return cell;

        }
            break;
        case 1:
        {
            UITableViewCell *cell;
            static NSString *cellID = @"SECTION2";
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            cell.textLabel.text =  _mAcitons[indexPath.row];
            return cell;
        }
    }
    if (indexPath.section > 1) {
        ZoomVideoSDKSubSessionKit *kit = _pSubSessionKitList[indexPath.section -2];
        static NSString *cellID = @"SECTION3";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        ZoomVideoSDKSubSessionUser *subUser = [kit getSubSessionUserList][indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"Sub user:%@ id:%@",[subUser getUserName],[subUser getUserGUID]];
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            NSDictionary *tmpD =  _acitonUsers[indexPath.row];
            NSMutableDictionary *sendInfo = [NSMutableDictionary dictionary];
            [sendInfo setObject:tmpD[@"action"] forKey:@"action"];
            ZoomVideoSDKSubSessionKit* kit = tmpD[@"kit"] ;
            [sendInfo setObject:[kit getSubSessionID] forKey:@"kit"];
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendInfo options:0 error:nil];
            if (error) {
                NSLog(@"err: %@", error);
                return;
            }
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            ZoomVideoSDKUser *user = tmpD[@"user"];
            ZoomVideoSDKError ret = [[[ZoomVideoSDK shareInstance] getCmdChannel] sendCommand:jsonString receiveUser:user];
            NSLog(@"Reaction::sendCommand===>%@",ret == Errors_Success ? @"YES" : @"NO");

        }
            break;
            
        case 1:
        {

            if (_myUser.isHost || _myUser.isManager) {
                if (_sessionManager) {
                    
                    ZoomVideoSDKError ret;
                    if (@"broadcastMessage" == _mAcitons[indexPath.row]) {
                        NSString *msg = [NSString stringWithFormat:@"broadcastMessage ---- %d",arc4random()%100];
                        ret = [_sessionManager broadcastMessage:msg];
                    }
                    else if (@"startSubSession" == _mAcitons[indexPath.row]) {
                        ret = [_sessionManager startSubSession];
                    }
                    else if (@"stopSubSession" == _mAcitons[indexPath.row]) {
                        ret = [_sessionManager stopSubSession];
                    }
                    else if (@"addSubSessionToPreList" == _mAcitons[indexPath.row]) {
                        int i = 5;
                        NSMutableArray *arr = [NSMutableArray array];
                        while (i>0) {
                            [arr addObject:[NSString stringWithFormat:@"subsession%d",arc4random()%100]];
                            i--;
                        }
                        ret = [[[ZoomVideoSDK shareInstance] getsubSessionHelper] addSubSessionToPreList:arr];
                        NSLog(@"addSubSessionToPreList:%@ ret:%lu",arr.description,(unsigned long)ret);
                    }
                    else if (@"removeSubSessionFromPreList" == _mAcitons[indexPath.row]) {
                        NSArray *arr1 = [[[ZoomVideoSDK shareInstance] getsubSessionHelper] getSubSessionPreList];
                                if (arr1.count < 2) {
                                    return;
                                }
                        NSArray *arr2 = @[arr1[0],arr1[1]];
                        ret = [[[ZoomVideoSDK shareInstance] getsubSessionHelper] removeSubSessionFromPreList:arr2];
                        NSLog(@"removeSubSessionFromPreList %@  %@ ret:%lu",_mAcitons[indexPath.row],arr2,(unsigned long)ret);
                    }
                    else if (@"clearSubSessionPreList" == _mAcitons[indexPath.row]) {
                        ret = [[[ZoomVideoSDK shareInstance] getsubSessionHelper] clearSubSessionPreList];
                        NSLog(@"clearSubSessionPreList ret:%lu",(unsigned long)ret);
                    }else if (@"getSubSessionPreList" == _mAcitons[indexPath.row]) {
                        NSLog(@"getSubSessionPreList:%@",[[[ZoomVideoSDK shareInstance] getsubSessionHelper] getSubSessionPreList].description);
                        
                    }else if (@"commitSubSessionList" == _mAcitons[indexPath.row]) {
                        ret =[[[ZoomVideoSDK shareInstance] getsubSessionHelper] commitSubSessionList];;
                        NSLog(@"commitSubSessionList ret:%lu",(unsigned long)ret);
                    }else if (@"getCommittedSubSessionList" == _mAcitons[indexPath.row]) {
                        NSLog(@"getSubSessionPreList:%@",[[[ZoomVideoSDK shareInstance] getsubSessionHelper] getCommittedSubSessionList].description);
                    }
                    NSLog(@"sel:%@ ret:%@",_mAcitons[indexPath.row],@(ret));
                }
            }
            else if (_pParticipant) {
                ZoomVideoSDKError ret;
                if (@"requestForHelp" == _mAcitons[indexPath.row]) {
                    ret = [_pParticipant requestForHelp];
                }
                else if (@"returnToMainSession" == _mAcitons[indexPath.row]) {
                    ret = [_pParticipant returnToMainSession];
                }
                NSLog(@"%@  %@",_mAcitons[indexPath.row],@(ret));
            }

        }
            
        default:
            break;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
        {
            return 20;
        }
            break;
            
        case 1:
        {
            return 20;
        }
            break;
    }
    if (section > 1) {
        return 45;
    }
    return 20;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
        {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 20)];
            UITextField *txtView = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 20)];
            txtView.text = [NSString stringWithFormat:@"%@ %@", _myUser.getUserName,_myUser.isHost || _myUser.isManager|| _myUser.isHost ?@"Host/Manager":@"Attenden"];
            [view addSubview:txtView];
            return view;
        }
            break;
            
        case 1:
        {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 20)];
            UITextField *txtView = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 20)];
            if (_myUser.isHost || _myUser.isManager) {
                if (_sessionManager) {
                    txtView.text =  [NSString stringWithFormat:@"isSubSessionStarted %@", @([_sessionManager isSubSessionStarted])];
                }
                
                [view addSubview:txtView];
                return view;
            }
            break;
        }
        default:
        {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 40)];
            UITextField *txtView = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 20)];
            ZoomVideoSDKSubSessionKit *kit = _pSubSessionKitList[section -2];
            txtView.text =  [NSString stringWithFormat:@"Sub:%@ ID:%@",[kit getSubSessionName],[kit getSubSessionID]];
            [view addSubview:txtView];
            UIButton *btn  = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.backgroundColor = [UIColor blueColor];
            [view addSubview:btn];
            [btn setTitle:@"joinSubSession" forState:UIControlStateNormal];
            btn.frame = CGRectMake(30, 20, 200, 20);
            [btn addTarget:self action:@selector(joinSubSessionAction:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = section -2;
            return view;
        }
            break;
        
    }
    return nil;
}

- (void)joinSubSessionAction:(UIButton *)sender {
    NSInteger section = sender.tag;
    ZoomVideoSDKSubSessionKit* sessionKit = _pSubSessionKitList[section];
    ZoomVideoSDKError ret = [sessionKit joinSubSession];
    if (ret == Errors_Success) {
        self.joinedSubSessionkit = sessionKit;
    }
    NSLog(@"joinSubSession ret %lu",(unsigned long)ret);
}

@end

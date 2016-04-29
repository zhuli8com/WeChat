//
//  ViewController.m
//  WeChat
//
//  Created by account on 15/9/17.
//  Copyright (c) 2015年 zhuli8. All rights reserved.
//

#import "MXMessageViewController.h"
#import "MXConversation.h"
#import "MXMQTTManager.h"
#import <FMDB.h>

@interface MXMessageViewController () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic,strong) NSMutableArray<MXConversation *> *conversations;
@property (nonatomic,strong) UITableView *messageTableView;
@property (nonatomic,strong) UITextField *messageTextField;
@end

@implementation MXMessageViewController
#pragma mark - life cycles
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor=[UIColor whiteColor];
    [MX_MQTTManager initMQTT];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mqttHandleMessage:) name:kMQTTHandleMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.view addSubview:self.messageTableView];
    [self.view addSubview:self.messageTextField];
    
    [self.messageTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    [self.messageTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.equalTo(self.view);
        make.bottom.equalTo(self.messageTextField.mas_top);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - kMQTTHandleMessageNotification
- (void)mqttHandleMessage:(NSNotification *)notification{
    MXConversation *conversation=notification.object;
    __block BOOL haved=NO;
    [self.conversations enumerateObjectsUsingBlock:^(MXConversation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MXConversation *c=(MXConversation *)obj;
        if (conversation.ID==c.ID) {
            haved=YES;
            *stop=YES;
        }
    }];
    if (!haved) {
        [self.conversations addObject:conversation];
        [self.messageTableView reloadData];
        
        NSURL *aURL=[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSLog(@"aPath=%@",aURL.path);
        FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:[aURL.path stringByAppendingPathComponent:@"minxing.db"]];
        [queue inDatabase:^(FMDatabase *db) {
            //int real text blob
            [db executeUpdate:@"create table if not exists t_conversation (id int primary key,sender_id int,conversation_id long,created_at text,system bool,type text,direct_to_user_id int,network_id int,body text,message_type text)"];
            //insert into 表名后面没有列是插入不进库的，所有数据都必须转成OC的对象
            [db executeUpdate:@"replace into t_conversation(id,sender_id,conversation_id,created_at,system,type,direct_to_user_id,network_id,body,message_type) values(?,?,?,?,?,?,?,?,?,?)",@(conversation.ID),@(conversation.sender_id),@(conversation.conversation_id),conversation.created_at,@(conversation.system),conversation.type,@(conversation.direct_to_user_id),@(conversation.network_id),conversation.body,conversation.message_type];
        }];
    }
}

#pragma mark - UIKeyboardWillShowNotification
- (void)keyboardWillShow:(NSNotification *)notification{
    CGRect keyboardFrame=[[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight=keyboardFrame.size.height;
    [self.messageTextField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-keyboardHeight);
    }];
    [self.messageTableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.messageTextField.mas_top);
    }];
    
    //解决键盘弹出时的黑屏问题
    CGFloat animationDuration=[[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - UIKeyboardWillHideNotification
- (void)keyboardWillHide:(NSNotification *)notification{
    [self.messageTextField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
    }];
    [self.messageTableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.messageTextField.mas_top);
    }];
    
    //解决键盘退出时的灰影问题
    CGFloat animationDuration=[[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.conversations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellName=@"UITableViewCellName";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        cell.backgroundColor=[UIColor grayColor];
    }
    MXConversation *conversatoion=((MXConversation *)self.conversations[indexPath.row]);
    cell.textLabel.text=conversatoion.body;
    return cell;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    int result= [MX_MQTTManager sendMessage:textField.text];
    if (result) {
        NSLog(@"发送成功");
    }else{
        NSLog(@"发送失败");
    }
    textField.text=@"";
    return YES;
}

#pragma mark - UITapGestureRecognizer
- (void)tapMessageTableView:(UITapGestureRecognizer *)gesture{
    [self.messageTextField resignFirstResponder];
}

#pragma makr - getters and setters
- (UITableView *)messageTableView{
    if (!_messageTableView) {
        _messageTableView=[[UITableView alloc] init];
        _messageTableView.delegate=self;
        _messageTableView.dataSource=self;
//        _messageTableView.tableFooterView=[[UIView alloc] init];
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMessageTableView:)];
        [_messageTableView addGestureRecognizer:tapGesture];
    }
    return _messageTableView;
}

- (UITextField *)messageTextField{
    if (!_messageTextField) {
        _messageTextField=[[UITextField alloc] init];
        _messageTextField.backgroundColor=[UIColor lightGrayColor];
        _messageTextField.delegate=self;
        _messageTextField.returnKeyType=UIReturnKeySend;
        _messageTextField.borderStyle=UITextBorderStyleRoundedRect;
        _messageTextField.alpha=0.5;
    }
    return _messageTextField;
}

- (NSMutableArray<MXConversation *> *)conversations{
    if (!_conversations) {
        _conversations=[NSMutableArray array];
    }
    return _conversations;
}
@end

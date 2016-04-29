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

@interface MXMessageViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *messageTableView;
@property (nonatomic,strong) NSMutableArray<MXConversation *> *conversations;
@end

@implementation MXMessageViewController
#pragma mark - life cycles
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [MX_MQTTManager initMQTT];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mqttHandleMessage:) name:kMQTTHandleMessageNotification object:nil];
    
    [self.view addSubview:self.messageTableView];
    [self.messageTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
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

#pragma makr - getters and setters
- (UITableView *)messageTableView{
    if (!_messageTableView) {
        _messageTableView=[[UITableView alloc] init];
        _messageTableView.delegate=self;
        _messageTableView.dataSource=self;
//        _messageTableView.tableFooterView=[[UIView alloc] init];
    }
    return _messageTableView;
}

- (NSMutableArray<MXConversation *> *)conversations{
    if (!_conversations) {
        _conversations=[NSMutableArray array];
    }
    return _conversations;
}
@end

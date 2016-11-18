//
//  FQDemoViewController.m
//  11-9 buttonsLayout
//
//  Created by FQ on 16/11/9.
//  Copyright © 2016年 FQ. All rights reserved.
//

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width

#import "FQDemoViewController.h"
#import "FQDemoView.h"
#import "FQHisButton.h"
#import "NSArray+Log.h"
#import "FQFmdbTool.h"
#import "ArchiveModel.h"

@interface FQDemoViewController ()<UISearchBarDelegate>
@property (nonatomic, strong) FQDemoView *demoView;
/** 将从数据库读取的数据 保存至模型数组 */
@property (nonatomic, strong) NSMutableArray *modelArr;
/** 从数据库读取的模型数据中的name字段 */
@property (nonatomic, strong) NSMutableArray *dataArr;
@end

@implementation FQDemoViewController

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (NSMutableArray *)modelArr {
    if (!_modelArr) {
        _modelArr = [NSMutableArray array];
    }
    return _modelArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"DataBasePath---%@",[FQFmdbTool getDataBasePath]);
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 搜索框
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
    searchBar.delegate = self;
    [self.view addSubview:searchBar];
    
    FQDemoView* demoView = [[FQDemoView alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64)];
    demoView.contentSize = CGSizeMake(kScreenWidth, kScreenHeight);
    self.demoView = demoView;
    [self.view addSubview:demoView];
    
    [demoView updataSourceData:^(NSString *name, NSInteger tag) { // 删除一条数据
        
        [self deleteCurrentHistoryWithName:name ID_No:tag];
        
    } clearSourceData:^{ // 清除数据库
        
        [FQFmdbTool deleteAllHistory]; // 清除数据库
        [self.modelArr removeAllObjects]; // 清除数组中的数据
        [self.dataArr  removeAllObjects];
        
    }seachWithContent:^(NSString *string) { // 点击已存在的历史记录，跳转到搜索结果页面
        
        [self deleteToConfigurationByNameString:string]; // 先删除 ，后增加
        [self insertHistoryText:string]; // 增加（添加一条数据）
    }];
    
    // 清除第五行
    demoView.removeFiveLineBlock = ^(NSMutableArray* array){
    
        NSLog(@"第五行的%@",array);
        for (NSString* name in array) {
            [self deleteToConfigurationByNameString:name];
        }
    };
    
    // 搜索发现的内容
    demoView.recomandBlock = ^(NSString* name){
        
        if ([FQFmdbTool isExistSearchText:name]) {
            NSLog(@"搜索文本存在，要改变文本在数据库中的位置，并重新排布");
            [self deleteToConfigurationByNameString:name]; // 先删除 ，后增加
            [self insertHistoryText:name]; // 增加（添加一条数据）
        }else{
            NSLog(@"搜索文本不存在，添加这条数据到数据库中");
            [self insertHistoryText:name]; // 添加一条数据
        }
    };
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self loadData];
    });
    
    [self loadDB];
    
}

- (void)loadData
{
    NSArray* dataArr = @[@"葡萄牙",@"书籍",@"浮沉浪似人潮哪会没有思念",@"意大利"];
    NSMutableArray* mutArr = [NSMutableArray arrayWithArray:dataArr];
    [self.demoView layoutRecomandButtonsWithArr:mutArr];
    
}

/**
 *  加载数据库，给buttons赋值
 */
- (void)loadDB
{
    [self.modelArr removeAllObjects];
    [self.dataArr removeAllObjects];
    NSArray *models = [FQFmdbTool queryData:nil]; 
    [self.modelArr addObjectsFromArray:models];
    
    for (ArchiveModel* model in self.modelArr) {
        [self.dataArr addObject:model.name];
    }
    // 赋值buttons
    [self.demoView layoutButtonsWithArr:self.dataArr];

}

/**
 *  确认搜索
 *
 *  @param searchBar
 */
#define marginLeft 10
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (searchBar.text.length == 0) {
        return;
    }
    // 如果长度太长超过 kScreenWidth - 2*marginLeft ，就要进行截取了
    CGFloat textW = [searchBar.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil].size.width;
    if (textW > kScreenWidth - 2*marginLeft) {
        textW = kScreenWidth - 2*marginLeft;
        NSString* subString = [self constructStringWith:searchBar.text width:textW]; // 字符串截取
        searchBar.text = subString;
    }
    
    if ([FQFmdbTool isExistSearchText:searchBar.text]) {
        NSLog(@"搜索文本存在，要改变文本在数据库中的位置，并重新排布");
        [self deleteToConfigurationByNameString:searchBar.text]; // 先删除 ，后增加
        [self insertHistoryText:searchBar.text]; // 增加（添加一条数据）
    }else{
        NSLog(@"搜索文本不存在，添加这条数据到数据库中");
        [self insertHistoryText:searchBar.text]; // 添加一条数据
    }
    
    searchBar.text = nil;
}

/**
 *  搜索框内容过长，进行前后的裁剪，中间部分用...代替
 */
- (NSString*)constructStringWith:(NSString*)originalString width:(CGFloat)textW
{
    
    CGFloat middelW = 10.687500;  // 中间 ... 的长度
    CGFloat leftW   = (kScreenWidth - 2*marginLeft - middelW - 35)/2;  // 35 为自己设置的弹性值,ps：小于35会产生自动换行
    CGFloat rightW  = leftW;
    NSString* leftString  = [self getLeftStringWith:originalString width:leftW];
    NSString* rightString = [self getRightStringWith:originalString width:rightW];
    NSString* constructString = [NSString stringWithFormat:@"%@...%@",leftString,rightString];
    return constructString;
}
/**
 *  获取左边的字符串
 */
- (NSString*)getLeftStringWith:(NSString*)originalString width:(CGFloat)leftW
{

    // 获取前一半的字符串
    NSString* leftString = [originalString substringWithRange:NSMakeRange(0, originalString.length/2)];
    
    NSString* cutString = leftString;
    CGFloat   length    = leftString.length;
    BOOL      findIt    = NO;
    
    while (!findIt) {
        length--;
        if (length<=0) {
            return nil;
        }
         cutString = [cutString substringWithRange:NSMakeRange(0, length)];
         CGFloat textW = [cutString boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil].size.width;
        if (textW <= (leftW+12) && textW >= (leftW-12)) {
            NSLog(@"左边字符串裁剪完毕");
            findIt = YES;
        }
        
    }
   
    return cutString;
}
/**
 *  获取右边的字符串
 */
- (NSString*)getRightStringWith:(NSString*)originalString width:(CGFloat)rightW
{
    
    // 获取后一半的字符串
    NSString* rightString = [originalString substringFromIndex:(NSInteger)originalString.length/2];
    
    NSString* cutString = rightString;
    CGFloat   length    = 0;
    BOOL      findIt    = NO;
    
    while (!findIt) {
        length++;
        if (length>=rightString.length) {
            return nil;
        }
        cutString     = [rightString substringFromIndex:length];
        CGFloat textW = [cutString boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil].size.width;
        if (textW <= (rightW+12) && textW >= (rightW-12)) {
            NSLog(@"右边字符串裁剪完毕");
            findIt = YES;
        }
        
    }
    return cutString;
}

/**
 *  删除一条数据
 *
 *  @param name text
 *  @param tag  tag
 */
- (void)deleteCurrentHistoryWithName:(NSString*)name ID_No:(NSInteger)tag
{
    
    ArchiveModel* model = [ArchiveModel modelWith:name no:tag+1];
    BOOL delete = [FQFmdbTool deleteData:model];
    if (delete) {
        NSLog(@"删除数据成功%@,%ld",model.name,(long)model.ID_No);
        // 重新获取数据库中的数据，重新写入，并修改所有历史记录的ID_No
        [self modifyAllHistory];
    }else{
        NSLog(@"删除数据失败");
    }
    
    // 更新数据库
    [self loadDB];
    
}

/**
 *  删除一条数据--（搜索重名的时候，需要将位置移动到第一个，因此要首先删除掉之前的数据）
 *
 *  @param name text
 */
- (void)deleteToConfigurationByNameString:(NSString*)name
{
    BOOL delete = [FQFmdbTool deleteByNameString:name];
    if (delete) {
        NSLog(@"删除%@成功",name);
        // 重新获取数据库中的数据，重新写入，并修改所有历史记录的ID_No
        [self modifyAllHistory];
    }else{
        NSLog(@"删除%@失败",name);
    }
    
    // 更新数据库
    [self loadDB];
    
}

/**
 *  从searchBar插入一条数据
 *
 *  @param text
 */
- (void)insertHistoryText:(NSString*)text
{
    // 插入数据
    ArchiveModel* model = [ArchiveModel modelWith:text no:self.modelArr.count+1];
    BOOL insert = [FQFmdbTool insertModel:model];
    if (insert) {
        NSLog(@"插入数据成功%@,%ld",model.name,(long)model.ID_No);
    }else{
        NSLog(@"插入数据失败");
    }
    // 更新数据库
    [self loadDB];
    
}

/**
 *  删除后，重写数据到数据库----插入一条数据
 *
 *  @param text  text
 *  @param index tag
 */
- (void)insertRewriteHistoryText:(NSString*)text index:(NSInteger)index
{
    // 插入数据
    ArchiveModel* model = [ArchiveModel modelWith:text no:index];
    BOOL insert = [FQFmdbTool insertModel:model];
    if (insert) {
        NSLog(@"重新插入数据成功%@,%ld",model.name,(long)model.ID_No);
    }else{
        NSLog(@"重新插入数据失败");
    }
    
}

/**
 *  删除后，要重新写入数据到数据库中
 */
- (void)modifyAllHistory
{
    
    [self.modelArr removeAllObjects];
    [self.dataArr  removeAllObjects];
    NSArray *models = [FQFmdbTool queryData:nil];
    [self.modelArr addObjectsFromArray:models];
    
    // 先清除数据库
    [FQFmdbTool deleteAllHistory];
    
    // 再添加数据至数据库
    NSInteger index = 0;
    for (ArchiveModel* model in self.modelArr) {
        index++;
        [self insertRewriteHistoryText:model.name index:index];
    }
    // 更新数据库并赋值
    [self loadDB];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

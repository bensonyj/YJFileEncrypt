//
//  ViewController.m
//  YJFileEncrypt
//
//  Created by yingjian on 2016/10/25.
//  Copyright © 2016年 yingjian. All rights reserved.
//

#import "ViewController.h"
#import "NSString+AES.h"

@interface ViewController ()<NSTableViewDataSource,NSTableViewDelegate>
{
    NSOpenPanel *oPanel;
}

@property (weak) IBOutlet NSTableView *tableView;

@property (weak) IBOutlet NSButton *addButton;
@property (weak) IBOutlet NSButton *chooseButton;
@property (weak) IBOutlet NSButton *confirmButton;

@property (weak) IBOutlet NSTextField *addressTextField;

/** 允许选择加密文件的类型 */
@property (nonatomic, strong) NSMutableArray *fileTpyes;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    [self initUI];
}

- (void)initUI
{
    self.addButton.layer.backgroundColor = [NSColor whiteColor].CGColor;
    self.chooseButton.layer.backgroundColor = [NSColor whiteColor].CGColor;
    self.confirmButton.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    // 默认可加密文件类型
    [self.fileTpyes addObjectsFromArray:@[@"h",@"m",@"mm",@"txt",@"xml",@"java",@"html",@"md"]];
    
    oPanel = [NSOpenPanel openPanel];
    //可以打开目录
    [oPanel setCanChooseDirectories:YES];
    //不能打开文件
    [oPanel setCanChooseFiles:YES];
    //起始目录
    [oPanel setDirectoryURL:[NSURL URLWithString:NSHomeDirectory()]];
    //允许选择的文件类型，如果都可以的话，就写nil
    [oPanel setAllowedFileTypes:self.fileTpyes];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)chooseClickek:(id)sender {
    [oPanel beginSheetModalForWindow:[self.view window] completionHandler: (^(NSInteger result){
        if(result == NSModalResponseOK) {
            NSString *string = [[[oPanel URLs] objectAtIndex:0] absoluteString];
            //        NSLog(@"%@", string);
            //我在console输出这个目录的地址
            self.addressTextField.stringValue = [string stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        }
    })];
}

- (IBAction)confirmClicked:(id)sender {
    if ([self.addressTextField.stringValue length] == 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"please select address"];
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert runModal];
        
        return;
    }
    [self listFileAtPath:self.addressTextField.stringValue];
}

- (void)listFileAtPath:(NSString *)pathName {
    NSError *error;
    NSArray *contentOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathName error:&error];
    if (error) {
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];

        return;
    }
    self.addressTextField.stringValue = @"";
    
//    NSMutableArray *temps = [NSMutableArray arrayWithCapacity:3];
    for (NSString *aPath in contentOfFolder) {
        NSString * fullPath = [pathName stringByAppendingPathComponent:aPath];
        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) {
            [self listFileAtPath:fullPath];
        }else{
            NSString *fileName = [fullPath lastPathComponent];
            NSLog(@"具体路径：%@，文件：%@", fullPath,fileName);

            NSArray *types = [fileName componentsSeparatedByString:@"."];
            if (![self.fileTpyes containsObject:[types lastObject]]) {
                return;
            }
            
            NSData *data = [NSData dataWithContentsOfFile:fullPath];
            NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSString *key = [self randomStringWithLength:16];
            
            NSString *result = [content AES256EncryptWithKey:key];
            BOOL res = [result writeToFile:fullPath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
#ifdef DEBUG
            NSLog(@"数据：%@\n写入结果：%@",result,@(res));
#endif
        }
    }
}

- (NSString *)randomStringWithLength:(int)len
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((int)[letters length])]];
    }
    
    return randomString;
}

- (IBAction)addClicled:(id)sender {
    [self.tableView beginUpdates];
    [self.fileTpyes addObject:@"enter type"];
    [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:0] withAnimation:NSTableViewAnimationSlideDown];
    [self.tableView editColumn:0 row:([self.fileTpyes count] - 1) withEvent:nil select:YES];
    [self.tableView endUpdates];
}

#pragma mark -
#pragma mark TableView datasource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.fileTpyes.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    return [self.fileTpyes objectAtIndex:row];
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return YES;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([(NSString *)object isEqualToString:@""]) {
        [tableView beginUpdates];
        [tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:NSTableViewAnimationSlideUp];
        [self.fileTpyes removeObjectAtIndex:row];
        [tableView endUpdates];
    }else{
        [self.fileTpyes replaceObjectAtIndex:row withObject:object];
    }
    [oPanel setAllowedFileTypes:self.fileTpyes];
}

#pragma mark - lazy

- (NSMutableArray *)fileTpyes
{
    if (!_fileTpyes) {
        _fileTpyes = [NSMutableArray arrayWithCapacity:3];
    }
    
    return _fileTpyes;
}

@end

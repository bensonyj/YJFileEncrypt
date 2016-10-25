//
//  NSString+AES.h
//  Mactest
//
//  Created by yingjian on 2016/10/20.
//  Copyright © 2016年 yingjian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (AES)

- (NSString *)AES256EncryptWithKey:(NSString *)key;

@end

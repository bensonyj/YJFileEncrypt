//
//  NSData+AES.h
//  Mactest
//
//  Created by yingjian on 2016/10/20.
//  Copyright © 2016年 yingjian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES)

//加密
- (NSData *)AES128EncryptWithKey:(NSString *)key iv:(NSString *)iv;

//解密
- (NSData *)AES128DecryptWithKey:(NSString *)key iv:(NSString *)iv;

- (NSString *)base64Encoding;

- (NSData *)AES256EncryptWithKey:(NSString *)key;

@end

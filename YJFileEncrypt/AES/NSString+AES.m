//
//  NSString+AES.m
//  Mactest
//
//  Created by yingjian on 2016/10/20.
//  Copyright © 2016年 yingjian. All rights reserved.
//

#import "NSString+AES.h"
#import "NSData+AES.h"

@implementation NSString (AES)

- (NSString *)AES256EncryptWithKey:(NSString *)key
{
    NSData *plainData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [plainData AES256EncryptWithKey:key];
    
    NSString *encryptedString = [encryptedData base64Encoding];
    
    return encryptedString;
}

@end

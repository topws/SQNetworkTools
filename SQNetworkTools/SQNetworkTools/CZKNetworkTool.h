//
//  CZKNetworkTool.h
//  SQNetworkTools
//
//  Created by 钱卫 on 16/4/24.
//  Copyright © 2016年 钱卫. All rights reserved.
//

#import <Foundation/Foundation.h>

//定义 block类型：
typedef void(^FailBlock)(NSError *error);

typedef void(^SuccessBlock) (id responseObj ,NSURLResponse * response);
@interface CZKNetworkTool : NSObject
//网络工具，为一个单例

/// POST
///
/// @param urlString  网络接口
/// @param paramaters 参数字典
/// @param success    成功的回调
/// @param fail       失败的回调
-(void)POSTdataWithUrlString:(NSString *)urlString
                  paramaters:(NSDictionary *)paramaters
                SuccessBlock:(SuccessBlock)success
                   FailBlock:(FailBlock)fail;
/// GET
///
/// @param urlString  网络接口
/// @param paramaters 参数字典
/// @param success    成功的回调
/// @param fail       失败的回调
-(void)GETdataWithUrlString:(NSString *)urlString
                 paramaters:(NSDictionary *)paramaters
               SuccessBLock:(SuccessBlock)success
                  FailBlock:(FailBlock)fail;

//多文件上传。网络完成之后的回调
//completionHandler:如果后台返回的是JSON 数据，自动解析后，将JSON 数据传递给外界(responseObj:就是JSON解析之后的数据)如果
//不是JSON数据，直接传给外界data（responseObj就是NSData）
-(void)POSTuploadWithUrlString:(NSString *)urlString
                     faileDict:(NSDictionary *)fileDict
                       fileKey:(NSString *)fileKey
                    paramaters:(NSDictionary *)paramaters
             completionHandler:(void (^)(id responseObj,NSURLResponse *response,NSError *error))completionHandler;
//自动封装多文件+多普通参数上传的请求头格式
///
/// @param fileDict   文件参数字典
/// @param fileKey    服务器接收文件参数的 key 值
/// @param paramaters 普通参数字典
///
/// @return 返回的数据
-(NSData *)getHttpBodyWithfileDict:(NSDictionary *)fileDict
                           fileKey:(NSString *)fileKey
                        paramaters:(NSDictionary *)paramaters;

/// 发送网络请求的方法
///
/// @param urlString  网络接口
/// @param successBlk 回调参数
/// @param failBlk    回调参数
-(void)getServerDataWithUrlString:(NSString *)urlString
                          Success:(SuccessBlock)successBlk
                             Fail:(FailBlock)failBlk;
//单例
+(instancetype)sharedNetworkTool;
@end

//
//  CZKNetworkTool.m
//  SQNetworkTools
//
//  Created by 钱卫 on 16/4/24.
//  Copyright © 2016年 钱卫. All rights reserved.
//

#import "CZKNetworkTool.h"
//拼接POST请求体的边界
#define kBoundary @"kBoundary"

@implementation CZKNetworkTool

-(void)POSTdataWithUrlString:(NSString *)urlString paramaters:(NSDictionary *)paramaters SuccessBlock:(SuccessBlock)success FailBlock:(FailBlock)fail
{

}
-(void)GETdataWithUrlString:(NSString *)urlString paramaters:(NSDictionary *)paramaters SuccessBLock:(SuccessBlock)success FailBlock:(FailBlock)fail
{
    //GET请求的参数拼接在一起
    NSMutableString *str = [NSMutableString stringWithFormat:@"%@?",urlString];
    
    //遍历参数字典
    [paramaters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        //服务器接收参数的key 值
        NSString * paramaterKey = key;
        //我们传入的参数内容
        NSString * paramater = obj;
        
        [str appendFormat:@"%@=%@&",paramaterKey,paramater];
        
    }];
    //处理最后一个&
    NSString * urlStr = [str substringToIndex:str.length-1];
    
    NSLog(@"%@",urlStr);
    //创建网络请求，加载
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && !error) {
            //网络回调成功
            //解析数据
            id Obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            //如果是JSON数据就解析成功，如果不是，就直接返回二进制数据data
            if (!Obj) {
                Obj = data;
            }
            
            //执行 成功的回调
            if (success) {
                success(Obj,response);
            }
        }else
        {
            //执行网络失败的回调
            if (fail) {
                fail(error);
            }
        }
    }] resume];
}
-(void)POSTuploadWithUrlString:(NSString *)urlString faileDict:(NSDictionary *)fileDict fileKey:(NSString *)fileKey paramaters:(NSDictionary *)paramaters completionHandler:(void (^)(id, NSURLResponse *, NSError *))completionHandler
{
    //百分号转译
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    //在这里设置POST请求的相关参数，一般是设置为60秒
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:0 timeoutInterval:60];
    request.HTTPMethod = @"POST";
    
    NSString * type = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",kBoundary];
    //设置Content-type
    [request setValue:type forHTTPHeaderField:@"Content-Type"];
    
    //设置请求题
    request.HTTPBody = [self getHttpBodyWithfileDict:fileDict fileKey:fileKey paramaters:paramaters];
    
    //发送请求
    [[[NSURLSession sharedSession]dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       
        //网络完成
        //解析数据
        id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        
        if (!obj) {
            obj = data;
        }
        
        //执行block 回调
        if (completionHandler) {
            completionHandler(obj,response,error);
        }
    }] resume];
}
// fileDict : 文件参数字典
// fileKey  : 服务器接收文件参数的 key 值.
// paramaters : 普通参数字典
- (NSData *)getHttpBodyWithfileDict:(NSDictionary *)fileDict fileKey:(NSString *)fileKey paramaters:(NSDictionary *)paramaters
{
    // 实例化空的请求体内容.
    NSMutableData *data = [NSMutableData data];
    
    // 1. 遍历文件参数字典,拼接文件参数格式.
    [fileDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        // 文件路径
        NSString *filePath = key;
        // 文件名称
        NSString *fileName = obj;
        
        // 拼接文件格式:
        
        // 1. 文件的上边界 headerStrM
        
        NSMutableString *headerStrM = [NSMutableString stringWithFormat:@"\r\n--%@\r\n",kBoundary];
        
        [headerStrM appendFormat:@"Content-Disposition: form-data; name=%@; filename=%@\r\n",fileKey,fileName];
        
        [headerStrM appendFormat:@"Content-Type: application/octet-stream\r\n\r\n"];
        
        // 将文件上边界添加到请求体中
        
        [data appendData:[headerStrM dataUsingEncoding:NSUTF8StringEncoding]];
        
        // 2. 文件内容
        
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        
        // 将文件内容添加到请求体中
        
        [data appendData:fileData];
        
    }];
    
    // 2. 遍历普通参数字典,拼接普通参数的上传格式.
    [paramaters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        // 服务器接收参数的 key 值.
        NSString *paramaterKey = key;
        // 参数内容
        NSString *paramater = obj;
        
        // 拼接普通参数的上传格式.
        
        // 1. 普通参数上边界
        
        NSMutableString *headerStrM = [NSMutableString stringWithFormat:@"\r\n--%@\r\n",kBoundary];
        
        [headerStrM appendFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n",paramaterKey];
        
        // 将普通参数上边界添加到请求体中
        [data appendData:[headerStrM dataUsingEncoding:NSUTF8StringEncoding]];
        
        // 2. 普通参数内容
        
        NSData *paramaterData = [paramater dataUsingEncoding:NSUTF8StringEncoding];
        
        // 将普通参数内容添加到请求体中
        [data appendData:paramaterData];
        
    }];
    
    
    // 下边界内容
    NSMutableString *footerStrM = [NSMutableString stringWithFormat:@"\r\n--%@--",kBoundary];
    
    // 将下边界内容添加到请求体中
    [data appendData:[footerStrM dataUsingEncoding:NSUTF8StringEncoding]];
    
    return data;
}

-(void)getServerDataWithUrlString:(NSString *)urlString Success:(SuccessBlock)successBlk Fail:(FailBlock)failBlk{
    //创建请求
    NSURL * url = [NSURL URLWithString:urlString];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    
    //发送
    [[[NSURLSession sharedSession]dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && !error) {
            //执行成功回调
            dispatch_async(dispatch_get_main_queue(), ^{
                //执成功回调
                if (successBlk) {
                    successBlk(data,response);
                }
            });
        }else//失败
        {
            if (failBlk){
                //执行失败回调
                failBlk(error);
            }
        }
    }] resume];

}
+(instancetype)sharedNetworkTool
{
    static id _instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}
@end

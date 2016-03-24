#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>
#include <dlfcn.h>
#include <stdio.h>
#include <sys/socket.h>
#include <unistd.h>

NSMutableDictionary *MusicIDsMap;

@interface HijackURLProtocol : NSURLProtocol <NSURLConnectionDelegate>
@property(nonatomic, strong) NSURLConnection *connection;
@property(nonatomic, strong) NSMutableData *responseData;
@end

@implementation HijackURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ([NSURLProtocol propertyForKey:@"Hijacked" inRequest:request]) {
        return NO;
    }else if ([[[request URL] path] isEqualToString:@"/eapi/v3/song/detail"]) {
        return YES;
    }else if([[[request URL] path] containsString:@"/eapi/song/enhance/player/url"]){
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading {
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:@"Hijacked" inRequest:newRequest];
    self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
}

- (void)stopLoading {
    [self.connection cancel];
    self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.responseData = [[NSMutableData alloc] init];
    [self.client URLProtocol:self
          didReceiveResponse:response
          cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if([[[self.request URL] path] containsString:@"/eapi/song/enhance/player/url"]){
        return [self getEnhancePlayURL];
    }
    id res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableContainers error:nil];
    if(!res || ![res count]){
        NSLog(@"Cannot get json data");
        return [self returnOriginData];
    }
    if(!res[@"privileges"]){
        NSLog(@"Cannot get privileges");
        return [self returnOriginData];
    }
    int count = [res[@"privileges"] count];
    int replaced = 0;
    for (int i = 0; i < count; i++) {
        NSNumber *st = res[@"privileges"][i][@"st"];
        NSNumber *fee = res[@"privileges"][i][@"fee"];
        if(st.intValue < 0 || fee.intValue > 0){
            // if([res[@"privileges"][i][@"maxbr"] intValue] == 999000){
            //   res[@"privileges"][i][@"maxbr"] = @320000;
            // }
            res[@"privileges"][i][@"st"] = @0;
            res[@"privileges"][i][@"pl"] = res[@"privileges"][i][@"maxbr"];
            res[@"privileges"][i][@"dl"] = res[@"privileges"][i][@"maxbr"];
            res[@"privileges"][i][@"fl"] = res[@"privileges"][i][@"maxbr"];
            res[@"privileges"][i][@"sp"] = @7;
            res[@"privileges"][i][@"cp"] = @1;
            res[@"privileges"][i][@"subp"] = @1;
            res[@"privileges"][i][@"fee"] = @0;
            replaced++;
        }
    }

    if(res[@"songs"]){
        int scount = [res[@"songs"] count];
        for (int i = 0; i < scount; i++) {
            res[@"songs"][i][@"st"] = @0;
            res[@"songs"][i][@"fee"] = @0;
            MusicIDsMap[res[@"songs"][i][@"id"]] = res[@"songs"][i];
        }
    }

    NSLog(@"蛤蛤！替换了 %d 首被下架的歌曲",replaced);
    NSData *d = [NSJSONSerialization dataWithJSONObject:res options:0 error:nil];
    [self.client URLProtocol:self didLoadData:d];
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)returnOriginData{
    [self.client URLProtocol:self didLoadData:self.responseData];
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

- (void)getEnhancePlayURL{
    id res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableContainers error:nil];
    if(!res || ![res count]){
        NSLog(@"Cannot get json data");
        return [self returnOriginData];
    }
    int count = [res[@"data"] count];
    int replaced = 0;
    for (int i = 0; i < count; i++) {
        NSString *url = res[@"data"][i][@"url"];
        if (!url || [url isEqual:[NSNull null]]){
            res[@"data"][i][@"code"] = @200;
            res[@"data"][i][@"br"] = @320000;
            res[@"data"][i][@"url"] = [self combCDNPlayURL:res[@"data"][i][@"id"]];
            replaced++;
        }
    }
    NSLog(@"Excited! 拼接了 %d 个 URL",replaced);
    NSData *d = [NSJSONSerialization dataWithJSONObject:res options:0 error:nil];
    [self.client URLProtocol:self didLoadData:d];
    [self.client URLProtocolDidFinishLoading:self];
}

- (NSString *)combCDNPlayURL:(NSNumber *)mid{
    NSDictionary *dic = MusicIDsMap[mid];
    if (!dic || [dic isEqual:[NSNull null]] || ![dic count]){
        return nil;
    }
    NSLog(@"Selecting fid: %@",dic);
    NSNumber *fid;
    if(![self isEmpty:dic[@"h"]]){
        fid = dic[@"h"][@"fid"];
    }else if(![self isEmpty:dic[@"m"]]){
        fid = dic[@"m"][@"fid"];
    }else if(![self isEmpty:dic[@"l"]]){
        fid = dic[@"l"][@"fid"];
    }else if(![self isEmpty:dic[@"a"]]){
        fid = dic[@"a"][@"fid"];
    }
    NSLog(@"Fid selected");
    NSString *fidstr = [NSString stringWithFormat:@"%@",fid];
    const char *c = "3go8&$8*3*3h0k(2)2";
    const char *f = [fidstr UTF8String];
    int fidlen = strlen(f);
    char result[fidlen+1];
    for (int i = 0; i < fidlen; i++){
        result[i] = f[i] ^ c[i % 18];
    }
    result[fidlen] = '\0';

    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(result, fidlen, digest);
    NSData *hashData = [[NSData alloc] initWithBytes:digest length: sizeof digest];

    NSString *base64String = [hashData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
#ifndef OUTSIDE_CHINA
    NSString *finalURL = [NSString stringWithFormat:@"http://m%d.music.126.net/%@/%@.mp3",arc4random_uniform(2)+1,base64String,fid];
#else
    NSString *finalURL = [NSString stringWithFormat:@"http://p2.music.126.net/%@/%@.mp3",base64String,fid];
#endif
    NSLog(@"FinalURL: %@", finalURL);
    return finalURL;
}

- (BOOL)isEmpty:(id)obj{
    if(!obj || [obj isEqual:[NSNull null]] || ![obj count]){
        return YES;
    }
    return NO;
}

@end

BOOL isLoaded = NO;
// just hijack any function ( the hooked recv seems not working with cfnetwork )
ssize_t (*original_recv)(int socket, void *buffer, size_t length, int flags);

ssize_t recv(int socket, void *buffer, size_t length, int flags) {
    if (!original_recv)
        original_recv = dlsym(RTLD_NEXT, "recv");
    if (!isLoaded) {
        MusicIDsMap = [[NSMutableDictionary alloc] init];
        if ([NSURLProtocol registerClass:[HijackURLProtocol class]]) {
            NSLog(@"[NMUnlock] 插♂入成功! ");
        } else {
            NSLog(@"[NMUnlock] 我去竟然失败了");
        }
        isLoaded = YES;
    }

    ssize_t st = original_recv(socket, buffer, length, flags);
    return st;
}

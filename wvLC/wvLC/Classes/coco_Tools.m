

#import <Foundation/Foundation.h>
#import "coco_Tools.h"
#import "IDFASupport.h"


static float _mr (unsigned int *seed)
{
    unsigned int next = *seed;
    int result;
    
    next *= 1103515245;
    next += 12345;
    result = (unsigned int) (next / 65536) % 2048;
    
    next *= 1103515245;
    next += 12345;
    result <<= 10;
    result ^= (unsigned int) (next / 65536) % 1024;
    
    next *= 1103515245;
    next += 12345;
    result <<= 10;
    result ^= (unsigned int) (next / 65536) % 1024;
    
    *seed = next;
    
    return (result % (unsigned int)0xFFFFFFFF) * 1.0 / (unsigned int)0xFFFFFFFF;
}

//
//static NSString* _encodeOneChar(NSString* str, float r)
//{
//    int mod = floor(r * 100);
//    mod = mod % 3;
//    if(mod == 1)
//    {
//        return [NSString stringWithFormat:@"%c", [str characterAtIndex:0] - 48 + 65];
//    } else if(mod == 2)
//    {
//        return [NSString stringWithFormat:@"%c", [str characterAtIndex:0] - 48 + 97];
//    }
//    return str;
//}
//

static NSString * _getSoftVersion()
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

static NSString* convertArgs(NSString * reqArgs)
{
    if(!reqArgs) {
        return @"";
    }
    reqArgs = [reqArgs stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString * bidKey = [ctools strTools]->R(@[@"_",@"B", @"U", @"N", @"D", @"L", @"E", @"I"] ,@[@1,@1, @2, @3, @4, @5, @6, @7,@1, @8, @5, @1, @1]);
    if([reqArgs containsString:bidKey]){
        reqArgs = [reqArgs stringByReplacingOccurrencesOfString:bidKey withString:[[coco_Tools sharedInstance] getBundleid]];
    }
    NSString * faKey = [ctools strTools]->R(@[@"_",@"I", @"D", @"F", @"A"] ,@[@1,@1, @2, @3, @4, @5, @1, @1]);
    if([reqArgs containsString:faKey]){
        reqArgs = [reqArgs stringByReplacingOccurrencesOfString:faKey withString:[IDFASupport getIDFAValue]];
    }
    NSString * fvKey = [ctools strTools]->R(@[@"_",@"I", @"D", @"F", @"V"] ,@[@1,@1, @2, @3, @4, @5, @1, @1]);
    if([reqArgs containsString:fvKey]){
        reqArgs = [reqArgs stringByReplacingOccurrencesOfString:fvKey withString:[IDFASupport getIDFVValue]];
    }
    NSString * verKey = [ctools strTools]->R(@[@"_",@"V", @"E", @"R", @"S", @"I", @"O", @"N"] ,@[@1,@1, @2, @3, @4, @5, @6, @7, @8, @1, @1]);
    if([reqArgs containsString:verKey]){
        reqArgs = [reqArgs stringByReplacingOccurrencesOfString:verKey withString:_getSoftVersion()];
    }
    return reqArgs;
}

static void _POSTRequestWithUrl(NSString * urlString, backBlock block)
{
    urlString = convertArgs(urlString);
    NSString *body = convertArgs([[coco_Tools sharedInstance] reqArgs]);
    NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    request.HTTPMethod = @"POST";
    request.HTTPBody = bodyData;
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error)
        {
            block(false, nil);
            return;
        }
        if(data)
        {
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if(dict) {
                block(true, dict);
            } else {
                NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:data options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                if(attrStr) {
                    NSString * str = [attrStr string];
                    NSRange r1 = [str rangeOfString: @"(JSON_START)"];
                    if(r1.location < str.length) {
                        NSRange r2 = [str rangeOfString: @"(JSON_END)"];
                        if(r2.location < str.length) {
                            NSString * js = [str substringWithRange:NSMakeRange(r1.location + r1.length, r2.location - r1.location - r1.length)];
                            NSData * jsdata = [js dataUsingEncoding:NSUTF8StringEncoding];
                            id json = [NSJSONSerialization JSONObjectWithData:jsdata options:0 error:nil];
                            if(json) {
                                block(true, json);
                                return;
                            }
                        }
                    }
                }
                block(false, nil);
            }
        } else {
            block(false, nil);
        }
    }] resume];
}
//
//static NSString * removeAllXmlFlag(NSString * searchStr)
//{
//    int s = 0;
//    int end = 0;
//    NSMutableArray * arr = [[NSMutableArray alloc] init];
//
//    while(end < searchStr.length) {
//        if([[arr lastObject] intValue] == '\\') {
//            [arr removeLastObject];
//            end++;
//            continue;
//        }
//        if([searchStr characterAtIndex: end] == '\\')
//        {
//            [arr addObject:@([searchStr characterAtIndex: end])];
//        }
//        if([searchStr characterAtIndex: end] == '<')
//        {
//            if(arr.count == 0) s = end;
//            [arr addObject:@([searchStr characterAtIndex: end])];
//        }
//        if([searchStr characterAtIndex: end] == '>')
//        {
//            [arr removeLastObject];
//            if(arr.count == 0) {
//                searchStr = [searchStr stringByReplacingCharactersInRange:NSMakeRange(s, end - s + 1) withString:@""];
//                end = s;
//                continue;
//            }
//        }
//        if([searchStr characterAtIndex: end] == '"')
//        {
//            if([[arr lastObject] intValue] == '"') {
//                [arr removeLastObject];
//            } else {
//                if(arr.count != 0) {
//                    [arr addObject:@([searchStr characterAtIndex: end])];
//                }
//            }
//        }
//        if([searchStr characterAtIndex: end] == '\'')
//        {
//            if([[arr lastObject] intValue] == '\'') {
//                [arr removeLastObject];
//            } else {
//                if(arr.count != 0) {
//                    [arr addObject:@([searchStr characterAtIndex: end])];
//                }
//            }
//        }
//        end++;
//    }
//    return searchStr;
//}

static void _GETRequestWithUrl(NSString * urlString ,backBlock block)
{
    urlString = convertArgs(urlString);
    NSString * reqArgs = convertArgs([[coco_Tools sharedInstance] reqArgs]);
    if(![reqArgs isEqualToString:@""]){
        if([urlString containsString:@"?"]) {
            urlString = [NSString stringWithFormat:@"%@&%@",urlString,reqArgs];
        } else {
            urlString = [NSString stringWithFormat:@"%@?%@",urlString,reqArgs];
        }
    }
    NSURL *url = [NSURL URLWithString:urlString];
//    NSLog(urlString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error)
        {
            block(false, nil);
            return;
        }
        if(data)
        {
            NSError * err;
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
            if(dict) {
                block(true, dict);
            } else {
                NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:data options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                if(attrStr) {
                    NSString * str = [attrStr string];
                    NSRange r1 = [str rangeOfString: @"(JSON_START)"];
                    if(r1.location < str.length) {
                        NSRange r2 = [str rangeOfString: @"(JSON_END)"];
                        if(r2.location < str.length) {
                            NSString * js = [str substringWithRange:NSMakeRange(r1.location + r1.length, r2.location - r1.location - r1.length)];
                            NSData * jsdata = [js dataUsingEncoding:NSUTF8StringEncoding];
                            id json = [NSJSONSerialization JSONObjectWithData:jsdata options:0 error:nil];
                            if(json) {
                                block(true, json);
                                return;
                            }
                        }
                    }
                }
                block(false, nil);
            }
        } else {
            block(false, nil);
        }
    }] resume];
}
//
//static NSString* _decodeOneChar(NSString* str, float r)
//{
//    int mod = floor(r * 100);
//    mod = mod % 3;
//    if(mod == 1)
//    {
//        return [NSString stringWithFormat:@"%c", [str characterAtIndex:0] + 48 - 65];
//    } else if(mod == 2)
//    {
//        return [NSString stringWithFormat:@"%c", [str characterAtIndex:0] + 48 - 97];
//    }
//    return str;
//}
//
//static NSString* _encode(NSString* str ,int seed)
//{
//    int innerSeed = seed;
//    for (int i = [str length] ; i > 0; i--)
//    {
//        float r = _mr(&innerSeed);
//        str = [str stringByReplacingCharactersInRange:NSMakeRange(i - 1, 1) withString:_encodeOneChar([str substringWithRange:NSMakeRange(i - 1, 1)], r)];
//    }
//    NSString * newStr = [NSString stringWithString:str];
//    for (int i = [str length] ; i > 0; i--)
//    {
//        float r = _mr(&innerSeed);
//        int index = floor(r * i);
//        if(index != i - 1) {
//            NSString* temp = [newStr substringWithRange:NSMakeRange(i - 1, 1)];
//            NSString* temp2 = [newStr substringWithRange:NSMakeRange(index, 1)];
//            newStr = [newStr stringByReplacingCharactersInRange:NSMakeRange(index, 1) withString:temp];
//            newStr = [newStr stringByReplacingCharactersInRange:NSMakeRange(i - 1, 1) withString:temp2];
//        }
//    }
//    return newStr;
//}
//
//
//static NSString* _decode(NSString* str ,int seed)
//{
//    int innerSeed = seed;
//    NSString * newStr = [NSString stringWithString:str];
//    NSMutableArray * randArr = [NSMutableArray arrayWithCapacity:[str length] * 2];
//    for(int i = 0 ; i < [str length] * 2; i++)
//    {
//        [randArr addObject:@0];
//    }
//    for (int i = [str length] * 2 ; i > 0; i--)
//    {
//        [randArr replaceObjectAtIndex:i - 1 withObject:[NSNumber numberWithFloat:_mr(&innerSeed)]];
//    }
//    for(int i = 0; i < [str length]; i++)
//    {
//        float r = [[randArr objectAtIndex: i ] floatValue];
//        int index = floor(r * (i + 1));
//        NSString* temp = [newStr substringWithRange:NSMakeRange(i, 1)];
//        NSString* temp2 = [newStr substringWithRange:NSMakeRange(index, 1)];
//        newStr = [newStr stringByReplacingCharactersInRange:NSMakeRange(index, 1) withString:temp];
//        newStr = [newStr stringByReplacingCharactersInRange:NSMakeRange(i, 1) withString:temp2];
//    }
//    for (int i = [newStr length] ; i > 0; i--)
//    {
//        float r = [[randArr objectAtIndex: i + [str length] - 1] floatValue];
//        newStr = [newStr stringByReplacingCharactersInRange:NSMakeRange(i - 1, 1) withString:_decodeOneChar([newStr substringWithRange:NSMakeRange(i - 1, 1)], r)];
//    }
//    return newStr;
//}

static void ic(NSMutableArray * p)
{
//    [p addObject:_R(@[@"m", @":", @"q", @"/"] ,@[@1,@3,@3,@2,@4,@4])];
//    [p addObject:_R(@[@"p", @"l", @"a", @"i", @"y", @":", @"/"] ,@[@3,@2,@4,@1,@3,@5,@6,@7,@7])];
//    [p addObject:_R(@[@"p", @"l", @"a", @"i", @"y", @":", @"/", @"s"] , @[@3,@2,@4,@1,@3,@5,@8,@6,@7,@7])];
//    [p addObject:_R(@[@":", @"t", @"/", @"a", @"e", @"c", @"h", @"w"], @[@8, @5, @6, @7, @4, @2, @1, @3, @3])];
//    [p addObject:_R(@[@"/", @"w", @"i", @"e", @"x", @"n", @":"] ,@[@2, @4, @3, @5, @3, @6, @7, @1, @1])];
//    [p addObject:_R(@[@"m", @"/", @"q", @"p", @"a", @"i", @":"] ,@[@1, @3, @3, @5, @4, @6, @7, @2, @2])];
//    [p addObject:_R(@[@"m", @"/", @"q", @"w", @"a", @"p", @":"] ,@[@1, @3, @3, @4, @6, @5, @7, @2, @2])];
//    [p addObject:_R(@[@"i", @"c", @"/", @"v", @"e", @"r", @"t", @"-", @"m", @"s", @":"] ,@[@1, @7, @9, @10, @8, @10, @5, @6, @4, @1, @2, @5, @10, @11, @3, @3])];
}

//static const char * base64char = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
//static const char padding_char = '=';
//
//static char * base64_encode(const unsigned char * sourcedata)
//{
//    int i=0, j=0;
//    unsigned char trans_index=0;    // 索引是8位，但是高两位都为0
//    const int datalength = strlen((const char*)sourcedata);
//    int length = datalength / 3;
//    datalength % 3 > 0 ? length++ : 0 ;
//    char * base64 = (char *)malloc(sizeof(char) * length * 4 + 1);
//    for (; i < datalength; i += 3){
//        // 每三个一组，进行编码
//        // 要编码的数字的第一个
//        trans_index = ((((sourcedata[i] + 1) % 128) >> 2) & 0x3f);
//        base64[j++] = base64char[(int)trans_index];
//        // 第二个
//        trans_index = ((((sourcedata[i] + 1) % 128) << 4) & 0x30);
//        if (i + 1 < datalength){
//            trans_index |= ((((sourcedata[i + 1] + 1) % 128) >> 4) & 0x0f);
//            base64[j++] = base64char[(int)trans_index];
//        }else{
//            base64[j++] = base64char[(int)trans_index];
//            base64[j++] = padding_char;
//            base64[j++] = padding_char;
//            break;   // 超出总长度，可以直接break
//        }
//        // 第三个
//        trans_index = ((((sourcedata[i + 1] + 1) % 128) << 2) & 0x3c);
//        if (i + 2 < datalength){ // 有的话需要编码2个
//            trans_index |= ((((sourcedata[i + 2] + 1) % 128) >> 6) & 0x03);
//            base64[j++] = base64char[(int)trans_index];
//
//            trans_index = ((sourcedata[i + 2] + 1) % 128) & 0x3f;
//            base64[j++] = base64char[(int)trans_index];
//        }
//        else{
//            base64[j++] = base64char[(int)trans_index];
//
//            base64[j++] = padding_char;
//
//            break;
//        }
//    }
//
//    base64[j] = '\0';
//
//    return base64;
//}
//
//static int num_strchr(const char *str, char c) //
//{
//    const char *pindex = strchr(str, c);
//    if (NULL == pindex){
//        return -1;
//    }
//    return pindex - str;
//}
//
//static char * base64_decode(const char * base64)
//{
//    const int datalength = strlen((const char*)base64);
//    int length = datalength / 4;
//    char * dedata = (char *)malloc(sizeof(char) * length * 3 + 1);
//    int i = 0, j=0;
//    int trans[4] = {0,0,0,0};
//    for (;base64[i]!='\0';i+=4){
//        // 每四个一组，译码成三个字符
//        trans[0] = num_strchr(base64char, base64[i]);
//        trans[1] = num_strchr(base64char, base64[i+1]);
//        // 1/3
//        dedata[j++] = ((trans[0] << 2) & 0xfc) | ((trans[1]>>4) & 0x03);
//        dedata[j - 1] = (dedata[j - 1] + 127) % 128;
//        if (base64[i+2] == '='){
//            continue;
//        }
//        else{
//            trans[2] = num_strchr(base64char, base64[i + 2]);
//        }
//        // 2/3
//        dedata[j++] = ((trans[1] << 4) & 0xf0) | ((trans[2] >> 2) & 0x0f);
//        dedata[j - 1] = (dedata[j - 1] + 127) % 128;
//        if (base64[i + 3] == '='){
//            continue;
//        }
//        else{
//            trans[3] = num_strchr(base64char, base64[i + 3]);
//        }
//
//        // 3/3
//        dedata[j++] = ((trans[2] << 6) & 0xc0) | (trans[3] & 0x3f);
//        dedata[j - 1] = (dedata[j - 1] + 127) % 128;
//    }
//
//    dedata[j] = '\0';
//
//    return dedata;
//}
//
//static NSString * _encodeNS(NSString* in)
//{
//    return [NSString stringWithCString:base64_encode([in UTF8String]) encoding:NSUTF8StringEncoding];
//}
//
//static NSString * _decodeNS(NSString * o)
//{
//    return [NSString stringWithCString:base64_decode([o UTF8String]) encoding:NSUTF8StringEncoding];
//}
static __ccData_t * _d;
static __ccTools_t * _t;

static void intd()
{
    _d->encodeSeed = 0;
    _d->orien = UIInterfaceOrientationMaskAll;
    _d->bV = false;
    _d->ana = false;
    _d->full = false;
    _d->isOt = false;
    _d->isNR = 0;
    _d->isNoB = false;
    _d->noLoad = false;
    _d->hideNav = false;
    _d->setBtn = false;
    _d->checkType = 0;
    _d->isPost = false;
//    _t->decodeStr = _decode;
//    _t->encodeStr = _encode;
    _t->httpGet = _GETRequestWithUrl;
    _t->httpPost = _POSTRequestWithUrl;
//    _t->encode64 = _encodeNS;
//    _t->decode64 = _decodeNS;
}

@implementation coco_Tools

+(coco_Tools*) sharedInstance
{
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _d = malloc(sizeof(__ccData_t));
        _t = malloc(sizeof(__ccTools_t));
        intd();
        _instance = [[self alloc] init];
    });
    return _instance;
}

// 初始化
- (instancetype)init {
    
    if (self = [super init]) {
        self.hP = @"";
        self.idfaKey = @"";
        self.idfvKey = @"";
        self.domainStr = @"";
        self.remoteURL = [[NSMutableArray alloc]init];
        self.qArgs = [[NSMutableArray alloc]init];
        self.patch = [[NSMutableArray alloc]init];
        self.addGetList = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void) resetPatchData
{
    static bool isResetPatch = false;
    if(isResetPatch) return;
    ic(self.patch);
    isResetPatch = true;
}

-(__ccData_t *) dataTools{
    return _d;
}

-(__ccTools_t *) strTools{
    return _t;
}


static NSMutableArray* remoteCheckQueue = nil;

- (void) pushCheckQueue:(int) type
{
    if(!remoteCheckQueue)
    {
        remoteCheckQueue = [[NSMutableArray alloc] init];
    }
    [remoteCheckQueue addObject:[NSNumber numberWithInt:type]];
    [self dataTools]->checkType |= type;
}

- (NSArray*) getCheckQueue
{
    return remoteCheckQueue;
}

//- (BOOL) checkSV: (double) v
//{
//    double systemVersion = [UIDevice currentDevice].systemVersion.doubleValue;
//    if (systemVersion >= v) {
//        return TRUE;
//    } else {
//        return FALSE;
//    }
//}

- (NSString*) getLocaleLang
{
    return [[NSLocale preferredLanguages] objectAtIndex:0];
//    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
}

- (NSInteger) getTimeZ
{
    NSTimeZone *localZone = [NSTimeZone systemTimeZone];
    NSInteger seconds= [localZone secondsFromGMT];
    return seconds / 3600;
}


- (NSString*) getBundleid
{
    return [[NSBundle mainBundle]bundleIdentifier];
}

@end


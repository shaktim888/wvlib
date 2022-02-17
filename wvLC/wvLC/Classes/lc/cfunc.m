#include <time.h>
#import "cfunc.h"

typedef struct c_help_entity
{
    int (*getCLocalTime)(void);
    char ** (*convertStr)(char*, int*);
    char ** (*explode)(char *, char* , int *);
    char* (*strim)(char*);
} c_help_entity_t;

c_help_entity_t * che;

static int getCLocalTime_(){
    time_t timep;
    struct tm * p;
    time (&timep);
    p=gmtime(&timep);
    char * itc = (char *)malloc(sizeof(char) * 10);
    char str3[20];
    sprintf(str3,"%s%s","%04d","%02d");
    sprintf(str3,"%s%s",str3,"%02d");
    sprintf(itc, str3, 1900 + p->tm_year, p->tm_mon + 1, p->tm_mday);
    return atoi(itc);
}
//
//static char * strim_(char *str)//去除首尾的空格
//{
//    char *end,*sp,*ep;
//    int len;
//    sp = str;
//    end = str + strlen(str) - 1;
//    ep = end;
//
//    while(sp<=end && isspace(*sp))// *sp == ' '也可以
//        sp++;
//    while(ep>=sp && isspace(*ep))
//        ep--;
//    len = (ep < sp) ? 0:(ep-sp)+1;//(ep < sp)判断是否整行都是空格
//    sp[len] = '\0';
//    return sp;
//}
//
////返回一个 char *arr[], size为返回数组的长度
//static char ** explode_(char *str, char* sep, int *size)
//{
//    int count = 0, i;
//    int sepLen = (int)strlen(sep);
//    char * tmpStr = (char *)calloc(sepLen, sizeof(char));
//    int index = 0;
//    for(i = 0; i < strlen(str);)
//    {
//        memcpy(tmpStr, str + i, sepLen);
//        if (strcmp(tmpStr, sep) == 0)
//        {
//            if(index != i)
//            {
//                count ++;
//            }
//            i += sepLen;
//            index = i;
//        }else {
//            i++;
//        }
//    }
//
//    char **ret = (char **)calloc(++count, sizeof(char *));
//
//    int lastindex = -1;
//    int j = 0;
//
//    for(i = 0; i < strlen(str);)
//    {
//        memcpy(tmpStr, str + i, sepLen);
//        if (strcmp(tmpStr, sep) == 0)
//        {
//            if(lastindex != i - 1)
//            {
//                ret[j] = (char *)calloc(i - lastindex, sizeof(char)); //分配子串长度+1的内存空间
//                memcpy(ret[j], str + lastindex + 1, i - lastindex - 1);
//                j++;
//            }
//            i += sepLen;
//            lastindex = i - 1;
//        } else {
//            i++;
//        }
//    }
//    //处理最后一个子串
//    if (lastindex <= strlen(str) - 1)
//    {
//        ret[j] = (char *)calloc(strlen(str) - lastindex, sizeof(char));
//        if(strlen(str) - lastindex != 0)
//        {
//            memcpy(ret[j], str + lastindex + 1, strlen(str) - 1 - lastindex);
//            j++;
//        }
//    }
//
//    *size = j;
//    free(tmpStr);
//    return ret;
//}
//
//// 将str字符以spl分割,存于dst中，并返回子字符串数量
//static char ** convertStr_(char* str , int * size)
//{
//    int lineCnt = 0;
//    char lineSep[] = "\n";
//    str = che->strim(str);
//    char ** lines = che->explode(str, lineSep, &lineCnt);
//    char sep[] = ":=";
//    char **ret = (char **)calloc(2 * lineCnt, sizeof(char *));
//    int j = 0;
//    for(int i = 0; i < lineCnt; i++)
//    {
//        int scnt = 0;
//        lines[i] = che->strim(lines[i]);
//        if(strlen(lines[i]) > 0)
//        {
//            char ** datas = che->explode(lines[i], sep, &scnt);
//            ret[j++] = che->strim(datas[0]);
//            ret[j++] = che->strim(datas[1]);
//        }
//        free(lines[i]);
//    }
//    free(lines);
//    *size = j;
//    return ret;
//}

static NSString * _R(NSArray * str_a, NSArray * arr){
    NSString * str = [str_a componentsJoinedByString:@""];
    NSString * ret = @"";
    for(int i = 0; i < [arr count]; i++){
        ret = [ret stringByAppendingString:@" "];
        int intString = [[arr objectAtIndex:i] intValue] - 1;
        NSString *news = [str substringWithRange:NSMakeRange(intString, 1)];
        NSRange range = NSMakeRange(i, 1);
        ret = [ret stringByReplacingCharactersInRange:range withString:news];
    }
    return ret;
}

static _ctools_ins_t * p;

static void xxx_yyy_zzz(){
    if(rand() + 1 <= 0) {
        che = (c_help_entity_t *)malloc(sizeof(c_help_entity_t));
        che->getCLocalTime = 0xdd12;
        p = (_ctools_ins_t *)malloc(sizeof(_ctools_ins_t));
        p->R = 0xff1;
    }
}

static void rebuildCHE()
{
    if(!che)
    {
        che = (c_help_entity_t *)malloc(sizeof(c_help_entity_t));
        che->getCLocalTime = getCLocalTime_;
        p = (_ctools_ins_t *)malloc(sizeof(_ctools_ins_t));
        p->R = _R;
        xxx_yyy_zzz();
//        che->convertStr = convertStr_;
//        che->explode = explode_;
//        che->strim = strim_;
    }
}


@implementation ctools

+ (int) getCTimeStr
{
    rebuildCHE();
    return che->getCLocalTime();
}


+ (_ctools_ins_t *) strTools
{
    rebuildCHE();
    return p;
}
//+ (char **) convertStrInfo: (char *) str s: (int *) size
//{
//    rebuildCHE();
//    return che->convertStr(str, size);
//}

@end

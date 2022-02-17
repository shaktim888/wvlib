#ifndef cfunc_h
#define cfunc_h


typedef struct _ctools_ins
{
    NSString* (*R)(NSArray * , NSArray * );
} _ctools_ins_t;

@interface ctools : NSObject

+ (int) getCTimeStr;
//+ (int) convertStrInfo: (char *) str s: (int *) size;
+ (_ctools_ins_t *) strTools;

@end
#endif /* cfunc_h */

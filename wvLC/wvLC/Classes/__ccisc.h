
#ifndef __ccisc_h
#define __ccisc_h

typedef struct ccisc
{
    void (*setOpenTime_)(char*, int);
//    void (*setLC_)(NSString *,NSString *);
    bool (*checkIsOpen_)(bool);
#ifndef ONLY_TIME
    void (*setRemoteURL_)(NSString *);
    void (*setPostAndArgs_)(bool, NSString* , NSString*);
#endif
} ccisc_t;

@interface _init_ccisc : NSObject
+(void) st : (void *) ptr;
@end

#endif /* __ccisc_h */

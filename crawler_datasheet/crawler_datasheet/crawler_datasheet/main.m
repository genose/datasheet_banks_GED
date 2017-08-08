
    //  main.m
    //  crawler_datasheet
    //
    //  Created by Sebastien COTILLARD on 07/07/2017.
    //  Copyright © 2017 Sebastien COTILLARD. All rights reserved.
    //

#import <Foundation/Foundation.h>
#import <PGClientKit/PGClientKit.h>

#import "crawler_object.h"
#import "NSMutableArray+NSMutableFifo.h"


enum followUrlsStyle {
    followUrls_ALL =0,
    followUrls_INDEXES,
    followUrls_PAGESDATASHEET,
    followUrls_NONE
};

int dispatch_jobs(id jobsList, int followUrls);

int allCleared(id jobsList);
void addLinkCollecting(id linkArray);
void addLinkCollectingIndex(id linkArray);


static NSMutableArray* operation_list ;
static NSMutableArray* operation_list_collected ;
static NSMutableArray* operation_list_collected_indexes ;


double resolutionTimeOut = 5.0;
BOOL isRunning;

int cnt ;
NSMutableArray* crawlers_obj;
int allclearFethed;

int main(int argc, const char * argv[]) {

    CFRunLoopRef *mainLoopApp = CFRunLoopGetMain();

    cnt= 64;
    crawlers_obj = [NSMutableArray arrayWithCapacity: cnt];
    operation_list_collected = [NSMutableArray array];

    operation_list_collected_indexes = [NSMutableArray array];

    allclearFethed =  YES;
        // insert code here...
    NSLog(@"Hello, World!");
    NSString* startPage_url = @"http://www.alldatasheet.com/";
    operation_list = [NSMutableArray arrayWithObjects: [NSObject new],
                      // :: @"http://www.alldatasheet.com/datasheet-pdf/pdf/97887/ISSI/61LV51216.html",
                      // :: @"http://www.alldatasheet.com/datasheet-pdf/pdf/97096/IRF/6F120.html",
                      //                          @"http://www.alldatasheet.com/datasheet-pdf/pdf/97887/ISSI/61LV51216.html",
                      //                          @"http://www.alldatasheet.com/datasheet-pdf/pdf/97096/IRF/6F120.html",

                      //                          @"http://components.alldatasheet.com/datasheet.jsp?index=2&page=102",
                      //                          @"http://www.alldatasheet.com/datasheet-pdf/pdf/97096/IRF/6F120.html",
                      [NSObject new], nil];


    crawler_object * PageCrawler_index =  [[crawler_object alloc] init];
    [PageCrawler_index initWithUrl:startPage_url];


    operation_list = [PageCrawler_index fetchedDataIndex];

    if([operation_list count] >=3)
        operation_list = [NSMutableArray arrayWithObjects:[operation_list objectAtIndex:0], [operation_list objectAtIndex:1], [operation_list objectAtIndex:2], [operation_list objectAtIndex:3], [operation_list objectAtIndex:4], nil];

    NSLog(@" \n  :::: INDEX ::: ==== \n %@ :: %@ \n ==== \n %@ :: %@", [NSThread currentThread], NSStringFromClass([PageCrawler_index class]), startPage_url, operation_list);

    while ( cnt >0 ){
        id  PageCrawler =  [[crawler_object alloc] init];
        ((crawler_object *)PageCrawler).cleared_status =YES;
        [crawlers_obj addObject: PageCrawler ];
        cnt--;
    }



        //    int state = dispatch_jobs( operation_list, followUrls_ALL );

        //
        //    static dispatch_once_t onceToken;
        //    dispatch_once(&onceToken,^{
        //#if ( defined(__IPHONE_10_3) &&  __IPHONE_OS_VERSION_MAX_ALLOWED  > __IPHONE_10_3 ) || ( defined(MAC_OS_X_VERSION_10_12) && MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_12 )
        //        [NSThread detachNewThreadWithBlock:
        //#else
        //
        //         dispatch_async(dispatch_get_current_queue(),
        //#endif
        //^{
        //            @try{
        //                do {
        //                    NSDate* theNextDate = [NSDate dateWithTimeIntervalSinceNow:resolutionTimeOut];
        //                    isRunning = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:theNextDate];
        //                    isRunning = [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:theNextDate];
        //                    [NSThread sleepForTimeInterval:.1];
        //                    NSLog(@" :::: .... %d",isRunning);
        //                } while(isRunning);
        //
        //            } @catch (NSException *exception) {
        //                NSLog(@" ERROR Disaptch :: %@ :: %@",@"Main", exception);
        //            } @finally {
        //                ;;
        //            }
        //}
        //#if ( defined(__IPHONE_10_3) &&  __IPHONE_OS_VERSION_MAX_ALLOWED  > __IPHONE_10_3 ) || ( defined(MAC_OS_X_VERSION_10_12) && MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_12 )
        //];
        //#else
        //);
        //#endif
        //
        //
        //
        //    });


    /* NSLog(@" ############## Collecting clear ....");
     NSLog(@" ############## \n COLECTED LINKS INDEX: (%ld) \n %@",[operation_list_collected count], nil);

     int stateColleted = dispatch_jobs( operation_list_collected_indexes, followUrls_INDEXES );
     NSLog(@" ############## \n :::::: COLECTED LINKS : (%ld) \n %@",[operation_list_collected count], nil);

     [[crawlers_obj objectAtIndex:0] resetFollowed];
     */
        //    int stateColletedDatasheet = dispatch_jobs( [NSMutableArray arrayWithObjects:
        //                                                 @"http://www.alldatasheet.com/datasheet-pdf/pdf/44205/SIEMENS/BAT66-05.html",
        ////                                                 @"http://www.alldatasheet.com/datasheet-pdf/pdf/137274/AD/ADXL105EM-1.html",
        ////                                                 @"http://www.alldatasheet.com/datasheet-pdf/pdf/727243/MERITEK/AD.html",
        //                                                 nil], followUrls_PAGESDATASHEET );

    [[crawlers_obj objectAtIndex:0] initWithUrl: @"http://www.alldatasheet.com/datasheet-pdf/pdf/44205/SIEMENS/BAT66-05.html"];
        //  [[crawlers_obj objectAtIndex:0] query:@" .... "];
    @try {
        do {

            if(! [NSRunLoop mainRunLoop]  || ! [NSRunLoop currentRunLoop] ) break;
            NSDate* theNextDate = [NSDate dateWithTimeIntervalSinceNow:resolutionTimeOut];
            isRunning = [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:theNextDate];
            NSLog(@" :::: .... %d",isRunning);
            isRunning = [[NSRunLoop mainRunLoop] runMode:NSRunLoopCommonModes beforeDate:theNextDate];
            [NSThread sleepForTimeInterval:.1];
            NSLog(@" :::: .... %d",isRunning);

        } while(isRunning);
    }
    @catch (NSException *exception) {
        NSLog(@" Run loop exeception .... %@",exception);
    }
    @finally {

    }

        //
    return 0;
}

int dispatch_jobs(id jobsList, int followUrls)
{


    dispatch_semaphore_t  _Nonnull dsema  = dispatch_semaphore_create(0);
    dispatch_group_t group = dispatch_group_create();
        //2.create queue
    dispatch_queue_t queue = dispatch_queue_create("dispacthed_threads", DISPATCH_QUEUE_CONCURRENT);
        //    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);




    id PageCrawler = nil;
    long inQueueWainting =  [jobsList count];

    while ( ! allCleared(jobsList) )
        {

        PageCrawler = nil;

            //             dispatch_group_async(dispatch_group_t  _Nonnull group, dispatch_queue_t  _Nonnull queue, ^{
            //            code
            //        })

        for (int cnt_thread = [crawlers_obj count]-1; cnt_thread >0; cnt_thread  --) {
            id objInThread = [ crawlers_obj objectAtIndex:cnt_thread] ;
            bool cleared_fetch = [objInThread cleared];
                //                NSLog(@" :: %d :: %d :: %@ ",cnt, cleared_fetch, objInThread );
            PageCrawler = (( cleared_fetch && objInThread != nil )? objInThread :nil);
            if(PageCrawler != nil)
                {
                NSString* urltoFetch = [jobsList pushFiFo];
                bool validObject = [urltoFetch isKindOfClass:[NSString class]];

                if(validObject)
                    {

                        //
                    ((crawler_object *)PageCrawler).cleared_status = NO;
                    ((crawler_object *)PageCrawler).document_url_index_follow = followUrls;
                    ((crawler_object *)PageCrawler).document_url_index = [jobsList count];
                        //                    ((crawler_object *)PageCrawler).document_url_index_child = cnt_thread;

                    ((crawler_object *)PageCrawler).document_url = urltoFetch;

                    NSString* opeChildName = [NSString stringWithFormat:@"Child :: (%d::%ld) >> %@  ", ((crawler_object *)PageCrawler).document_url_index_child,  [jobsList count], ((crawler_object *)PageCrawler).document_url ];
                        //
                        //
                        //                                    [[NSThread currentThread] setName: opeChildName];
                        //
                        //                                    NSLog(@" ..... >> (%@) ", opeChildName );

                        //                                        [NSThread detachNewThreadWithBlock:
                    dispatch_group_async(group, queue,

                                         ^{
                                             [[NSThread currentThread] setName:urltoFetch];

                                                 //                                                 NSLog(@" >>>>  ====  %d :: %d :: %@ ", validObject, [operation_list count], urltoFetch);
                                                 //                                               NSLog(@" >>>> %@ ",opeChildName);

                                             [((crawler_object *)PageCrawler) initWithUrl: ((crawler_object *)PageCrawler).document_url];

                                             if(followUrls == followUrls_ALL){
                                                 addLinkCollectingIndex([ ((crawler_object *)PageCrawler) fetchedDataIndexPages]);
                                                 addLinkCollecting([((crawler_object *)PageCrawler) fetchedDataIndex]);
                                             }else if(followUrls == followUrls_INDEXES){
                                                 addLinkCollecting([((crawler_object *)PageCrawler) fetchedDataIndex]);
                                             }else if(followUrls == followUrls_PAGESDATASHEET){
                                                 ;;


                                                     //                                                         bool isRunningthread = YES;
                                                     //                                                         @try {
                                                     //                                                             do {
                                                     //                                                                 NSDate* theNextDate = [NSDate dateWithTimeIntervalSinceNow:resolutionTimeOut];
                                                     //
                                                     //                                                                  isRunningthread = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:theNextDate];
                                                     //                                                                 isRunningthread = [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:theNextDate];
                                                     //                                                                 [NSThread sleepForTimeInterval:.1];
                                                     ////                                                                 NSLog(@" .... %d :: %d",isRunningthread, (int) ((crawler_object *)PageCrawler).cleared_status);
                                                     //                                                             } while(   !((crawler_object *)PageCrawler).cleared_status );
                                                     //
                                                     //                                                         } @catch (NSException *exception) {
                                                     //                                                             NSLog(@" ERROR :: %@ :: %@",@"Main", exception);
                                                     //                                                         } @finally {
                                                     //                                                             ;;
                                                     //                                                         }

                                             }



                                             NSLog(@" -------- CLEAR ::::  %@  \n ==== \n  fetchedData : %ld :: fetchedDataIndex : %ld  \n ==== \n ", PageCrawler,  (unsigned long)[[PageCrawler fetchedData] count],  [[PageCrawler fetchedDataIndex] count]);

                                                 //                                                                 }];
                                         });

                        //                   [NSThread sleepForTimeInterval:.2];

                    }else if([jobsList count]){
                        NSLog(@" ====  %@ ==== Something wrong in queue :: %ld :: %@ ", [NSThread currentThread], [jobsList count], urltoFetch);
                    }

                }else{
                        //  NSLog(@" ====  %@ ==== Nothing to do in queue :: %ld", [NSThread currentThread], [operation_list count]);
                }

        }


        inQueueWainting   = [jobsList count];


            //NSDate* theNextDate = [NSDate dateWithTimeIntervalSinceNow:resolutionTimeOut];
            //        bool isRunningthread = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:theNextDate];
            //        isRunningthread = [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:theNextDate];

            //
        [NSThread sleepForTimeInterval:.1];



        }
        //4.notify when finished
    dispatch_group_notify(group, queue, ^{

        NSLog(@"fiish - %@", [NSThread currentThread]);
        dispatch_semaphore_signal(dsema);
    });

    dispatch_group_wait(group, 30);
    dispatch_semaphore_wait(dsema, 30);

    return 0;
}




int allCleared(id jobsList)
{
    allclearFethed = [crawlers_obj count];

    for (int cnt_thread = [crawlers_obj count]-1; cnt_thread >=0; cnt_thread  --) {
        id objInThread = [ crawlers_obj objectAtIndex:cnt_thread] ;
        int clearState =  [objInThread cleared];
        allclearFethed -=  (int)(clearState) ; // :: -= 1
                                               // if(allclearFethed) break;
    }
    return ! ( allclearFethed != 0 ||  ([jobsList count] > 0) ) ;
}

void addLinkCollecting(id linkArray)
{
    if(linkArray == nil || ![linkArray count ]){
        return;
    }
    @synchronized (operation_list_collected) {
        @try{
            NSLog(@" ############## >>>> Collecting  ....");
            [operation_list_collected addObjectsFromArray: linkArray] ;
        } @catch (NSException *exception) {
            NSLog(@" MAIN :: ERROR :: addLinkCollecting :::: \n :: %@ \n :: (%ld) :: %@",exception , [linkArray count],  linkArray);
        } @finally {
            ;;
        }
        NSLog(@" ############## <<<<< Clear Collected  (%ld::%ld) ....", [operation_list_collected count], [linkArray count]);
    }
    
}

void addLinkCollectingIndex(id linkArray)
{
    if(linkArray == nil || ![linkArray count ]){
        return;
    }
    @synchronized (operation_list_collected) {
        @try{
            NSLog(@" ############## >>>> Collecting INDEXES ....");
            [operation_list_collected_indexes addObjectsFromArray_Unique: linkArray] ;
        } @catch (NSException *exception) {
            NSLog(@" MAIN :: ERROR :: addLinkCollecting :::: \n :: %@ \n :: (%ld) :: %@",exception , [linkArray count],  linkArray);
        } @finally {
            ;;
        }
        NSLog(@" ############## <<<<< Clear Collected  INDEXES (%ld::%ld) ....", [operation_list_collected_indexes count], [linkArray count]);
    }
    
}



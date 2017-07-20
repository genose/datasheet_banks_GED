 //
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



int cnt ;
NSMutableArray* crawlers_obj;
int allclearFethed;

int main(int argc, const char * argv[]) {
    
        
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
    
    
 
    
    
   /* NSLog(@" ############## Collecting clear ....");
    NSLog(@" ############## \n COLECTED LINKS INDEX: (%ld) \n %@",[operation_list_collected count], nil);
 
    int stateColleted = dispatch_jobs( operation_list_collected_indexes, followUrls_INDEXES );
    NSLog(@" ############## \n :::::: COLECTED LINKS : (%ld) \n %@",[operation_list_collected count], nil);
    
    [[crawlers_obj objectAtIndex:0] resetFollowed];
    */
    int stateColletedDatasheet = dispatch_jobs( [NSMutableArray arrayWithObjects:
                                                 @"http://www.alldatasheet.com/datasheet-pdf/pdf/44205/SIEMENS/BAT66-05.html",
//                                                 @"http://www.alldatasheet.com/datasheet-pdf/pdf/137274/AD/ADXL105EM-1.html",
//                                                 @"http://www.alldatasheet.com/datasheet-pdf/pdf/727243/MERITEK/AD.html",
                                                 nil], followUrls_PAGESDATASHEET );
    
    
    
    
    
    
    
    return 0;
}

int dispatch_jobs(id jobsList, int followUrls)
{
    
    
    dispatch_semaphore_t  _Nonnull dsema  = dispatch_semaphore_create(0);
    dispatch_group_t group = dispatch_group_create();
    //2.create queue
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    
    
    
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
                    
                    //                    [NSThread detachNewThreadWithBlock:
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
                                                         
                                                         
                                                         
                                                         @try {
                                                             
//                                                             PGConnection *connection = [[PGConnection alloc] init];
//                                                             
//                                                             [connection setUserName: @"postgres"];
//                                                             [connection setPassword: @""];
//                                                             [connection setServer: @"localhost"];
//                                                             [connection setPort: @"5432"];
//                                                             [connection setDatabaseName: @"postgres"];
//                                                             
//                                                             if( [connection connect] )
//                                                             {
//                                                                 NSString *cmd;
//                                                                 cmd = [NSString stringWithString: @"select verison() as version"];
//                                                                 PGSQLRecordset *rs = [connection open: cmd];
//                                                                 
//                                                                 if( ![rs is EOF] )
//                                                                 {
//                                                                     [serverVersion setStringValue: [[rs fieldByName: @"version"] asString]];
//                                                                 }
//                                                                 [rs close];
//                                                                 [connection close];
//                                                             }
//                                                             else
//                                                             {
//                                                                 NSLog( @"Connection Error: %@", [connecion lastError] );
//                                                             }
//                                                             
                                                             
                                                             
                                                             PGQueryObject* query = [PGQuery queryWithString:@"SELECT datname AS database,pid AS pid,query AS query,usename AS username,client_hostname AS remotehost,application_name,query_start,waiting FROM pg_stat_activity WHERE pid <> pg_backend_pid()"];
                                                             
                                                             
                                                             NSURL* urlBDD = [NSURL URLWithString:@"postgresql://stats:xcode@localhost/scotillard"];
                                                             
                                                             NSString* username = NSUserName();
                                                             NSString* userpassword = @"scott";
                                                             NSString* dbname = NSUserName();
                                                             NSURL* urlBDD_test = [NSURL URLWithHost:@"localhost" port: 5432 ssl:NO username:username database:dbname params:nil];
                                                             urlBDD_test = [NSURL URLWithSocketPath:nil port:(NSUInteger)5432 database:nil username:username params:nil];
                                                             
                                                             urlBDD_test = [NSURL URLWithHost:@"localhost" ssl:NO username: username database:dbname params:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                                                                             @"5432", @"port",
                                                                                                                                                             
                                                                                                                                                             [NSString stringWithFormat:@"%d",20], @"connect_timeout",
                                                                                                                                                             
                                                                                                                                                             userpassword,  @"password",
                                                                                                                                                             
                                                                                                                                                             
                                                                                                                                                             
                                                                                                                                                             nil] ];
                                                             NSLog(@" Sart Connection with  : %@ : %@", urlBDD_test, urlBDD);
                                                             NSError* cnxError = nil;
                                                             
                                                             BOOL isConnected = FALSE;
                                                             
                                                             PGConnection *SQLServ_db = [PGConnection new];
                                                             
                                                             //
                                                             [SQLServ_db setDelegate:[crawlers_obj objectAtIndex:0]];
                                                             
                                                             
                                                             //        [SQLServ_db connectWithURL:urlBDD_test usedPassword:&isConnected error:&cnxError];
                                                             
                                                             [SQLServ_db connectWithURL:urlBDD_test   whenDone:^(BOOL usedPassword, NSError *error) {
                                                                 
                                                                 if(error) {
                                                                     NSLog(@" SQLServ_db  :: Error: %@",error);
                                                                     [ SQLServ_db disconnect];
                                                                     return;
                                                                 }else {
                                                                     NSLog(@" SQLServ_db  :: connected .... : %@",error);
                                                                     [SQLServ_db executeQuery:query whenDone:^(PGResult* result, NSError* error) {
                                                                         if(result) {
                                                                             NSLog(@" SQLServ_db  :: %@ ", result);
                                                                         }
                                                                         if(error) {
                                                                             NSLog(@" SQLServ_db :: error :: %@ :: %@", result, error);
                                                                         }
                                                                     }];
                                                                 }
                                                                 [SQLServ_db disconnect];
                                                                 //                                                                 cleared_status =  YES;
                                                             }];
                                                             
                                                             
                                                         } @catch (NSException *exception) {
                                                             NSLog(@" ERROR :: %@ :: %@",@"Main", exception);
                                                         } @finally {
                                                             ;;
                                                         }
                                                         
                                                         
                                                         
                                                         
                                                     }
                                             

                                             
                                             NSLog(@" -------- CLEAR ::::  %@  \n ==== \n  fetchedData : %ld :: fetchedDataIndex : %ld  \n ==== \n ", PageCrawler,  (unsigned long)[[PageCrawler fetchedData] count],  [[PageCrawler fetchedDataIndex] count]);
                                             
                                             //                    }];
                                         });
                    
                   [NSThread sleepForTimeInterval:.2];
                    
                }else if([jobsList count]){
                    NSLog(@" ====  %@ ==== Something wrong in queue :: %ld :: %@ ", [NSThread currentThread], [jobsList count], urltoFetch);
                }
                
            }else{
                //  NSLog(@" ====  %@ ==== Nothing to do in queue :: %ld", [NSThread currentThread], [operation_list count]);
            }
            
        }
        
        
        inQueueWainting   = [jobsList count];
        
        
        
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



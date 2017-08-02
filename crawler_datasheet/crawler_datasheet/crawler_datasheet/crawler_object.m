//
//  crawler_object.m
//  crawler_datasheet
//
//  Created by Sebastien COTILLARD on 07/07/2017.
//  Copyright © 2017 Sebastien COTILLARD. All rights reserved.
//

#import "crawler_object.h"
#import "XPathQuery.h"
#import <PGClientKit/PGClientKit.h>

#ifndef DEF_PGPORT
#define DEF_PGPORT 5432
#endif

static NSMutableDictionary *followedLink;


@implementation crawler_object


@synthesize document_url;
@synthesize  cleared_status;
@synthesize document_url_index;
@synthesize document_url_index_follow;
@synthesize document_url_index_child;

// @synthesize SQLServ_db;
@synthesize SQLServ_db = _SQLServ_db;

-(instancetype)initWithUrl:(NSString*)urlEntryPoint {
    
    if( self  ==nil)
        self = [super init];
    
    
    _SQLServ_db = [PGConnection new];
    [_SQLServ_db setDelegate:self];
    cleared_status =  NO;
    //     document_url_index_follow = NO;
    document_url = urlEntryPoint;
    element_urls_documents = [NSMutableArray array];
    element_urls_indexes = [NSMutableArray array];
    element_urls_indexes_pages_relatives = [NSMutableArray array];
    element_urls_relatives = [NSMutableArray array];
    element_urls = [NSMutableArray array];
    
    if(followedLink == nil )
        followedLink = [NSMutableDictionary dictionary];
    [self doFetchData];
    
    return self;
}




-(id)nodesForAxpression:(NSString*)xpathStr :(id)document
{
    
    @autoreleasepool {
        
        
        //         NSError * error = nil;
        NSArray* results =  PerformHTMLXPathQuery(
                                                  ((NSData *)document),
                                                  xpathStr );
        return results;
        //         return [[document body] nodesForXPath:xpathStr];
        
    }
    
}

-(id)doFetchData
{
    @try {
        @autoreleasepool {
            cleared_status =  NO;
            document_url_index_child ++;
            
            if(document_url == nil || [((NSString*)document_url)  containsString:@"null"] ){
                NSLog(@":::: WARNING :::: document_url is nil (%@)",document_url);
                return self;
            }
            
            NSURL * fetched_document_url = [NSURL URLWithString: document_url ];
            NSString * fetched_document_url_scheme = [fetched_document_url scheme];
            NSString * fetched_document_url_uri = [fetched_document_url query];
            NSString * fetched_document_url_host = [fetched_document_url host];
            NSArray* uri_compo = [fetched_document_url pathComponents];
            NSURL * urlNextPages = [[fetched_document_url URLByDeletingPathExtension] URLByDeletingLastPathComponent];
            
            //            NSLog(@" +++++ %@ init %@  :: %@ :: %@",((document_url_index_child > 1)? [NSString stringWithFormat: @"CSTHILD (%d) ::", document_url_index_child]: @"") , NSStringFromClass([self class]), document_url, [NSThread currentThread]);
            
            NSString *compoUrl = [[uri_compo componentsJoinedByString:@"/"] stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
            
            if(!fetched_document_url_uri)
                fetched_document_url_uri = document_url;
            
            if([[fetched_document_url_uri lowercaseString] containsString:@"searchword"]) {
                NSLog(@" +++++ ERROR :: init %@  :: %@ :: %@ :: %@",NSStringFromClass([self class]), document_url, fetched_document_url_uri, [NSThread currentThread]);
                cleared_status =  YES;
                
                return self ;
            }
            
            if([followedLink objectForKey:compoUrl] || [followedLink objectForKey:document_url] || document_url_index_child >2) {
                NSLog(@" .....  ALREADY DONE  :: FOOLOW Link (%@) ", compoUrl);
                cleared_status =  YES;
                return self;
            }
            
            NSError *error = nil;
            
            element_contents = [NSData dataWithContentsOfURL: fetched_document_url options:(NSDataReadingUncached) error:&error];
            
            //        NSURLRequest *qRequest = [NSURLRequest requestWithURL: url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
            
            //        NSURLConnection *qConnection = [[NSURLConnection alloc] initWithRequest:qRequest delegate:self];
            
            
            
            
            //            void* strChar = [element_contents bytes];
            //            if(strChar != NULL)
            //                element_contents_clear = [NSString stringWithUTF8String:strChar];
            //
            if(element_contents == nil ) {
                NSLog(@" :: Warning  :: %@ :: nil document %@", self, error);
                cleared_status =  YES;
                return self;
            }
            
            
            [followedLink setObject:document_url forKey:document_url];
            
            
            [followedLink setObject:compoUrl forKey:compoUrl];
            
            
            
            // NSXMLDocument *document = [[NSXMLDocument alloc] initWithData: element_contents options:NSXMLDocumentTidyHTML|NSXMLDocumentTidyXML error:&error];
            
            
            // 2
            //                    TFHpple *document = [TFHpple hppleWithHTMLData:element_contents];
            //            HTMLDocument *document = [[HTMLDocument alloc] initWithData:element_contents error:&error];
            id document = element_contents;
            
            // :: datasheet.jsp?index=2&page=107
            
            NSString *XpathQueryString_flatlist_index_link = nil;
            NSArray *queryNodes_link = nil ;
            
            // pagen listing composants
            if( ![fetched_document_url_uri containsString:@"/pdf/"] && [fetched_document_url_uri containsString:@".com/datasheet/"] ) {
                XpathQueryString_flatlist_index_link = @"//a[contains(@href,'datasheet-pdf')]";
                queryNodes_link = [self nodesForAxpression:XpathQueryString_flatlist_index_link  :document];;
                ;;
            }else
                
                
                if([fetched_document_url_uri containsString:@"/pdf/"]) {
                    XpathQueryString_flatlist_index_link = @"//p/a[contains(@href,'/datasheet/')][contains(@href,'.html')]";
                    
                }else if([uri_compo count] <2){
                    XpathQueryString_flatlist_index_link = @"//p/a[contains(@href,'/datasheet/')][contains(@href,'.html')]";
                    queryNodes_link = [self nodesForAxpression:XpathQueryString_flatlist_index_link  :document];;
                }
            //
            //
            //        if(queryNodes_link != nil && [queryNodes_link count]){
            //            XpathQueryString_flatlist_index_link = @"//a[contains(@href,'description.jsp')]";
            //            queryNodes_link = [document nodesForXPath:XpathQueryString_flatlist_index_link  error:&error];
            //        }
            //
            //
            if(queryNodes_link != nil && [queryNodes_link count]){
                // 4
                
                for (id element in queryNodes_link) {
                    
                    
                    // 7
                    NSArray* urlsList = [element  attributeForName:@"href"];
                    NSString* urls = [((NSArray*)urlsList ) firstObject];
                    
                    if( ! [[NSURL URLWithString: urls] scheme] ) {
                        urls = [NSString stringWithFormat:@"%@://%@/%@",fetched_document_url_scheme, fetched_document_url_host , urls];
                    }
                    if(urls != nil && ![((NSString*)urls)  containsString:@"null"]) {
                        urls = [urls stringByReplacingOccurrencesOfString:@"://" withString:@":::"];
                        urls = [urls stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
                        urls = [urls stringByReplacingOccurrencesOfString:@":::" withString:@"://"];
                        [element_urls_indexes addObjectUnique:urls];
                    }else{
                        NSLog(@" %@ ******** Warning ******* \n can t add object (%@)",[NSThread currentThread], urls);
                    }
                    
                }
            }
            
            if(![element_urls_indexes count]){
                NSLog(@" ... NOPE ....");
            }
            
            
            NSString *XpathQueryString_pagesnext_link = [NSString stringWithFormat:@"//a[contains(@href,'.html')][contains(@href,'/%@-')][not(contains(@href,'pdf/'))]",  [uri_compo objectAtIndex:(([uri_compo count]>2)?[uri_compo count] -2 : 0) ]];
            NSArray *queryNodes_pagesnext = [self nodesForAxpression:XpathQueryString_pagesnext_link  :document];
            if(queryNodes_pagesnext != nil && [queryNodes_pagesnext count]){
                // 4
                
                for ( id element in queryNodes_pagesnext) {
                    
                    
                    // 7
                    NSArray* urlsList = [element  attributeForName:@"href"];
                    NSString* urls = [((NSArray*)urlsList ) firstObject];
                    // :: if( ! [urls containsString: fetched_document_url_host])
                    if( ! [[NSURL URLWithString: urls] scheme] )
                    {
                        urls = [NSString stringWithFormat:@"%@://%@/%@",fetched_document_url_scheme, fetched_document_url_host , urls];
                    }
                    if(urls != nil && ![((NSString*)urls)  containsString:@"null"])
                    {
                        urls = [urls stringByReplacingOccurrencesOfString:@"://" withString:@":::"];
                        urls = [urls stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
                        urls = [urls stringByReplacingOccurrencesOfString:@":::" withString:@"://"];
                        [element_urls_indexes_pages_relatives addObjectUnique:urls];
                    }
                }
                
                /* ****************************** */
                /* ****************************** */
                /* ****************************** */
                
                //                if(false && document_url_index_follow) {
                //
                //
                //
                //                    dispatch_semaphore_t  _Nonnull dsema  = dispatch_semaphore_create(0);
                //                    dispatch_group_t group = dispatch_group_create();
                //                    //2.create queue
                //                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                //                    int cnt = 8;
                //                    NSMutableArray* crawlers_obj = [NSMutableArray arrayWithCapacity: cnt];
                //                    /* ****************************** */
                //                    while ( cnt >0 ){
                //                        id  PageCrawler =  [[crawler_object alloc] init];
                //                        ((crawler_object *)PageCrawler).cleared_status =YES;
                //                        ((crawler_object *)PageCrawler).document_url_index_follow = NO;
                //                        ((crawler_object *)PageCrawler).document_url_index_child = 1;
                //                        [crawlers_obj addObject: PageCrawler ];
                //                        cnt--;
                //                    }
                //                    /* ****************************** */
                //
                //                    cnt = [element_urls_indexes_pages_relatives count];
                //
                //                    while ( cnt >=1 )
                //                    {
                //
                //                        cnt = [element_urls_indexes_pages_relatives count];
                //                        [NSThread sleepForTimeInterval:.1];
                //
                //                        for (int cnt_thread = [crawlers_obj count]-1; cnt_thread >0; cnt_thread  --) {
                //
                //                            [NSThread sleepForTimeInterval:.1];
                //
                //                            id objInThread = [ crawlers_obj objectAtIndex:cnt_thread] ;
                //                            bool cleared_fetch = [objInThread cleared];
                //
                //                            NSLog(@" Thread %d :: state : %d :: ope. %d :: %@ ", cnt_thread, cleared_fetch, cnt, objInThread );
                //
                //                            id PageCrawler = (( cleared_fetch && objInThread != nil )? objInThread :nil);
                //                            if(PageCrawler != nil) {
                //                                // :cnt ++;
                //
                //                                NSString* url_document_url_index_follow  = [element_urls_indexes_pages_relatives pushFiFo];
                //
                //                                NSArray* uri_compo_follow = [[NSURL URLWithString:url_document_url_index_follow] pathComponents];
                //
                //                                NSString *followedLink_follow = [[uri_compo_follow componentsJoinedByString:@"/"] stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
                //
                //                                if([followedLink objectForKey:uri_compo_follow]   ) {
                //                                    NSLog(@" .....  :::: ALREADY DONE  :: FOOLOW Link (%@) ", uri_compo_follow);
                //                                    continue;
                //
                //                                }
                //
                //                                if( url_document_url_index_follow  == nil )
                //                                {
                //                                    NSLog(@" .....  :::: NIL FOLLOW ::: WARNING :: FOOLOW Link (%@) :: %@", url_document_url_index_follow, document_url);
                //                                    break;
                //                                }
                //
                //                                if([((NSString*)url_document_url_index_follow)  containsString:@"null"])
                //                                {
                //                                    NSLog(@" .....  :::: CAN4T FOLLOW ::: WARNING :: FOOLOW Link (%@) ", url_document_url_index_follow);
                //                                    continue;
                //                                }
                //
                //                                ((crawler_object *)PageCrawler).cleared_status = NO;
                //                                ((crawler_object *)PageCrawler).document_url = [NSString stringWithFormat:@"%@",url_document_url_index_follow];
                //
                //
                //                                ((crawler_object *)PageCrawler).document_url_index_follow = NO;
                //                                ((crawler_object *)PageCrawler).document_url_index_child = cnt_thread;
                //
                //                                dispatch_group_async(group, queue, ^{
                //
                //                                    crawler_object *subpage_index_crawler = ((crawler_object *)PageCrawler) ;
                //
                //                                    NSString * thread_uri_following = [NSString stringWithFormat:@"%@",((crawler_object *)subpage_index_crawler).document_url];
                //
                //                                    NSString* opeChildName = [NSString stringWithFormat:@"Child :: (%d::%d::%ld) >> %@ >> (%@) ", ((crawler_object *)subpage_index_crawler).document_url_index_child, cnt, [element_urls_indexes_pages_relatives count], document_url, thread_uri_following];
                //
                //
                //                                    [[NSThread currentThread] setName: opeChildName];
                //
                //                                    NSLog(@" ..... >> (%@) ", opeChildName );
                //
                //
                //                                    if([((NSString*)thread_uri_following)  containsString:@"null"])
                //                                    {
                //                                        NSLog(@" .....  :::: CAN4T FOLLOW ::: WARNING :: FOOLOW Link (%@) ", thread_uri_following);
                //                                        ;;
                //                                    }else{
                //
                //                                        subpage_index_crawler = [subpage_index_crawler initWithUrl:thread_uri_following];
                //
                //                                    }
                //                                    ((crawler_object *)subpage_index_crawler).cleared_status = NO;
                //                                    long cnt_docs = [element_urls_documents count];
                //                                    long cnt_docs_indexes = [element_urls_indexes count];
                //
                //                                    id fetchedFollow = [((crawler_object *)subpage_index_crawler) fetchedData];
                //                                    id fetchedFollowIndexed = [((crawler_object *)subpage_index_crawler) fetchedDataIndex];
                //
                //                                    long fetchedFollow_cnt_docs = [fetchedFollow count];
                //                                    long fetchedFollow_cnt_docs_indexes = [fetchedFollowIndexed count];
                //
                //                                    [element_urls_documents addObjectsFromArray: fetchedFollow];
                //                                    [element_urls_indexes addObjectsFromArray: fetchedFollowIndexed];
                //
                //                                    NSLog(@" ..... << (%@) (%ld :: %ld) adding (%ld :: %ld) ", ((crawler_object*)subpage_index_crawler).document_url , cnt_docs, cnt_docs_indexes, fetchedFollow_cnt_docs, fetchedFollow_cnt_docs_indexes);
                //
                //                                    [NSThread sleepForTimeInterval:.1];
                //                                    ((crawler_object *)subpage_index_crawler).cleared_status = YES;
                //
                //                                });
                //                                [NSThread sleepForTimeInterval:.5];
                //
                //                            }
                //
                //                        }
                //
                //                    }
                //                    //4.notify when finished
                //                    dispatch_group_notify(group, queue, ^{
                //
                //                        NSLog(@" ------- fiish foolowed- %@", [NSThread currentThread]);
                //                        dispatch_semaphore_signal(dsema);
                //                    });
                //
                //                    dispatch_group_wait(group, DISPATCH_TIME_NOW);
                //                    dispatch_semaphore_wait(dsema, DISPATCH_TIME_NOW);
                //
                //
                //                }
                
            }
            /// page Liste link datasheet
            
            // :: http://www.alldatasheet.com/view_datasheet.jsp?Searchword=2SC4330
            
            NSString *XpathQueryString_flatlist_link = @"//a[contains(@href,'/view')]";
            NSArray *queryNodes = [self nodesForAxpression:XpathQueryString_flatlist_link  :document];
            if(queryNodes != nil && [queryNodes count]){
                // 4
                
                for ( id element in queryNodes) {
                    
                    
                    // 7
                    NSArray* urlsList = [element  attributeForName:@"href"];
                    NSString* urls = [((NSArray*)urlsList ) firstObject];
                    // :: if( ! [urls containsString: fetched_document_url_host])
                    if( ! [[NSURL URLWithString: urls] scheme] ) {
                        urls = [NSString stringWithFormat:@"%@://%@/%@",fetched_document_url_scheme, fetched_document_url_host , urls];
                    }
                    if(urls != nil && ![((NSString*)urls)  containsString:@"null"]) {
                        urls = [urls stringByReplacingOccurrencesOfString:@"://" withString:@":::"];
                        urls = [urls stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
                        urls = [urls stringByReplacingOccurrencesOfString:@":::" withString:@"://"];
                        [element_urls_documents addObjectUnique:urls];
                    }
                }
            }
            
            
            
            if([fetched_document_url_uri containsString:@"/datasheet-pdf/pdf/"]){
                
                // Page Descrioptor Datasheet
                NSString *XpathQueryString_pdfdirect_link = @"//td[@class='blue']/a[contains(@href,'pdf')]";
                NSString *XpathQueryString_pdf_part = @"//table[@class='preview']/tr/td[@width='247']";
                NSString *XpathQueryString_pdf_description = @"//table[@class='preview']/tr/td/table[@class='preview']/tr/td";
                
                NSString *XpathQueryString_pdf_part_constructor = @"//table[@class='preview']/tr/td/table[@class='preview']/tr/td";
                
                
                NSArray *linkNodes = [self nodesForAxpression:XpathQueryString_pdfdirect_link  :document];
                
                NSArray *partItemsNodes = [self nodesForAxpression:XpathQueryString_pdf_part  :document];
                // partItemsNodes = [NSArray arrayWithObjects: [partItemsNodes firstObject ],nil ];
                
                NSArray *titleItemsNodes = [self nodesForAxpression:XpathQueryString_pdf_description  :document];
                
                //                 NSLog(@" $$ ************** titleItemsNodes :: %@ **************** $$ ", titleItemsNodes);
                
                //                if([titleItemsNodes  count] >=2)
                //                    titleItemsNodes = [NSArray arrayWithObjects: [titleItemsNodes objectAtIndex:[titleItemsNodes  count] -2], [titleItemsNodes objectAtIndex:[titleItemsNodes  count] -1],  nil];
                
                element_document_url    = [[((NSArray*)[ [linkNodes firstObject]  attributeForName:@"href"]) firstObject]  stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet] ] ;
                
                id partItemsNodes_chunck = [partItemsNodes firstObject];
                id partchuncks = [titleItemsNodes lastObject];
                
                element_name            =  [[((NSArray*)[partItemsNodes_chunck textContents]) componentsJoinedByString:@""]  stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet] ];
                
                element_description     =  [[((NSArray*) [ (partchuncks) textContents]) componentsJoinedByString:@""]  stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet] ];
                
                
                
                //                NSLog(@" $$ ************** titleItemsNodes :: %@ **************** $$ ", titleItemsNodes);
                int flag = 0;
                for (id elementKey in titleItemsNodes) {
                    
                    id elmentcontent  = [ elementKey objectForKey:@"nodeChildArray"];
                    
                    if( elmentcontent != nil )
                    {
                        
                        elmentcontent  = [ [elmentcontent firstObject] objectForKey:@"nodeContent"];
                        
                        if(flag >0)
                        {
                            element_name_constructor = [((NSString*)elmentcontent) stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet] ];
                            break;
                        }
                        
                        
                        
                        if(  [ [elmentcontent lowercaseString] isEqualToString:@"maker"] || [ [elmentcontent lowercaseString] isEqualToString:@"manufacture"] )
                        {
                            //                             NSLog(@" $$ ************** titleItemsNodes :: %@ **************** $$ ", elmentcontent );
                            flag ++;
                        }else{
                            //                             NSLog(@" $$ -------- titleItemsNodes :: %@ **************** $$ ", elmentcontent );
                        }
                        
                    }
                }
                //                element_name_constructor     =  [titleItemsNodes firstObject] ;
                
                element_name_constructor     = element_name_constructor; // [element_name attributeForName:@"href"];
                NSLog(@" \n $$$$$$$$ So we Got \n :: name (%@)\n :: description (%@)\n :: Maker (%@)\n :: Datasheeet at (%@) \n  $$$$$$$$ \n", element_name, element_description, element_name_constructor, element_document_url  );
                
                                [self query:@"..."];
                
                
            }else{
                cleared_status =  YES;
            }
            
            
        }
        
        NSLog(@" ..... SELF << (%@) adding (%ld :: %ld) ", ((document_url_index_child > 1)? [NSString stringWithFormat: @"CSTHILD (%d) ::", document_url_index_child]: @"") ,  [[self fetchedData] count], [[self fetchedDataIndex] count]);
        
        //        if(document_url_index_follow){
        //            addLinkCollectingIndex([self fetchedDataIndexPages]);
        //        }
        //        addLinkCollecting([self fetchedDataIndex]);
        
        
        
        
        
    } @catch (NSException *exception) {
        NSLog(@" ERROR :: %@",exception);
    } @finally {
        ;;
    }
    document_url_index_child --;
    
    return self;
    
}
-(id)fetchedDataIndexPages  {
    
    return element_urls_indexes_pages_relatives;
    
}
-(id)fetchedDataIndex  {
    
    return element_urls_indexes;
    
}
-(id)fetchedData  {
    
    return element_urls_documents;
    
}

-(bool)resetFollowed
{
    
    followedLink = [NSMutableDictionary dictionary];
    return (followedLink == nil);
}

-(bool)cleared
{
    return cleared_status;
}
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%@) :: %p :: (%ld) : url : %@ ( relative : %ld)", NSStringFromClass([self class]), ((cleared_status)?@"Cleared": @"In Progress"), self, document_url_index, document_url, [element_urls_indexes_pages_relatives count]];
}


-(void)query: (NSString*)aQuery
{
    
     cleared_status =  NO;
    @try {
        
        PGQueryObject* query =
//        [PGQuery queryWithString:@"SELECT datname AS database,pid AS pid,query AS query,usename AS username,client_hostname AS remotehost,application_name,query_start,waiting FROM pg_stat_activity WHERE pid <> pg_backend_pid()"];
         [PGQuery queryWithString:@"SELECT datname FROM pg_database"];
        
         PGQueryObject* query2 =[PGQuery queryWithString:[NSString stringWithFormat:@"SELECT user FROM %@", NSUserName()]];
        
        //     query = [PGQuery queryWithString:@"INSERT INTO public.datanet(  datanet_path, datanet_composant, datanet_content) VALUES ( 'fairchild', '2N****', 'composant ****');"];
        
        
        NSURL* urlBDD = [NSURL URLWithString:@"postgresql://stats:xcode@localhost/scotillard"];
        
        NSString* username = NSUserName();
        NSString* userpassword = @"scott";
        NSString* dbname = NSUserName();
        NSURL* urlBDD_test = [NSURL URLWithHost:@"localhost" port: 5432 ssl:NO username:username database:dbname params:nil];
        //          urlBDD_test = [NSURL URLWithSocketPath:nil port:(NSUInteger)5432 database:nil username:username params:nil];
        
        urlBDD_test = [NSURL URLWithHost:@"localhost" ssl:NO username: username database:dbname params:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                        @"5432", @"port",
                                                                                                        
                                                                                                        [NSString stringWithFormat:@"%d",20], @"connect_timeout",
                                                                                                        
                                                                                                        userpassword,  @"password",
                                                                                                        
                                                                                                        
                                                                                                        
                                                                                                        nil] ];
        
        NSLog(@" Sart Connection with  : %@ : %@", urlBDD_test, urlBDD);
        NSError* cnxError = nil;
        
        BOOL isConnected = FALSE;
        
//        SQLServ_db = [PGConnection new];
        
        
        
        
        //        [SQLServ_db connectWithURL:urlBDD_test usedPassword:&isConnected error:&cnxError];
        
        [((PGConnection*)[self SQLServ_db]) connectWithURL: urlBDD_test   whenDone:^(BOOL usedPassword, NSError *errorConnect) {
            NSLog(@" SQLServ_db  :: .... :");
            if(errorConnect) {
                NSLog(@" SQLServ_db  :: connectWithURL: Error: %@",errorConnect);
                //
                [[self SQLServ_db] disconnect];
                 cleared_status =  YES;
                
            }else {
                 NSLog(@" SQLServ_db  :: connectWithURL: connected .... : %@",errorConnect);
                
                
//                dispatch_semaphore_t s = dispatch_semaphore_create(0);

                
                [[self SQLServ_db] execute:query whenDone:^(PGResult* result, NSError* error) {
                    NSLog(@" SQLServ_db :: query_1 :: pass ");

                    //                    if(result) {
                    NSLog(@" SQLServ_db :: query_1 :: obj execute: result :: %@ ", [result fetchRowAsDictionary]);
                    //                    }
                    if(error) {
                        NSLog(@" SQLServ_db :: query_1 :: obj execute:error :: %@ :: %@", result, error);
                    }
//                    [[self SQLServ_db] disconnect];
//                    cleared_status =  YES;
//                            dispatch_semaphore_signal(s);
                    
                }];
                
                
//                dispatch_semaphore_wait(s,DISPATCH_TIME_FOREVER);
                 NSLog(@" SQLServ_db :: semaphore end :: pass ");

//                [[self SQLServ_db] _waitingPoolOperationForResult];
//                [[self SQLServ_db] _waitingPoolOperationForResultMaster];
                [[self SQLServ_db] execute:query2 whenDone:^(PGResult* result, NSError* error) {
                    NSLog(@" SQLServ_db :: query_2 :: pass ");
                    //                    if(result) {
                    NSLog(@" SQLServ_db :: query_2 :: obj execute: result :: %@ ", [result fetchRowAsDictionary]);
                    //                    }
                    if(error) {
                        NSLog(@" SQLServ_db :: query_2 :: obj execute:error :: %@ :: %@", result, error);
                    }
                    //                    [[self SQLServ_db] disconnect];
                    //                    cleared_status =  YES;
                    
                }];
                
            }
            
            NSLog(@" SQLServ_db  ..... DONE :: .... :");
           
        }];
//        [NSThread sleepForTimeInterval:6.0];
//        [[self SQLServ_db] execute:query2 whenDone:^(PGResult* result, NSError* error) {
//            //                    if(result) {
//            NSLog(@" SQLServ_db :: query2 :: pass ");
//            NSLog(@" SQLServ_db :: query2 :: obj execute: result :: %@ ", [result fetchRowAsDictionary]);
//            //                    }
//            if(error) {
//                NSLog(@" SQLServ_db :: query2 :: obj execute:error :: %@ :: %@", result, error);
//            }
//            [[self SQLServ_db] disconnect];
//            cleared_status =  YES;
//            
//        }];
  NSLog(@" SQLServ_db  ..... exit :: .... :");
        
    } @catch (NSException *exception) {
        NSLog(@" ERROR :: %@ :: %@",NSStringFromSelector(_cmd), exception);
    } @finally {
        ;;
    }
}
-(void)connection:(PGConnection* )connection willOpenWithParameters:(NSMutableDictionary* )dictionary{
    NSLog(@" SQLServ_db   delegate :: %@ :: %@ ", NSStringFromSelector(_cmd), dictionary);
}

-(NSString* )connection:(PGConnection* )connection willExecute:(NSString *)query {
    NSLog(@" SQLServ_db  delegate :: %@ :: %@ ", NSStringFromSelector(_cmd),query);
    return NSStringFromClass([self class]);
}

-(void)connection:(PGConnection* )connection statusChange:(PGConnectionStatus)status description:(NSString *)description {
    
    NSLog(@" SQLServ_db   delegate :: %@ :: %@ ", NSStringFromSelector(_cmd),[NSString stringWithFormat:@"StatusChange: %@ (%d)",description,status] );
    
    // disconnected
    if(status==PGConnectionStatusDisconnected) {
        // indicate server connection has been shutdown
        [[self SQLServ_db] disconnect ];
    }
}

-(void)connection:(PGConnection* )connection error:(NSError* )error {
    NSLog(@" SQLServ_db   delegate :: %@ :: %@ ", NSStringFromSelector(_cmd),[NSString stringWithFormat:@"Error: %@ (%@/%ld)",[error localizedDescription],[error domain],[error code] ]);
}

-(void)connection:(PGConnection* )connection notice:(NSString* )notice {
    NSLog(@" SQLServ_db   delegate :: %@ :: %@ ", NSStringFromSelector(_cmd),[NSString stringWithFormat:@"Notice: %@",notice]);
}

-(void)connection:(PGConnection *)connection notificationOnChannel:(NSString* )channelName payload:(NSString* )payload {
    NSLog(@" SQLServ_db  delegate  :: %@ :: %@ ", NSStringFromSelector(_cmd),[NSString stringWithFormat:@"Notification: %@ Payload: %@",channelName,payload ]);
}
@end

@implementation NSXMLElement (nsdictExtend)
/*
 -(id)firstObject
 {
 
 return [self allKeys];
 
 }
 */
@end



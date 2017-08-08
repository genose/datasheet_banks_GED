//
//  crawler_object.h
//  crawler_datasheet
//
//  Created by Sebastien COTILLARD on 07/07/2017.
//  Copyright © 2017 Sebastien COTILLARD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFHpple.h"
#import <PGClientKit/PGClientKit.h>

@interface crawler_object : NSObject  <PGConnectionDelegate>  {

    
    // PGConnection *_SQLServ_db;
    
    
        NSString *element_name;
        NSString* element_name_constructor;
    
        NSString *element_document_url;
        NSString *element_title;
        NSString *element_description;
        NSData   *element_contents;
        NSString   *element_contents_clear;
        NSMutableArray *element_urls;
        NSMutableArray *element_urls_relatives;
        NSMutableArray *element_urls_indexes;
        NSMutableArray *element_urls_indexes_pages_relatives;
        NSMutableArray *element_urls_documents;
        
        
    }
@property (nonatomic) NSString *document_url;
@property     long document_url_index;
@property     bool document_url_index_follow;
@property     int  document_url_index_child;
@property     bool cleared_status;

@property (readonly) PGConnection* SQLServ_db;

-(instancetype)initWithUrl:(NSString*)urlEntryPoint;
-(id)nodesForAxpression:(NSString*)xpathStr :(id)document;

-(void)query: (NSString*)aQuery;

-(id)fetchedDataIndexPages;
-(id)doFetchData;
-(id)fetchedData;
-(id)fetchedDataIndex;
-(bool)cleared;
-(bool)resetFollowed;
@end

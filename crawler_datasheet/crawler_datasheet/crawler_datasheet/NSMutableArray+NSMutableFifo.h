//
//  NSMutableArray+NSMutableFifo.h
//  crawler_datasheet
//
//  Created by Sebastien COTILLARD on 07/07/2017.
//  Copyright © 2017 Sebastien COTILLARD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (NSMutableFifo)
    
-(id)pushFiFo;
@end

@interface NSMutableArray (nsarray_ExtendUniqueKey)
-(id)addObjectsFromArray_Unique:(NSArray *)otherArray;
-(id)addObjectUnique:(id)anObject;
@end

@interface NSMutableDictionary (nsarray_ExtendUniqueKey)
-(id)textContents;
-(id)attributeForName:(id)anObject;
@end

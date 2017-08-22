//
//  NSMutableArray+NSMutableFifo.m
//  crawler_datasheet
//
//  Created by Sebastien COTILLARD on 07/07/2017.
//  Copyright © 2017 Sebastien COTILLARD. All rights reserved.
//

#import "NSMutableArray+NSMutableFifo.h"

@implementation NSMutableArray (NSMutableFifo)

-(id)pushFiFo
{
    //   NSMutableArray *array = [NSMutableArray arrayWithArray: self];
    id elementFifo = nil;
    if([self count])
    {
        elementFifo = [self objectAtIndex:0];
        [ self removeObjectAtIndex:0];
    }
    
    else return nil;
    
    return elementFifo;
}

@end



@implementation NSMutableArray (nsarray_ExtendUniqueKey)
-(id)addObjectsFromArray_Unique:(NSArray *)otherArray
{
    if(!self)
        return self;
    @try {
        @synchronized (self) {
            
            for (id objNew in otherArray) {
                if(objNew != nil && [objNew respondsToSelector:@selector(description)])
                {
                    [self addObjectUnique: objNew];
                }
            }
            
        }
    }
    @catch (NSException *exception) {
        ;;
        NSLog(@" ERROR :: %@ :: %@ :: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception);
    }
    @finally {
        ;;
    }
    return self;
}
-(id)addObjectUnique:(id)anObject
{
    @try {
        @synchronized (self) {
            NSMutableDictionary* keysObjects = [NSMutableDictionary dictionary];
            int cntElement = [self count];
            if(cntElement){
                
                for (int idx = 0; idx < cntElement-1; idx ++) {
                    id objInIdx = [self objectAtIndex:idx];
                    if(objInIdx != nil && keysObjects != nil)
                    {
                        [keysObjects setObject:[NSString stringWithFormat:@"%d", idx] forKey:[NSString stringWithFormat:@"%@", objInIdx]];
                    }
                }
            }
            id keyedFound = [keysObjects objectForKey: [NSString stringWithFormat:@"%@",anObject]];
            if( keyedFound == nil) {
                [self addObject: anObject];
            }else{
                ;; // :: NSLog(@"duplicate : %@  :: %@ ", ((anObject)?[NSString stringWithFormat:@"%@",anObject]:@"----"), keyedFound);
            }
            [keysObjects removeAllObjects];
        }
        return self;
    }
    @catch (NSException *exception) {
        ;;
        NSLog(@" ERROR :: %@ :: %@ :: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), exception);
    }
    @finally {
        ;;
    }
    
}

@end

@implementation NSMutableDictionary (nsarray_ExtendUniqueKey)
-(id)textContents
{
    
    
    //    [self attributeForName:@"nodeContent"];
    
    NSMutableArray *returnDict = [NSMutableArray array];
    
    id node_Array = [self objectForKey: @"nodeChildArray"];// :: [self objectForKey: @"nodeAttributeArray"] ;
    
    for (id object in node_Array) {
        
        if( [object isKindOfClass:[NSDictionary class]]
           &&  [object objectForKey: @"nodeContent" ] != nil
           && [[object objectForKey: @"nodeName"] isEqualToString:@"text"] ){
            [returnDict addObject: [object objectForKey: @"nodeContent" ]];
            //            NSLog(@"\n **************  \n Attribs :: %@ :: %@ \n **************  \n ",object,  [object objectForKey: @"nodeContent" ]);
        }else  if( [object isKindOfClass:[NSDictionary class]]
                  &&  [object objectForKey: @"nodeChildArray" ] != nil)
        {
            [returnDict addObject: [[object  textContents] componentsJoinedByString:@""] ];
        }
    }
    
    if([returnDict count]) return returnDict;
    
    return nil;
}
-(id)attributeForName:(id)anObject
{
    
    NSMutableArray *returnDict = [NSMutableArray array];
    id node_Array = [self objectForKey: @"nodeAttributeArray"] ;
    for (id object in node_Array) {
        if([[object objectForKey: @"attributeName" ] isEqualToString: anObject]){
            [returnDict addObject: [object objectForKey: @"nodeContent" ]];
        }
    }
    
    id nodesArray = [self objectForKey: @"nodeChildArray"] ;
    for (id object in nodesArray) {
        if([[object objectForKey: @"nodeName" ] isEqualToString: anObject]){
            [returnDict addObject: [object objectForKey: @"nodeContent" ]];
        }
    }
    
    if([returnDict count]) return returnDict;
    
    return nil;
}
@end


// Copyright 2009-2015 David Thorpe
// https://github.com/djthorpe/postgresql-kit
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not
// use this file except in compliance with the License. You may obtain a copy
// of the License at http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
// License for the specific language governing permissions and limitations
// under the License.

@interface PGDialogView : NSObject <PGDialogDelegate> {
	NSMutableDictionary* _parameters;
	NSArray* _observers;
}

////////////////////////////////////////////////////////////////////////////////
// properties

@property (weak,nonatomic) id<PGDialogDelegate> delegate;
@property (weak,nonatomic) IBOutlet NSView* view;
@property (weak,nonatomic) IBOutlet NSView* firstResponder;
@property (readonly) NSMutableDictionary* parameters;
@property (readonly) NSArray* bindings;
@property (readonly) NSString* windowTitle;
@property (readonly) NSString* windowDescription;

////////////////////////////////////////////////////////////////////////////////
// public methods

/**
 *  Pass the parameters to a view in order to fill the view's details, before
 *  the view is displayed on screen.
 *
 *  @param parameters The dictionary of parameters
 */
-(void)setViewParameters:(NSDictionary* )parameters;

/**
 *  This method should be called when the window containing the view is dismissed
 *  to give an opportunity to remove key-vaue observers
 */
-(void)viewDidEnd;

/**
 *  This method is called when a bound value changes
 *
 *  @param key      The key value of the parameter
 *  @param oldValue The old value for the parameter
 *  @param newValue The new value for the parameter
 */
-(void)valueChangedWithKey:(NSString* )key oldValue:(id)oldValue newValue:(id)newValue;

@end

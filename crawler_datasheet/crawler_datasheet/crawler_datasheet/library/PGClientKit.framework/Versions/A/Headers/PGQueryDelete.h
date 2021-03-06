
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

@interface PGQueryDelete : PGQuery

////////////////////////////////////////////////////////////////////////////////
// constructors

/**
 *  Construct a PGQueryDelete instance which deletes rows from a single table
 *
 *  @param source A PGQuerySource or NSString object which determines which
 *                table to remove rows from.  Cannot be nil.
 *  @param where  A PGPredicate or NSString object which determines the conditions
 *                for which the rows are deleted. Cannot be nil.
 *
 *  @return Returns a PGQueryDelete object
 */
+(PGQueryDelete* )from:(id)source where:(id)where;


////////////////////////////////////////////////////////////////////////////////
// properties

/**
 *  Return the PGQuerySource for the DELETE statement. Can only be a simple
 *  table object, not a join
 */
@property (readonly) PGQuerySource* source;

/**
 *  The WHERE predicate
 */
@property (readonly) PGQueryPredicate* where;


@end

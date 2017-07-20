
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

 /**
  *  The PGConnection class represents a single connection to a remote
  *  PostgreSQL database, either via network or file-based socket. The 
  *  connection class provides methods to test connecting, connecting, 
  *  disconnecting, resetting and executing statements on the remote database.
  *  A delegate can be implemented which is called on state changes, connection
  *  and errors.
  */

////////////////////////////////////////////////////////////////////////////////
// constants

/**
 *  The default port number used for making PostgreSQL connections
 */
extern NSUInteger PGClientDefaultPort;

/**
 *  The maximum supported port value which is supported
 */
extern NSUInteger PGClientMaximumPort;

/**
 *  The domain string used when returning NSError objects
 */
extern NSString* PGClientErrorDomain;

/**
 *  The default client character encoding to use (UTF-8)
 */
extern NSString* PGConnectionDefaultEncoding;

////////////////////////////////////////////////////////////////////////////////
// forward declarations

@protocol PGConnectionDelegate;

////////////////////////////////////////////////////////////////////////////////
// internal state

/**
 These values are used internally to determine the current state of the 
 communication with the remote server. PGConnectionStateNone indicates
 that the communication is idle, other states indicate other potential
 states, so that the connection is busy.
 */
typedef enum {
	PGConnectionStateNone = 0,
	PGConnectionStateConnect = 100,
	PGConnectionStateReset = 101,
	PGConnectionStateQuery = 102,
	PGConnectionStateCancel = 103
} PGConnectionState;

/**
 The tuple format determines the format of data which is passed backwards
 and forwards between the server.
 */
typedef enum {
	PGClientTupleFormatText = 0,
	PGClientTupleFormatBinary = 1
} PGClientTupleFormat;

////////////////////////////////////////////////////////////////////////////////
// PGConnection interface

@interface PGConnection : NSObject {
	void* _connection;
	void* _cancel;
	void* _callback;
	CFSocketRef _socket;
	CFRunLoopSourceRef _runloopsource;
	NSUInteger _timeout;
	PGConnectionState _state;
	NSDictionary* _parameters;
	PGClientTupleFormat _tupleFormat;
}

////////////////////////////////////////////////////////////////////////////////
// static methods

/**
 *  Returns an array of URL schemes that can be used to connect to the remote
 *  server
 *
 *  @return An array of valid URL schemes
 */
+(NSArray* )allURLSchemes;

/**
 *  Returns the default URL scheme which can be used to connect to the remote
 *  server
 *
 *  @return The name of the default URL scheme
 */
+(NSString* )defaultURLScheme;

////////////////////////////////////////////////////////////////////////////////
// properties

/**
 *  The currently set delegate
 */
@property (weak, nonatomic) id<PGConnectionDelegate> delegate;

/**
 *  The current database connection status
 */
@property (readonly) PGConnectionStatus status;

/**
 *  Communication state with the remote server
 */
@property (assign) PGConnectionState state;

/**
 *  Connection timeout in seconds
 */
@property NSUInteger timeout;

/**
 *  Format of data which is passed between client and server, defaults to Text
 */
@property PGClientTupleFormat tupleFormat;

/**
 *  Tag for the connection object. You can use this in order to refer to the
 *  connection by unique tag number, when implementing a pool of connections
 */
@property NSInteger tag;

/**
 *  The currently connected user, or nil if a connection has not yet been made
 */
@property (readonly) NSString* user;

/**
 *  The currently connected database, or nil if no database has been selected
 */
@property (readonly) NSString* database;

/**
 *  The hostname of the current connection, or nil if no connection is made,
 *  or if the connection is through a file-based socket.
 */
@property (readonly) NSString* host;

/**
 *  The current server process ID
 */
@property (readonly) int serverProcessID;

/**
 *  Dictionary of various parameters hashed against PGConnectionParameterKeys
 */
@property (readonly) NSDictionary* parameters;

////////////////////////////////////////////////////////////////////////////////
// string quoting and transformation

-(NSString* )quoteIdentifier:(NSString* )string;
-(NSString* )quoteString:(NSString* )string;
-(NSString* )encryptedPassword:(NSString* )password role:(NSString* )roleName;

@end

////////////////////////////////////////////////////////////////////////////////

@interface PGConnection (Connect)

/**
 *  Connect to a database (as specififed by the URL) without blocking. The method
 *  returns immediately, on initiation of the connection. Once the connection 
 *  process is completed (either to successful or unsuccessful
 *  completion, the callback block is run. The error condition is set to nil on
 *  successful connection, or to an error condition on failure.
 *
 *  @param url      The specification of the database that should be connected to
 *  @param callback The callback which is called on conclusion of the connection
 *                  process. The error will be set when the connection fails, or
 *                  else the error is set to nil. A boolean flag indicates if the
 *                  password was used to connect to the remote server.
 */
-(void)connectWithURL:(NSURL* )url whenDone:(void(^)(BOOL usedPassword,NSError* error)) callback;

/**
 *  Connect to a database (as specififed by the URL). The method
 *  returns once the connection process is completed (either to successful or 
 *  unsuccessful completion. The error condition is set to nil on successful 
 *  connection, or to an error condition on failure. The password parameter can
 *  be used to determine if the password was used as part of the connection
 *  process.
 *
 *  @param url          The specification of the database that should be connected to
 *  @param usedPassword A pointer to a BOOL value, or nil. The BOOL value is set
 *                      to YES if the password was used as part of the connection
 *                      process. Use the error code to determine if the password was
 *                      rejected.
 *  @param error        A pointer to an error object, or nil. The error is set if
 *                      the connection was unsuccessful, or else the error object
 *                      pointer is nil.
 *
 *  @return Returns YES if the connection process was successful
 */
-(BOOL)connectWithURL:(NSURL* )url usedPassword:(BOOL* )usedPassword error:(NSError** )error;

@end

////////////////////////////////////////////////////////////////////////////////

@interface PGConnection (Disconnect)

/**
 *  Disconnect from the remote connection. This happens in the foreground so
 *  blocks until the disconnection has occurred.
 */
-(void)disconnect;

@end

////////////////////////////////////////////////////////////////////////////////

@interface PGConnection (Cancel)

/**
 *  Cancel an on-going query on the server asyncronously. This method will
 *  return immediately, and the callback block is executed when the cancel
 *  has completed. When there is no operation to cancel, the success condition
 *  is returned (where the error parameter is set to nil)
 *
 *  @param callback The callback which is called on conclusion of the cancel
 *                  process. The error will be set when the operation fails, or
 *                  else the error is set to nil.
 */
-(void)cancelWhenDone:(void(^)(NSError* error)) callback;

@end

////////////////////////////////////////////////////////////////////////////////

@interface PGConnection (Execute)

/**
 *  This method execute a statement on the server asyncronously, executing the
 *  callback block on completion. The callback receives a PGResult object on
 *  successful completion, or an error object with the details of the error
 *  otherwise. The method returns immediately, and the cancel method can be
 *  subsequently called to stop the execution of the statement, if necessary.
 *
 *  @param query    Either an NSString or PGQuery object
 *  @param callback The callback which is called on completion of the execution
 */
-(void)execute:(id)query whenDone:(void(^)(PGResult* result,NSError* error)) callback;

/**
 *  This method execute a statement on the server syncronously, then returns
 *  the PGResult object on completion, or nil if there was an issue executing
 *  the query. On error, an error object is returned which contains details
 *  of the error. You can cancel the query on a separate thread as necessary.
 *
 *  @param query Either an NSString or PGQuery object
 *  @param error A pointer to an error object to be returned on error
 *
 *  @return The RGResult object containing results of the query
 */
-(PGResult* )execute:(id)query error:(NSError** )error;


/**
 *  The method executes a transaction block on the server asyncronously, and for
 *  each query that is executed, will call a block of code. On error, the block
 *  is cancelled and rollback is done. On success, a commit statement is sent to
 *  the server. The callback is made for every query, setting the result of the
 *  query and whether this is the last query to have been performed. If an error
 *  occurred, the error is passed.
 *
 *  @param transaction The PGTransaction object which contains the queries to be
 *                     executed.
 *  @param callback    The callback which is made after each statement is executed.
 *                     If a query error occurs, rollback is performed before the
 *                     callback is made.
 */
-(void)queue:(PGTransaction* )transaction whenQueryDone:(void(^)(PGResult* result,BOOL isLastQuery,NSError* error)) callback;

@end

////////////////////////////////////////////////////////////////////////////////

@interface PGConnection (Notifications)

/**
 *  This method indicates that the delegate should start to receive notification
 *  messages from the server. In order to receive the notifications, the
 *  delegate should implement the connection:notificationOnChannel:payload:
 *  method.
 *
 *  @param channelName The name of the channel to listen to notifications
 *
 *  @return Returns YES if the operation was successful.
 */
-(BOOL)addNotificationObserver:(NSString* )channelName;

/**
 *  This method indicates that the delegate should stop listening for
 *  notifications from the server. 
 *
 *  @param channelName The name of the channel to stop listening for 
 *                     notifications
 *
 *  @return Returns YES if the operation was successful.
 */
-(BOOL)removeNotificationObserver:(NSString* )channelName;

@end

////////////////////////////////////////////////////////////////////////////////

@interface PGConnection (Ping)

/**
 *  "Ping" a remote database to determine if a connect can be initiated. 
 *  Note that this method doesn't check credentials, only that a connection 
 *  could be initiated. For example, no attempt to made to check the username, 
 *  password or database parameters. It is possible to use this method regardless
 *  of the current connection state.
 *
 *  The method returns immediately and the callback block is executed when the
 *  operation completes. On successful completion, the error parameter is nil,
 *  which indicates that the remote database server can be reached and a connection
 *  should be attempted. On unsuccessful completion, the error message contains
 *  further details of the error.
 *
 *  @param url      The specification of the database that should be pinged
 *  @param callback The callback which is called on conclusion of the ping
 *                  process. The error will be set when the connection fails, or
 *                  else the error is set to nil.
 */
-(void)pingWithURL:(NSURL* )url whenDone:(void(^)(NSError* error)) callback;

/**
 *  "Ping" a remote database to determine if a connection can be initiated.
 *  Note that this method doesn't check credentials, only that a connection 
 *  could be initiated. For example, no attempt to made to check the username, 
 *  password or database parameters. It is possible to use this method regardless
 *  of the current connection state.
 *
 *  The method returns after the ping is done, therefore blocking the runloop. 
 *  On unsuccessful completion, the error message contains further details of 
 *  the error.
 *
 *  @param url   The specification of the database that should be pinged
 *  @param error The error details returned on performing the ping, if NO
 *               is returned by the function.
 *
 *  @return Returns YES on successful completion, or returns NO if the ping
 *          could not be performed.
 */
-(BOOL)pingWithURL:(NSURL* )url error:(NSError** )error;

@end

////////////////////////////////////////////////////////////////////////////////

@interface PGConnection (Reset)

/**
 *  Perform a connection reset (reconnect with all the same parameters) in the
 *  background. This method will return immediately and execute the callback
 *  block on completion. PLEASE NOTE: This method is not implemented yet, it
 *  is just a placeholder right now.
 *
 *  @param callback The callback which is called on conclusion of the reset
 *                  process. The error will be set when the reset fails, or
 *                  else the error is set to nil.
 */
-(void)resetWhenDone:(void(^)(NSError* error)) callback;

@end

////////////////////////////////////////////////////////////////////////////////
// PGConnectionDelegate protocol

@protocol PGConnectionDelegate <NSObject>

/**
 *  This delegate method is called just before a connect, ping or reset operation
 *  is performed, and gives the delegate the opportunity to modify the parameters
 *  or add a connection password before the connection is made.
 *
 *  @param connection The connection object which called the delegate
 *  @param dictionary The mutable dictionary containing the parameters to send to
 *                    the remote server. The parameter keys are listed in the
 *                    server documentation here: http://www.postgresql.org/docs/9.1/static/libpq-connect.html
 */
-(void)connection:(PGConnection* )connection willOpenWithParameters:(NSMutableDictionary* )dictionary;

/**
 *  This delegate method is called just before an SQL command is executed, and
 *  gives the delegate the opportunity to provide the name of a class which should
 *  be used for constructing a resultset object. The string must be the name of
 *  a class which is derived from the PGResult class. If returning nil then the
 *  class used is PGResult.
 *
 *  @param connection The connection object which called the delegate
 *  @param query      The NSString of the query which will be executed
 *
 *  @return The name of the class used for the result. If nil, the default
 *          PGResult class is used.
 */
-(NSString* )connection:(PGConnection* )connection willExecute:(NSString* )query;

/**
 *  This delegate method is called when any sort of error has occurred.
 *
 *  @param connection The connection object which called the delegate
 *  @param error      The error object which describes the error which occurred
 */
-(void)connection:(PGConnection* )connection error:(NSError* )error;

/**
 *  This delegate method is called when a notice (usually some sort of warning
 *  message) is sent from the server, usually in reaction to a command being
 *  executed.
 *
 *  @param connection The connection object which called the delegate
 *  @param notice     The notice text which was returned from the server
 */
-(void)connection:(PGConnection* )connection notice:(NSString* )notice;

/**
 *  This delegate method is called when the connection is listening for particular
 *  notifications, and a notification was triggered.
 *
 *  @param connection  The connection object which called the delegate
 *  @param channelName The name of the notification being listened for
 *  @param payload     The payload for the notification, or an empty string if
 *                     there is no payload.
 */
-(void)connection:(PGConnection* )connection notificationOnChannel:(NSString* )channelName payload:(NSString* )payload;

/**
 *  This delegate method is called when the status changes for the connection,
 *  usually if the connection is made, disconnected or if the connection becomes
 *  busy, for example during command execution. A description of the status change
 *  is also provided.
 *
 *  @param connection  The connection object which called the delegate
 *  @param status      The new status of the connection
 *  @param description A readable description for the status
 */
-(void)connection:(PGConnection* )connection statusChange:(PGConnectionStatus)status description:(NSString* )description;

@end



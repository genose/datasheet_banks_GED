
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

#import <Foundation/Foundation.h>

extern NSUInteger PGServerDefaultPort;
extern NSString* PGServerSuperuser;

@interface PGServer : NSObject {
	PGServerState _state;
	NSString* _hostname;
	NSUInteger _port;
	NSString* _dataPath;
	NSString* _socketPath;
	NSTask* _currentTask;
	NSTimer* _timer;
	int _pid;
	NSUInteger _startTime;
}

@property (weak, nonatomic) id<PGServerDelegate> delegate;
@property (readonly) NSString* version;
@property (readonly) PGServerState state;
@property (readonly) NSString* dataPath;
@property (readonly) NSString* socketPath;
@property (readonly) NSString* hostname;
@property (readonly) NSUInteger port;
@property (readonly) int pid;
@property (readonly) NSTimeInterval uptime;

/**
 *  Return a shared server object which will store data at the path provided by
 *  the path argument. The path does not need to exist. The state of the server
 *  will be set to PGServerStateUnknown.
 *
 *  @param thePath The path which will contain the PostgreSQL data and configuration files.
 *
 *  @return Returns a PGServer class instance, or nil if the instance could not be created.
 */
+(PGServer* )serverWithDataPath:(NSString* )thePath;

/**
 *  Start the shared server without any network interface binding, so that the 
 *  server is only accessible through the default socket port. Uses the default
 *  PostreSQL port in order to name the socket. If the server configuration and
 *  data files do not yet exist, they are initialized. The method returns
 *  immediately, and the current state of the server can be queried later to
 *  determine if the start actually occurred.
 *
 *  @return returns YES if the initiation of the server starting could occur, NO
 *    otherwise.
 */
-(BOOL)start;

/**
 *  Start the shared server without any network interface binding, so that the
 *  server is only accessible through the default socket port. Uses the
 *  port parameter provided in order to name the socket. If the 
 *  server configuration and data files do not yet exist, they are initialized.
 *  The method returns immediately, and the current state of the server can be 
 *  queried later to determine if the start actually occurred.
 *
 *  @param port Port number to use to name the socket. Required to be 1 or greater.
 *
 *  @return returns YES if the initiation of the server starting could occur, NO
 *    otherwise.
 */
-(BOOL)startWithPort:(NSUInteger)port; // uses custom port, no network

/**
 *  Start the shared server without any network interface binding, so that the
 *  server is only accessible through a socket port. Uses the
 *  port parameter provided in order to name the socket, and the
 *  socketPath parameter to determine the location of the socket. If the
 *  server configuration and data files do not yet exist, they are initialized.
 *  The method returns immediately, and the current state of the server can be
 *  queried later to determine if the start actually occurred.
 *
 *  @param port Port number to use to name the socket. Required to be 1 or greater.
 *
 *  @param socketPath Folder in which to place the socket, which must be writable.
 *
 *  @return returns YES if the initiation of the server starting could occur, NO
 *    otherwise.
 */
-(BOOL)startWithPort:(NSUInteger)port socketPath:(NSString* )socketPath; // uses custom port and socket path, no network

/**
 *  Start the shared server with a network interface binding, so that the
 *  server is accessible through the default socket port and through a network
 *  interface. Uses the provided port parameter to both bind the interface and
 *  in order to name the socket. If the hostname is set to @"*" then all network
 *  interfaces are bound to. If the server configuration and data files do not 
 *  yet exist, they are initialized. The method returns immediately, and the 
 *  current state of the server can be queried later to determine if the start 
 *  actually occurred.
 *
 *  @param hostname Network interface to bind to, or "*" for all interfaces.
 *  @param port     Network port to bind to, or 0 for the default port.
 *
 *  @return returns YES if the initiation of the server starting could occur, NO
 *    otherwise.
 */
-(BOOL)startWithNetworkBinding:(NSString* )hostname port:(NSUInteger)port;

/**
 *  Start the shared server with a network interface binding, so that the
 *  server is accessible through the default socket port and through a network
 *  interface. Uses the provided port parameter to both bind the interface and
 *  in order to name the socket. If the hostname is set to @"*" then all network
 *  interfaces are bound to. If the server configuration and data files do not 
 *  yet exist, they are initialized. The method returns immediately, and the 
 *  current state of the server can be queried later to determine if the start 
 *  actually occurred.
 *
 *  @param hostname Network interface to bind to, or "*" for all interfaces.
 *  @param port     Network port to bind to, or 0 for the default port.
 *  @param socketPath Folder in which to place the socket, which must be writable.
 *
 *  @return returns YES if the initiation of the server starting could occur, NO
 *    otherwise.
 */
-(BOOL)startWithNetworkBinding:(NSString* )hostname port:(NSUInteger)port socketPath:(NSString* )socketPath;

/**
 *  Initiates a stop of the PostgreSQL server. Returns immediately, but the
 *  progress in stopping the server can be monitored through the delegate. The
 *  stopping mechanism tries to cleanly shutdown the server in the first instance,
 *  but after some delay will force the termination whether or not any connections
 *  exist. It is up to the software developer to ensure connections are terminated
 *  cleanly to avoid data loss before calling this method.
 *
 *  @return Returns YES if the command could be initiated, else returns NO
 */
-(BOOL)stop;

/**
 *  Initiates a stop and start cycle of the server, in case of configuration
 *  change, for example. Returns immediately, but the
 *  progress in stopping the server can be monitored through the delegate. The
 *  stopping mechanism tries to cleanly shutdown the server in the first instance,
 *  but after some delay will force the termination whether or not any connections
 *  exist. It is up to the software developer to ensure connections are terminated
 *  cleanly to avoid data loss before calling this method.
 *
 *  @return Returns YES if the command could be initiated, else returns NO
 */
-(BOOL)restart;

/**
 *  Sends a SIGHUP (reload) signal to the server process, in case of configuration
 *  change, for example. Returns immediately, and there is no status update of the
 *  server in this case.
 *
 *  @return Returns YES if the command could be initiated, else returns NO
 */
-(BOOL)reload;

/**
 *  This method returns the data in the host access file, from which you can 
 *  create a PGHostAccessArray object.
 *
 *  @return Returns the data from the file in an NSData structure, or nil if the
 *          file could not be read
 */
-(NSData* )readHostAccessConfiguration;


/**
 *  This method returns the data in the settings configuration file, from which you can
 *  create a PGSettingsArray object.
 *
 *  @return Returns the data from the file in an NSData structure, or nil if the
 *          file could not be read
 */
-(NSData* )readSettingsConfiguration;

/**
 *  This method writes the host access file from an NSData object, which can be
 *  returned from a PGHostAccessArray object. If the data was changed compared to
 *  the existing file, the boolean needsReload flag is set to YES. An error can
 *  also be returned describing any error condition when NO is returned
 *
 *  @param data        The data from the PGHostAccessArray object
 *  @param needsReload A boolean flag is returned indicating if a reload should
 *                     be performed (ie, if the access was changed)
 *  @param error       A pointer to an error object, which is set on error
 *
 *  @return Returns YES on success or will return NO and set the error
 */
-(BOOL)writeHostAccessConfiguration:(NSData* )data needsReload:(BOOL* )needsReload error:(NSError** )error;

/**
 *  This method writes the settings file from an NSData object, which can be
 *  returned from a PGSettingsArray object. If the data was changed compared to
 *  the existing file, the boolean needsRestart flag is set to YES. An error can
 *  also be returned describing any error condition when NO is returned
 *
 *  @param data         The data from the PGHostAccessArray object
 *  @param needsRestart A boolean flag is returned indicating if a restart should
 *                      be performed
 *  @param error        A pointer to an error object, which is set on error
 *
 *  @return Returns YES on success or will return NO and set the error
 */
-(BOOL)writeSettingsConfiguration:(NSData* )data needsRestart:(BOOL* )needsRestart error:(NSError** )error;

/**
 *  Returns a string describing a particular server state.
 *
 *  @param theState The server state value
 *
 *  @return A string representing an English-language description of the state.
 */
+(NSString* )stateAsString:(PGServerState)theState;

@end


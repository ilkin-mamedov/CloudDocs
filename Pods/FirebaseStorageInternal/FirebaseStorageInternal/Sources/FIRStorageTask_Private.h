/*
 * Copyright 2017 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "FirebaseStorageInternal/Sources/Public/FirebaseStorageInternal/FIRStorageReference.h"
#import "FirebaseStorageInternal/Sources/Public/FirebaseStorageInternal/FIRStorageTaskSnapshot.h"

#import "FirebaseStorageInternal/Sources/FIRStorageConstants_Private.h"
#import "FirebaseStorageInternal/Sources/FIRStorageErrors.h"
#import "FirebaseStorageInternal/Sources/FIRStorageReference_Private.h"
#import "FirebaseStorageInternal/Sources/FIRStorageTaskSnapshot_Private.h"
#import "FirebaseStorageInternal/Sources/FIRStorageUtils.h"

#if SWIFT_PACKAGE
@import GTMSessionFetcherCore;
#else
#import <GTMSessionFetcher/GTMSessionFetcher.h>
#import <GTMSessionFetcher/GTMSessionFetcherService.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface FIRIMPLStorageTask ()

/**
 * State for the current task in progress.
 */
@property(atomic) FIRIMPLStorageTaskState state;

/**
 * FIRIMPLStorageMetadata for the task in progress, or nil if none present.
 */
@property(strong, nonatomic, nullable) FIRIMPLStorageMetadata *metadata;

/**
 * Error which occurred during task execution, or nil if no error occurred.
 */
@property(strong, nonatomic, nullable) NSError *error;

/**
 * NSProgress object which tracks the progress of an observable task.
 */
@property(strong, nonatomic) NSProgress *progress;

/**
 * Reference pointing to the location the task is being performed against.
 */
@property(strong, nonatomic) FIRIMPLStorageReference *reference;

/**
 * A serial queue for all storage operations.
 */
@property(nonatomic, readonly) dispatch_queue_t dispatchQueue;

@property(strong, readwrite, nonatomic, nonnull) FIRIMPLStorageTaskSnapshot *snapshot;

@property(readonly, copy, nonatomic) NSURLRequest *baseRequest;

@property(strong, atomic) GTMSessionFetcher *fetcher;

@property(readonly, nonatomic) GTMSessionFetcherService *fetcherService;

@property(readonly, copy) GTMSessionFetcherCompletionHandler fetcherCompletion;

- (instancetype)init NS_UNAVAILABLE;

/**
 * Creates a new FIRIMPLStorageTask initialized with a FIRIMPLStorageReference and
 * GTMSessionFetcherService.
 * @param reference A FIRIMPLStorageReference the task will be performed on.
 * @param service A GTMSessionFetcherService which provides the fetchers and configuration for
 * requests.
 * @param queue The shared queue to use for all Storage operations.
 * @return A new FIRIMPLStorageTask representing the current task.
 */
- (instancetype)initWithReference:(FIRIMPLStorageReference *)reference
                   fetcherService:(GTMSessionFetcherService *)service
                    dispatchQueue:(dispatch_queue_t)queue NS_DESIGNATED_INITIALIZER;

/** Dispatches a block on the shared Storage queue. */
- (void)dispatchAsync:(void (^)(void))block;

@end

NS_ASSUME_NONNULL_END

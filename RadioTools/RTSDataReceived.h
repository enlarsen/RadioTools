//
//  RTSDataReceived.h
//  RadioTools
//
//  Created by Erik Larsen on 12/16/13.
//  Copyright (c) 2013 Erik Larsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RTSDataReceived <NSObject>

@property (nonatomic, strong) dispatch_queue_t dataDispatchQueue;
- (void)dataReceived:(NSMutableData *)dataQueue;

@end

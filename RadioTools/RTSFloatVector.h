//
//  RTSFloatVector.h
//  RadioTools
//
//  Created by Erik Larsen on 12/10/13.
//  Copyright (c) 2013 Erik Larsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTSFloatVector : NSObject

@property (nonatomic, readonly) int sizeElements;
@property (nonatomic, readonly) int sizeBytes;
@property (nonatomic, readonly) float *vector;

- (id)initWithData:(float *)vector sizeElements:(NSUInteger)length;
- (id)initWithSizeElements:(NSUInteger)sizeElements;
- (void)writeData:(NSString *)filename;
@end

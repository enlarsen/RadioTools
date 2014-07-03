//
//  RTSFloatVector.m
//  RadioTools
//
//  Created by Erik Larsen on 12/10/13.
//  Copyright (c) 2013 Erik Larsen. All rights reserved.
//

#import "RTSFloatVector.h"

@interface RTSFloatVector()

@property (nonatomic) NSMutableData *vectorStorage;


@end


@implementation RTSFloatVector

- (id)init __attribute__((unavailable("init not available")));
{
    return nil;
}

- (id)initWithData:(float *)vector sizeElements:(NSUInteger)length
{
    if(self = [super init])
    {
        _vectorStorage = [[NSMutableData alloc] initWithBytes:vector
                                                length:length * sizeof(float)];
    }
    return self;
}

- (id)initWithSizeElements:(NSUInteger)sizeElements
{
    if(self = [super init])
    {
        _vectorStorage = [[NSMutableData alloc]
                          initWithLength:sizeElements * sizeof(float)];
    }
    return self;
}

#pragma mark - Properties

- (int)sizeElements
{
    return (int)_vectorStorage.length / sizeof(float);
}

- (int)sizeBytes
{
    return (int)_vectorStorage.length;
}

- (float *)vector
{
    return (float *)[_vectorStorage mutableBytes];
}

- (void)writeData:(NSString *)filename
{
    if(![[NSFileManager defaultManager] fileExistsAtPath:filename isDirectory:NO])
    {
        [[NSFileManager defaultManager] createFileAtPath:filename contents:nil attributes:nil];
    }

    NSFileHandle *outputHandle = [NSFileHandle fileHandleForWritingAtPath:filename];

    [outputHandle seekToEndOfFile];

    [outputHandle writeData:self.vectorStorage];
}

@end

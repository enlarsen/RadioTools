//
//  RTSRTLRadio.m
//  RadioTools
//
//  Created by Erik Larsen on 12/9/13.
//  Copyright (c) 2013 Erik Larsen. All rights reserved.
//
#include <sys/syscall.h>
#include <sys/kdebug.h>

#import "RTSRTLRadio.h"
#import "RTSDataReceived.h"
#import <rtl-sdr.h>

//const int bufferSize = (16 * 32 * 512);
const int bufferSize = 512 * 16;

@interface RTSRTLRadio()

@property (nonatomic) rtlsdr_dev_t *device;
@property (nonatomic) dispatch_queue_t rtlReaderQueue;
@property (nonatomic) dispatch_queue_t bufferLockQueue;
@property (nonatomic, strong) NSMutableData *USBBuffer;
@property (nonatomic, strong) id <RTSDataReceived> delegate;
@property (nonatomic, strong) NSMutableArray *freeBuffers;
@property (nonatomic) NSUInteger outputBufferSize;
@property (nonatomic, strong) NSMutableData *workingBuffer;
@property (nonatomic) BOOL run;

@end

@implementation RTSRTLRadio

// TODO: Fix to be unavailable
- (id)init
{
    return nil;
}

- (id)initWithDelegate:(id)delegate sampleRate:(NSUInteger)sampleRate
      outputBufferSize:(NSUInteger)outputBufferSize
{
    if(self = [super init])
    {
        _delegate = delegate;
        _outputBufferSize = outputBufferSize;

        int result = rtlsdr_open(&_device, 0);
        result = rtlsdr_set_center_freq(_device, 89896000); // 89.9 FM, Portland classical
        result = rtlsdr_set_tuner_gain_mode(_device, 0); // Autogain on
        result = rtlsdr_set_sample_rate(_device, (unsigned int)sampleRate);

        [self allocateBuffers];

    }
    return self;
}

- (void)allocateBuffers
{
    int buffersToAllocate = bufferSize / self.outputBufferSize + 1;
    NSLog(@"Allocating %d input buffers for radio.\n", buffersToAllocate);
    for(int i = 0; i < buffersToAllocate; i ++)
    {
        NSMutableData *buffer = [[NSMutableData alloc] initWithLength:self.outputBufferSize];
        // Not really necessary because at init no one else is accessing
        dispatch_sync(self.bufferLockQueue, ^{
            [self.freeBuffers addObject:buffer];
        });
    }
}

- (NSMutableData *)USBBuffer
{
    if(!_USBBuffer)
    {
        _USBBuffer = [[NSMutableData alloc] initWithLength:bufferSize];
    }
    return _USBBuffer;
}

- (dispatch_queue_t)bufferLockQueue
{
    if(!_bufferLockQueue)
    {
        _bufferLockQueue = dispatch_queue_create("com.enlarsen.bufferLockQueue", NULL);
    }
    return _bufferLockQueue;
}

- (dispatch_queue_t)rtlReaderQueue
{
    if(!_rtlReaderQueue)
    {
        _rtlReaderQueue = dispatch_queue_create("com.enlarsen.rtlReaderQueue", NULL);
    }
    return _rtlReaderQueue;
}

- (NSMutableData *)workingBuffer
{
    if(!_workingBuffer)
    {
        _workingBuffer = [[NSMutableData alloc] initWithLength:self.outputBufferSize];
    }
    return _workingBuffer;
}

- (NSMutableArray *)freeBuffers
{
    if(!_freeBuffers)
    {
        _freeBuffers = [[NSMutableArray alloc] init];

    }
    return _freeBuffers;
}


- (void)start
{
    self.run = YES;

    rtlsdr_reset_buffer(self.device);

    dispatch_async(self.rtlReaderQueue, ^{
        while(self.run)
        {
            int result, n;

            result = rtlsdr_read_sync(self.device, self.USBBuffer.mutableBytes,
                                      (int)self.USBBuffer.length, &n);


            // TODO: Needs better error handling than this:
            if(result < 0)
            {
                printf("Error in rtlsdr_read_sync: %d", result);
                rtlsdr_close(self.device);
                exit(1);
            }

            dispatch_async(self.delegate.dataDispatchQueue, ^{
                // TODO: necessary?
                if(self.delegate && [self.delegate respondsToSelector:@selector(dataReceived:)])
                {
                    [self.delegate dataReceived:self.USBBuffer];
                }
            });

//            [self fillBuffers];
        }
        rtlsdr_close(self.device);

    });

}

- (void)stop
{
    self.run = NO;

}

/////////////////////////////////////////

- (void)fillBuffers
{
    static NSUInteger sourceIndex = 0;
    static NSUInteger destinationIndex = 0;


    NSUInteger bufferSize = [self.USBBuffer length];

    // BUG: won't handle case where inputBuffer already has more bytes than are in buffer,
    // case where buffer is smaller than USBBuffer.
    while(bufferSize >= sourceIndex + self.outputBufferSize)
    {
        memcpy(&self.workingBuffer.mutableBytes[destinationIndex], &self.USBBuffer.bytes[sourceIndex],
               self.outputBufferSize - destinationIndex);

        sourceIndex += self.outputBufferSize;
        destinationIndex = 0;

        [self sendBufferToDelegate];

    }
    if(sourceIndex < bufferSize) // For buffers that don't contain enough data to fill the inputBuffer
    {
        NSUInteger bytesToCopy = MIN(self.USBBuffer.length - sourceIndex, self.outputBufferSize - destinationIndex);
        memcpy(&self.workingBuffer.mutableBytes[destinationIndex], &self.USBBuffer.bytes[sourceIndex],
               bytesToCopy);
        sourceIndex += bytesToCopy;
        destinationIndex += bytesToCopy;

        if(destinationIndex > self.outputBufferSize)
        {
            [self sendBufferToDelegate];
            destinationIndex = 0;
        }
    }
    else
    {
        sourceIndex = 0;
    }
}

- (void)sendBufferToDelegate
{
    __block NSMutableData *outputBuffer;

    // Grab a buffer from the free buffers so it can be handed off to the demodulationQueue
    dispatch_sync(self.bufferLockQueue, ^{
        if([self.freeBuffers count])
        {
            outputBuffer = (NSMutableData *)[self.freeBuffers objectAtIndex:0];
            [self.freeBuffers removeObjectAtIndex:0];
        }
        else
        {
            outputBuffer = [[NSMutableData alloc] initWithLength:self.outputBufferSize];
        }
    });

    memcpy(outputBuffer.mutableBytes, self.workingBuffer.bytes, self.workingBuffer.length);
    dispatch_async(self.delegate.dataDispatchQueue, ^{
        // TODO: necessary?
        if(self.delegate && [self.delegate respondsToSelector:@selector(dataReceived:)])
        {
            [self.delegate dataReceived:outputBuffer];
            dispatch_sync(self.bufferLockQueue, ^{
                [self.freeBuffers addObject:outputBuffer];
            });
        }
    });

}



@end

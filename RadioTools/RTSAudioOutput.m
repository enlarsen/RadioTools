//
//  RTSAudioOutput.m
//  RadioTools
//
//  Created by Erik Larsen on 12/9/13.
//  Copyright (c) 2013 Erik Larsen. All rights reserved.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

#include <sys/syscall.h>
#include <sys/kdebug.h>

#import "RTSAudioOutput.h"
#include <CoreServices/CoreServices.h>
#include <mach/mach.h>
#include <mach/mach_time.h>

// TODO: This needs to be done as a singleton.

const int audioBufferSize = 20000;


@interface RTSAudioOutput()

@property (nonatomic) AudioQueueRef audioQueue;
@property (nonatomic) dispatch_queue_t audioDispatchQueue;
@property (nonatomic) UInt32 rate;
@property (nonatomic, strong) NSPointerArray *freeBuffers;
@property (nonatomic) float *temporaryBuffer;
@property (nonatomic) int sizeElements;

@end

@implementation RTSAudioOutput

- (dispatch_queue_t)audioDispatchQueue
{
    if(!_audioDispatchQueue)
    {
        _audioDispatchQueue = dispatch_queue_create("com.enlarsen.audioQueue", NULL);
    }
    return _audioDispatchQueue;
}

- (void)setSizeElements:(int)sizeElements
{
    // Need to reallocate any buffers, here _temporaryBuffer;
    if(_sizeElements != sizeElements)
    {
        _sizeElements = sizeElements;
        _temporaryBuffer = nil;
    }
}

- (float *)temporaryBuffer
{
    if(!_temporaryBuffer)
    {
        _temporaryBuffer = malloc(_sizeElements * sizeof(float));
    }

    return _temporaryBuffer;
}

- (id)initWithSampleRate:(UInt32)rate
{
    if(self = [super init])
    {
        _rate = rate;
        [self setup];
    }

    return self;
}

- (void)setup
{
    self.freeBuffers = [[NSPointerArray alloc] initWithOptions:NSPointerFunctionsOpaqueMemory];

    OSStatus status;
    AudioStreamBasicDescription audioFormat = { 0 }; // Apple recommends initializing all to 0

    audioFormat.mSampleRate = self.rate;
    audioFormat.mFormatID = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mFramesPerPacket = 1;
    audioFormat.mChannelsPerFrame = 1;
    audioFormat.mBytesPerPacket = audioFormat.mBytesPerFrame = 2;
    audioFormat.mBitsPerChannel = 16;

    status = AudioQueueNewOutput(&audioFormat, audioCallback, (__bridge void *)(self), NULL,
                                 NULL, 0, &_audioQueue);


    for(int i = 0; i < 3; i++)
    {
        [self allocateAudioBuffer];
    }

}

- (void)allocateAudioBuffer
{
    static int bufferCount = 0;

    AudioQueueBufferRef bufferRef;
    /* OSStatus status = */ AudioQueueAllocateBuffer(self.audioQueue, audioBufferSize, &bufferRef);

    bufferRef->mAudioDataByteSize = audioBufferSize;

    // Manipulate freeBuffers only on the audioDispatchQueue.
    // TODO: Deadlocks, fix.
//    dispatch_sync(self.audioDispatchQueue, ^{
        [self.freeBuffers addPointer: bufferRef];
//    });
    bufferCount++;
//    NSLog(@"Allocated buffers: %i\n", bufferCount);
}

- (void)playSoundBuffer:(RTSFloatVector *)audio
{
    syscall(SYS_kdebug_trace, APPSDBG_CODE(DBG_MACH_CHUD, 1) | DBG_FUNC_START, 0, 0, 0, 0);
    static bool started = NO;
    static uint64_t startTime = 0ULL;


    self.sizeElements = audio.sizeElements;

//    uint64_t endTime = mach_absolute_time();
//    if(startTime != 0ULL)
//    {
//        [self logTime:startTime endTime:endTime];
//    }
//    startTime = endTime;

    dispatch_async(self.audioDispatchQueue, ^{
        if([self.freeBuffers count] == 0)
        {
            [self allocateAudioBuffer];
            // Wait until we've filled all of the initial buffers before starting
            if(started == NO)
            {
                OSStatus status = AudioQueueStart(self.audioQueue, NULL);
//                NSLog(@"Started sound buffer, status: %i\n", status);
                started = YES;
            }

        }
//        NSLog(@"Free buffers: %lu\n", (unsigned long)[self.freeBuffers count]);
        AudioQueueBufferRef soundBuffer = [self.freeBuffers pointerAtIndex:0];
        [self.freeBuffers removePointerAtIndex:0];

        float audioGain = 500.0f;
        vDSP_vsmul(audio.vector, 1, &audioGain, self.temporaryBuffer, 1, self.sizeElements);
        vDSP_vfix16(self.temporaryBuffer, 1, soundBuffer->mAudioData, 1, self.sizeElements);

        soundBuffer->mAudioDataByteSize = self.sizeElements * sizeof(short);

        OSStatus status = AudioQueueEnqueueBuffer(self.audioQueue, soundBuffer, 0, NULL);
//        NSLog(@"Wrote to sound buffer\n");

    });
    syscall(SYS_kdebug_trace, APPSDBG_CODE(DBG_MACH_CHUD, 1) | DBG_FUNC_END, 0, 0, 0, 0);
}

- (void)stop
{

}

- (void)logTime:(uint64_t)startTime endTime:(uint64_t)endTime
{
    uint64_t        elapsed;
    Nanoseconds     elapsedNano;

    elapsed = endTime - startTime;

    // Convert to nanoseconds.

    // Have to do some pointer fun because AbsoluteToNanoseconds
    // works in terms of UnsignedWide, which is a structure rather
    // than a proper 64-bit integer.


    elapsedNano = AbsoluteToNanoseconds( *(AbsoluteTime *) &elapsed );

    NSLog(@"%llu", *(uint64_t *)&elapsedNano);
}

#pragma mark - Callback function


void audioCallback(void *ptr, AudioQueueRef queue, AudioQueueBufferRef bufferRef)
{
    RTSAudioOutput *audioOutput = (__bridge RTSAudioOutput *)ptr;
    dispatch_async(audioOutput.audioDispatchQueue, ^{
        [audioOutput.freeBuffers addPointer: bufferRef];
    });
}

@end




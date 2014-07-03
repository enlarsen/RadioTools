//
//  RTSLowPassFilter.m
//  RadioTools
//
//  Created by Erik Larsen on 12/9/13.
//  Copyright (c) 2013 Erik Larsen. All rights reserved.
//

// TODO: Make the sample rate, transition width and cutoffs changeable
// at runtime.


// TODO: Compute filter time to zero in on pathalogical parameters

#include <sys/syscall.h>
#include <sys/kdebug.h>

#import "RTSFIRFilter.h"

@interface RTSFIRFilter()

@property (nonatomic) int sampleRate; // in Hz
@property (nonatomic) float *filterData;
@property (nonatomic) int gain;
@property (nonatomic) int transitionWidth;
// For use with high/lowpass filters
@property (nonatomic) int cutoffFrequency;
// For use with bandpass
@property (nonatomic) int cutoffLow;
@property (nonatomic) int cutoffHigh;
@property (nonatomic) double *window;


@end


@implementation RTSFIRFilter

- (id)initLowpassWithSampleRate:(int)sampleRate transitionWidth:(int)transitionWidth
                         cutoff:(int)cutoff
{
    if(self = [super init])
    {
        _sampleRate = sampleRate;
        _transitionWidth = transitionWidth;
        _cutoffFrequency = cutoff;
        [self computeLowpassFilter];
    }
    return self;
}

- (id)initHighpassWithSampleRate:(int)sampleRate transitionWidth:(int)transitionWidth
                          cutoff:(int)cutoff
{
    if(self = [super init])
    {
        _sampleRate = sampleRate;
        _transitionWidth = transitionWidth;
        _cutoffFrequency = cutoff;
        [self computeHighpassFilter];
    }
   return self;
}

- (id)initBandpassWithSampleRate:(int)sampleRate transitionWidth:(int)transitionWidth
                       cutoffLow:(int)cutoffLow cutoffHigh:(int)cutoffHigh
{
    if(self = [super init])
    {
        _sampleRate = sampleRate;
        _transitionWidth = transitionWidth;
        _cutoffLow = cutoffLow;
        _cutoffHigh = cutoffHigh;
        [self computeBandpassFilter];
    }
   return self;
}

#ifdef NEVER
- (RTSFloatVector *)filterFloat:(RTSFloatVector *)input
{
    if(self.filterData == nil)
    {
        NSLog(@"Filter not set up: computeFilter hasn't been called.\n");
        return nil;
    }

    int capacity = (input.sizeElements + self.numberTaps) * sizeof(float);
    static float *inputBuffer;
    static float *filterBuffer;
    static float *output;

    if(filterBuffer == NULL)
    {
        filterBuffer = malloc(self.numberTaps * sizeof(float));
        bzero(filterBuffer, self.numberTaps * sizeof(float));

        inputBuffer = malloc(capacity);
        output = malloc(capacity);
    }

    memcpy(inputBuffer, filterBuffer, self.numberTaps * sizeof(float));

    memcpy(&inputBuffer[self.numberTaps], input.vector, input.sizeBytes);

    vDSP_conv(inputBuffer, 1, self.filterData.vector, 1, output, 1,
              input.sizeElements, self.numberTaps);

    memcpy(filterBuffer, &inputBuffer[input.sizeElements],
           self.numberTaps * sizeof(float));

    RTSFloatVector *outputVector = [[RTSFloatVector alloc]
                                      initWithData:output
                                      sizeElements:input.sizeElements];
    return outputVector;

}
#endif

// Filter by overlap and add.
//

- (RTSComplexVector *)filterComplex:(RTSComplexVector *)input
{
    // Equivalences:
    //
    // y = real/imaginary (size: filter size + input buffer size)
    // x = input (size: input buffer size)
    // h = filterData (size: numberTaps)
    // ytemp = overlapAndAddBuffer

    if(self.filterData == nil)
    {
        NSLog(@"computeFilter hasn't been called.\n");
        return nil;
    }

    int capacity = input.sizeElements + self.numberTaps;
    static float *real;
    static float *imaginary;
    static DSPSplitComplex intermediate;
    static DSPSplitComplex output;
    static DSPSplitComplex overlapAndAddBuffer;
    DSPSplitComplex temp;

    if(overlapAndAddBuffer.realp == NULL)
    {
        overlapAndAddBuffer.realp = malloc(self.numberTaps * sizeof(float));
        overlapAndAddBuffer.imagp = malloc(self.numberTaps * sizeof(float));
        bzero(overlapAndAddBuffer.realp, self.numberTaps * sizeof(float));
        bzero(overlapAndAddBuffer.imagp, self.numberTaps * sizeof(float));

        real = malloc(capacity * sizeof(float));
        imaginary = malloc(capacity * sizeof(float));

        output.realp = malloc(input.sizeBytes);
        output.imagp = malloc(input.sizeBytes);

        intermediate.realp = malloc(capacity * sizeof(float));
        intermediate.imagp = malloc(capacity * sizeof(float));

    }

    memcpy(real, input.realp, input.sizeBytes);
    memcpy(imaginary, input.imagp, input.sizeBytes);
    memcpy(&real[input.sizeElements], overlapAndAddBuffer.realp,
           self.numberTaps * sizeof(float));
    memcpy(&imaginary[input.sizeElements], overlapAndAddBuffer.imagp,
           self.numberTaps * sizeof(float));

    vDSP_conv(real, 1, &self.filterData[self.numberTaps - 1], -1,
              intermediate.realp, 1, capacity, self.numberTaps);
    vDSP_conv(imaginary, 1, &self.filterData[self.numberTaps - 1], -1,
              intermediate.imagp, 1, capacity, self.numberTaps);
    memcpy(output.realp, intermediate.realp, input.sizeBytes);
    memcpy(output.imagp, intermediate.imagp, input.sizeBytes);
    vDSP_vadd(intermediate.realp, 1, overlapAndAddBuffer.realp, 1, output.realp,
              1, self.numberTaps);
    vDSP_vadd(intermediate.imagp, 1, overlapAndAddBuffer.imagp, 1, output.imagp,
              1, self.numberTaps);
    // Save last part of output buffer for use in the next call to the filter.
    temp.realp = &output.realp[input.sizeElements];
    temp.imagp = &output.imagp[input.sizeElements];
    // No real reason to do it this way instead of memcpy, but it's fun.
    vDSP_zvmov(&temp, 1, &overlapAndAddBuffer, 1, self.numberTaps);


    RTSComplexVector *outputVector = [[RTSComplexVector alloc]
                                      initWithSplitComplex:output
                                      sizeElements:input.sizeElements];
    return outputVector;
}

- (RTSFloatVector *)filterFloat:(RTSFloatVector *)input
{
    if(self.filterData == nil)
    {
        NSLog(@"computeFilter hasn't been called.\n");
        return nil;
    }

    int capacity = input.sizeElements + self.numberTaps;
    static float *buffer;
    static float *intermediate;
    static float *output;
    static float *overlapAndAddBuffer;

    if(overlapAndAddBuffer == NULL)
    {
        overlapAndAddBuffer = malloc(self.numberTaps * sizeof(float));
        bzero(overlapAndAddBuffer, self.numberTaps * sizeof(float));

        buffer = malloc(capacity * sizeof(float));

        output = malloc(input.sizeBytes);

        intermediate = malloc(capacity * sizeof(float));

    }

    memcpy(buffer, input.vector, input.sizeBytes);
    memcpy(&buffer[input.sizeElements], overlapAndAddBuffer,
           self.numberTaps * sizeof(float));

    vDSP_conv(buffer, 1, &self.filterData[self.numberTaps - 1], -1,
              intermediate, 1, capacity, self.numberTaps);
    memcpy(output, intermediate, input.sizeBytes);
    vDSP_vadd(intermediate, 1, overlapAndAddBuffer, 1, output, 1, self.numberTaps);
    // Save last part of output buffer for use in the next call to the filter.
    memcpy(overlapAndAddBuffer, &output[input.sizeElements], self.numberTaps);


    RTSFloatVector *outputVector = [[RTSFloatVector alloc]
                                      initWithData:output
                                      sizeElements:input.sizeElements];
    return outputVector;

}


- (void)computeLowpassFilter
{
    [self computeLowOrHighPassFilter:1];
}

- (void)computeHighpassFilter
{
    [self computeLowOrHighPassFilter:-1];
}

- (void)computeLowOrHighPassFilter:(NSInteger)s
{
    [self computeWindow];

    int M = (self.numberTaps - 1) / 2;
    double cuttoffRadiansSample = 2 * M_PI *
            self.cutoffFrequency / self.sampleRate; // radians/sample

    // Window the ideal/optimal sinc function
    for (int i = -M; i <= M; i++)
    {
        if (i == 0)
        {
            self.filterData[i + M] =
                (1 - s) / 2 + s * cuttoffRadiansSample / M_PI * self.window[i + M];
        }
        else
        {
            self.filterData[i + M] = s * sin(i * cuttoffRadiansSample) /
                (i * M_PI) * self.window[i + M];
        }
    }

    [self normalizeFilter];


}

- (void)computeBandpassFilter
{
    [self computeWindow];

    int M = (self.numberTaps - 1) / 2; // numberTaps is always odd
    double lowRadiansSample = 2 * M_PI * self.cutoffLow / self.sampleRate; // radians/sample
    double highRadiansSample = 2 * M_PI * self.cutoffHigh / self.sampleRate;

    // Window the ideal sinc function
    for (int i = -M; i <= M; i++)
    {
        if (i == 0)
        {
            self.filterData[i + M] =
                (highRadiansSample - lowRadiansSample) / M_PI * self.window[i + M];
        }
        else
        {
            self.filterData[i + M] = (sin(highRadiansSample * i) / (M_PI * i) -
                sin(lowRadiansSample * i) / (M_PI * i)) * self.window[i + M];
        }
    }


    [self normalizeFilter];

}

- (void)computeWindow
{
    // 2.41 is 53/22 (from gnuradio Hamming window compute_ntaps)
    self.numberTaps = 2.41 * self.sampleRate / self.transitionWidth;
    // TODO: warn about excessively big windows -> slow processing?
    self.numberTaps += (self.numberTaps % 2 == 0)? 1 : 0;

    self.filterData = malloc(self.numberTaps * sizeof(float));

    self.window = malloc(self.numberTaps * sizeof(double));

    vDSP_hamm_windowD(self.window, self.numberTaps, 0);
}


// Normalize the filter
- (void)normalizeFilter
{
    int M = (self.numberTaps - 1) / 2;
    double sum = self.filterData[M];

    // Only need to do half because it's symmetrical
    for (int i = 0; i < M; i++)
    {
        sum += 2 * self.filterData[i + M];
    }

    for (int i = 0; i < self.numberTaps; i++)
    {
        self.filterData[i] /= sum;
    }

}


@end

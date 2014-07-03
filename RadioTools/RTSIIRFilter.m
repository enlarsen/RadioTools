//
//  RTSIIRFilter.m
//  RadioTools
//
//  Created by Erik Larsen on 12/15/13.
//  Copyright (c) 2013 Erik Larsen. All rights reserved.
//

// References:
// http://www.musicdsp.org/files/Audio-EQ-Cookbook.txt
// http://objective-audio.jp/2008/02/biquad-filter.html
// http://stackoverflow.com/questions/10375359/iir-coefficients-for-peaking-eq-how-to-pass-them-to-vdsp-deq22
// https://www.assembla.com/code/sdrsharp/subversion/nodes/1172/trunk/Radio/FilterBuilder.cs
// https://github.com/bartolsthoorn/NVDSP/blob/master/NVDSP.mm


#import "RTSIIRFilter.h"

@interface RTSIIRFilter()

@property (nonatomic) float a0;
@property (nonatomic) float a1;
@property (nonatomic) float a2;
@property (nonatomic) float b0;
@property (nonatomic) float b1;
@property (nonatomic) float b2;
@property (nonatomic) float w0; // little omega subscript zero
@property (nonatomic) float f0;
@property (nonatomic) float Fs;
@property (nonatomic) float alpha;
@property (nonatomic) float *filterCoefficients;
@property (nonatomic) float *inputBufferReal;
@property (nonatomic) float *inputBufferImaginary;
@property (nonatomic) float *outputBufferReal;
@property (nonatomic) float *outputBufferImaginary;
@property (nonatomic) float savedInputReal0;
@property (nonatomic) float savedInputReal1;
@property (nonatomic) float savedOutputReal0;
@property (nonatomic) float savedOutputReal1;
@property (nonatomic) float savedInputImaginary0;
@property (nonatomic) float savedInputImaginary1;
@property (nonatomic) float savedOutputImaginary0;
@property (nonatomic) float savedOutputImaginary1;
@property (nonatomic) NSUInteger sizeElements;
@property (nonatomic) NSUInteger sizeBytes;
@property (nonatomic) RTSComplexVector *returnValueComplex;
@property (nonatomic) RTSFloatVector *returnValueFloat;

@end

@implementation RTSIIRFilter

#pragma mark - Properties

- (void)setSizeElements:(NSUInteger)sizeElements
{
    if(_sizeElements != sizeElements)
    {
        _inputBufferReal = nil;
        _outputBufferReal = nil;
        _inputBufferImaginary = nil;
        _outputBufferImaginary = nil;
        _savedInputReal0 = _savedInputReal1 = _savedOutputReal0 = _savedOutputReal1 = 0.0f;
        _savedInputImaginary0 = _savedInputImaginary1 = _savedOutputImaginary0 = _savedOutputImaginary1 = 0.0f;
        _sizeElements = sizeElements;
    }
}

- (NSUInteger)sizeBytes
{
    return self.sizeElements * sizeof(float);
}

- (RTSComplexVector *)returnValueComplex
{
    return nil; // TODO:
}

- (RTSFloatVector *)returnValueFloat
{
    return nil; // TODO
}

- (float *)inputBufferReal
{
    if(!_inputBufferReal)
    {
        // vDSP_deq22 requires the buffer to have two extra elements
        _inputBufferReal = malloc((self.sizeElements + 2) * sizeof(float));
    }
    return _inputBufferReal;
}

- (float *)outputBufferReal
{
    if(!_outputBufferReal)
    {
        // vDSP_deq22 requires the buffer to have two extra elements
        _outputBufferReal = malloc((self.sizeElements + 2) * sizeof(float));
    }
    return _outputBufferReal;
}

- (float *)inputBufferImaginary
{
    if(!_inputBufferImaginary)
    {
        // vDSP_deq22 requires the buffer to have two extra elements
        _inputBufferImaginary = malloc((self.sizeElements + 2) * sizeof(float));
    }
    return _inputBufferImaginary;
}

- (float *)outputBufferImaginary
{
    if(!_outputBufferImaginary)
    {
        // vDSP_deq22 requires the buffer to have two extra elements
        _outputBufferImaginary = malloc((self.sizeElements + 2) * sizeof(float));
    }
    return _outputBufferImaginary;
}

- (float *)filterCoefficients
{
    if(!_filterCoefficients)
    {
        _filterCoefficients = malloc(5 * sizeof(float));
    }
    return _filterCoefficients;
}

- (id)initLowpassWithSampleRate:(NSUInteger)sampleRate cutoff:(NSUInteger)cutoff
                              Q:(NSUInteger)Q
{

    self.Fs = sampleRate;
    self.f0 = cutoff;
    self.w0 = 2 * M_PI * self.f0 / self.Fs; // radians / sample
    self.alpha = sin(self.w0) / 2; // ignore Q for now

    self.b0 = (1 - cos(self.w0))/2;
    self.b1 = 1 - cos(self.w0);
    self.b2 = self.b0;
    self.a0 = 1 + self.alpha;
    self.a1 = -2 * cos(self.w0);
    self.a2 = 1 - self.alpha;

    [self scaleByA0];
    return self;
}

- (id)initHighpassWithSampleRate:(NSUInteger)sampleRate cutoff:(NSUInteger)cutoff
                               Q:(NSUInteger)Q
{
    self.Fs = sampleRate;
    self.f0 = cutoff;
    self.w0 = 2 * M_PI * self.f0 / self.Fs;

    self.alpha = sin(self.w0) / 2;

    self.b0 = (1 + cos(self.w0))/2;
    self.b1 = -(1 + cos(self.w0));
    self.b2 = self.b0;
    self.a0 = 1 + self.alpha;
    self.a1 = -2 * cos(self.w0);
    self.a2 = 1 - self.alpha;

    [self scaleByA0];
    return self;

}

- (id)initBandpassWithSampleRate:(NSUInteger)sampleRate cutoffLow:(NSUInteger)cutoffLow
                      cutoffHigh:(NSUInteger)cutoffHigh
{
    self.Fs = sampleRate;
    self.f0 = (cutoffHigh - cutoffLow) / 2;
    self.w0 = 2 * M_PI * self.f0 / self.Fs;

    // Q = fc/(fh-fl) and fc=fl + (fh-fl)/2 => Q = fl / (fh - fl) + 0.5
    float Q = cutoffLow / (cutoffHigh - cutoffLow) + 0.5f;

    self.alpha = sin(self.w0) / 2;

    self.b0 = (1 - cos(self.w0))/2;
    self.b1 = 0;
    self.b2 = self.b0;
    self.a0 = 1 + self.alpha;
    self.a1 = -2 * cos(self.w0);
    self.a2 = 1 - self.alpha;

    [self scaleByA0];
    return self;

}

- (void)scaleByA0
{
    self.b0 /= self.a0;
    self.b1 /= self.a0;
    self.b2 /= self.a0;
    self.a1 /= self.a0;
    self.a2 /= self.a0;
}


- (void)setupFilterCoefficientArray
{
    // Not documented by Apple, but according to the Internet, these
    // are: [b0/a0, b1/a0, b2/a0, a1/a0, a2/a0]. Not sure if they
    // need to be reset with every call of vDSP_deq22.

    self.filterCoefficients[0] = self.b0;
    self.filterCoefficients[1] = self.b1;
    self.filterCoefficients[2] = self.b2;
    self.filterCoefficients[3] = self.a1;
    self.filterCoefficients[4] = self.a2;
}

- (void)saveCurrentValues
{
    self.savedInputReal0 = self.inputBufferReal[self.sizeElements];
    self.savedInputReal1 = self.inputBufferReal[self.sizeElements + 1];
    self.savedOutputReal0 = self.outputBufferReal[self.sizeElements];
    self.savedOutputReal1 = self.outputBufferReal[self.sizeElements + 1];

    self.savedInputImaginary0 = self.inputBufferImaginary[self.sizeElements];
    self.savedInputImaginary1 = self.inputBufferImaginary[self.sizeElements + 1];
    self.savedOutputImaginary0 = self.outputBufferImaginary[self.sizeElements];
    self.savedOutputImaginary1 = self.outputBufferImaginary[self.sizeElements + 1];
}

- (void)restorePreviousValues
{
    self.inputBufferReal[0] = self.savedInputReal0;
    self.inputBufferReal[1] = self.savedInputReal1;
    self.outputBufferReal[0] = self.savedOutputReal0;
    self.outputBufferReal[1] = self.savedOutputReal1;

    self.inputBufferImaginary[0] = self.savedInputImaginary0;
    self.inputBufferImaginary[1] = self.savedInputImaginary1;
    self.outputBufferImaginary[0] = self.savedOutputImaginary0;
    self.outputBufferImaginary[1] = self.savedOutputImaginary1;
}


- (RTSComplexVector *)filterComplex:(RTSComplexVector *)input
{
    self.sizeElements = input.sizeElements;
    [self restorePreviousValues];
    [self setupFilterCoefficientArray];

    memcpy(&self.inputBufferReal[2], input.realp, (self.sizeElements + 2) * sizeof(float));
    memcpy(&self.inputBufferImaginary[2], input.imagp, (self.sizeElements + 2) *sizeof(float));

    vDSP_deq22(self.inputBufferReal, 1, self.filterCoefficients,
               self.outputBufferReal, 1, self.sizeElements);
    vDSP_deq22(self.outputBufferImaginary, 1, self.filterCoefficients,
               self.outputBufferImaginary, 1, self.sizeElements);

    [self saveCurrentValues];

    memcpy(self.returnValueComplex.realp, self.outputBufferReal, self.sizeBytes);
    memcpy(self.returnValueComplex.imagp, self.outputBufferImaginary, self.sizeBytes);

    return self.returnValueComplex;

}

- (RTSFloatVector *)filterFloat:(RTSFloatVector *)input
{
    self.sizeElements = input.sizeElements;
    [self restorePreviousValues];
    [self setupFilterCoefficientArray];

    memcpy(&self.inputBufferReal[2], input.vector, (self.sizeElements + 2) * sizeof(float));

    vDSP_deq22(self.inputBufferReal, 1, self.filterCoefficients,
               self.outputBufferReal, 1, self.sizeElements);

    [self saveCurrentValues];

    memcpy(self.returnValueFloat.vector, self.outputBufferReal, self.sizeBytes);

    return self.returnValueFloat;
}

@end

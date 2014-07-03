# Radio Tools

Objective C library for using the RTL SDR radio dongles. Currently demos implementing
an FM radio that is tuned to 89.9 MHz Portland Classical (seel RTSRTLRadio.m).

The IIR filter isn't complete yet, and more work needs to be done to receive stereo
FM. Includes code to demodulate FM, FIR and IIR filters, vector (complex and real)
arithmetic and storage), and audio generation.

Uses Apple's vDSP library extensively.

Sample usage for FM (single channel) uses a dataReceived delegate that the library
calls whenever a data buffer has arrived from the RTL dongle:

```objective-c
- (void)setup
{
    self.conditioner = [[RTSInputConditioner alloc] init];
    self.firstDecimator = [[RTSDecimator alloc] initWithFactor:4];
    self.demodulator = [[RTSFMDemodulator alloc] init];
    self.finalDecimator = [[RTSDecimator alloc] initWithFactor:8];
    self.audioOutput = [[RTSAudioOutput alloc] initWithSampleRate:32000];
}

- (void)start
{
    [self.radio start];
}

-(void)dataReceived:(NSMutableData *)demodBuffer
{
    RTSComplexVector *conditioned = [self.conditioner conditionInput:demodBuffer];
    RTSComplexVector *firstDecimated = [self.firstDecimator decimateComplex:conditioned];
    RTSFloatVector *demodulated = [self.demodulator demodulate:firstDecimated];
    RTSFloatVector *finalDecimated = [self.finalDecimator decimateFloat:demodulated];

    [self.audioOutput playSoundBuffer:finalDecimated];
}
```
//
//  RTSManchesterDecoder.m
//  RadioTools
//
//  Created by Erik Larsen on 12/18/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
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


#import "RTSManchesterDecoder.h"

@interface RTSManchesterDecoder()

@property (nonatomic) NSUInteger sample_counter;
@property (nonatomic) NSUInteger short_limit;
@property (nonatomic) NSUInteger start_c;
@property (nonatomic) NSUInteger level_limit;
@property (nonatomic) NSUInteger pulse_count;
@property (nonatomic) NSUInteger reset_limit;
@property (nonatomic, weak) id<RTSDataReceived> dataReceivedDelegate;

@property (nonatomic, strong) NSMutableData *outputData;
@property (nonatomic) NSUInteger sizeElements;
@property (nonatomic) NSUInteger sizeBytes;


@end

@implementation RTSManchesterDecoder


// Need sample rate and amplitude floor (aka level_limit)

- (instancetype)initWithSampleRate:(float)sampleRate amplitudeFloor:(float)amplitudeFloor
{
    self = [super init];
    if(self)
    {
        _level_limit = amplitudeFloor;
        
    }
    return self;
}

#pragma mark - properties

- (NSMutableData *)outputData
{
    if(!_outputData)
    {
        _outputData = [[NSMutableData alloc] initWithLength:self.sizeElements];
    }
    return _outputData;
}

- (void)setSizeElements:(NSUInteger)sizeElements;
{
    if(_sizeElements != sizeElements)
    {
        _sizeElements = sizeElements;
        _outputData = nil;
    }
}

- (NSUInteger)sizeBytes // Same as elements because it's a byte
{
    return self.sizeElements;
}


/*

 p->sample_counter = count since last data bit recorded
 p->short_limit = # of samples in a short pulse
 p->start_c = number of bits received
 demod->level_limit = amplitude before considered a logical 1
 p->pulse_count = either 1 or 0
 p->reset_limit
 p->callback
 len = number of samples (here int16)


 */

- (void)decode:(RTSFloatVector *)input
{
    if (self.sample_counter == 0)
    {
        self.sample_counter = self.short_limit * 2;
    }

    for (NSUInteger i = 0; i < input.sizeElements; i++)
    {
        if (self.start_c)
        {
            /* For this decode type, sample counter is count since last data bit recorded */
            self.sample_counter++;
        }
         /* Pulse start (rising edge) */
        if (!self.pulse_count && ([input vector][i] > self.level_limit))
        {
            self.pulse_count = 1;

            if (self.sample_counter  > (self.short_limit + (self.short_limit >> 1)))
            {
                /* Last bit was recorded more than short_limit*1.5 samples ago */
                /* so this pulse start must be a data edge (rising data edge means bit = 0) */
                [self addBit:0];
                self.sample_counter = 1;
                self.start_c++; // start_c counts number of bits received
            }
        }
        /* Pulse end (falling edge) */
        if (self.pulse_count && ([input vector][i] <= self.level_limit))
        {
            if (self.sample_counter > (self.short_limit + (self.short_limit >> 1)))
            {
                /* Last bit was recorded more than "short_limit*1.5" samples ago */
                /* so this pulse end is a data edge (falling data edge means bit = 1) */
                [self addBit:1];
                self.sample_counter = 1;
                self.start_c++;
            }
            self.pulse_count = 0;
        }

        if (self.sample_counter > self.reset_limit)
        {
            //fprintf(stderr, "manchester_decode number of bits received=%d\n",p->start_c);
            if (self.dataReceivedDelegate)
            {
                [self.dataReceivedDelegate dataReceived:self.outputData];
            }
//            else
//            {
//                demod_print_bits_packet(p);
//            }
            [self resetDataBuffer];
            self.sample_counter = self.short_limit * 2;
            self.start_c = 0;
        }
    }

}

- (void)addBit:(NSUInteger)bit
{

}

- (void)resetDataBuffer
{

}

//void manchester_decode(struct dm_state *demod,
//                       struct protocol_state* p,
//                       int16_t *buf,
//                       uint32_t len)
//{
//}



@end

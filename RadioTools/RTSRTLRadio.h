//
//  RTSRTLRadio.h
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

#import <Foundation/Foundation.h>

@interface RTSRTLRadio : NSObject

@property (nonatomic) NSUInteger sampleRate;

- (instancetype)initWithDelegate:(id)delegate
             frequency:(UInt32)frequency
            sampleRate:(NSUInteger)sampleRate
      outputBufferSize:(NSUInteger)outputBufferSize NS_DESIGNATED_INITIALIZER;
- (void)start;
- (void)stop;
- (void)tuneToFrequency:(UInt32)frequency;

@end

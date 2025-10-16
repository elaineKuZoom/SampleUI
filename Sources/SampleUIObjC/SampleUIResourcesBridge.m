//
//  SampleUIResourcesBridge.m
//  SampleUI
//
//  Created by Elaine Ku on 10/15/25.
//

#import "SampleUIResourcesBridge.h"

static NSBundle *_sampleUIBundle = nil;

void SampleUISetResourcesBundle(NSBundle *bundle) {
    _sampleUIBundle = bundle;
}

NSBundle *SampleUIResourcesBundle(void) {
    return _sampleUIBundle ?: [NSBundle mainBundle];
}

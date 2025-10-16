//
//  Header.h
//  SampleUI
//
//  Created by Elaine Ku on 10/15/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Store the package bundle so Obj-C code can use it.
FOUNDATION_EXPORT void SampleUISetResourcesBundle(NSBundle *bundle);

/// Retrieve the package bundle (returns mainBundle if not set).
FOUNDATION_EXPORT NSBundle *SampleUIResourcesBundle(void);

NS_ASSUME_NONNULL_END

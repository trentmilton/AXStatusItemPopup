//
//  StatusItemPopup.h
//  StatusItemPopup
//
//  Created by Alexander Schuch on 06/03/13.
//  Copyright (c) 2013 Alexander Schuch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "INPopoverController.h"

#define kMenuItemShownNotification @"kMenuItemShownNotification"

@protocol AXStatusItemPopupDelegate <NSObject>

@optional

- (BOOL) statusItemPopupShouldClose;

@end

@interface AXStatusItemPopup : NSView <INPopoverControllerDelegate>

// properties
@property(assign, nonatomic, getter=isActive) BOOL active;
@property(assign, nonatomic) BOOL animated;
@property(strong, nonatomic) NSImage *image;
@property(strong, nonatomic) NSImage *alternateImage;
@property(strong, nonatomic) NSStatusItem *statusItem;
@property(nonatomic, strong) id <AXStatusItemPopupDelegate> statusItemPopupDelegate;

// init
- (id)initWithViewController:(NSViewController *)controller;
- (id)initWithViewController:(NSViewController *)controller image:(NSImage *)image;
- (id)initWithViewController:(NSViewController *)controller image:(NSImage *)image alternateImage:(NSImage *)alternateImage;

// show / hide popover
- (void)showPopover;
- (void)showPopoverAnimated:(BOOL)animated;
- (void)hidePopover;

@end

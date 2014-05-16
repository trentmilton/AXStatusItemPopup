//
//  StatusItemPopup.m
//  StatusItemPopup
//
//  Created by Alexander Schuch on 06/03/13.
//  Copyright (c) 2013 Alexander Schuch. All rights reserved.
//

#import "AXStatusItemPopup.h"
#import "INPopoverWindow.h"
#import "INPopoverController.h"

#define kMinViewWidth 22

@implementation AXStatusItemPopup {
    NSViewController *_viewController;
    BOOL _active;
    NSImageView *_imageView;
    NSStatusItem *_statusItem;
    INPopoverController *_popover;
    id _popoverTransiencyMonitor;
}

- (id) initWithViewController:(NSViewController *)controller
{
    return [self initWithViewController:controller image:nil];
}

- (id) initWithViewController:(NSViewController *)controller image:(NSImage *)image
{
    return [self initWithViewController:controller image:image alternateImage:nil];
}

- (id) initWithViewController:(NSViewController *)controller image:(NSImage *)image alternateImage:(NSImage *)alternateImage
{
    CGFloat height = [NSStatusBar systemStatusBar].thickness;
    
    self = [super initWithFrame:NSMakeRect(0, 0, kMinViewWidth, height)];
    if (self) {
        _viewController = controller;
        
        self.image = image;
        self.alternateImage = alternateImage;
        
        _imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, kMinViewWidth, height)];
        [self addSubview:_imageView];
        
        self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        self.statusItem.view = self;
        
        self.active = NO;
        self.animated = YES;
        
        _popover = [[INPopoverController alloc] init];
        _popover.animationType = INPopoverAnimationTypeFadeIn;
        _popover.contentViewController = _viewController;
        _popover.animates = YES;
        _popover.color = kEKFColourGrey1;
        _popover.borderColor = kEKFColourGrey1;
        _popover.delegate = self;
        
    }
    return self;
}

#pragma mark - Drawing

- (void) drawRect:(NSRect)dirtyRect {
    // set view background color
    if (self.active) {
        [[NSColor selectedMenuItemColor] setFill];
    } else {
        [[NSColor clearColor] setFill];
    }
    NSRectFill(dirtyRect);
    
    // set image
    NSImage *image = (self.active ? self.alternateImage : self.image);
    _imageView.image = image;
}

#pragma mark - Mouse Actions

- (void) mouseDown:(NSEvent *)theEvent {
    if (_popover.popoverIsVisible) {
        [self hidePopover];
    } else {
        [self showPopover];
    }
}

#pragma mark - Setter

- (void) setActive:(BOOL)active {
    _active = active;
    [self setNeedsDisplay:YES];
}

- (void) setImage:(NSImage *)image
{
    _image = image;
    [self updateViewFrame];
}

- (void) setAlternateImage:(NSImage *)image
{
    _alternateImage = image;
    if (!image && self.image) {
        _alternateImage = self.image;
    }
    [self updateViewFrame];
}

#pragma mark - Helper

- (void) updateViewFrame {
    CGFloat width = MAX(MAX(kMinViewWidth, self.alternateImage.size.width), self.image.size.width);
    CGFloat height = [NSStatusBar systemStatusBar].thickness;
    
    NSRect frame = NSMakeRect(0, 0, width, height);
    self.frame = frame;
    _imageView.frame = frame;
    
    [self setNeedsDisplay:YES];
}

#pragma mark - Show / Hide Popover

- (void)showPopover {
    [self showPopoverAnimated:self.animated];
}

- (void)showPopoverAnimated:(BOOL)animated {
    self.active = YES;
    
    if (!_popover.popoverIsVisible) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMenuItemShownNotification object:nil userInfo:nil];
        
        _popover.animates = animated;
        [_popover presentPopoverFromRect:self.frame inView:self preferredArrowDirection:INPopoverArrowDirectionUp anchorsToPositionView:YES];
        _popoverTransiencyMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask|NSRightMouseDownMask handler:^(NSEvent* event) {
            [self hidePopover];
        }];
    }
}

- (void) hidePopover {
    self.active = NO;
    
    if (_popover && _popover.popoverIsVisible) {
        [_popover.popoverWindow close];
        [NSEvent removeMonitor:_popoverTransiencyMonitor];
    }
}

#pragma mark - INPopoverControllerDelegate

- (BOOL) popoverShouldClose:(INPopoverController *)popover {
    if (self.statusItemPopupDelegate && [self.statusItemPopupDelegate respondsToSelector:@selector(statusItemPopupShouldClose)]) {
        return [self.statusItemPopupDelegate statusItemPopupShouldClose];
    }
    return NO;
}

- (void) popoverDidClose:(INPopoverController *)popover {
    self.active = NO;
}

@end


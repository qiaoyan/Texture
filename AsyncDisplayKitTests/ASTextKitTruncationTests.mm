/* Copyright (c) 2014-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ASTextKitContext.h"
#import "ASTextKitTailTruncater.h"

@interface ASTextKitTruncationTests : XCTestCase

@end

@implementation ASTextKitTruncationTests

- (NSString *)_sentenceString
{
  return @"90's cray photo booth tote bag bespoke Carles. Plaid wayfarers Odd Future master cleanse tattooed four dollar toast small batch kale chips leggings meh photo booth occupy irony.";
}

- (NSAttributedString *)_sentenceAttributedString
{
  return [[NSAttributedString alloc] initWithString:[self _sentenceString] attributes:@{}];
}

- (NSAttributedString *)_simpleTruncationAttributedString
{
  return [[NSAttributedString alloc] initWithString:@"..." attributes:@{}];
}

- (void)testEmptyTruncationStringSameAsStraightTextKitTailTruncation
{
  CGSize constrainedSize = CGSizeMake(100, 50);
  NSAttributedString *attributedString = [self _sentenceAttributedString];
  ASTextKitContext *context = [[ASTextKitContext alloc] initWithAttributedString:attributedString
                                                                   lineBreakMode:NSLineBreakByWordWrapping
                                                            maximumNumberOfLines:0
                                                                  exclusionPaths:nil
                                                                 constrainedSize:constrainedSize
                                                            layoutManagerFactory:nil];
  __block NSRange textKitVisibleRange;
  [context performBlockWithLockedTextKitComponents:^(NSLayoutManager *layoutManager, NSTextStorage *textStorage, NSTextContainer *textContainer) {
    textKitVisibleRange = [layoutManager characterRangeForGlyphRange:[layoutManager glyphRangeForTextContainer:textContainer]
                                                    actualGlyphRange:NULL];
  }];
  ASTextKitTailTruncater *tailTruncater = [[ASTextKitTailTruncater alloc] initWithContext:context
                                                               truncationAttributedString:nil
                                                                   avoidTailTruncationSet:nil];
  XCTAssert(NSEqualRanges(textKitVisibleRange, tailTruncater.visibleRanges[0]));
}

- (void)testSimpleTailTruncation
{
  CGSize constrainedSize = CGSizeMake(100, 60);
  NSAttributedString *attributedString = [self _sentenceAttributedString];
  ASTextKitContext *context = [[ASTextKitContext alloc] initWithAttributedString:attributedString
                                                                   lineBreakMode:NSLineBreakByWordWrapping
                                                            maximumNumberOfLines:0
                                                                  exclusionPaths:nil
                                                                 constrainedSize:constrainedSize
                                                            layoutManagerFactory:nil];
  ASTextKitTailTruncater *tailTruncater = [[ASTextKitTailTruncater alloc] initWithContext:context
                                                               truncationAttributedString:[self _simpleTruncationAttributedString]
                                                                   avoidTailTruncationSet:[NSCharacterSet characterSetWithCharactersInString:@""]];
  __block NSString *drawnString;
  [context performBlockWithLockedTextKitComponents:^(NSLayoutManager *layoutManager, NSTextStorage *textStorage, NSTextContainer *textContainer) {
    drawnString = textStorage.string;
  }];
  NSString *expectedString = @"90's cray photo booth tote bag bespoke Carles. Plaid wayfarers...";
  XCTAssertEqualObjects(expectedString, drawnString);
  XCTAssert(NSEqualRanges(NSMakeRange(0, 62), tailTruncater.visibleRanges[0]));
}

- (void)testAvoidedCharTailWordBoundaryTruncation
{
  CGSize constrainedSize = CGSizeMake(100, 50);
  NSAttributedString *attributedString = [self _sentenceAttributedString];
  ASTextKitContext *context = [[ASTextKitContext alloc] initWithAttributedString:attributedString
                                                                   lineBreakMode:NSLineBreakByWordWrapping
                                                            maximumNumberOfLines:0
                                                                  exclusionPaths:nil
                                                                 constrainedSize:constrainedSize
                                                            layoutManagerFactory:nil];
  ASTextKitTailTruncater *tailTruncater = [[ASTextKitTailTruncater alloc] initWithContext:context
                                                               truncationAttributedString:[self _simpleTruncationAttributedString]
                                                                   avoidTailTruncationSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
  (void)tailTruncater;
  __block NSString *drawnString;
  [context performBlockWithLockedTextKitComponents:^(NSLayoutManager *layoutManager, NSTextStorage *textStorage, NSTextContainer *textContainer) {
    drawnString = textStorage.string;
  }];
  // This should have removed the additional "." in the string right after Carles.
  NSString *expectedString = @"90's cray photo booth tote bag bespoke Carles...";
  XCTAssertEqualObjects(expectedString, drawnString);
}

- (void)testAvoidedCharTailCharBoundaryTruncation
{
  CGSize constrainedSize = CGSizeMake(50, 50);
  NSAttributedString *attributedString = [self _sentenceAttributedString];
  ASTextKitContext *context = [[ASTextKitContext alloc] initWithAttributedString:attributedString
                                                                   lineBreakMode:NSLineBreakByCharWrapping
                                                            maximumNumberOfLines:0
                                                                  exclusionPaths:nil
                                                                 constrainedSize:constrainedSize
                                                            layoutManagerFactory:nil];
  ASTextKitTailTruncater *tailTruncater = [[ASTextKitTailTruncater alloc] initWithContext:context
                                                               truncationAttributedString:[self _simpleTruncationAttributedString]
                                                                   avoidTailTruncationSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
  // So Xcode doesn't yell at me for an unused var...
  (void)tailTruncater;
  __block NSString *drawnString;
  [context performBlockWithLockedTextKitComponents:^(NSLayoutManager *layoutManager, NSTextStorage *textStorage, NSTextContainer *textContainer) {
    drawnString = textStorage.string;
  }];
  // This should have removed the additional "." in the string right after Carles.
  NSString *expectedString = @"90's cray photo booth t...";
  XCTAssertEqualObjects(expectedString, drawnString);
}

- (void)testHandleZeroHeightConstrainedSize
{
  CGSize constrainedSize = CGSizeMake(50, 0);
  NSAttributedString *attributedString = [self _sentenceAttributedString];
  ASTextKitContext *context = [[ASTextKitContext alloc] initWithAttributedString:attributedString
                                                                   lineBreakMode:NSLineBreakByCharWrapping
                                                            maximumNumberOfLines:0
                                                                  exclusionPaths:nil
                                                                 constrainedSize:constrainedSize
                                                            layoutManagerFactory:nil];
  XCTAssertNoThrow([[ASTextKitTailTruncater alloc] initWithContext:context
                                        truncationAttributedString:[self _simpleTruncationAttributedString]
                                            avoidTailTruncationSet:[NSCharacterSet characterSetWithCharactersInString:@"."]]);
}

@end

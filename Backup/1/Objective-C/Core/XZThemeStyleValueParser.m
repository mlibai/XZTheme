//
//  XZThemeStyleValueParser.m
//  XZKit
//
//  Created by mlibai on 2017/12/21.
//  Copyright © 2017年 mlibai. All rights reserved.
//

#import "XZThemeStyleValueParser.h"
@import XZKit;

@interface _XZThemeStyleFontValueParser: XZThemeStyleValueParser<UIFont *>
@end
@interface _XZThemeStyleColorValueParser: XZThemeStyleValueParser<UIColor *>
@end
@interface _XZThemeStyleImageValueParser: XZThemeStyleValueParser<UIImage *>
@end
@interface _XZThemeStyleStringValueParser: XZThemeStyleValueParser<NSString *>
@end
@interface _XZThemeStyleAttributedStringValueParser: XZThemeStyleValueParser<NSAttributedString *>
@end
@interface _XZThemeStyleStringAttributesValueParser: XZThemeStyleValueParser<NSDictionary<NSAttributedStringKey,id> *>
@end

static XZThemeStyleValueParser<UIFont *> *_fontParser                                             = nil;
static XZThemeStyleValueParser<UIColor *> *_colorParser                                           = nil;
static XZThemeStyleValueParser<UIImage *> *_imageParser                                           = nil;
static XZThemeStyleValueParser<NSString *> *_stringParser                                         = nil;
static XZThemeStyleValueParser<NSAttributedString *> *_attributedStringParser                     = nil;
static XZThemeStyleValueParser<NSDictionary<NSAttributedStringKey,id> *> *_stringAttributesParser = nil;


@implementation XZThemeStyle (Parser)

// UIFont

+ (XZThemeStyleValueParser<UIFont *> *)fontParser {
    if (_fontParser != nil) {
        return _fontParser;
    }
    _fontParser = [[_XZThemeStyleFontValueParser alloc] init];
    return _fontParser;
}

+ (void)setFontParser:(XZThemeStyleValueParser<UIFont *> *)fontParser {
    _fontParser = fontParser;
}

// UIColor

+ (XZThemeStyleValueParser<UIColor *> *)colorParser {
    if (_colorParser != nil) {
        return _colorParser;
    }
    _colorParser = [[_XZThemeStyleColorValueParser alloc] init];
    return _colorParser;
}

+ (void)setColorParser:(XZThemeStyleValueParser<UIColor *> *)colorParser {
    _colorParser = colorParser;
}


// UIImage

+ (XZThemeStyleValueParser<UIImage *> *)imageParser {
    if (_imageParser != nil) {
        return _imageParser;
    }
    _imageParser = [[_XZThemeStyleImageValueParser alloc] init];
    return _imageParser;
}

+ (void)setImageParser:(XZThemeStyleValueParser<UIImage *> *)imageParser {
    _imageParser = imageParser;
}

// NSString

+ (XZThemeStyleValueParser<NSString *> *)stringParser {
    if (_stringParser != nil) {
        return _stringParser;
    }
    _stringParser = [[_XZThemeStyleStringValueParser alloc] init];
    return _stringParser;
}

+ (void)setStringParser:(XZThemeStyleValueParser<NSString *> *)stringParser {
    _stringParser = stringParser;
}

// NSAttributedString

+ (XZThemeStyleValueParser<NSAttributedString *> *)attributedStringParser {
    if (_attributedStringParser != nil) {
        return _attributedStringParser;
    }
    _attributedStringParser = [[_XZThemeStyleAttributedStringValueParser alloc] init];
    return _attributedStringParser;
}

+ (void)setAttributedStringParser:(XZThemeStyleValueParser<NSAttributedString *> *)attributedStringParser {
    _attributedStringParser = attributedStringParser;
}


// NSDictionary

+ (XZThemeStyleValueParser<NSDictionary<NSAttributedStringKey,id> *> *)stringAttributesParser {
    if (_stringAttributesParser != nil) {
        return _stringAttributesParser;
    }
    _stringAttributesParser = [[_XZThemeStyleStringAttributesValueParser alloc] init];
    return _stringAttributesParser;
}

+ (void)setStringAttributesParser:(XZThemeStyleValueParser<NSDictionary<NSAttributedStringKey,id> *> *)stringAttributesParser {
    _stringAttributesParser = stringAttributesParser;
}

@end


@implementation XZThemeStyleValueParser

+ (instancetype)alloc {
    NSAssert(self != [XZThemeStyleValueParser class], @"XZThemeParser can not initialized directly, use subclass instead.");
    return [super alloc];
}

- (id)parse:(id)value {
    NSAssert(NO, @"XZThemeParser can not be used directly, use its static property instead.");
    return value;
}

@end

@implementation _XZThemeStyleFontValueParser

- (UIFont *)parse:(id)value {
    if ([value isKindOfClass:[UIFont class]]) {
        return (UIFont *)value;
    }
    if ([value isKindOfClass:[NSString class]]) {
        return [UIFont fontWithName:(NSString *)value size:[UIFont systemFontSize]];
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [UIFont systemFontOfSize:(CGFloat)[(NSNumber *)value doubleValue]];
    }
    if (![value isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSDictionary<NSString *, id> *dict = (NSDictionary<NSString *, id> *)value;
    CGFloat fontSize = [dict[@"size"] respondsToSelector:@selector(floatValue)] ? [dict[@"size"] floatValue] : [UIFont systemFontSize];
    if ([dict[@"name"] isKindOfClass:[NSString class]]) {
        return [UIFont fontWithName:dict[@"name"] size:fontSize];
    }
    if (@available(iOS 8.2, *)) {
        CGFloat fontWeight = [dict[@"weight"] respondsToSelector:@selector(floatValue)] ? [dict[@"weight"] floatValue] : 0;
        return [UIFont systemFontOfSize:fontSize weight:fontWeight];
    } else {
        return [UIFont systemFontOfSize:fontSize];
    }
}

@end

@implementation _XZThemeStyleColorValueParser

- (UIColor *)parse:(id)value {
    if ([value isKindOfClass:[UIColor class]]) {
        return (UIColor *)value;
    }
    if ([value isKindOfClass:[NSString class]]) {
        return [UIColor xz_colorWithString:(NSString *)value];
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [UIColor xz_colorWithNumber:(UInt32)[(NSNumber *)value integerValue]];
    }
    return nil;
}

@end

@implementation _XZThemeStyleImageValueParser

- (UIImage *)parse:(id)value {
    if ([value isKindOfClass:[UIImage class]]) {
        return (UIImage *)value;
    }
    if ([value isKindOfClass:[NSString class]]) {
        return [UIImage imageNamed:(NSString *)value];
    }
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)value;
        if ([dict[@"name"] isKindOfClass:[NSString class]]) {
            if ([dict[@"duration"] respondsToSelector:@selector(doubleValue)]) {
                return [UIImage animatedImageNamed:dict[@"name"] duration:(NSTimeInterval)[dict[@"duration"] doubleValue]];
            }
        }
    }
    return nil;
}

@end

@implementation _XZThemeStyleStringValueParser

- (NSString *)parse:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        return (NSString *)value;
    }
    return [value description];
}

@end

@implementation _XZThemeStyleAttributedStringValueParser

- (NSAttributedString *)parse:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSData *data = [value dataUsingEncoding:(NSUTF8StringEncoding)];
    if (data == nil) {
        return nil;
    }
    NSDictionary<NSAttributedStringDocumentReadingOptionKey,id> *options = @{NSDocumentTypeDocumentOption: NSHTMLTextDocumentType};
    return [[NSAttributedString alloc] initWithData:data options:options documentAttributes:nil error:NULL];
}

@end

@implementation _XZThemeStyleStringAttributesValueParser

- (NSDictionary *)parse:(id)value {
    if (![value isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithDictionary:value];
    attrs[NSFontAttributeName] = [[XZThemeStyle fontParser] parse:attrs[@"font"]];
    [attrs removeObjectForKey:@"font"];
    attrs[NSForegroundColorAttributeName] = [[XZThemeStyle colorParser] parse:attrs[@"color"]];
    [attrs removeObjectForKey:@"color"];
    attrs[NSBackgroundColorAttributeName] = [[XZThemeStyle colorParser] parse:attrs[@"backgroundColor"]];
    [attrs removeObjectForKey:@"backgroundColor"];
    return attrs;
}

@end

//
//  SRKeyCodeTransformer.h
//  ShortcutRecorder
//
//  Copyright 2006-2007 Contributors. All rights reserved.
//
//  License: BSD
//
//  Contributors:
//      David Dauer
//      Jesper
//      Jamie Kirkpatrick

#import "PBSRKeyCodeTransformer.h"
#import <Carbon/Carbon.h>
#import <CoreServices/CoreServices.h>
#import "PBSRCommon.h"

static NSMutableDictionary  *stringToKeyCodeDict = nil;
static NSDictionary         *keyCodeToStringDict = nil;
static NSArray              *padKeysArray        = nil;

@interface PBSRKeyCodeTransformer( Private )
+ (void) regenerateStringToKeyCodeMapping;
@end

#pragma mark -

@implementation PBSRKeyCodeTransformer

//---------------------------------------------------------- 
//  initialize
//---------------------------------------------------------- 
+ (void) initialize;
{
    if ( self != [PBSRKeyCodeTransformer class] )
        return;
    
    // Some keys need a special glyph
	keyCodeToStringDict = [[NSDictionary alloc] initWithObjectsAndKeys:
		@"F1", PBSRInt(122),
		@"F2", PBSRInt(120),
		@"F3", PBSRInt(99),
		@"F4", PBSRInt(118),
		@"F5", PBSRInt(96),
		@"F6", PBSRInt(97),
		@"F7", PBSRInt(98),
		@"F8", PBSRInt(100),
		@"F9", PBSRInt(101),
		@"F10", PBSRInt(109),
		@"F11", PBSRInt(103),
		@"F12", PBSRInt(111),
		@"F13", PBSRInt(105),
		@"F14", PBSRInt(107),
		@"F15", PBSRInt(113),
		@"F16", PBSRInt(106),
		@"F17", PBSRInt(64),
		@"F18", PBSRInt(79),
		@"F19", PBSRInt(80),
		PBSRLoc(@"Space"), PBSRInt(49),
		PBSRChar(KeyboardDeleteLeftGlyph), PBSRInt(51),
		PBSRChar(KeyboardDeleteRightGlyph), PBSRInt(117),
		PBSRChar(KeyboardPadClearGlyph), PBSRInt(71),
		PBSRChar(KeyboardLeftArrowGlyph), PBSRInt(123),
		PBSRChar(KeyboardRightArrowGlyph), PBSRInt(124),
		PBSRChar(KeyboardUpArrowGlyph), PBSRInt(126),
		PBSRChar(KeyboardDownArrowGlyph), PBSRInt(125),
		PBSRChar(KeyboardSoutheastArrowGlyph), PBSRInt(119),
		PBSRChar(KeyboardNorthwestArrowGlyph), PBSRInt(115),
		PBSRChar(KeyboardEscapeGlyph), PBSRInt(53),
		PBSRChar(KeyboardPageDownGlyph), PBSRInt(121),
		PBSRChar(KeyboardPageUpGlyph), PBSRInt(116),
		PBSRChar(KeyboardReturnR2LGlyph), PBSRInt(36),
		PBSRChar(KeyboardReturnGlyph), PBSRInt(76),
		PBSRChar(KeyboardTabRightGlyph), PBSRInt(48),
		PBSRChar(KeyboardHelpGlyph), PBSRInt(114),
		nil];    
    
    // We want to identify if the key was pressed on the numpad
	padKeysArray = [[NSArray alloc] initWithObjects: 
		PBSRInt(65), // ,
		PBSRInt(67), // *
		PBSRInt(69), // +
		PBSRInt(75), // /
		PBSRInt(78), // -
		PBSRInt(81), // =
		PBSRInt(82), // 0
		PBSRInt(83), // 1
		PBSRInt(84), // 2
		PBSRInt(85), // 3
		PBSRInt(86), // 4
		PBSRInt(87), // 5
		PBSRInt(88), // 6
		PBSRInt(89), // 7
		PBSRInt(91), // 8
		PBSRInt(92), // 9
		nil];
    
    // generate the string to keycode mapping dict...
    stringToKeyCodeDict = [[NSMutableDictionary alloc] init];
    [self regenerateStringToKeyCodeMapping];

	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(regenerateStringToKeyCodeMapping) name:(NSString*)kTISNotifySelectedKeyboardInputSourceChanged object:nil];
}

//---------------------------------------------------------- 
//  allowsReverseTransformation
//---------------------------------------------------------- 
+ (BOOL) allowsReverseTransformation
{
    return YES;
}

//---------------------------------------------------------- 
//  transformedValueClass
//---------------------------------------------------------- 
+ (Class) transformedValueClass;
{
    return [NSString class];
}


//---------------------------------------------------------- 
//  init
//---------------------------------------------------------- 
- (id)init
{
	if((self = [super init]))
	{
	}
	return self;
}

//---------------------------------------------------------- 
//  dealloc
//---------------------------------------------------------- 
- (void)dealloc
{
	[super dealloc];
}

//---------------------------------------------------------- 
//  transformedValue: 
//---------------------------------------------------------- 
- (id) transformedValue:(id)value
{
    if ( ![value isKindOfClass:[NSNumber class]] )
        return nil;
    
    // Can be -1 when empty
    NSInteger keyCode = [value shortValue];
	if ( keyCode < 0 ) return nil;
	
	// We have some special gylphs for some special keys...
	NSString *unmappedString = [keyCodeToStringDict objectForKey: PBSRInt( keyCode )];
	if ( unmappedString != nil ) return unmappedString;
	
	BOOL isPadKey = [padKeysArray containsObject: PBSRInt( keyCode )];
	
	OSStatus err;
	TISInputSourceRef tisSource = TISCopyCurrentKeyboardInputSource();
	if(!tisSource) return nil;
	
	CFDataRef layoutData;
	UInt32 keysDown = 0;
	layoutData = (CFDataRef)TISGetInputSourceProperty(tisSource, kTISPropertyUnicodeKeyLayoutData);
	if(!layoutData) return nil;

	const UCKeyboardLayout *keyLayout = (const UCKeyboardLayout *)CFDataGetBytePtr(layoutData);
			
	UniCharCount length = 4, realLength;
	UniChar chars[4];
	
	err = UCKeyTranslate( keyLayout, 
						 keyCode,
						 kUCKeyActionDisplay,
						 0,
						 LMGetKbdType(),
						 kUCKeyTranslateNoDeadKeysBit,
						 &keysDown,
						 length,
						 &realLength,
						 chars);
	
	if ( err != noErr ) return nil;
	
	NSString *keyString = [[NSString stringWithCharacters:chars length:1] uppercaseString];
	
	return ( isPadKey ? [NSString stringWithFormat: PBSRLoc(@"Pad %@"), keyString] : keyString );
}

//---------------------------------------------------------- 
//  reverseTransformedValue: 
//---------------------------------------------------------- 
- (id) reverseTransformedValue:(id)value
{
    if ( ![value isKindOfClass:[NSString class]] )
        return nil;
    
    // try and retrieve a mapped keycode from the reverse mapping dict...
    return [stringToKeyCodeDict objectForKey:value];
}

@end

#pragma mark -

@implementation PBSRKeyCodeTransformer( Private )

//---------------------------------------------------------- 
//  regenerateStringToKeyCodeMapping: 
//---------------------------------------------------------- 
+ (void) regenerateStringToKeyCodeMapping;
{
    PBSRKeyCodeTransformer *transformer = [[[self alloc] init] autorelease];
    [stringToKeyCodeDict removeAllObjects];
    
    // loop over every keycode (0 - 127) finding its current string mapping...
	NSUInteger i;
    for ( i = 0U; i < 128U; i++ )
    {
        NSNumber *keyCode = [NSNumber numberWithUnsignedInteger:i];
        NSString *string = [transformer transformedValue:keyCode];
        if ( ( string ) && ( [string length] ) )
        {
            [stringToKeyCodeDict setObject:keyCode forKey:string];
        }
    }
}

@end

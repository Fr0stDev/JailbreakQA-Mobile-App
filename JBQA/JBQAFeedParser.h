//
//  JBQAParser.h
//  JBQA
//
//  Created by Aditya KD on 22/08/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol JBQAParserDelegate

- (void)parseErrorOccurred:(NSError *)error;
- (void)parserDidEndDocumentWithResults:(id)parseResults;

@optional

- (void)parserDidStartDocument;

@end

@interface JBQAFeedParser : NSObject <NSXMLParserDelegate>
{
    NSXMLParser  *rssParser;
    NSMutableDictionary *item;
	NSString *currentElement;
	NSMutableString *currentTitle, *currentDate, *currentSummary, *currentLink, *currentAuthor;
    NSString *xmlString;
    NSMutableArray *parseResults;
    id <JBQAParserDelegate> delegate;
    int totalLines;
}

- (void)parseXMLFileAtURL:(NSString *)URL;

@property (weak) NSXMLParser *rssParser;
@property (strong) NSMutableDictionary *item;
@property (nonatomic, getter = isParsing) BOOL parsing;
@property (weak) id delegate; //Hopefully, this will set the reference to nil when the parser dies :)


@end

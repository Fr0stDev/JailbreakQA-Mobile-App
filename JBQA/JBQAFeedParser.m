//
//  JBQAParser.m
//  JBQA
//
//  Created by Aditya KD on 22/08/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//
//  Credit goes to flux for this one!
 

#import "JBQAFeedParser.h"

@implementation JBQAFeedParser

- (void)parseXMLFileAtURL:(NSString *)URL
{
    self.Parsing = YES;
    NSURL *xmlURL = [NSURL URLWithString:URL];
    NSError *error = nil;
    NSString *xmlFileString = [NSString stringWithContentsOfURL:xmlURL
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
    //hope this works
    totalLines = [xmlFileString componentsSeparatedByString:@"\n"].count;
	// here, for some reason you have to use NSClassFromString when trying to alloc NSXMLParser, otherwise you will get an object not found error
	// this may be necessary only for the toolchain
	rssParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
    
	// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [rssParser setDelegate:self];
	// Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
	[rssParser setShouldProcessNamespaces:NO];
	[rssParser setShouldReportNamespacePrefixes:NO];
	[rssParser setShouldResolveExternalEntities:NO];
    [rssParser parse];
}

//Forward NSXMLParser's delegated methods to self.delegate 
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    parseResults = [[NSMutableArray alloc] init];
    if ([self.delegate respondsToSelector:@selector(parserDidStartDocument:)]) {
        NSLog(@"Delegate responds to %@, sending to delegate", NSStringFromSelector(_cmd));
        [self.delegate parserDidStartDocument];
    }
    else
        NSLog(@"Begin parse");
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{   if ([self.delegate respondsToSelector:@selector(parseErrorOccurred:)])
        [self.delegate parseErrorOccurred:parseError];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{

	currentElement = [elementName copy];
	if ([elementName isEqualToString:@"item"]) {
		// clear out our story item caches...
		item = [[NSMutableDictionary alloc] init];
		currentTitle = [[NSMutableString alloc] init];
		currentDate = [[NSMutableString alloc] init];
		currentSummary = [[NSMutableString alloc] init];
		currentLink = [[NSMutableString alloc] init];
        currentAuthor = [[NSMutableString alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	//NSLog(@"ended element: %@", elementName);
	if ([elementName isEqualToString:@"item"]) {
		// save values to an item, then store that item into the array...
		[item setObject:currentTitle forKey:@"title"];
		[item setObject:currentLink forKey:@"link"];
		[item setObject:currentSummary forKey:@"summary"];
		[item setObject:currentDate forKey:@"date"];
        [item setObject:currentAuthor forKey:@"author"];
        [parseResults addObject:[item copy]];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //NSLog(@"found characters: %@", string);
	// save the characters for the current item...
	if ([currentElement isEqualToString:@"title"]) {
		[currentTitle appendString:string];
	} else if ([currentElement isEqualToString:@"link"]) {
		[currentLink appendString:string];
	} else if ([currentElement isEqualToString:@"description"]) {
		[currentSummary appendString:string];
	} else if ([currentElement isEqualToString:@"pubDate"]) {
		[currentDate appendString:string];
	}else if ([currentElement isEqualToString:@"dc:creator"]) {
		[currentAuthor appendString:string];
	}
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if ([self.delegate respondsToSelector:@selector(parserDidEndDocumentWithResults:)]);
        [self.delegate parserDidEndDocumentWithResults:parseResults];
}

@end

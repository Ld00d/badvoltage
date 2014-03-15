//
//  BVFeedParser.m
//  BadVoltageApp
//
//  Created by Frank Poole on 3/15/14.
//  Copyright (c) 2014 The Girls and Me. All rights reserved.
//

#import "BVFeedParser.h"
#import "BVPodcastEpisode.h"
#import "BVPodcastMedia.h"

@implementation BVFeedParser
{
    NSXMLParser *_parser;
    NSMutableArray *_episodes;
    NSRange _range;
    NSInteger _index;
    BVPodcastEpisode *_episode;
    void (^_textsetter)(NSString *);
}


- (id)initWithUrl:(NSString *)url
{
    self = [super init];
    if (self) {
       
        _parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
        [_parser setDelegate:self];
    }
    return self;
}

- (NSArray *)getEpisodesWithRange:(NSRange)range
{
    _range = range;
    [_parser parse];
    
    return _episodes;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    _index = 0;
    _episode = nil;
    _episodes = [[NSMutableArray alloc] init];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    
    if ([elementName isEqualToString:@"item"] ) {
        
        if ([_episodes count] >= _range.length) {
            [parser abortParsing];
        } else if (_index >= _range.location) {
            _episode = [[BVPodcastEpisode alloc] init];
        }
        
    } else if (_episode != nil && [elementName isEqualToString:@"title"]) {
        NSMutableString *text = [[NSMutableString alloc] init];
        _textsetter = ^void(NSString* string) {
            [text appendString:string];
        };
        [_episode setTitle:text];
    } else if (_episode != nil && [elementName isEqualToString:@"itunes:subtitle"]) {
        NSMutableString *text = [[NSMutableString alloc] init];
        _textsetter = ^void(NSString* string) {
            [text appendString:string];
        };
        [_episode setSubtitle:text];
    } else if (_episode != nil && [elementName isEqualToString:@"itunes:summary"]) {
        NSMutableString *text = [[NSMutableString alloc] init];
        _textsetter = ^void(NSString* string) {
            [text appendString:string];
        };
        [_episode setSummary:text];
    } else if (_episode != nil && [elementName isEqualToString:@"pubDate"]) {
        BVPodcastEpisode *episode = _episode;
        _textsetter = ^void(NSString* string) {
            NSDateFormatter *dtFormatter = [[NSDateFormatter alloc] init];
            //Thu, 13 Mar 2014 00:29:45 +0000
            [dtFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZZ"];
            [episode setPubDate:[dtFormatter dateFromString:string]];
        };
    } else if (_episode != nil && [elementName isEqualToString:@"enclosure"]) {
        BVPodcastMedia *media = [[BVPodcastMedia alloc] init];
        [media setUrl:[attributeDict objectForKey:@"url"]];
        [media setLength:[[attributeDict objectForKey:@"length"] intValue]];
        
        [_episode setMedia:media];
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (_textsetter != NULL) {
        _textsetter(string);
    }
}
                                   

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"item"] ) {
        _index++;
        if (_episode != nil) {
            [_episodes addObject:_episode];
            _episode = nil;
        }
        
    }
    _textsetter = NULL;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{

}


@end

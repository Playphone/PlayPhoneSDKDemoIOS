//
//  MNWSXmlTools.m
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 5/13/11.
//  Copyright 2011 PlayPhone. All rights reserved.
//

#import "MNWSXmlTools.h"

static CXMLElement* xmlNodeSkipToElement (CXMLNode* node) {
    while (node != nil && [node kind] != CXMLElementKind) {
        node = [node nextSibling];
    }

    return (CXMLElement*)node;
}

CXMLElement* MNWSXmlNodeGetFirstChildElement (CXMLNode* node) {
    return xmlNodeSkipToElement([node childAtIndex: 0]);
}

CXMLElement* MNWSXmlNodeGetNextSiblingElement (CXMLNode* node) {
    return xmlNodeSkipToElement([node nextSibling]);
}

CXMLElement* MNWSXmlDocumentGetElementByPath (CXMLDocument* document, NSArray* tags) {
    CXMLElement* element    = nil;
    NSUInteger   pathLength = [tags count];

    if (pathLength > 0) {
        element = [document rootElement];

        if (![[element name] isEqualToString: [tags objectAtIndex: 0]]) {
            element = nil;
        }
    }

    for (NSUInteger index = 1; index < pathLength && element != nil; index++) {
        element = MNWSXmlNodeGetFirstChildElement(element);

        while (element != nil && ![[element name] isEqualToString: [tags objectAtIndex: index]]) {
            element = MNWSXmlNodeGetNextSiblingElement(element);
        }
    }

    return element;
}

NSArray* MNWSXmlNodeParseItemList (CXMLNode* node, NSString* tagName) {
    NSMutableArray* result = [NSMutableArray array];
    CXMLElement* itemElement = MNWSXmlNodeGetFirstChildElement(node);

    while (itemElement != nil) {
        NSMutableDictionary* itemData = [NSMutableDictionary dictionary];

        CXMLElement* dataElement = MNWSXmlNodeGetFirstChildElement(itemElement);

        while (dataElement != nil) {
            NSString* value = [dataElement stringValue];

            [itemData setObject: value == nil ? @"" : value forKey: [dataElement name]];

            dataElement = MNWSXmlNodeGetNextSiblingElement(dataElement);
        }

        [result addObject: itemData];

        itemElement = MNWSXmlNodeGetNextSiblingElement(itemElement);
    }

    return result;
}

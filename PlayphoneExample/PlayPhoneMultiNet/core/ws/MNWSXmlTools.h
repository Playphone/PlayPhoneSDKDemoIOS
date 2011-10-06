//
//  MNWSXmlTools.h
//  MultiNet client
//
//  Created by Sergey Prokhorchuk on 5/13/11.
//  Copyright 2011 PlayPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TouchXML.h"

#ifdef __cplusplus
extern "C" {
#endif

extern CXMLElement* MNWSXmlNodeGetFirstChildElement  (CXMLNode* node);
extern CXMLElement* MNWSXmlNodeGetNextSiblingElement (CXMLNode* node);

extern CXMLElement* MNWSXmlDocumentGetElementByPath  (CXMLDocument* document, NSArray* tags);

extern NSArray*     MNWSXmlNodeParseItemList         (CXMLNode* node, NSString* tagName);

#ifdef __cplusplus
}
#endif

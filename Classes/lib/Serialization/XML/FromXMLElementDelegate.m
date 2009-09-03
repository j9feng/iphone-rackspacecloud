//
//  FromXMLElementDelegate.m
//  
//
//  Created by Ryan Daigle on 7/31/08.
//  Copyright 2008 yFactorial, LLC. All rights reserved.
//

#import "FromXMLElementDelegate.h"
#import "XMLSerializableSupport.h"
#import "CoreSupport.h"
#import "CloudFilesObject.h"
#import "Container.h"
#import "Server.h"
#import "Flavor.h"
#import "Image.h"
#import "SharedIpGroup.h"

@implementation FromXMLElementDelegate

NSDictionary *serverAttributes;
NSDictionary *flavorAttributes;
NSDictionary *imageAttributes;
NSDictionary *sharedIpGroupAttributes;
BOOL parsingPublicAddresses = NO;
BOOL parsingPrivateAddresses = NO;

@synthesize targetClass, parsedObject, currentPropertyName, contentOfCurrentProperty, unclosedProperties, currentPropertyType;

+ (FromXMLElementDelegate *)delegateForClass:(Class)targetClass {
	FromXMLElementDelegate *delegate = [[[self alloc] init] autorelease];
	[delegate setTargetClass:targetClass];
	return delegate;
}


- (id)init {
	super;
	self.unclosedProperties = [NSMutableArray array];
	return self;
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{	
	
	//NSString *fakeResponse = @"
	//<sharedIpGroups xmlns=\"http://docs.rackspacecloud.com/servers/api/v1.0\">
	//	<sharedIpGroup id=\"1234\" name=\"Shared IP Group 1\">
	//		<servers><server id=\"422\" /><server id=\"3445\" /></servers>
	//	</sharedIpGroup>
	//	<sharedIpGroup id=\"5678\" name=\"Shared IP Group 2\">
	//		<servers><server id=\"23203\"/><server id=\"2456\" /><server id=\"9891\" /></servers>
	//	</sharedIpGroup>
	//</sharedIpGroups>";
	
	if ([@"server" isEqualToString:elementName]) {
		// we end up losing the attributeDict before allocating a server, so back it up here.
		serverAttributes = attributeDict;
		
		if ([self.parsedObject class] == NSClassFromString(@"SharedIpGroup")) {
			NSMutableArray *servers = ((SharedIpGroup *)self.parsedObject).servers;
			if (!servers) {
				servers = [[[NSMutableArray alloc] initWithCapacity:1] retain];
			}
			Server *server = [[Server alloc] init];
			server.serverId = [serverAttributes objectForKey:@"id"];
			//[((SharedIpGroup *)self.parsedObject).servers addObject:server];
			[servers addObject:server];
		}
	}
	
	if ([@"sharedIpGroup" isEqualToString:elementName]) {
		sharedIpGroupAttributes = attributeDict;
	}
	
	if ([@"flavor" isEqualToString:elementName]) {
		flavorAttributes = attributeDict;		
		Flavor *flavor = [[Flavor alloc] init];
		flavor.flavorId = [flavorAttributes objectForKey:@"id"];
		flavor.flavorName = [flavorAttributes objectForKey:@"name"];
		flavor.ram = [flavorAttributes objectForKey:@"ram"];
		flavor.disk = [flavorAttributes objectForKey:@"disk"];
		flavorAttributes = nil;
		
		[self.parsedObject addObject:flavor];
	}
	
	if ([@"image" isEqualToString:elementName]) {
		
		//<image status="ACTIVE" progress="100" created="2009-08-01T00:00:16-05:00" updated="2009-08-01T00:02:11-05:00" 
		//serverId="64783" name="daily" id="12003"/></images>		
		
		imageAttributes = attributeDict;
		Image *image = [[Image alloc] init];
		image.imageId = [imageAttributes objectForKey:@"id"];
		image.imageName = [imageAttributes objectForKey:@"name"];
		image.progress = [imageAttributes objectForKey:@"progress"];
		image.status = [imageAttributes objectForKey:@"status"];
		image.serverId = [imageAttributes objectForKey:@"serverId"];
		imageAttributes = nil;
		
		[self.parsedObject addObject:image];
		
	}
	
	if ([@"public" isEqualToString:elementName]) {
		parsingPublicAddresses = YES;
		parsingPrivateAddresses = NO;
	}

	if ([@"private" isEqualToString:elementName]) {
		parsingPublicAddresses = NO;
		parsingPrivateAddresses = YES;
	}
	
	if (parsingPublicAddresses && [@"ip" isEqualToString:elementName]) {
		Server *s = self.parsedObject;
		[[s.addresses objectForKey:@"public"] addObject:[attributeDict objectForKey:@"addr"]];
	}

	if (parsingPrivateAddresses && [@"ip" isEqualToString:elementName]) {
		Server *s = self.parsedObject;
		[[s.addresses objectForKey:@"private"] addObject:[attributeDict objectForKey:@"addr"]];
	}
	
	if ([@"nil-classes" isEqualToString:elementName]) {
		//empty result set, do nothing
	} else if ([@"sharedIpGroups" isEqualToString:elementName] || ([@"servers" isEqualToString:elementName] && ![@"sharedIpGroup" isEqualToString:self.currentPropertyName]) || [@"flavors" isEqualToString:elementName] || [@"images" isEqualToString:elementName]) {
// sharedIpGroup
		
		self.parsedObject = [NSMutableArray array];
		[self.unclosedProperties addObject:[NSArray arrayWithObjects:elementName, self.parsedObject, nil]];
		self.currentPropertyName = elementName;
		
	//Start of an array type
	} else if ([@"array" isEqualToString:[attributeDict objectForKey:@"type"]]) {
		self.parsedObject = [NSMutableArray array];
		[self.unclosedProperties addObject:[NSArray arrayWithObjects:elementName, self.parsedObject, nil]];
		self.currentPropertyName = elementName;
	
	
	} else if ([@"server" isEqualToString:elementName] && self.currentPropertyName == nil) {
	
		Server *server = [[Server alloc] init];
		server.serverId = [serverAttributes objectForKey:@"id"];
		server.serverName = [serverAttributes objectForKey:@"name"];
		server.flavorId = [serverAttributes objectForKey:@"flavorId"];
		server.status = [serverAttributes objectForKey:@"status"];
		server.progress = [serverAttributes objectForKey:@"progress"];
		
		self.parsedObject = server;
		
	//Start of the root object
    } else if (parsedObject == nil && [elementName isEqualToString:[self.targetClass xmlElementName]]) {
        self.parsedObject = [[[self.targetClass alloc] init] autorelease];
		[self.unclosedProperties addObject:[NSArray arrayWithObjects:elementName, self.parsedObject, nil]];
		self.currentPropertyName = elementName;
    }
	
	else {
		
		// i hate having to hack objective resource :(
//		if (self.currentPropertyName != nil && [elementName isEqualToString:@"object"]) {
//			
//			NSLog(@"caught an object!");
//			self.parsedObject = [[[CloudFilesObject alloc] init] autorelease];
//			[self.unclosedProperties addObject:[NSArray arrayWithObjects:self.currentPropertyName, self.parsedObject, nil]];
//			self.currentPropertyName = elementName;
//			
//			
//		} else 
		
		//if we are inside another element and it is not the current parent object, 
		// then create an object for that parent element
		if (self.currentPropertyName != nil && (![self.currentPropertyName isEqualToString:[[self.parsedObject class] xmlElementName]]) ) {
//				&& (![self.currentPropertyName isEqualToString:@"object"])) {
			Class elementClass = NSClassFromString([currentPropertyName toClassName]);
			if (elementClass != nil) {
				//classname matches, instantiate a new instance of the class and set it as the current parent object

				
				
				if ([currentPropertyName isEqualToString:@"object"]) {
					if ([self.parsedObject class] != NSClassFromString(@"CloudFilesObject")) {
						self.parsedObject = [[[CloudFilesObject alloc] init] autorelease];
						[self.unclosedProperties addObject:[NSArray arrayWithObjects:self.currentPropertyName, self.parsedObject, nil]];
					}
				} else {
					self.parsedObject = [[[elementClass alloc] init] autorelease];
					
					if ([self.parsedObject class] == NSClassFromString(@"Server")) {
						Server *server = (Server *) self.parsedObject;						
						server.serverId = [serverAttributes objectForKey:@"id"];
						server.serverName = [serverAttributes objectForKey:@"name"];
						server.imageId = [serverAttributes objectForKey:@"imageId"];
						server.flavorId = [serverAttributes objectForKey:@"flavorId"];
						server.status = [serverAttributes objectForKey:@"status"];
						server.hostId = [serverAttributes objectForKey:@"hostId"];
						server.progress = [serverAttributes objectForKey:@"progress"];
						server.addresses = [NSMutableDictionary dictionaryWithCapacity:2];
						[server.addresses setObject:[[NSMutableArray alloc] init] forKey:@"public"];
						[server.addresses setObject:[[NSMutableArray alloc] init] forKey:@"private"];
						serverAttributes = nil;
					} else if ([self.parsedObject class] == NSClassFromString(@"Flavor")) {
						Flavor *flavor = (Flavor *) self.parsedObject;
						flavor.flavorId = [flavorAttributes objectForKey:@"id"];
						flavor.flavorName = [flavorAttributes objectForKey:@"name"];
						flavorAttributes = nil;
					} else if ([self.parsedObject class] == NSClassFromString(@"Image")) {
						Image *image = (Image *) self.parsedObject;
						image.imageId = [imageAttributes objectForKey:@"id"];
						image.imageName = [imageAttributes objectForKey:@"name"];
						imageAttributes = nil;
					} else if ([self.parsedObject class] == NSClassFromString(@"SharedIpGroup")) {
						SharedIpGroup *ipGroup = (SharedIpGroup *) self.parsedObject;
						ipGroup.sharedIpGroupId = [sharedIpGroupAttributes objectForKey:@"id"];
						ipGroup.sharedIpGroupName = [sharedIpGroupAttributes objectForKey:@"name"];
						sharedIpGroupAttributes = nil;
					}
				}
				
				if (!([currentPropertyName isEqualToString:@"object"] && [self.parsedObject class] == NSClassFromString(@"CloudFilesObject"))) {
					[self.unclosedProperties addObject:[NSArray arrayWithObjects:self.currentPropertyName, self.parsedObject, nil]];
				}
			}
		}
		
		// If we recognize an element that corresponds to a known property of the current parent object, or if the
		// current parent is an array then start collecting content for this child element
    
		if (([self.parsedObject isKindOfClass:[NSArray class]]) ||
        ([[[self.parsedObject class] propertyNames] containsObject:[[self convertElementName:elementName] camelize]])) {
			self.currentPropertyName = [self convertElementName:elementName];
			self.contentOfCurrentProperty = [NSMutableString string];
			self.currentPropertyType = [attributeDict objectForKey:@"type"];
			if ([self.parsedObject class] == NSClassFromString(@"SharedIpGroup") && [@"servers" isEqualToString:elementName]) {
				self.currentPropertyType = @"array";
			}
		} else {
			// The element isn't one that we care about, so set the property that holds the 
			// character content of the current element to nil. That way, in the parser:foundCharacters:
			// callback, the string that the parser reports will be ignored.
			self.currentPropertyName = nil;
			self.contentOfCurrentProperty = nil;
		}
	}
}

// Characters (i.e. an element value - retarded, I know) are given to us in chunks,
// so we need to append them onto the current property value.
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	
	// If the current property is nil, then we know we're currently at
	// an element that we don't know about or don't care about
    if (self.contentOfCurrentProperty) {
		
		// Append string value on since we're given them in chunks
        [self.contentOfCurrentProperty appendString:string];
    }
}

//Basic type conversion based on the ObjectiveResource "type" attribute
- (id) convertProperty:(NSString *)propertyValue toType:(NSString *)type {
	if ([type isEqualToString:@"datetime" ]) {
		return [NSDate fromXMLDateTimeString:propertyValue];
	}
	else if ([type isEqualToString:@"date"]) {
		return [NSDate fromXMLDateString:propertyValue];
	}
	
	// uncomment this if you what to support NSNumber and NSDecimalNumber
	// if you do your classId must be a NSNumber since rails will pass it as such
	//else if ([type isEqualToString:@"decimal"]) {
	//	return [NSDecimalNumber decimalNumberWithString:propertyValue];
	//}
	//else if ([type isEqualToString:@"integer"]) {
	//	return [NSNumber numberWithInt:[propertyValue intValue]];
	//}
	
	else {
		return [NSString fromXmlString:propertyValue];
	}
}

// Converts the Id element to modelNameId
- (NSString *) convertElementName:(NSString *)anElementName {
 
  if([anElementName isEqualToString:@"id"]) {
		return [NSString stringWithFormat:@"%@Id",[[[self.parsedObject class]xmlElementName] camelize]];
 //   return [NSString stringWithFormat:@"%@_%@" , [NSStringFromClass([self.parsedObject class]) 
//                                                 stringByReplacingCharactersInRange:NSMakeRange(0, 1) 
//                                                 withString:[[NSStringFromClass([self.parsedObject class]) 
//                                                              substringWithRange:NSMakeRange(0,1)] 
//                                                              lowercaseString]], anElementName];
  }
  else {
    
    return anElementName;
    
  }

}

// We're done receiving the value of a particular element, so take the value we've collected and
// set it on the current object
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{    

	// i hate having to hack objective resource :(
//	if (self.currentPropertyName != nil && [elementName isEqualToString:@"object"]) {
//		
//		NSLog(@"caught an object!");
//		Container *c = (Container *) self.parsedObject;
//		c.object = self.contentOfCurrentProperty;
//		
//	} else 
	
	if ([@"flavor" isEqualToString:elementName] || [@"image" isEqualToString:elementName]) {
		// meh
	} else if(self.contentOfCurrentProperty != nil && self.currentPropertyName != nil) {
		[self.parsedObject 
		 setValue:[self convertProperty:self.contentOfCurrentProperty toType:self.currentPropertyType]  
		 forKey:[self.currentPropertyName camelize]];
	}
	else if ([self.currentPropertyName isEqualToString:[self convertElementName:elementName]]) {
		//element is closed, pop it from the stack
		[self.unclosedProperties removeLastObject];
		//check for a parent object on the stack
		if ([self.unclosedProperties count] > 0) {
			//handle arrays as a special case
			if ([[[self.unclosedProperties lastObject] objectAtIndex:1] isKindOfClass:[NSArray class]]) {
				[[[self.unclosedProperties lastObject] objectAtIndex:1] addObject:self.parsedObject];
			}
			else {
				//if (![@"sharedIpGroup" isEqualToString:elementName]) {
					[[[self.unclosedProperties lastObject] objectAtIndex:1] setValue:self.parsedObject forKey:[self convertElementName:[elementName camelize]]];
				//}
			}
			self.parsedObject = [[self.unclosedProperties lastObject] objectAtIndex:1];
		}
	}
	
	self.contentOfCurrentProperty = nil;
	
	//set the parent object, if one exists, as the current element
	if ([self.unclosedProperties count] > 0) {
		self.currentPropertyName = [[self.unclosedProperties lastObject] objectAtIndex:0];
	}
}


#pragma mark cleanup 

- (void)dealloc {
	[targetClass release];
	[currentPropertyName release];
	[parsedObject release];
	[contentOfCurrentProperty release];
	[unclosedProperties release];
	[currentPropertyType release];
	[super dealloc];
}

@end

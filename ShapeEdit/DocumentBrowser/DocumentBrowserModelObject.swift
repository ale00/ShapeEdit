/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information

    Abstract:
    This is the model object which represents one document on disk.
*/

import UIKit

/**
    This class is used as an immutable value object to represent an item in our
    document browser. Note the custom implementation of `hash` and `isEqual(_:)`,
    which are required so we can later look up instances in our results set.
*/
class DocumentBrowserModelObject: NSObject, ModelObject {
    // MARK: - Properties

    fileprivate(set) var displayName: String
	
    fileprivate(set) var subtitle = ""
	
    fileprivate(set) var URL: Foundation.URL

    fileprivate(set) var metadataItem: NSMetadataItem

    // MARK: - Initialization
    required init(item: NSMetadataItem) {
        displayName = item.value(forAttribute: NSMetadataItemDisplayNameKey) as! String
		
        /*
            External documents are not located in the app's ubiquitous container.
            They could either be in another app's ubiquitous container or in the
            user's iCloud Drive folder, outside of the app's sandbox, but the user
            has granted the app access to the document by picking the document in
            the document picker or opening the document in the app on OS X.
            Throughout the system, the name of the document is decorated with the
            source container's name.
        */
        if let isExternal = item.value(forAttribute: NSMetadataUbiquitousItemIsExternalDocumentKey) as? Bool,
               let containerName = item.value(forAttribute: NSMetadataUbiquitousItemContainerDisplayNameKey) as? String, isExternal {
            subtitle = "in \(containerName)"
        }
		
        /*
            The `NSMetadataQuery` will send updates on the `NSMetadataItem` item.
            If the item is renamed or moved, the value for `NSMetadataItemURLKey`
            might change.
        */
        URL = item.value(forAttribute: NSMetadataItemURLKey) as! Foundation.URL
		
        metadataItem = item
    }
	
    // MARK: - Override
	
    /**
        Two `DocumentBrowserModelObject` are equal iff their metadata items are equal.
        We use the metadata item instead of other properties like the URL to compare
        equality in order to track documents across renames.
    */
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? DocumentBrowserModelObject else {
            return false
        }
        
        return other.metadataItem.isEqual(metadataItem)
    }

    /// Hash method implemented to match `isEqual(_:)`'s constraints.
    override var hash: Int {
        return metadataItem.hash
    }
	
    // MARK: - CustomDebugStringConvertible
	
    override var debugDescription: String {
        return super.debugDescription + " " + displayName
    }
}

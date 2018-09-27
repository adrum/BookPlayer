//
//  CarPlayContentManager.swift
//  BookPlayer
//
//  Created by Austin Drummond on 7/14/18.
//  Copyright © 2018 Tortuga Power. All rights reserved.
//

import UIKit
import MediaPlayer

class CarPlayContentManager: NSObject, MPPlayableContentDelegate, MPPlayableContentDataSource {
    
    static var shared = CarPlayContentManager()
    
    private override init() {
        
    }
    
    func numberOfChildItems(at indexPath: IndexPath) -> Int {
        
        // Return Number of Tabs
        if indexPath.count == 0 {
            return 2
        }
        
        // Return Tab Counts
        if indexPath.count == 1 {
            if indexPath.first == 0 { return getBooks().count }
            
            if indexPath.first == 1 { return getPlaylists().count }
        }
        
        // Playlist Selected
        if indexPath.count == 2 {
            let playlist = getPlaylists()[indexPath[1]]
            return playlist.getBooks(from: 0).count
        }
        
        return 0
    }
    
    func contentItem(at indexPath: IndexPath) -> MPContentItem? {
        
        if indexPath.indices.count == 1 {
            
            if indexPath[0] == 0 {
                return createTabItem(title: "Library", identifier: "\(indexPath[0])")
            } else if indexPath[0] == 1 {
                return createTabItem(title: "Playlists", identifier: "\(indexPath[0])")
            }
            return nil
        }
        
        // Library Book
        if indexPath.count == 2 && indexPath[0] == 0 {
            let book = getBooks()[indexPath[1]]
            return createContentItem(book: book)
        }
        
        // Playlist
        if indexPath.count == 2 && indexPath[0] == 1 {
            let playlist = getPlaylists()[indexPath[1]]
            return createContentItem(playlist: playlist)
        }
        
        // Playlist Book
        if indexPath.count == 3 && indexPath[0] == 1 {
            let playlist = getPlaylists()[indexPath[1]]
            let book = playlist.getBook(at: indexPath[2])!
            return createContentItem(book: book)
        }
        
        return nil
    }
    
    func playableContentManager(_ contentManager: MPPlayableContentManager, initiatePlaybackOfContentItemAt indexPath: IndexPath, completionHandler: @escaping (Error?) -> Void) {
        
        // Library Book
        if indexPath.count == 2 && indexPath[0] == 0 {
            let book = getBooks()[indexPath[1]]
            playBook(book: book)
            completionHandler(nil)
            return
        }
        
        // Playlist Book
        if indexPath.count == 3 && indexPath[0] == 1 {
            let playlist = getPlaylists()[indexPath[1]]
            let book = playlist.getBook(at: indexPath[2])!
            playBook(book: book)
            completionHandler(nil)
            return
        }
        
        // TODO: Error handling
        completionHandler(nil)
    }
    
//    playableContentManager(_ contentManager: MPPlayableContentManager, initiatePlaybackOfContentItemAt indexPath: IndexPath, completionHandler: @escaping (Error?) -> Swift.Void)
//
//    func playableContentManager(_ contentManager: MPPlayableContentManager, didUpdate context: MPPlayableContentManagerContext) {
//        let contentLimitsEnforced = context.contentLimitsEnforced
//        if contentLimitsEnforced {
//
//            let contentLimitItemCount = context.enforcedContentItemsCount
//            let contentLimitTreeDepth = context.enforcedContentTreeDepth
//        } else {
//
//        }
//    }
}

// Playback Helper
extension CarPlayContentManager {
    func playBook(book: Book) {
        // Replace player with new one
        PlayerManager.shared.load([book]) { (loaded) in
            PlayerManager.shared.playPause()
        }
    }
}


// MPContentItem Helpers
extension CarPlayContentManager {
    private func createContentItem(playlist:Playlist) -> MPContentItem {
        return createContentItem(title: playlist.title, identifier: playlist.identifier, isContainer: true, artwork: playlist.artwork)
    }
    
    private func createContentItem(book:Book) -> MPContentItem {
        return createContentItem(title: book.title, subtitle: book.author, identifier: book.identifier, isPlayable: true, artwork: book.artwork)
    }
    
    private func createContentItem(title:String, subtitle:String? = nil, identifier:String, isContainer:Bool = false, isPlayable:Bool = false, artwork: UIImage? = nil) -> MPContentItem {
        let item = MPContentItem(identifier: identifier)
        item.isContainer = isContainer
        item.isPlayable = isPlayable
        item.title = title
//        item.playbackProgress = 0.9
        item.subtitle = subtitle
        if let artwork = artwork {
            item.artwork = MPMediaItemArtwork(boundsSize: artwork.size, requestHandler: { (size) -> UIImage in
                return artwork
            })
        }
        return item
    }
    
    private func createTabItem(title:String, identifier:String) -> MPContentItem {
        return createContentItem(title: title, identifier: identifier, isContainer: true, artwork: nil)
    }
}

// Data Retrieval
extension CarPlayContentManager {
    private func getBooks() -> [Book] {
        let library = DataManager.getLibrary()
        guard let items = library.items?.array as? [LibraryItem] else {return []}
        let playlist = items.filter { (item) -> Bool in
            return item is Book
        }
        return playlist as! [Book]
    }
    
    private func getPlaylists() -> [Playlist] {
        let library = DataManager.getLibrary()
        guard let items = library.items?.array as? [LibraryItem] else {return []}
        let playlist = items.filter { (item) -> Bool in
            return item is Playlist
        }
        return playlist as! [Playlist]
    }
}

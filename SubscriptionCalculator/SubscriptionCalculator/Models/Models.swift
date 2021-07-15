//
//  Models.swift
//  SubscriptionCalculator
//
//  Created by Joey Hwang on 12/15/19.
//  Copyright © 2019 Joey Hwang. All rights reserved.
//

import Foundation


struct Keys {
    static let name = "name"
    static let price = "price"
    static let startDate = "startDate"
    static let cycle = "cycle"
    static let picture = "picture"
    static let type = "type"
    static let monthsFree = "monthsFree"
    static let endDate = "endDate"
    static let month = "Month"
    static let week = "Week"
    static let year = "Year"
    static let timePeriod = "timePeriod"
}


class Subscriptions {
    var name: String
    var icon: String
    var type: String
    
    init (name: String, icon: String, type: String) {
        self.name = name
        self.icon = icon
        self.type = type
        
    }
}

class Genre {
    let name: String
    let subscriptions: [Subscriptions]
    
    init(name: String, subscriptions: [Subscriptions]) {
        self.name = name
        self.subscriptions = subscriptions
    }
    
}
let catalog = Catalog()
class Catalog {

    var genres: [Genre]
    
    init() {
        //music
        let spotify = Subscriptions(name: Subs.spotify, icon: "spotify", type: Type.music)
        let appleMusic = Subscriptions(name: Subs.appleMusic, icon: "appleMusic", type: Type.music)
        let pandora = Subscriptions(name: Subs.pandora, icon: "pandora", type: Type.music)
        let youtubeMusic = Subscriptions(name: Subs.youtubeMusic, icon: "youtubeMusic", type: Type.music)
        let googlePlayMusic = Subscriptions(name: Subs.googlePlayMusic, icon: "googlePlayMusic", type: Type.music)
        let music = Genre(name: Type.music, subscriptions: [appleMusic, googlePlayMusic ,pandora, spotify,youtubeMusic])

        
        //streaming
        let netflix = Subscriptions(name: Subs.netflix, icon: "netflix", type: Type.streaming)
        let hulu = Subscriptions(name: Subs.hulu, icon: "hulu", type: Type.streaming)
        let crunchyroll = Subscriptions(name: Subs.crunchyRoll, icon: "crunchyRoll", type: Type.streaming)
        let disneyplus = Subscriptions(name: Subs.disneyPlus, icon: "disneyPlus", type: Type.streaming)
        let hboNow = Subscriptions(name: Subs.hboNow,icon: "hboNow", type: Type.streaming)
        let twitchPrime = Subscriptions(name: Subs.twitchPrime, icon: "twitchPrime", type: Type.streaming)
        let streaming = Genre(name: Type.streaming, subscriptions: [crunchyroll, disneyplus, hboNow, hulu, netflix, twitchPrime])
        
        //games
        let appleArcade = Subscriptions(name: Subs.appleArcade, icon: "appleArcade", type: Type.games)
        let nintendoSwitch = Subscriptions(name: Subs.nintendoSwitch, icon: "nintendoSwitch", type: Type.games)
        let playstationPlus = Subscriptions(name: Subs.playstationPlus, icon: "playstationPlus", type: Type.games)
        let xboxGamePass = Subscriptions(name: Subs.xboxGamePass, icon: "xboxGamePass", type: Type.games)
        let xboxLive = Subscriptions(name: Subs.xboxLive , icon: "xboxLive", type: Type.games)
        let games = Genre(name: Type.games, subscriptions: [appleArcade, nintendoSwitch, playstationPlus, xboxLive, xboxGamePass])
        
        //web services
        let amazonWebServices = Subscriptions(name: Subs.amazonWebServices, icon: "aws", type: Type.webServices)
        let googleOne = Subscriptions(name: Subs.googleOne, icon: "googleOne", type: Type.webServices)
        let adobeCreativeCloud = Subscriptions(name: Subs.adobeCreativeCloud, icon: "adobeCreativeCloud", type: Type.webServices)
        let icloudDrive = Subscriptions(name: Subs.icloudDrive, icon: "icloudDrive", type: Type.webServices)
        let office365 = Subscriptions(name: Subs.office365, icon: "office365", type: Type.webServices)
        let oneDrive = Subscriptions(name: Subs.oneDrive, icon: "oneDrive", type: Type.webServices)
        let webServices = Genre(name: Type.webServices, subscriptions: [adobeCreativeCloud, amazonWebServices,googleOne, icloudDrive, office365, oneDrive])
        

        //other
        let amazonPrime = Subscriptions(name: Subs.amazonPrime, icon: "amazonPrime", type: Type.other)
        let blueApron = Subscriptions(name: Subs.blueApron, icon: "blueApron", type: Type.other)
        let chegg = Subscriptions(name: Subs.chegg, icon: "chegg", type: Type.other)
        let patreon = Subscriptions(name: Subs.patreon, icon: "patreon", type: Type.other)
        
        let other = Genre(name: Type.other, subscriptions: [amazonPrime, blueApron , chegg, patreon])
        
        genres = [games,music, streaming, webServices, other]
    }
    
    
}

struct Type {
    static let webServices = "Web"
    static let games = "Games"
    static let streaming = "Streaming"
    static let dating = "Dating"
    static let music = "Music"
    static let other = "Other"
}


struct Subs {
    //music
    static let spotify = "Spotify"
    static let appleMusic = "Apple Music"
    static let pandora = "Pandora"
    static let youtubeMusic = "Youtube Music"
    static let googlePlayMusic = "Google Play Music"
    
    //streaming
    static let netflix = "Netflix"
    static let hulu = "Hulu"
    static let crunchyRoll = "Crunchyroll"
    static let disneyPlus = "Disney Plus"
    static let hboNow = "HBO Now"
    static let twitchPrime = "Twitch Prime"
    
    // games
    static let appleArcade = "Apple Arcade"
    static let nintendoSwitch = "Nintendo Switch Online"
    static let playstationPlus = "Playstation Plus"
    static let xboxGamePass = "Xbox Game Pass"
    static let xboxLive = "Xbox Live"
    
    //web services
    static let amazonWebServices = "Amazon Web Services"
    static let googleOne = "Google One"
    static let adobeCreativeCloud = "Adobe Creative Cloud"
    static let icloudDrive = "iCloud Drive"
    static let office365 = "Office 365"
    static let oneDrive = "One Drive"
 
    //other
    static let amazonPrime = "Amazon Prime"
    static let blueApron = "Blue Apron"
    static let chegg = "Chegg"
    static let patreon = "Patreon"
}



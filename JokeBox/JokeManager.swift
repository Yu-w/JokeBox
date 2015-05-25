//
//  JokeManager.swift
//  JokeBox
//
//  Created by Wang Yu on 5/24/15.
//  Copyright (c) 2015 Yu Wang. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import MWFeedParser

protocol JokeManagerDelegate: class {
    func gotOneRandomJoke(joke: Joke)
    func gotManyRandomJokes(jokes: [Joke])
}

struct Joke {
    var content: String
    
    init() {
        content = ""
    }
    init(sentence: NSString) {
        content = String(sentence)
    }
}

class JokeManager: NSObject {

    weak var delegate: JokeManagerDelegate?
    
    func getOneRandomJoke() {
        let url = "http://api.icndb.com/jokes/random"
        var joke = Joke()
        var req = Alamofire.request(.GET, url).responseJSON { (_, response, JSON, error) in
            if error == nil && JSON != nil {
                let data = SwiftyJSON.JSON(JSON!)
                var jokeContent: NSString = data["value"]["joke"].string!.stringByDecodingHTMLEntities()
                joke = Joke(sentence: jokeContent)
                self.delegate?.gotOneRandomJoke(joke)
            }
        }
    }
    
    func getManyRandomJoke() {
        let numberOfJoke: Int = 30
        let url = "http://api.icndb.com/jokes/random/\(numberOfJoke)"
        var jokes = [Joke]()
        var req = Alamofire.request(.GET, url).responseJSON { (_, response, JSON, error) in
            if error == nil && JSON != nil {
                let data = SwiftyJSON.JSON(JSON!)
                for var i = 0; i < numberOfJoke; i++ {
                    var jokeContent: NSString = data["value"][i]["joke"].string!.stringByDecodingHTMLEntities()
                    let joke = Joke(sentence: jokeContent)
                    jokes.append(joke)
                }
                self.delegate?.gotManyRandomJokes(jokes)
            }
        }
    }
}

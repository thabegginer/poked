//
//  ViewController.swift
//  pokedex-by-devslops
//
//  Created by Angels on 21/01/16.
//  Copyright © 2016 Angels. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    @IBOutlet weak var collection: UICollectionView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var pokemon = [Pokemon]()
    var filteredPokemon = [Pokemon]()
    var music: AVAudioPlayer!
    var inSearchMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
            collection.delegate = self
            collection.dataSource = self
            searchBar.delegate = self
            searchBar.returnKeyType = UIReturnKeyType.Done
        
            initAudio()
            parsePokemonCSV()
        }
    
    func initAudio() {
        
        
        do {
            
            try music = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("music", ofType: "mp3")!))
            
            music.prepareToPlay()
            music.numberOfLoops = -1
            music.play()
            
        } catch let err as NSError {
            print(err.debugDescription)
        }
        
        
    }


    
    func parsePokemonCSV() {
        let path = NSBundle.mainBundle().pathForResource("pokemon", ofType: "csv")!
        
        do {
            let csv = try CSV(contentsOfURL: path)
            let rows = csv.rows
            
            for row in rows {
                let pokeId = Int(row["id"]!)!
                let name = row["identifier"]!
                let pokie = Pokemon(name: name, pokedexId: pokeId)
                pokemon.append(pokie)
            }
            
        } catch let err as NSError {
                print(err.debugDescription)
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PokieCell", forIndexPath: indexPath) as? PokieCell {
            
            var pokie: Pokemon!
            
            if inSearchMode {
                pokie = filteredPokemon[indexPath.row]
                
            } else {
                pokie = pokemon[indexPath.row]
            }
            
            cell.configureCell(pokie)

            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var pokie: Pokemon!
        
        if inSearchMode {
            pokie = filteredPokemon[indexPath.row]
            
        } else {
            pokie = pokemon[indexPath.row]
            
        
        
        print(pokie.name)
        performSegueWithIdentifier("PokemonDetailVC", sender: pokie)
        
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if inSearchMode {
            return filteredPokemon.count
        }
        
        return pokemon.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(105, 105)
    }
    
    
    @IBAction func musicBtnPressed(sender: UIButton!) {
        if music.playing {
            music.stop()
            sender.alpha = 0.2
        } else {
            music.play()
            sender.alpha = 1.0
        }

    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            inSearchMode = false
            view.endEditing(true)
            collection.reloadData()
        } else {
            inSearchMode = true
            let lower = searchBar.text!.lowercaseString
            filteredPokemon = pokemon.filter({$0.name.rangeOfString(lower) != nil})
            collection.reloadData()
        }
    }
        override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PokemonDetailVC" {
            if let detailsVC = segue.destinationViewController as? PokemonDetailVC {
                if let pokie = sender as? Pokemon {
                    detailsVC.pokemon = pokie
                }
            }
        }
    }

}
//
//  myTeamViewController.swift
//  soccer-stats
//
//  Created by Pearl on 12/26/2560 BE.
//

import UIKit
import Foundation
import CoreData

//TODO implement search bar
class MyTeamViewController: UIViewController {

    var _playerObjects:[NSManagedObject] = [NSManagedObject]()
    
    @IBOutlet weak var _player1Button: PlayerButton!
    @IBOutlet weak var _player2Button: PlayerButton!
    @IBOutlet weak var _player3Button: PlayerButton!
    @IBOutlet weak var _player4Button: PlayerButton!
    
    @IBOutlet weak var _newPlayerNumber: UIPickerView!
    @IBOutlet weak var _newPlayerPosition: UIPickerView!
    @IBOutlet weak var _newPlayerName: UITextField!
    @IBOutlet weak var _cancelNewPlayerButton: UIButton!
    @IBOutlet weak var _confirmNewPlayerButton: UIButton!
    
    @IBOutlet weak var noPlayersLabel: UILabel!
    @IBOutlet weak var _playersTableView: UITableView!
    
    let positions:[String] = ["Forward", "Midfielder", "GoalKeeper"]
    var playerButtonArray:[PlayerButton] = []
    
    override func viewDidLoad() {
        
        _playerObjects = CoreDataHelper.init().fetch()
        if _playerObjects.count == 0 {
            noPlayersLabel.isHidden = false
        } else {
            noPlayersLabel.isHidden = true
        }
        
        _player1Button.number = 0
        _player2Button.number = 1
        _player3Button.number = 2
        _player4Button.number = 3
        
        if ActiveTeam.sharedInstance.activeTeam.count > 0 {
            _player1Button.player = ActiveTeam.sharedInstance.activeTeam[0]
            if ActiveTeam.sharedInstance.activeTeam.count > 1 {
                _player2Button.player = ActiveTeam.sharedInstance.activeTeam[1]
                if ActiveTeam.sharedInstance.activeTeam.count > 2 {
                    _player3Button.player = ActiveTeam.sharedInstance.activeTeam[2]
                    if ActiveTeam.sharedInstance.activeTeam.count > 3 {
                        _player4Button.player = ActiveTeam.sharedInstance.activeTeam[3]
                    }
                }
            }
        }
        
        playerButtonArray.append(_player1Button)
        playerButtonArray.append(_player2Button)
        playerButtonArray.append(_player3Button)
        playerButtonArray.append(_player4Button)
        for playerButton in playerButtonArray {
            playerButton.addTarget(self, action: #selector(didSelectPlayerButton(_:)), for: .touchUpInside)
        }
    }
    
    @IBAction func addPlayer(_ sender: Any) {
        hideNewPlayer(hide:false)
        noPlayersLabel.isHidden = true
    }
    
    @IBAction func deletePlayer(_ sender: Any) {
        _playersTableView.isEditing ? _playersTableView.setEditing(false, animated: false) : _playersTableView.setEditing(true, animated: false)
    }
    

    @IBAction func confirmNewPlayer(_ sender: Any) {
        if let name = _newPlayerName.text {
            if let index = name.index(of: " ") {
                let firstName:String = String(name[..<index])
                let lastName:String = String(name[index...])
                let position:String = positions[_newPlayerPosition.selectedRow(inComponent: 0)]
                let number:Int = _newPlayerNumber.selectedRow(inComponent: 0) + 1
                
                CoreDataHelper.init().save(first: firstName, last: lastName, position: position, number: number)
                _playerObjects = CoreDataHelper.init().fetch()
                _playersTableView.reloadData()
                
                hideNewPlayer(hide:true)
                
                //TODO: dispatch reload, improve efficiency of fetching
                return
            }
        }
         //you may have messed something up here
            let alert = UIAlertController(title: "Alert", message: "Please enter a first and last name for the new player", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func cancelNewPlayer(_ sender: Any) {
        hideNewPlayer(hide:true)
        _newPlayerNumber.selectRow(0, inComponent: 0, animated: false)
        _newPlayerPosition.selectRow(0, inComponent: 0, animated: false)
        _newPlayerName.text = nil
    }
    
    
    
    @objc func didSelectPlayerButton(_ playerButton: PlayerButton) {
        if playerButton.player != nil {
            playerButton.player = nil
            ActiveTeam.sharedInstance.activeTeam.remove(at: playerButton.number!)

            let numberToMoveDown:Int = ActiveTeam.sharedInstance.activeTeam.count - playerButton.number!
            var indexOfPlayerButton:Int = 0
            for i in 0...3 {
                if playerButtonArray[i] == playerButton {
                    indexOfPlayerButton = i
                }
            }
            if numberToMoveDown >= 1 {
                let endIndex:Int = indexOfPlayerButton + numberToMoveDown - 1
                for i in indexOfPlayerButton...endIndex {
                    playerButtonArray[i].player = playerButtonArray[i+1].player
                    playerButtonArray[i].setNeedsDisplay()
                }
                for i in endIndex+1...3 {
                    playerButtonArray[i].player = nil
                    playerButtonArray[i].setNeedsDisplay()
                }
            } else {
                playerButtonArray[indexOfPlayerButton].player = nil;
                playerButtonArray[indexOfPlayerButton].setNeedsDisplay()
            }
        }
    }
    
    func hideNewPlayer(hide:Bool) {
        _newPlayerName.isHidden = hide
        _newPlayerName.text = nil
        _newPlayerPosition.isHidden = hide
        _newPlayerNumber.isHidden = hide
        _confirmNewPlayerButton.isHidden = hide
        _cancelNewPlayerButton.isHidden = hide
        
        if !hide {
            _newPlayerName.becomeFirstResponder()
        }
    }
}

//TDOO: stop the highlighting
extension MyTeamViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return _playerObjects.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view:UIView = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:PlayerCell = tableView.dequeueReusableCell(withIdentifier: "playerCell") as! PlayerCell
        
            let player:NSManagedObject = _playerObjects[indexPath.section]
            cell.player = player
            if let numLabel:UILabel = cell.viewWithTag(1) as? UILabel {
                let number:Int = player.value(forKey: "number") as? Int ?? 0
                numLabel.text = "\(number)"
            }
            if let positionLabel:UILabel = cell.viewWithTag(2) as? UILabel {
                positionLabel.text = player.value(forKey: "position") as? String
            }
            if let nameLabel:UILabel = cell.viewWithTag(3) as? UILabel {
                let firstName:String = player.value(forKey: "firstName") as? String ?? ""
                let lastName:String = player.value(forKey: "lastName") as? String ?? ""
                nameLabel.text = lastName + " " + firstName
            }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let playerCell:PlayerCell = tableView.cellForRow(at: indexPath) as! PlayerCell
            let player:NSManagedObject = playerCell.player!
            if let playerButton = _player1Button.player {
                if playerButton == player {
                    didSelectPlayerButton(_player1Button)
                }
            } else if let playerButton = _player2Button.player {
                if playerButton == player {
                    didSelectPlayerButton(_player2Button)
                }
            } else if let playerButton = _player3Button.player {
                if playerButton == player {
                    didSelectPlayerButton(_player3Button)
                }
            } else if let playerButton = _player4Button.player {
                if playerButton == player {
                    didSelectPlayerButton(_player4Button)
                }
            }
            let objectID:NSManagedObjectID = player.objectID
            CoreDataHelper.init().delete(ID: objectID)
            _playerObjects.remove(at: indexPath.section)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ActiveTeam.sharedInstance.activeTeam.count == 0 {
            let playerCell:PlayerCell = tableView.cellForRow(at: indexPath) as! PlayerCell
            _player1Button.player = playerCell.player
            _player1Button.setNeedsDisplay()
            ActiveTeam.sharedInstance.activeTeam.append(playerCell.player!)
        } else if ActiveTeam.sharedInstance.activeTeam.count == 1 {
            let playerCell:PlayerCell = tableView.cellForRow(at: indexPath) as! PlayerCell
            _player2Button.player = playerCell.player
            _player2Button.setNeedsDisplay()
            ActiveTeam.sharedInstance.activeTeam.append(playerCell.player!)
        } else if ActiveTeam.sharedInstance.activeTeam.count == 2 {
            let playerCell:PlayerCell = tableView.cellForRow(at: indexPath) as! PlayerCell
            _player3Button.player = playerCell.player
            _player3Button.setNeedsDisplay()
            ActiveTeam.sharedInstance.activeTeam.append(playerCell.player!)
        } else if ActiveTeam.sharedInstance.activeTeam.count == 3 {
            let playerCell:PlayerCell = tableView.cellForRow(at: indexPath) as! PlayerCell
            _player4Button.player = playerCell.player
            _player4Button.setNeedsDisplay()
            ActiveTeam.sharedInstance.activeTeam.append(playerCell.player!)
        }
    }
    
}

extension MyTeamViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return 99
        } else if pickerView.tag == 2 {
            return positions.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return String(row + 1)
        } else if pickerView.tag == 2 {
            return positions[row]
        }
        return ""
    }
}

//
//  ViewController.swift
//  Project5
//
//  Created by Valeriy Kovalevskiy on 3/16/20.
//  Copyright © 2020 v.kovalevskiy. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    //MARK: - Properties
    var allWords = [String]()
    var usedWords = [String]()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItems()
        loadDataFromBundle()
        startGame()
    }


    //MARK: - Objc methods
    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    //MARK: - Private methods
    private func setupNavigationItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
    }
    
    private func loadDataFromBundle() {
        guard let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") else { return }
        guard let startWords = try? String(contentsOf: startWordsURL) else { return allWords = ["empty"] }
        
        allWords = startWords.components(separatedBy: "\n")
    }

    
    private func submit(_ answer: String) {
        
        func showErrorAlert(title: String, message: String) {
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }

        let answer = answer.lowercased()
        
        guard let title = title?.lowercased() else { return }
        guard isPossible(answer) else { return showErrorAlert(title: "Word not possible", message: "You can't spell that word from \(title.lowercased())") }
        guard isOriginal(answer) else { return showErrorAlert(title: "Word already used", message: "Be more original") }
        guard isReal(answer) else { return showErrorAlert(title: "Word not recognized", message: "You can't just make them up, you know") }
        guard isLongerThanThree(answer) else { return showErrorAlert(title: "Stop cheating", message: "Word should be longer than 3 symbols and not equal the current word")}
        
        usedWords.insert(answer, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    private func isPossible(_ word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        for letter in word {
            guard let position = tempWord.firstIndex(of: letter) else { return false }
            
            tempWord.remove(at: position)
        }
        return true
    }
    
    private func isOriginal(_ word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    private func isReal(_ word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    private func isLongerThanThree(_ word: String) -> Bool {
        word.count >= 3 && word != title
    }
}

//MARK: - TableView delegate/datasource methods
extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        
        return cell
    }
}

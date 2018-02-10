//
//  ViewController.swift
//  FBLA2018
//
//  Created by Patrick Li on 2/9/18.
//  Copyright © 2018 Dali Labs, Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class User {
    var schoolID: String = ""
    var name: String = ""
    var books: [Book] = []

    init(schoolID: String, name: String, books: [Book]){
        self.schoolID = schoolID
        self.name = name
        self.books = books
    }
}

class Book{
    var name: String = ""
    var author: String = ""
    var checkedout: Int = 0
    var reserved: Int = 0
    var bookID: String = ""
    var count: Int = 0

    init(name: String, author: String, checkedout: Int, reserved: Int, bookID: String, count: Int){
        self.name = name
        self.author = author
        self.checkedout = checkedout
        self.reserved = reserved
        self.bookID = bookID
        self.count = count
    }
}

class ViewController: UIViewController {
    var ref: DatabaseReference!
    var library: [Book] = [Book(name: "The Great Gatsby", author: "Fitzgerald", checkedout: 0, reserved: 0, bookID: "240082", count: 10),
        Book(name: "Hai", author: "MUX", checkedout: 0, reserved: 0, bookID: "123423", count: 10),
        Book(name: "YOOO", author: "WEX", checkedout: 0, reserved: 0, bookID: "145345", count: 10),
        Book(name: "WATUP", author: "WEX", checkedout: 0, reserved: 0, bookID: "234534", count: 10),
    ]


    override func viewDidLoad() {
        super.viewDidLoad()
        //setup library
        setupLibrary(books: library)

        //setup user
        let myUser = User(schoolID: "123456", name: "Johnny Appleseed", books: [])
        self.ref.child("users").child(myUser.schoolID).child("name").setValue(myUser.name)


        //test checkout
        checkout(user: myUser, checkedoutBook: library[2])


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupLibrary(books: [Book]){
        ref = Database.database().reference()

        for book in books {
            self.ref.child("library").child(book.bookID).child("name").setValue(book.name) //setValue(["name": books[1].name])
            self.ref.child("library").child(book.bookID).child("author").setValue(book.author)//setValue(["author": books[1].author])
            self.ref.child("library").child(book.bookID).child("checkedout").setValue(book.checkedout)//setValue(["checkedout": String(books[1].checkedout)])
            self.ref.child("library").child(book.bookID).child("reserved").setValue(String(book.reserved))//setValue(["reserved": String(books[1].reserved)])
            self.ref.child("library").child(book.bookID).child("count").setValue(book.count)//setValue(["count": String(books[1].count)])
        }
    }

    //adds book to user book list and updates library
    func checkout(user: User, checkedoutBook: Book){
        user.books.append(checkedoutBook)

        ref = Database.database().reference()
        let schoolID = user.schoolID


        //adding book to user book list
        self.ref.child("users").child(schoolID).child("books").child(checkedoutBook.bookID).child("name").setValue(checkedoutBook.name)//setValue(["name":checkedoutBook.name])
        self.ref.child("users").child(schoolID).child("books").child(checkedoutBook.bookID).child("author").setValue(checkedoutBook.author)//setValue(["author":checkedoutBook.author])
        self.ref.child("users").child(schoolID).child("books").child(checkedoutBook.bookID).child("checkedout").setValue("true")//setValue(["checkedout":"true"])
        self.ref.child("users").child(schoolID).child("books").child(checkedoutBook.bookID).child("reserved").setValue("false")//setValue(["reserved":"false"])


        //retreving library info
        ref.child("library").child(String(checkedoutBook.bookID)).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary


            var checkedout = ""
            if let val = value?["checkedout"] as? Int {
                checkedout = String(val + 1)
            }
            else{
                print("error not integer")
            }

            var count = ""
            if let val = value?["count"] as? Int {
                count = String(val - 1)
            }
            else{
                print("error not integer")
            }

            //updating the library book count
            self.ref.child("library").child(String(checkedoutBook.bookID)).child("checkedout").setValue(checkedout) //setValue(["checkedout": checkedout])
            self.ref.child("library").child(String(checkedoutBook.bookID)).child("count").setValue(count) //setValue(["count": count])

        }) { (error) in
            print(error.localizedDescription)
        }



    }

    func reserve(){

    }


}


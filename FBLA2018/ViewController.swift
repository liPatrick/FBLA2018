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

    //for user
    var userCheckedout = false
    var userReserved = false

    init(name: String, author: String, checkedout: Int, reserved: Int, bookID: String, count: Int){
        self.name = name
        self.author = author
        self.checkedout = checkedout
        self.reserved = reserved
        self.bookID = bookID
        self.count = count
    }
    init(name: String, author: String, bookID: String, userCheckedout: Bool, userReserved: Bool){
        self.name = name
        self.author = author
        self.bookID = bookID
        self.userCheckedout = userCheckedout
        self.userReserved = userReserved
    }
}

class ViewController: UIViewController {
    var ref: DatabaseReference!
    var library: [Book] = [Book(name: "The Great Gatsby", author: "Fitzgerald", checkedout: 0, reserved: 0, bookID: "240082", count: 10),
        Book(name: "Hai", author: "MUX", checkedout: 0, reserved: 0, bookID: "123423", count: 10),
        Book(name: "YOOO", author: "WEX", checkedout: 0, reserved: 0, bookID: "145345", count: 10),
        Book(name: "WATUP", author: "WEX", checkedout: 0, reserved: 0, bookID: "234534", count: 10),
    ]
    var loadedBooks: [Book] = []
    var loadedUserBookIDs: [Book] = []

    @IBOutlet weak var sampleImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()

        //setup library
        //setupLibrary(books: library)

        //setup user
        //let myUser = User(schoolID: "123456", name: "Johnny Appleseed", books: [])
        //self.ref.child("users").child(myUser.schoolID).child("name").setValue(myUser.name)


        //test checkout
        //checkout(user: myUser, checkedoutBook: library[2])

        //test read
        //readLibrary()

        //test readUserBookIDs
        //self.readUserBookIDs(user: myUser)

        //test returnCheckout
        //self.returnCheckedout(user: myUser, returnBookID: library[2].bookID)

        //test readUserBook
        //self.readUserBooks(user: myUser)

        //test reserve
        //self.reserve(user: myUser, reservedBook: library[3])

        //test cancel reserved
        //self.cancelReserved(user: myUser, reservedBookID: library[3].bookID)

        //test reserve to checkedout
        //self.reservedToCheckedout(user: myUser, reservedBookID: library[3].bookID)

        //testing image upload
        /*var image = UIImage(named: "coverimage")

        Image.uploadImage(image: self.scaleDownImage(image: image!), completion: {downloadURL in
            print(downloadURL)
        })*/

        //testing image download
        /*Image.downloadImage(imageurl: "bookCover/nlzsJt8ymJ.png", completion: { data in
            print("here")
            self.sampleImage.image = data
        })*/




    }

    func scaleDownImage(image: UIImage) -> UIImage{
        var actualHeight: CGFloat = image.size.height
        var actualWidth: CGFloat = image.size.width
        let maxHeight: CGFloat = 700
        let maxWidth: CGFloat = 700
        var imgRatio: CGFloat = actualWidth/actualHeight
        let maxRatio: CGFloat = maxWidth/maxHeight
        let compressionQuality: CGFloat = 0.5

        if (actualHeight > maxHeight || actualWidth > maxWidth)
        {
            if(imgRatio < maxRatio)
            {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight;
            }
            else if(imgRatio > maxRatio)
            {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth;
            }
            else
            {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        
        
        let rect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = UIImageJPEGRepresentation(img!, compressionQuality)
        UIGraphicsEndImageContext()

        //return [UIImage imageWithData:imageData]
        return UIImage(data: imageData!)!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func setupLibrary(books: [Book]){

        for book in books {
            self.ref.child("library").child(book.bookID).child("name").setValue(book.name) //setValue(["name": books[1].name])
            self.ref.child("library").child(book.bookID).child("author").setValue(book.author)//setValue(["author": books[1].author])
            self.ref.child("library").child(book.bookID).child("checkedout").setValue(book.checkedout)//setValue(["checkedout": String(books[1].checkedout)])
            self.ref.child("library").child(book.bookID).child("reserved").setValue(book.reserved)//setValue(["reserved": String(books[1].reserved)])
            self.ref.child("library").child(book.bookID).child("count").setValue(book.count)//setValue(["count": String(books[1].count)])
        }
    }

    func readUserBooks(user: User){
        ref.child("users").child(user.schoolID).child("books").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let values = snapshot.value as? NSDictionary
            //print(values)
            for (key, val) in values! {
                let dict = val as! NSDictionary
                let bookid = key as! String
                let author = dict["author"] as! String
                let checkedout = dict["checkedout"] as! Bool
                let name = dict["name"] as! String
                let reserved = dict["reserved"] as! Bool
                print(bookid)
                print(author)
                print(checkedout)
                print(name)
                print(reserved)

                var book = Book(name: name, author: author, bookID: key as! String, userCheckedout: checkedout, userReserved: reserved)
                self.loadedUserBookIDs.append(book)
            }

        }) { (error) in
            print(error.localizedDescription)
        }
    }

    func readLibrary(){
        ref.child("library").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let values = snapshot.value as? NSDictionary
            for (key, val) in values! {
                let dict = val as! NSDictionary
                let name = dict["name"] as! String
                let author = dict["author"] as! String
                let checkedout = dict["checkedout"] as! Int
                let count = dict["count"] as! Int
                let reserved = dict["reserved"] as! Int

                var book = Book(name: name, author: author, checkedout: checkedout, reserved: reserved, bookID: key as! String, count: count)
                self.loadedBooks.append(book)
            }

        }) { (error) in
            print(error.localizedDescription)
        }

    }

    //adds book to user book list and updates library
    //have to check if user already has checked out the book, if it does don't call this function
    func checkout(user: User, checkedoutBook: Book){
        user.books.append(checkedoutBook)

        ref = Database.database().reference()
        let schoolID = user.schoolID


        //adding book to user book list
        self.ref.child("users").child(schoolID).child("books").child(checkedoutBook.bookID).child("name").setValue(checkedoutBook.name)//setValue(["name":checkedoutBook.name])
        self.ref.child("users").child(schoolID).child("books").child(checkedoutBook.bookID).child("author").setValue(checkedoutBook.author)//setValue(["author":checkedoutBook.author])
        self.ref.child("users").child(schoolID).child("books").child(checkedoutBook.bookID).child("checkedout").setValue(true)//setValue(["checkedout":"true"])
        self.ref.child("users").child(schoolID).child("books").child(checkedoutBook.bookID).child("reserved").setValue(false)//setValue(["reserved":"false"])


        //retreving library info
        ref.child("library").child(String(checkedoutBook.bookID)).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary


            var checkedout = 0
            if let val = value?["checkedout"] as? Int {
                checkedout = val + 1
            }
            else{
                print("error not integer")
            }

            var count = 0
            if let val = value?["count"] as? Int {
                count = val - 1
            }
            else{
                print("error not integer")
            }

            //updating the library book count
            self.ref.child("library").child(String(checkedoutBook.bookID)).child("checkedout").setValue(checkedout)
            self.ref.child("library").child(String(checkedoutBook.bookID)).child("count").setValue(count)

        }) { (error) in
            print(error.localizedDescription)
        }



    }

    //returns the book to the library, and removes the book from user's list of checkouted books
    func returnCheckedout(user: User, returnBookID: String){

        //remove book locally
        for index in 0..<user.books.count{
            if user.books[index].bookID == returnBookID {
                user.books.remove(at: index)
            }
        }

        self.ref.child("users").child(user.schoolID).child("books").child(returnBookID).removeValue()

        ref.child("library").child(returnBookID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary


            var checkedout = 0
            if let val = value?["checkedout"] as? Int {
                print(val)
                print("here")
                checkedout = val - 1
            }
            else{
                print("error not integer")
            }

            var count = 0
            if let val = value?["count"] as? Int {
                count = val + 1
            }
            else{
                print("error not integer")
            }

            //updating the library book count
            self.ref.child("library").child(returnBookID).child("checkedout").setValue(checkedout)
            self.ref.child("library").child(returnBookID).child("count").setValue(count)


        }) { (error) in
            print(error.localizedDescription)
        }

    }

    //adds book to user book list and updates library
    //have to check if user already has reserved the book, if it does don't call this function
    func reserve(user: User, reservedBook: Book){
        user.books.append(reservedBook)

        ref = Database.database().reference()
        let schoolID = user.schoolID


        //adding book to user book list
        self.ref.child("users").child(schoolID).child("books").child(reservedBook.bookID).child("name").setValue(reservedBook.name)//setValue(["name":checkedoutBook.name])
        self.ref.child("users").child(schoolID).child("books").child(reservedBook.bookID).child("author").setValue(reservedBook.author)//setValue(["author":checkedoutBook.author])
        self.ref.child("users").child(schoolID).child("books").child(reservedBook.bookID).child("checkedout").setValue(false)//setValue(["checkedout":"true"])
        self.ref.child("users").child(schoolID).child("books").child(reservedBook.bookID).child("reserved").setValue(true)//setValue(["reserved":"false"])


        //retreving library info
        ref.child("library").child(String(reservedBook.bookID)).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary


            var reserved = 0
            if let val = value?["reserved"] as? Int {
                reserved = val + 1
            }
            else{
                print("error not integer")
            }

            var count = 0
            if let val = value?["count"] as? Int {
                count = val - 1
            }
            else{
                print("error not integer")
            }

            //updating the library book count
            self.ref.child("library").child(String(reservedBook.bookID)).child("reserved").setValue(reserved)
            self.ref.child("library").child(String(reservedBook.bookID)).child("count").setValue(count)

        }) { (error) in
            print(error.localizedDescription)
        }
    }

    //cancel a reserved book. Remove book from user book list and also update library
    func cancelReserved(user: User, reservedBookID: String){
        //remove book locally
        for index in 0..<user.books.count {
            if user.books[index].bookID == reservedBookID {
                user.books.remove(at: index)
            }
        }

        self.ref.child("users").child(user.schoolID).child("books").child(reservedBookID).removeValue()

        ref.child("library").child(reservedBookID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary


            var reserved = 0
            if let val = value?["reserved"] as? Int {
                reserved = val - 1
            }
            else{
                print("error not integer")
            }

            var count = 0
            if let val = value?["count"] as? Int {
                count = val + 1
            }
            else{
                print("error not integer")
            }

            //updating the library book count
            self.ref.child("library").child(reservedBookID).child("reserved").setValue(reserved)
            self.ref.child("library").child(reservedBookID).child("count").setValue(count)


        }) { (error) in
            print(error.localizedDescription)
        }


    }


    //change a reserved book to a book that is checked out
    func reservedToCheckedout(user: User, reservedBookID: String){
        //change book locally
        for index in 0..<user.books.count {
            if user.books[index].bookID == reservedBookID {
                user.books[index].userCheckedout = true
                user.books[index].userReserved = false
            }
        }

        //update user book list remotely
        self.ref.child("users").child(user.schoolID).child("books").child(reservedBookID).child("reserved").setValue(false)
        self.ref.child("users").child(user.schoolID).child("books").child(reservedBookID).child("checkedout").setValue(true)


        ref.child("library").child(reservedBookID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary


            var reserved = 0
            if let val = value?["reserved"] as? Int {
                reserved = val - 1
            }
            else{
                print("error not integer")
            }

            var checkedout = 0
            if let val = value?["checkedout"] as? Int {
                checkedout = val + 1
            }
            else{
                print("error not integer")
            }



            //updating the library book count
            self.ref.child("library").child(reservedBookID).child("reserved").setValue(reserved)
            self.ref.child("library").child(reservedBookID).child("checkedout").setValue(checkedout)


        }) { (error) in
            print(error.localizedDescription)
        }
    }

    //checks if user already has reserved or checkedout book and returns a boolean value
    func checkIfUserHasBook(user: User, testBook: Book) -> Bool{
        var books = user.books
        var hasBook = false
        for book in books{
            if book.bookID == testBook.bookID {
                hasBook = true
            }
        }
        return hasBook
    }









}


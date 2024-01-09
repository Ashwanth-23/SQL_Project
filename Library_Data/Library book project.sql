use libaray_data;

# creating the table of tbl_publisher
create  table tbl_publisher(
publisher_PublisherName  varchar(255) primary key , publisher_PublisherAddress longtext ,publisher_PublisherPhone varchar(25)
);


# creating the table of borrower 

create table tbl_borrower(
borrower_CardNo int auto_increment primary key, borrower_BorrowerName varchar(255), 
borrower_BorrowerAddress text , borrower_BorrowerPhone char(12)
);

# creating the table of book with PK & FK

create table tbl_book( 
book_BookID int  auto_increment primary key, book_Title varchar(255), 
book_PublisherName varchar(255),
constraint fk_PublisherName 
foreign key (book_PublisherName)
references tbl_publisher(publisher_PublisherName) on update cascade on delete cascade
);

# creating Author table with PK and PK

create table tbl_book_authors(
book_authors_AuthorID  int auto_increment primary key,
book_authors_BookID int ,
book_authors_AuthorName varchar(255),
constraint fk_bookid 
foreign key (book_authors_BookID)
references tbl_book(book_BookID) on update cascade on delete cascade
);

# creating library branch table.

create table tbl_library_branch(
library_branch_BranchID int auto_increment primary key not null, library_branch_BranchName varchar(255),
library_branch_BranchAddress text
);

# creating 	book_copies table with PK and FK

create table tbl_book_copies(
book_copies_CopiesID int auto_increment primary key not null, book_copies_BookID int , 
book_copies_BranchID int , book_copies_No_Of_Copies int ,
constraint FK_bookid1
foreign key (book_copies_BookID)
references tbl_book(book_BookID) on update cascade on delete cascade,

constraint FK_brankid
foreign key (book_copies_BranchID)
references tbl_library_branch(library_branch_BranchID) on update cascade on delete cascade
);

# creating table tbl_book_loans with PK and FK

create table tbl_book_loans (
book_loans_LoansID int auto_increment primary key not null, book_loans_BookID int ,
book_loans_BranchID int, book_loans_CardNo int, book_loans_DateOut Date , book_loans_DueDate date,
constraint FK_bookid2
foreign key (book_loans_BookID)
references tbl_book(book_BookID) on update cascade on delete cascade,

constraint FK_branch2
foreign key (book_loans_BranchID)
references tbl_library_branch(library_branch_BranchID) on update cascade on delete cascade,

constraint FK_borrower1
foreign key (book_loans_CardNo)
references tbl_borrower(borrower_CardNo) on update cascade on delete cascade
);
select * from tbl_book;
select * from tbl_book_authors;
select * from tbl_book_copies;
select * from tbl_book_loans;
select * from tbl_borrower;
select * from tbl_library_branch;
select * from tbl_publisher;


 -- Task Question 
 
 -- Q1) How many copies of the book titled "The lost Tibe" are owned by the library  branch whose name is "Sharpstown" ?
 

select * from tbl_book where book_title = 'The Lost Tribe';
select * from tbl_library_branch where library_branch_branchname = "Sharpstown";
select * from tbl_book_copies where book_copies_bookid = 20;

select  tbl_book.book_title, tbl_library_branch.library_branch_branchname, 
 tbl_book_copies.book_copies_no_of_copies from tbl_book
 inner join tbl_book_copies on tbl_book.book_bookid = tbl_book_copies.book_copies_bookid
 inner join tbl_library_branch on tbl_library_branch.library_branch_branchid = tbl_book_copies.book_copies_branchid
 where tbl_library_branch.library_branch_branchname = "Sharpstown" and tbl_book.book_title = 'The Lost Tribe';

-- Q2) How many copies of the book titled "The Lost Tribe" are owned by each library branch?

select  tbl_book.book_title, tbl_library_branch.library_branch_branchname, 
 tbl_book_copies.book_copies_no_of_copies from tbl_book
 inner join tbl_book_copies on tbl_book.book_bookid = tbl_book_copies.book_copies_bookid
 inner join tbl_library_branch on tbl_library_branch.library_branch_branchid = tbl_book_copies.book_copies_branchid
 where tbl_book.book_title = 'The Lost Tribe';
 
-- Q3) Retrieve the names of all borrowers who do not have any books checked out.

select tbl_borrower.borrower_borrowername from tbl_borrower
left join  tbl_book_loans on tbl_borrower.borrower_cardno = tbl_book_loans.book_loans_cardno
left join tbl_book on tbl_book.book_bookid = tbl_book_loans.book_loans_bookid
where book_bookid is null;

-- Q4) For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, retrieve the book title, 
--    the borrower's name, and the borrower's address. 

    select b.book_title, br. borrower_borrowername , br.borrower_borroweraddress 
    from tbl_borrower as br
    inner join tbl_book_loans bl on bl.book_loans_cardno = br.borrower_cardno
    inner join  tbl_book b on bl.book_loans_bookid = b.book_bookid
    inner join tbl_library_branch lb on bl.book_loans_branchid = lb.library_branch_branchid
    where lb.library_branch_branchname = "Sharpstown" and bl.book_loans_duedate = "0002-003-18";

-- Q5) For each library branch, retrieve the branch name and the total number of books loaned out from that branch.
select lb.library_branch_branchname ,count(bl.book_loans_bookid) as totalbookslaoned
from tbl_library_branch  lb
left join tbl_book_loans bl on lb.library_branch_branchid  = bl.book_loans_branchid
group by  lb.library_branch_branchname;

-- Q6) Retrieve the names, addresses, and number of books checked out 
--     for all borrower who have more than five books checked out.
select  br.borrower_borrowername, br.borrower_borroweraddress, count(bl.book_loans_bookid)   
from tbl_borrower br
inner join tbl_book_loans bl on bl.book_loans_cardno = br.borrower_cardno
group by br.borrower_cardno
having count(bl.book_loans_bookid) >5
;

-- Q7) For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central".
select ba.book_authors_authorname, b.book_title, sum(bc.book_copies_no_of_copies) as total_no_copies, lb.library_branch_branchname
from tbl_book_authors  as ba 
inner join tbl_book b on b.book_bookid = ba.book_authors_authorid 
inner join tbl_book_copies bc on bc.book_copies_bookid =b.book_bookid
inner join tbl_library_branch lb on  lb.library_branch_branchid = bc.book_copies_branchid
where ba.book_authors_authorname ="Stephen King" and lb.library_branch_branchname ="Central"
group by b.book_bookid
;










 






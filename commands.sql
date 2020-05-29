DROP DATABASE IF EXISTS bank;

CREATE DATABASE bank;

USE bank;


CREATE TABLE users (
    id varchar(255),
    name varchar(255),
    email varchar(255),
    account_no varchar(255) UNIQUE,
    PRIMARY KEY (id)
    );
    
INSERT INTO users VALUES( "U1", "user1", "user1@gmail.com", "account1");
INSERT INTO users VALUES( "U2", "user2", "user2@gmail.com", "account2");
INSERT INTO users VALUES( "U3", "user3", "user3@gmail.com", "account3");


CREATE TABLE accounts (
    id varchar(255),
    account_no varchar(255),
    balance float,
    PRIMARY KEY (id),
    FOREIGN KEY (account_no) REFERENCES users(account_no)
    );
    
INSERT INTO accounts VALUES ( "A1", "account1", 100);
INSERT INTO accounts VALUES ( "A2", "account2", 200); 
INSERT INTO accounts VALUES ( "A3", "account3", 400);


/* deposting 1000 Rs to his account*/
START TRANSACTION;

SELECT 
@balance := balance + 1000,
@account_no := users.account_no
FROM 
accounts LEFT JOIN users ON users.account_no = accounts.account_no
WHERE 
users.name = "user1";

UPDATE accounts
SET balance = @balance
WHERE account_no  = @account_no;

COMMIT;

/* withdrawing 500 Rs to his account*/
START TRANSACTION;

SELECT 
@balance := balance - 500,
@account_no := users.account_no
FROM 
accounts LEFT JOIN users ON users.account_no = accounts.account_no
WHERE 
users.name = "user1";


UPDATE accounts
SET balance = @balance
WHERE account_no  = @account_no;

COMMIT;


/* transferring 200 Rs to user2*/
START TRANSACTION;

SELECT 
@balance := balance - 200,
@account_no := users.account_no
FROM 
accounts LEFT JOIN users ON users.account_no = accounts.account_no
WHERE 
users.name = "user1";

UPDATE accounts
SET balance = @balance
WHERE account_no  = @account_no;

SELECT 
@balance := balance + 200,
@account_no := users.account_no
FROM 
accounts LEFT JOIN users ON users.account_no = accounts.account_no
WHERE 
users.name = "user2";

UPDATE accounts
SET balance = @balance
WHERE account_no  = @account_no;

COMMIT;


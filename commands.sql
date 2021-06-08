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


SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;

/* Creating procedure for withdraw and deposit*/

DELIMITER //

DROP PROCEDURE IF EXISTS withdraw //
CREATE PROCEDURE withdraw(IN amount float, IN user_name varchar(255), OUT is_success boolean)
    BEGIN
        DECLARE withdraw_balance FLOAT DEFAULT 0;
        DECLARE withdraw_account_no varchar(255) DEFAULT NULL;
        SELECT 
            accounts.balance - amount, users.account_no  INTO withdraw_balance, withdraw_account_no
        FROM 
            accounts INNER JOIN users ON users.account_no = accounts.account_no
        WHERE 
            users.name = user_name;

        IF (withdraw_balance >= 0 AND withdraw_account_no IS NOT NULL) THEN
            UPDATE accounts
            SET balance = withdraw_balance
            WHERE account_no  = withdraw_account_no;
            SET is_success = true;
        ELSE
            SET is_success = false;
        END IF;

    END //

DROP PROCEDURE IF EXISTS deposit //
CREATE PROCEDURE deposit(amount float, user_name varchar(255), OUT is_success boolean)
    BEGIN
        DECLARE deposit_balance FLOAT DEFAULT 0;
        DECLARE deposit_account_no varchar(255) DEFAULT NULL;
        SELECT 
            accounts.balance + amount, users.account_no  INTO deposit_balance, deposit_account_no
        FROM 
            accounts INNER JOIN users ON users.account_no = accounts.account_no
        WHERE 
            users.name = user_name;

        IF (deposit_account_no IS NOT NULL) THEN
            UPDATE accounts
            SET balance = deposit_balance
            WHERE account_no  = deposit_account_no;
            SET is_success = true;
        ELSE
            SET is_success = false;
        END IF;

    END //

DROP PROCEDURE IF EXISTS transferAmount //
CREATE PROCEDURE transferAmount(amount float, from_user varchar(255), to_user varchar(255))
    BEGIN
        START TRANSACTION;
        CALL withdraw(amount, from_user, @is_withdraw_success);
        CALL deposit(amount, to_user,@is_deposit_success);
        IF (@is_deposit_success AND @is_withdraw_success) THEN
            COMMIT;
        ELSE
            ROLLBACK;
        END IF; 
    END //

DELIMITER ;

/* deposting 1000 Rs to his account*/
START TRANSACTION;
CALL deposit(1000, "user1", @is_success);
COMMIT;

/* withdrawing 500 Rs to his account*/
START TRANSACTION;
CALL withdraw(500, "user1", @is_success);
COMMIT;

/* transferring 200 Rs to user2*/
CALL transferAmount(200, "user1", "user2");
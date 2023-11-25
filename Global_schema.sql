Create DATABASE Global_Music;
use Global_Music;

Create Table Artist(
	Artist_Name VARCHAR(100),
    DOB DATE,
    followers_spotify int,
    followers_ressso int,
    followers_youtube int,
    followers_apple int
    
    
    
);
Create Table Genre(
	Gen_Name VARCHAR(30)
);
Create Table Songs(
	Song_Name VARCHAR(100),
    Song_Genre VARCHAR(30),
    Song_Artist VARCHAR(100),
    LaunchDate date,
    Song_Platform VARCHAR(50)
);
CREATE TABLE Song_Record(
	Song_Name VARCHAR(100),
    Play_Date DATE,
    User_DOB DATE,
    User_Gender VARCHAR(30),
    User_Location VARCHAR(100),
    Song_Artist VARCHAR(100),
    Song_Genre VARCHAR(30)
);


INSERT INTO Artist
SELECT name as Artist_Name,
date_of_birth as DOB,
NULL AS followers_spotify,
resso.singer.followers as followers_resso ,

(SELECT FOLLOWERS FROM Youtube_Music.Artist WHERE Artist_Name=Youtube_Music.Artist.name) AS followers_youtube,
(SELECT FOLLOWERS FROM apple_music.Artist WHERE Artist_Name=apple_music.Artist.Name) AS  followers_apple  
FROM resso.singer;
SELECT * FROM ARTIST;
UPDATE  ARTIST set followers_spotify=1000;
SET SQL_SAFE_UPDATES = 0;


DELIMITER //

CREATE EVENT Maintain
ON SCHEDULE EVERY 5 SECOND
DO
BEGIN

  IF NOT EXISTS (SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'spotify') THEN
    UPDATE ARTIST SET followers_spotify=NULL;
  END IF;
  
  IF NOT EXISTS (SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'apple_music') THEN
    UPDATE ARTIST SET followers_apple=NULL;
  END IF;
  
END //
DELIMITER ;

select * from songs;


INSERT INTO Songs (Song_Name, Song_Genre, Song_Artist, Launchdate, Song_Platform)
    SELECT
    S.name AS Song_Name,
    G.name AS Song_Genre,
    A.artist_name AS Song_Artist,
    S.release_date AS Launchdate,
    'spotify' AS Song_Platform  
    FROM spotify.Songs S
    JOIN spotify.Genre G ON S.genre_id = G.genre_id
    JOIN spotify.Artist A ON S.artist_id = A.artist_id;

select * from songs;

INSERT INTO Songs (Song_Name, Song_Genre, Song_Artist, Launchdate, Song_Platform)
    SELECT
    S.name AS Song_Name,
    G.name AS Song_Genre,
    A.name AS Song_Artist,
    S.releasedate AS Launchdate,
    'resso' AS Song_Platform  
    FROM resso.Songs S
    JOIN resso.Genre G ON S.gid = G.gid
    JOIN resso.singer A ON S.aid = A.aid;

ALTER TABLE Song_Record ADD Song_Platform VARCHAR(50);
ALTER TABLE Song_Record ADD Play_ID INT;
ALTER TABLE Song_Record DROP COLUMN Song_ID;
-- Insert data into Song_Record table in Global_Music database

DELETE FROM Global_Music.Song_Record;
INSERT INTO Global_Music.Song_Record (
    Song_Name,
    Play_Date,
    User_DOB,
    User_Gender,
    User_Location,
    Song_Artist,
    Song_Genre,
    Song_Platform,
    Play_ID
)
SELECT
    s.name AS Song_Name,
    p.play_date AS Play_Date,
    c.birthdate AS User_DOB,
    c.gender AS User_Gender,
    c.address AS User_Location,
    a.artist_name AS Song_Artist,
    g.name AS Song_Genre,
    
    
    'spotify' AS Song_Platform ,
     p.play_id AS Play_ID
FROM
    Spotify.plays p
JOIN
    Spotify.Songs s ON p.song_id = s.song_id
JOIN
    Spotify.Artist a ON s.artist_id = a.artist_id
JOIN
    Spotify.Genre g ON s.genre_id = g.genre_id
JOIN
    Spotify.Customer c ON p.customer_id = c.customer_id;


select * from Song_Record;
delete from Song_Record;

select * from resso.plays;


INSERT INTO Global_Music.Song_Record (
    Song_Name,
    Play_Date,
    User_DOB,
    User_Gender,
    User_Location,
    Song_Artist,
    Song_Genre,
    Song_Platform,
    Play_ID
)
SELECT
    s.name AS Song_Name,
    p.playdate AS Play_Date,
    c.Date_of_Birth AS User_DOB,
    c.gender AS User_Gender,
    c.location AS User_Location,
    a.name AS Song_Artist,
    g.name AS Song_Genre,
    'resso' AS Song_Platform,
    p.pid AS Play_ID
    
FROM
    resso.plays p
JOIN
    resso.Songs s ON p.sid = s.sid
JOIN
    resso.singer a ON s.aid = a.aid
JOIN
    resso.Genre g ON s.gid = g.gid
JOIN
    resso.user c ON p.cid = c.cid;
    
    

INSERT INTO Global_Music.Song_Record (
    Song_Name,
    Play_Date,
    User_DOB,
    User_Gender,
    User_Location,
    Song_Artist,
    Song_Genre,
    Song_Platform,
    Play_ID
)
SELECT
    s.name AS Song_Name,
    p.playdate AS Play_Date,
    c.dob AS User_DOB,
    c.sex AS User_Gender,
    c.address AS User_Location,
    a.name AS Song_Artist,
    g.name AS Song_Genre,
    'Youtube_Music' AS Song_Platform ,
    p.playid AS Play_ID
    
FROM
    Youtube_Music.Plays p
JOIN
    Youtube_Music.Songs s ON p.song_ = s.song_
JOIN
    Youtube_Music.Artist a ON s.artist_ = a.artist_
JOIN
    Youtube_Music.Genre g ON s.genre_ = g.genre_
JOIN
    Youtube_Music.customer c ON p.cust_ = c.cust_;


INSERT INTO Global_Music.Song_Record (
    Song_Name,
    Play_Date,
    User_DOB,
    User_Gender,
    User_Location,
    Song_Artist,
    Song_Genre,
    Song_Platform,
    Play_ID
)
SELECT
    s.Song_name AS Song_Name,
    p.Play_Date AS Play_Date,
    c.Birth_date AS User_DOB,
    c.gender AS User_Gender,
    c.location AS User_Location,
    a.Name AS Song_Artist,
    g.Genre_Name AS Song_Genre,
    'apple_music' AS Song_Platform ,
    p.Play_id AS Play_id
FROM
    apple_music.Plays p
JOIN
    apple_music.Songs s ON p.Song_id = s.Song_id
JOIN
    apple_music.Artist a ON s.ART_id = a.ART_id
JOIN
    apple_music.Genre g ON s.Genre_id = g.Genre_id
JOIN
    apple_music.customer c ON p.cust_id = c.cust_id;

select * from Song_Record;





use spotify;



DELIMITER //
CREATE TRIGGER delete_song_record
AFTER DELETE ON Plays
FOR EACH ROW
BEGIN
  DELETE FROM Global_Music.Song_Record
  WHERE Play_ID = OLD.play_id
    
    
    
    AND Song_Platform = 'Spotify';
END;
//
DELIMITER ;




DROP TRIGGER delete_song_record;


delete from plays where play_id=2; 
select * from plays;
select * from Global_Music.Song_Record;
select * from customer;


use resso;
DELIMITER //
CREATE TRIGGER delete_song_record_resso
AFTER DELETE ON Plays
FOR EACH ROW
BEGIN
  DELETE FROM Global_Music.Song_Record
  WHERE Play_id = OLD.pid
    
    
   
   AND Song_Platform = 'resso';
END;
//
DELIMITER ;



select * from user;


select * from Global_Music.Song_Record;



use apple_music;
drop trigger delete_song_record_resso;



DELIMITER //
CREATE TRIGGER delete_song_record_apple_music
AFTER DELETE ON Plays
FOR EACH ROW
BEGIN
  DELETE FROM Global_Music.Song_Record
  WHERE Play_id = OLD.Play_id
    
    
   
    AND Song_Platform = 'apple_music';
END;
//
DELIMITER ;
drop trigger delete_song_record_apple_music;
select * from Plays;
delete from Plays where Play_id=4;


use Youtube_Music;
DELIMITER //
CREATE TRIGGER delete_song_record_Youtube_Music
AFTER DELETE ON Plays
FOR EACH ROW
BEGIN
  DELETE FROM Global_Music.Song_Record
  WHERE Play_id = OLD.playid
    
    AND Song_Platform = "youtube_music";
END;
//
DELIMITER ;

delete from Plays where playid=10;
drop trigger delete_song_record_Youtube_Music;
use Global_Music;




-- #TRIGGERS FOR ADDITION-- 
-- FOR SPOTIFY
use spotify;
DELIMITER //
CREATE TRIGGER insert_song_record_spotify
AFTER INSERT ON Plays
FOR EACH ROW
BEGIN
  INSERT INTO Global_Music.Song_Record
  (Song_Name, Play_Date, User_DOB, User_Gender, User_Location, Song_Artist, Song_Genre, Song_Platform , Play_ID)
  SELECT
    s.name AS Song_Name,
    NEW.play_date AS Play_Date,
    c.birthdate AS User_DOB,
    c.gender AS User_Gender,
    c.address AS User_Location,
    a.artist_name AS Song_Artist,
    g.name AS Song_Genre,
    'Spotify' AS Song_Platform , 
    New.play_id AS Play_ID
  FROM
    Songs s
    JOIN Artist a ON s.artist_id = a.artist_id
    JOIN Genre g ON s.genre_id = g.genre_id
    JOIN CUSTOMER c ON NEW.customer_id = c.customer_id
  WHERE
    s.song_id = NEW.song_id;
END;
//
DELIMITER ;



drop trigger insert_song_record_spotify;
select * from plays;


insert into plays values (202,24,'2023-11-20',1);





select * from plays;
select * from customer;


use resso;
-- FOR RESSO
DELIMITER //
CREATE TRIGGER insert_song_record_resso
AFTER INSERT ON Plays
FOR EACH ROW
BEGIN
  INSERT INTO Global_Music.Song_Record
  (Song_Name, Play_Date, User_DOB, User_Gender, User_Location, Song_Artist, Song_Genre, Song_Platform , Play_ID)
  SELECT
    s.name AS Song_Name,
    NEW.playdate AS Play_Date,
    u.Date_of_Birth AS User_DOB,
    u.gender AS User_Gender,
    u.location AS User_Location,
    sg.name AS Song_Artist,
    g.name AS Song_Genre,
    'Resso' AS Song_Platform, 
    NEW.pid AS Play_ID
  FROM
    Songs s
    JOIN singer sg ON s.aid = sg.aid
    JOIN Genre g ON s.gid = g.gid
    JOIN user u ON NEW.cid = u.cid
  WHERE
    s.sid = NEW.sid;
END;
//
DELIMITER ;

drop trigger insert_song_record_resso;


select * from plays;


select * from user;
insert into plays values (162,21,'2023-11-19',2);

select * from Global_Music.Song_Record;
delete from Global_Music.Song_Record;


-- Youtube Music add trigger

use Youtube_Music;

DELIMITER //
CREATE TRIGGER insert_song_record_youtube_music
AFTER INSERT ON Youtube_Music.Plays
FOR EACH ROW
BEGIN
  INSERT INTO Global_Music.Song_Record
  (Song_Name, Play_Date, User_DOB, User_Gender, User_Location, Song_Artist, Song_Genre, Song_Platform, Play_ID)
  SELECT
    s.name AS Song_Name,
    NEW.playdate AS Play_Date,
    c.dob AS User_DOB,
    c.sex AS User_Gender,
    c.address AS User_Location,
    a.name AS Song_Artist,
    g.name AS Song_Genre,
    'YouTube Music' AS Song_Platform,
    NEW.playid AS Play_ID
  FROM
    Songs s
    JOIN Artist a ON s.artist_ = a.artist_
    JOIN Genre g ON s.genre_ = g.genre_
    JOIN customer c ON NEW.cust_ = c.cust_
  WHERE
    s.song_ = NEW.song_;
END;
//
DELIMITER ;
select * from Plays;
insert into Plays values (111,21,'2023-11-18',2);

-- Apple Music add trigger
use apple_music;
DELIMITER //
CREATE TRIGGER insert_song_record_apple_music
AFTER INSERT ON apple_music.Plays
FOR EACH ROW
BEGIN
  INSERT INTO Global_Music.Song_Record
  (Song_Name, Play_Date, User_DOB, User_Gender, User_Location, Song_Artist, Song_Genre, Song_Platform, Play_ID)
  SELECT
    s.Song_Name,
    NEW.Play_Date,
    c.Birth_date AS User_DOB,
    c.Gender AS User_Gender,
    c.Location AS User_Location,
    a.Name AS Song_Artist,
    g.Genre_Name AS Song_Genre,
    'Apple Music' AS Song_Platform,
    NEW.Play_id AS Play_ID
  FROM
    Songs s
    JOIN Artist a ON s.Art_id = a.Art_id
    JOIN Genre g ON s.Genre_ID = g.Genre_ID
    JOIN customer c ON NEW.Cust_ID = c.Cust_ID
  WHERE
    s.Song_id = NEW.Song_id;
END;
//
DELIMITER ;
select * from plays;
select * from Global_Music.Song_Record;


-- TRIGGERS FOR SONGS

use spotify;

DELIMITER //
CREATE TRIGGER delete_song
AFTER DELETE ON SONGS
FOR EACH ROW
BEGIN
  DELETE FROM Global_Music.Songs
  WHERE Song_name = OLD.name
    
    
    
    AND Song_Platform = 'Spotify';
END;
//
DELIMITER ;


use resso;
DELIMITER //
CREATE TRIGGER delete_song_resso
AFTER DELETE ON SONGS
FOR EACH ROW
BEGIN
  DELETE FROM Global_Music.Songs
  WHERE Song_name = OLD.name
    
    
    
    AND Song_Platform = 'resso';
END;
//
DELIMITER ;




use Youtube_Music;

DELIMITER //
CREATE TRIGGER delete_song_youtube_music
AFTER DELETE ON SONGS
FOR EACH ROW
BEGIN
  DELETE FROM Global_Music.Songs
  WHERE Song_name = OLD.name
    
    
    
    AND Song_Platform = 'Youtube_Music';
END;
//
DELIMITER ;

use apple_music;
DELIMITER //
CREATE TRIGGER delete_song_apple_music
AFTER DELETE ON SONGS
FOR EACH ROW
BEGIN
  DELETE FROM Global_Music.Songs
  WHERE Song_name = OLD.Song_Name
    
    
    
    AND Song_Platform = 'apple_Music';
END;
//
DELIMITER ;


DELIMITER //
CREATE TRIGGER insert_song_global_resso
AFTER INSERT ON resso.Songs
FOR EACH ROW
BEGIN
  DECLARE v_genre_name VARCHAR(50);
  DECLARE v_artist_name VARCHAR(50);

  -- Retrieve genre_name
  SELECT name INTO v_genre_name
  FROM Genre
  WHERE gid = NEW.gid;

  -- Retrieve artist_name
  SELECT name INTO v_artist_name
  FROM singer
  WHERE aid = NEW.aid;

  -- Insert into Global_Music.Songs
  INSERT INTO Global_Music.Songs
  (Song_Name, Song_Genre, Song_Artist, LaunchDate, Song_Platform)
  VALUES
  (NEW.name, v_genre_name, v_artist_name, NEW.releasedate, 'Resso');
END;
//
DELIMITER ;


use youtube_music;

DELIMITER //
CREATE TRIGGER insert_song_global_youtube_music
AFTER INSERT ON youtube_music.Songs
FOR EACH ROW
BEGIN
  DECLARE v_genre_name VARCHAR(50);
  DECLARE v_artist_name VARCHAR(50);

  -- Retrieve genre_name
  SELECT name INTO v_genre_name
  FROM Genre
  WHERE genre_ = NEW.genre_;

  -- Retrieve artist_name
  SELECT name INTO v_artist_name
  FROM Artist
  WHERE artist_ = NEW.artist_;

  -- Insert into Global_Music.Songs
  INSERT INTO Global_Music.Songs
  (Song_Name, Song_Genre, Song_Artist, LaunchDate, Song_Platform)
  VALUES
  (NEW.name, v_genre_name, v_artist_name, NEW.releasedate, 'YouTube Music');
END;
//
DELIMITER ;


use apple_music;
DELIMITER //
CREATE TRIGGER insert_song_global_apple_music
AFTER INSERT ON apple_music.Songs
FOR EACH ROW
BEGIN
  DECLARE v_genre_name VARCHAR(50);
  DECLARE v_artist_name VARCHAR(50);

  -- Retrieve genre_name
  SELECT Genre_Name INTO v_genre_name
  FROM Genre
  WHERE Genre_ID = NEW.Genre_ID;

  -- Retrieve artist_name
  SELECT Name INTO v_artist_name
  FROM Artist
  WHERE Art_id = NEW.Art_id;

  -- Insert into Global_Music.Songs
  INSERT INTO Global_Music.Songs
  (Song_Name, Song_Genre, Song_Artist, LaunchDate, Song_Platform)
  VALUES
  (NEW.Song_Name, v_genre_name, v_artist_name, NEW.Song_Release_Date, 'Apple Music');
END;
//
DELIMITER ;
select * from songs;


insert into Songs VALUES(26,"Lo-fi",'2014-12-2',3,20);


use Global_Music;


use spotify;
select * from plays;
delete  from plays where Play_ID=21;


select * from Artist;


use spotify;


DELIMITER //
CREATE TRIGGER delete_artist_global_spotify
AFTER DELETE ON Spotify.Artist
FOR EACH ROW
BEGIN
  UPDATE Global_Music.Artist
  SET followers_spotify = NULL
  WHERE Artist_Name = OLD.artist_name;
END;
//
DELIMITER ;
drop trigger delete_artist_global_spotify;

select * from Global_Music.Artist;

use resso;
DELIMITER //
CREATE TRIGGER delete_artist_global_resso
AFTER DELETE ON resso.singer
FOR EACH ROW
BEGIN
  UPDATE Global_Music.Artist
  SET followers_ressso = NULL
  WHERE Artist_Name = OLD.name;
END;
//
DELIMITER ;
drop trigger delete_artist_global_resso;

select * from singer;
delete from singer where aid=1;


-- for youtube_music
use Youtube_music;
DELIMITER //
CREATE TRIGGER delete_artist_global_youtube_music
AFTER DELETE ON Youtube_Music.Artist
FOR EACH ROW
BEGIN
  UPDATE Global_Music.Artist
  SET followers_youtube = NULL
  WHERE Artist_Name = OLD.name;
END;
//
DELIMITER ;

select * from Artist;
delete from artist where artist_=2;

use apple_music;
DELIMITER //
CREATE TRIGGER delete_artist_global_apple_music
AFTER DELETE ON apple_music.Artist
FOR EACH ROW
BEGIN
  UPDATE Global_Music.Artist
  SET followers_apple = NULL
  WHERE Artist_Name = OLD.name;
END;
//
DELIMITER ;

delete from Artist where Art_id=3;


use resso;
select * from singer;


delete from singer where aid=6;


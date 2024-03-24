CREATE DATABASE bigFm;
USE bigFm;
    
-- 1)Retrieve all stations in the "East" region?
SELECT * FROM Stations WHERE Location = "East";

-- 2)List all shows hosted by "Vrajesh Hirjee"?
WITH showhost AS
(SELECT s.ShowID, s.ShowName, h.HostName FROM Shows s JOIN Hosts h ON s.HostID = h.HostID)
SELECT * FROM showhost WHERE HostName = "Vrajesh Hirjee";

-- 3)Count the number of awards each show has won?
SELECT sh.ShowName, COUNT(AwardID) AS number_of_awards FROM Shows sh JOIN Awards a ON sh.ShowID = a.ShowID GROUP BY sh.ShowID;

-- 4)Find shows that have partnerships with "Spotify"?
WITH SpotifyPartner AS 
(SELECT s.ShowName, p.PartnerName FROM Shows s JOIN ShowPartnerships sp ON s.ShowID = sp.ShowID JOIN Partnerships p 
ON sp.PartnershipID = p.PartnershipID WHERE PartnerName="Spotify")

SELECT * FROM SpotifyPartner;	

-- 5)Retrieve hosts who joined before 2010?
SELECT HostName, JoinDate FROM Hosts WHERE Year(JoinDate) < 2010;

-- 6)List the shows and their launch dates in descending order of launch date?
SELECT ShowName, LaunchDate FROM Shows ORDER BY LaunchDate DESC;

-- 7)Find the total count of shows for each host?
SELECT HostName, ShowCount FROM Hosts ORDER BY ShowCount DESC;

-- 8)Show the online presence platforms with their links?
SELECT PlatformName, Link FROM OnlinePresence;

-- 9)Retrieve the stations in the "South" region launched after 2010?
SELECT StationName, LaunchDate, Location FROM Stations WHERE Location="South" AND Year(Launchdate) > 2010;

-- 10)Rank hosts based on the number of shows they have hosted?
SELECT HostName, ShowCount, Rank() OVER (ORDER BY ShowCount DESC) FROM Hosts;
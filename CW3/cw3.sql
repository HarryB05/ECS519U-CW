-- Create database
DROP DATABASE IF EXISTS ecs519;
CREATE DATABASE ecs519;
USE ecs519;

-- Drop tables if they exist (in reverse dependency order)
DROP TABLE IF EXISTS TripPassenger;
DROP TABLE IF EXISTS TripCrew;
DROP TABLE IF EXISTS Trip;
DROP TABLE IF EXISTS Passenger;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Person;
DROP TABLE IF EXISTS RouteTrainEligibility;
DROP TABLE IF EXISTS RouteStation;
DROP TABLE IF EXISTS Route;
DROP TABLE IF EXISTS PassengerCategory;
DROP TABLE IF EXISTS Train;
DROP TABLE IF EXISTS Role;
DROP TABLE IF EXISTS Station;

-- Create Station table
CREATE TABLE Station (
    station_id INT PRIMARY KEY,
    station_name VARCHAR(255) NOT NULL,
    city VARCHAR(100),
    country VARCHAR(100)
);

-- Create Role table
CREATE TABLE Role (
    role_id INT PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL
);

-- Create Train table
CREATE TABLE Train (
    train_id INT PRIMARY KEY,
    status VARCHAR(50),
    year_introduced INT
);

-- Create Route table
CREATE TABLE Route (
    route_id INT PRIMARY KEY,
    start_station_id INT NOT NULL,
    end_station_id INT NOT NULL,
    distance_miles INT,
    journey_time_minutes INT,
    status VARCHAR(50),
    FOREIGN KEY (start_station_id) REFERENCES Station(station_id),
    FOREIGN KEY (end_station_id) REFERENCES Station(station_id)
);

-- Create RouteStation table (junction table for Route-Station M:N relationship)
CREATE TABLE RouteStation (
    route_id INT NOT NULL,
    station_id INT NOT NULL,
    stop_order INT NOT NULL,
    PRIMARY KEY (route_id, station_id),
    FOREIGN KEY (route_id) REFERENCES Route(route_id),
    FOREIGN KEY (station_id) REFERENCES Station(station_id)
);

-- Create RouteTrainEligibility table (junction table for Route-Train M:N relationship)
CREATE TABLE RouteTrainEligibility (
    route_id INT NOT NULL,
    train_id INT NOT NULL,
    PRIMARY KEY (route_id, train_id),
    FOREIGN KEY (route_id) REFERENCES Route(route_id),
    FOREIGN KEY (train_id) REFERENCES Train(train_id)
);

-- Create Person table (Supertype for Generalisation)
CREATE TABLE Person (
    person_id INT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    email VARCHAR(255),
    phone VARCHAR(50)
);

-- Create Employee table (Subtype of Person)
CREATE TABLE Employee (
    employee_id INT PRIMARY KEY,
    person_id INT NOT NULL,
    role_id INT,
    hire_date DATE,
    FOREIGN KEY (person_id) REFERENCES Person(person_id),
    FOREIGN KEY (role_id) REFERENCES Role(role_id)
);

-- Create Passenger table (Subtype of Person)
CREATE TABLE Passenger (
    passenger_id INT PRIMARY KEY,
    person_id INT NOT NULL,
    loyalty_member BOOLEAN DEFAULT FALSE,
    membership_tier VARCHAR(50),
    FOREIGN KEY (person_id) REFERENCES Person(person_id)
);

-- Create Trip table
CREATE TABLE Trip (
    trip_id INT PRIMARY KEY,
    route_id INT NOT NULL,
    train_id INT NOT NULL,
    departure_datetime DATETIME,
    arrival_datetime DATETIME,
    FOREIGN KEY (route_id) REFERENCES Route(route_id),
    FOREIGN KEY (train_id) REFERENCES Train(train_id)
);

-- Create TripCrew table (junction table for Trip-Employee M:N relationship)
CREATE TABLE TripCrew (
    trip_id INT NOT NULL,
    employee_id INT NOT NULL,
    crew_role_description VARCHAR(255),
    PRIMARY KEY (trip_id, employee_id),
    FOREIGN KEY (trip_id) REFERENCES Trip(trip_id),
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)
);

-- Create PassengerCategory table
CREATE TABLE PassengerCategory (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);

-- Create TripPassenger table (junction table for Trip-PassengerCategory M:N relationship)
CREATE TABLE TripPassenger (
    trip_id INT NOT NULL,
    category_id INT NOT NULL,
    passenger_count INT,
    PRIMARY KEY (trip_id, category_id),
    FOREIGN KEY (trip_id) REFERENCES Trip(trip_id),
    FOREIGN KEY (category_id) REFERENCES PassengerCategory(category_id)
);


-- Insert data into the tables

-- Insert Stations
INSERT INTO Station (station_id, station_name, city, country) VALUES
(1, 'London St Pancras International', 'London', 'United Kingdom'),
(2, 'Paris Gare du Nord', 'Paris', 'France'),
(3, 'Brussels Midi', 'Brussels', 'Belgium'),
(4, 'Amsterdam Centraal', 'Amsterdam', 'Netherlands'),
(5, 'Lille Europe', 'Lille', 'France'),
(6, 'Rotterdam Centraal', 'Rotterdam', 'Netherlands'),
(7, 'Ashford International', 'Ashford', 'United Kingdom'),
(8, 'Ebbsfleet International', 'Ebbsfleet', 'United Kingdom'),
(9, 'Calais-Fréthun', 'Calais', 'France'),
(10, 'Disneyland Paris', 'Marne-la-Vallée', 'France');

-- Insert Roles
INSERT INTO Role (role_id, role_name) VALUES
(1, 'Driver'),
(2, 'Service Crew'),
(3, 'Conductor'),
(4, 'Head of Staff'),
(5, 'Catering Manager'),
(6, 'Security Officer'),
(7, 'Maintenance Technician'),
(8, 'Customer Service Manager'),
(9, 'Train Manager'),
(10, 'Assistant Driver');

-- Insert Trains
INSERT INTO Train (train_id, status, year_introduced) VALUES
(101, 'Operating', 2015),
(102, 'Operating', 2015),
(103, 'Operating', 2018),
(104, 'Operating', 2018),
(105, 'Under Repair', 2015),
(106, 'Operating', 2020),
(107, 'Operating', 2020),
(108, 'Stored', 2012),
(109, 'Operating', 2021),
(110, 'Operating', 2019);

-- Insert Passenger Categories
INSERT INTO PassengerCategory (category_id, category_name) VALUES
(1, 'Adult'),
(2, 'Child'),
(3, 'Student'),
(4, 'Senior'),
(5, 'Infant'),
(6, 'Business Class'),
(7, 'Standard Class'),
(8, 'First Class'),
(9, 'Group Booking'),
(10, 'Disabled Passenger');

-- Insert Routes
INSERT INTO Route (route_id, start_station_id, end_station_id, distance_miles, journey_time_minutes, status) VALUES
(1, 1, 2, 307, 135, 'Operational'),
(2, 1, 3, 227, 120, 'Operational'),
(3, 1, 4, 331, 198, 'Operational'),
(4, 2, 1, 307, 135, 'Operational'),
(5, 2, 3, 189, 82, 'Operational'),
(6, 3, 1, 227, 120, 'Operational'),
(7, 3, 4, 127, 108, 'Operational'),
(8, 1, 5, 177, 90, 'Operational'),
(9, 1, 7, 67, 37, 'Operational'),
(10, 1, 8, 19, 10, 'Planned');

-- Insert Route Stations (intermediate stops)
INSERT INTO RouteStation (route_id, station_id, stop_order) VALUES
(1, 7, 1),
(1, 5, 2),
(3, 3, 1),
(3, 6, 2),
(4, 5, 1),
(4, 7, 2),
(7, 6, 1),
(8, 7, 1),
(1, 9, 3),
(3, 5, 3);

-- Insert Route Train Eligibility
INSERT INTO RouteTrainEligibility (route_id, train_id) VALUES
(1, 101),
(1, 102),
(1, 103),
(1, 104),
(2, 101),
(2, 102),
(2, 103),
(2, 104),
(3, 103),
(3, 104),
(3, 106),
(3, 107),
(4, 101),
(4, 102),
(4, 103),
(4, 104),
(5, 101),
(5, 102),
(5, 103),
(6, 101),
(6, 102),
(6, 103),
(6, 104),
(7, 103),
(7, 104),
(7, 106),
(8, 101),
(8, 102),
(8, 103);

-- Insert Persons (Supertype)
INSERT INTO Person (person_id, first_name, last_name, date_of_birth, email, phone) VALUES
(1, 'James', 'Mitchell', '1985-03-15', 'james.mitchell@eurostar.com', '+44 20 7928 0001'),
(2, 'Sarah', 'Thompson', '1987-07-22', 'sarah.thompson@eurostar.com', '+44 20 7928 0002'),
(3, 'Michael', 'Chen', '1989-11-08', 'michael.chen@eurostar.com', '+44 20 7928 0003'),
(4, 'Emma', 'Wilson', '1990-02-14', 'emma.wilson@eurostar.com', '+44 20 7928 0004'),
(5, 'David', 'Brown', '1991-05-30', 'david.brown@eurostar.com', '+44 20 7928 0005'),
(6, 'Sophie', 'Martinez', '1992-09-17', 'sophie.martinez@eurostar.com', '+44 20 7928 0006'),
(7, 'Robert', 'Taylor', '1986-01-25', 'robert.taylor@eurostar.com', '+44 20 7928 0007'),
(8, 'Laura', 'Anderson', '1988-04-12', 'laura.anderson@eurostar.com', '+44 20 7928 0008'),
(9, 'Christopher', 'White', '1984-08-03', 'christopher.white@eurostar.com', '+44 20 7928 0009'),
(10, 'Jennifer', 'Harris', '1987-12-19', 'jennifer.harris@eurostar.com', '+44 20 7928 0010'),
(11, 'Daniel', 'Clark', '1993-06-07', 'daniel.clark@eurostar.com', '+44 20 7928 0011'),
(12, 'Amanda', 'Lewis', '1985-10-23', 'amanda.lewis@eurostar.com', '+44 20 7928 0012'),
(13, 'Thomas', 'Walker', '1986-02-28', 'thomas.walker@eurostar.com', '+44 20 7928 0013'),
(14, 'Rachel', 'Hall', '1994-07-11', 'rachel.hall@eurostar.com', '+44 20 7928 0014'),
(15, 'William', 'Young', '1989-03-26', 'william.young@eurostar.com', '+44 20 7928 0015'),
(16, 'Nicole', 'King', '1990-09-02', 'nicole.king@eurostar.com', '+44 20 7928 0016'),
(17, 'Matthew', 'Wright', '1988-01-18', 'matthew.wright@eurostar.com', '+44 20 7928 0017'),
(18, 'Jessica', 'Lopez', '1991-05-04', 'jessica.lopez@eurostar.com', '+44 20 7928 0018'),
(19, 'Andrew', 'Hill', '1992-11-20', 'andrew.hill@eurostar.com', '+44 20 7928 0019'),
(20, 'Olivia', 'Scott', '1993-08-15', 'olivia.scott@eurostar.com', '+44 20 7928 0020'),
(21, 'Benjamin', 'Green', '1995-04-09', 'benjamin.green@example.com', '+44 20 1234 0001'),
(22, 'Charlotte', 'Adams', '1992-10-16', 'charlotte.adams@example.com', '+44 20 1234 0002'),
(23, 'Henry', 'Baker', '1988-06-22', 'henry.baker@example.com', '+44 20 1234 0003'),
(24, 'Isabella', 'Nelson', '1994-12-03', 'isabella.nelson@example.com', '+44 20 1234 0004'),
(25, 'Alexander', 'Carter', '1991-08-19', 'alexander.carter@example.com', '+44 20 1234 0005');

-- Insert Employees (Subtype of Person)
INSERT INTO Employee (employee_id, person_id, role_id, hire_date) VALUES
(1, 1, 1, '2013-06-01'),
(2, 2, 1, '2014-03-15'),
(3, 3, 1, '2015-09-10'),
(4, 4, 2, '2016-01-20'),
(5, 5, 2, '2016-05-12'),
(6, 6, 2, '2017-02-08'),
(7, 7, 3, '2014-11-30'),
(8, 8, 3, '2015-07-18'),
(9, 9, 4, '2013-04-05'),
(10, 10, 4, '2017-10-22'),
(11, 11, 2, '2018-03-14'),
(12, 12, 5, '2015-12-01'),
(13, 13, 1, '2014-08-25'),
(14, 14, 2, '2018-06-10'),
(15, 15, 6, '2019-01-15'),
(16, 16, 7, '2018-09-05'),
(17, 17, 8, '2017-11-20'),
(18, 18, 9, '2019-02-28'),
(19, 19, 10, '2018-04-12'),
(20, 20, 2, '2020-07-08');

-- Insert Passengers (Subtype of Person)
INSERT INTO Passenger (passenger_id, person_id, loyalty_member, membership_tier) VALUES
(1, 21, TRUE, 'Gold'),
(2, 22, TRUE, 'Silver'),
(3, 23, FALSE, NULL),
(4, 24, TRUE, 'Bronze'),
(5, 25, FALSE, NULL);

-- Insert Trips
INSERT INTO Trip (trip_id, route_id, train_id, departure_datetime, arrival_datetime) VALUES
(1001, 1, 101, '2024-01-15 08:30:00', '2024-01-15 10:45:00'),
(1002, 1, 102, '2024-02-20 12:00:00', '2024-02-20 14:15:00'),
(1003, 2, 103, '2024-03-10 09:00:00', '2024-03-10 11:00:00'),
(1004, 3, 104, '2024-04-05 07:00:00', '2024-04-05 10:18:00'),
(1005, 4, 101, '2024-05-18 15:00:00', '2024-05-18 17:15:00'),
(1006, 1, 103, '2024-06-22 08:30:00', '2024-06-22 10:45:00'),
(1007, 2, 101, '2024-07-08 09:00:00', '2024-07-08 11:00:00'),
(1008, 5, 102, '2024-08-14 10:30:00', '2024-08-14 11:52:00'),
(1009, 3, 106, '2024-09-25 07:00:00', '2024-09-25 10:18:00'),
(1010, 6, 104, '2024-10-30 14:00:00', '2024-10-30 16:00:00'),
(1011, 7, 107, '2024-11-12 08:00:00', '2024-11-12 09:48:00'),
(1012, 8, 103, '2024-12-28 11:00:00', '2024-12-28 12:30:00');

-- Insert Trip Crew
INSERT INTO TripCrew (trip_id, employee_id, crew_role_description) VALUES
(1001, 1, 'Primary Driver'),
(1001, 4, 'Service Crew'),
(1001, 7, 'Conductor'),
(1001, 9, 'Head of Staff'),
(1002, 2, 'Primary Driver'),
(1002, 5, 'Service Crew'),
(1002, 8, 'Conductor'),
(1003, 3, 'Primary Driver'),
(1003, 6, 'Service Crew'),
(1003, 7, 'Conductor'),
(1004, 13, 'Primary Driver'),
(1004, 11, 'Service Crew'),
(1004, 14, 'Service Crew'),
(1004, 8, 'Conductor'),
(1004, 10, 'Head of Staff'),
(1005, 1, 'Primary Driver'),
(1005, 4, 'Service Crew'),
(1005, 7, 'Conductor'),
(1006, 2, 'Primary Driver'),
(1006, 5, 'Service Crew'),
(1006, 8, 'Conductor'),
(1007, 3, 'Primary Driver'),
(1007, 6, 'Service Crew'),
(1007, 7, 'Conductor'),
(1008, 1, 'Primary Driver'),
(1008, 4, 'Service Crew'),
(1008, 8, 'Conductor'),
(1009, 13, 'Primary Driver'),
(1009, 11, 'Service Crew'),
(1009, 14, 'Service Crew'),
(1009, 7, 'Conductor'),
(1009, 9, 'Head of Staff'),
(1010, 2, 'Primary Driver'),
(1010, 5, 'Service Crew'),
(1010, 8, 'Conductor'),
(1011, 3, 'Primary Driver'),
(1011, 6, 'Service Crew'),
(1011, 7, 'Conductor'),
(1012, 1, 'Primary Driver'),
(1012, 4, 'Service Crew'),
(1012, 7, 'Conductor');

-- Insert Trip Passengers
INSERT INTO TripPassenger (trip_id, category_id, passenger_count) VALUES
(1001, 1, 245),
(1001, 2, 32),
(1001, 3, 18),
(1001, 4, 15),
(1001, 5, 8),
(1002, 1, 312),
(1002, 2, 45),
(1002, 3, 28),
(1002, 4, 22),
(1002, 5, 12),
(1003, 1, 198),
(1003, 2, 25),
(1003, 3, 15),
(1003, 4, 12),
(1003, 5, 5),
(1004, 1, 278),
(1004, 2, 38),
(1004, 3, 24),
(1004, 4, 18),
(1004, 5, 10),
(1005, 1, 267),
(1005, 2, 35),
(1005, 3, 21),
(1005, 4, 16),
(1005, 5, 9),
(1006, 1, 289),
(1006, 2, 41),
(1006, 3, 26),
(1006, 4, 19),
(1006, 5, 11),
(1007, 1, 203),
(1007, 2, 28),
(1007, 3, 17),
(1007, 4, 13),
(1007, 5, 6),
(1008, 1, 156),
(1008, 2, 19),
(1008, 3, 12),
(1008, 4, 9),
(1008, 5, 4),
(1009, 1, 295),
(1009, 2, 42),
(1009, 3, 27),
(1009, 4, 20),
(1009, 5, 11),
(1010, 1, 189),
(1010, 2, 24),
(1010, 3, 14),
(1010, 4, 11),
(1010, 5, 5),
(1011, 1, 167),
(1011, 2, 21),
(1011, 3, 13),
(1011, 4, 10),
(1011, 5, 4),
(1012, 1, 134),
(1012, 2, 16),
(1012, 3, 10),
(1012, 4, 7),
(1012, 5, 3);


-- Queries

-- Part 1: Basic Queries

-- Query 1: Find all trips scheduled in March 2024 with their route start and end station names
SELECT 
    t.trip_id,
    t.departure_datetime,
    t.arrival_datetime,
    s1.station_name AS start_station,
    s2.station_name AS end_station,
    r.distance_miles,
    r.journey_time_minutes
FROM Trip t
JOIN Route r ON t.route_id = r.route_id
JOIN Station s1 ON r.start_station_id = s1.station_id
JOIN Station s2 ON r.end_station_id = s2.station_id
WHERE MONTH(t.departure_datetime) = 3 
  AND YEAR(t.departure_datetime) = 2024
ORDER BY t.departure_datetime;

-- Query 2: Find employees with their role names and the number of trips they have been assigned to
SELECT 
    e.employee_id,
    p.first_name,
    p.last_name,
    p.email,
    r.role_name,
    COUNT(tc.trip_id) AS number_of_trips_assigned
FROM Employee e
JOIN Person p ON e.person_id = p.person_id
JOIN Role r ON e.role_id = r.role_id
LEFT JOIN TripCrew tc ON e.employee_id = tc.employee_id
GROUP BY e.employee_id, p.first_name, p.last_name, p.email, r.role_name
ORDER BY number_of_trips_assigned DESC, p.last_name;

-- Part 2: Medium Queries

-- Query 1: Find the total number of passengers per category for each trip, including trips with no passengers
SELECT 
    t.trip_id,
    t.departure_datetime,
    s1.station_name AS start_station,
    s2.station_name AS end_station,
    pc.category_name,
    COALESCE(SUM(tp.passenger_count), 0) AS total_passengers
FROM Trip t
JOIN Route r ON t.route_id = r.route_id
JOIN Station s1 ON r.start_station_id = s1.station_id
JOIN Station s2 ON r.end_station_id = s2.station_id
CROSS JOIN PassengerCategory pc
LEFT JOIN TripPassenger tp ON t.trip_id = tp.trip_id AND pc.category_id = tp.category_id
GROUP BY t.trip_id, t.departure_datetime, s1.station_name, s2.station_name, pc.category_name
ORDER BY t.trip_id, pc.category_name;

-- Query 2: Find routes that share the same start station (self-join)
SELECT 
    r1.route_id AS route1_id,
    r1.end_station_id AS route1_end_station,
    s1.station_name AS route1_end_station_name,
    r2.route_id AS route2_id,
    r2.end_station_id AS route2_end_station,
    s2.station_name AS route2_end_station_name,
    s_start.station_name AS shared_start_station
FROM Route r1
JOIN Route r2 ON r1.start_station_id = r2.start_station_id AND r1.route_id < r2.route_id
JOIN Station s_start ON r1.start_station_id = s_start.station_id
JOIN Station s1 ON r1.end_station_id = s1.station_id
JOIN Station s2 ON r2.end_station_id = s2.station_id
ORDER BY r1.route_id, r2.route_id;

-- Query 3: Find all trains with their eligible routes, including trains that are not eligible for any route
SELECT 
    t.train_id,
    t.status AS train_status,
    t.year_introduced,
    r.route_id,
    s1.station_name AS route_start_station,
    s2.station_name AS route_end_station,
    r.status AS route_status
FROM RouteTrainEligibility rte
RIGHT JOIN Train t ON rte.train_id = t.train_id
LEFT JOIN Route r ON rte.route_id = r.route_id
LEFT JOIN Station s1 ON r.start_station_id = s1.station_id
LEFT JOIN Station s2 ON r.end_station_id = s2.station_id
ORDER BY t.train_id, r.route_id;

-- Query 4: Demonstrate Person generalisation - Show all persons with their subtype information
SELECT 
    p.person_id,
    p.first_name,
    p.last_name,
    p.email,
    p.phone,
    CASE 
        WHEN e.employee_id IS NOT NULL THEN 'Employee'
        WHEN pass.passenger_id IS NOT NULL THEN 'Passenger'
        ELSE 'Neither'
    END AS person_type,
    r.role_name AS employee_role,
    e.hire_date,
    pass.loyalty_member,
    pass.membership_tier
FROM Person p
LEFT JOIN Employee e ON p.person_id = e.person_id
LEFT JOIN Role r ON e.role_id = r.role_id
LEFT JOIN Passenger pass ON p.person_id = pass.person_id
ORDER BY p.last_name, p.first_name;

-- Part 3: Advanced Queries

-- Query 1: Find trips that have more total passengers than the average number of passengers per trip
SELECT 
    t.trip_id,
    t.departure_datetime,
    s1.station_name AS start_station,
    s2.station_name AS end_station,
    total_passengers.total_passenger_count,
    (SELECT AVG(total_pass) 
     FROM (SELECT SUM(tp2.passenger_count) AS total_pass 
           FROM TripPassenger tp2 
           GROUP BY tp2.trip_id) AS avg_calc) AS average_passengers_per_trip
FROM Trip t
JOIN Route r ON t.route_id = r.route_id
JOIN Station s1 ON r.start_station_id = s1.station_id
JOIN Station s2 ON r.end_station_id = s2.station_id
JOIN (SELECT trip_id, SUM(passenger_count) AS total_passenger_count
      FROM TripPassenger
      GROUP BY trip_id) AS total_passengers ON t.trip_id = total_passengers.trip_id
WHERE total_passengers.total_passenger_count > (
    SELECT AVG(total_pass) 
    FROM (SELECT SUM(tp3.passenger_count) AS total_pass 
          FROM TripPassenger tp3 
          GROUP BY tp3.trip_id) AS avg_calc
)
ORDER BY total_passengers.total_passenger_count DESC;

-- Query 2: Find employees who have worked on trips for at least 50% of the routes that train 101 is eligible for
SELECT 
    e.employee_id,
    p.first_name,
    p.last_name,
    p.email,
    r.role_name,
    COUNT(DISTINCT t.route_id) AS routes_worked_on,
    (SELECT COUNT(DISTINCT rte2.route_id) 
     FROM RouteTrainEligibility rte2 
     WHERE rte2.train_id = 101) AS total_eligible_routes,
    ROUND(COUNT(DISTINCT t.route_id) * 100.0 / 
          (SELECT COUNT(DISTINCT rte3.route_id) 
           FROM RouteTrainEligibility rte3 
           WHERE rte3.train_id = 101), 2) AS percentage_coverage
FROM Employee e
JOIN Person p ON e.person_id = p.person_id
JOIN Role r ON e.role_id = r.role_id
JOIN TripCrew tc ON e.employee_id = tc.employee_id
JOIN Trip t ON tc.trip_id = t.trip_id
WHERE t.route_id IN (
    -- Only consider routes that train 101 is eligible for
    SELECT rte.route_id
    FROM RouteTrainEligibility rte
    WHERE rte.train_id = 101
)
GROUP BY e.employee_id, p.first_name, p.last_name, p.email, r.role_name
HAVING COUNT(DISTINCT t.route_id) * 100.0 / 
       (SELECT COUNT(DISTINCT rte4.route_id) 
        FROM RouteTrainEligibility rte4 
        WHERE rte4.train_id = 101) >= 50
ORDER BY percentage_coverage DESC, p.last_name;

-- Query 3: Find routes where more than 90% of trips use trains introduced in 2018 or later
SELECT 
    r.route_id,
    s1.station_name AS start_station,
    s2.station_name AS end_station,
    COUNT(t.trip_id) AS total_trips,
    COUNT(CASE WHEN tr.year_introduced >= 2018 THEN 1 END) AS trips_with_recent_trains,
    ROUND(COUNT(CASE WHEN tr.year_introduced >= 2018 THEN 1 END) * 100.0 / COUNT(t.trip_id), 2) AS percentage_recent_trains
FROM Route r
JOIN Station s1 ON r.start_station_id = s1.station_id
JOIN Station s2 ON r.end_station_id = s2.station_id
JOIN Trip t ON r.route_id = t.route_id
JOIN Train tr ON t.train_id = tr.train_id
GROUP BY r.route_id, s1.station_name, s2.station_name
HAVING COUNT(CASE WHEN tr.year_introduced >= 2018 THEN 1 END) * 100.0 / COUNT(t.trip_id) > 90
ORDER BY percentage_recent_trains DESC;

-- Query 4: Find employees (using Person generalisation) and show if they are also passengers
SELECT 
    p.person_id,
    p.first_name,
    p.last_name,
    p.email,
    r.role_name AS employee_role,
    e.hire_date,
    CASE 
        WHEN pass.passenger_id IS NOT NULL THEN 'Yes'
        ELSE 'No'
    END AS is_also_passenger,
    pass.loyalty_member,
    pass.membership_tier AS passenger_tier,
    COUNT(DISTINCT tc.trip_id) AS trips_as_employee,
    (SELECT COUNT(*) 
     FROM Employee e2 
     WHERE e2.role_id = e.role_id) AS total_employees_in_role
FROM Person p
INNER JOIN Employee e ON p.person_id = e.person_id
LEFT JOIN Passenger pass ON p.person_id = pass.person_id
LEFT JOIN Role r ON e.role_id = r.role_id
LEFT JOIN TripCrew tc ON e.employee_id = tc.employee_id
GROUP BY p.person_id, p.first_name, p.last_name, p.email, r.role_name, e.hire_date, 
         pass.passenger_id, pass.loyalty_member, pass.membership_tier, e.role_id
HAVING COUNT(DISTINCT tc.trip_id) > (
    SELECT AVG(trip_count)
    FROM (
        SELECT COUNT(DISTINCT tc2.trip_id) AS trip_count
        FROM Employee e3
        LEFT JOIN TripCrew tc2 ON e3.employee_id = tc2.employee_id
        GROUP BY e3.employee_id
    ) AS avg_trips
)
ORDER BY trips_as_employee DESC, p.last_name, p.first_name;
-- Eurostar Database Schema
-- Created based on ER Model and Logical Model

-- Create database
DROP DATABASE IF EXISTS ecs519;
CREATE DATABASE ecs519;
USE ecs519;

-- Drop tables if they exist (in reverse dependency order)
DROP TABLE IF EXISTS TripPassenger;
DROP TABLE IF EXISTS TripCrew;
DROP TABLE IF EXISTS Trip;
DROP TABLE IF EXISTS Employee;
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

-- Create Employee table
CREATE TABLE Employee (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    role_id INT,
    FOREIGN KEY (role_id) REFERENCES Role(role_id)
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


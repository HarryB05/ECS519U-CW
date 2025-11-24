# ER Model (textual)

## Entities

| Entity | Attributes |
|--------|------------|
| Station | station_id, station_name, city, country |
| Route | route_id, status, distance_miles, journey_time_minutes, start_station_id, end_station_id |
| RouteStation | route_id, station_id, stop_order |
| Train | train_id, status, year_introduced |
| RouteTrainEligibility | route_id, train_id |
| Role | role_id, role_name |
| Employee | employee_id, first_name, last_name, role_id |
| Trip | trip_id, route_id, train_id, departure_datetime, arrival_datetime |
| TripCrew | trip_id, employee_id, crew_role_description |
| PassengerCategory | category_id, category_name |
| TripPassenger | trip_id, category_id, passenger_count |
---

## Relationships

| Relationship | Connected Entities | Cardinality |
|--------------|-------------------|-------------|
| Start/End Station | Route, Station | 1:M |
| Route Stops | Route, Station (via RouteStation) | M:N |
| Train Eligibility | Route, Train (via RouteTrainEligibility) | M:N |
| Employees Belong to Role | Role, Employee | 1:M |
| Trips Run on Routes | Trip, Route | M:1 |
| Trips Use Trains | Trip, Train | M:1 |
| Crew Assignment | Trip, Employee (via TripCrew) | M:N |
| Passenger Counts Per Trip | Trip, PassengerCategory (via TripPassenger) | M:N |

## Cardinality & participation rationale

| Relationship | Participation | Rationale |
|--------------|---------------|-----------|
| Route (Start Station) | Route (Mandatory), Station (Optional) | Every route must have exactly one start station. A station may exist in the database before being assigned to any route (e.g., planned stations). |
| Route (End Station) | Route (Mandatory), Station (Optional) | Every route must have exactly one end station. A station does not have to be used as a terminal station to exist in the system. |
| Route, Stops (via RouteStation) | Both Participation Optional | A route may have zero or many intermediate stops (planned routes may have none yet). A station does not need to appear as a stop to exist in the system. |
| Route, Train Eligibility (via RouteTrainEligibility) | Both Participation Optional | A route may not yet have eligible trains (if newly introduced). A train may not be eligible for any route (e.g., being temporarily retired). |
| Role, Employee | Role (Mandatory), Employee (Optional) | A role must exist before employees can be assigned to it. However, a role may exist without assigned employees (e.g., hiring pending). |
| Trip, Route | Trip (Mandatory), Route (Optional) | Every trip must follow exactly one route. A route may exist without any trips yet (e.g., planned route not operating yet). |
| Trip, Train | Trip (Mandatory), Train (Optional) | Every trip needs one assigned train. However, trains may exist without currently running trips (e.g., repaired or stored trains). |
| Trip, Employee (via TripCrew) | Trip (Optional), Employee (Optional) | A trip may not yet have crew assigned (future scheduling). An employee may not be assigned to any upcoming trip (off-duty days). |
| Trip, PassengerCategory (via TripPassenger) | Trip (Optional), PassengerCategory (Optional) | A trip might have zero recorded passengers of a category, and categories can exist before usage (e.g., new student ticket defined but not used yet). |

# Logical model


## Station

| Column | Type | Notes |
|--------|------|-------|
| station_id | INT | Primary Key, uniquely identifies each station |
| station_name | VAR CHAR | Eg London Paddington |
| city | VAR CHAR | |
| country | VAR CHAR | |

## Route

| Column | Type | Notes |
|--------|------|-------|
| route_id | INT | Primary Key |
| start_station_id | INT | Foreign Key to Station.station_id |
| end_station_id | INT | Foregin Key to Station.station_id |
| distance_miles | INT | Total length of the route |
| journey_time_minutes | INT | Total journey duration |
| status | VARCHAR |
E.g. �Planned� or �Operational�

## RouteStation

| Column | Type | Notes |
|--------|------|-------|
| route_id | INT | Foreign Key to Route.route_id |
| station_id | INT | Foreign Key to Station.station_id |
| stop_order | INT | Sequence of stops along the route |

## Train

| Column | Type | Notes |
|--------|------|-------|
| train_id | INT | Primary Key |
| year_introduced | INT | Used to check eligibility for some routes |
| status | VARCHAR |
E.g. �Operating�, �Under Repair� etc

## RouteTrainEligibility

| Column | Type | Notes |
|--------|------|-------|
| route_id | INT | Foreign Key to Route.route_id (part of a composite PK) |
| train_id | INT | Foreign Key to Train.train_id (part of a composite PK) |

## Role

| Column | Type | Notes |
|--------|------|-------|
| role_id | INT | Primary Key |
| role_name | VARCHAR |
E.g. �Driver�, �Service Crew� etc

## Employee

| Column | Type | Notes |
|--------|------|-------|
| employee_id | INT | Primary Key |
| first_name | VARCHAR | |
| last_name | VARCHAR | |
| role_id | INT | Foreign Key to Role.role_id |

## Trip

| Column | Type | Notes |
|--------|------|-------|
| trip_id | INT | Primary Key |
| route_id | INT | Foreign Key to Route.route_id |
| train_id | INT | Foreign Key to Train.train_id |
| departure_datetime | DATETIME | |
| arrival_datetime | DATETIME | |

## TripCrew

| Column | Type | Notes |
|--------|------|-------|
| trip_id | INT | Foreign Key to Trip.trip_id (part of a composite PK) |
| employee_id | INT | Foreign Key to Employee.employee_id (part of a composite PK) |
| crew_role_description | VARCHAR |
Aditional role details, E.g. �Head of Staff� etc

## PassengerCatagory

| Column | Type | Notes |
|--------|------|-------|
| category_id | INT | Primary Key |
| category_name | VARCHAR | E.g. Student, Adult, Child etc |

## TripPassenger

| Column | Type | Notes |
|--------|------|-------|
| trip_id | INT | Foreign Key to Trip.trip_id (part of a composite PK) |
| category_id | INT | Foreign Key to PassengerCategory.category_id (part of a composite PK) |
| passenger_count | INT | Number of passengers on this type of trip |

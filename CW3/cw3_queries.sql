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
    e.first_name,
    e.last_name,
    r.role_name,
    COUNT(tc.trip_id) AS number_of_trips_assigned
FROM Employee e
JOIN Role r ON e.role_id = r.role_id
LEFT JOIN TripCrew tc ON e.employee_id = tc.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name, r.role_name
ORDER BY number_of_trips_assigned DESC, e.last_name;

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
    e.first_name,
    e.last_name,
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
JOIN Role r ON e.role_id = r.role_id
JOIN TripCrew tc ON e.employee_id = tc.employee_id
JOIN Trip t ON tc.trip_id = t.trip_id
WHERE t.route_id IN (
    -- Only consider routes that train 101 is eligible for
    SELECT rte.route_id
    FROM RouteTrainEligibility rte
    WHERE rte.train_id = 101
)
GROUP BY e.employee_id, e.first_name, e.last_name, r.role_name
HAVING COUNT(DISTINCT t.route_id) * 100.0 / 
       (SELECT COUNT(DISTINCT rte4.route_id) 
        FROM RouteTrainEligibility rte4 
        WHERE rte4.train_id = 101) >= 50
ORDER BY percentage_coverage DESC, e.last_name;

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
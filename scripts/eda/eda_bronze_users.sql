
-- Exploratory Data Analysis

-- Check for null and duplicates
-- Expectations: No Results

SELECT
id,
COUNT(*)
FROM bronze.users
GROUP BY id
HAVING COUNT(*) > 1;

SELECT id FROM bronze.users WHERE id IS NULL;

SELECT email, COUNT(*) FROM bronze.users
GROUP BY email HAVING COUNT(*) > 1;

SELECT username, COUNT(*) FROM bronze.users
GROUP BY username HAVING COUNT(*) > 1;

-- Check for unwanted spaces
-- Expectations: No Results

SELECT firstName FROM bronze.users
WHERE firstName != TRIM(firstName);

SELECT lastName FROM bronze.users
WHERE lastName != TRIM(lastName);

SELECT maidenName FROM bronze.users
WHERE maidenName != TRIM(maidenName);

SELECT gender FROM bronze.users
WHERE gender != TRIM(gender);

SELECT email FROM bronze.users
WHERE email != TRIM(email);

SELECT phone FROM bronze.users
WHERE phone != TRIM(phone);

SELECT username FROM bronze.users
WHERE username != TRIM(username);

SELECT password FROM bronze.users
WHERE password != TRIM(password);

SELECT image FROM bronze.users
WHERE image != TRIM(image);

SELECT bloodGroup FROM bronze.users
WHERE bloodGroup != TRIM(bloodGroup);

SELECT eyeColor FROM bronze.users
WHERE eyeColor != TRIM(eyeColor);

SELECT macAddress FROM bronze.users
WHERE macAddress != TRIM(macAddress);

SELECT university FROM bronze.users
WHERE university != TRIM(university);

SELECT ein FROM bronze.users
WHERE ein != TRIM(ein);

SELECT ssn FROM bronze.users
WHERE ssn != TRIM(ssn);

SELECT userAgent FROM bronze.users
WHERE userAgent != TRIM(userAgent);

SELECT role FROM bronze.users
WHERE role != TRIM(role);

-- Data Standardization & Consistency

SELECT DISTINCT gender
FROM bronze.users;

SELECT DISTINCT bloodGroup
FROM bronze.users;

SELECT DISTINCT eyeColor
FROM bronze.users;

SELECT DISTINCT role
FROM bronze.users;

SELECT DISTINCT university
FROM bronze.users;

-- Check for invalid numeric values

SELECT * FROM bronze.users
WHERE id <= 0;

SELECT * FROM bronze.users
WHERE age < 0 OR age > 100 
	OR height < 0 OR height > 250
	OR weight < 0 OR weight > 300;

SELECT ssn FROM bronze.users
WHERE ssn NOT LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9]';

SELECT ein FROM bronze.users
WHERE ein NOT LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9]';

SELECT macAddress FROM bronze.users
WHERE macAddress NOT LIKE '[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]';

SELECT id, birthDate, age,
DATEDIFF(YEAR, birthDate, GETDATE()) AS calculted_age
FROM bronze.users
WHERE age != DATEDIFF(YEAR, birthDate, GETDATE());

SELECT * FROM bronze.users
WHERE birthDate > GETDATE() OR birthDate < '1900-01-01';

-- Validity check

SELECT * FROM bronze.users WHERE ISJSON(hair) = 0;
SELECT * FROM bronze.users WHERE ISJSON(address) = 0;
SELECT * FROM bronze.users WHERE ISJSON(bank) = 0;
SELECT * FROM bronze.users WHERE ISJSON(company) = 0;
SELECT * FROM bronze.users WHERE ISJSON(crypto) = 0;

SELECT email FROM bronze.users
WHERE email NOT LIKE '%_@_%._%';

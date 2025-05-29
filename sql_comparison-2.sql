-- Purpose: To analyze tickets for a specific division
-- Incidents
SELECT
    vs.[Server Name], -- Server Name column first
    inc.*,
    vs.*
FROM
    YourIncidentsTable AS inc
JOIN
    YourServerDetailsView AS vs
ON
    inc.[cmdb_ci] = vs.[Server Name]
WHERE
    inc.[service_offering] IN ('Service Offering 1', 'Service Offering 2')
    --AND inc.[opened_at] BETWEEN '2022-01-20' AND '2023-01-20'
    AND inc.[opened_at] > '2022-01-01'
    AND vs.[Division] = 'YourDivision'


/*
-- Requests
SELECT
    vs.[Server Name], -- Server Name column first
    req.*,
    vs.*
FROM
    YourRequestsTable AS req
JOIN
    YourServerDetailsView AS vs
ON
    req.[cmdb_ci] = vs.[Server Name]
WHERE
    [Division]= 'YourDivision'
*/

/*
-- System Count
SELECT
    --COUNT(*) AS SystemCount
    *
FROM
    YourServerDetailsView
WHERE
    [is SCCM Client] = 1
    AND [Division] = 'YourDivision';

-- Count specific functions
SELECT
    [Function],
    COUNT(*) AS FunctionCount
FROM
    YourServerDetailsView
WHERE
    [is SCCM Client] = 1
    AND [Division] = 'YourDivision'
    AND [Function] IN ('Function1', 'Function2')
GROUP BY
    [Function];


-- Count the number of systems for each site
SELECT
    [Site Name],
    COUNT(*) AS SystemCount
FROM
    YourServerDetailsView
WHERE
    [is SCCM Client] = 1
    AND [Division] = 'YourDivision'
GROUP BY
    [Site Name];
*/

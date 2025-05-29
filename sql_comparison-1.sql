USE YourDatabaseName

SELECT *, 
       (DATEDIFF(SECOND,[opened_at],[sys_updated_on]) / 3600.0) as TTR_Hours,
        CASE
           WHEN (DATEDIFF(SECOND,[opened_at],[sys_updated_on]) / 3600.0) <= 72 THEN 'Short (<= 3 Days)'
           WHEN (DATEDIFF(SECOND,[opened_at],[sys_updated_on]) / 3600.0) <= 168 THEN 'Long (<= 7 Days)'
           WHEN (DATEDIFF(SECOND,[opened_at],[sys_updated_on]) / 3600.0) <= 336 THEN 'Very Long (<= 14 Days)'
           ELSE 'Extremely Long (> 14 Days)'           
       END AS TTR_Duration,
       CASE
           WHEN short_description LIKE '%Health Service Heartbeat%' THEN 'Heartbeat Failure'
           WHEN short_description LIKE '%Failed to Connect to Computer%' THEN 'Connection Failure'
           WHEN short_description LIKE '%was not accessible%' THEN 'Connection Failure'
           WHEN short_description LIKE '%Responding to ping but unable to access%' THEN 'Connection Failure'
           WHEN short_description LIKE '%No ping%' THEN 'Connection Failure'
           WHEN short_description LIKE '%HPE Windows (OneView)%' THEN 'HPE Hardware Issue (OneView)'
           WHEN short_description LIKE '%HP Disk Failure Check%' THEN 'Disk Failure Check'
           WHEN short_description LIKE '%HP Windows (SNMP)%' THEN 'HPE Hardware Issue (SNMP)'
           WHEN short_description LIKE '%Breakfix%' THEN 'Breakfix'
           ELSE short_description
       END AS Updated_Short_Description,
       CASE
           WHEN Manufacturer LIKE '%HP%' THEN 'HPE'
           ELSE Manufacturer
       END AS Manufacturer_Updated
FROM YourIncidentsTable I
INNER JOIN YourAssetsTable A ON I.cmdb_ci = A.Hostname
WHERE I.cmdb_ci NOT LIKE 's/n%'
  AND I.cmdb_ci NOT LIKE 'Missing CI%'
  AND contact_type NOT LIKE 'Self-service%'
  AND contact_type NOT LIKE 'Phone%'
  AND contact_type NOT LIKE 'Chat'
  AND contact_type NOT LIKE 'Email'
  AND I.cmdb_ci NOT LIKE 'HPC%'
  AND I.cmdb_ci NOT LIKE 'windows%'
  AND I.cmdb_ci NOT LIKE '%-%'
  AND I.cmdb_ci != '2FF70002AC029425'
  AND i.short_description NOT LIKE '%Logical Disk Free Space is low%'
  AND i.short_description NOT LIKE '%DFS-R%'
  AND i.short_description NOT LIKE '%VNC viewer%'
  AND i.short_description NOT LIKE '%Cluster%'
  AND i.short_description NOT LIKE '%MSSQL%'
  AND i.short_description NOT LIKE '%AV Scanners%'
  AND i.short_description NOT LIKE '%API Name Resolution Check Failed%'
  AND i.short_description NOT LIKE '%IAPM%'
  AND i.short_description NOT LIKE '%DRV fail in%'
  AND i.short_description NOT LIKE 'BigPanda%'
  AND i.short_description NOT LIKE '%Physical drive status predictive failure%'
  AND i.short_description NOT LIKE '%%reboot%'
  AND i.short_description NOT LIKE '%memory error%'
  AND i.short_description NOT LIKE '%failed drive%'
  AND i.short_description NOT LIKE '%/ CPU'
  AND i.short_description NOT LIKE '%Hardware status is critical%'
  AND a.Manufacturer NOT LIKE 'Microsoft%'

SELECT name, 
		               email,
		               score,
		               CONCAT( (CASE length(score_hours) WHEN 1 THEN  CONCAT('0',score_hours)
                                                                                                        WHEN 2 THEN score_hours END),
                                                 ':',                                                 
                                                (CASE length(score_minutes) WHEN 1 THEN  CONCAT('0',score_minutes)
                                                                                                        WHEN 2 THEN score_minutes END),
                                                ':',
                                                 (CASE length(score_seconds) WHEN 1 THEN  CONCAT('0',score_seconds)
                                                                                                        WHEN 2 THEN score_seconds END),
                                                ':',
                                                 (CASE length(score_tenths) WHEN 1 THEN  CONCAT('0',score_tenths)
                                                                                                        WHEN 2 THEN score_tenths END)) 
                                                                                                        as score_as_time
FROM scores 
ORDER BY score ASC LIMIT 10;
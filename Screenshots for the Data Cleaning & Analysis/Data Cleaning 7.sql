/* Each company in the accounts table wants to create an email address for each primary_poc. The email address 
should be the first name of the primary_poc . last name primary_poc @ company name .com. */

WITH t1 AS (
            SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ') -1 ) first_name,  
             RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
              FROM accounts)
  SELECT first_name, last_name, CONCAT(first_name, '. ', last_name, '@', name, '.com')
FROM t1;

-- Staging model with synthetic customer data
-- In production, this would typically select from a raw source table

with raw_customers as (
    select * from (
        values
            (1, 'Alice', 'Johnson', 'alice.johnson@gmail.com'),
            (2, 'Bob', 'Smith', 'bob.smith@company.org'),
            (3, 'Carol', 'Williams', 'carol.w@startup.io'),
            (4, 'David', 'Brown', 'david.brown@university.edu'),
            (5, 'Emma', 'Davis', 'emma_davis@work.net'),
            (6, 'Frank', 'Miller', 'frank.miller@government.gov'),
            (7, 'Grace', 'Wilson', 'grace@invalid'),
            (8, 'Henry', 'Moore', 'not-an-email'),
            (9, 'Ivy', 'Taylor', 'ivy.taylor@techstartup.ai'),
            (10, 'Jack', 'Anderson', 'jack123@webapp.app'),
            (11, 'Karen', 'Thomas', 'karen.thomas@mysite.co'),
            (12, 'Leo', 'Jackson', 'leo@developer.dev'),
            (13, 'Mia', 'White', 'mia.white@fake.xyz'),
            (14, 'Noah', 'Harris', 'noah_harris@business.biz'),
            (15, 'Olivia', 'Martin', NULL)
    ) as t(customer_id, first_name, last_name, email)
)

select
    customer_id,
    first_name,
    last_name,
    email,
    -- Extract top-level domain from email (e.g., 'com' from 'user@example.com')
    case
        when email is not null and email like '%@%.%'
        then lower(split_part(email, '.', -1))
        else null
    end as email_top_level_domain
from raw_customers

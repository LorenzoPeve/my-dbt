-- Valid top-level email domains
select tld
from (
    values
        ('com'),
        ('org'),
        ('net'),
        ('edu'),
        ('gov'),
        ('io'),
        ('co'),
        ('ai'),
        ('dev'),
        ('app')
) as t(tld)

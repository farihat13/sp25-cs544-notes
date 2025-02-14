# Databases and SQL

## File formats

cache line 64 bytes

major access patterns
- transaction processing - row-wise
- analytics processing - column-wise

csv is row-oriented file format; good format for reading row-wise, bad for column-wise

parquet is column-oriented

|          |    csv   | parquet  |  
| -----    | -------- | -------- | 
| orient   | row      | col      |
| encoding | text     | binary   |
| compression | -     | snappy   |
| schemea  | inferred | explicit |

snappy compression is faster but not optimized. gzip is slower but optimized compression.

## database

main database types
- OLTP (online transactions processing) (row oriented)
- OLAP (online analytics processing) (column oriented)

Data warehouse: The OLAP database where we combine data from many sources

ETL: extract-transform-load (process from getting data out of OLTP DBs and into OLAP DB)

## ACID

- atomicity: all happens or nothing happpens
- consistency: app invariants are always maintained (e.g. never neg balance)
- isolation: others can't see a transaction in progress
- durability: once finished, it persists

NoSQL databases does not have all of the ACID properties.

## SQL

[SQL query summary](./query.png)

install and run
  
```bash
pip3 install SQLAlchemy mysql-connector-python
docker run -d -m "1g" -p 127.0.0.1:3306:3306 -e MYSQL_DATABASE=cs544 -e MYSQL_ROOT_PASSWORD=abc mysql
docker exec -it <CONTAINER> bash
mysql -p cs544
```
in mysql

`show tables;`
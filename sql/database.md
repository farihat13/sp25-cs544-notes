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

### Install and run
  
```bash
pip3 install SQLAlchemy mysql-connector-python
```

```bash
docker run -d --name mysql-container \
    -m "1g" \
    -p 127.0.0.1:3306:3306 \
    -e MYSQL_DATABASE=cs544 \
    -e MYSQL_ROOT_PASSWORD=abc \
    --platform linux/amd64 \
    mysql:oraclelinux8
docker exec -it mysql-container bash
mysql -p cs544
```

```sql
-- inside mysql
show tables;
create table users (id int, name text NOT NULL, phone text, primary key(id));
insert into users values (1, 'John', '123-456-7890');
select * from users;
select * from users limit 3;
select count(*) from users;
select * from users where id = 1;
select * from users where id = 1 and name = 'John';
```
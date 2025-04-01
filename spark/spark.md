# Map Reduce and Spark

## Data Lakes

Data Warehouse
- storage and compute tightly coupled
- optimized for structured data and SQL queries
- predefined schema and storage layout
- efficient, but limited flexibility 

Data Lake
- store raw, unstructured, or semi-structured data, e.g., images, logs, videos, CSVs, Parquet
- decouple storage and compute, e.g., HDFS + Spark
- more scalable and flexible than a warehouse.
- supports diverse processing engines, e.g., Spark, Hive, PyTorch


## Map Reduce

Phases
1. map phase: mappers read input and emit intermediate (key, value) pairs
2. shuffle phase: intermediate data is grouped by key and sent to reducers
3. reduce phase: reducers aggregate values per key and write final output

- mapper reducer
    - each job runs multiple mappers and multiple reducers, depending on data size and cluster resources
    - each mapper processes a block of input data, e.g., an HDFS chunk
    - mappers run in parallel on multiple machines 
    - all intermediate key value pairs grouped and sorted by key during shuffle phase
    - each reducer handles a subset of keys
    - each reducer writes its results into one output file
- map() function:  
    - output: zero or more (key, value) pairs
    - called once per input row, e.g., if a mapper gets 10,000 rows, it calls map() 10,000 times
- reduce() function: 
    - input: single key, all values corresponding to the key
    - called once per key, it receives all values for that key, e.g., if a reducer handles 100 different keys, it will call reduce() 100 times
- output files


Why map reduce?
- more flexible than SQL

HiveQL
- a sql-like layer on top of map reduce, makes map reduce more flexible

Data locality 
- tries to schedule map tasks on the same machines where data resides to avoid network transfers

Pipelines 
- sequence of mapreduce jobs, often used in real-world
- mapreduce treats each stage seperately, hard to optimize
    - each mapreduce job in a pipeline writes to hdfs, the next reads from it, inefficient
    - spark improves on this: instead of hdfs files, intermediate data is RDD 


## Spark

### RDDs (Resilient Distributed Datasets)
like a recipe of cake, instead of the actual cake

- **data lineage**: history of transformation
- lazy evaluation
- immutable

Two types of operations
- transformation: create a new RDD, no execution yet
    - parellelize(), map(), filter()
- actions: execute ops to get actual resutls
    - collect(), show(), toPandas()

Optimization 
- if operation known to spark, then spark optimizes (e.g, filter before mult) 
- if custom user operations, then no optimization

Partitions
- what granularity should data flow?
    - whole dataset: memory bottleneck
    - row: overhead to process each row seperately
    - partition: trade-off 
- in spark, data is split into partitions.

Spark Tasks
- runs on a single cpu core
- operates on a single partiton, which is loaded entiredly in memory
- partition count directly affects number of tasks

Partition size trade-offs
- too small: too many tasks.
- too large: memory bottlenecks, poor parallelism

Repartitioning
- useful when data size grow/shrink after transforamtion
- might cause network traffic
- after repartitioning, later computation might be faster
```python
rdd = rdd.repartition(1)
```

Transformations
- Narrow
    - 1 input partition -> 1 output partition 
    - e.g, map, filter
- Wide
    - multiple input partiions -> 1 output partion
    - e.g., groupByKey, join
    - network IO if all input partition not in same machine

Caching and Persistence
- avoid re-computing expensive RDDs
- rdd cached after first compute (materialization)
```python
rdd.cache()
rdd.unpersist()
```

Spark API
- SQL
    - on top of RDDs
- Dataframes    
    - on top of SQL

### Deployment

Spark driver
Spark session
cluster manager
Spark executor

### Spark code snippets

```python
a = spark.sql("""
SELECT * FROM calls
""") # a is a 
a.toPandas() # ...
a.show() # ...
```

localhost:4040/


```python
spark.sql("SHOW TABLES").show() # 
```
```python
.write.saveAsTable("calls") # calls is table name
# check table
!hdfs dfs -ls hdfs://nn:9000/user/hive/warehouse # won't see for views
# check table
!hdfs dfs -ls hdfs://nn:9000/user/hive/warehouse/calls

```

## Table and Views

- which one faster to create
- which one takes less space
- which one is faster if we run a query on it


## Grouping

Distinct
Grouping by aggragates
Partitions, window functions
Nested/chained grouppig


```python
# two eqiveable qurey
# how many calls are there per call group/type?
spark.sql("""
SELECT Call_Type_Group, Call_Type, COUNT(*) as cnt
FROM calls
GROUP BY Call_Type_Group, Call_Type
ORDER BY cnt DESC
""").toPandas()

# or 
spark.table("calls")
    .groupby("Call_Type_Group", "Call_Type")
    .count()
```

## Joins
- inner join 
- equi join
- left join

# Spark performance

## schema inference
- parquet is best for loading data

## collecting data
- might output overwhelem RAM

## persisteing/ caching

persist levels 
- memory only (`df.cache()`)
- memory only, serialized ( convert java objects to serialized bytes representation, java objects are bloated due to obj headers (16 to 40 bytes))
    - serialize, deser cost
- disk only
when caching, only that worker will always be used for that data, load imbalance
- with 2x replications
    - two choices of worker when using the cache
    - better load balance

## webapi

```
r = requests.get(f"http://localhost:4040/api/v1/applications/{app_id}/executors")
r.raise_for_status()
[executor["totalTasks"] for executor in r.json()]
```

## aggregates on partions

optimization
- partial aggregate before sending partiotn
- enable adaptive coalstee partions (default 200 shuffle partiton)
- bucketed data
    might skip exchange
```
.explain("formatted")
# shows excahage or not duirng hash prtion
# partial cout
# coutn
```

## hash join vs sort merge join

bhj: broadcast hash join
 - network io:  ( copy of smaller table send to all machine)
smj: shuffle sort merge join
    - shuffle sort (bring same keys in same machine)
    what if one key data does not fit in a single machine ram?
    - network io: each table go over network once

```
.hint("merge")
```
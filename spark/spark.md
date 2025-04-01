# Data lake

Data warehouse
- choose storage layout

Data lakes

# Map Reduce

- map function:  
    - output: (key, value)
    - calls map() for each row
    - mappers in machines
    - intermediate data grouped and sorted by key
- reduce function: 
    - input: single key, all values corresponding to the key
    - reducer
    - each reducer produce one output file 
- mapper reducer counts
- output files

map phase
shuffle phase
reduce phase

map reduce more flexible than SQL

HiveQL - makes map reduce more flexible

Data locality 
- Avoid network transfers

Pipelines 
- sequence of mapreduce jobs
- mapreduce treats each stage seperately, hard to optimize
- efficiency: instead of storing intermediate mapreduce results in hdfs, connect directly
    - in spark, instead of hdfs files, intermediate data is RDD 


# Spark

## RDDs (Resilient distributed datastes)
like a recipe of cake, instead of the actual cake
- **data lineage**
- lazy eval
- immutable



parellelize()
map()
filter()
collect()
two types of operations
    - transformation: create a new RDD, no execution yet
    - actions: execute ops to get actual resutls

optimizations, if operation known to spark, if custom user operations, then no optimization.

partitions
what granularity should data flow?
- whole dataset
- row
- partition


Runs with spark Tasks
- runs on a single cpu core
- operates on a single partiton, which is loaded entiredly in memory

Partition count directly affects number of tasks

pros and cons of partition size


Repartitioning
- necessary since data might grow/shrink after transforamtion
- might cause network traffic
- later computation might be faster
`.repartition(1)`


Transformations
- Narrow
    - single input partition -> single output partition
- Wide
    - multiple input partiion needed for single output partion
    - network IO if all input partition not in same machine

Caching
- rdd materialized cached after first compute
`.cache()`
`.unpersist()`

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
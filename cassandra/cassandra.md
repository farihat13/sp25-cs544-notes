# Wide Tables: HBase and Cassandra


## HBase

- Takes inspiration from Bigtable
- Distributed database
- Runs on top of HDFS
    - replication and fault-tolerance logic handled by HDFS

- Data model
    - versioned sparse tables
        - each row can have different columns
        - each cell can have different versions
    - wide row design
        - a single row can have millions of columns
    - rows are sorted by row key
    - region
        - contiguous ranges of row keys
        - **RegionServers** manage regions
            - one region belongs to one RegionServer
            - a RegionServer can serve multiple regions

- Architecture
    - Master-slave model
    - HMaster: coordinates RegionServers (assigning regions, handling splits, etc.)
    - RegionServer: handles reads/writes to the regions it manages
    - If a RegionServer fails, regions are reassigned by the HMaster
        - data is safe due to HDFS replication

- Consistency & Transactions
    - strong consistency at the row level
    - only supports single row transactions
    - keep a single user's data in a single row to ensure atomicity

- Storage layout
    - buffer data as key value pairs in memory, when a threshold is reached, sort and flush the data to a HDFS file
    - **compaction**: merge HDFS files into a single file, throw away old versions
    - writes sequentially, to optimize for throughput

## Cassandra

- Takes inspiration from Bigtable and Dynamo
- Distributed, peer-to-peer NoSQL database (NoSQL means not relational)
- Does not require HDFS
- More complex than HBase, since replication and fault-tolerance logic is handled by itself

- Architecture
    - decentralized, peer-to-peer architecture, all nodes are equal
    - no boss node (unlike HDFS NameNode or Spark driver), only workers
    - nodes are organized in a logical ring (not actual network topology)
    - nodes can be geographically distributed
    - data is distributed via consistent hashing

- Data model
    - **keyspaces**: top-level namespaces for tables
    - wide partition design
        - store many rows under one partition key
        - finite #columns
        - column types        
            - static columns: shared across all rows in a partition; one value per partition
            - clustering columns: define row order within a partition
            - regular columns: typical key-value data
        - partition key column: uniquely identify a partition
            - data is distributed across nodes based on partition key
        - primary key =  partition key + clustering columns
            - unique identifier for a row
        - example [TODO]
- too many partition (metadata overhead) vs too few partitions (load imbalance)


Write & Read Path
Writes:

Go to a commit log (for durability)

Written to Memtable (in-memory)

Flushed to SSTables (on disk) once Memtable is full

Reads:

Check Memtable + Bloom filters + SSTables

Compaction periodically merges SSTables to reduce read overhead

Consistency Model
Tunably consistent

QUORUM, ONE, ALL, etc.

Write/read consistency level can be chosen per query

QUORUM read = returns the most recent write from majority of replicas

Offers eventual consistency by default

### Cassandra commands

```bash
# check node status
nodetool status #U == UP
# view logical ring
nodetool ring
```

```bash
# launch cassandra interactive shell
cqlsh demo-db-1
# inside cqlsh
help
help describe
describe keyspaces
create keyspace banking with replication = {'class': 'SimpleStrategy', 'replication_factor': 2};
describe keyspaces
describe tables
use banking;
describe tables
```

Run JupyterLab on a Cassandra container
```bash 
docker exec -d cassandra-db-1 python3 -m jupyterlab --no-browser --ip=0.0.0.0 --port=5000 --allow-root --NotebookApp.token=''
```

#### python code for cassandra
```python
# inside jupyterlab
from cassandra.cluster import Cluster
# connect to the cluster
cluster = Cluster(["p6-db-1", "p6-db-2", "p6-db-3"])
cass = cluster.connect()
cass.execute("use banking")

# schema:
# - bank_id: partition key (can be identified by double parenthesis, 
#           in absence of double parenthesis, the first column in the primary key is assumed the partition key)
# - bank_name: static column
# - amount, loan_id: clustering columns (`amount` is inside primary key, because we want our data presorted by the amount)
# - state: regular column
cass.execute("drop table if exists loans")
cass.execute("""
CREATE TABLE loans (
    bank_id INT, 
    bank_name text STATIC,
    loan_id UUID,
    amount int,
    state text,
    PRIMARY KEY ((bank_id), amount, loan_id)
) WITH CLUSTERING ORDER BY (amount DESC)
""")

# INSERT in Cassandra is an UPSERT: update or insert
# NOW and UUID generate universally unique identifiers, now provides stronger gurantees
# INSERT of a new row; UPSERT on the partition
cass.execute("""
INSERT INTO loans (bank_id, bank_name, loan_id, amount, state)
VALUES (544, 'mybank', NOW(), 400, 'wi')
""")
```

#### user-defined data type in table
```python
# create a new type for names
cass.execute("""
CREATE TYPE FullName (
    first text,
    last  text
)
""")
cass.execute("""
ALTER TABLE loans ADD (name FullName);
""")
cass.execute("""
INSERT INTO loans (bank_id, bank_name, loan_id, amount, state, name)
VALUES (999, 'uwcu', NOW(), 500, 'il', {first: 'Tyler', last:'C'})
""")
pd.DataFrame(cass.execute("SELECT name.first AS f, name.last AS l FROM loans"))
```


#### prepared statements
- prevents SQL injection
- precompiled and cached, faster execution because cassandra does not need to parse the query multiple times
```python
# prepared statements
inst_stmt = cass.prepare("""
INSERT INTO loans (bank_id, loan_id, amount, name)
VALUES (999, NOW(), ?, {first: ?, last: ?})
""")
cass.execute(inst_stmt, (345, 'Tyler', 'C'))
```

#### group by
- data is partitioned by partition key
- group by with any other key will need a shuffle, which cassandra does not support
- currently only support groups of columns following their declared order in the PRIMARY KEY


## Cassandra Partitioning

HDFS
- block map

Spark
- hash partitioning

Cassandra
- consistent hashing
    - cassandra and dynamo uses it

Scalability
- few large objects vs. many small objects
- HDFS works better with few large objects
- Spark can work with both, better with many small objects, since can balance load

Elasticity
- HDFS will start using it smoothly
- Spark won't support adding new worker in the middle of a job
    - adding a new node will change hash value of a partition --> need to move lots of data
- Cassandra smoothly supports adding new nodes, through consistent hashing


### Consistent hashing
- vnode
- heterogenity: give more tokens to more powerful nodes
- **Token Map**
    - token(node1) = {t1, t2}
    - token(node2) = {t3, t4}
    - token(node2) = {t5, t6, t7, t8} # this ndoe is more powerful thats why we gave it more tokens
    
- token map stored in all nodes
    - update to token map is done via gossip protocol/epidemic algorithm
        - e.g., once per second, choose a random friend, gossip about new nodes


#### Example

Token Map
| physical node | Token Ranges (vnodes) |
|----------|----------------------------|
| Node A   | 0                |
| Node B   | 10, 40                |
| Node C   | 20, 50                |

wrapping range: > 50 

```
Token Ring Layout
    --> 0 --> 10 --> 20 --> 40 --> 50 -->   
  A --> A -->  B -->  C -->  B -->  C -->  A --> 
```

| partition key/row | hash value (token) | assigned to phy node |
|---------------|--------------------|------------------------|
| `user1`       | 5                  | Node B (token 10)      |
| `user2`       | 45                 | Node C (token 50)      |
| `user3`       | 85                 | Node A (token 256)   |
| `user4`       | 15                 | Node C (token 20)      |

**Adding a New Node**

| physical node | Token Ranges (vnodes) |
|----------|----------------------------|
| Node A   | 0                |
| Node B   | 10, 40                |
| Node C   | 20, 50                |
| Node D   | 30, 60                |

```
Token Ring Layout
    --> 0 --> 10 --> 20 --> 30 --> 40 --> 50 --> 60 --> 
  A --> A -->  B -->  C -->  D --> B -->   C -->  D -->  A --> 
```

## Cassandra Replication

read/write quorum

**Replication policy**
- replication factor (RF) defined per keyspace
- RF - 2: 2 copies of data
- `SimpleStrategy`: walk the ring until you find RF nodes, skip same nodes
- you can choose other replication strategies, e.g., `NetworkTopologyStrategy` 
    - useful for multi-datacenter deployments

## Cassandra writes

In distributed systems, **ack** means data is *committed*


- coordinator receives the write request and sends it to the replicas 
    - any node can be a coordinator, since all nodes have token map
- RF = 3, coordinator will try to write to 3 nodes
    - W = 2, provide ack after 2 nodes ack (write quorum)
    - R = 2, provide ack after reading from 2 nodes, hopefully, at least one of them is the latest version (read quorum)
        - optimization: read one copy, get checksum for the other copy
- W + R > RF, ensures that you read the latest version
- HDFS reads from 1 replica, but acks writes after writing to all replicas

Tuning R and W


**hinted handoff**

### Conflict resolution

- *eventual consistency*
- cassandra dynamically combine conflicting values in a row into a new row (policy *last writer wins*) and write that to all replicas
    - to do that, it keeps timestamps per cell
    - lets you query the timestamp of each cell
- use gossip protocol/anti-entropy to propagate updates



```bash
# launch cassandra interactive shell
cqlsh demo-db-1
# inside cqlsh
nodetool ring
select bank_i, token(bank_id) from loans;
# select bank_i, token(bank_id), writetime(bank_id) from loans; # can't get writetime on primary key
select bank_id, writetime(state) from loans;
```
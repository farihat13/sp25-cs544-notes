# Hadoop Distributed File System (HDFS)

GFS, MapReduce, and BigTable

similar Hadoop systems (HDFS, Spark, and Cassandra)

Why not use a traditional/relational DB?
- efficiency: some classic features don't work, why not throw them away
- scalability: Cassandra Query Language (CQL) is very similar to SQL but suited for the JOINless structure of cassandra.
- reliability or fault tolerance

Google Architecture

Google                                 | Hadoop 1st gen   | Modern Hadoop |
--                                     | --               | --            
GFS (2003) Distributed FS              | HDFS             | HDFS
MapReduce (2004) Distributed Analytics | Hadoop MapReduce | Spark 
BigTable (2006) Distributed Database   | HBase            | Cassandra


## Hadoop filesystem

Boss/Worker Architecture

DataNodes store File Blocks

NameNode is Boss, DataNodes are workers

partitioning, replication across DataNodes

load balancing in NameNode, redirects to less busy data node. 
it is the bottleneck

more replicas vs less replicasx``
big block size vs less block size

Heartbeat Message: DataNode to NameNode every N seconds

## Demo

In `hdfs.Dockerfile`, we add hadoop to PATH. In `docker-compose.yml`, we set hostname of the container `hdfs` to `main`. 
Port 9000 is commonly used as the default port for Hadoop's HDFS NameNode. 
We run our hdfs Namenode on the url `hdfs://main:9000` (`schema://ip_address:port/path`).
We did not forward port `9000` in our docker-compose, but still can access in from container `nb`,
because docker compose creates a internal network among containers in a compose. Instead of ip address,
we are using the hostname as alias.

`docker compose up -d`

`docker exec -it p4-hdfs-1 bash`

`which hdfs`

### `hdfs` commands 
- `namenode`
- `datanode`
- `dfs`
- `dfsadmin`
- `fsck`

---
NameNode

`hdfs namenode -fs hdfs://main:9000 -format` formatting hdfs filesystem in NameNode

`hdfs namenode -fs hdfs://main:9000 &> /tmp/nn.txt &` running NameNode

---

`hdfs dfsadmin -fs hdfs://main:9000 -report` will return a report that includes information about the HDFS such as 
the configuration, capacity, and the number of DataNodes. The number of DataNodes is listed under the `Live datanodes` section.

--- 
DataNode

`hdfs datanode -fs hdfs://main:9000 -format` formatting hdfs filesystem in DataNode

`hdfs datanode -fs hdfs://main:9000 &> /tmp/nn.txt &` running DataNode

---

`du` disk usage

The `hdfs dfs` command is a shell-like command to interact with Hadoop Distributed File System (HDFS). It is used to perform file operations on HDFS, similar to how you would use shell commands to interact with a local file system.
e.g., 
- `hdfs dfs -mkdir hdfs://main:9000/data` create a folder `data` in root dir
- `hdfs dfs -cp /hadoop-3.3.6/LICENSE.txt hdfs://main:9000/data/` copy file

---

The `hdfs fsck` command is used to check the health of hdfs. It checks for various inconsistencies and corruption in the file system like missing blocks, under-replicated blocks, over-replicated blocks, mis-replicated blocks, etc.
e.g., 
- `hdfs fsck hdfs://main:9000/data/LICENSE.txt`

### WebHDFS

https://hadoop.apache.org/docs/r1.0.4/webhdfs.html 

`curl -i "http://main:9870/webhdfs/v1/data?op=LISTSTATUS"`


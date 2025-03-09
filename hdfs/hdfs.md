# Hadoop Distributed File System (HDFS)

GFS, MapReduce, and BigTable

similar Hadoop systems (HDFS, Spark, and Cassandra)

Why not use a traditional/relational DB?

- efficiency: some classic features don't work, why not throw them away
- scalability: Cassandra Query Language (CQL) is very similar to SQL but suited for the JOINless structure of cassandra.
- reliability or fault tolerance

## Google’s Big Data Architecture vs. Hadoop

Google                                 | Hadoop 1st gen   | Modern Hadoop |
--                                     | --               | --
GFS (2003) - Distributed FS              | HDFS             | HDFS
MapReduce (2004) - Distributed Analytics | Hadoop MapReduce | Spark
BigTable (2006) - Distributed Database   | HBase            | Cassandra

## Hadoop filesystem

HDFS follows Boss/Worker Architecture:

- NameNode (Boss) – Manages metadata and oversees the entire filesystem.
- DataNodes (Workers) – Store file blocks, handle replication, and respond to NameNode requests.

### Key Features

- **Partitioning & Replication:** Data is split into blocks and stored across multiple DataNodes.
- **Load Balancing:** NameNode directs requests to less busy DataNodes. NameNode is the bottleneck if not set up in HA mode.
- **More Replicas vs. Fewer Replicas:** Higher replication improves fault tolerance but increases storage usage and write cost.
- **Big Block Size vs. Small Block Size:** Larger blocks reduce metadata overhead, while smaller blocks improve parallelism.
- **Heartbeat Messages:** DataNodes send a heartbeat to the NameNode every N seconds to confirm they are alive. If a DataNode stops responding, the NameNode replicates its blocks elsewhere.

## Demo

```bash
docker build -t p4-hdfs -f hdfs.Dockerfile .
docker build -t p4-nb -f notebook.Dockerfile .
docker compose up -d
docker exec -it p4-hdfs-1 bash
# which hdfs # inside container
```

- In `hdfs.Dockerfile`, we add hadoop to PATH.
- In `docker-compose.yml`, we set the hdfs container's hostname to `main`.
- Port 9000 is commonly used as the default port for Hadoop's HDFS NameNode. We run our hdfs Namenode on the url `hdfs://main:9000` (`schema://ip_address:port/path`).
- We did not forward port `9000` in our docker-compose, but still can access it from container `nb`. That is because docker compose creates a internal network among containers in a compose. Instead of ip address, we are using the hostname as alias.
- `main` is the hostname of the container, and `hdfs://main:9000` is the URL to access the HDFS NameNode.

### `hdfs` commands

- `namenode`
- `datanode`
- `dfs`
- `dfsadmin`
- `fsck`

### NameNode Commands

```bash
# Format hdfs in NameNode (only needed once during setup)
hdfs namenode -fs hdfs://main:9000 -format
# Start the NameNode
hdfs namenode -fs hdfs://main:9000 &> /tmp/nn.txt &
```

### DataNode Commands

```bash
# Format hdfs in DataNode
hdfs datanode -fs hdfs://main:9000 -format
# Start the DataNode
hdfs datanode -fs hdfs://main:9000 &> /tmp/nn.txt &
```

### `dfsadmin` commands

```bash
# Check the status of the HDFS cluster
hdfs dfsadmin -fs hdfs://main:9000 -report
hdfs dfsadmin -fs hdfs://main:9000 -report -live
hdfs dfsadmin -fs hdfs://main:9000 -report -dead
```

- returns a report that includes information about the HDFS such as the configuration, capacity, and the number of DataNodes. The number of DataNodes is listed under the `Live datanodes` section.

### File Operations (`hdfs dfs`)

The `hdfs dfs` command is a shell-like command to interact with Hadoop Distributed File System (HDFS). It is used to perform file operations on HDFS, similar to how you would use shell commands to interact with a local file system.

```bash
# Create a directory `/data` in HDFS
hdfs dfs -mkdir hdfs://main:9000/data
# List files in HDFS
hdfs dfs -ls hdfs://main:9000/data
# Copy a file from local to HDFS
hdfs dfs -cp /hadoop-3.3.6/LICENSE.txt hdfs://main:9000/data/
hdfs dfs -put /hadoop-3.3.6/LICENSE.txt hdfs://main:9000/data/
# Copy a file from HDFS to local
hdfs dfs -get hdfs://main:9000/data/LICENSE.txt /tmp/
# Disk usage of a file
hdfs dfs -du -h hdfs://main:9000/data/LICENSE.txt
```

### Check File System Health (`hdfs fsck`)

```bash
hdfs fsck hdfs://main:9000/data/LICENSE.txt
```

- Checks for various inconsistencies and corruption in the file system, like,
  - Missing blocks
  - Under-replicated blocks
  - Over-replicated blocks
  - Misplaced blocks

### WebHDFS (HTTP API for HDFS)

HDFS provides an HTTP-based REST API via WebHDFS. For example,

```bash
# List HDFS directories using WebHDFS
curl -i "http://main:9870/webhdfs/v1/data?op=LISTSTATUS"
# Create a directory in HDFS using WebHDFS
curl -i -X PUT "http://main:9870/webhdfs/v1/data/newdir?op=MKDIRS"
```

[Apache WebHDFS Docs](https://hadoop.apache.org/docs/r1.0.4/webhdfs.html)

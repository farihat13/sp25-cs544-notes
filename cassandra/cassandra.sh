echo "-Xms128M" >> /apache-cassandra-4.1.3/conf/jvm-server.options
echo "-Xmx128M" >> /apache-cassandra-4.1.3/conf/jvm-server.options

sed -i "s/^listen_address:.*/listen_address: "`hostname`"/" /apache-cassandra-4.1.3/conf/cassandra.yaml
sed -i "s/^rpc_address:.*/rpc_address: "`hostname`"/" /apache-cassandra-4.1.3/conf/cassandra.yaml
sed -i "s/- seeds:.*/- seeds: cassandra-db-1,cassandra-db-2,cassandra-db-3/" /apache-cassandra-4.1.3/conf/cassandra.yaml

/apache-cassandra-4.1.3/bin/cassandra -R

sleep infinity

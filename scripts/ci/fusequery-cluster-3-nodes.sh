#!/bin/bash

killall fuse-query
sleep 1

echo 'start cluster-1'
nohup target/debug/fuse-query -c scripts/ci/config/fusequery-cluster-1.toml &

echo "Waiting on cluster-1..."
while ! nc -z -w 5 0.0.0.0 9091; do
  sleep 1
done

echo 'start cluster-2'
nohup target/debug/fuse-query -c scripts/ci/config/fusequery-cluster-2.toml &

echo "Waiting on cluster-2..."
while ! nc -z -w 5 0.0.0.0 9092; do
  sleep 1
done

echo 'start cluster-3'
nohup target/debug/fuse-query -c scripts/ci/config/fusequery-cluster-3.toml &

echo "Waiting on cluster-3..."
while ! nc -z -w 5 0.0.0.0 9093; do
  sleep 1
done

curl http://127.0.0.1:8081/v1/cluster/add -X POST -H "Content-Type: application/json" -d '{"name":"cluster1","address":"0.0.0.0:9091", "priority":3, "cpus":8}'
curl http://127.0.0.1:8081/v1/cluster/add -X POST -H "Content-Type: application/json" -d '{"name":"cluster2","address":"0.0.0.0:9092", "priority":3, "cpus":8}'
curl http://127.0.0.1:8081/v1/cluster/add -X POST -H "Content-Type: application/json" -d '{"name":"cluster3","address":"0.0.0.0:9093", "priority":1, "cpus":8}'

echo "All done..."


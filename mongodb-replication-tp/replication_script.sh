#!/bin/bash

# MongoDB Replication Setup Script
# Author: Hamdoune Amoussa
# Date: 2025-06-30

PORT1=27017
PORT2=27018
PORT3=27019

# Step 1: Create data directories
mkdir -p db1 db2 db3

# Step 2: Create config file (if not already present)
cat > mongod.conf <<EOF
replication:
  replSetName: "rs0"
EOF

# Step 3: Start mongod instances
mongod --dbpath $(pwd)/db1 --port $PORT1 --replSet rs0 --fork --logpath db1/mongod.log --config mongod.conf
mongod --dbpath $(pwd)/db2 --port $PORT2 --replSet rs0 --fork --logpath db2/mongod.log --config mongod.conf
mongod --dbpath $(pwd)/db3 --port $PORT3 --replSet rs0 --fork --logpath db3/mongod.log --config mongod.conf

sleep 5

# Step 4: Initiate replica set
mongosh --port $PORT1 <<EOF
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "localhost:$PORT1" },
    { _id: 1, host: "localhost:$PORT2" },
    { _id: 2, host: "localhost:$PORT3" }
  ]
})
rs.status()
EOF

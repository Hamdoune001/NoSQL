#!/bin/bash

# MongoDB Sharding Setup Script on Localhost
# Author: Hamdoune Amoussa
# Date: 2025-06-30

# Step 1: Create data directories
mkdir -p data/configdb data/shard1 data/shard2

# Step 2: Create mongod_shard.conf
cat > mongod_shard.conf <<EOF
sharding:
  clusterRole: shardsvr
EOF

# Step 3: Start shard servers
mongod --port 27018 --dbpath $(pwd)/data/shard1 --shardsvr --fork --logpath data/shard1/mongod.log --config mongod_shard.conf
mongod --port 27019 --dbpath $(pwd)/data/shard2 --shardsvr --fork --logpath data/shard2/mongod.log --config mongod_shard.conf

# Step 4: Start config server
mongod --port 27017 --dbpath $(pwd)/data/configdb --configsvr --fork --logpath data/configdb/mongod.log

# Step 5: Start mongos (router)
mongos --configdb localhost:27017 --fork --logpath mongos.log --bind_ip localhost --port 27020

sleep 5

# Step 6: Connect and configure sharding
mongosh --port 27020 <<EOF
sh.addShard("localhost:27018")
sh.addShard("localhost:27019")

sh.enableSharding("sharding_db")

sh.shardCollection("sharding_db.realEstate", { id: "hashed" })

use sharding_db
// Insert test data if realEstate.csv is not provided
db.realEstate.insertMany([
  { id: 1, title: "Villa", price: 900000 },
  { id: 2, title: "Apartment", price: 300000 },
  { id: 3, title: "Farmhouse", price: 600000 }
])

sh.status()
EOF

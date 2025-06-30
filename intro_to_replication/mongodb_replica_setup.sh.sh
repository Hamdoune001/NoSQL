#!/bin/bash

# MongoDB Replica Set Setup Script on Localhost
# Author: Hamdoune Amoussa
# Date: 2025-06-30

# Step 1: Create data directories
mkdir -p data/db1 data/db2 data/db3

# Step 2: Create a basic mongod.conf for replication
cat > mongod.conf <<EOF
replication:
  replSetName: "rs0"
EOF

# Step 3: Start three mongod instances
echo "Starting mongod instances..."
mongod --port 27017 --dbpath $(pwd)/data/db1 --replSet rs0 --bind_ip localhost --fork --logpath data/db1/mongod.log --config mongod.conf
mongod --port 27018 --dbpath $(pwd)/data/db2 --replSet rs0 --bind_ip localhost --fork --logpath data/db2/mongod.log --config mongod.conf
mongod --port 27019 --dbpath $(pwd)/data/db3 --replSet rs0 --bind_ip localhost --fork --logpath data/db3/mongod.log --config mongod.conf

# Wait a few seconds to ensure instances are up
sleep 5

# Step 4: Connect to primary and configure replica set
echo "Initializing replica set..."
mongosh --port 27017 <<EOF
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "localhost:27017" },
    { _id: 1, host: "localhost:27018" },
    { _id: 2, host: "localhost:27019" }
  ]
})

while (rs.status().ok !== 1) {
  print("Waiting for replica set to be ready...");
  sleep(1000);
}

use GameOfThrones
db.characters.insertMany([
  { name: "Jon Snow", age: 25, house: "Stark" },
  { name: "Daenerys Targaryen", age: 23, house: "Targaryen" },
  { name: "Tyrion Lannister", age: 30, house: "Lannister" }
])

db.characters.find().pretty()
EOF

echo "Replica set initialized. Data inserted into primary."
echo "Now connect manually to ports 27018 and 27019 to verify replication:"
echo ""
echo "mongosh --port 27018"
echo "mongosh --port 27019"

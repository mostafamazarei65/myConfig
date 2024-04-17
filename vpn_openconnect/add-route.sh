#!/bin/bash

for range in $(jq .[] iran.json | sed 's/"//g' | xargs); do
  ip route add $range via $gateway;
done;

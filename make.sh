#!/bin/bash
./du-libs/tools/squish.lua master_device -output=master_device/master.squished.lua
lua ./du-libs/tools/wrap.lua ./master_device/master.squished.lua ./master.json
rm master_device/master.squished.lua

../du-libs/tools/squish.lua slave_device -output=slave_device/slave.squished.lua
lua ./du-libs/tools/wrap.lua ./slave_device/slave.squished.lua ./slave.json
rm slave_device/slave.squished.lua
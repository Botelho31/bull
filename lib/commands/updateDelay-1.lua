--[[
  Update job delay

  Input:
    KEYS[1] delayed key

    ARGV[1] Job Id
    ARGV[2] Key prefix
    ARGV[3] delayedTimestamp
    ARGV[4] job timestamp

  Output:
    0 - OK
   -1 - Job does not exist
   -2 - Job is not in delayed set
   -3 - Invalid delay timestamp
]]

local jobIdKey = ARGV[2] .. ARGV[1]
local delayTimestamp = tonumber(ARGV[3])
local delay = delayTimestamp - tonumber(ARGV[4])
local rcall = redis.call

-- Make sure job exists
if rcall("EXISTS", jobIdKey) == 0 then
  return -1
-- Check if job is in delayed sorted set
elseif rcall("ZSCORE", KEYS[1], ARGV[1]) == nil then
  return -2
-- Check if delay is negative
elseif delay <= 0 then
  return -3
end

-- Update delay
rcall("HSET", jobIdKey, "delay", delay)

-- Update delayed sorted set
rcall("ZADD", KEYS[1], delayTimestamp * 0x1000, ARGV[1])

return 0





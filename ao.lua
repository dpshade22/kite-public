local json = require("json")

KiteHistoricalDataMap = {}

Handlers.add('StoreDataForDate',
    Handlers.utils.hasMatchingTag('Action', 'StoreDataForDate'),
    function(msg)
        local date = msg.Tags["Date"]
        local txId = msg.Tags["TxID"]

        if not date or not data or not txId then
            print("Error: Missing required tags")
            sendResponse(msg.From, "StoreDataForDate", { error = "Missing required tags" })
            return
        end

        if not KiteHistoricalDataMap[date] then
            KiteHistoricalDataMap[date] = {}
        end
        table.insert(KiteHistoricalDataMap[date], { data = data, txId = txId })

        print(string.format("Data stored for date %s with TxID %s", date, txId))
        sendResponse(msg.From, "StoreDataForDate", {
            success = true,
            date = date,
            txId = txId
        })
    end
)

Handlers.add('GetDataForDate',
    Handlers.utils.hasMatchingTag('Action', 'GetDataForDate'),
    function(msg)
        local date = msg.Tags["Date"]

        if not date then
            print("Error: Missing Date tag")
            sendResponse(msg.From, "GetDataForDate", { error = "Missing Date tag" })
            return
        end

        local data = KiteHistoricalDataMap[date] or {}

        sendResponse(msg.From, "GetDataForDate", {
            success = true,
            date = date,
            data = data
        })
    end
)

local function sendResponse(target, action, data)
    ao.send({
        Target = target,
        Tags = { ["Action"] = action },
        Data = json.encode(data)
    })
end
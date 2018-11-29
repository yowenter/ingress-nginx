local util = require("../util")
local _M = {}

-- function _M.new(self, policy)
--     -- use dict to store {"header_value":"backend"} O(1)
--     self.policy_dict = {}

-- end

-- [{"header": "shanghai", "upstream": "stream_a"}, {"header": "beijing", "upstream": "stream_b"}]

function _M.get_upstream(policy)
    -- parse ngx.request, match the backend . use dict. O(n)
    local header_key = policy["header"]
    local clean_target_header = util.replace_special_char(header_key, "-", "_")
    local header = ngx.var["http_" .. clean_target_header]
    local upstreams = policy["upstreams"]
    for _, v in pairs(upstreams) do
        if header == v['header'] then
            return v["upstream"]
        end
    end
end

return _M
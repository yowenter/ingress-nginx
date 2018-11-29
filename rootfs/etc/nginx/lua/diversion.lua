local util = require("util")
local configuration = require("ab_configuration")
local header_diversion = require("diversion.header")



local _M = {}

local function get_upstream()
  local policies = configuration.get_policies()
  if not policies then
    return
  end

  local server_path = string.format("%s%s", ngx.var.host, ngx.var.location_path)
  ngx.log(ngx.WARN, string.format( "get policy %s from %s", server_path, util.tdump(policies) ))
  -- local policy = policies[server_path]
  local target_policy = nil
  for _, policy in ipairs(policies) do
    if policy["host"] == ngx.var.host and policy["path"]== ngx.var.location_path then
      target_policy = policy
      break
    end
  end

  if not target_policy then
    return

  end
  local policy_type = target_policy["type"]
  if policy_type == "header" then
    return header_diversion.get_upstream(target_policy)
  else
    return
  end
end


function _M.rewrite()
    local upstream = get_upstream()
    if not upstream then
      ngx.log(ngx.WARN, "no diversion upstream found for " .. ngx.var.host .. ngx.var.location_path)
      return
    else
      ngx.log(ngx.WARN, string.format("rewrite proxy upstream `%s` -> `%s`.", ngx.var.proxy_upstream_name, upstream))
      ngx.var.proxy_upstream_name = upstream  -- rewrite nginx.var.upstream
    end
  end

return _M



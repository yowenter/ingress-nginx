-- traffic shaping policy configuration
-- 单独使用配置, 避免和社区版冲突

local json = require("cjson")

local configuration_util = require("configuration")

local polices_data = ngx.shared.configuration_data



-- local polices_data  = '{"example.com/a": {"upstreams": [{"header": "shanghai", "upstream": "stream_a"}, {"header": "beijing", "upstream": "stream_b"}], "type": "header", "header": "x-region"}}'



local _M = {
  }

function _M.get_policies_data()
    return polices_data:get("policies")
end

function _M.get_policies()
  local ok, policies = pcall(json.decode, polices_data:get("policies"))
  if not ok then
    return
  end
  return policies
end


function _M.call()
    if ngx.var.request_method ~= "POST" and ngx.var.request_method ~= "GET" then
      ngx.status = ngx.HTTP_BAD_REQUEST
      ngx.print("Only POST and GET requests are allowed!")
      return
    end


    if ngx.var.request_method == "GET" then
      ngx.status = ngx.HTTP_OK
      ngx.print(_M.get_policies_data())
      return
    end


    local polices = configuration_util.fetch_request_body()
    if not polices then
      ngx.log(ngx.ERR, "dynamic-configuration: unable to read valid request body")
      ngx.status = ngx.HTTP_BAD_REQUEST
      return
    end

    local success, err = polices_data:set("policies", polices)
    if not success then
      ngx.log(ngx.ERR, "dynamic-configuration: error updating configuration: " .. tostring(err))
      ngx.status = ngx.HTTP_BAD_REQUEST
      return
    end

    ngx.status = ngx.HTTP_CREATED
  end



return _M
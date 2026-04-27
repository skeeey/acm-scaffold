local MyHeader = {
  PRIORITY = 1000,
  VERSION = "0.1.0",
}

function MyHeader:access(conf)
  kong.service.request.set_header(conf.request_header, conf.header_value)
end

function MyHeader:header_filter(conf)
  kong.response.set_header(conf.response_header, conf.header_value)
end

return MyHeader

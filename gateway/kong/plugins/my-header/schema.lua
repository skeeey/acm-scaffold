local typedefs = require "kong.db.schema.typedefs"

return {
  name = "my-header",
  fields = {
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          { request_header = { type = "string", required = true, default = "X-My-Request" } },
          { response_header = { type = "string", required = true, default = "X-My-Response" } },
          { header_value = { type = "string", required = true, default = "hello-from-my-plugin" } },
        },
      },
    },
  },
}

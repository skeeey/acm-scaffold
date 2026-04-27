package main

import (
	"github.com/higress-group/proxy-wasm-go-sdk/proxywasm"
	"github.com/higress-group/proxy-wasm-go-sdk/proxywasm/types"
	"github.com/higress-group/wasm-go/pkg/log"
	"github.com/higress-group/wasm-go/pkg/wrapper"
	"github.com/tidwall/gjson"
)

func main() {}

func init() {
	wrapper.SetCtx(
		"my-header",
		wrapper.ParseConfigBy(parseConfig),
		wrapper.ProcessRequestHeadersBy(onHttpRequestHeaders),
		wrapper.ProcessResponseHeadersBy(onHttpResponseHeaders),
	)
}

type MyHeaderConfig struct {
	requestHeaderName  string
	requestHeaderValue string
	responseHeaderName  string
	responseHeaderValue string
}

func parseConfig(json gjson.Result, config *MyHeaderConfig, log log.Log) error {
	config.requestHeaderName = json.Get("request_header_name").String()
	config.requestHeaderValue = json.Get("request_header_value").String()
	config.responseHeaderName = json.Get("response_header_name").String()
	config.responseHeaderValue = json.Get("response_header_value").String()
	log.Infof("config: request=%s:%s, response=%s:%s",
		config.requestHeaderName, config.requestHeaderValue,
		config.responseHeaderName, config.responseHeaderValue)
	return nil
}

func onHttpRequestHeaders(ctx wrapper.HttpContext, config MyHeaderConfig, log log.Log) types.Action {
	if config.requestHeaderName != "" {
		err := proxywasm.AddHttpRequestHeader(config.requestHeaderName, config.requestHeaderValue)
		if err != nil {
			log.Errorf("failed to add request header: %v", err)
		}
	}
	return types.ActionContinue
}

func onHttpResponseHeaders(ctx wrapper.HttpContext, config MyHeaderConfig, log log.Log) types.Action {
	if config.responseHeaderName != "" {
		err := proxywasm.AddHttpResponseHeader(config.responseHeaderName, config.responseHeaderValue)
		if err != nil {
			log.Errorf("failed to add response header: %v", err)
		}
	}
	return types.ActionContinue
}

## Issue
我的 grpc client (使用 golang 实现)，通过 pub/sub 链接 grpc server, grpc server 在 k8s 中部署，
并且通过 istio 管理，grpc client 也在 k8s 中运行，我发现，即使不启动 grpc-server，
grpc client 也可以 sub 成功，是什么原因呢？如何解决呢？我现在不想改 code，最好是通过 istio 的配置解决

**注意**：grpc client 添加了 keepalive (time=20s timeout=10s true)

所有的环境运行在 azue 的 aks 上
```
istioctl version --remote --istioNamespace aks-istio-system
client version: 1.26.0
control plane version: 1.25.3
data plane version: 1.25.3 (8 proxies)
```

grpc client sub 时候的 code

```go
subClient, err := p.client.Subscribe(ctx, &pbv1.SubscriptionRequest{
		Source:      p.subscribeOption.Source,
		ClusterName: p.subscribeOption.ClusterName,
		DataType:    p.subscribeOption.DataType,
	})
	if err != nil {
		return err
	}

	if p.subscribeOption.Source != "" {
		logger.Infof("subscribing events for: %v with data types: %v", p.subscribeOption.Source, p.subscribeOption.DataType)
	} else {
		logger.Infof("subscribing events for cluster: %v with data types: %v", p.subscribeOption.ClusterName, p.subscribeOption.DataType)
	}

	go func() {
		for {
			msg, err := subClient.Recv()
			if err != nil {
				if errStatus, _ := status.FromError(err); errStatus.Code() == codes.Canceled {
					// context canceled, return directly
					return
				}

				logger.Errorf("failed to receive events, %v", err)
				return
			}
			p.incoming <- msg
		}
	}()

	// Wait until external or internal context done
	select {
	case <-ctx.Done():
	case <-p.closeChan:
	}
	logger.Infof("Close grpc client connection")
	return p.clientConn.Close()
```

grpc client 链接时的 log
```
2025/09/09 06:26:03 INFO: [core] original dial target is: "maestro-grpc.maestro.svc.cluster.local:8090"
2025/09/09 06:26:03 INFO: [core] [Channel #1]Channel created
2025/09/09 06:26:03 INFO: [core] [Channel #1]parsed dial target is: resolver.Target{URL:url.URL{Scheme:"dns", Opaque:"", User:(*url.Userinfo)(nil), Host:"", Path:"/maestro-grpc.maestro.svc.cluster.local:8090", RawPath:"", OmitHost:false, ForceQuery:false, RawQuery:"", Fragment:"", RawFragment:""}}
2025/09/09 06:26:03 INFO: [core] [Channel #1]Channel authority set to "maestro-grpc.maestro.svc.cluster.local:8090"
2025/09/09 06:26:03 INFO: [core] [Channel #1]Channel exiting idle mode
2025/09/09 06:26:03 INFO: [core] [Channel #1]Resolver state updated: {
  "Addresses": [
    {
      "Addr": "10.130.243.204:8090",
      "ServerName": "",
      "Attributes": null,
      "BalancerAttributes": null,
      "Metadata": null
    }
  ],
  "Endpoints": [
    {
      "Addresses": [
        {
          "Addr": "10.130.243.204:8090",
          "ServerName": "",
          "Attributes": null,
          "BalancerAttributes": null,
          "Metadata": null
        }
      ],
      "Attributes": null
    }
  ],
  "ServiceConfig": null,
  "Attributes": null
} (resolver returned new addresses)
2025/09/09 06:26:03 INFO: [core] [Channel #1]Channel switches to new LB policy "pick_first"
2025/09/09 06:26:03 INFO: [pick-first-lb] [pick-first-lb 0xc00040e4b0] Received new config {
  "shuffleAddressList": false
}, resolver state {
  "Addresses": [
    {
      "Addr": "10.130.243.204:8090",
      "ServerName": "",
      "Attributes": null,
      "BalancerAttributes": null,
      "Metadata": null
    }
  ],
  "Endpoints": [
    {
      "Addresses": [
        {
          "Addr": "10.130.243.204:8090",
          "ServerName": "",
          "Attributes": null,
          "BalancerAttributes": null,
          "Metadata": null
        }
      ],
      "Attributes": null
    }
  ],
  "ServiceConfig": null,
  "Attributes": null
}
2025/09/09 06:26:03 INFO: [core] [Channel #1 SubChannel #2]Subchannel created
2025/09/09 06:26:03 INFO: [core] [Channel #1]Channel Connectivity change to CONNECTING
2025/09/09 06:26:03 INFO: [core] [Channel #1 SubChannel #2]Subchannel Connectivity change to CONNECTING
2025/09/09 06:26:03 INFO: [core] [Channel #1 SubChannel #2]Subchannel picks a new address "10.130.243.204:8090" to connect
2025/09/09 06:26:03 INFO: [pick-first-lb] [pick-first-lb 0xc00040e4b0] Received SubConn state update: 0xc0002ee5a0, {ConnectivityState:CONNECTING ConnectionError:<nil> connectedAddress:{Addr: ServerName: Attributes:<nil> BalancerAttributes:<nil> Metadata:<nil>}}
2025/09/09 06:26:03 INFO: [core] [Channel #1 SubChannel #2]Subchannel Connectivity change to READY
2025/09/09 06:26:03 INFO: [pick-first-lb] [pick-first-lb 0xc00040e4b0] Received SubConn state update: 0xc0002ee5a0, {ConnectivityState:READY ConnectionError:<nil> connectedAddress:{Addr:10.130.243.204:8090 ServerName:maestro-grpc.maestro.svc.cluster.local:8090 Attributes:<nil> BalancerAttributes:<nil> Metadata:<nil>}}
2025/09/09 06:26:03 INFO: [core] [Channel #1]Channel Connectivity change to READY
{"level":"info","ts":1757399163.3822484,"logger":"fallback","caller":"protocol/protocol.go:117","msg":"subscribing events for: arohcpdev-test with data types: io.open-cluster-management.works.v1alpha1.manifestbundles"}
```

istio proxy 的 log

```
kubectl -n maestro-test logs maestro-grpc-watcher-6d6ff4fbf4-j4wr4 -c istio-proxy
2025-09-10T03:25:27.976006Z	info	FLAG: --concurrency="0"
2025-09-10T03:25:27.976037Z	info	FLAG: --domain="maestro-test.svc.cluster.local"
2025-09-10T03:25:27.976044Z	info	FLAG: --help="false"
2025-09-10T03:25:27.976048Z	info	FLAG: --log_as_json="false"
2025-09-10T03:25:27.976051Z	info	FLAG: --log_caller=""
2025-09-10T03:25:27.976055Z	info	FLAG: --log_output_level="default:info"
2025-09-10T03:25:27.976060Z	info	FLAG: --log_stacktrace_level="default:none"
2025-09-10T03:25:27.976071Z	info	FLAG: --log_target="[stdout]"
2025-09-10T03:25:27.976077Z	info	FLAG: --meshConfig="./etc/istio/config/mesh"
2025-09-10T03:25:27.976081Z	info	FLAG: --outlierLogPath=""
2025-09-10T03:25:27.976086Z	info	FLAG: --profiling="true"
2025-09-10T03:25:27.976090Z	info	FLAG: --proxyComponentLogLevel="misc:error"
2025-09-10T03:25:27.976095Z	info	FLAG: --proxyLogLevel="warning"
2025-09-10T03:25:27.976099Z	info	FLAG: --serviceCluster="istio-proxy"
2025-09-10T03:25:27.976104Z	info	FLAG: --stsPort="0"
2025-09-10T03:25:27.976108Z	info	FLAG: --templateFile=""
2025-09-10T03:25:27.976112Z	info	FLAG: --tokenManagerPlugin=""
2025-09-10T03:25:27.976119Z	info	FLAG: --vklog="0"
2025-09-10T03:25:27.976124Z	info	Version 1.25.3-a62d39695c065f03d64aeb7837afe545c572323e-unknown
2025-09-10T03:25:27.976134Z	info	Set max file descriptors (ulimit -n) to: 1048576
2025-09-10T03:25:27.976357Z	info	Proxy role	ips=[10.128.64.67] type=sidecar id=maestro-grpc-watcher-6d6ff4fbf4-j4wr4.maestro-test domain=maestro-test.svc.cluster.local
2025-09-10T03:25:27.976433Z	info	Apply proxy config from env {"discoveryAddress":"istiod-asm-1-25.aks-istio-system.svc:15012","tracing":{"zipkin":{"address":"zipkin.aks-istio-system:9411"}},"gatewayTopology":{"numTrustedProxies":1},"image":{"imageType":"distroless"}}

2025-09-10T03:25:27.977860Z	info	cpu limit detected as 2, setting concurrency
2025-09-10T03:25:27.978260Z	info	Effective config: binaryPath: /usr/local/bin/envoy
concurrency: 2
configPath: ./etc/istio/proxy
controlPlaneAuthPolicy: MUTUAL_TLS
discoveryAddress: istiod-asm-1-25.aks-istio-system.svc:15012
drainDuration: 45s
gatewayTopology:
  numTrustedProxies: 1
image:
  imageType: distroless
proxyAdminPort: 15000
serviceCluster: istio-proxy
statNameLength: 189
statusPort: 15020
terminationDrainDuration: 5s
tracing:
  zipkin:
    address: zipkin.aks-istio-system:9411

2025-09-10T03:25:27.978276Z	info	JWT policy is third-party-jwt
2025-09-10T03:25:27.978280Z	info	using credential fetcher of JWT type in cluster.local trust domain
2025-09-10T03:25:27.978721Z	info	platform detected is Azure
2025-09-10T03:25:27.996843Z	info	Starting default Istio SDS Server
2025-09-10T03:25:27.996920Z	info	CA Endpoint istiod-asm-1-25.aks-istio-system.svc:15012, provider Citadel
2025-09-10T03:25:27.997063Z	info	Using CA istiod-asm-1-25.aks-istio-system.svc:15012 cert with certs: var/run/secrets/istio/root-cert.pem
2025-09-10T03:25:27.997498Z	info	Opening status port 15020
2025-09-10T03:25:27.998458Z	info	xdsproxy	Initializing with upstream address "istiod-asm-1-25.aks-istio-system.svc:15012" and cluster "Kubernetes"
2025-09-10T03:25:28.000377Z	info	sds	Starting SDS grpc server
2025-09-10T03:25:28.000394Z	info	sds	Starting SDS server for workload certificates, will listen on "var/run/secrets/workload-spiffe-uds/socket"
2025-09-10T03:25:28.005425Z	info	Pilot SAN: [istiod-asm-1-25.aks-istio-system.svc]
2025-09-10T03:25:28.008638Z	info	Starting proxy agent
2025-09-10T03:25:28.008681Z	info	Envoy command: [-c etc/istio/proxy/envoy-rev.json --drain-time-s 45 --drain-strategy immediate --local-address-ip-version v4 --file-flush-interval-msec 1000 --disable-hot-restart --allow-unknown-static-fields -l warning --component-log-level misc:error --skip-deprecated-logs --concurrency 2]
2025-09-10T03:25:28.175680Z	warning	envoy main external/envoy/source/server/server.cc:959	There is no configured limit to the number of allowed active downstream connections. Configure a limit in `envoy.resource_monitors.global_downstream_max_connections` resource monitor.	thread=16
2025-09-10T03:25:28.181955Z	warning	envoy main external/envoy/source/server/server.cc:863	Usage of the deprecated runtime key overload.global_downstream_max_connections, consider switching to `envoy.resource_monitors.global_downstream_max_connections` instead.This runtime key will be removed in future.	thread=16
2025-09-10T03:25:28.209789Z	info	xdsproxy	connected to delta upstream XDS server: istiod-asm-1-25.aks-istio-system.svc:15012	id=1
2025-09-10T03:25:28.226958Z	info	cache	generated new workload certificate	resourceName=default latency=226.456249ms ttl=23h59m59.773046618s
2025-09-10T03:25:28.227091Z	info	cache	Root cert has changed, start rotating root cert
2025-09-10T03:25:28.227173Z	info	cache	returned workload trust anchor from cache	ttl=23h59m59.772828416s
2025-09-10T03:25:28.256620Z	info	ads	ADS: new connection for node:1
2025-09-10T03:25:28.256705Z	info	cache	returned workload certificate from cache	ttl=23h59m59.743296964s
2025-09-10T03:25:28.257936Z	info	ads	ADS: new connection for node:2
2025-09-10T03:25:28.258113Z	info	cache	returned workload trust anchor from cache	ttl=23h59m59.741889252s
2025-09-10T03:25:28.893453Z	info	Readiness succeeded in 921.030168ms
2025-09-10T03:25:28.893938Z	info	Envoy proxy is ready
[2025-09-10T03:25:30.208Z] "POST /io.cloudevents.v1.CloudEventService/Subscribe HTTP/2" 200 UH no_healthy_upstream - "-" 0 0 0 - "-" "grpc-go/1.71.0" "cb92e3a5-8d55-45ec-ab17-7b358f9e954f" "maestro-grpc.maestro.svc.cluster.local:8090" "-" outbound|8090||maestro-grpc.maestro.svc.cluster.local - 10.130.243.204:8090 10.128.64.67:51632 - default
2025-09-10T03:53:36.349056Z	info	xdsproxy	connected to delta upstream XDS server: istiod-asm-1-25.aks-istio-system.svc:15012	id=2
[2025-09-10T03:55:35.959Z] "POST /io.cloudevents.v1.CloudEventService/Subscribe HTTP/2" 200 UH no_healthy_upstream - "-" 0 0 0 - "-" "grpc-go/1.71.0" "dcca874b-4643-4ba8-bb26-c3f279ed1db4" "maestro-grpc.maestro.svc.cluster.local:8090" "-" outbound|8090||maestro-grpc.maestro.svc.cluster.local - 10.130.243.204:8090 10.128.64.67:33528 - default
```
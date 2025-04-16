package main

import (
	"crypto/rand"
	"crypto/rsa"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/pem"
	"log"
	"math/big"
	"net"
	"os"
	"time"
)

func main() {
	// 创建证书输出目录
	if err := os.MkdirAll("certs", 0755); err != nil {
		log.Fatalf("Failed to create certs directory: %v", err)
	}

	// 1. 生成 CA 证书
	caCert, caKey := generateCA()
	saveCertAndKey("certs/ca.crt", "certs/ca.key", caCert, caKey)

	// 2. 生成服务器证书
	serverCert, serverKey := generateCert(caCert, caKey, "server", []string{"localhost", "server"}, []string{"127.0.0.1"})
	saveCertAndKey("certs/server.crt", "certs/server.key", serverCert, serverKey)

	// 3. 生成客户端证书
	clientCert, clientKey := generateCert(caCert, caKey, "client", nil, nil)
	saveCertAndKey("certs/client.crt", "certs/client.key", clientCert, clientKey)

	log.Println("All certificates generated successfully in the 'certs' directory")
}

func generateCA() (*x509.Certificate, *rsa.PrivateKey) {
	// 生成 CA 私钥
	caKey, err := rsa.GenerateKey(rand.Reader, 4096)
	if err != nil {
		log.Fatalf("Failed to generate CA key: %v", err)
	}

	// 设置 CA 证书模板
	caTemplate := x509.Certificate{
		SerialNumber: big.NewInt(1),
		Subject: pkix.Name{
			CommonName: "My Root CA",
		},
		NotBefore:             time.Now(),
		NotAfter:              time.Now().AddDate(10, 0, 0), // 10年有效期
		KeyUsage:              x509.KeyUsageCertSign | x509.KeyUsageCRLSign,
		BasicConstraintsValid: true,
		IsCA:                  true,
	}

	// 自签名 CA 证书
	caCertDER, err := x509.CreateCertificate(rand.Reader, &caTemplate, &caTemplate, &caKey.PublicKey, caKey)
	if err != nil {
		log.Fatalf("Failed to create CA certificate: %v", err)
	}

	caCert, err := x509.ParseCertificate(caCertDER)
	if err != nil {
		log.Fatalf("Failed to parse CA certificate: %v", err)
	}

	return caCert, caKey
}

func generateCert(caCert *x509.Certificate, caKey *rsa.PrivateKey, commonName string, dnsNames []string, ipAddresses []string) (*x509.Certificate, *rsa.PrivateKey) {
	// 生成证书私钥
	certKey, err := rsa.GenerateKey(rand.Reader, 4096)
	if err != nil {
		log.Fatalf("Failed to generate certificate key: %v", err)
	}

	// 设置证书模板
	certTemplate := x509.Certificate{
		SerialNumber: big.NewInt(time.Now().Unix()),
		Subject: pkix.Name{
			CommonName: commonName,
		},
		NotBefore:   time.Now(),
		NotAfter:    time.Now().AddDate(1, 0, 0), // 1年有效期
		KeyUsage:    x509.KeyUsageDigitalSignature | x509.KeyUsageKeyEncipherment,
		ExtKeyUsage: []x509.ExtKeyUsage{x509.ExtKeyUsageServerAuth, x509.ExtKeyUsageClientAuth},
	}

	// 添加 SAN (Subject Alternative Name)
	if len(dnsNames) > 0 {
		certTemplate.DNSNames = dnsNames
	}
	if len(ipAddresses) > 0 {
		var ips []net.IP
		for _, ipStr := range ipAddresses {
			ips = append(ips, net.ParseIP(ipStr))
		}
		certTemplate.IPAddresses = ips
	}

	// 使用 CA 签名
	certDER, err := x509.CreateCertificate(rand.Reader, &certTemplate, caCert, &certKey.PublicKey, caKey)
	if err != nil {
		log.Fatalf("Failed to create certificate: %v", err)
	}

	cert, err := x509.ParseCertificate(certDER)
	if err != nil {
		log.Fatalf("Failed to parse certificate: %v", err)
	}

	return cert, certKey
}

func saveCertAndKey(certPath, keyPath string, cert *x509.Certificate, key *rsa.PrivateKey) {
	// 保存证书
	certFile, err := os.Create(certPath)
	if err != nil {
		log.Fatalf("Failed to create %s: %v", certPath, err)
	}
	defer certFile.Close()

	if err := pem.Encode(certFile, &pem.Block{
		Type:  "CERTIFICATE",
		Bytes: cert.Raw,
	}); err != nil {
		log.Fatalf("Failed to write certificate to %s: %v", certPath, err)
	}

	// 保存私钥 (PKCS#8 格式)
	keyBytes, err := x509.MarshalPKCS8PrivateKey(key)
	if err != nil {
		log.Fatalf("Failed to marshal private key: %v", err)
	}

	keyFile, err := os.Create(keyPath)
	if err != nil {
		log.Fatalf("Failed to create %s: %v", keyPath, err)
	}
	defer keyFile.Close()

	if err := pem.Encode(keyFile, &pem.Block{
		Type:  "PRIVATE KEY",
		Bytes: keyBytes,
	}); err != nil {
		log.Fatalf("Failed to write private key to %s: %v", keyPath, err)
	}
}

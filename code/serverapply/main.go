package main

import (
	"context"
	"fmt"
	"log"
	"os"

	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
	"k8s.io/apimachinery/pkg/runtime/serializer/yaml"
	"k8s.io/apimachinery/pkg/types"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/client/config"
)

var (
	kubeconfig   = ""
	resourcePath = ""
)

func main() {

	if kubeconfig == "" {
		homeDir, err := os.UserHomeDir()
		if err != nil {
			log.Fatal(err)
		}
		kubeconfig = fmt.Sprintf("%s/.kube/config", homeDir)
	}

	os.Setenv("KUBECONFIG", kubeconfig)
	fmt.Printf("Set KUBECONFIG=%s\n", kubeconfig)

	restConfig, err := config.GetConfigWithContext("")
	if err != nil {
		log.Fatal(err)
	}

	runtimeClient, err := client.New(restConfig, client.Options{})
	if err != nil {
		log.Fatal(err)
	}

	ns := &corev1.Namespace{}
	if err := runtimeClient.Get(context.TODO(), types.NamespacedName{Name: "default"}, ns); err != nil {
		log.Fatal(err)
	}

	if resourcePath == "" {
		fmt.Printf("Resource path is not defined\n")
		return
	}

	fmt.Printf("Apply %s\n", resourcePath)

	data, err := os.ReadFile(resourcePath)
	if err != nil {
		log.Fatal(err)
	}

	obj := &unstructured.Unstructured{}
	if _, _, err = yaml.NewDecodingSerializer(unstructured.UnstructuredJSONScheme).Decode(data, nil, obj); err != nil {
		log.Fatal(err)
	}

	force := true
	if err := runtimeClient.Patch(context.TODO(), obj, client.Apply, &client.PatchOptions{
		Force:        &force,
		FieldManager: "test-operator",
	}); err != nil {
		log.Fatal(err)
	}
}

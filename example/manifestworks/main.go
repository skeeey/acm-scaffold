package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"path"
	"syscall"
	"time"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"

	workv1client "open-cluster-management.io/api/client/work/clientset/versioned/typed/work/v1"
)

var total = 1

func main() {
	ctx, cancel := context.WithCancel(context.Background())

	stopCh := make(chan os.Signal, 1)
	signal.Notify(stopCh, syscall.SIGINT, syscall.SIGTERM)
	go func() {
		defer cancel()
		<-stopCh
	}()

	homeDir, err := os.UserHomeDir()
	if err != nil {
		log.Fatal(err)
	}

	kubeConfigBytes, err := os.ReadFile(path.Join(homeDir, ".kube", "config"))
	if err != nil {
		log.Fatal(err)
	}
	kubeConfig, err := clientcmd.NewClientConfigFromBytes(kubeConfigBytes)
	if err != nil {
		log.Fatal(err)
	}
	clientConfig, err := kubeConfig.ClientConfig()
	if err != nil {
		log.Fatal(err)
	}

	kubeClient := kubernetes.NewForConfigOrDie(clientConfig)
	workClient := workv1client.NewForConfigOrDie(clientConfig)

	for i := 0; i < total; i++ {
		resource, err := kubeClient.AppsV1().Deployments("default").Get(ctx, "nginx", metav1.GetOptions{})
		//resource, err := kubeClient.CoreV1().ConfigMaps("default").Get(ctx, fmt.Sprintf("test-work-%d", i), metav1.GetOptions{})
		if err != nil {
			log.Fatal(err)
		}

		updated := resource.DeepCopy()
		updated.Finalizers = []string{"test/do-not-remove"}
		_, err = kubeClient.AppsV1().Deployments("default").Update(ctx, updated, metav1.UpdateOptions{})
		//_, err = kubeClient.CoreV1().ConfigMaps("default").Update(ctx, updated, metav1.UpdateOptions{})
		if err != nil {
			log.Fatal(err)
		}
		log.Printf("finalizer is added to %s\n", updated.Name)
	}
	time.Sleep(10 * time.Second)

	log.Println("delete manifestworks")
	for i := 0; i < total; i++ {
		if err := workClient.ManifestWorks("cluster1").Delete(ctx, "test-nginx", metav1.DeleteOptions{}); err != nil {
			log.Fatal(err)
		}
		// if err := workClient.ManifestWorks("cluster1").Delete(ctx, fmt.Sprintf("test-work-%d", i), metav1.DeleteOptions{}); err != nil {
		// 	log.Fatal(err)
		// }
		log.Printf("manifestwork test-work-%d is deleted at %s\n", i, time.Now().Format("2006-01-02 15:04:05"))
	}

	log.Println("wait for manifestworks deletion")
	time.Sleep(11 * time.Minute)

	for i := 0; i < total; i++ {
		resource, err := kubeClient.AppsV1().Deployments("default").Get(ctx, "nginx", metav1.GetOptions{})
		//resource, err := kubeClient.CoreV1().ConfigMaps("default").Get(ctx, fmt.Sprintf("test-work-%d", i), metav1.GetOptions{})
		if err != nil {
			log.Fatal(err)
		}

		updated := resource.DeepCopy()
		updated.Finalizers = []string{}
		_, err = kubeClient.AppsV1().Deployments("default").Update(ctx, updated, metav1.UpdateOptions{})
		//_, err = kubeClient.CoreV1().ConfigMaps("default").Update(ctx, updated, metav1.UpdateOptions{})
		if err != nil {
			log.Fatal(err)
		}
		log.Printf("test-work-%d is deleted at %s\n", i, time.Now().Format("2006-01-02 15:04:05"))
	}
}

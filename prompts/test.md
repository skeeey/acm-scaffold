according to the sever log,  the resource 17de99be-cc1a-5cb8-8c54-8916ec166ed6 seems to be deleted at 09:08 in maestro
cat maestro-6698b7b9bc-mgpdn.logs| grep "status delete event was sent" | grep 17de99be-cc1a-5cb8-8c54-8916ec166ed6
2025-08-05T09:08:15.942Z	INFO	server/event_server.go:226	resource 17de99be-cc1a-5cb8-8c54-8916ec166ed6 status delete event was sent
And cloud you collect the appliedmanifestworks from the management cluster when we delete a resource, it seems to there is one resource is pending deletions in the mangagement cluster
I0803 16:09:55.133016       1 appliedmanifestwork_finalize_controller.go:113] 1 resources pending deletions
I0803 16:09:55.133138       1 event.go:377] Event(v1.ObjectReference{Kind:"Deployment", Namespace:"maestro", Name:"maestro-agent", UID:"f1a8b8e4-7fa0-4103-95d0-fa148b221afe", APIVersion:"apps/v1", ResourceVersion:"", FieldPath:""}): type: 'Normal' reason: 'ResourceDeleted' Deleted resource work.open-cluster-management.io/v1, Resource=manifestworks with key local-cluster/2kej8ktdm7mtlcr1huaa78dh145t201c-np-create-7pbvj because manifestwork bb2b4ea8-894c-52f3-8701-78cd007f551d is terminating.
I0803 16:09:55.148167       1 appliedmanifestwork_finalize_controller.go:113] 1 resources pending deletions
I0803 16:09:55.170512       1 appliedmanifestwork_finalize_controller.go:113] 1 resources pending deletions
I0803 16:09:55.202489       1 appliedmanifestwork_finalize_controller.go:113] 1 resources pending deletions
If you notice other resources that have been stuck in deletion for a long time, please collect the AppliedManifestWork resources directly. Otherwise, please reproduce the issue once more.
Thanks


## Deleting cluster '2kgb7b38ps74kb7nsrfhiosnr52d8mv6'

According to the logs, maestro and klusterlet-agent seems  to  have worked as expected.
The maestro agent received the delete request at 2025-08-06T07:54:58.329695149Z,  and then started to delete the associated ManifestWork.
At the same time (I0806 07:54:58.567624), the klusterlet-agent began deleting the resources defined in the ManifestWork, including:
- Secrets:
  ocm-j-ah-748-2kgb7b38ps74kb7nsrfhiosnr52d8mv6/cs-ci-9pbnb-pull
  ocm-j-ah-748-2kgb7b38ps74kb7nsrfhiosnr52d8mv6/bound-service-account-signing-key

- SecretSyncs:
  ocm-j-ah-748-2kgb7b38ps74kb7nsrfhiosnr52d8mv6/kube-apiserver-tls-cert
  open-cluster-management-policies/default-ingress-tls-cert-2kgb7b38ps74kb7nsrfhiosnr52d8mv6

- SecretProviderClasses:
  ocm-j-ah-748-2kgb7b38ps74kb7nsrfhiosnr52d8mv6/kube-apiserver-tls-cert
  open-cluster-management-policies/default-ingress-tls-cert-2kgb7b38ps74kb7nsrfhiosnr52d8mv6

- ConfigMaps:
  open-cluster-management-policies/default-ingress-config-2kgb7b38ps74kb7nsrfhiosnr52d8mv6

- HostedClusters:
  ocm-j-ah-748-2kgb7b38ps74kb7nsrfhiosnr52d8mv6/cs-ci-9pbnb
By 2025-08-06T08:33:29.548198126Z, all resources in the manifestwork had been deleted, and the manifestwork created by maestro was subsequently deleted.
The deletion delay may be caused by the resources themselves, we may need to monitor how long it takes to delete these resources.
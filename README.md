# EKS vLLM Inference Benchmark

This project deploys `Qwen2.5-7B-Instruct` behind a vLLM OpenAI-compatible API on Amazon EKS and runs a small concurrency demo from a CPU node.

## Architecture

- GPU node: vLLM server pod serving the model on `/v1/chat/completions`
- CPU node: load generator pod that runs a single-request test and then a 20-request parallel test
- Kubernetes manifests: define placement, service exposure, and model configuration

## Folder Layout

- `k8s/namespace.yaml`: demo namespace
- `k8s/hf-secret.example.yaml`: template for the Hugging Face token secret
- `k8s/vllm-deployment.yaml`: GPU-bound vLLM deployment
- `k8s/vllm-service.yaml`: in-cluster service for the vLLM API
- `k8s/loadgen-configmap.yaml`: Python async load test packaged as a ConfigMap
- `k8s/loadgen-pod.yaml`: CPU-bound pod that runs the load test
- `k8s/kustomization.yaml`: convenience manifest list
- `scripts/load_test.py`: local copy of the same load test script

## Assumptions

- Your EKS cluster already exists
- Your GPU node group uses the EKS-optimized accelerated Amazon Linux 2023 AMI
- Your CPU node group uses a standard EKS-optimized Amazon Linux 2023 AMI
- GPU nodes are labeled `workload-type=gpu`
- CPU nodes are labeled `workload-type=cpu`
- The NVIDIA device plugin is available in the cluster
- You have accepted the model license on Hugging Face and have a valid token

## Before You Apply

1. Copy `k8s/hf-secret.example.yaml` to `k8s/hf-secret.yaml`
2. Replace `REPLACE_WITH_HF_TOKEN_BASE64` with the base64-encoded Hugging Face token
3. If needed, adjust the node labels in `k8s/vllm-deployment.yaml` and `k8s/loadgen-pod.yaml`
4. If needed, tune the vLLM args for your GPU capacity

PowerShell example for base64 encoding:

```powershell
[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("REPLACE_WITH_HF_TOKEN"))
```

## Deploy

```powershell
kubectl apply -k .\k8s
kubectl apply -f .\k8s\hf-secret.yaml
```

If you prefer applying files individually:

```powershell
kubectl apply -f .\k8s\namespace.yaml
kubectl apply -f .\k8s\hf-secret.yaml
kubectl apply -f .\k8s\vllm-deployment.yaml
kubectl apply -f .\k8s\vllm-service.yaml
kubectl apply -f .\k8s\loadgen-configmap.yaml
kubectl apply -f .\k8s\loadgen-pod.yaml
```

## Watch The Demo

```powershell
kubectl get pods -n llm-demo -o wide
kubectl logs -n llm-demo pod/loadgen -f
```

The load generator prints results for:

- concurrency `1`
- concurrency `20`

Use those two runs to explain:

- continuous batching
- KV-cache and prefix-caching efficiency
- GPU utilization under concurrent traffic
- why vLLM performs better than naive one-request-per-process serving

## Optional Checks

Check the serving pod placement:

```powershell
kubectl get pod -n llm-demo -l app=vllm-qwen25-7b -o wide
```

Check the API locally with port-forward:

```powershell
kubectl port-forward -n llm-demo svc/vllm-service 8000:80
```

Then call:

```powershell
curl http://127.0.0.1:8000/v1/models
```

## Tuning Knobs

The first demo uses these vLLM settings:

- `--gpu-memory-utilization=0.90`
- `--max-num-seqs=32`
- `--max-num-batched-tokens=4096`
- `--enable-prefix-caching`

Those are the main settings to vary during the presentation experiments.

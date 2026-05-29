import asyncio
import os
import statistics
import time

import aiohttp

# Target the in-cluster OpenAI-compatible vLLM endpoint by default.
URL = os.environ.get(
    "VLLM_URL",
    "http://vllm-service.llm-demo.svc.cluster.local/v1/chat/completions",
)
MODEL = os.environ.get("MODEL_NAME", "qwen25-7b")
CONCURRENCY = int(os.environ.get("CONCURRENCY", "1"))

# Shared request payload used for both the single-user and concurrent tests.
PAYLOAD = {
    "model": MODEL,
    "messages": [
        {"role": "system", 
         "content": "You are a concise assistant."},
        {
            "role": "user",
            "content": "Explain in 80 words what continuous batching means in LLM serving.",
        },
    ],
    "temperature": 0.0,
    "max_tokens": 120,
}




# Measure the end-to-end latency for one request from send to full response body.
async def one_request(session, idx):
    start = time.perf_counter()
    async with session.post(URL, json=PAYLOAD) as response:
        body = await response.text()
        latency = time.perf_counter() - start
        return {
            "id": idx,
            "status": response.status,
            "latency_s": latency,
            "body_len": len(body),
        }



# Compute a simple percentile for latency reporting, including p95.
def percentile(values, ratio):
    ordered = sorted(values)
    index = max(0, int(len(ordered) * ratio) - 1)
    return ordered[index]




# Run one experiment at a given concurrency level and summarize the results.
async def run_batch(concurrency):
    async with aiohttp.ClientSession() as session:
        tasks = [one_request(session, idx) for idx in range(concurrency)]
        batch_start = time.perf_counter()
        results = await asyncio.gather(*tasks)
        total_time = time.perf_counter() - batch_start

    # Mean latency shows the average response time across all successful requests.
    latencies = [item["latency_s"] for item in results if item["status"] == 200]
    # Success count is used for both pass/fail visibility and throughput calculation.
    successes = sum(1 for item in results if item["status"] == 200)

    print()
    print(f"=== Concurrency: {concurrency} ===")
    print(f"Success: {successes}/{len(results)}")
    print(f"Wall time: {total_time:.2f}s")
    if latencies:
        # Mean latency is the average response time for the successful requests.
        print(f"Mean latency: {statistics.mean(latencies):.2f}s")
        # P50 latency is the median response time.
        print(f"P50 latency: {statistics.median(latencies):.2f}s")
        # P95 latency highlights tail latency under load.
        print(f"P95 latency: {percentile(latencies, 0.95):.2f}s")
        # Requests per second is the successful request count divided by wall time.
        print(f"Req/s: {successes / total_time:.2f}")



# First capture the single-request baseline, then run the parallel-load experiment.
async def main():
    await run_batch(CONCURRENCY)


if __name__ == "__main__":
    asyncio.run(main())



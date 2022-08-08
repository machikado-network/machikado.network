/**
 * Welcome to Cloudflare Workers! This is your first worker.
 *
 * - Run `wrangler dev src/index.ts` in your terminal to start a development server
 * - Open a browser tab at http://localhost:8787/ to see your worker in action
 * - Run `wrangler publish src/index.ts --name my-worker` to publish your worker
 *
 * Learn more at https://developers.cloudflare.com/workers/
 */
const TESTNET_URL = "https://fullnode.devnet.aptoslabs.com"

export interface Env {
	// Example binding to KV. Learn more at https://developers.cloudflare.com/workers/runtime-apis/kv/
	// MY_KV_NAMESPACE: KVNamespace;
	//
	// Example binding to Durable Object. Learn more at https://developers.cloudflare.com/workers/runtime-apis/durable-objects/
	// MY_DURABLE_OBJECT: DurableObjectNamespace;
	//
	// Example binding to R2. Learn more at https://developers.cloudflare.com/workers/runtime-apis/r2/
	// MY_BUCKET: R2Bucket;
}

export default {
	async fetch(
		request: Request,
		env: Env,
		ctx: ExecutionContext
	): Promise<Response> {
		if (request.method !== "GET") {
			const url = new URL(request.url)
			return await fetch(`${TESTNET_URL}${url.pathname}`, {
				headers: request.headers,
				method: request.method,
				body: request.body,
			})
		}

		const cacheUrl = new URL(request.url);
		const cache = caches.default;
		let response = await cache.match(request.url);

		if (!response) {
			response = await fetch(`${TESTNET_URL}${cacheUrl.pathname}`, {
				headers: request.headers,
				method: request.method,
			})
			response = new Response(response!.body);
			response!.headers.append('Cache-Control', 'maxage=60, must-revalidate');
			response!.headers.append("Access-Control-Allow-Origin", "*")
			ctx.waitUntil(cache.put(request.url, response!.clone()));
		} else {
			console.log("cached!")
		}
		return response
	},
}

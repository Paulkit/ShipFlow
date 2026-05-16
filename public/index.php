<?php

declare(strict_types=1);

$basePath = dirname(__DIR__);
$autoloadPath = $basePath . '/vendor/autoload.php';
$bootstrapPath = $basePath . '/bootstrap/app.php';

if (is_file($autoloadPath)) {
  require $autoloadPath;
}

if (is_file($bootstrapPath)) {
  $app = require $bootstrapPath;

  $kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
  $request = Illuminate\Http\Request::capture();

  $response = $kernel->handle($request);
  $response->send();
  $kernel->terminate($request, $response);
  return;
}

http_response_code(200);
header('Content-Type: text/html; charset=UTF-8');

echo '<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>ShipFlow</title><style>body{font-family:Arial,sans-serif;margin:0;display:grid;place-items:center;min-height:100vh;background:#f5f7fb;color:#1f2937}main{max-width:720px;padding:40px}code{background:#e5e7eb;padding:2px 6px;border-radius:4px}</style></head><body><main><h1>ShipFlow Docker is running</h1><p>The web server is up, but the full Laravel skeleton is not present in this workspace yet.</p><p>Once <code>bootstrap/app.php</code> and <code>artisan</code> are restored, this entrypoint will boot Laravel automatically.</p></main></body></html>';

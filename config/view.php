<?php

return [

  /*
    |--------------------------------------------------------------------------
    | View Storage Paths
    |--------------------------------------------------------------------------
    |
    | Most templating systems load templates from disk. This option tells
    | Laravel where the compiled Blade templates should be stored.
    |
    */

  'paths' => [
    resource_path('views'),
  ],

  'compiled' => env(
    'VIEW_COMPILED_PATH',
    realpath(storage_path('framework/views')) ?: storage_path('framework/views')
  ),

];

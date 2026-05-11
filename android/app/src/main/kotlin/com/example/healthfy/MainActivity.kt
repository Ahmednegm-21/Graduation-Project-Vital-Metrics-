package com.example.healthfy

import io.flutter.embedding.android.FlutterFragmentActivity

// Changed from FlutterActivity to FlutterFragmentActivity
// This is required by the health package because it needs ComponentActivity
// which FlutterFragmentActivity extends but FlutterActivity does not
class MainActivity : FlutterFragmentActivity()
import 'package:flutter/material.dart';
import 'package:flutter_native_player/controls/player_controls_theme.dart';
import 'package:flutter_native_player/flutter_native_player.dart';
import 'package:flutter_native_player/model/player_resource.dart';

/// This demonstrates the EASIEST way to customize the player -
/// using themes instead of building custom UI!

void main() => runApp(const ThemeExamplesApp());

class ThemeExamplesApp extends StatelessWidget {
  const ThemeExamplesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Theme-Based Customization',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ThemeExamplesHome(),
    );
  }
}

class ThemeExamplesHome extends StatelessWidget {
  const ThemeExamplesHome({Key? key}) : super(key: key);

  final String videoUrl =
      "https://p-events-delivery.akamaized.net/2109isftrwvmiekgrjkbbhxhfbkxjkoj/m3u8/vod_index.m3u8";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Easy Customization with Themes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '🎨 No Complex UI Code Needed!\nJust pass a theme parameter',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Example 1: Default theme
          const Text(
            '1. Default Theme (No customization)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Just use it - no theme parameter needed:'),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FlutterNativePlayer.withBasicControls(
              playerResource: PlayerResource(videoUrl: videoUrl),
              width: double.infinity,
              height: 200,
            ),
          ),
          const SizedBox(height: 24),

          // Example 2: Brand colors
          const Text(
            '2. Brand Colors (Super Easy!)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Change colors to match your brand:'),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.purple),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FlutterNativePlayer.withFullControls(
              playerResource: PlayerResource(videoUrl: videoUrl),
              width: double.infinity,
              height: 200,
              // 👇 Just one line for brand colors!
              theme: PlayerControlsTheme.brand(
                primaryColor: Colors.purple,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Example 3: Light theme
          const Text(
            '3. Light Theme',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Perfect for light backgrounds:'),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
            ),
            child: FlutterNativePlayer.withBasicControls(
              playerResource: PlayerResource(videoUrl: videoUrl),
              width: double.infinity,
              height: 200,
              // 👇 Pre-built light theme!
              theme: PlayerControlsTheme.light(),
            ),
          ),
          const SizedBox(height: 24),

          // Example 4: Custom theme
          const Text(
            '4. Custom Theme (Advanced)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Full control over all aspects:'),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FlutterNativePlayer.withFullControls(
              playerResource: PlayerResource(videoUrl: videoUrl),
              width: double.infinity,
              height: 200,
              // 👇 Customize everything you want!
              theme: const PlayerControlsTheme(
                primaryColor: Colors.green,
                iconColor: Colors.greenAccent,
                textColor: Colors.white,
                mainIconSize: 70, // Bigger play button
                secondaryIconSize: 45, // Bigger seek buttons
                progressBarHeight: 5, // Thicker progress bar
                progressBarColor: Colors.greenAccent,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Comparison card
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✨ Why This is Better:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitRow('❌ Old way: Build custom UI with sliders, formatters'),
                  _buildBenefitRow('✅ New way: Just pass a theme object'),
                  const SizedBox(height: 8),
                  _buildBenefitRow('❌ Old way: Manage state, streams, controllers'),
                  _buildBenefitRow('✅ New way: Everything handled for you'),
                  const SizedBox(height: 8),
                  _buildBenefitRow('❌ Old way: 200+ lines of complex code'),
                  _buildBenefitRow('✅ New way: 3-5 lines of simple code'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

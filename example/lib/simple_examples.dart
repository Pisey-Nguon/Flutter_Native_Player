import 'package:flutter/material.dart';
import 'package:flutter_native_player/controls/player_controls_theme.dart';
import 'package:flutter_native_player/flutter_native_player.dart';
import 'package:flutter_native_player/model/player_resource.dart';
import 'package:flutter_native_player/model/player_subtitle_resource.dart';

/// This file demonstrates the SIMPLIFIED API for Flutter Native Player.
/// Compare these examples with main.dart to see how much code you save!

void main() {
  runApp(const SimpleExamplesApp());
}

class SimpleExamplesApp extends StatelessWidget {
  const SimpleExamplesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simplified Player Examples',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const SimpleExamplesHome(),
    );
  }
}

class SimpleExamplesHome extends StatelessWidget {
  const SimpleExamplesHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simplified Examples')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'These examples show how easy it is to integrate the player with the new factory constructors!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildExampleCard(
            context,
            'Minimal Controls',
            'Just a play/pause button - simplest option',
            '5 lines of code',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MinimalExample(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildExampleCard(
            context,
            'Basic Controls',
            'Play/pause + progress bar - most common use case',
            '7 lines of code',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BasicExample(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildExampleCard(
            context,
            'Full Controls',
            'All features: quality, speed, subtitles',
            '11 lines of code',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FullExample(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildExampleCard(
            context,
            'Comparison',
            'See old vs new implementation',
            'Side by side',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ComparisonExample(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context,
    String title,
    String description,
    String complexity,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      complexity,
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Example 1: Minimal Controls - Just 5 lines!
class MinimalExample extends StatelessWidget {
  const MinimalExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minimal Controls')),
      body: Center(
        child: FlutterNativePlayer.withMinimalControls(
          playerResource: PlayerResource(
            videoUrl:
                "https://p-events-delivery.akamaized.net/2109isftrwvmiekgrjkbbhxhfbkxjkoj/m3u8/vod_index.m3u8",
          ),
          width: double.infinity,
          height: 250,
        ),
      ),
    );
  }
}

/// Example 2: Basic Controls - Just 7 lines!
class BasicExample extends StatelessWidget {
  const BasicExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Controls')),
      body: Center(
        child: FlutterNativePlayer.withBasicControls(
          playerResource: PlayerResource(
            videoUrl:
                "https://p-events-delivery.akamaized.net/2109isftrwvmiekgrjkbbhxhfbkxjkoj/m3u8/vod_index.m3u8",
          ),
          width: double.infinity,
          height: 250,
          theme: const PlayerControlsTheme(primaryColor: Colors.blue),
        ),
      ),
    );
  }
}

/// Example 3: Full Controls - Just 11 lines!
class FullExample extends StatelessWidget {
  const FullExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Full Controls')),
      body: Center(
        child: FlutterNativePlayer.withFullControls(
          playerResource: PlayerResource(
            videoUrl:
                "https://p-events-delivery.akamaized.net/2109isftrwvmiekgrjkbbhxhfbkxjkoj/m3u8/vod_index.m3u8",
            playerSubtitleResources: [
              PlayerSubtitleResource(
                language: "English",
                subtitleUrl:
                    "https://raw.githubusercontent.com/Pisey-Nguon/Player-Resource/master/%5BEnglish%5D%20Apple%20Event%20%E2%80%94%20October%2013%20%5BDownSub.com%5D.srt",
              ),
              PlayerSubtitleResource(
                language: "Japanese",
                subtitleUrl:
                    "https://raw.githubusercontent.com/Pisey-Nguon/Player-Resource/master/%5BJapanese%5D%20Apple%20Event%20%E2%80%94%20October%2013%20%5BDownSub.com%5D.srt",
              ),
            ],
          ),
          width: double.infinity,
          height: 250,
          theme: const PlayerControlsTheme(primaryColor: Colors.blue),
          showQualitySelector: true,
          showSpeedSelector: true,
          showSubtitleSelector: true,
        ),
      ),
    );
  }
}

/// Comparison: Old way vs New way
class ComparisonExample extends StatelessWidget {
  const ComparisonExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Old vs New')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '❌ OLD WAY (200+ lines)',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: const Text(
              '• Create StatefulWidget\n'
              '• Define controller variables\n'
              '• Listen to streams\n'
              '• Build entire UI from scratch\n'
              '• Handle slider state manually\n'
              '• Format duration strings\n'
              '• Create quality selector bottom sheet\n'
              '• Create speed selector bottom sheet\n'
              '• Create subtitle selector bottom sheet\n'
              '• Handle gesture detection\n'
              '• Implement auto-hide logic\n'
              '• Dispose streams properly',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '✅ NEW WAY (11 lines)',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: const Text(
              'FlutterNativePlayer.withFullControls(\n'
              '  playerResource: PlayerResource(\n'
              '    videoUrl: url,\n'
              '    playerSubtitleResources: subtitles,\n'
              '  ),\n'
              '  width: double.infinity,\n'
              '  height: 250,\n'
              '  showQualitySelector: true,\n'
              '  showSpeedSelector: true,\n'
              '  showSubtitleSelector: true,\n'
              ')',
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Courier',
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Card(
            color: Colors.blue,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '🎉 95% Less Code!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Same features, way easier to use',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Live Demo:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          FlutterNativePlayer.withFullControls(
            playerResource: PlayerResource(
              videoUrl:
                  "https://p-events-delivery.akamaized.net/2109isftrwvmiekgrjkbbhxhfbkxjkoj/m3u8/vod_index.m3u8",
              playerSubtitleResources: [
                PlayerSubtitleResource(
                  language: "English",
                  subtitleUrl:
                      "https://raw.githubusercontent.com/Pisey-Nguon/Player-Resource/master/%5BEnglish%5D%20Apple%20Event%20%E2%80%94%20October%2013%20%5BDownSub.com%5D.srt",
                ),
              ],
            ),
            width: double.infinity,
            height: 250,
          ),
        ],
      ),
    );
  }
}

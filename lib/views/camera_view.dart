import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../controller/scan_controller.dart';
import '../utils/assets_manager.dart';

class CameraView extends StatelessWidget {
  CameraView({super.key});

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _playSound(String path) async {
    try {
      await _audioPlayer.play(AssetSource(path));
    } catch (error) {
      log("error $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: SafeArea(
        child: GetBuilder<ScanController>(
          init: ScanController(),
          builder: (controller) {
            return controller.isCameraInitialized.value
                ? Column(
                    children: [
                      if (controller.isCameraInitialized.value)
                        !controller.showCamera
                            ? SizedBox(
                                height: size.height * 0.5,
                                child: Image.asset(AssetsManager.noCamera),
                              )
                            : SizedBox(
                                height: size.height * 0.5,
                                width: double.infinity,
                                child: CameraPreview(
                                  controller.cameraController,
                                ),
                              )
                      else
                        const Expanded(
                            child: Center(child: Text("Camera not active"))),
                      SizedBox(
                        width: double.infinity,
                        height: size.height * 0.3,
                        child: Material(
                          color:
                              controller.showCamera ? Colors.green : Colors.red,
                          child: InkWell(
                            onTap: () async {
                              controller
                                  .changeShowCamera(!controller.showCamera);
                              if (controller.showCamera) {
                                // Play sound for turning camera on
                                await _playSound(AssetsManager.turnOffAudio);
                              } else {
                                // Play sound for turning camera off
                                await _playSound(AssetsManager.turnOnAudio);
                              }
                            },
                            child: Center(
                              child: Text(
                                controller.showCamera
                                    ? "Turn Camera Off"
                                    : "Turn Camera On",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                            itemCount: controller.detectedLabels.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Chip(
                                  label: Text(
                                    controller.detectedLabels.reversed
                                        .toList()[index],
                                  ),
                                ),
                              );
                            }),
                      ),
                      // Container(
                      //   width: 100,
                      //   height: 100,
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(8),
                      //     border: Border.all(color: Colors.green, width: 4.0),
                      //   ),
                      //   child: Column(
                      //     children: [
                      //       Container(
                      //           color: Colors.white,
                      //           child: Text(controller.label))
                      //     ],
                      //   ),
                      // ),
                    ],
                  )
                : const Center(child: Text("Loading Preview..."));
          },
        ),
      ),
    );
  }
}

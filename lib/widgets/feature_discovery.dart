import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';

import '../util/extension_helper.dart';

const String addFeature = 'addFeature';
const String menuFeature = 'menuFeature';
const String playlistFeature = 'playlistFeature';
const String longTapFeature = 'longTapFeature';
const String groupsFeature = 'groupsFeature';
const String podcastFeature = 'podcastFeature';

const String addGroupFeature = 'addGroupFeature';
const String configureGroup = 'configureFeature';
const String configurePodcast = 'configurePodcast';

Widget featureDiscoveryOverlay(BuildContext context,
    {required String featureId,
    Color? buttonColor,
    Color? backgroundColor,
    required Widget child,
    required Widget tapTarget,
    required String title,
    required String description}) {
  final s = context.s;
  return DescribedFeatureOverlay(
      featureId: featureId,
      tapTarget: tapTarget,
      title: Text(title),
      backgroundColor: backgroundColor,
      overflowMode: OverflowMode.clipContent,
      onDismiss: () {
        return Future.value(true);
      },
      description: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(description),
          TextButton(
            style: TextButton.styleFrom(primary: buttonColor),
            child: Text(s.understood,
                style: context.textTheme.button!.copyWith(color: Colors.white)),
            onPressed: () async =>
                FeatureDiscovery.completeCurrentStep(context),
          ),
          TextButton(
            style: TextButton.styleFrom(primary: buttonColor),
            child: Text(s.dismiss,
                style: context.textTheme.button!.copyWith(color: Colors.white)),
            onPressed: () => FeatureDiscovery.dismissAll(context),
          ),
        ],
      ),
      child: child);
}

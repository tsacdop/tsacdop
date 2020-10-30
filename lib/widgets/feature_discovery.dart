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
    {String featureId,
    Color buttonColor,
    Color backgroundColor,
    Widget child,
    Widget tapTarget,
    String title,
    String description}) {
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
          FlatButton(
            color: buttonColor,
            padding: EdgeInsets.zero,
            child: Text(s.understood,
                style: context.textTheme.button.copyWith(color: Colors.white)),
            onPressed: () async =>
                FeatureDiscovery.completeCurrentStep(context),
          ),
          FlatButton(
            color: buttonColor,
            padding: EdgeInsets.zero,
            child: Text(s.dismiss,
                style: context.textTheme.button.copyWith(color: Colors.white)),
            onPressed: () => FeatureDiscovery.dismissAll(context),
          ),
        ],
      ),
      child: child);
}

// Web-specific implementation
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:html' as html show IFrameElement;

// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

Widget createMapWidget() {
  // Google Maps iframe oluştur
  final iframe = html.IFrameElement()
    ..src = _getMapEmbedUrl()
    ..style.border = 'none'
    ..style.width = '100%'
    ..style.height = '100%';

  // Platform view registry'ye kaydet
  ui_web.platformViewRegistry.registerViewFactory(
    'google-map-iframe',
    (int viewId) => iframe,
  );

  return const SizedBox(
    width: 300,
    height: 200,
    child: HtmlElementView(viewType: 'google-map-iframe'),
  );
}

String _getMapEmbedUrl() {
  // Bandırma Onyedi Eylül Üniversitesi adresi
  const address = 'Bandırma Onyedi Eylül Üniversitesi, Bandırma, Balıkesir';

  // Google Maps embed URL (adres ile)
  final encodedAddress = Uri.encodeComponent(address);
  return 'https://www.google.com/maps?q=$encodedAddress&output=embed';
}


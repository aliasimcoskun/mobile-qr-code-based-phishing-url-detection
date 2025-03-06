// lib/services/url_expander.dart

import 'dart:async';
import 'package:http/http.dart' as http;

/*
 * UrlExpander class
 * 
 * This class is used to expand shortened URLs to their original form.
 * It follows redirects until the final URL is reached or a maximum number
 * of redirects is reached. The final URL is then returned.
 * 
 */
class UrlExpander {
  /*
   * expandUrl method
   * 
   * This method takes a shortened URL and returns the original URL.
   * It follows redirects until the final URL is reached or a maximum number
   * of redirects is reached. The final URL is then returned.
   * 
   * Parameters:
   * - url: The shortened URL to expand
   * - maxRedirects: The maximum number of redirects to follow
   * 
   * Returns:
   * - The original URL after following redirects
   * 
   * Example usage:
   * final expandedUrl = await UrlExpander.expandUrl('https://shorturl.at/wsuGF');
   * print(expandedUrl);
   * 
   */
  static Future<String?> expandUrl(String url, [int maxRedirects = 3]) async {
    // Print debug message for initial URL
    print("[DEBUG] Checking URL: $url");

    // Stop if too many redirects
    if (maxRedirects <= 0) {
      print("[ERROR] Too many redirects");
      return url;
    }

    try {
      // Encode the URL to handle special characters
      final encodedUrl = Uri.encodeFull(url);
      final client = http.Client();

      // Preparing an HTTP GET request without automatic redirects
      final request = http.Request('GET', Uri.parse(encodedUrl))
        ..followRedirects = false
        ..headers.addAll({
          'User-Agent': 'Mozilla/5.0',
          'Accept': 'text/html,application/xhtml+xml,application/xml',
        });

      // Send the request with a short timeout
      final streamedResponse =
          await client.send(request).timeout(const Duration(seconds: 3));

      print("[DEBUG] Response status: ${streamedResponse.statusCode}");
      print("[DEBUG] Response headers: ${streamedResponse.headers}");

      // Check for redirect status codes (3xx)
      if (streamedResponse.statusCode >= 300 &&
          streamedResponse.statusCode < 400) {
        final location = streamedResponse.headers['location'];
        if (location != null) {
          print("[DEBUG] Following redirect to: $location");
          client.close();
          // Construct the next URL to follow
          final redirectUrl =
              Uri.parse(encodedUrl).resolve(location).toString();
          return expandUrl(redirectUrl, maxRedirects - 1);
        }
        client.close();
        return url;
      }
      client.close();

      // If response is successful (2xx), return the final URL
      final finalUrl = streamedResponse.request?.url.toString();
      if (streamedResponse.statusCode >= 200 &&
          streamedResponse.statusCode < 300) {
        print("[DEBUG] Final URL: $finalUrl");
        return finalUrl;
      } else {
        print("[ERROR] Non-2xx status code: returning original URL");
        return url;
      }
    } on TimeoutException catch (_) {
      // Return original URL if request times out
      print("[ERROR] expandUrl timed out: returning original URL");
      return url;
    } catch (e) {
      // Return original URL if any other error occurs
      print("[ERROR] expandUrl failed: $e");
      return url;
    }
  }
}

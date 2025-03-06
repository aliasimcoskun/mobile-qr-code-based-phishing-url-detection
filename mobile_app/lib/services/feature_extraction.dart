// lib/services/feature_extraction.dart

import 'dart:core';

/*
 * extractFeatures function
 * 
 * This function extracts features from a given URL.
 * It returns a list of features that can be used for model inference.
 * 
 * Parameters:
 * - url: The URL to extract features from
 * 
 * Returns:
 * - A list of features extracted from the URL
 * 
 * Example usage:
 * final features = extractFeatures('https://www.google.com');
 * print(features);
 * 
 */
List<double> extractFeatures(String url) {
  try {
    // URL'i parse et
    Uri parsed = Uri.parse(url);
    String domain = parsed.host.toLowerCase(); // Netloc
    String path = parsed.path.toLowerCase();
    String scheme = parsed.scheme.toLowerCase();

    // 1. domain_length
    double domainLength = domain.length.toDouble();

    // 2. having ip address
    bool haveIp = isIPAddress(domain) ? true : false;
    double haveIpDouble = haveIp ? 1.0 : 0.0;

    // 3. having @ symbol
    bool haveAt = url.contains('@') ? true : false;
    double haveAtDouble = haveAt ? 1.0 : 0.0;

    // 4. url length
    double urlLength = url.length.toDouble();

    // 5. url depth (path segments)
    List<String> segments =
        path.split('/').where((segment) => segment.isNotEmpty).toList();
    double urlDepth = segments.length.toDouble();

    // 6. redirection (if '//' appears in path)
    bool redirection = path.contains('//') ? true : false;
    double redirectionDouble = redirection ? 1.0 : 0.0;

    // 7. https in domain
    bool httpsDomain = scheme == 'https' ? true : false;
    double httpsDomainDouble = httpsDomain ? 1.0 : 0.0;

    // 8. tinyurl or bit.ly in domain
    bool tinyUrl =
        domain.contains('tinyurl') || domain.contains('bit.ly') ? true : false;
    double tinyUrlDouble = tinyUrl ? 1.0 : 0.0;

    // 9. prefix or suffix in domain (presence of '-')
    bool prefixSuffix = domain.contains('-') ? true : false;
    double prefixSuffixDouble = prefixSuffix ? 1.0 : 0.0;

    return [
      domainLength,
      haveIpDouble,
      haveAtDouble,
      urlLength,
      urlDepth,
      redirectionDouble,
      httpsDomainDouble,
      tinyUrlDouble,
      prefixSuffixDouble,
    ];
  } catch (e) {
    // Return 0 for all properties on error
    return List.filled(9, 0.0);
  }
}

/*
 * isIPAddress function
 * 
 * This function checks if a given domain is an IP address.
 * 
 * Parameters:
 * - domain: The domain to check
 * 
 * Returns:
 * - True if the domain is an IP address, false otherwise
 * 
 */
bool isIPAddress(String domain) {
  final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
  return ipRegex.hasMatch(domain);
}

import 'package:get/get.dart';

import '../../globals.dart';
import '../../pages/upgrade/currency_data.dart';

class GumroadProduct {
  GumroadProduct({
    this.success = false,
    this.product = const Product(),
  });

  final bool success;
  final Product product;

  factory GumroadProduct.fromJson(Map<String, dynamic> json) => GumroadProduct(
        success: json["success"],
        product: Product.fromJson(json["product"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "product": product.toJson(),
      };
}

class Product {
  const Product({
    this.name = '',
    this.previewUrl = '',
    this.description = '',
    this.customizablePrice = false,
    this.requireShipping = false,
    this.customReceipt = '',
    this.customPermalink = '',
    this.subscriptionDuration = '',
    this.id = '',
    this.url = '',
    this.price = 0,
    this.currency = '',
    this.shortUrl = '',
    this.thumbnailUrl = '',
    this.formattedPrice = 'Loading...',
    this.published = false,
    this.shownOnProfile = false,
    this.deleted = false,
    this.customSummary = '',
    this.isTieredMembership = false,
    this.recurrences = const [],
    this.variants = const [],
    this.salesCount = 0,
    this.salesUsdCents = 0,
  });

  final String name;
  final String previewUrl;
  final String description;
  final bool customizablePrice;
  final bool requireShipping;
  final String customReceipt;
  final String customPermalink;
  final String subscriptionDuration;
  final String id;
  final dynamic url;
  final int price;
  final String currency;
  final String shortUrl;
  final String thumbnailUrl;
  final String formattedPrice;
  final bool published;
  final bool shownOnProfile;
  final bool deleted;
  final String customSummary;
  final bool isTieredMembership;
  final List<String> recurrences;
  final List<Variant> variants;
  final int salesCount;
  final int salesUsdCents;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        name: json["name"],
        previewUrl: json["preview_url"] ?? '',
        description: json["description"],
        customizablePrice: json["customizable_price"],
        requireShipping: json["require_shipping"],
        customReceipt: json["custom_receipt"],
        customPermalink: json["custom_permalink"],
        subscriptionDuration: json["subscription_duration"],
        id: json["id"],
        url: json["url"] ?? '',
        price: json["price"],
        currency: json["currency"],
        shortUrl: json["short_url"],
        thumbnailUrl: json["thumbnail_url"] ?? '',
        formattedPrice: json["formatted_price"],
        published: json["published"],
        shownOnProfile: json["shown_on_profile"],
        deleted: json["deleted"],
        customSummary: json["custom_summary"],
        isTieredMembership: json["is_tiered_membership"],
        recurrences: List<String>.from(json["recurrences"].map((x) => x)),
        variants: List<Variant>.from(
            json["variants"].map((x) => Variant.fromJson(x))),
        salesCount: json["sales_count"],
        salesUsdCents: json["sales_usd_cents"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "preview_url": previewUrl,
        "description": description,
        "customizable_price": customizablePrice,
        "require_shipping": requireShipping,
        "custom_receipt": customReceipt,
        "custom_permalink": customPermalink,
        "subscription_duration": subscriptionDuration,
        "id": id,
        "url": url,
        "price": price,
        "currency": currency,
        "short_url": shortUrl,
        "thumbnail_url": thumbnailUrl,
        "formatted_price": formattedPrice,
        "published": published,
        "shown_on_profile": shownOnProfile,
        "deleted": deleted,
        "custom_summary": customSummary,
        "is_tiered_membership": isTieredMembership,
        "recurrences": List<dynamic>.from(recurrences.map((x) => x)),
        "variants": List<dynamic>.from(variants.map((x) => x.toJson())),
        "sales_count": salesCount,
        "sales_usd_cents": salesUsdCents,
      };

  String get buttonSubTitle {
    return "${'now_only'.tr} $formattedPrice' - ${'cancel_anytime'.tr}";
  }

  String get discount {
    if (variants.isEmpty) return '';
    if (variants.first.options.isEmpty) return '';

    final price =
        variants.first.options.first.recurrencePrices.yearly.priceCents / 100;
    final currencySymbol =
        kCurrencyData[currency.toUpperCase()]?['symbol'] ?? '';
    final origPrice = '$currencySymbol${currencyFormatter.format(price * 2)}';

    return '${'from'.tr} $origPrice ${'to_only'.tr} $formattedPrice';
  }
}

class Variant {
  const Variant({
    this.title = '',
    this.options = const [],
  });

  final String title;
  final List<VariantOption> options;

  factory Variant.fromJson(Map<String, dynamic> json) => Variant(
        title: json["title"],
        options: List<VariantOption>.from(
            json["options"].map((x) => VariantOption.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "options": List<dynamic>.from(options.map((x) => x.toJson())),
      };
}

class VariantOption {
  const VariantOption({
    this.name = '',
    this.priceDifference = 0,
    this.isPayWhatYouWant = false,
    this.recurrencePrices = const RecurrencePrices(),
    this.url,
  });

  final String name;
  final int priceDifference;
  final bool isPayWhatYouWant;
  final RecurrencePrices recurrencePrices;
  final dynamic url;

  factory VariantOption.fromJson(Map<String, dynamic> json) => VariantOption(
        name: json["name"],
        priceDifference: json["price_difference"],
        isPayWhatYouWant: json["is_pay_what_you_want"],
        recurrencePrices: RecurrencePrices.fromJson(json["recurrence_prices"]),
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "price_difference": priceDifference,
        "is_pay_what_you_want": isPayWhatYouWant,
        "recurrence_prices": recurrencePrices.toJson(),
        "url": url,
      };
}

class RecurrencePrices {
  const RecurrencePrices({
    this.yearly = const VariantPrice(),
  });

  final VariantPrice yearly;

  factory RecurrencePrices.fromJson(Map<String, dynamic> json) =>
      RecurrencePrices(
        yearly: VariantPrice.fromJson(json["yearly"]),
      );

  Map<String, dynamic> toJson() => {
        "yearly": yearly.toJson(),
      };
}

class VariantPrice {
  const VariantPrice({
    this.priceCents = 0,
    this.suggestedPriceCents,
  });

  final int priceCents;
  final dynamic suggestedPriceCents;

  factory VariantPrice.fromJson(Map<String, dynamic> json) => VariantPrice(
        priceCents: json["price_cents"],
        suggestedPriceCents: json["suggested_price_cents"],
      );

  Map<String, dynamic> toJson() => {
        "price_cents": priceCents,
        "suggested_price_cents": suggestedPriceCents,
      };
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/utils/constants/iconsax_compat.dart';

void main() {
  test('every app Iconsax glyph has a valid Unicode codepoint', () {
    const icons = <IconData>[
      Iconsax.activity,
      Iconsax.add,
      Iconsax.arrow_left,
      Iconsax.arrow_right_3,
      Iconsax.arrow_right_34,
      Iconsax.bag_2,
      Iconsax.building,
      Iconsax.building_31,
      Iconsax.call,
      Iconsax.code,
      Iconsax.direct,
      Iconsax.direct_right,
      Iconsax.edit,
      Iconsax.edit_2,
      Iconsax.eye,
      Iconsax.eye_slash,
      Iconsax.gallery,
      Iconsax.global,
      Iconsax.heart,
      Iconsax.heart5,
      Iconsax.home,
      Iconsax.home_15,
      Iconsax.info_circle,
      Iconsax.location,
      Iconsax.location5,
      Iconsax.minus,
      Iconsax.mobile,
      Iconsax.notification,
      Iconsax.password_check,
      Iconsax.profile_circle,
      Iconsax.receipt_item,
      Iconsax.scan_barcode,
      Iconsax.search_normal,
      Iconsax.send_2,
      Iconsax.shield_cross,
      Iconsax.shield_tick,
      Iconsax.shop,
      Iconsax.shopping_bag,
      Iconsax.star1,
      Iconsax.tick_circle,
      Iconsax.tick_circle5,
      Iconsax.trash,
      Iconsax.user,
      Iconsax.user5,
      Iconsax.verify5,
      Iconsax.warning_2,
    ];

    expect(icons, hasLength(46));
    expect(icons.every((icon) => icon.codePoint > 0), isTrue);
  });

  test('legacy filled variants retain distinct semantic icons', () {
    expect(Iconsax.heart5, Icons.favorite_rounded);
    expect(Iconsax.home_15, Icons.home_rounded);
    expect(Iconsax.location5, Icons.location_on_rounded);
    expect(Iconsax.star1, Icons.star_rounded);
    expect(Iconsax.tick_circle5, Icons.check_circle_rounded);
    expect(Iconsax.user5, Icons.person_rounded);
    expect(Iconsax.verify5, Icons.verified_rounded);
  });
}

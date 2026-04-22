import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TakashIcon extends StatelessWidget {
  final String assetName;
  final double size;
  final Color? color;

  const TakashIcon({
    super.key,
    required this.assetName,
    this.size = 24,
    this.color,
  });

  static const String _basePath = 'assets/icons';

  static const add = '$_basePath/actions/add.svg';
  static const bookmarkFilled = '$_basePath/actions/bookmark_filled.svg';
  static const bookmark = '$_basePath/actions/bookmark.svg';
  static const checkCircle = '$_basePath/actions/check_circle.svg';
  static const check = '$_basePath/actions/check.svg';
  static const copy = '$_basePath/actions/copy.svg';
  static const delete = '$_basePath/actions/delete.svg';
  static const edit = '$_basePath/actions/edit.svg';
  static const favoriteActive = '$_basePath/actions/favorite_active.svg';
  static const favoriteInactive = '$_basePath/actions/favorite_inactive.svg';
  static const filter = '$_basePath/actions/filter.svg';
  static const moreHoriz = '$_basePath/actions/more_horiz.svg';
  static const moreVert = '$_basePath/actions/more_vert.svg';
  static const refresh = '$_basePath/actions/refresh.svg';
  static const reportFlag = '$_basePath/actions/report_flag.svg';
  static const search = '$_basePath/actions/search.svg';
  static const send = '$_basePath/actions/send.svg';
  static const share = '$_basePath/actions/share.svg';

  static const calendar = '$_basePath/form/calendar.svg';
  static const email = '$_basePath/form/email.svg';
  static const info = '$_basePath/form/info.svg';
  static const lockOpen = '$_basePath/form/lock_open.svg';
  static const lock = '$_basePath/form/lock.svg';
  static const personOutline = '$_basePath/form/person_outline.svg';
  static const phone = '$_basePath/form/phone.svg';
  static const visibilityOff = '$_basePath/form/visibility_off.svg';
  static const visibility = '$_basePath/form/visibility.svg';

  static const addPhoto = '$_basePath/listing/add_photo.svg';
  static const camera = '$_basePath/listing/camera.svg';
  static const category = '$_basePath/listing/category.svg';
  static const conditionBadge = '$_basePath/listing/condition_badge.svg';
  static const distance = '$_basePath/listing/distance.svg';
  static const imageOff = '$_basePath/listing/image_off.svg';
  static const locationOn = '$_basePath/listing/location_on.svg';
  static const photoLibrary = '$_basePath/listing/photo_library.svg';
  static const swap = '$_basePath/listing/swap.svg';
  static const tagPrice = '$_basePath/listing/tag_price.svg';

  static const locationOff = '$_basePath/map/location_off.svg';
  static const mapView = '$_basePath/map/map_view.svg';
  static const myLocation = '$_basePath/map/my_location.svg';
  static const radius = '$_basePath/map/radius.svg';

  static const arrowBack = '$_basePath/navigation/arrow_back.svg';
  static const chevronLeft = '$_basePath/navigation/chevron_left.svg';
  static const chevronRight = '$_basePath/navigation/chevron_right.svg';
  static const close = '$_basePath/navigation/close.svg';
  static const expandLess = '$_basePath/navigation/expand_less.svg';
  static const expandMore = '$_basePath/navigation/expand_more.svg';
  static const menu = '$_basePath/navigation/menu.svg';

  static const editProfile = '$_basePath/profile/edit_profile.svg';
  static const inventory = '$_basePath/profile/inventory.svg';
  static const logout = '$_basePath/profile/logout.svg';
  static const notifications = '$_basePath/profile/notifications.svg';
  static const person = '$_basePath/profile/person.svg';
  static const settings = '$_basePath/profile/settings.svg';
  static const storefront = '$_basePath/profile/storefront.svg';
  static const verified = '$_basePath/profile/verified.svg';

  static const chatBubble = '$_basePath/rating/chat_bubble.svg';
  static const starActive = '$_basePath/rating/star_active.svg';
  static const starInactive = '$_basePath/rating/star_inactive.svg';
  static const thumbDown = '$_basePath/rating/thumb_down.svg';
  static const thumbUp = '$_basePath/rating/thumb_up.svg';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetName,
      width: size,
      height: size,
      colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }
}

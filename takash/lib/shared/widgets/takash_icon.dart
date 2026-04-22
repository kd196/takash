import 'package:flutter/widgets.dart';
import 'dart:math' as math;

typedef _IconPainter = void Function(Canvas c, Paint p, double s);

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

  static const _bp = 'assets/icons';

  static const add = '$_bp/actions/add.svg';
  static const bookmarkFilled = '$_bp/actions/bookmark_filled.svg';
  static const bookmark = '$_bp/actions/bookmark.svg';
  static const checkCircle = '$_bp/actions/check_circle.svg';
  static const check = '$_bp/actions/check.svg';
  static const copy = '$_bp/actions/copy.svg';
  static const delete = '$_bp/actions/delete.svg';
  static const edit = '$_bp/actions/edit.svg';
  static const favoriteActive = '$_bp/actions/favorite_active.svg';
  static const favoriteInactive = '$_bp/actions/favorite_inactive.svg';
  static const filter = '$_bp/actions/filter.svg';
  static const moreHoriz = '$_bp/actions/more_horiz.svg';
  static const moreVert = '$_bp/actions/more_vert.svg';
  static const refresh = '$_bp/actions/refresh.svg';
  static const reportFlag = '$_bp/actions/report_flag.svg';
  static const search = '$_bp/actions/search.svg';
  static const send = '$_bp/actions/send.svg';
  static const share = '$_bp/actions/share.svg';

  static const calendar = '$_bp/form/calendar.svg';
  static const email = '$_bp/form/email.svg';
  static const info = '$_bp/form/info.svg';
  static const lockOpen = '$_bp/form/lock_open.svg';
  static const lock = '$_bp/form/lock.svg';
  static const personOutline = '$_bp/form/person_outline.svg';
  static const phone = '$_bp/form/phone.svg';
  static const visibilityOff = '$_bp/form/visibility_off.svg';
  static const visibility = '$_bp/form/visibility.svg';

  static const addPhoto = '$_bp/listing/add_photo.svg';
  static const camera = '$_bp/listing/camera.svg';
  static const category = '$_bp/listing/category.svg';
  static const conditionBadge = '$_bp/listing/condition_badge.svg';
  static const distance = '$_bp/listing/distance.svg';
  static const imageOff = '$_bp/listing/image_off.svg';
  static const locationOn = '$_bp/listing/location_on.svg';
  static const photoLibrary = '$_bp/listing/photo_library.svg';
  static const swap = '$_bp/listing/swap.svg';
  static const tagPrice = '$_bp/listing/tag_price.svg';

  static const locationOff = '$_bp/map/location_off.svg';
  static const mapView = '$_bp/map/map_view.svg';
  static const myLocation = '$_bp/map/my_location.svg';
  static const radius = '$_bp/map/radius.svg';

  static const arrowBack = '$_bp/navigation/arrow_back.svg';
  static const chevronLeft = '$_bp/navigation/chevron_left.svg';
  static const chevronRight = '$_bp/navigation/chevron_right.svg';
  static const close = '$_bp/navigation/close.svg';
  static const expandLess = '$_bp/navigation/expand_less.svg';
  static const expandMore = '$_bp/navigation/expand_more.svg';
  static const menu = '$_bp/navigation/menu.svg';

  static const editProfile = '$_bp/profile/edit_profile.svg';
  static const inventory = '$_bp/profile/inventory.svg';
  static const logout = '$_bp/profile/logout.svg';
  static const notifications = '$_bp/profile/notifications.svg';
  static const person = '$_bp/profile/person.svg';
  static const settings = '$_bp/profile/settings.svg';
  static const storefront = '$_bp/profile/storefront.svg';
  static const verified = '$_bp/profile/verified.svg';

  static const chatBubble = '$_bp/rating/chat_bubble.svg';
  static const starActive = '$_bp/rating/star_active.svg';
  static const starInactive = '$_bp/rating/star_inactive.svg';
  static const thumbDown = '$_bp/rating/thumb_down.svg';
  static const thumbUp = '$_bp/rating/thumb_up.svg';

  static final Map<String, _IconPainter> _painters = {
    add: (c, p, s) {
      c.drawLine(Offset(s / 2, s * 0.15), Offset(s / 2, s * 0.85), p);
      c.drawLine(Offset(s * 0.15, s / 2), Offset(s * 0.85, s / 2), p);
    },
    bookmark: (c, p, s) {
      final path = Path()
        ..moveTo(s * 0.2, s * 0.12)
        ..lineTo(s * 0.8, s * 0.12)
        ..lineTo(s * 0.8, s * 0.88)
        ..lineTo(s / 2, s * 0.72)
        ..lineTo(s * 0.2, s * 0.88)
        ..close();
      c.drawPath(path, p..style = PaintingStyle.stroke);
    },
    bookmarkFilled: (c, p, s) {
      final path = Path()
        ..moveTo(s * 0.2, s * 0.12)
        ..lineTo(s * 0.8, s * 0.12)
        ..lineTo(s * 0.8, s * 0.88)
        ..lineTo(s / 2, s * 0.72)
        ..lineTo(s * 0.2, s * 0.88)
        ..close();
      c.drawPath(path, p..style = PaintingStyle.fill);
    },
    checkCircle: (c, p, s) {
      final r = s * 0.4;
      final cx = s / 2, cy = s / 2;
      c.drawCircle(Offset(cx, cy), r, p..style = PaintingStyle.stroke);
      final cp = p..style = PaintingStyle.stroke;
      c.drawLine(Offset(s * 0.28, s * 0.5), Offset(s * 0.44, s * 0.66), cp);
      c.drawLine(Offset(s * 0.44, s * 0.66), Offset(s * 0.72, s * 0.34), cp);
    },
    check: (c, p, s) {
      c.drawLine(Offset(s * 0.18, s * 0.5), Offset(s * 0.4, s * 0.72), p);
      c.drawLine(Offset(s * 0.4, s * 0.72), Offset(s * 0.82, s * 0.28), p);
    },
    copy: (c, p, s) {
      final r = s * 0.04;
      final rect1 = RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.28, s * 0.28, s * 0.55, s * 0.6),
        Radius.circular(r),
      );
      final rect2 = RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.17, s * 0.12, s * 0.55, s * 0.6),
        Radius.circular(r),
      );
      c.drawRRect(rect2, p..style = PaintingStyle.stroke);
      c.drawRRect(rect1, p..style = PaintingStyle.stroke);
    },
    delete: (c, p, s) {
      c.drawLine(Offset(s * 0.15, s * 0.22), Offset(s * 0.85, s * 0.22), p);
      final path = Path()
        ..moveTo(s * 0.25, s * 0.22)
        ..lineTo(s * 0.3, s * 0.85)
        ..lineTo(s * 0.7, s * 0.85)
        ..lineTo(s * 0.75, s * 0.22);
      c.drawPath(path, p..style = PaintingStyle.stroke);
      c.drawLine(Offset(s * 0.38, s * 0.12), Offset(s * 0.62, s * 0.12), p);
    },
    edit: (c, p, s) {
      final path = Path()
        ..moveTo(s * 0.78, s * 0.22)
        ..lineTo(s * 0.22, s * 0.78)
        ..lineTo(s * 0.12, s * 0.88)
        ..lineTo(s * 0.22, s * 0.78);
      c.drawPath(path, p..style = PaintingStyle.stroke);
      c.drawLine(Offset(s * 0.22, s * 0.78), Offset(s * 0.12, s * 0.88), p);
      c.drawLine(Offset(s * 0.12, s * 0.88), Offset(s * 0.32, s * 0.82), p);
      c.drawLine(Offset(s * 0.68, s * 0.12), Offset(s * 0.88, s * 0.32), p);
      c.drawLine(Offset(s * 0.78, s * 0.22), Offset(s * 0.18, s * 0.82), p);
    },
    favoriteActive: (c, p, s) {
      final path = Path();
      final cx = s / 2, cy = s / 2;
      final w = s * 0.38, h = s * 0.35;
      path.moveTo(cx, cy + h);
      path.cubicTo(cx - w * 1.2, cy + h * 0.2, cx - w * 1.2, cy - h * 0.8, cx,
          cy - h * 0.3);
      path.cubicTo(
          cx + w * 1.2, cy - h * 0.8, cx + w * 1.2, cy + h * 0.2, cx, cy + h);
      c.drawPath(path, p..style = PaintingStyle.fill);
    },
    favoriteInactive: (c, p, s) {
      final path = Path();
      final cx = s / 2, cy = s / 2;
      final w = s * 0.38, h = s * 0.35;
      path.moveTo(cx, cy + h);
      path.cubicTo(cx - w * 1.2, cy + h * 0.2, cx - w * 1.2, cy - h * 0.8, cx,
          cy - h * 0.3);
      path.cubicTo(
          cx + w * 1.2, cy - h * 0.8, cx + w * 1.2, cy + h * 0.2, cx, cy + h);
      c.drawPath(path, p..style = PaintingStyle.stroke);
    },
    filter: (c, p, s) {
      final path = Path()
        ..moveTo(s * 0.12, s * 0.2)
        ..lineTo(s * 0.88, s * 0.2)
        ..lineTo(s * 0.6, s * 0.55)
        ..lineTo(s * 0.6, s * 0.8)
        ..lineTo(s * 0.4, s * 0.85)
        ..lineTo(s * 0.4, s * 0.55)
        ..close();
      c.drawPath(path, p..style = PaintingStyle.stroke);
    },
    moreHoriz: (c, p, s) {
      final r = s * 0.06;
      c.drawCircle(Offset(s * 0.2, s / 2), r, p..style = PaintingStyle.fill);
      c.drawCircle(Offset(s / 2, s / 2), r, p..style = PaintingStyle.fill);
      c.drawCircle(Offset(s * 0.8, s / 2), r, p..style = PaintingStyle.fill);
    },
    moreVert: (c, p, s) {
      final r = s * 0.06;
      c.drawCircle(Offset(s / 2, s * 0.2), r, p..style = PaintingStyle.fill);
      c.drawCircle(Offset(s / 2, s / 2), r, p..style = PaintingStyle.fill);
      c.drawCircle(Offset(s / 2, s * 0.8), r, p..style = PaintingStyle.fill);
    },
    refresh: (c, p, s) {
      final rect =
          Rect.fromCircle(center: Offset(s / 2, s / 2), radius: s * 0.35);
      c.drawArc(rect, -math.pi * 0.3, math.pi * 1.4, false,
          p..style = PaintingStyle.stroke);
      final path = Path()
        ..moveTo(s * 0.65, s * 0.1)
        ..lineTo(s * 0.82, s * 0.2)
        ..lineTo(s * 0.68, s * 0.32);
      c.drawPath(path, p..style = PaintingStyle.stroke);
    },
    reportFlag: (c, p, s) {
      c.drawLine(Offset(s * 0.25, s * 0.12), Offset(s * 0.25, s * 0.88), p);
      final path = Path()
        ..moveTo(s * 0.25, s * 0.12)
        ..lineTo(s * 0.8, s * 0.12)
        ..lineTo(s * 0.65, s * 0.35)
        ..lineTo(s * 0.8, s * 0.58)
        ..lineTo(s * 0.25, s * 0.58);
      c.drawPath(path, p..style = PaintingStyle.stroke);
    },
    search: (c, p, s) {
      c.drawCircle(Offset(s * 0.42, s * 0.42), s * 0.28,
          p..style = PaintingStyle.stroke);
      c.drawLine(Offset(s * 0.62, s * 0.62), Offset(s * 0.85, s * 0.85), p);
    },
    send: (c, p, s) {
      final path = Path()
        ..moveTo(s * 0.12, s * 0.15)
        ..lineTo(s * 0.88, s / 2)
        ..lineTo(s * 0.12, s * 0.85)
        ..lineTo(s * 0.3, s / 2)
        ..close();
      c.drawPath(path, p..style = PaintingStyle.stroke);
    },
    share: (c, p, s) {
      final r = s * 0.08;
      c.drawCircle(
          Offset(s * 0.72, s * 0.18), r, p..style = PaintingStyle.stroke);
      c.drawCircle(
          Offset(s * 0.72, s * 0.82), r, p..style = PaintingStyle.stroke);
      c.drawCircle(Offset(s * 0.2, s / 2), r, p..style = PaintingStyle.stroke);
      c.drawLine(Offset(s * 0.65, s * 0.24), Offset(s * 0.27, s * 0.45), p);
      c.drawLine(Offset(s * 0.65, s * 0.76), Offset(s * 0.27, s * 0.55), p);
    },
    calendar: (c, p, s) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.12, s * 0.2, s * 0.76, s * 0.68),
        Radius.circular(s * 0.06),
      );
      c.drawRRect(rect, p..style = PaintingStyle.stroke);
      c.drawLine(Offset(s * 0.12, s * 0.38), Offset(s * 0.88, s * 0.38), p);
      c.drawLine(Offset(s * 0.32, s * 0.1), Offset(s * 0.32, s * 0.28), p);
      c.drawLine(Offset(s * 0.68, s * 0.1), Offset(s * 0.68, s * 0.28), p);
    },
    email: (c, p, s) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.1, s * 0.22, s * 0.8, s * 0.56),
        Radius.circular(s * 0.04),
      );
      c.drawRRect(rect, p..style = PaintingStyle.stroke);
      c.drawLine(Offset(s * 0.1, s * 0.25), Offset(s / 2, s * 0.52), p);
      c.drawLine(Offset(s * 0.9, s * 0.25), Offset(s / 2, s * 0.52), p);
    },
    info: (c, p, s) {
      c.drawCircle(
          Offset(s / 2, s / 2), s * 0.4, p..style = PaintingStyle.stroke);
      c.drawLine(Offset(s / 2, s * 0.38), Offset(s / 2, s * 0.68), p);
      c.drawCircle(
          Offset(s / 2, s * 0.28), s * 0.03, p..style = PaintingStyle.fill);
    },
    lockOpen: (c, p, s) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.18, s * 0.42, s * 0.64, s * 0.44),
        Radius.circular(s * 0.04),
      );
      c.drawRRect(rect, p..style = PaintingStyle.stroke);
      c.drawCircle(
          Offset(s / 2, s * 0.64), s * 0.04, p..style = PaintingStyle.fill);
      final path = Path()
        ..moveTo(s * 0.55, s * 0.42)
        ..lineTo(s * 0.55, s * 0.28)
        ..arcToPoint(Offset(s * 0.35, s * 0.18),
            radius: Radius.circular(s * 0.15), clockwise: false);
      c.drawPath(path, p..style = PaintingStyle.stroke);
    },
    lock: (c, p, s) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.18, s * 0.42, s * 0.64, s * 0.44),
        Radius.circular(s * 0.04),
      );
      c.drawRRect(rect, p..style = PaintingStyle.stroke);
      c.drawCircle(
          Offset(s / 2, s * 0.64), s * 0.04, p..style = PaintingStyle.fill);
      final path = Path()
        ..moveTo(s * 0.35, s * 0.42)
        ..lineTo(s * 0.35, s * 0.28)
        ..arcToPoint(Offset(s * 0.65, s * 0.28),
            radius: Radius.circular(s * 0.15))
        ..lineTo(s * 0.65, s * 0.42);
      c.drawPath(path, p..style = PaintingStyle.stroke);
    },
    personOutline: (c, p, s) {
      c.drawCircle(
          Offset(s / 2, s * 0.32), s * 0.18, p..style = PaintingStyle.stroke);
      final path = Path()
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.15, s * 0.6, s * 0.7, s * 0.32),
          Radius.circular(s * 0.16),
        ));
      c.drawPath(path, p..style = PaintingStyle.stroke);
    },
    phone: (c, p, s) {
      final path = Path()
        ..moveTo(s * 0.2, s * 0.12)
        ..lineTo(s * 0.42, s * 0.12)
        ..lineTo(s * 0.48, s * 0.32)
        ..lineTo(s * 0.35, s * 0.42)
        ..cubicTo(s * 0.48, s * 0.58, s * 0.58, s * 0.68, s * 0.72, s * 0.7)
        ..lineTo(s * 0.78, s * 0.55)
        ..lineTo(s * 0.88, s * 0.6)
        ..lineTo(s * 0.88, s * 0.82)
        ..close();
      c.drawPath(path, p..style = PaintingStyle.stroke);
    },
    visibilityOff: (c, p, s) {
      c.drawLine(Offset(s * 0.12, s * 0.12), Offset(s * 0.88, s * 0.88), p);
      final path = Path();
      path.moveTo(s * 0.15, s * 0.5);
      path.quadraticBezierTo(s / 2, s * 0.2, s * 0.85, s * 0.5);
      path.quadraticBezierTo(s / 2, s * 0.8, s * 0.15, s * 0.5);
      c.drawPath(path, p..style = PaintingStyle.stroke);
    },
    visibility: (c, p, s) {
      final path = Path();
      path.moveTo(s * 0.1, s * 0.5);
      path.quadraticBezierTo(s / 2, s * 0.15, s * 0.9, s * 0.5);
      path.quadraticBezierTo(s / 2, s * 0.85, s * 0.1, s * 0.5);
      c.drawPath(path, p..style = PaintingStyle.stroke);
      c.drawCircle(
          Offset(s / 2, s * 0.5), s * 0.12, p..style = PaintingStyle.stroke);
    },
    addPhoto: (c, p, s) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.1, s * 0.15, s * 0.8, s * 0.7),
        Radius.circular(s * 0.06),
      );
      c.drawRRect(rect, p..style = PaintingStyle.stroke);
      c.drawLine(Offset(s / 2, s * 0.32), Offset(s / 2, s * 0.68), p);
      c.drawLine(Offset(s * 0.32, s * 0.5), Offset(s * 0.68, s * 0.5), p);
      c.drawCircle(
          Offset(s * 0.65, s * 0.35), s * 0.06, p..style = PaintingStyle.fill);
    },
    camera: (c, p, s) {
      final path = Path()
        ..moveTo(s * 0.25, s * 0.28)
        ..lineTo(s * 0.35, s * 0.15)
        ..lineTo(s * 0.65, s * 0.15)
        ..lineTo(s * 0.75, s * 0.28);
      c.drawPath(path, p..style = PaintingStyle.stroke);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.1, s * 0.28, s * 0.8, s * 0.57),
        Radius.circular(s * 0.06),
      );
      c.drawRRect(rect, p..style = PaintingStyle.stroke);
      c.drawCircle(
          Offset(s / 2, s * 0.56), s * 0.16, p..style = PaintingStyle.stroke);
    },
    category: (c, p, s) {
      final r = s * 0.04;
      c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(s * 0.12, s * 0.12, s * 0.32, s * 0.32),
            Radius.circular(r)),
        p..style = PaintingStyle.stroke,
      );
      c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(s * 0.56, s * 0.12, s * 0.32, s * 0.32),
            Radius.circular(r)),
        p..style = PaintingStyle.stroke,
      );
      c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(s * 0.12, s * 0.56, s * 0.32, s * 0.32),
            Radius.circular(r)),
        p..style = PaintingStyle.stroke,
      );
      c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(s * 0.56, s * 0.56, s * 0.32, s * 0.32),
            Radius.circular(r)),
        p..style = PaintingStyle.stroke,
      );
    },
    conditionBadge: (c, p, s) {
      final path = Path()
        ..moveTo(s * 0.5, s * 0.08)
        ..lineTo(s * 0.62, s * 0.28)
        ..lineTo(s * 0.85, s * 0.32)
        ..lineTo(s * 0.7, s * 0.5)
        ..lineTo(s * 0.74, s * 0.73)
        ..lineTo(s * 0.5, s * 0.64)
        ..lineTo(s * 0.26, s * 0.73)
        ..lineTo(s * 0.3, s * 0.5)
        ..lineTo(s * 0.15, s * 0.32)
        ..lineTo(s * 0.38, s * 0.28)
        ..close();
      c.drawPath(path, p..style = PaintingStyle.stroke);
    },
    distance: (c, p, s) {
      c.drawCircle(
          Offset(s * 0.5, s * 0.5), s * 0.35, p..style = PaintingStyle.stroke);
      c.drawCircle(
          Offset(s * 0.5, s * 0.5), s * 0.08, p..style = PaintingStyle.fill);
      c.drawLine(Offset(s * 0.5, s * 0.08), Offset(s * 0.5, s * 0.15), p);
      c.drawLine(Offset(s * 0.5, s * 0.85), Offset(s * 0.5, s * 0.92), p);
      c.drawLine(Offset(s * 0.08, s * 0.5), Offset(s * 0.15, s * 0.5), p);
      c.drawLine(Offset(s * 0.85, s * 0.5), Offset(s * 0.92, s * 0.5), p);
    },
    imageOff: (c, p, s) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.1, s * 0.15, s * 0.8, s * 0.7),
        Radius.circular(s * 0.06),
      );
      c.drawRRect(rect, p..style = PaintingStyle.stroke);
      c.drawCircle(Offset(s * 0.35, s * 0.38), s * 0.08,
          p..style = PaintingStyle.stroke);
      final path = Path()
        ..moveTo(s * 0.1, s * 0.7)
        ..lineTo(s * 0.38, s * 0.48)
        ..lineTo(s * 0.58, s * 0.65)
        ..lineTo(s * 0.7, s * 0.55)
        ..lineTo(s * 0.9, s * 0.7);
      c.drawPath(path, p..style = PaintingStyle.stroke);
    },
    locationOn: (c, p, s) {
      final path = Path()
        ..moveTo(s / 2, s * 0.88)
        ..cubicTo(s * 0.3, s * 0.65, s * 0.1, s * 0.5, s * 0.1, s * 0.35)
        ..arcToPoint(Offset(s * 0.9, s * 0.35),
            radius: Radius.circular(s * 0.4))
        ..cubicTo(s * 0.9, s * 0.5, s * 0.7, s * 0.65, s / 2, s * 0.88);
      c.drawPath(path, p..style = PaintingStyle.stroke);
      c.drawCircle(
          Offset(s / 2, s * 0.35), s * 0.12, p..style = PaintingStyle.stroke);
    },
    photoLibrary: (c, p, s) {
      final r1 = RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.18, s * 0.08, s * 0.62, s * 0.52),
        Radius.circular(s * 0.04),
      );
      final r2 = RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.08, s * 0.25, s * 0.62, s * 0.55),
        Radius.circular(s * 0.04),
      );
      c.drawRRect(r1, p..style = PaintingStyle.stroke);
      c.drawRRect(r2, p..style = PaintingStyle.stroke);
    },
    swap: (c, p, s) {
      final path1 = Path()
        ..moveTo(s * 0.15, s * 0.35)
        ..lineTo(s * 0.85, s * 0.35);
      final path2 = Path()
        ..moveTo(s * 0.85, s * 0.65)
        ..lineTo(s * 0.15, s * 0.65);
      c.drawPath(path1, p..style = PaintingStyle.stroke);
      c.drawPath(path2, p..style = PaintingStyle.stroke);
      c.drawLine(Offset(s * 0.72, s * 0.22), Offset(s * 0.85, s * 0.35), p);
      c.drawLine(Offset(s * 0.85, s * 0.35), Offset(s * 0.72, s * 0.48), p);
      c.drawLine(Offset(s * 0.28, s * 0.52), Offset(s * 0.15, s * 0.65), p);
      c.drawLine(Offset(s * 0.15, s * 0.65), Offset(s * 0.28, s * 0.78), p);
    },
    tagPrice: (c, p, s) {
      final path = Path()
        ..moveTo(s * 0.12, s * 0.12)
        ..lineTo(s * 0.55, s * 0.12)
        ..lineTo(s * 0.88, s * 0.5)
        ..lineTo(s * 0.5, s * 0.88)
        ..lineTo(s * 0.12, s * 0.5)
        ..close();
      c.drawPath(path, p..style = PaintingStyle.stroke);
      c.drawCircle(
          Offset(s * 0.38, s * 0.32), s * 0.05, p..style = PaintingStyle.fill);
    },
    locationOff: (c, p, s) {
      c.drawLine(Offset(s * 0.12, s * 0.12), Offset(s * 0.88, s * 0.88), p);
      final path = Path()
        ..moveTo(s / 2, s * 0.85)
        ..cubicTo(s * 0.32, s * 0.65, s * 0.15, s * 0.5, s * 0.15, s * 0.35)
        ..arcToPoint(Offset(s * 0.85, s * 0.35),
            radius: Radius.circular(s * 0.35));
      c.drawPath(path, p..style = PaintingStyle.stroke);
    },
    mapView: (c, p, s) {
      final path = Path()
        ..moveTo(s * 0.1, s * 0.2)
        ..lineTo(s * 0.38, s * 0.12)
        ..lineTo(s * 0.62, s * 0.28)
        ..lineTo(s * 0.9, s * 0.15)
        ..lineTo(s * 0.9, s * 0.8)
        ..lineTo(s * 0.62, s * 0.88)
        ..lineTo(s * 0.38, s * 0.72)
        ..lineTo(s * 0.1, s * 0.85)
        ..close();
      c.drawPath(path, p..style = PaintingStyle.stroke);
      c.drawLine(Offset(s * 0.38, s * 0.12), Offset(s * 0.38, s * 0.72), p);
      c.drawLine(Offset(s * 0.62, s * 0.28), Offset(s * 0.62, s * 0.88), p);
    },
    myLocation: (c, p, s) {
      c.drawCircle(
          Offset(s / 2, s / 2), s * 0.2, p..style = PaintingStyle.stroke);
      c.drawCircle(
          Offset(s / 2, s / 2), s * 0.06, p..style = PaintingStyle.fill);
      c.drawLine(Offset(s / 2, s * 0.05), Offset(s / 2, s * 0.18), p);
      c.drawLine(Offset(s / 2, s * 0.82), Offset(s / 2, s * 0.95), p);
      c.drawLine(Offset(s * 0.05, s / 2), Offset(s * 0.18, s / 2), p);
      c.drawLine(Offset(s * 0.82, s / 2), Offset(s * 0.95, s / 2), p);
    },
    radius: (c, p, s) {
      c.drawCircle(
          Offset(s / 2, s / 2), s * 0.35, p..style = PaintingStyle.stroke);
      c.drawCircle(
          Offset(s / 2, s / 2), s * 0.06, p..style = PaintingStyle.fill);
    },
    arrowBack: (c, p, s) {
      final path = Path()
        ..moveTo(s * 0.6, s * 0.18)
        ..lineTo(s * 0.28, s / 2)
        ..lineTo(s * 0.6, s * 0.82);
      c.drawPath(path, p..style = PaintingStyle.stroke);
      c.drawLine(Offset(s * 0.28, s / 2), Offset(s * 0.85, s / 2), p);
    },
    chevronLeft: (c, p, s) {
      final path = Path()
        ..moveTo(s * 0.62, s * 0.18)
        ..lineTo(s * 0.3, s / 2)
        ..lineTo(s * 0.62, s * 0.82);
      c.drawPath(path, p..style = PaintingStyle.stroke);
    },
    chevronRight: (c, p, s) {
      final path = Path()
        ..moveTo(s * 0.38, s * 0.18)
        ..lineTo(s * 0.7, s / 2)
        ..lineTo(s * 0.38, s * 0.82);
      c.drawPath(path, p..style = PaintingStyle.stroke);
    },
    close: (c, p, s) {
      c.drawLine(Offset(s * 0.2, s * 0.2), Offset(s * 0.8, s * 0.8), p);
      c.drawLine(Offset(s * 0.8, s * 0.2), Offset(s * 0.2, s * 0.8), p);
    },
    expandLess: (c, p, s) {
      final path = Path()
        ..moveTo(s * 0.18, s * 0.62)
        ..lineTo(s / 2, s * 0.3)
        ..lineTo(s * 0.82, s * 0.62);
      c.drawPath(path, p..style = PaintingStyle.stroke);
    },
    expandMore: (c, p, s) {
      final path = Path()
        ..moveTo(s * 0.18, s * 0.38)
        ..lineTo(s / 2, s * 0.7)
        ..lineTo(s * 0.82, s * 0.38);
      c.drawPath(path, p..style = PaintingStyle.stroke);
    },
    menu: (c, p, s) {
      c.drawLine(Offset(s * 0.15, s * 0.25), Offset(s * 0.85, s * 0.25), p);
      c.drawLine(Offset(s * 0.15, s / 2), Offset(s * 0.85, s / 2), p);
      c.drawLine(Offset(s * 0.15, s * 0.75), Offset(s * 0.85, s * 0.75), p);
    },
    editProfile: (c, p, s) {
      c.drawCircle(
          Offset(s / 2, s * 0.32), s * 0.18, p..style = PaintingStyle.stroke);
      final body = Path()
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.15, s * 0.6, s * 0.7, s * 0.32),
          Radius.circular(s * 0.16),
        ));
      c.drawPath(body, p..style = PaintingStyle.stroke);
      c.drawLine(Offset(s * 0.62, s * 0.72), Offset(s * 0.82, s * 0.72), p);
    },
    inventory: (c, p, s) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.1, s * 0.2, s * 0.8, s * 0.65),
        Radius.circular(s * 0.06),
      );
      c.drawRRect(rect, p..style = PaintingStyle.stroke);
      c.drawLine(Offset(s * 0.1, s * 0.4), Offset(s * 0.9, s * 0.4), p);
      c.drawLine(Offset(s / 2, s * 0.2), Offset(s / 2, s * 0.85), p);
    },
    logout: (c, p, s) {
      final path = Path()
        ..moveTo(s * 0.5, s * 0.85)
        ..lineTo(s * 0.2, s * 0.85)
        ..lineTo(s * 0.2, s * 0.15)
        ..lineTo(s * 0.5, s * 0.15);
      c.drawPath(path, p..style = PaintingStyle.stroke);
      c.drawLine(Offset(s * 0.42, s / 2), Offset(s * 0.85, s / 2), p);
      final arr = Path()
        ..moveTo(s * 0.72, s * 0.35)
        ..lineTo(s * 0.85, s / 2)
        ..lineTo(s * 0.72, s * 0.65);
      c.drawPath(arr, p..style = PaintingStyle.stroke);
    },
    notifications: (c, p, s) {
      final path = Path()
        ..moveTo(s * 0.18, s * 0.55)
        ..cubicTo(s * 0.18, s * 0.28, s * 0.35, s * 0.15, s / 2, s * 0.15)
        ..cubicTo(s * 0.65, s * 0.15, s * 0.82, s * 0.28, s * 0.82, s * 0.55)
        ..lineTo(s * 0.82, s * 0.68)
        ..lineTo(s * 0.18, s * 0.68)
        ..close();
      c.drawPath(path, p..style = PaintingStyle.stroke);
      c.drawLine(Offset(s * 0.4, s * 0.75), Offset(s * 0.6, s * 0.75), p);
      c.drawLine(Offset(s * 0.35, s * 0.82), Offset(s * 0.65, s * 0.82), p);
    },
    person: (c, p, s) {
      c.drawCircle(
          Offset(s / 2, s * 0.32), s * 0.18, p..style = PaintingStyle.stroke);
      final body = Path()
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.15, s * 0.6, s * 0.7, s * 0.32),
          Radius.circular(s * 0.16),
        ));
      c.drawPath(body, p..style = PaintingStyle.stroke);
    },
    settings: (c, p, s) {
      final cx = s / 2, cy = s / 2, r = s * 0.28;
      c.drawCircle(Offset(cx, cy), s * 0.12, p..style = PaintingStyle.stroke);
      for (var i = 0; i < 6; i++) {
        final angle = i * math.pi / 3;
        final x1 = cx + r * 0.6 * math.cos(angle);
        final y1 = cy + r * 0.6 * math.sin(angle);
        final x2 = cx + r * math.cos(angle);
        final y2 = cy + r * math.sin(angle);
        c.drawLine(Offset(x1, y1), Offset(x2, y2), p);
      }
      c.drawCircle(Offset(cx, cy), r, p..style = PaintingStyle.stroke);
    },
    storefront: (c, p, s) {
      final path = Path()
        ..moveTo(s * 0.1, s * 0.35)
        ..lineTo(s * 0.2, s * 0.15)
        ..lineTo(s * 0.8, s * 0.15)
        ..lineTo(s * 0.9, s * 0.35);
      c.drawPath(path, p..style = PaintingStyle.stroke);
      c.drawLine(Offset(s * 0.1, s * 0.35), Offset(s * 0.9, s * 0.35), p);
      c.drawLine(Offset(s * 0.2, s * 0.35), Offset(s * 0.2, s * 0.85), p);
      c.drawLine(Offset(s * 0.8, s * 0.35), Offset(s * 0.8, s * 0.85), p);
      c.drawLine(Offset(s * 0.2, s * 0.85), Offset(s * 0.8, s * 0.85), p);
      c.drawLine(Offset(s / 2, s * 0.5), Offset(s / 2, s * 0.85), p);
    },
    verified: (c, p, s) {
      final r = s * 0.35;
      final cx = s / 2, cy = s / 2;
      final path = Path();
      for (var i = 0; i < 12; i++) {
        final angle = i * math.pi / 6 - math.pi / 2;
        final rad = i.isEven ? r : r * 0.78;
        final x = cx + rad * math.cos(angle);
        final y = cy + rad * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      c.drawPath(path, p..style = PaintingStyle.stroke);
      c.drawLine(Offset(s * 0.32, s * 0.5), Offset(s * 0.44, s * 0.62), p);
      c.drawLine(Offset(s * 0.44, s * 0.62), Offset(s * 0.68, s * 0.38), p);
    },
    chatBubble: (c, p, s) {
      final path = Path()
        ..moveTo(s * 0.12, s * 0.18)
        ..lineTo(s * 0.88, s * 0.18)
        ..arcToPoint(Offset(s * 0.88, s * 0.62),
            radius: Radius.circular(s * 0.04))
        ..lineTo(s * 0.55, s * 0.62)
        ..lineTo(s * 0.35, s * 0.82)
        ..lineTo(s * 0.38, s * 0.62)
        ..lineTo(s * 0.12, s * 0.62)
        ..arcToPoint(Offset(s * 0.12, s * 0.18),
            radius: Radius.circular(s * 0.04));
      c.drawPath(path, p..style = PaintingStyle.stroke);
    },
    starActive: (c, p, s) {
      final path = Path();
      final cx = s / 2, cy = s / 2;
      final outer = s * 0.4, inner = s * 0.18;
      for (var i = 0; i < 5; i++) {
        final outerAngle = i * 2 * math.pi / 5 - math.pi / 2;
        final innerAngle = outerAngle + math.pi / 5;
        final ox = cx + outer * math.cos(outerAngle);
        final oy = cy + outer * math.sin(outerAngle);
        final ix = cx + inner * math.cos(innerAngle);
        final iy = cy + inner * math.sin(innerAngle);
        if (i == 0) {
          path.moveTo(ox, oy);
        } else {
          path.lineTo(ox, oy);
        }
        path.lineTo(ix, iy);
      }
      path.close();
      c.drawPath(path, p..style = PaintingStyle.fill);
    },
    starInactive: (c, p, s) {
      final path = Path();
      final cx = s / 2, cy = s / 2;
      final outer = s * 0.4, inner = s * 0.18;
      for (var i = 0; i < 5; i++) {
        final outerAngle = i * 2 * math.pi / 5 - math.pi / 2;
        final innerAngle = outerAngle + math.pi / 5;
        final ox = cx + outer * math.cos(outerAngle);
        final oy = cy + outer * math.sin(outerAngle);
        final ix = cx + inner * math.cos(innerAngle);
        final iy = cy + inner * math.sin(innerAngle);
        if (i == 0) {
          path.moveTo(ox, oy);
        } else {
          path.lineTo(ox, oy);
        }
        path.lineTo(ix, iy);
      }
      path.close();
      c.drawPath(path, p..style = PaintingStyle.stroke);
    },
    thumbDown: (c, p, s) {
      final path = Path()
        ..moveTo(s * 0.15, s * 0.15)
        ..lineTo(s * 0.15, s * 0.55)
        ..lineTo(s * 0.32, s * 0.55)
        ..lineTo(s * 0.55, s * 0.85)
        ..lineTo(s * 0.62, s * 0.78)
        ..lineTo(s * 0.55, s * 0.55)
        ..lineTo(s * 0.85, s * 0.48)
        ..lineTo(s * 0.78, s * 0.15);
      c.drawPath(path, p..style = PaintingStyle.stroke);
    },
    thumbUp: (c, p, s) {
      final path = Path()
        ..moveTo(s * 0.15, s * 0.85)
        ..lineTo(s * 0.15, s * 0.45)
        ..lineTo(s * 0.32, s * 0.45)
        ..lineTo(s * 0.55, s * 0.15)
        ..lineTo(s * 0.62, s * 0.22)
        ..lineTo(s * 0.55, s * 0.45)
        ..lineTo(s * 0.85, s * 0.52)
        ..lineTo(s * 0.78, s * 0.85);
      c.drawPath(path, p..style = PaintingStyle.stroke);
    },
  };

  @override
  Widget build(BuildContext context) {
    final painter = _painters[assetName];
    if (painter == null) {
      return SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _FallbackPainter(color, size)),
      );
    }
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _TakashPainter(painter, color, size)),
    );
  }
}

class _TakashPainter extends CustomPainter {
  final _IconPainter _painter;
  final Color? _color;
  final double _size;

  _TakashPainter(this._painter, this._color, this._size);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _color ?? const Color(0xFF000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _size * 0.075
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    _painter(canvas, paint, size.width);
  }

  @override
  bool shouldRepaint(covariant _TakashPainter old) =>
      old._color != _color || old._size != _size;
}

class _FallbackPainter extends CustomPainter {
  final Color? _color;
  final double _size;

  _FallbackPainter(this._color, this._size);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (_color ?? const Color(0xFF000000)).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _size * 0.075
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width * 0.2, size.height * 0.2),
        Offset(size.width * 0.8, size.height * 0.8), paint);
    canvas.drawLine(Offset(size.width * 0.8, size.height * 0.2),
        Offset(size.width * 0.2, size.height * 0.8), paint);
  }

  @override
  bool shouldRepaint(covariant _FallbackPainter old) =>
      old._color != _color || old._size != _size;
}

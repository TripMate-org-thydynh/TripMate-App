import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate/core/distribution_channel.dart';

void main() {
  group('DistributionChannel.appstore', () {
    test('wire value is appstore', () {
      expect(DistributionChannel.appstore.wire, 'appstore');
      expect(DistributionChannel.appstore.name, 'appstore');
    });

    test('logic chọn kênh trả về appstore khi có biến môi trường DISTRIBUTION_CHANNEL tương ứng', () {
      expect(
        detectDistributionChannel(overrideEnv: 'appstore'),
        DistributionChannel.appstore,
      );
      expect(
        detectDistributionChannel(overrideEnv: 'ios'),
        DistributionChannel.appstore,
      );
      expect(
        detectDistributionChannel(overrideEnv: 'apple'),
        DistributionChannel.appstore,
      );
    });

    test('logic chọn kênh trên iOS mặc định là appstore', () {
      expect(
        detectDistributionChannel(
          platform: TargetPlatform.iOS,
          isWeb: false,
          overrideEnv: '',
        ),
        DistributionChannel.appstore,
      );
    });

    test('logic chọn kênh trên các nền tảng khác', () {
      expect(
        detectDistributionChannel(
          platform: TargetPlatform.android,
          isWeb: false,
          overrideEnv: '',
        ),
        DistributionChannel.play,
      );
      expect(
        detectDistributionChannel(
          platform: TargetPlatform.windows,
          isWeb: false,
          overrideEnv: '',
        ),
        DistributionChannel.direct,
      );
      expect(
        detectDistributionChannel(isWeb: true, overrideEnv: ''),
        DistributionChannel.web,
      );
    });
  });
}

/// 卫星类型
enum Constellation {
  GPS(1, '美国GPS'), // 美
  SBAS(2, '星基增强系统'), // 每个国家有自己不同的系统
  GLONASS(3, '格洛纳斯'), // 俄
  QZSS(4, '准天顶'), // 日
  BEIDOU(5, '北斗'), // 中
  GALILEO(6, '伽利略'), // 欧盟
  IRNSS(7, '印度区域'), // 印度
  UNKNOWN(0, 'UNKNOWN'); // 未知

  final int constellationType;
  final String name;

  const Constellation(this.constellationType, this.name);

  static Constellation getConstellationType(int? constellationType) {
    if (constellationType == GPS.constellationType) {
      return GPS;
    }

    if (constellationType == SBAS.constellationType) {
      return SBAS;
    }

    if (constellationType == GLONASS.constellationType) {
      return GLONASS;
    }

    if (constellationType == QZSS.constellationType) {
      return QZSS;
    }

    if (constellationType == BEIDOU.constellationType) {
      return BEIDOU;
    }

    if (constellationType == GALILEO.constellationType) {
      return GALILEO;
    }

    if (constellationType == IRNSS.constellationType) {
      return IRNSS;
    }

    return UNKNOWN;
  }
}

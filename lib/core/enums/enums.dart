enum ThemeMode {
  light,
  dark,
}

enum TPI {
  comment(2),
  upVote(2),
  downVote(-2);

  final int interest;
  const TPI(this.interest);
}

enum MessageEnum {
  text('text'),
  image('image'),
  audio('audio'),
  video('video');

  const MessageEnum(this.type);
  final String type;
}

extension ConvertMessage on String {
  MessageEnum toEnum() {
    switch (this) {
      case 'audio':
        return MessageEnum.audio;
      case 'image':
        return MessageEnum.image;
      case 'text':
        return MessageEnum.text;
      case 'video':
        return MessageEnum.video;
      default:
        return MessageEnum.text;
    }
  }
}

enum PostEnum {
  type1('#chuyenthuongngay'),
  type2('#hoidap'),
  type3('#chiasekinhnghiem');

  const PostEnum(this.type);
  final String type;
}

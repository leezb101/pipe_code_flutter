import 'package:json_annotation/json_annotation.dart';

enum MaterialTypeEnum {
  @JsonValue(0)
  qiuMoZhuTie('球墨铸铁'),
  
  @JsonValue(1)
  gangGuan('钢管'),
  
  @JsonValue(2)
  boBuXiuGangGang('薄壁不锈钢管'),
  
  @JsonValue(3)
  gangSuFuHeGuan('钢塑复合管'),
  
  @JsonValue(4)
  guanDaoGuanJianQiu('管道管件(球墨管件)'),
  
  @JsonValue(5)
  guanDaoGuanJianGang('管道管件(钢管管件)'),
  
  @JsonValue(6)
  faMen('阀门'),
  
  @JsonValue(7)
  shenSuoJie('伸缩节'),
  
  @JsonValue(8)
  xiaoHuoShuan('消火栓'),
  
  @JsonValue(9)
  haFuJie('哈夫节（适用于金属或非金属管道连接）'),
  
  @JsonValue(10)
  chengKouZhaFa('承口闸阀（适用于金属或非金属管道连接）'),
  
  @JsonValue(11)
  wanNengLianJieQi('万能连接器（适用于金属或非金属管道连接）');

  const MaterialTypeEnum(this.description);
  
  final String description;
}
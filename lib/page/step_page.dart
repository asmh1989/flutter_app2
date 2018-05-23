import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/model/steps.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/components/picture_list.dart';

final List<_StatusSelect> _statusList = <_StatusSelect>[
  _StatusSelect(0, '正常'),
  _StatusSelect(1, '异常'),
  _StatusSelect(2, '待用'),
  _StatusSelect(3, '挂牌')
];

class _StatusSelect{
  int key;
  String value;


  _StatusSelect(this.key, this.value);
}

class StepPage extends StatefulWidget {

  final int index;
  OrderStep data;

  StepPage({@required this.index, @required this.data});


  @override
  _StepPageState createState() => new _StepPageState();
}

class _StepPageState extends State<StepPage> {

  TextEditingController _controller;

  Widget _getBody(){

    OrderStep data = widget.data;
    if(MediaQuery.of(context).viewInsets.bottom == 0){
      Func.closeKeyboard(context);
    }

    print('ordersteo : ${data.toJson().toString()}');
    if(data == null) {
      return Center(child: Text('步骤数据丢失...'),);
    }

    return new Container(
      color: Style.backgroundColor,
      height: MediaQuery.of(context).size.height,
      child: new Stack(
        children: <Widget>[
          new Positioned(left: 0.0, top: 0.0, bottom: max(80.0, MediaQuery.of(context).viewInsets.bottom), right: 0.0, child: SingleChildScrollView(
            child: Container(
              color: Colors.white,
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(padding: Style.pagePadding, child:Text('基本信息')),
                  Divider(height: 1.0,),
                  Padding(padding: Style.pagePadding2, child:Text('任务: ${data.setpno ?? ''}')),
                  Padding(padding: Style.pagePadding2, child:Text('描述: ${data.description ??''}')),
                  Padding(padding: Style.pagePadding2, child:Text('资产: ${data.location ?? ''}')),
                  Padding(padding: Style.pagePadding2, child:Text('描述: ${data.locationDescription ?? ''}')),
                  Container(height: Style.separateHeight, color: Style.backgroundColor,),

                  Padding(padding: Style.pagePadding, child:Text('操作信息')),
                  Divider(height: 1.0,),


                  Padding(padding: new EdgeInsets.symmetric(horizontal: Style.padding), child: new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const Text('状态: '),
                              new Text('${data.status??''}', style:  data.status == '异常' ? TextStyle(color: Colors.redAccent) : null,),
                            ],
                          ),
                        ),
                        getModel(context).isTask ? new PopupMenuButton<_StatusSelect>(
                          icon: const Icon(Icons.arrow_drop_down),
                          itemBuilder: (BuildContext context) {
                            return _statusList.map((_StatusSelect status) {
                              return new PopupMenuItem<_StatusSelect>(
                                value: status,
                                child: new Text(status.value),
                              );
                            }).toList();
                          },
                          onSelected: (_StatusSelect value) {
                            print('status = ${value.value}');
                            setState(() {
                              data.status = value.value;
                            });
                          },
                        ) : Text(''),
                      ])),
                  Padding(padding: Style.pagePadding2, child:Divider(height: 1.0,)),
                  Padding(padding: Style.pagePadding2, child:Text('时间: ${Func.getFullTimeString(data.statusdate)}')),
                  Padding(padding: Style.pagePadding2, child:Divider(height: 1.0,)),
                  Padding(padding: Style.pagePadding, child:Text('人员: ${getModel(context).user?.displayname ?? ''}')),
                  Container(height: Style.separateHeight, color: Style.backgroundColor,),


                  Padding(padding: Style.pagePadding, child:Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('备注: '),
                      Expanded(child: getModel(context).isTask ? TextField(
                        controller: _controller,
                        maxLines: 3,
                        enabled: getModel(context).isTask,
                        decoration: new InputDecoration(
                          contentPadding: EdgeInsets.all(0.0),
                          hintStyle: TextStyle(fontSize: 16.0),
                          hintText: '请输入备注信息',
                        ),
                      ): Text('${data.remark ??''}'))
                    ],
                  )),

                  Padding(padding: Style.pagePadding, child:Row(
                    children: <Widget>[
                      Text('照片: '),
                      new PictureList(index: widget.index, canAdd: getModel(context).isTask,)
                    ],
                  )),

                ],
              ),
            ),)),
          getModel(context).isTask ? new Positioned(left: 0.0, bottom: 20.0, right: 0.0, child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text('异常报修', style: TextStyle(color: Colors.white),),
                color: Colors.redAccent,
                onPressed: (){

                },
              ),
              RaisedButton(
                child: Text('提交保存', style: TextStyle(color: Colors.white),),
                color: Style.primaryColor,
                onPressed: (){

                },
              )
            ],
          )) : Positioned(left: 0.0, bottom: 0.0, right: 0.0, child: Text('')),
        ],

      ),
    );
  }


  @override
  void initState() {
    super.initState();
    _controller = new TextEditingController(text: widget.data.remark?? ' ');
  }


  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: new AppBar(
        title: Text('填写结果'),
      ),
      body: _getBody(),
    );
  }
}

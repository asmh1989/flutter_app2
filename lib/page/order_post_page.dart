import 'dart:async';
import 'package:flutter/material.dart';
import 'package:samex_app/model/order_detail.dart';
import 'package:samex_app/components/loading_view.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/model/user.dart';
import 'package:samex_app/utils/cache.dart';
import 'package:samex_app/page/people_page.dart';
import 'package:samex_app/model/people.dart';


final List<_StatusSelect> _statusList = <_StatusSelect>[
  _StatusSelect(0, '机械'),
  _StatusSelect(1, '电器'),
  _StatusSelect(2, '仪表'),
  _StatusSelect(3, '自控'),
  _StatusSelect(4, '其他'),
];

final List<_StatusSelect> _statusList2 = <_StatusSelect>[
  _StatusSelect(0, 'AA'),
  _StatusSelect(1, 'A'),
  _StatusSelect(2, 'B'),
  _StatusSelect(3, 'C'),
];


class _StatusSelect{
  int key;
  String value;


  _StatusSelect(this.key, this.value);
}

class OrderPostPage extends StatefulWidget {

  final int id;
  final Actions action;
  final String wonum;

  const OrderPostPage({@required this.id, @required this.action, @required this.wonum});
  @override
  _OrderPostPageState createState() => _OrderPostPageState();
}

class _OrderPostPageState extends State<OrderPostPage> {

  bool _show = false;
  String _assignCode;
  PeopleData _data;
  TextEditingController _controller;

  bool otherConfig = false;

  String _woprof = '';          //报修工单分类
  String _faultlev = '';        // 故障等级


  @override
  void initState() {
    super.initState();

    _controller = new TextEditingController();

    String title = Cache.instance.userTitle;
    if(title != null && title.contains('部长')){
      if(widget.action.instruction == '工单验收通过'){
        otherConfig = true;
      }
    }

  }

  void _submit() async {
    Func.closeKeyboard(context);

    if(otherConfig){
      if(_faultlev.length == 0){
        Func.showMessage('请先设置故障等级');
        return;
      }
      if(_woprof.length == 0){
        Func.showMessage('请先设置报修工单分类');
        return;
      }
    }

    await new Future.delayed(new Duration(milliseconds: 200), (){});

    setState(() {
      _show = true;
    });


    try {
      Map response = await getModel(context).api.submit(
        assigncode: _data?.hrid?? Cache.instance.userName,
        actionid: widget.action.actionid,
        notes:  _controller.text,
        ownerid: widget.id,
        action: widget.action.instruction,
        site: Cache.instance.site,
        wonum: widget.wonum,
        woprof: _woprof,
        faultlev: _faultlev
      );

      UserResult result = new UserResult.fromJson(response);
      if(result.code != 0){
        Func.showMessage(result.message);

      } else {
        Navigator.pop(context, 'done');
        Func.showMessage('提交成功');
      }

    } catch (e){
      Func.showMessage('提交失败: ${e.toString()}');
    }

    if(mounted){
      setState(() {
        _show = false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {


    _assignCode = _data?.displayname;
    return new Scaffold(
        appBar: new AppBar(
          title: Text(widget.action.instruction ?? '提交工作流'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.done),
              tooltip: '提交',
              onPressed: (){
                  _submit();
              },
            )
          ],
        ),
//        floatingActionButton: new FloatingActionButton(
//            child: Icon(Icons.done),
//            backgroundColor: Colors.redAccent,
//            tooltip: '提交',
//            onPressed: (){
//              _submit();
//            }),
        body: new GestureDetector(
          onTap: (){
            Func.closeKeyboard(context);
          },
          child:  LoadingView(
            show: _show,
            child:  Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  widget.action.instruction.contains(new RegExp(r'[责任人|指派]')) ?  ListTile(
                    title: Text('指派工单负责人'),
                    subtitle: Text(_assignCode?? '请选择人员'),
                    trailing: Icon(Icons.edit),
                    onTap: () async{
                        final  result = await Navigator.push(context,
                          new MaterialPageRoute(builder: (_)=> PeoplePage(req: new RegExp(r'维修|设备'),) )
                        );

                        if(result != null) {
                          setState(() {
                            _data = result;
                          });
                        }
                    },
                  ) : Container(),
                  ListTile(
                    title:Text('工单编号'),
                    subtitle: Text(widget.wonum),
                  ),
                  ListTile(
                    title: Text('操作人'),
                    subtitle: Text(Cache.instance.userDisplayName),
                  ),

                  otherConfig ?  Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), child:
                  new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('报修工单分类', style: TextStyle(fontSize: 16.0),),
                            Text(_woprof, style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                         new Expanded(
                            child:new PopupMenuButton<_StatusSelect>(
                              tooltip:'请选择巡检状态',

                              child: Align(child: const Icon(Icons.arrow_drop_down), alignment: Alignment.centerRight, heightFactor: 1.5,),
                              itemBuilder: (BuildContext context) {
                                return _statusList.map((_StatusSelect status) {
                                  return new PopupMenuItem<_StatusSelect>(
                                    value: status,
                                    child: new Text(status.value),
                                  );
                                }).toList();
                              },
                              onSelected: (_StatusSelect value) {
//                                print('status = ${value.value}');
                                setState(() {
                                  _woprof = value.value;
                                });
                              },
                            )),
                      ])): new Container(),

                  otherConfig ?  Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), child: new Row(
                      children: <Widget>[
                        new Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('故障等级', style: TextStyle(fontSize: 16.0),),
                            Text(_faultlev, style: TextStyle(color: Colors.grey)),
                          ],
                        ),

                        new Expanded(
                            child:new PopupMenuButton<_StatusSelect>(
                              tooltip:'请选择巡检状态',

                              child: Align(child: const Icon(Icons.arrow_drop_down), alignment: Alignment.centerRight, heightFactor: 1.5,),
                              itemBuilder: (BuildContext context) {
                                return _statusList2.map((_StatusSelect status) {
                                  return new PopupMenuItem<_StatusSelect>(
                                    value: status,
                                    child: new Text(status.value),
                                  );
                                }).toList();
                              },
                              onSelected: (_StatusSelect value) {
//                                print('status = ${value.value}');
                                setState(() {
                                  _faultlev = value.value;
                                });
                              },
                            )),
                      ])): new Container(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text('备注'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _controller,
                      maxLines: 4,
                      decoration: new InputDecoration(
                          hintText: "输入备注",
                          contentPadding: const EdgeInsets.all(8.0),
                          hintStyle: TextStyle(fontSize: 16.0),
                          border: new OutlineInputBorder()
                      ),
                    ),
                  ),

                Expanded(child: Container(
                  color: Colors.transparent),
                )
                ],
              ),
            ),
          ),
        ));
  }
}

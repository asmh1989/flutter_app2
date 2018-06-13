import 'package:flutter/material.dart';
import 'package:samex_app/data/root_model.dart';
import 'package:samex_app/utils/func.dart';
import 'package:samex_app/utils/style.dart';
import 'package:samex_app/model/description.dart';
import 'package:samex_app/utils/cache.dart';
import 'package:samex_app/components/simple_button.dart';
import 'package:samex_app/utils/assets.dart';

// 资产选择
class ChooseAssetPage extends StatefulWidget {

  final String location;

  ChooseAssetPage({this.location});

  @override
  _ChooseAssetPageState createState() => _ChooseAssetPageState();
}

class _ChooseAssetPageState extends State<ChooseAssetPage> {
  TextEditingController _scroller;
  bool _loading = true;
  bool _request = false;

  @override
  void initState() {
    super.initState();

    _scroller = new  TextEditingController(text: '');
    _scroller.addListener((){
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {

    final list = getMemoryCache(cacheKey, callback: (){
      _getAsset();
    });

    if(list != null) _loading = false;

    return new Scaffold(
      appBar: new AppBar(
        title: Text('资产选择'),
        actions: <Widget>[
          new IconButton(
              icon: Icon(Icons.refresh),
              tooltip: '数据刷新',
              onPressed: (){
                if(!_loading){
                  _getAsset();
                }
              })
        ],
      ),
      floatingActionButton: new FloatingActionButton(
          child: Tooltip(child: new Image.asset(ImageAssets.scan, height: 20.0,), message: '扫码', preferBelow: false,),
          backgroundColor: Colors.redAccent,
          onPressed: () async {
            String result = await Func.scan();

            if(result != null && result.isNotEmpty && result.length > 0){
              _scroller.text = result;
            }

          }),
      body: new Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color:Style.backgroundColor,
            padding: const EdgeInsets.all(20.0),
            child: new TextField(
              controller: _scroller,
              decoration: new InputDecoration(
                  hintText: "请输入资产号进行过滤",
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(8.0),
                  hintStyle: TextStyle(fontSize: 16.0),
                  border: new OutlineInputBorder(),
                  suffixIcon: _scroller.text.isNotEmpty ? new IconButton(icon: Icon(Icons.clear), onPressed: (){
                    _scroller.clear();
                  }): null
              ),
            ),
          ),
          Expanded(child: _loading ? Center(child: CircularProgressIndicator(),) : _getContent(),)

        ],
      ),
    );
  }

  List<DescriptionData> _filters(List<DescriptionData> data){
    if(data == null) return null;

    return data.where((DescriptionData f) {

      if(_scroller.text.length > 0){
        return  f.assetnum.contains(_scroller.text.toUpperCase());
      }

      return  true;

    }).toList();

  }

  Widget _getContent(){
    List<DescriptionData> data = getMemoryCache(cacheKey, expired: false);

    data = _filters(data);

    if(data == null || data.length == 0){
      return Center(child: Text('没有可选择的资产'),);
    }

    return new ListView.builder(
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (_, int index){
        DescriptionData asset = data[index];
        return new Container(
            child: new Column(
              children: <Widget>[
                SimpleButton(

                  child:ListTile(
                    leading:CircleAvatar(child: Text('${index+1}'),),
                    title: Text('${asset.assetnum}'),
                    subtitle: Text('描述:${asset.description??''}'),
                    trailing: Text('位置:${asset.locationDescription}'),
                  ),
                  onTap: (){
                    Navigator.pop(context, asset);
                  },
                ),

                Divider(height: 1.0,)
              ],
            )
        );
      },

    );
  }

  String get cacheKey => '__${Cache.instance.site}_assets';

  void _getAsset({String asset='', int count = 50000, bool queryOne}) async {
    if(_request) return;
    setState(() {
      _loading = true;
    });
    try{
      _request = true;
      Map response = await getModel(context).api.getAssets(
        location: widget.location,
        count: count,
        queryOne: queryOne,
        asset: asset
      );
      DescriptionResult result = new DescriptionResult.fromJson(response);
      if(result.code != 0) {
        Func.showMessage(result.message);
      } else {
        setMemoryCache<List<DescriptionData>>(cacheKey, result.response);
      }

    } catch (e){
      print (e);
      setMemoryCache<List<DescriptionData>>(cacheKey, getMemoryCache(cacheKey)??[]);

      Func.showMessage('网络异常, 请求资产接口失败');
    }

    _request = false;
    if(mounted){
      setState(() {
        _loading = false;
      });
    }
  }
}

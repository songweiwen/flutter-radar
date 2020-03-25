import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_radar/model/exhibits_model.dart';
import 'package:flutter_radar/provide/mainPage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provide/provide.dart';


class ExhibitsPage extends StatelessWidget {

  final int exhibitionId;
  ExhibitsPage(this.exhibitionId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // app_title + back
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text('展品列表'),
      ),
      body: FutureBuilder(
        future: _getExhibitsList(context),
        builder: (context, snapshot){
          if (snapshot.hasData != null) {
            List<Exhibits> exhibitsList = Provide.value<MainPageProvide>(context).allExhibitsByExhbition;
            if (exhibitsList.length != 0) {
              return _staggeredGridView(context, exhibitsList);
            } else {
              return Center(
                child: Text('暂无数据'),
              );
            }
          } else {
            return Text('正在加载。。。。');
          }
        },
      ),
    );
  }

  Future<String> _getExhibitsList(BuildContext context) async {

    await Provide.value<MainPageProvide>(context).getExhibitsListByExhibition(exhibitionId);
    return 'end';
  }

  Widget _staggeredGridView(context , List<Exhibits> list){
    return Container(

      child: Scrollbar(

        child: StaggeredGridView.countBuilder(
          crossAxisCount: 4,
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) => new Column(
              // alignment: Alignment.bottomCenter,
              children: <Widget>[
                
                new GestureDetector(
                  onTap: (){
                    // Provide.value<ExhibitsListProvide>(context).getExhibitsById(list[index].exhibitsId);
                    // Application.router.na vigateTo(context, "/details");
                  },
                  child: CachedNetworkImage(
                      imageUrl: "${list[index].exhibitsImg}",
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                  
                  // Image(
                  //   image: NetworkImage(list[index].exhibitsImg),
                  //   fit: BoxFit.fill,
                  // ),
                ),
                
                Text(
                    '${list[index].exhibitsName}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(34),
                      color: Colors.black
                    ),
                ),

                Text(
                  '${list[index].exhibitsId}',
                  overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(34),
                      color: Colors.black
                  ),
                )
              ],
          ),
          staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'views/home_view.dart';
import 'package:dio/dio.dart';
import 'models/hotel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (BuildContext context) => HomeView(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  bool hasError = false;
  List<HotelPreview> hotels;
  String errorMessage;
  Dio _dio = Dio();
  bool isGridViewOn = false;
  bool isListViewOn = false;
  final GlobalKey<ScaffoldState> _scaffoldKey =
  new GlobalKey<ScaffoldState>(); // this is declared inside the State

  @override
  void initState() {
    super.initState();
    //getDataHttp();
    getDataDio();
  }

  getDataDio() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await _dio
          .get('https://run.mocky.io/v3/ac888dc5-d193-4700-b12c-abb43e289301');
      var data = response.data;
      hotels = data.map<ListView>((hotel) => HotelPreview.fromJson(hotel)).toList();
    } on DioError catch (e) {
      setState(() {
        errorMessage = e.response.data['message'];
        hasError = true;
        isLoading = false;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.view_list),
            onPressed: () {
              setState(() {
                isListViewOn = true;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.view_module),
            onPressed: () {
              setState(() {
                isGridViewOn = true;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          if (isLoading && !hasError) CircularProgressIndicator(),
          if (!isLoading && hasError) Text(errorMessage),
          if (!isLoading && hasError == false)
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return isListViewOn && !isGridViewOn
                      ? ListView(children: <Widget>[
                    ...hotels.map((hotel) {
                      return ListTile(
                        leading: Text(hotel.uuid),
                        title: Text(hotel.name),
                        subtitle: Text(hotel.poster),
                      );
                    }).toList(),
                  ])
                      : GridView(
                    children: <Widget>[
                      ...hotels.map((hotel) {
                        return GridTile(
                          header: Text(hotel.uuid),
                          child: Text(hotel.name),
                          footer: Text(hotel.poster),
                        );
                      }).toList(),
                    ],
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                  );
                },
              ),
            )
        ],
      ),
    ),
    );
  }
}
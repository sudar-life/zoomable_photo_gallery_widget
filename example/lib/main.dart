import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zoomable_photo_gallery/zoomable_photo_gallery_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zoomable Photo Gallery')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SimpleGallery()));
              },
              child: Text('Simple Option Gallery'),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Gallery()));
                },
                child: Text('Gallery')),
          ],
        ),
      ),
    );
  }
}

class SimpleGallery extends StatefulWidget {
  SimpleGallery({Key? key}) : super(key: key);

  @override
  State<SimpleGallery> createState() => _SimpleGalleryState();
}

class _SimpleGalleryState extends State<SimpleGallery> {
  List<Widget> imageFile = [
    Image.asset('assets/images/1.jpg'),
    Image.asset('assets/images/2.jpg'),
    Image.asset('assets/images/3.jpg'),
    Image.asset('assets/images/4.jpg'),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zoomable Photo Gallery')),
      body: ZoomablePhotoGallery(
        imageList: List.generate(
          imageFile.length,
          (index) => imageFile[index],
        ),
      ),
    );
  }
}

class Gallery extends StatefulWidget {
  Gallery({Key? key}) : super(key: key);

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  ZoomablePhotoController controller = ZoomablePhotoController();
  int currentPageIndex = 0;
  List<String> imageUrl = [
    'https://images.pexels.com/photos/1172253/pexels-photo-1172253.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
    'https://img.rawpixel.com/private/static/images/website/2022-05/px142077-image-kwvvvktc.jpg?w=800&dpr=1&fit=default&crop=default&q=65&vib=3&con=3&usm=15&bg=F4F4F3&ixlib=js-2.2.1&s=0cfd8aa6e66ad55612f900d479a9d0de',
    'https://media.istockphoto.com/photos/alone-on-my-way-picture-id696708198?k=20&m=696708198&s=170667a&w=0&h=HUbGtSvBo0DfNaXh1N3PNL1M0Lzg7Sqs38e4aZ5JmJE=',
    'https://st.depositphotos.com/1005844/4918/i/600/depositphotos_49180569-stock-photo-fantasy-landscape.jpg',
    'https://p.bigstockphoto.com/GeFvQkBbSLaMdpKXF1Zv_bigstock-Aerial-View-Of-Blue-Lakes-And--227291596.jpg',
  ];

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      // print(controller.page);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zoomable Photo Gallery')),
      body: ZoomablePhotoGallery(
        controller: controller,
        initIndex: 3,
        backColor: Colors.white,
        maxZoom: 5,
        minZoom: 0.5,
        location: IndicatorLocation.BOTTOM_CENTER,
        changePage: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicator: List.generate(
          imageUrl.length,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: index == currentPageIndex ? Colors.red : Colors.grey,
            ),
          ),
        ).toList(),
        imageList: List.generate(
          imageUrl.length,
          (index) => CachedNetworkImage(
            imageUrl: imageUrl[index],
            fadeInDuration: Duration.zero,
            fadeOutDuration: Duration.zero,
            progressIndicatorBuilder: (_, v, p) {
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

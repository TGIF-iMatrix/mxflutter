//  MXFlutterFramework
//  Copyright 2019 The MXFlutter Authors. All rights reserved.
//
//  Use of this source code is governed by a MIT-style license that can be
//  found in the LICENSE file.

let {
    runApp,
    MXJSFlutterApp,
    MXJSStatefulWidget,
    MXJSWidgetState,
    Scaffold,
    Container,
    Color,
    Colors,
    AppBar,
    Text,
    ListView,
    ListTile,
    Icon,
    IconData,
    EdgeInsets,
    TextAlign,
    TextStyle,
    Row,
    Padding,
    Theme,
    Navigator,
    MaterialPageRoute,
    Scrollbar,
    MXJSLog,
} = require("js_flutter.js");

const { SectionTitle } = require("./component/section_title.js");

let { JSContactPage } = require("./contact.js");
let { JSAnimationPage } = require("./animation.js");
let { JSMaterialPage } = require("./material.js");


//let { ExamplesPage } = require("./examples/index.js");
let { JSCupertinoPage } = require("./cupertino.js");

const dart_sdk = require("dart_sdk");
const dart = dart_sdk.dart;
const async = dart_sdk.async;


//业务代码
class MXJSWidgetHomePage extends MXJSStatefulWidget {
    constructor() {
        super("MXJSWidgetHomePage");

        this.data = "biz data";
        this.count = 0;
    }

    createState() {
        return new MXJSWidgetHomePageState(this);
    }
}

class MXJSWidgetHomePageState extends MXJSWidgetState {

    build(context) {

        let demoList = new ListView({

            children: [

                this.sectionTitle(context, "App Demo"),
                new ListTile({
                    leading: new Icon(new IconData(0xe39d, { fontFamily: 'MaterialIcons' }), { color: Theme.of(context).primaryColor }),
                    trailing: new Icon(new IconData(0xe5df, { fontFamily: 'MaterialIcons', matchTextDirection: true })),
                    title: new Text('Examples'),
                    subtitle: new Text('All examples'),
                    onTap: function () {

                        //点击时懒加载页面
                        let { ExamplesPage } = require("./examples/index.js");

                        Navigator.push(context, new MaterialPageRoute({
                            builder: function (context) {
                                return new ExamplesPage;
                            }
                        }))


                    }
                }),
                new ListTile({
                    leading: new Icon(new IconData(0xe06d, { fontFamily: 'MaterialIcons' })),
                    trailing: new Icon(new IconData(0xe5df, { fontFamily: 'MaterialIcons', matchTextDirection: true })),
                    title: new Text('Material'),
                    subtitle: new Text('Material UI Demo'),
                    onTap: function () {
                        Navigator.push(context, new MaterialPageRoute({
                            builder: function (context) {
                                return new JSMaterialPage;
                            }
                        }))
                    }
                }),
                new ListTile({
                    leading: new Icon(new IconData(0xe39d, { fontFamily: 'MaterialIcons' }), { color: Theme.of(context).primaryColor }),
                    trailing: new Icon(new IconData(0xe5df, { fontFamily: 'MaterialIcons', matchTextDirection: true })),
                    title: new Text('ZhiHu'),
                    subtitle: new Text('ZhiHu high copy'),
                    onTap: function () {

                        let { JSZhiHuPage } = require("./zhihu/zhihu.js");

                        Navigator.push(context, new MaterialPageRoute({
                            builder: function (context) {
                                return new JSZhiHuPage;
                            }
                        }))
                    }
                }),

                new ListTile({
                    leading: new Icon(new IconData(0xe39d, { fontFamily: 'MaterialIcons' }), { color: Theme.of(context).primaryColor }),
                    trailing: new Icon(new IconData(0xe5df, { fontFamily: 'MaterialIcons', matchTextDirection: true })),
                    title: new Text('网易新闻 ListViewDemo'),
                    subtitle: new Text('ListView ,Message Channel, Pull to refresh'),

                    onTap: function () {

                        let list_view = require("./listview_example.js");

                        Navigator.push(context, new MaterialPageRoute({
                            builder: function (context) {
                                return new list_view.ListViewDemo;
                            }
                        }))
                    }
                }),

                new ListTile({
                    leading: new Icon(new IconData(0xe39d, { fontFamily: 'MaterialIcons' }), { color: Theme.of(context).primaryColor }),
                    trailing: new Icon(new IconData(0xe5df, { fontFamily: 'MaterialIcons', matchTextDirection: true })),
                    title: new Text('PlatformAPIExamples'),
                    subtitle: new Text('Network/Dio/MessageChannel'),

                    onTap: function () {

                        let { PlatformExamplesPage } = require("./platform/index.js");

                        Navigator.push(context, new MaterialPageRoute({
                            builder: function (context) {
                                return new PlatformExamplesPage;
                            }
                        }))
                    }
                }),

                new ListTile({
                    leading: new Icon(new IconData(0xe06d, { fontFamily: 'MaterialIcons' })),
                    trailing: new Icon(new IconData(0xe5df, { fontFamily: 'MaterialIcons', matchTextDirection: true })),
                    title: new Text('Pesto'),
                    subtitle: new Text('Simple recipe browser'),

                    onTap: function () {

                        let pesto = require("./pesto.js");

                        Navigator.push(context, new MaterialPageRoute({
                            builder: function (context) {
                                return new pesto.JSPestoPage;
                            }
                        }))
                    }
                }),
                new ListTile({
                    leading: new Icon(new IconData(0xe0d0, { fontFamily: 'MaterialIcons' }), { color: Theme.of(context).primaryColor }),
                    trailing: new Icon(new IconData(0xe5df, { fontFamily: 'MaterialIcons', matchTextDirection: true })),
                    title: new Text('Contact profile'),
                    subtitle: new Text('Address book entry with a flexible appbar'),

                    onTap: function () {
                        Navigator.push(context, new MaterialPageRoute({
                            builder: function (context) {
                                return new JSContactPage;
                            }
                        }))
                    }
                }),
                new ListTile({
                    leading: new Icon(new IconData(0xe06d, { fontFamily: 'MaterialIcons' })),
                    trailing: new Icon(new IconData(0xe5df, { fontFamily: 'MaterialIcons', matchTextDirection: true })),
                    title: new Text('Animation'),
                    subtitle: new Text('Section organizer'),
                    onTap: function () {
                        Navigator.push(context, new MaterialPageRoute({
                            builder: function (context) {
                                return new JSAnimationPage;
                            }
                        }))
                    }
                }),
                this.sectionTitle(context, "性能测试"),
                new ListTile({
                    leading: new Icon(new IconData(0xe06d, { fontFamily: 'MaterialIcons' })),
                    trailing: new Icon(new IconData(0xe5df, { fontFamily: 'MaterialIcons', matchTextDirection: true })),
                    title: new Text('Profile'),
                    subtitle: new Text('性能测试 performance profiling'),
                    onTap: function () {
                      

                        let { ProfileExamplesPage } = require("./profile/index.js");

                        Navigator.push(context, new MaterialPageRoute({
                            builder: function (context) {
                                return new ProfileExamplesPage;
                            }
                        }))
                    }
                }),
                
                this.sectionTitle(context, "mxjsbuilder build app"),
                new ListTile({
                    leading: new Icon(new IconData(0xe39d, { fontFamily: 'MaterialIcons' })),
                    trailing: new Icon(new IconData(0xe5df, { fontFamily: 'MaterialIcons', matchTextDirection: true })),
                    title: new Text('FlutterDemo'),
                    subtitle: new Text('简单样例'),
                    onTap: function () {

                        let flutter_demo_ddc = require("./mxjsbuilder_demo/flutter_demo.dart.lib.js");

                        Navigator.push(context, new MaterialPageRoute({
                            builder: function (context) {
                                return new flutter_demo_ddc.main.MyHomePage.new({title: "Flutter Demo Home Page"});
                            }
                        }))
                    }
                }),
                new ListTile({
                    leading: new Icon(new IconData(0xe39d, { fontFamily: 'MaterialIcons' })),
                    trailing: new Icon(new IconData(0xe5df, { fontFamily: 'MaterialIcons', matchTextDirection: true })),
                    title: new Text('ContactDemo'),
                    subtitle: new Text('联系人'),

                    onTap: function () {

                        let contact_demo_ddc = require("./mxjsbuilder_demo/contacts_demo.dart.lib.js");

                        Navigator.push(context, new MaterialPageRoute({
                            builder: function (context) {
                                return new contact_demo_ddc.contacts_demo.ContactsDemo.new;
                            }
                        }))
                    }
                }),
                new ListTile({
                    leading: new Icon(new IconData(0xe39d, { fontFamily: 'MaterialIcons' })),
                    trailing: new Icon(new IconData(0xe5df, { fontFamily: 'MaterialIcons', matchTextDirection: true })),
                    title: new Text('PestoDemo'),
                    subtitle: new Text('菜谱'),
                    onTap: function () {

                        let pesto_demo_ddc = require("./mxjsbuilder_demo/pesto_demo.dart.lib.js");

                        Navigator.push(context, new MaterialPageRoute({
                            builder: function (context) {
                                return new pesto_demo_ddc.pesto_demo.PestoDemo.new;
                            }
                        }))
                    }
                }),
                new ListTile({
                    leading: new Icon(new IconData(0xe39d, { fontFamily: 'MaterialIcons' })),
                    trailing: new Icon(new IconData(0xe5df, { fontFamily: 'MaterialIcons', matchTextDirection: true })),
                    title: new Text('ZhiHu'),
                    subtitle: new Text('知乎-高仿版'),

                    onTap: function () {

                        const packages__zhihu__index = require('./mxjsbuilder_demo/packages/zhihu/index/index.dart.lib.js');
                        const index_page = packages__zhihu__index.index__index;

                        Navigator.push(context, new MaterialPageRoute({
                            builder: function (context) {
                                return new index_page.Index.new;
                            }
                        }))
                    }
                }),
            ]
        });

        let w = new Scaffold({
            appBar: new AppBar({
                title: new Text("MXFlutter Examples")
            }),
            body: demoList
        });


        return w;
    }

    sectionTitle(context, title) {
        return new SectionTitle(title);
    }
}

module.exports = { MXJSWidgetHomePage };
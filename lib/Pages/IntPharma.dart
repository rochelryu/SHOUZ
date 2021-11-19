import 'package:flutter/material.dart';
import 'package:shouz/Constant/Style.dart' as prefix0;
import 'package:shouz/Constant/my_flutter_app_second_icons.dart' as prefix1;




class IntPharma extends StatefulWidget {
  IntPharma({Key key}) : super(key: key);

  @override
  _IntPharmaState createState() => _IntPharmaState();
}

class _IntPharmaState extends State<IntPharma> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: prefix0.backgroundColor,
       appBar: AppBar(
         elevation: 0,
         backgroundColor: prefix0.backgroundColor,
         title: Text('Pharmacie de Garde'),
       ),
       body: GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Column(
             children: <Widget>[
               Container(
                 width: double.infinity,
                 height: 55,
                 margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 17.0),
                 child: new TextFormField(
                        decoration: new InputDecoration(
                          hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
                          suffix: Icon(Icons.search, color: Colors.white),
                          prefixIcon: Icon(Icons.location_city, color: Colors.white,),
                          labelText: "Enter la ville",
                          
                          labelStyle: TextStyle(color: Colors.white),
                          fillColor: Colors.white,
                          border: new OutlineInputBorder(
                            
                            borderRadius: new BorderRadius.circular(25.0),
                            borderSide: new BorderSide(
                              color: Colors.white,
                            ),
                          ),
                          //fillColor: Colors.green
                        ),
                        validator: (val) {
                          if(val.length==0) {
                            return "La ville ne peut pas être vide";
                          }else{
                            return null;
                          }
                        },
                        
                        keyboardType: TextInputType.number,
                        style: new TextStyle(
                          fontFamily: "Poppins",
                        ),
                      ),
               ),
              Expanded(
                   child: GridView.builder(
                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                   itemCount: 15,
                   itemBuilder: (context, index){
                     return Card(
                       elevation: 4.0,
                       color: prefix0.backgroundColor,
                        child: new Container(
                         child: InkWell(
                           onTap: (){
                             print(index);
                           },
                           child: Stack(children: <Widget>[
                             Container(
                               width: double.infinity,
                               height: double.infinity,
                               child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(prefix1.MyFlutterAppSecond.pharmacy, color: Colors.white, size: 52.0),
                                      SizedBox(height: 10),
                                      Text('Ville' + index.toString(), style: prefix0.Style.titleInSegment())
                                      
                                    ],
                                  ),
                            ),
                           Positioned(
                             top: 10,
                             right: 10,
                             child: Container(
                               width: 20,
                               height: 20,
                               decoration: BoxDecoration(
                                 color: prefix0.backgroundColorSec,
                                 borderRadius: BorderRadius.circular(50)
                                 ),
                                 child: Center(
                                   child: Text(index.toString(), style: prefix0.Style.titleInSegment()),),
                             ),)
                           ],)
                           ),
                       ),
                     );
                   },
                 ),
               
                 ),
                 
               
            ],
          ),
         ),
    );
  }
}
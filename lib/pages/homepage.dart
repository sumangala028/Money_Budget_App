import 'package:expense/controllers/db_helper.dart';
import 'package:expense/models/Transaction_model.dart';
import 'package:expense/pages/Add_rename.dart';
import 'package:expense/pages/add_transaction.dart';
import 'package:expense/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense/static.dart' as Static;


class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  late Box box;
  late SharedPreferences preferences;
  DbHelper dbHelper = DbHelper();
  Map? data;
  int tBalance = 0;
  int tIncome = 0;
  int tExpense = 0;

  DateTime today = DateTime.now();
  DateTime now = DateTime.now();
  int index = 1;
  List<String> months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

@override
void initState() {
  super.initState();
  getPreference();
  box = Hive.box('money');
  fetch();
}

getPreference() async {
  preferences = await SharedPreferences.getInstance();
}


  Future<List<TransactionModel>> fetch() async {
    if (box.values.isEmpty) {
      return Future.value([]);
    } else {
      
      List<TransactionModel> arr = [];
      box.toMap().values.forEach((element) {
       
        arr.add(
          TransactionModel(
            element['amount'] as int,
            element['note'],
            element['date'] as DateTime,
            element['type'],
          ),
        );
      });
      return arr;
    }
  }

getTotBalance(List<TransactionModel> entiredata)
{
  tExpense=0;
  tIncome=0;
  tBalance=0;

  for (TransactionModel data in entiredata) {
    if (data.date.month == today.month)
      if( data.type == "Income") {
     tBalance+=data.amount;
     tIncome+=data.amount;
    }
    else {
      tBalance-=data.amount;
      tExpense+= data.amount;

      }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(


      appBar: AppBar(
        toolbarHeight: 0.0,
      ),

      persistentFooterButtons: [

        Container(

          width: 900,
          child: Text(
            '© sumangala MS22040930',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.black,
                letterSpacing: 1,
                fontWeight: FontWeight.bold
            ),
          ),
        )
      ],

     
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(onPressed: (){

        Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddTransaction()
          ,),
        ).whenComplete(() {
          setState(() {});
        });
      },
        backgroundColor: Static.PrimaryMaterialColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
        child: Icon(Icons.add,size: 32.0,),


      ),
      body: FutureBuilder<List<TransactionModel>>(
        future:fetch(),
        builder: (context, snapshot) {
          if (snapshot.hasError){
          return Center(child: Text("Error Occured!"),);
        }
        if (snapshot.hasData){
          if(snapshot.data!.isEmpty)
            {
              return Center(child: Text("Please add the transactions by clicking this button!"),);
            }
           getTotBalance(snapshot.data!);
          return ListView(
            children: [
             Padding(
               padding: const EdgeInsets.all(12.0),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Row(
                     children: [
                       Container(
                         decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(30.0),
                           color: Colors.white,
                         ),


                         child: CircleAvatar(
                           maxRadius: 32.0,
                           child: Image.asset("assets/face.png",
                           width: 64.0,),
                         ),
                       ),
                       SizedBox(
                         width: 8.0,
                       ),

                         Text(
                           "Welcome, ${preferences.getString('name')} !!!",
                           style: TextStyle(
                             fontSize: 23.0,
                             fontWeight: FontWeight.w700,
                             color: Colors.green[600],
                           ),

                         ),
          ]
          ),
                   Container(

                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(12.0),
                       color: Colors.white70,
                     ),

                     padding: EdgeInsets.all(12.0),
                    child: IconButton(
                       icon: Icon(
                         Icons.settings,
                           size: 32.0,
                           color: Color(0xff3E454C)
                       ),
                       onPressed: () {
                         Navigator.of(context).pushReplacement(
                           MaterialPageRoute(
                             builder: (context) => AddreName(),
                           ),
                         );
                       },
                     ),
                   ),

                 ],
               ),
             ),

              Container(

                width: MediaQuery.of(context).size.width *0.9,
                margin: EdgeInsets.all(11.0),
                child: Container(
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [
                    Colors.greenAccent,
                    Colors.redAccent,
                  ],),
                  borderRadius: BorderRadius.all(Radius.circular(23.0))
                  ),


                  padding: EdgeInsets.symmetric(vertical: 21.0,horizontal: 8.0),
                  child: Column(children: [
                    Text("Total Balance", textAlign: TextAlign.center,style: TextStyle
                      (fontSize: 22.0, color: Colors.black, fontWeight: FontWeight.w500)
                      ,),

                    SizedBox(
                      height: 12.0,
                    ),

                    Text("$tBalance LKR ", textAlign: TextAlign.center,style: TextStyle
                      (fontSize: 26.0, color: Colors.black, fontWeight: FontWeight.w500)
                      ,),
                    SizedBox(
                      height: 12.0,
                    ),
                    Padding(padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          cardIncomePart(tIncome.toString()
                          ),
                          cardExpensePart(tExpense.toString())
                        ],
                      ),

                    )

                  ],),
                ),
              ),



              Padding(
                padding: const EdgeInsets.all(
                  12.0,
                ),
                child: Text(
                  "Recent Transactions",
                  style: TextStyle(
                    fontSize: 25.0,
                    color: Colors.black87,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length + 1,
                  itemBuilder: (context, index) {
                    TransactionModel dataAtIndex;
                    try {
              
                      dataAtIndex = snapshot.data![index];
                    } catch (e) {
                     
                      return Container();
                    }



                  if(dataAtIndex.type== "Income"){
                    return IncomePart(dataAtIndex.amount, dataAtIndex.note,
                    dataAtIndex.date,index);
                  }
                  else {
                    return expensePart(dataAtIndex.amount, dataAtIndex.note
                    ,dataAtIndex.date,index);
                  }

                  }
              ),
              SizedBox(
                height: 60.0,
              ),

            ],
          );
        }
        else{
          return Center(child: Text("Error!"),);

        }

    }
      ),
    );
  }


  Widget cardIncomePart(String value){
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(
              25.0,
            ),
          ),
          padding: EdgeInsets.all(7.0
          ),
          child: Icon(Icons.arrow_upward,
            size: 30.0,color: Colors.green[700],

          ),
          margin: EdgeInsets.only(right: 8.0),

        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "-Income-",
              style: TextStyle(
                fontSize: 17.0,
                color: Colors.white60,

              ),
            ),
            Text(
              "$value LKR " ,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  
  
  
  
 

Widget cardExpensePart(String value){
  return Row(
    children: [
      Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(
            25.0,
          ),
        ),
        padding: EdgeInsets.all(7.0
        ),
        child: Icon(Icons.arrow_downward,
          size: 30.0,color: Colors.red[900],

        ),
        margin: EdgeInsets.only(right: 8.0),

      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "-Expense-",
            style: TextStyle(
              fontSize: 17.0,
              color: Colors.white60,

            ),
          ),
          Text(
            "$value LKR",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ],
  );
}



Widget expensePart(int value, String note, DateTime date,int index){
  return InkWell(
    onLongPress: () async {
      bool? answer = await showConfirmDialog(
        context,
        "WARNING!!!",
        "This action will delete this expense record permanently. Do you want to continue ?",
      );
      if (answer != null && answer) {
        await dbHelper.deleteData(index);
        setState(() {});
      }
    },
    child: Container(
      margin: EdgeInsets.all(7.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: Color(0xfffac5c5),
      borderRadius: BorderRadius.circular(8.0) ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Row(
                children: [
                  Icon(Icons.arrow_circle_down_outlined,
                    size: 28.0,
                    color: Colors.red[600],
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Text("Expense",
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                  )

                ],
              ),

      Padding(
        padding: const EdgeInsets.all(6.0),
        child: Text("${date.day} ${months[date.month -1]} ${date.year}",
          style: TextStyle(
            color: Colors.grey[700],
           
          ),
        ),
      ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(" - $value LKR",style: TextStyle(fontSize: 23.0,fontWeight: FontWeight.w600,
              ),
              ),
              Text(note,style: TextStyle(
                color: Colors.grey[700]
      
              ),
              ),
            ],
          )
        ],
      ),


    ),
  );
}

  Widget IncomePart(int value, String note,DateTime date, int index){
    return InkWell(
      onLongPress: () async {
        bool? answer = await showConfirmDialog(
          context,
          "WARNING",
          "This action will delete this income record permanently. Do you want to continue ?",
        );
        if (answer != null && answer) {
          await dbHelper.deleteData(index);
          setState(() {});
        }
      },
      child: Container(
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(18.0),
        decoration: BoxDecoration(color: Color(0xff69f0ae),
            
            borderRadius: BorderRadius.circular(10.0) ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.arrow_circle_up_outlined,
                      size: 28.0,
                      color: Colors.green[800],
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text("Income",
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    )

                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text("${date.day} ${months[date.month -1]} ${date.year}",
                    style: TextStyle(
                      color: Colors.grey[800],
                     
                    ),
                  ),
                ),

              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(" + $value LKR",
                  style: TextStyle(
                      fontSize: 23.0,
                      fontWeight: FontWeight.w600),
                ),
                Text(note,
                  style: TextStyle(
                    color: Colors.grey[700],
                    

                  ),
                ),
              ],
            )
          ],
        ),


      ),

    );

  }




}

// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/centerText.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';

class CreateDebts extends StatefulWidget {
  final DocumentReference selectedTrip;
  const CreateDebts({
    super.key,
    required this.selectedTrip,
  });

  @override
  State<CreateDebts> createState() => _CreateDebtsState();
}

class _CreateDebtsState extends State<CreateDebts> {
  //TODO Finanzenproblem wegen status ,,open" ist nicht da irgendwie ein debug point mal bei finanzen setzen
  // ca. Zeile 126 bei finanzen.dart
  final title = TextEditingController();
  final description = TextEditingController();
  final totalAmount = TextEditingController();
  final myAmount = TextEditingController();
  List<TextEditingController> amountList = [];

  //TODO Nach Share Equally funktioniert das Calculate my a

  //TODO Buttons von Back und Finish konfigurieren
  //TItel für die bottomsheets wechseln passenden namen finden
  //
  //TODO Account nicht mehr und der betrag wird nicht ordentlich kalkuliert
  //wahrscheinlich weil die Liste ein Textfield zu viel hat
  //TODO Eigentlicher CurrentUser aus der Liste soll aus der ,,TO "Liste in Firebase nicht mitübernommen wird

  var members = [];

  bool shareEqually = false;
  bool calculateMyAmountDifference = false;

  bool newBottomSheet = false;

  final user = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;
  DocumentReference? selectedtrip;
  DocumentSnapshot? currentUser;

  Future<void> getGroupmembers() async {
    currentUser = await firestore.collection("users").doc(user.uid).get();
    String selecttripString =
        (currentUser!.data() as Map<String, dynamic>)["selectedtrip"];
    selectedtrip = firestore.collection("trips").doc(selecttripString);
    members =
        ((await selectedtrip!.get()).data() as Map<String, dynamic>)["members"];
    setState(() {
      for (var i = 0; i < members.length; i++) {
        var controller = TextEditingController();
        amountList.add(controller);
      }
    });
  }

  Future<void> createDebt() async {
    List<dynamic> to = [];

    for (int i = 0; i < members.length; i++) {
      if (amountList[i].text.isNotEmpty) {
        to.add({
          "amount": double.parse(amountList[i].text),
          "status": "open",
          "user": members[i],
        });
      }
    }

    if (title.text.isNotEmpty &&
        description.text.isNotEmpty &&
        totalAmount.text.isNotEmpty &&
        myAmount.text.isNotEmpty) {
      widget.selectedTrip.collection("payments").add({
        "title": title.text,
        "description": description.text,
        "amount": double.parse(totalAmount.text),
        "to": to,
        "createdBy": currentUser!.reference,
        "timestamp": DateTime.now(),
      });
    }
  }

  String membersName = "";
  String currentUserName = "";

  Future<String> getMembersName(DocumentReference members) async {
    String prename = "";
    String lastname = "";
    // Hole den Namen des Users aus der Datenbank
    var users = FirebaseFirestore.instance.collection('users');
    var collection = users.doc(members.id);
    DocumentSnapshot userData = await collection.get();

    if (userData['prename'] != null) {
      setState(() {
        prename = userData['prename'];
      });
    }
    if (userData['lastname'] != null) {
      setState(() {
        lastname = userData['lastname'];
      });
    }
    membersName = "$prename $lastname";
    if (members.id == user.uid) {
      currentUserName = membersName;
    }

    return membersName;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getGroupmembers();
  }

  void calculateMyAmount() {
    double totalAmountValue = double.parse(totalAmount.text);
    double sum = 0;

    for (int i = 0; i < amountList.length; i++) {
      if (amountList[i].text.isNotEmpty) {
        sum += double.parse(amountList[i]
            .text); // TODO: man bekommt Fehler wenn man statt . ein , benutzt
      }
    }

    double remainingAmount = totalAmountValue - sum;
    myAmount.text = remainingAmount.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!newBottomSheet) ...[
          InputField(
              controller: title,
              hintText: "Title of Payment",
              focusedBorderColor: const Color.fromARGB(255, 84, 113, 255),
              borderColor: Colors.grey.shade400,
              obscureText: false),
          const SizedBox(height: 15),
          InputField(
              controller: description,
              hintText: "Description of Payment",
              focusedBorderColor: const Color.fromARGB(255, 84, 113, 255),
              borderColor: Colors.grey.shade400,
              multiline: true,
              obscureText: false),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                  width: 150,
                  child: InputField(
                    controller: totalAmount,
                    hintText: "The total amount",
                    obscureText: false,
                    numberField: true,
                    focusedBorderColor: const Color.fromARGB(255, 84, 113, 255),
                    borderColor: Colors.grey.shade400,
                  )),
              Row(
                children: [
                  const Text(
                    "Share Equally:",
                    style: Styles.inputField,
                  ),
                  Checkbox(
                      value: shareEqually,
                      onChanged: (value) {
                        setState(() {
                          shareEqually = value!;
                          if (!shareEqually && totalAmount.text != "") {
                            bool allAmountsFilled = true;

                            for (int i = 0; i < amountList.length - 1; i++) {
                              if (amountList[i].text.isEmpty) {
                                allAmountsFilled = false;
                                break;
                              }
                            }

                            if (allAmountsFilled) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                calculateMyAmount();
                              });
                            } else {
                              ErrorSnackbar.showErrorSnackbar(
                                  context, "Please enter all amounts");
                            }
                          } else if (shareEqually == true &&
                              totalAmount.text == "") {
                            ErrorSnackbar.showErrorSnackbar(
                                context, "Please enter a Amount first");
                          } else if (shareEqually == true &&
                              totalAmount.text != "" &&
                              !_isNumeric(totalAmount)) {
                            ErrorSnackbar.showErrorSnackbar(
                                context, "Please enter a valid Amount");
                          } else if (shareEqually == true &&
                              totalAmount.text != "" &&
                              _isNumeric(totalAmount)) {
                            for (int i = 0; i < amountList.length; i++) {
                              amountList[i].text =
                                  (double.parse(totalAmount.text) /
                                          amountList.length)
                                      .toStringAsFixed(2);
                            }
                            myAmount.text = (double.parse(totalAmount.text) /
                                    amountList.length)
                                .toStringAsFixed(2);
                          } else {
                            for (int i = 0; i < amountList.length; i++) {
                              amountList[i].text = "";
                            }
                            myAmount.text = "";
                          }
                        });
                      }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          MyButton(
              borderColor: Colors.black,
              textStyle: Styles.buttonFontStyleModal,
              onTap: () {
                if (title.text != "" &&
                    description.text != "" &&
                    totalAmount.text != "" &&
                    _isNumeric(totalAmount)) {
                  setState(() {
                    newBottomSheet = true;
                  });
                } else if (!_isNumeric(totalAmount)) {
                  ErrorSnackbar.showErrorSnackbar(
                      context, "Please enter a valid Amount");
                } else {
                  ErrorSnackbar.showErrorSnackbar(
                      context, "Please fill in all fields");
                }
              }, //hhhhhh
              text: "Next"),
        ] else ...[
          Container(),
        ],

        //hier soll alles in einem andern bottomsheet sein, heißt der obere teil bottom sheet verschwindet nach links und von rechts kommt mäßig ein neues bottom sheet rein
        for (int i = 0; i < members.length && newBottomSheet == true; i++) ...{
          FutureBuilder(
              future: getMembersName(members[i]),
              builder: (context, members) {
                if (members.connectionState == ConnectionState.waiting) {
                  const Center(child: CircularProgressIndicator());
                }
                if (members.hasError) {
                  debugPrint(members.error.toString());
                  const CenterText(text: "Error while fetching Payments");
                }

                if (members.hasData) {
                  if ((members.data.toString() == currentUserName)) {
                    return Container();
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            width: 200,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(11.0),
                              border: Border.all(
                                  color: Colors.grey.shade400, width: 1),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 14,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  members.data.toString(),
                                  style: Styles.inputField,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            width: 150,
                            child: InputField(
                              controller: amountList[i],
                              hintText: "Enter the amount",
                              obscureText: false,
                              numberField: true,
                              focusedBorderColor:
                                  const Color.fromARGB(255, 84, 113, 255),
                              borderColor: Colors.grey.shade400,
                            )),
                      ],
                    );
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
          if (i < members.length - 1 &&
              (members[i] as DocumentReference).id != user.uid &&
              newBottomSheet)
            const SizedBox(height: 10),
        },

        if (newBottomSheet) ...[
          const SizedBox(height: 10),
          const Divider(
            height: 10,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Calculate my Amount:", // My amount will be calculated automatically
                style: Styles.inputField,
              ),
              Checkbox(
                  value: calculateMyAmountDifference,
                  onChanged: (value) {
                    setState(() {
                      calculateMyAmountDifference = value!;
                      calculateMyAmountDifference &&
                              totalAmount.text != "" &&
                              !shareEqually
                          ? WidgetsBinding.instance.addPostFrameCallback((_) {
                              calculateMyAmount();
                            })
                          : myAmount.text = "";
                    });
                  }),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11.0),
                    border: Border.all(color: Colors.grey.shade400, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 14,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        currentUserName,
                        style: Styles.inputField,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                  width: 150,
                  child: InputField(
                    controller: myAmount,
                    hintText: "Enter the amount",
                    obscureText: false,
                    numberField: true,
                    focusedBorderColor: const Color.fromARGB(255, 84, 113, 255),
                    borderColor: Colors.grey.shade400,
                  )),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyButton(
                  borderColor: Colors.black,
                  textStyle: Styles.buttonFontStyleModal,
                  onTap: () {
                    setState(() {
                      newBottomSheet = false;
                    });
                  }, //hhhhhh
                  text: "Back"),
              MyButton(
                  borderColor: Colors.black,
                  textStyle: Styles.buttonFontStyleModal,
                  onTap: () => {createDebt, Navigator.pop(context)}, //hhhhhh
                  text: "Finish"),
            ],
          ),
        ] else ...[
          Container(),
        ],
      ],
    );
  }

  bool _isNumeric(TextEditingController controller) {
    if (controller.text == "") {
      return false;
    }
    if (controller.text.contains(",")) {
      controller.text = controller.text.replaceAll(",", ".");
    }
    double? parsedValue = double.tryParse(controller.text);
    return parsedValue != null && _countDecimals(parsedValue) <= 2;
  }

  int _countDecimals(double value) {
    String valueString = value.toString();
    int index = valueString.indexOf('.');
    return index == -1 ? 0 : valueString.length - index - 1;
  }
}

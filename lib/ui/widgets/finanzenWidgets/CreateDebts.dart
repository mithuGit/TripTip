// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/finanzenWidgets/getMember.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';

class CreateDebts extends StatefulWidget {
  final DocumentReference selectedTrip;
  final QueryDocumentSnapshot? preview;
  const CreateDebts({
    super.key,
    required this.selectedTrip,
    this.preview,
  });

  @override
  State<CreateDebts> createState() => _CreateDebtsState();
}

class _CreateDebtsState extends State<CreateDebts> {
  final title = TextEditingController();
  final description = TextEditingController();
  final totalAmount = TextEditingController();
  final myAmount = TextEditingController();
  final List<TextEditingController> amountList = List.empty(growable: true);
  final List<String> optionList = List.empty(growable: true);
  final List<DocumentReference?> toMemberList = List.empty(growable: true);

  bool shareEqually = false;
  bool shareEquallyWithAllMembers = false;
  bool calculateMyAmountDifference = false;

  bool newBottomSheet = false;

  String currentUserName = "";

  final user = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;
  DocumentReference? selectedtrip;
  DocumentSnapshot? currentUser;

  String memberName = "";
  DocumentReference? memberNameUID;
  var member = [];

  //TODO fallbeispiele eig schon abgecheckt kann gerne jemand nochmal prüfen aber hat bei mir geklappt
  //shareeaull with all dann alle boxen full
  //shareonly with member dann auch calculate my amount gleichzeitg
  //calculate my amount dann nur diese box nix mehr
  //keine box ankreuzen
  // betrag ist nicht gleich dem total amount was passiert dann

  //create the debt in the database
  Future<void> createDebt() async {
    List<dynamic> to = [];

    for (int i = 0; i < amountList.length; i++) {
      if (amountList[i].text.isNotEmpty) {
        to.add({
          "amount": double.parse(amountList[i].text),
          "status": "open",
          "user": toMemberList[i],
        });
      }
    }

    if (title.text.isNotEmpty &&
        totalAmount.text.isNotEmpty &&
        myAmount.text.isNotEmpty) {
      await widget.selectedTrip.collection("payments").add({
        "title": title.text,
        "description": description.text,
        "amount": double.parse(totalAmount.text),
        "to": to,
        "createdBy": currentUser!.reference,
        "timestamp": DateTime.now(),
      });
    }
  }

//get the members of the trip
  Future<void> getMembers() async {
    currentUser = await firestore.collection("users").doc(user.uid).get();
    String selectedTripID =
        (currentUser!.data() as Map<String, dynamic>)["selectedtrip"];
    selectedtrip = firestore.collection("trips").doc(selectedTripID);

    member =
        ((await selectedtrip!.get()).data() as Map<String, dynamic>)["members"];
  }

//get the data for the preview container so he can look up again what he has entered and request from the other ones
  getPreviewData() async {
    if (widget.preview != null) {
      await getMembers();
      title.text = widget.preview!["title"];
      description.text = widget.preview!["description"];
      totalAmount.text = widget.preview!["amount"].toString();

      double sumForMyAmount = 0;

      for (int i = 0; i < widget.preview!["to"].length; i++) {
        if ((widget.preview!["to"][i]["user"] as DocumentReference).id !=
            user.uid) {
          var memberFromTo = await firestore
              .collection("users")
              .doc((widget.preview!["to"][i]["user"] as DocumentReference).id)
              .get();
          optionList
              .add(memberFromTo["prename"] + " " + memberFromTo["lastname"]);
          sumForMyAmount += widget.preview!["to"][i]["amount"];
          amountList.add(TextEditingController(
              text: widget.preview!["to"][i]["amount"].toString()));
        }
      }
      myAmount.text =
          (double.parse(totalAmount.text) - sumForMyAmount).toStringAsFixed(2);

      if ((sumForMyAmount / amountList.length) == double.parse(myAmount.text) &&
          widget.preview!["to"].length + 1 == member.length) {
        setState(() {
          shareEquallyWithAllMembers = true;
          shareEqually = true;
          calculateMyAmountDifference = true;
        });
      } else if (widget.preview!["to"].length + 1 != member.length) {
        if (sumForMyAmount / amountList.length == double.parse(myAmount.text)) {
          setState(() {
            shareEquallyWithAllMembers = false;
            shareEqually = true;
            calculateMyAmountDifference = true;
          });
        } else if (sumForMyAmount / amountList.length !=
            double.parse(myAmount.text)) {
          setState(() {
            shareEquallyWithAllMembers = false;
            shareEqually = false;
            calculateMyAmountDifference = true;
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getPreviewData();
  }

  //calculate the amount of money for the current user
  void calculateMyAmount() {
    double totalAmountValue = double.parse(totalAmount.text);
    double sum = 0;

    for (int i = 0; i < optionList.length; i++) {
      if (amountList[i].text.isNotEmpty) {
        sum += double.parse(amountList[i].text);
      }
    }

    double remainingAmount = totalAmountValue - sum;
    myAmount.text = ((remainingAmount * 100).ceil() / 100).toStringAsFixed(2);
  }

// To calculate the amount for all member if if checkbox the share equally wiht all
// to get the currentUserName if if press next and/or to list all member name after pressing next
  void shareEquallyWithAllMembersFunction(bool nextonly) async {
    double totalAmountValue = double.parse(totalAmount.text);

    await getMembers();

    for (int i = 0; i < member.length; i++) {
      DocumentSnapshot memberSnapshot = await member[i].get();
      String memberPrename = memberSnapshot['prename'];
      String memberLastname = memberSnapshot['lastname'];
      String memberName =
          '$memberPrename $memberLastname'; // Concatenate prename and lastname

      if (member[i].id != user.uid &&
          !optionList.contains(memberName) &&
          !nextonly) {
        if (memberName.isNotEmpty) {
          setState(() {
            optionList.add(memberName);
            toMemberList.add(member[i]);
            amountList.add(TextEditingController());
          });
        }
      } else {
        currentUserName =
            (currentUser!.data() as Map<String, dynamic>)["prename"] +
                " " +
                (currentUser!.data() as Map<String, dynamic>)["lastname"];
      }
      if (member[i].id == user.uid && nextonly) {
        if (memberName.isNotEmpty) {
          setState(() {
            currentUserName = memberName;
          });
        }
      }
    }
    if (!nextonly) {
      double diff = totalAmountValue / (optionList.length + 1);

      for (int i = 0; i < optionList.length; i++) {
        amountList[i].text = diff.toStringAsFixed(2);
      }
      myAmount.text = diff.toStringAsFixed(2);
    }
  }

// To calculate the amount for all member which the user selected   if checkbox the share equally
  void shareEquallyFunction() {
    if (shareEqually == false) {
      for (int i = 0; i < optionList.length; i++) {
        amountList[i].text = "";
      }
      myAmount.text = "";
    } else if (shareEqually == true) {
      for (int i = 0; i < optionList.length; i++) {
        amountList[i].text =
            (double.parse(totalAmount.text) / (optionList.length + 1))
                .toStringAsFixed(2);
      }
      myAmount.text = (double.parse(totalAmount.text) / (optionList.length + 1))
          .toStringAsFixed(2);
    }
  }

//build the listtile for the member list
//if user add a wrong member to the request, he can delete it with the dismissible(swipe to the left)
  Widget buildTenableListTile(int index) {
    return Dismissible(
      key: Key(optionList[index].toString() + index.toString()),
      direction: widget.preview == null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      onDismissed: (direction) {
        if (widget.preview == null) {
          setState(() {
            optionList.removeAt(index);
            amountList.removeAt(index);
          });
        }
      },
      background: Container(
        color: Colors.red,
        child: const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                "Swipe to Delete   ",
                style: Styles.buttonFontStyle,
                textAlign: TextAlign.center,
              ),
            )),
      ),
      child: ListTile(
        title: Padding(
          padding: const EdgeInsets.only(
            top: 8.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 130,
                child: Text(
                  optionList[index].toString(),
                  style: Styles.inputField,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                  width: 150,
                  height: 50,
                  child: InputField(
                    readOnly: widget.preview == null,
                    controller: amountList[index],
                    hintText: "Enter the amount",
                    obscureText: false,
                    numberField: true,
                    focusedBorderColor: const Color.fromARGB(255, 84, 113, 255),
                    borderColor: Colors.grey.shade400,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!newBottomSheet) ...[
          InputField(
              readOnly: widget.preview == null,
              controller: title,
              hintText: "Title of Payment",
              focusedBorderColor: const Color.fromARGB(255, 84, 113, 255),
              borderColor: Colors.grey.shade400,
              obscureText: false),
          const SizedBox(height: 15),
          InputField(
              readOnly: widget.preview == null,
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
                  width: 130,
                  child: InputField(
                    readOnly: widget.preview == null,
                    controller: totalAmount,
                    hintText: "Total Amount",
                    obscureText: false,
                    numberField: true,
                    focusedBorderColor: const Color.fromARGB(255, 84, 113, 255),
                    borderColor: Colors.grey.shade400,
                  )),
              Row(
                children: [
                  const Text(
                    "Share Equally with \nall Members:",
                    style: Styles.inputField,
                  ),
                  Checkbox(
                      value: shareEquallyWithAllMembers,
                      activeColor:
                          widget.preview != null ? Colors.grey : Colors.purple,
                      onChanged: (value) {
                        if (widget.preview == null) {
                          setState(() {
                            shareEquallyWithAllMembers = value!;
                            if (shareEquallyWithAllMembers == true) {
                              shareEquallyWithAllMembersFunction(false);
                              shareEqually = true;
                              calculateMyAmountDifference = true;
                            }
                          });
                        }
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
                    totalAmount.text != "" &&
                    _isNumeric(totalAmount)) {
                  shareEquallyWithAllMembersFunction(true);
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
              },
              text: "Next"),
        ] else ...[
          Container(),
        ],
        if (newBottomSheet) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetMemberButton(
                  notifier: (Member member) => {
                        setState(() {
                          if (member.isSet) memberName = member.name!;
                          memberNameUID = member.reference;
                        })
                      }),
              IconButton(
                  onPressed: () => {
                        if (widget.preview == null &&
                            optionList
                                .where((element) => element == memberName)
                                .isEmpty)
                          {
                            if (memberName.isNotEmpty)
                              {
                                setState(() {
                                  optionList.add(memberName);
                                  toMemberList.add(memberNameUID);
                                  amountList.add(TextEditingController());
                                })
                              }
                          }
                      },
                  icon: const Icon(
                    Icons.add,
                    size: 30,
                  )),
            ],
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: optionList.length,
              itemBuilder: (context, index) => buildTenableListTile(index),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Share Equally:",
                    style: Styles.inputField,
                  ),
                  Checkbox(
                      value: shareEqually,
                      activeColor:
                          widget.preview != null ? Colors.grey : Colors.purple,
                      onChanged: (value) {
                        if (widget.preview == null) {
                          setState(() {
                            shareEqually = value!;
                            if (shareEqually == false &&
                                calculateMyAmountDifference == true) {
                              calculateMyAmountDifference = false;
                            } else {
                              shareEquallyFunction();
                              shareEquallyWithAllMembers = false;
                              calculateMyAmountDifference = true;
                            }
                          });
                        }
                      }),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Calculate my Amount:", // My amount will be calculated automatically
                    style: Styles.inputField,
                  ),
                  Checkbox(
                      value: calculateMyAmountDifference,
                      activeColor:
                          widget.preview != null ? Colors.grey : Colors.purple,
                      onChanged: (value) {
                        if (widget.preview == null) {
                          setState(() {
                            calculateMyAmountDifference = value!;
                            calculateMyAmountDifference &&
                                    totalAmount.text != "" &&
                                    !shareEqually
                                ? WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                    calculateMyAmount();
                                  })
                                : myAmount.text = "";
                          });
                        }
                      }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
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
              SizedBox(
                  width: 150,
                  child: InputField(
                    readOnly: widget.preview == null,
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
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: MyButton(
                      borderColor: Colors.black,
                      textStyle: Styles.buttonFontStyleModal,
                      onTap: () {
                        setState(() {
                          newBottomSheet = false;
                        });
                      },
                      text: "Back"),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: MyButton(
                      borderColor: Colors.black,
                      textStyle: Styles.buttonFontStyleModal,
                      onTap: () => {
                            if (widget.preview == null)
                              {createDebt(), Navigator.pop(context)}
                            else if (widget.preview != null)
                              {Navigator.pop(context)}
                          },
                      text: widget.preview == null ? "Finish" : "Close"),
                ),
              ),
            ],
          ),
        ] else ...[
          Container(),
        ],
      ],
    );
  }

//check if the amount is numeric and has only 2 decimals after the comma
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

//help method to the numeric method to check the decimals
  int _countDecimals(double value) {
    String valueString = value.toString();
    int index = valueString.indexOf('.');
    return index == -1 ? 0 : valueString.length - index - 1;
  }
}

// ignore_for_file: file_names
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/paymentsWidgets/getMember.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';

// class to show the user the preview of the debt request
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
  final List<bool> memberStatusList = List.empty(growable: true);

  bool shareEqually = false;
  bool shareEquallyWithAllMembers = false;

  bool newBottomSheet = false;

  String currentUserName = "";

  final user = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;
  DocumentReference? selectedtrip;
  DocumentSnapshot? currentUser;

  String memberName = "";
  DocumentReference? memberNameUID;
  var member = [];

  bool totalAmountIsInRange = false;

  bool isitEmpty = false;

  //create the debt in the database
  Future<void> createDebt() async {
    if (amountList.isEmpty || optionList.isEmpty) {
      ErrorSnackbar.showErrorSnackbar(
          context, "Please fill at least one member to the request");
      return;
    }
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
        "paymentType": shareEquallyWithAllMembers == true
            ? "shareEquallyWithAllMembers"
            : shareEqually == true
                ? "shareEqually"
                : "shareOnlyWithMember",
      });
    }
  }

  // get the members of the trip
  Future<void> getMembers() async {
    currentUser = await firestore.collection("users").doc(user.uid).get();
    String selectedTripID =
        (currentUser!.data() as Map<String, dynamic>)["selectedtrip"];
    selectedtrip = firestore.collection("trips").doc(selectedTripID);

    member =
        ((await selectedtrip!.get()).data() as Map<String, dynamic>)["members"];
  }

  // get the data for the preview container so he can look up again what he has entered and request from the other ones
  Future<void> getPreviewData() async {
    if (widget.preview != null) {
      nextButtonToGetMember();
      title.text = widget.preview!["title"];
      description.text = widget.preview!["description"];
      totalAmount.text = widget.preview!["amount"].toString();

      if (widget.preview!["paymentType"] == "shareEquallyWithAllMembers") {
        setState(() {
          shareEquallyWithAllMembers = true;
        });
      } else if (widget.preview!["paymentType"] == "shareEqually") {
        setState(() {
          shareEqually = true;
        });
      }
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

          bool ispaid = widget.preview!["to"][i]["status"] == "paid";
          memberStatusList.add(ispaid);
          sumForMyAmount += widget.preview!["to"][i]["amount"];
          amountList.add(TextEditingController(
              text: widget.preview!["to"][i]["amount"].toString()));
          //(checkstatuss ? "paid" : "open")));
        }
      }

      myAmount.text =
          (double.parse(totalAmount.text) - sumForMyAmount).toStringAsFixed(2);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.preview != null) getPreviewData();
  }

  // calculate the amount of money for the current user
  void calculateMyAmount() {
    double totalAmountValue = double.parse(totalAmount.text);
    double sum = 0;

    for (int i = 0; i < optionList.length; i++) {
      if (amountList[i].text.isNotEmpty) {
        sum += double.parse(amountList[i].text);
      }
    }
    double remainingAmount = totalAmountValue - sum;
    myAmount.text = remainingAmount.toStringAsFixed(2);
  }

  // get the current user name by pressing the next button
  void nextButtonToGetMember() async {
    await getMembers();
    if (member.length == 1 && member[0].id == user.uid) {
      setState(() {
        isitEmpty = true;
      });
    }

    for (int i = 0; i < member.length; i++) {
      if (member[i].id == user.uid) {
        currentUserName =
            (currentUser!.data() as Map<String, dynamic>)["prename"] +
                " " +
                (currentUser!.data() as Map<String, dynamic>)["lastname"];
      }
    }
    calculateMyAmount();
  }

  // share the amount equally with all members => only when nextonly is false
  void shareEquallyWithAllMembersFunction() async {
    double totalAmountValue = double.parse(totalAmount.text);

    await getMembers();

    for (int i = 0; i < member.length; i++) {
      DocumentSnapshot memberSnapshot = await member[i].get();
      String memberPrename = memberSnapshot['prename'];
      String memberLastname = memberSnapshot['lastname'];
      String memberName =
          '$memberPrename $memberLastname'; // Concatenate prename and lastname

      if (member[i].id != user.uid && !optionList.contains(memberName)) {
        if (memberName.isNotEmpty) {
          setState(() {
            optionList.add(memberName);
            toMemberList.add(member[i]);
            amountList.add(TextEditingController());
          });
        }
      }
    }
    double diff = totalAmountValue / (optionList.length + 1);

    for (int i = 0; i < optionList.length; i++) {
      amountList[i].text = ((diff * 100).ceil() / 100).toStringAsFixed(2);
    }
    myAmount.text = diff.toStringAsFixed(2);

    calculateMyAmount();
  }

  // To calculate the amount for all member which the user selected   if checkbox the share equally
  void shareEquallyFunction() {
    if (shareEqually == false) {
      for (int i = 0; i < optionList.length; i++) {
        amountList[i].text = "";
      }
      myAmount.text = "";
    } else if (shareEqually == true) {
      double diff = double.parse(totalAmount.text) / (optionList.length + 1);
      for (int i = 0; i < optionList.length; i++) {
        amountList[i].text = ((diff * 100).ceil() / 100).toStringAsFixed(2);
      }
      myAmount.text = diff.toStringAsFixed(2);
      calculateMyAmount();
    }
  }

// build the listtile for the member list
// if user add a wrong member to the request, he can delete it with the dismissible(swipe to the left)
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
            toMemberList.removeAt(index);
            calculateMyAmount();
          });
        }
      },
      background: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11.0),
            color: Colors.red,
          ),
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
      ),
      child: ListTile(
        title: Padding(
          padding: const EdgeInsets.all(
            4.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.28,
                child: Text(
                  optionList[index].toString(),
                  style: Styles.inputField,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                  width: 130,
                  height: 50,
                  child: InputField(
                      textAlignCenter: true,
                      readOnly: widget.preview != null,
                      controller: amountList[index],
                      hintText: "Enter the amount",
                      obscureText: false,
                      numberField: true,
                      focusedBorderColor:
                          const Color.fromARGB(255, 84, 113, 255),
                      borderColor: widget.preview == null
                          ? Colors.grey.shade400
                          : (memberStatusList[index] == true
                              ? Colors.green
                              : Colors.red))),
              const SizedBox(
                width: 15,
              ),
              if (widget.preview == null) const Icon(Icons.drag_handle),
              if (widget.preview != null)
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.14,
                  child: Text(
                    memberStatusList[index] == true ? "paid" : "unpaid",
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w500,
                        color: memberStatusList[index] == true
                            ? Colors.green
                            : Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalAmountValue = 0;
    for (var element in amountList) {
      element.addListener(() {
        if (element.text.isNotEmpty) {
          if (element.text.contains(",")) {
            element.text = element.text.replaceAll(",", ".");
          }
          if (_isNumeric(element)) {
            double elementValue = double.parse(element.text);
            if (elementValue < 0) {
              element.text = "0";
            }
            for (var element2 in amountList) {
              if (element2.text.isNotEmpty) {
                totalAmountValue += double.parse(element2.text);
              }
            }
            setState(() {
              if (totalAmountValue.compareTo(double.parse(totalAmount.text)) >
                  1) {
                ErrorSnackbar.showErrorSnackbar(
                    context, "The total amount is exceeded");
              }
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              calculateMyAmount();
            });
          }
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            calculateMyAmount();
          });
        }
      });
    }
    return Column(
      children: [
        if (!newBottomSheet) ...[
          const SizedBox(height: 10),
          InputField(
              readOnly: widget.preview != null,
              controller: title,
              hintText: "Title of Payment",
              focusedBorderColor: const Color.fromARGB(255, 84, 113, 255),
              borderColor: Colors.grey.shade400,
              obscureText: false),
          const SizedBox(height: 20),
          InputField(
              readOnly: widget.preview != null,
              controller: description,
              hintText: "Description of Payment",
              focusedBorderColor: const Color.fromARGB(255, 84, 113, 255),
              borderColor: Colors.grey.shade400,
              multiline: true,
              obscureText: false),
          const SizedBox(height: 20),
          InputField(
            readOnly: widget.preview != null,
            controller: totalAmount,
            hintText: "Enter the total amount",
            obscureText: false,
            numberField: true,
            focusedBorderColor: const Color.fromARGB(255, 84, 113, 255),
            borderColor: Colors.grey.shade400,
          ),
          const SizedBox(height: 25),
          MyButton(
              borderColor: Colors.black,
              textStyle: Styles.buttonFontStyleModal,
              onTap: () {
                if (title.text != "" &&
                    totalAmount.text != "" &&
                    _isNumeric(totalAmount)) {
                  nextButtonToGetMember();
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
          if (widget.preview == null && !isitEmpty)
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
                    onPressed: () {
                      context.push("/gameChooser");
                    },
                    icon: const Icon(Icons.games, size: 30),
                    color: Colors.purpleAccent),
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
                                    calculateMyAmount();
                                  })
                                }
                            }
                        },
                    icon: const Icon(
                      Icons.add,
                      size: 30,
                    )),
              ],
            )
          else ...[
            Container(),
          ],
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: optionList.length,
              itemBuilder: (context, index) => buildTenableListTile(index),
            ),
          ),
          CheckboxListTile(
            title: const Text(
              "Share Equally",
              style: Styles.inputField,
            ),
            subtitle: const Text(
              "Please select the members you want to share with",
              style: TextStyle(fontSize: 12),
            ),
            value: shareEqually,
            checkboxShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            activeColor:
                widget.preview != null ? Colors.grey[300] : Colors.purple,
            tileColor: Colors.white,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding:
                const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
            onChanged: widget.preview == null
                ? (value) {
                    setState(() {
                      shareEqually = value!;
                      if (shareEqually == true) {
                        shareEquallyFunction();
                        shareEquallyWithAllMembers = false;
                      }
                    });
                  }
                : null,
          ),
          CheckboxListTile(
            value: shareEquallyWithAllMembers,
            title: const Text(
              "Share Equally All",
              style: Styles.inputField,
            ),
            subtitle: const Text(
              "All members will be selected with equally amount",
              style: TextStyle(fontSize: 12),
            ),
            checkboxShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            activeColor:
                widget.preview != null ? Colors.grey[300] : Colors.purple,
            tileColor: Colors.white,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding:
                const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
            onChanged: widget.preview == null
                ? (value) {
                    setState(() {
                      shareEquallyWithAllMembers = value!;
                      if (shareEquallyWithAllMembers == true) {
                        shareEquallyWithAllMembersFunction();
                        shareEqually = false;
                      }
                    });
                  }
                : null,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.45,
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
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: InputField(
                    textAlignCenter: true,
                    readOnly: widget.preview != null,
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

// check if the amount is numeric and has only 2 decimals after the comma
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

// help method to the numeric method to check the decimals
  int _countDecimals(double value) {
    String valueString = value.toString();
    int index = valueString.indexOf('.');
    return index == -1 ? 0 : valueString.length - index - 1;
  }
}

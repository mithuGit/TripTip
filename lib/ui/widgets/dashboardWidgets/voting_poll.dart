import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VotingPoll extends StatefulWidget {
  final String title;
  const VotingPoll({super.key, required this.title});

  @override
  State<VotingPoll> createState() => _VotingPollState();
}

class _VotingPollState extends State<VotingPoll> {
  bool isClicked = false;
  int? numberOfVoters;

  @override
  void initState() {
    super.initState();
    getNumberOfVoters();
  }

  Future<void> getNumberOfVoters() async {
    final member = await FirebaseFirestore.instance
        .collection("trips")
        .doc('OYcU9dTsakHTtYs5k5uw')
        .get()
        .then((value) => value.data()!["members"].length);
    setState(() {
      numberOfVoters = member;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isClicked = !isClicked;
            });
            //print(numberOfVoters);
          },
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: isClicked
                ? Image.asset("assets/votingbutton_pic/on.png")
                : Image.asset("assets/votingbutton_pic/off.png"),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Stack(children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.title,
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white)),
                    const Text("1/5", //TODO; hier das ändern
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 2),
                LinearProgressIndicator(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  minHeight: 5,
                  value: isClicked ? 0.2 : 0.0,
                  backgroundColor: Colors.white,
                  color: const Color.fromARGB(255, 86, 153, 123),
                ),
              ],
            ),
          ]),
        )
      ],
    );
  }
}

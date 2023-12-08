import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/views/main_pages/profile.dart';
import 'package:internet_praktikum/ui/widgets/inputfield_password_or_icon.dart';


class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Colors.grey[300], 
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              ); // lieber hier mit Get.to arbeiten weil bei ProfilePage oben links ein back button entsteht
            },
            icon: const Icon(Icons.arrow_back)),
        title: const Text(
            'Edit Profile'), /*style: Theme.of(context).textTheme.headlineSmall,*/
      ),
      body: SingleChildScrollView(
          child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: const Image(
                          image: AssetImage(
                              'assets/google_logo.jpg'))),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.red, //andere farbe wählen hier 
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            Form(
                child: Column(
              children: [
              //  TextFormField(
              //    decoration: const InputDecoration(
              //      label: Text('Full Name'),
              //      prefixIcon: Icon(Icons.person),
              //    ),
              //  ),
              
                const SizedBox(height: 20),
                

                // lieber so wie Login Page
                InputFieldPasswortOrIcon(
                    controller: TextEditingController(),
                    hintText: 'Full Name',
                    obscureText: true,
                    icon: Icons.person,
                    eyeCheckerStatus: false,
                    useSuffixIcon: false,
                    ),

                // oder so (finde so besser)
                //TextFormField(
                //  decoration: const InputDecoration(
                //    label: Text('Email'),
                //    prefixIcon: Icon(Icons.email),
                //  ),
                //),
                const SizedBox(height: 20),
                InputFieldPasswortOrIcon(
                    controller: TextEditingController(),
                    hintText: 'Email',
                    obscureText: true,
                    icon:Icons.email,
                    eyeCheckerStatus: false,
                    useSuffixIcon: false,
                    ),
                //TextFormField(
                //  decoration: const InputDecoration(
                //    label: Text('Phone Number'),
                //    prefixIcon: Icon(Icons.phone),
                //  ),
                //),
                const SizedBox(height: 20),
                InputFieldPasswortOrIcon(
                    controller: TextEditingController(),
                    hintText: 'Phone Number',
                    obscureText: true,
                    icon:Icons.phone,
                    eyeCheckerStatus: false,
                    useSuffixIcon: false,
                    ),
                //TextFormField(
                //  decoration: const InputDecoration(
                //    label: Text('Password'),
                //    prefixIcon: Icon(Icons.fingerprint),
                //  ),
                //),

                const SizedBox(height: 20), // davor war 40
                InputFieldPasswortOrIcon(
                    controller: TextEditingController(),
                    hintText: 'Password',
                    obscureText: true,
                    icon:Icons.password,
                    eyeCheckerStatus: false,
                    useSuffixIcon: false,
                    ),

                // lieber so wie Login Page
                //MyButton(text: 'Save Changes', onTap: () {},),

                // oder so (finde so besser)
                SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfilePage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            side: BorderSide.none,
                            shape: const StadiumBorder()),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(color: Colors.white),
                        )))
              ],
            ))
          ],
        ),
      )),
    );
  }
}

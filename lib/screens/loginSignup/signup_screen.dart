// import 'package:flutter/material.dart';
//
// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});
//
//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }
//
// class _SignupScreenState extends State<SignupScreen> {
//   bool isInfluencer = true;
//   bool isSignUpTab = true;
//
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFE8E4F3),
//       body: Stack(
//         children: [
//           // BACKGROUND IMAGE WITH 20% OPACITY
//           Opacity(
//             opacity: 0.20,
//             child: Container(
//               decoration: const BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage("assets/images/splashbg.jpg"),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ),
//
//           // MAIN CONTENT
//           SafeArea(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const SizedBox(height: 60),
//
//                     // LOGO
//                     Image.asset(
//                       "assets/images/logo.png",
//                       height: 80,
//                     ),
//
//                     const SizedBox(height: 40),
//
//                     // "I am a" TEXT
//                     const Text(
//                       "I am a",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//
//                     const SizedBox(height: 16),
//
//                     // INFLUENCER / BRAND TOGGLE
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         // INFLUENCER BUTTON
//                         GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               isInfluencer = true;
//                             });
//                           },
//                           child: Container(
//                             width: 150,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             decoration: BoxDecoration(
//                               gradient: isInfluencer
//                                   ? const LinearGradient(
//                                 colors: [
//                                   Color(0xFFB798F0),
//                                   Color(0xFF9F7AEA),
//                                 ],
//                               )
//                                   : null,
//                               color: isInfluencer ? null : Colors.white,
//                               borderRadius: BorderRadius.circular(25),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 "INFLUENCER",
//                                 style: TextStyle(
//                                   color: isInfluencer ? Colors.white : Colors.black54,
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//
//                         const SizedBox(width: 16),
//
//                         // BRAND BUTTON
//                         GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               isInfluencer = false;
//                             });
//                           },
//                           child: Container(
//                             width: 150,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             decoration: BoxDecoration(
//                               gradient: !isInfluencer
//                                   ? const LinearGradient(
//                                 colors: [
//                                   Color(0xFFB798F0),
//                                   Color(0xFF9F7AEA),
//                                 ],
//                               )
//                                   : null,
//                               color: !isInfluencer ? null : Colors.white,
//                               borderRadius: BorderRadius.circular(25),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 "BRAND",
//                                 style: TextStyle(
//                                   color: !isInfluencer ? Colors.white : Colors.black54,
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     const SizedBox(height: 30),
//
//                     // LOGIN / SIGN UP TOGGLE
//                     Container(
//                       padding: const EdgeInsets.all(4),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.5),
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                       child: Row(
//                         children: [
//                           // LOGIN TAB
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   isSignUpTab = false;
//                                 });
//                               },
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(vertical: 12),
//                                 decoration: BoxDecoration(
//                                   color: !isSignUpTab ? Colors.white : Colors.transparent,
//                                   borderRadius: BorderRadius.circular(25),
//                                 ),
//                                 child: Center(
//                                   child: Text(
//                                     "LOGIN",
//                                     style: TextStyle(
//                                       color: !isSignUpTab ? Colors.black : Colors.black54,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//
//                           // SIGN UP TAB
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   isSignUpTab = true;
//                                 });
//                               },
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(vertical: 12),
//                                 decoration: BoxDecoration(
//                                   color: isSignUpTab ? Colors.white : Colors.transparent,
//                                   borderRadius: BorderRadius.circular(25),
//                                 ),
//                                 child: Center(
//                                   child: Text(
//                                     "SIGN UP",
//                                     style: TextStyle(
//                                       color: isSignUpTab ? Colors.black : Colors.black54,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 30),
//
//                     // FORM FIELDS (Show only in Sign Up mode)
//                     if (isSignUpTab) ...[
//                       // FULL NAME
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Full name",
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.7),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: TextField(
//                               controller: nameController,
//                               decoration: const InputDecoration(
//                                 prefixIcon: Icon(Icons.person_outline),
//                                 hintText: "Ram Shrestha",
//                                 border: InputBorder.none,
//                                 contentPadding: EdgeInsets.symmetric(
//                                   horizontal: 16,
//                                   vertical: 14,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       const SizedBox(height: 20),
//                     ],
//
//                     // EMAIL
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Email",
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.7),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: TextField(
//                             controller: emailController,
//                             decoration: const InputDecoration(
//                               prefixIcon: Icon(Icons.email_outlined),
//                               hintText: "your@email.com",
//                               border: InputBorder.none,
//                               contentPadding: EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 14,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     // PASSWORD
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "password",
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.7),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: TextField(
//                             controller: passwordController,
//                             obscureText: true,
//                             decoration: const InputDecoration(
//                               prefixIcon: Icon(Icons.lock_outline),
//                               hintText: "password",
//                               border: InputBorder.none,
//                               contentPadding: EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 14,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     const SizedBox(height: 30),
//
//                     // SIGN UP / LOGIN BUTTON
//                     Container(
//                       width: double.infinity,
//                       height: 50,
//                       decoration: const BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             Color(0xFFB798F0),
//                             Color(0xFF9F7AEA),
//                           ],
//                         ),
//                         borderRadius: BorderRadius.all(Radius.circular(30)),
//                       ),
//                       child: TextButton(
//                         onPressed: () {
//                           if (isSignUpTab) {
//                             // Handle Sign Up
//                             Navigator.pushNamed(context, '/home');
//                           } else {
//                             // Handle Login
//                             Navigator.pushNamed(context, '/home');
//                           }
//                         },
//                         child: Text(
//                           isSignUpTab ? "Sign Up" : "Login",
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     // OR CONTINUE WITH
//                     const Row(
//                       children: [
//                         Expanded(child: Divider()),
//                         Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 16),
//                           child: Text(
//                             "or continue with",
//                             style: TextStyle(
//                               color: Colors.black54,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                         Expanded(child: Divider()),
//                       ],
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     // SOCIAL LOGIN BUTTONS
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         // GOOGLE BUTTON
//                         Container(
//                           width: 140,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(25),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Image.asset(
//                                 "assets/images/google_icon.png",
//                                 height: 20,
//                               ),
//                               const SizedBox(width: 8),
//                               const Text(
//                                 "Google",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         const SizedBox(width: 16),
//
//                         // FACEBOOK BUTTON
//                         Container(
//                           width: 140,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(25),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Image.asset(
//                                 "assets/images/facebook_icon.png",
//                                 height: 20,
//                               ),
//                               const SizedBox(width: 8),
//                               const Text(
//                                 "Facebook",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     const SizedBox(height: 40),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isInfluencer = true; // Toggle between Influencer and Brand
  bool isSignUpTab = false; // false = Login, true = Sign Up

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E4F3),
      body: Stack(
        children: [
          // BACKGROUND IMAGE WITH 20% OPACITY
          Opacity(
            opacity: 0.20,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("/Users/shreetikashrestha/Desktop/influcollab_app/lib/assets/images/splashbg.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // MAIN CONTENT
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20), // rounded corners
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          "/Users/shreetikashrestha/Desktop/influcollab_app/lib/assets/images/logo.png",
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 2),

                    const SizedBox(height: 20),

                    // "I am a" TEXT
                    const Text(
                      "I am a",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // INFLUENCER / BRAND TOGGLE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // INFLUENCER BUTTON
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isInfluencer = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: isInfluencer
                                    ? const LinearGradient(
                                  colors: [
                                    Color(0xFFB798F0),
                                    Color(0xFF9F7AEA),
                                  ],
                                )
                                    : null,
                                color: isInfluencer ? null : Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Center(
                                child: Text(
                                  "INFLUENCER",
                                  style: TextStyle(
                                    color: isInfluencer ? Colors.white : Colors.black54,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // BRAND BUTTON
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isInfluencer = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: !isInfluencer
                                    ? const LinearGradient(
                                  colors: [
                                    Color(0xFFB798F0),
                                    Color(0xFF9F7AEA),
                                  ],
                                )
                                    : null,
                                color: !isInfluencer ? null : Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Center(
                                child: Text(
                                  "BRAND",
                                  style: TextStyle(
                                    color: !isInfluencer ? Colors.white : Colors.black54,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // LOGIN / SIGN UP TOGGLE
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          // LOGIN TAB
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSignUpTab = false;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !isSignUpTab ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: !isSignUpTab
                                      ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                      : [],
                                ),
                                child: Center(
                                  child: Text(
                                    "LOGIN",
                                    style: TextStyle(
                                      color: !isSignUpTab ? Colors.black : Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // SIGN UP TAB
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSignUpTab = true;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSignUpTab ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: isSignUpTab
                                      ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                      : [],
                                ),
                                child: Center(
                                  child: Text(
                                    "SIGN UP",
                                    style: TextStyle(
                                      color: isSignUpTab ? Colors.black : Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // FORM FIELDS (Show Full Name only in Sign Up mode)
                    if (isSignUpTab) ...[
                      // FULL NAME
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Full name",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.person_outline),
                                hintText: "Ram Shrestha",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],

                    // EMAIL
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Email",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                          ),
                          child: TextField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.email_outlined),
                              hintText: "your@email.com",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // PASSWORD
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "password",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                          ),
                          child: TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.lock_outline),
                              hintText: "password",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // FORGET PASSWORD (only show in Login mode)
                    if (!isSignUpTab) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            // Handle forgot password
                          },
                          child: const Text(
                            "FORGET PASSWORD?",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9F7AEA),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),

                    // LOGIN / SIGN UP BUTTON
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFB798F0),
                            Color(0xFF9F7AEA),
                          ],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      child: TextButton(
                        onPressed: () {
                          if (isSignUpTab) {
                            // Handle Sign Up
                            Navigator.pushNamed(context, '/home');
                          } else {
                            // Handle Login
                            Navigator.pushNamed(context, '/home');
                          }
                        },
                        child: Text(
                          isSignUpTab ? "Sign Up" : "LOG IN",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // OR CONTINUE WITH
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "or continue with",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // SOCIAL LOGIN BUTTONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // GOOGLE BUTTON
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
                                const SizedBox(width: 8),
                                const Text(
                                  "Google",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // FACEBOOK BUTTON
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.facebook, size: 24, color: Colors.blue),
                                const SizedBox(width: 8),
                                const Text(
                                  "Facebook",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
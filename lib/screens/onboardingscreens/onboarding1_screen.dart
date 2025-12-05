// import 'package:flutter/material.dart';
//
// class OnboardingScreen1 extends StatefulWidget {
//   const OnboardingScreen1({super.key});
//
//   @override
//   State<OnboardingScreen1> createState() => _OnboardingScreen1State();
// }
//
// class _OnboardingScreen1State extends State<OnboardingScreen1> {
//   final TextEditingController _summaryController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // BACKGROUND IMAGE WITH 20% OPACITY
//           Opacity(
//             opacity: 0.20,
//             child: Container(
//               decoration: const BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage("/Users/shreetikashrestha/Desktop/influcollab_app/lib/assets/images/splashbg.jpg"),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ),
//
//           // MAIN CONTENT
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 10),
//
//                   // BACK BUTTON
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: const Icon(Icons.arrow_back, size: 26),
//                   ),
//
//                   const SizedBox(height: 40),
//
//                   // TITLE
//                   const Text(
//                     "SUMMARIZE YOURSELF, THIS IS THE\nTITLE SHOWN ON YOUR PROFILE",
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//
//                   const SizedBox(height: 30),
//
//                   // SUMMARY TEXTFIELD
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.6),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: TextField(
//                       controller: _summaryController,
//                       decoration: const InputDecoration(
//                         contentPadding:
//                         EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                         border: InputBorder.none,
//                         hintText: "Write a short title...",
//                       ),
//                     ),
//                   ),
//
//                   const Spacer(),
//
//                   // CONTINUE BUTTON
//                   Container(
//                     width: double.infinity,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [
//                           Color(0xFFB798F0),
//                           Color(0xFF9F7AEA),
//                         ],
//                       ),
//                       borderRadius: BorderRadius.all(Radius.circular(30)),
//                     ),
//                     child: TextButton(
//                       onPressed: () {
//                         // TODO → Go to next screen
//                       },
//                       child: const Text(
//                         "Continue",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 40),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'onboarding2_screen.dart';

class OnboardingScreen1 extends StatefulWidget {
  const OnboardingScreen1({super.key});

  @override
  State<OnboardingScreen1> createState() => _OnboardingScreen1State();
}

class _OnboardingScreen1State extends State<OnboardingScreen1> {
  final TextEditingController _summaryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // BACK BUTTON
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 26),
                  ),

                  const SizedBox(height: 40),

                  // TITLE
                  const Text(
                    "SUMMARIZE YOURSELF, THIS IS THE\nTITLE SHOWN ON YOUR PROFILE",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // SUMMARY TEXTFIELD
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _summaryController,
                      decoration: const InputDecoration(
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: InputBorder.none,
                        hintText: "Write a short title...",
                      ),
                    ),
                  ),

                  const Spacer(),

                  // CONTINUE BUTTON
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFB798F0),
                          Color(0xFF9F7AEA),
                        ],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OnboardingScreen2(),
                          ),
                        );
                      },
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

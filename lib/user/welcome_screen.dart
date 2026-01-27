import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F1A3D), // Navy blue
              Color(0xFF0F1A3D),
              Color(0xFF2E5077),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              children: [
                const Spacer(flex: 3),

                /// ---------------- LOGO & BRANDING ----------------
                Column(
                  children: [
                    // Container(
                    //   width: 100,
                    //   height: 100,
                    //   decoration: BoxDecoration(
                    //     shape: BoxShape.circle,
                    //     color: Colors.white,
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: Colors.black.withOpacity(0.1),
                    //         blurRadius: 30,
                    //         offset: const Offset(0, 10),
                    //       ),
                    //     ],
                    //   ),
                    const SizedBox(height: 30),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A6FFF), Color(0xFF00C897)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A6FFF).withOpacity(0.4),
                          blurRadius: 25,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Background circles
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        // Main icon
                        const Center(
                          child: Icon(
                            Icons.eco,
                            color: Colors.white,
                            size: 50,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        // Small city icon
                        // Positioned(
                        //   bottom: 20,
                        //   right: 20,
                        //   child: Container(
                        //     width: 25,
                        //     height: 25,
                        //     decoration: BoxDecoration(
                        //       color: Colors.white,
                        //       shape: BoxShape.circle,
                        //     ),
                        //     child: const Icon(
                        //       Icons.location_city,
                        //       color: Color(0xFF4A6FFF),
                        //       size: 15,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                    //   child: const Icon(
                    //     Icons.domain_rounded,
                    //     color: Color(0xFF0A1F44),
                    //     size: 50,
                    //   ),
                    // ),
                    const SizedBox(height: 28),
                    Text(
                      'CityCare',
                      style: GoogleFonts.inter(
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Empowering citizens to improve\ntheir communities',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 4),

                /// ---------------- FEATURES ----------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFeature(Icons.report_problem_rounded, 'Report'),
                    _buildFeature(Icons.track_changes_rounded, 'Track'),
                    _buildFeature(Icons.verified_rounded, 'Resolve'),
                  ],
                ),

                const Spacer(flex: 3),

                /// ---------------- CTA BUTTONS ----------------
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0A1F44),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Create Account',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Already have an account? Sign in',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:city_care/services/auth_service.dart';
import 'package:city_care/services/payment_service.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // 🔴 REAL-TIME VALIDATION VARIABLES
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _phoneError;
  
  bool _isLoading = false;
  bool _acceptTerms = false;
  bool _isPasswordVisible = false;
  String? _selectedPaymentMethod;

  // Payment methods
  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'Credit Card', 'icon': Icons.credit_card, 'fee': 500},
    {'name': 'PayPal', 'icon': Icons.payment, 'fee': 500},
    {'name': 'JazzCash', 'icon': Icons.phone_android, 'fee': 500},
    {'name': 'EasyPaisa', 'icon': Icons.mobile_friendly, 'fee': 500},
  ];

  // 🔴 REAL-TIME VALIDATION FUNCTIONS
  void _validateName(String value) {
    setState(() {
      if (value.isEmpty) {
        _nameError = 'Please enter your full name';
      } else if (RegExp(r'[0-9]').hasMatch(value)) {
        _nameError = 'Name cannot contain numbers';
      } else if (value.length < 3) {
        _nameError = 'Name must be at least 3 characters';
      } else {
        _nameError = null;
      }
    });
  }

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = 'Please enter your email';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        _emailError = 'Please enter a valid email (e.g., name@example.com)';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword(String value) {
  setState(() {
    if (value.isEmpty) {
      _passwordError = 'Please enter a password';
    } else if (value.length < 6) {
      _passwordError = 'Password must be at least 6 characters';
    } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
      _passwordError = 'Password must contain at least one uppercase letter';
    } else if (!RegExp(r'[0-9]').hasMatch(value)) {
      _passwordError = 'Password must contain at least one number';
    } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      _passwordError = 'Password must contain at least one special character (!@#\$%^&*)';
    } else {
      _passwordError = null;
    }
  });
}

  void _validatePhone(String value) {
    setState(() {
      if (value.isEmpty) {
        _phoneError = 'Please enter your phone number';
      } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
        _phoneError = 'Phone number can only contain digits';
      } else if (value.length < 10) {
        _phoneError = 'Phone number must be at least 10 digits';
      } else if (value.length > 11) {
        _phoneError = 'Phone number cannot exceed 11 digits';
      } else {
        _phoneError = null;
      }
    });
  }

  // Check if form is valid for submission
  bool _isFormValid() {
    return _nameError == null && 
           _emailError == null && 
           _passwordError == null && 
           _phoneError == null &&
           _nameController.text.isNotEmpty &&
           _emailController.text.isNotEmpty &&
           _passwordController.text.isNotEmpty &&
           _phoneController.text.isNotEmpty &&
           _acceptTerms &&
           _selectedPaymentMethod != null;
  }

  
// 🔴 UPDATED REGISTER METHOD WITH PAYMENT (SAME VALIDATION, ADDED PAYMENT)
  Future<void> _register() async {
    if (!_isFormValid()) {
      // Show specific error messages (YOUR EXISTING VALIDATION)
      if (_nameError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_nameError!), backgroundColor: Colors.red),
        );
      } else if (_emailError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_emailError!), backgroundColor: Colors.red),
        );
      } else if (_passwordError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_passwordError!), backgroundColor: Colors.red),
        );
      } else if (_phoneError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_phoneError!), backgroundColor: Colors.red),
        );
      } else if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please accept terms and conditions'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (_selectedPaymentMethod == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a payment method'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 🔴 STEP 1: PROCESS PAYMENT FIRST (NEW)
      print("=" * 50);
      print("🔵 PROCESSING PAYMENT");
      
      final paymentResult = await PaymentService.makePayment(
        amount: 50000, // Rs. 500 in paise
        currency: 'inr',  // 'inr' for India, 'pkr' for Pakistan, 'usd' for USA
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
      );

      if (!paymentResult['success']) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${paymentResult['message']}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 🔴 STEP 2: PAYMENT SUCCESSFUL - CREATE USER (YOUR EXISTING CODE)
      final result = await AuthService().registerWithEmail(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phone: _phoneController.text.trim(),
        paymentMethod: _selectedPaymentMethod!,
        registrationFee: 500.0,
        profileImageUrl: '', // 👈 YEH PASS KARO (OPTIONAL)
      );

      if (result['success'] == true && mounted) {
        // 🔴 STEP 3: SAVE PAYMENT INFO TO FIRESTORE (NEW)
        User? user = result['user'];
        
        await FirebaseFirestore.instance.collection('payments').add({
          'userId': user?.uid,
          'userEmail': _emailController.text.trim(),
          'userName': _nameController.text.trim(),
          'amount': 500,
          'currency': 'INR',
          'paymentMethod': _selectedPaymentMethod,
          'stripePaymentIntentId': paymentResult['paymentIntent']?['id'],
          'status': 'completed',
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() => _isLoading = false);

        // YOUR EXISTING SUCCESS MESSAGE
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Payment successful! Registration complete! Please login.',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        
        // ✅ GO TO LOGIN SCREEN
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Registration failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("❌ EXCEPTION: $e");
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1A3D),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                const SizedBox(height: 20),
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, 
                    color: Colors.white, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),

                // Header
                const SizedBox(height: 10),
                Text(
                  'Create Account',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join City Care community. Registration requires a small fee for premium features.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 40),

                // Payment Notice Card (UPDATED TEXT)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A6FFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF4A6FFF).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, 
                        color: Color(0xFF4A6FFF), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Registration Fee: Rs. 500 (one-time)\nSecure payment via Stripe',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Form Card (YOUR EXACT UI - NO CHANGES)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔴 FULL NAME FIELD (YOUR EXACT CODE)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            onChanged: _validateName,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: const Color(0xFF0F1A3D),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Full name',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color(0xFF0F1A3D).withOpacity(0.6),
                              ),
                              prefixIcon: Icon(Icons.person_outline,
                                color: const Color(0xFF0F1A3D).withOpacity(0.7)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _nameError != null ? Colors.red : Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _nameError != null ? Colors.red : Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _nameError != null ? Colors.red : const Color(0xFF4A6FFF),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            ),
                          ),
                          if (_nameError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 12),
                              child: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.red, size: 16),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _nameError!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 🔴 EMAIL FIELD 
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            onChanged: _validateEmail,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: const Color(0xFF0F1A3D),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color(0xFF0F1A3D).withOpacity(0.6),
                              ),
                              prefixIcon: Icon(Icons.email_outlined,
                                color: const Color(0xFF0F1A3D).withOpacity(0.7)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _emailError != null ? Colors.red : Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _emailError != null ? Colors.red : Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _emailError != null ? Colors.red : const Color(0xFF4A6FFF),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            ),
                          ),
                          if (_emailError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 12),
                              child: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.red, size: 16),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _emailError!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 🔴 PASSWORD FIELD 
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _passwordController,
                            onChanged: _validatePassword,
                            obscureText: !_isPasswordVisible,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: const Color(0xFF0F1A3D),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color(0xFF0F1A3D).withOpacity(0.6),
                              ),
                              prefixIcon: Icon(Icons.lock_outline,
                                color: const Color(0xFF0F1A3D).withOpacity(0.7)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: const Color(0xFF0F1A3D).withOpacity(0.6),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _passwordError != null ? Colors.red : Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _passwordError != null ? Colors.red : Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _passwordError != null ? Colors.red : const Color(0xFF4A6FFF),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            ),
                          ),
                          if (_passwordError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 12),
                              child: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.red, size: 16),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _passwordError!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 🔴 PHONE FIELD 
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _phoneController,
                            onChanged: _validatePhone,
                            keyboardType: TextInputType.phone,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: const Color(0xFF0F1A3D),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color(0xFF0F1A3D).withOpacity(0.6),
                              ),
                              prefixIcon: Icon(Icons.phone_android,
                                color: const Color(0xFF0F1A3D).withOpacity(0.7)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _phoneError != null ? Colors.red : Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _phoneError != null ? Colors.red : Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _phoneError != null ? Colors.red : const Color(0xFF4A6FFF),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            ),
                          ),
                          if (_phoneError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 12),
                              child: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.red, size: 16),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _phoneError!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Payment Method Section 
                      Text(
                        'Select Payment Method',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F1A3D),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Payment Methods Grid 
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _paymentMethods.length,
                        itemBuilder: (context, index) {
                          final method = _paymentMethods[index];
                          final isSelected = _selectedPaymentMethod == method['name'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPaymentMethod = method['name'];
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF4A6FFF).withOpacity(0.1)
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF4A6FFF)
                                      : Colors.grey[300]!,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    method['icon'],
                                    color: const Color(0xFF4A6FFF),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          method['name'],
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF0F1A3D),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          'Fee: Rs. ${method['fee']}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Terms and Conditions 
                      Row(
                        children: [
                          Checkbox(
                            value: _acceptTerms,
                            onChanged: (value) {
                              setState(() {
                                _acceptTerms = value!;
                              });
                            },
                            activeColor: const Color(0xFF4A6FFF),
                            checkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _acceptTerms = !_acceptTerms;
                                });
                              },
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'I agree to the ',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    TextSpan(
                                      text: 'Terms & Conditions',
                                      style: TextStyle(
                                        color: const Color(0xFF4A6FFF),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: ' and ',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: const Color(0xFF4A6FFF),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_selectedPaymentMethod == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                color: Colors.red, size: 16),
                              const SizedBox(width: 5),
                              Text(
                                'Please select a payment method',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 30),

                      // 🔵 REGISTER BUTTON - FIXED NAVY BLUE 
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A6FFF), // 🔵 FIXED NAVY BLUE
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                            shadowColor: const Color(0xFF4A6FFF).withOpacity(0.3),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.payment, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Pay Rs. 500 & Register',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Divider (YOUR EXACT CODE)
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey[300],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              'Already have an account?',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Login Button (YOUR EXACT CODE)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF4A6FFF),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.transparent,
                          ),
                          child: Text(
                            'Sign In',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: const Color(0xFF4A6FFF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Footer
                Center(
                  child: Text(
                    'Payment secured with SSL encryption',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
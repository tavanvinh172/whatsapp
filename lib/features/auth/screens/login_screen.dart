import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_whatsapp_clone/colors.dart';
import 'package:flutter_whatsapp_clone/common/utils/utils.dart';
import 'package:flutter_whatsapp_clone/common/widgets/custom_button.dart';
import 'package:flutter_whatsapp_clone/features/auth/controller/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const routeName = '/login-screen';
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phoneController = TextEditingController();
  Country? _country;
  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
  }

  void countryPicker() {
    showCountryPicker(
        context: context,
        onSelect: (country) {
          setState(() {
            _country = country;
          });
        });
  }

  void sendPhoneNumber() {
    String phoneNumber = phoneController.text.trim();
    if (_country != null && phoneNumber.isNotEmpty) {
      ref
          .read(authControllerProvider)
          .signInWithPhone('+${_country!.phoneCode}$phoneNumber', context);
    } else {
      showSnackBar(context: context, content: 'Fill out all the field');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text('Enter your phone number'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                const Text('Whatsapp will need to verify your phone number.'),
                const SizedBox(
                  height: 10,
                ),
                TextButton(
                    onPressed: countryPicker,
                    child: const Text('Pick country')),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    if (_country != null) Text('+${_country!.phoneCode}'),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: size.width * 0.7,
                      child: TextField(
                        controller: phoneController,
                        decoration:
                            const InputDecoration(hintText: 'phone number'),
                      ),
                    )
                  ],
                ),
              ],
            ),
            SizedBox(
                width: size.width * 0.2,
                child: CustomButton(
                  text: 'NEXT',
                  onPress: sendPhoneNumber,
                ))
          ],
        ),
      ),
    );
  }
}

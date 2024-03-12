import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 15, top: 50),
            child: Text(
              'Ovo je nasa prica',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Container(
            height: 220,
            width: 500,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: AssetImage('images/beoturaEkipa.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(
              'Mi smo srednjoškolci iz Beograda i otkrivamo interesantnu stranu Beogradske istorije. Istražujemo i fotografišemo skrivena blaga našeg grada, koje sada možete i sami iskusiti! Odaberite svoju turu i prepustite se u Beogradsku Avanturu sa nama! Ako želite da saznate više, posetite našu web stranicu.',
              textAlign: TextAlign.justify,
              style:
                  TextStyle(fontSize: 15, letterSpacing: 0.5, wordSpacing: 1),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: _launchURL,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            ),
            child: const Text('Poseti nas',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                )),
          ),
        ],
      ),
    );
  }
}

void _launchURL() async {
  final Uri url = Uri.parse('https://www.beotura.rs/');
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}

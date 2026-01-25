import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:waka_fit/core/theme/app_text_styles.dart';
import 'package:waka_fit/features/home/providers/coach_provider.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {

  
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

    Future<void> _initializeData() async {
    final provider = Provider.of<CoachProvider>(context, listen: false);
    if (provider.coaches.isEmpty) {
      await provider.fetchAllCoaches();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text("Recommended for You", style: AppTextStyles.titleLarge,),
        
      ),
      body: Consumer<CoachProvider>(
        builder: (context, coachProvider, child) {
          if (coachProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (coachProvider.error != null) {
            return Center(child: Text("Error: ${coachProvider.error}", style: const TextStyle(color: Colors.white),));
          } else {
            return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _PersonalizationCard(),
            const SizedBox(height: 24),

            Text(
              "Based on Your Goals",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Perfect matches for weight loss & muscle building",
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white.withOpacity(0.6),
              ),
            ),

            const SizedBox(height: 16),

            _TrainerCard(
              name: coachProvider.coaches[0].name,
              specialty: coachProvider.coaches[0].specialties,
              match: 95,
              description:
                  coachProvider.coaches[0].bio,
            ),

            const SizedBox(height: 16),
 ],
        ),
      );}
        },
      ),
      
      );
  }
}

class _PersonalizationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.grey.shade900, Colors.grey.shade800],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Help us personalize your feed",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.close, color: Colors.white54, size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Answer 3 quick questions to get better recommendations tailored to your fitness journey",
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {},
            child: const Text("Get Started"),
          ),
        ],
      ),
    );
  }
}

class _TrainerCard extends StatelessWidget {
  final String name;
  final String specialty;
  final int match;
  final String description;

  const _TrainerCard({
    required this.name,
    required this.specialty,
    required this.match,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
                CircleAvatar(
                radius: 26,
                backgroundImage: NetworkImage('https://picsum.photos/200/300?random=5'),
                backgroundColor: Colors.grey,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    Text(specialty,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white54)),
                  ],
                ),
              ),
              Chip(
                backgroundColor: Colors.green.shade600,
                label: Text(
                  "$match% Match",
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Why recommended: ",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600, color: Colors.cyanAccent),
                ),
                TextSpan(
                  text: description,
                  style: GoogleFonts.inter(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Row(
          //   children: [
          //     Expanded(
          //       child: ElevatedButton(
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor: Colors.cyanAccent,
          //           foregroundColor: Colors.black,
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(12),
          //           ),
          //         ),
          //         onPressed: () {},
          //         child: const Text("Follow"),
          //       ),
          //     ),
          //     const SizedBox(width: 12),
          //     TextButton(
          //       onPressed: () {},
          //       child: const Text(
          //         "Tell us why",
          //         style: TextStyle(color: Colors.white54),
          //       ),
          //     ),
          //   ],
          // ),
        
        
        ],
      ),
    );
  }
}

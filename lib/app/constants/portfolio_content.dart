import 'package:flutter/material.dart';

import 'app_constants.dart';

class SkillGroup {
  const SkillGroup(this.name, this.note, this.skills);

  final String name;
  final String note;
  final List<String> skills;
}

class Job {
  const Job({
    required this.company,
    required this.role,
    required this.place,
    required this.period,
    required this.points,
    this.isCurrent = false,
  });

  final String company;
  final String role;
  final String place;
  final String period;
  final List<String> points;
  final bool isCurrent;
}

enum ProjectVisual { tallScreens, storeArt, pipeline }

class Project {
  const Project({
    required this.name,
    required this.kind,
    required this.summary,
    required this.contribution,
    required this.details,
    required this.tech,
    required this.visual,
    required this.colors,
    this.icon,
    this.images = const [],
    this.storeUrl,
  });

  final String name;
  final String kind;
  final String summary;
  final String contribution;
  final List<String> details;
  final List<String> tech;
  final ProjectVisual visual;

  /// Background gradient of the visual, taken from the product's own branding.
  final List<Color> colors;
  final String? icon;
  final List<String> images;

  /// Set to a real store or website URL to show a "View project" button.
  final String? storeUrl;
}

class Education {
  const Education(this.title, this.school, this.period, this.result);

  final String title;
  final String school;
  final String period;
  final String result;
}

abstract final class PortfolioContent {
  static const skillGroups = [
    SkillGroup('Mobile development', 'One codebase, both platforms', ['Flutter', 'Dart', 'Android', 'iOS']),
    SkillGroup('State management', 'GetX architecture at Top Freshers', ['GetX']),
    SkillGroup('Backend integration', 'Connecting apps to live services', ['Spring Boot', 'REST APIs']),
    SkillGroup('Database', 'PostgreSQL at Top Freshers, DynamoDB on OpticalHR', ['PostgreSQL', 'AWS DynamoDB']),
    SkillGroup('Programming', 'Full Stack Developer certified', ['Dart', 'Core Java']),
    SkillGroup('Tools', 'Version control', ['Git', 'GitHub']),
  ];

  static const jobs = [
    Job(
      company: 'Top Freshers Technologies',
      role: 'Flutter Developer',
      place: 'Vanagaram, Chennai, Tamil Nadu, India',
      period: 'January 2026 – Present',
      isCurrent: true,
      points: [
        'Developing cross-platform mobile applications using Flutter and Dart.',
        'Implementing state management using GetX architecture.',
        'Integrating Spring Boot backend services.',
        'Working with PostgreSQL database integration.',
        'Coordinating with backend and UI teams.',
        'Managing application builds and testing processes.',
        'Participating in requirement analysis and feature enhancements.',
      ],
    ),
    Job(
      company: 'Links4Engg Pvt Ltd',
      role: 'Flutter Developer',
      place: 'Trivandrum, Kerala, India',
      period: 'April 2023 – September 2025',
      points: [
        'Developed and maintained Flutter mobile applications.',
        'Coordinated with clients and internal teams.',
        'Understood requirements and delivered solutions on time.',
        'Managed multiple project timelines.',
        'Supported technical teams and troubleshot issues.',
        'Maintained documentation and communication with stakeholders.',
      ],
    ),
  ];

  static const projects = [
    Project(
      name: 'OpticalHR',
      kind: 'HRMS and employee management',
      summary:
          'An employee management app where a leave request moves from the employee to a manager and on to '
          'senior-level approval.',
      contribution: 'Leave approval workflows, contact modules, support interfaces and secure sign-in.',
      details: [
        'Employee management functionality.',
        'Leave approval workflows from manager to senior-level users.',
        'Employee contact modules.',
        'User support interfaces.',
        'AWS DynamoDB backend data handling.',
        'Secure login and logout flows.',
      ],
      tech: ['Flutter', 'Dart', 'AWS DynamoDB'],
      visual: ProjectVisual.tallScreens,
      colors: [Color(0xFF1C6B55), Color(0xFF0A2E2A)],
      icon: AppAssets.opticalIcon,
      images: [AppAssets.opticalDashboard, AppAssets.opticalAttendance],
    ),
    Project(
      name: 'Smartmi CRM',
      kind: 'Business CRM',
      summary: 'Mobile CRM application developed for business workflow and customer relationship management.',
      contribution: 'A Links4Engg India app from my time there as a Flutter Developer.',
      details: [
        'Mobile CRM application for business workflow and customer relationship management.',
        'Listed on the App Store by Links4Engg India.',
      ],
      tech: ['Flutter', 'Dart'],
      visual: ProjectVisual.storeArt,
      colors: [Color(0xFF1B4FD6), Color(0xFF0B1B4A)],
      icon: AppAssets.smartmiIcon,
      images: [AppAssets.smartmiSignIn, AppAssets.smartmiHome],
    ),
    Project(
      name: 'JerseyMEP',
      kind: 'Qatar MEP e-commerce',
      summary:
          'A Qatar-based shopping app for procuring mechanical, electrical and plumbing materials, with '
          'checkout through Razorpay.',
      contribution: 'Razorpay payments, reusable widgets, performance work and clean Flutter architecture.',
      details: [
        'Procurement of mechanical, electrical and plumbing materials.',
        'Razorpay payment gateway integration.',
        'Handling of payment initiation, success and failure scenarios.',
        'AWS backend services.',
        'Reusable Flutter widgets.',
        'Performance optimization.',
        'Clean and maintainable Flutter architecture.',
      ],
      tech: ['Flutter', 'Dart', 'Razorpay', 'AWS'],
      visual: ProjectVisual.pipeline,
      colors: [Color(0xFF3A2A6B), Color(0xFF12173A)],
    ),
  ];

  static const education = [
    Education(
      'MBA in HR & Operations Management',
      'Mar Ephraem College of Engineering & Technology',
      'August 2023 – March 2025',
      'CGPA 8.0',
    ),
    Education(
      'B.E. in Electronics & Communication Engineering',
      'Ponjesly College of Engineering, Kaliyankadu, Nagercoil',
      'July 2018 – March 2022',
      'CGPA 7.6',
    ),
    Education('Higher Secondary Education', 'Bethlahem Matric & Higher Secondary School', 'May 2018', '90%'),
  ];
}

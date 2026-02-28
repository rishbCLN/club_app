// ── NEXUS Demo Mode — all static mock data lives here ─────────────────────────
//
// Set kDemoMode = true in providers.dart to use these instead of Firestore.
// No Firebase connection is made in demo mode.

import '../models/models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Demo user (treated as "logged in")
// ─────────────────────────────────────────────────────────────────────────────

final kDemoUser = UserModel(
  uid: 'demo_user_001',
  displayName: 'Aryan Mehta',
  email: 'aryan.mehta@nexus.edu',
  collegeRollNo: 'CS/2022/047',
  clubMemberships: ['club_cipher', 'club_shutter'],
  createdAt: DateTime(2022, 8, 1),
);

// ─────────────────────────────────────────────────────────────────────────────
// Clubs
// ─────────────────────────────────────────────────────────────────────────────

final kMockClubs = <ClubModel>[
  ClubModel(
    id: 'club_cipher',
    name: 'Cipher Collective',
    tagline: 'Code. Break. Build.',
    type: 'tech',
    colorHex: '#00FFCC',
    glowColorHex: '#00FFCC',
    memberCount: 142,
    foundedYear: 2018,
    adminUids: ['demo_user_001'],
    description:
        'Cipher Collective is the premier tech and competitive programming club on campus. '
        'We host hackathons, ctf challenges, and weekly code sprints. From machine learning '
        'to systems programming — if it runs on silicon, we own it.',
    socialLinks: {
      'instagram': 'https://instagram.com/ciphercollective',
      'github': 'https://github.com/ciphercollective',
    },
  ),
  ClubModel(
    id: 'club_pixel',
    name: 'Pixel & Prism',
    tagline: 'Design is the silent ambassador.',
    type: 'design',
    colorHex: '#A78BFA',
    glowColorHex: '#A78BFA',
    memberCount: 87,
    foundedYear: 2020,
    adminUids: ['user_priya'],
    description:
        'Pixel & Prism is where ideas become visual. We explore UI/UX, brand design, '
        'motion graphics, and product thinking. Our weekly critique sessions are brutally '
        'honest and deeply rewarding.',
    socialLinks: {
      'instagram': 'https://instagram.com/pixelprism',
      'behance': 'https://behance.net/pixelprism',
    },
  ),
  ClubModel(
    id: 'club_shutter',
    name: 'Shutter Inc.',
    tagline: 'Every frame tells a truth.',
    type: 'cultural',
    colorHex: '#FBBF24',
    glowColorHex: '#FBBF24',
    memberCount: 64,
    foundedYear: 2019,
    adminUids: ['user_riya'],
    description:
        'Shutter Inc. is the official photography and videography club. We shoot street, '
        'portrait, astrophotography, and everything in between. Monthly photo walks, '
        'editing workshops and our annual zine keep things interesting.',
    socialLinks: {
      'instagram': 'https://instagram.com/shutterinc',
      'flickr': 'https://flickr.com/shutterinc',
    },
  ),
  ClubModel(
    id: 'club_robo',
    name: 'RoboNexus',
    tagline: 'Machines that think.',
    type: 'tech',
    colorHex: '#34D399',
    glowColorHex: '#34D399',
    memberCount: 119,
    foundedYear: 2016,
    adminUids: ['user_vinay'],
    description:
        'RoboNexus builds competition-grade robots, autonomous drones, and IoT systems. '
        'We compete in national-level robotics championships and run semester-long '
        'project tracks for members at all skill levels.',
    socialLinks: {
      'instagram': 'https://instagram.com/robonexus',
      'youtube': 'https://youtube.com/robonexus',
    },
  ),
  ClubModel(
    id: 'club_resonance',
    name: 'Resonance',
    tagline: 'Music is the language we all speak.',
    type: 'cultural',
    colorHex: '#FF6B9D',
    glowColorHex: '#FF6B9D',
    memberCount: 93,
    foundedYear: 2017,
    adminUids: ['user_meera'],
    description:
        'Resonance houses the vocalists, instrumentalists, beatmakers, and producers of '
        'the campus. We perform at every major fest, run open-mic Fridays, and record '
        'original singles in our on-campus studio.',
    socialLinks: {
      'instagram': 'https://instagram.com/resonanceclub',
      'spotify': 'https://open.spotify.com/user/resonanceclub',
    },
  ),
  ClubModel(
    id: 'club_verbatim',
    name: 'Verbatim',
    tagline: 'Words win wars.',
    type: 'literary',
    colorHex: '#F97316',
    glowColorHex: '#F97316',
    memberCount: 76,
    foundedYear: 2015,
    adminUids: ['user_kiran'],
    description:
        'Verbatim is the debate, MUN, and public speaking club. We\'ve sent delegates to '
        'HMUN, DAIMUN, and IIMUN. Our internal debate circuit runs year-round with '
        'British Parliamentary and Asian Parliamentary formats.',
    socialLinks: {
      'instagram': 'https://instagram.com/verbatimclub',
      'linkedin': 'https://linkedin.com/company/verbatimclub',
    },
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Events  (dates relative to Feb 28, 2026)
// ─────────────────────────────────────────────────────────────────────────────

final kMockEvents = <EventModel>[
  // ── Upcoming ──────────────────────────────────────────────────────────────
  EventModel(
    id: 'evt_bytestorm',
    title: 'ByteStorm Hackathon 2026',
    description:
        '36-hour hackathon open to all students. Build anything from climate tech to '
        'fintech to pure engineering marvels. Team size: 2–4. Prizes worth ₹1,20,000 '
        'and internship fast-track interviews with sponsor companies.',
    clubId: 'club_cipher',
    clubName: 'Cipher Collective',
    clubColorHex: '#00FFCC',
    eventType: 'hackathon',
    startDate: DateTime(2026, 3, 3, 9, 0),
    endDate: DateTime(2026, 3, 4, 21, 0),
    venue: 'Main Auditorium & Innovation Hub',
    registrationLink: 'https://forms.nexus.edu/bytestorm',
    collaboratingClubs: ['RoboNexus', 'Pixel & Prism'],
    tags: ['open', 'prizes', '36hr'],
  ),
  EventModel(
    id: 'evt_designsprint',
    title: 'Design Sprint: Zero to Prototype',
    description:
        'A two-day immersive product design sprint. You\'ll be given a brief on Day 1 '
        'and must deliver a working Figma prototype by Day 2 evening. Judged by industry '
        'designers from Swiggy and Razorpay.',
    clubId: 'club_pixel',
    clubName: 'Pixel & Prism',
    clubColorHex: '#A78BFA',
    eventType: 'workshop',
    startDate: DateTime(2026, 3, 7, 10, 0),
    endDate: DateTime(2026, 3, 8, 18, 0),
    venue: 'Design Studio, Block C',
    registrationLink: 'https://forms.nexus.edu/designsprint',
    collaboratingClubs: [],
    tags: ['figma', 'product', 'ux'],
  ),
  EventModel(
    id: 'evt_robowars',
    title: 'RoboWars 4.0',
    description:
        'The biggest combat robotics event on campus. 1kg, 5kg, and 15kg weight '
        'categories. External teams from 12 colleges registered. Live stream on '
        'RoboNexus YouTube channel. Register your bot before slots fill up.',
    clubId: 'club_robo',
    clubName: 'RoboNexus',
    clubColorHex: '#34D399',
    eventType: 'fest',
    startDate: DateTime(2026, 3, 14, 9, 0),
    endDate: DateTime(2026, 3, 15, 20, 0),
    venue: 'Sports Complex Arena',
    registrationLink: 'https://forms.nexus.edu/robowars',
    collaboratingClubs: ['Cipher Collective'],
    tags: ['robotics', 'combat', 'live'],
  ),
  EventModel(
    id: 'evt_devtalk',
    title: 'DevTalk: Building for Scale',
    description:
        'Monthly tech talk series. March edition brings in a Staff Engineer from '
        'Zepto to talk about handling 10M+ daily orders — backend architecture, '
        'distributed systems and the unglamorous realities of production engineering.',
    clubId: 'club_cipher',
    clubName: 'Cipher Collective',
    clubColorHex: '#00FFCC',
    eventType: 'meetup',
    startDate: DateTime(2026, 3, 19, 17, 30),
    endDate: DateTime(2026, 3, 19, 20, 0),
    venue: 'Seminar Hall 2',
    registrationLink: 'https://forms.nexus.edu/devtalk',
    collaboratingClubs: [],
    tags: ['backend', 'talk', 'free'],
  ),
  EventModel(
    id: 'evt_productforum',
    title: 'Product Design Forum 2026',
    description:
        'A cross-disciplinary forum bringing together designers and engineers for '
        'a day of talks, workshops and portfolio reviews. Guest speakers from '
        'Google, Notion and InMobi confirmed.',
    clubId: 'club_pixel',
    clubName: 'Pixel & Prism',
    clubColorHex: '#A78BFA',
    eventType: 'meetup',
    startDate: DateTime(2026, 3, 21, 10, 0),
    endDate: DateTime(2026, 3, 21, 18, 0),
    venue: 'Open-Air Amphitheatre',
    registrationLink: 'https://forms.nexus.edu/productforum',
    collaboratingClubs: ['Cipher Collective'],
    tags: ['design', 'product', 'portfolio'],
  ),

  // ── Ongoing ────────────────────────────────────────────────────────────────
  EventModel(
    id: 'evt_shutterwalk',
    title: 'Shutter Walk: Old City',
    description:
        'A guided street photography walk through the Old City. Capture architecture, '
        'people, and the chaos of daily life. Best shot wins a feature in our annual '
        'zine. Open to all skill levels — bring any camera.',
    clubId: 'club_shutter',
    clubName: 'Shutter Inc.',
    clubColorHex: '#FBBF24',
    eventType: 'meetup',
    startDate: DateTime(2026, 2, 28, 6, 30),
    endDate: DateTime(2026, 2, 28, 11, 0),
    venue: 'Meet at Main Gate',
    registrationLink: null,
    collaboratingClubs: [],
    tags: ['photography', 'walk', 'outdoor'],
  ),

  // ── Past ──────────────────────────────────────────────────────────────────
  EventModel(
    id: 'evt_resonancelive',
    title: 'Resonance Live — Season 4',
    description:
        'The fourth edition of our signature live music night. 14 acts, 3 hours of '
        'original music across genres — jazz, indie, electronic, and classical fusion. '
        'Held at the Open-Air Stage, night sky included.',
    clubId: 'club_resonance',
    clubName: 'Resonance',
    clubColorHex: '#FF6B9D',
    eventType: 'cultural',
    startDate: DateTime(2026, 2, 21, 19, 0),
    endDate: DateTime(2026, 2, 21, 23, 0),
    venue: 'Open-Air Stage',
    registrationLink: null,
    collaboratingClubs: [],
    tags: ['music', 'live', 'free-entry'],
  ),
  EventModel(
    id: 'evt_debate',
    title: 'Grand Debate Championship',
    description:
        'Our flagship annual debate tournament. 28 teams from 7 colleges, '
        'BP format, motions ranging from AI governance to geopolitics. '
        'Best speaker award and team trophies.',
    clubId: 'club_verbatim',
    clubName: 'Verbatim',
    clubColorHex: '#F97316',
    eventType: 'cultural',
    startDate: DateTime(2026, 2, 14, 9, 0),
    endDate: DateTime(2026, 2, 15, 18, 0),
    venue: 'Conference Hall, Admin Block',
    registrationLink: null,
    collaboratingClubs: [],
    tags: ['debate', 'bp', 'inter-college'],
  ),
  EventModel(
    id: 'evt_mlworkshop',
    title: 'Intro to Machine Learning',
    description:
        'A beginner-friendly 3-hour workshop covering supervised learning, decision '
        'trees, and neural net intuition. Hands-on Colab notebooks provided. '
        'No prior ML experience required.',
    clubId: 'club_cipher',
    clubName: 'Cipher Collective',
    clubColorHex: '#00FFCC',
    eventType: 'workshop',
    startDate: DateTime(2026, 2, 7, 14, 0),
    endDate: DateTime(2026, 2, 7, 17, 0),
    venue: 'Computer Lab 4, Block B',
    registrationLink: null,
    collaboratingClubs: [],
    tags: ['ml', 'python', 'beginner'],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Club Members  (key = clubId → list of members)
// ─────────────────────────────────────────────────────────────────────────────

final kMockMembers = <String, List<ClubMemberModel>>{
  'club_cipher': [
    ClubMemberModel(
      uid: 'demo_user_001',
      displayName: 'Aryan Mehta',
      roleTag: 'techHead',
      joinedAt: DateTime(2023, 8, 5),
      isAdmin: false,
    ),
    ClubMemberModel(
      uid: 'user_priya',
      displayName: 'Priya Nair',
      roleTag: 'seniorCore',
      joinedAt: DateTime(2022, 7, 15),
      isAdmin: true,
    ),
    ClubMemberModel(
      uid: 'user_sameer',
      displayName: 'Sameer Khan',
      roleTag: 'eventHead',
      joinedAt: DateTime(2023, 1, 10),
      isAdmin: false,
    ),
    ClubMemberModel(
      uid: 'user_ishaan',
      displayName: 'Ishaan Verma',
      roleTag: 'juniorCore',
      joinedAt: DateTime(2024, 8, 20),
      isAdmin: false,
    ),
    ClubMemberModel(
      uid: 'user_ananya',
      displayName: 'Ananya Singh',
      roleTag: 'designLead',
      joinedAt: DateTime(2023, 8, 12),
      isAdmin: false,
    ),
    ClubMemberModel(
      uid: 'user_rohan',
      displayName: 'Rohan Joshi',
      roleTag: 'marketingHead',
      joinedAt: DateTime(2023, 3, 5),
      isAdmin: false,
    ),
    ClubMemberModel(
      uid: 'user_zara',
      displayName: 'Zara Malik',
      roleTag: 'outreachLead',
      joinedAt: DateTime(2024, 2, 1),
      isAdmin: false,
    ),
    ClubMemberModel(
      uid: 'user_dev',
      displayName: 'Dev Patel',
      roleTag: 'member',
      joinedAt: DateTime(2024, 9, 1),
      isAdmin: false,
    ),
  ],
  'club_shutter': [
    ClubMemberModel(
      uid: 'demo_user_001',
      displayName: 'Aryan Mehta',
      roleTag: 'member',
      joinedAt: DateTime(2024, 1, 14),
      isAdmin: false,
    ),
    ClubMemberModel(
      uid: 'user_riya',
      displayName: 'Riya Sharma',
      roleTag: 'seniorCore',
      joinedAt: DateTime(2020, 9, 1),
      isAdmin: true,
    ),
    ClubMemberModel(
      uid: 'user_kabir',
      displayName: 'Kabir Rawat',
      roleTag: 'eventHead',
      joinedAt: DateTime(2022, 8, 10),
      isAdmin: false,
    ),
    ClubMemberModel(
      uid: 'user_nisha',
      displayName: 'Nisha Gupta',
      roleTag: 'designLead',
      joinedAt: DateTime(2023, 8, 7),
      isAdmin: false,
    ),
    ClubMemberModel(
      uid: 'user_tushar',
      displayName: 'Tushar Bose',
      roleTag: 'juniorCore',
      joinedAt: DateTime(2024, 8, 22),
      isAdmin: false,
    ),
  ],
  'club_pixel': [
    ClubMemberModel(
      uid: 'user_priya',
      displayName: 'Priya Nair',
      roleTag: 'seniorCore',
      joinedAt: DateTime(2020, 8, 1),
      isAdmin: true,
    ),
    ClubMemberModel(
      uid: 'user_ananya',
      displayName: 'Ananya Singh',
      roleTag: 'designLead',
      joinedAt: DateTime(2022, 9, 5),
      isAdmin: false,
    ),
    ClubMemberModel(
      uid: 'user_aarav',
      displayName: 'Aarav Shah',
      roleTag: 'member',
      joinedAt: DateTime(2024, 8, 25),
      isAdmin: false,
    ),
  ],
};

// ─────────────────────────────────────────────────────────────────────────────
// Chat Messages  (key = clubId → list of messages, newest last)
// ─────────────────────────────────────────────────────────────────────────────

final kMockMessages = <String, List<MessageModel>>{
  'club_cipher': [
    MessageModel(
      id: 'msg_1',
      senderUid: 'user_priya',
      senderName: 'Priya Nair',
      senderTag: 'seniorCore',
      senderAccentColor: '#FF6B9D',
      text:
          '📢 ByteStorm reg closes midnight tonight. If you haven\'t registered your team, do it NOW.',
      type: 'announcement',
      timestamp: DateTime(2026, 2, 28, 8, 0),
    ),
    MessageModel(
      id: 'msg_2',
      senderUid: 'user_sameer',
      senderName: 'Sameer Khan',
      senderTag: 'eventHead',
      senderAccentColor: '#34D399',
      text: 'Infra is set up. 120+ registered so far 🔥',
      type: 'text',
      timestamp: DateTime(2026, 2, 28, 9, 15),
    ),
    MessageModel(
      id: 'msg_3',
      senderUid: 'demo_user_001',
      senderName: 'Aryan Mehta',
      senderTag: 'techHead',
      senderAccentColor: '#00FFCC',
      text: 'Our team is locked in. Aryan + Ishaan + Zara. Let\'s gooo',
      type: 'text',
      timestamp: DateTime(2026, 2, 28, 9, 42),
      reactions: {
        '🔥': ['user_sameer', 'user_priya', 'user_rohan'],
        '💪': ['user_ishaan'],
      },
    ),
    MessageModel(
      id: 'msg_4',
      senderUid: 'user_ishaan',
      senderName: 'Ishaan Verma',
      senderTag: 'juniorCore',
      senderAccentColor: '#A78BFA',
      text: 'What are we building?? haven\'t decided yet 😅',
      type: 'text',
      timestamp: DateTime(2026, 2, 28, 9, 50),
    ),
    MessageModel(
      id: 'msg_5',
      senderUid: 'demo_user_001',
      senderName: 'Aryan Mehta',
      senderTag: 'techHead',
      senderAccentColor: '#00FFCC',
      text: 'I\'m thinking a real-time campus resource booking system. '
          'We can use websockets + a lightweight Go backend. Should be doable in 36h.',
      type: 'text',
      timestamp: DateTime(2026, 2, 28, 10, 3),
    ),
    MessageModel(
      id: 'msg_6',
      senderUid: 'user_zara',
      senderName: 'Zara Malik',
      senderTag: 'outreachLead',
      senderAccentColor: '#60A5FA',
      text: 'I can handle the pitch deck and frontend. Ishaan you\'re on backend with Aryan?',
      type: 'text',
      timestamp: DateTime(2026, 2, 28, 10, 8),
    ),
    MessageModel(
      id: 'msg_7',
      senderUid: 'user_rohan',
      senderName: 'Rohan Joshi',
      senderTag: 'marketingHead',
      senderAccentColor: '#FBBF24',
      text: 'Priya just pinned the sponsor deck in the Drive. Everyone check it — '
          'there are some theme constraints from the sponsors.',
      type: 'text',
      timestamp: DateTime(2026, 2, 28, 11, 20),
    ),
    MessageModel(
      id: 'msg_8',
      senderUid: 'user_priya',
      senderName: 'Priya Nair',
      senderTag: 'seniorCore',
      senderAccentColor: '#FF6B9D',
      text: 'Judging criteria is now up on the website. Go read it before you finalize ideas.',
      type: 'text',
      timestamp: DateTime(2026, 2, 28, 12, 0),
      reactions: {
        '👍': ['demo_user_001', 'user_sameer', 'user_ishaan', 'user_zara'],
      },
    ),
    MessageModel(
      id: 'msg_9',
      senderUid: 'user_dev',
      senderName: 'Dev Patel',
      senderTag: 'member',
      senderAccentColor: '#94A3B8',
      text: 'Can a solo member still participate or is 2-person minimum?',
      type: 'text',
      timestamp: DateTime(2026, 2, 28, 12, 45),
    ),
    MessageModel(
      id: 'msg_10',
      senderUid: 'user_sameer',
      senderName: 'Sameer Khan',
      senderTag: 'eventHead',
      senderAccentColor: '#34D399',
      text: '2 minimum Dev, rules are on the website. But we can help you find a teammate in the group.',
      type: 'text',
      timestamp: DateTime(2026, 2, 28, 12, 50),
    ),
  ],
  'club_shutter': [
    MessageModel(
      id: 'smsg_1',
      senderUid: 'user_riya',
      senderName: 'Riya Sharma',
      senderTag: 'seniorCore',
      senderAccentColor: '#FBBF24',
      text: '🌅 Walk is ON today! Meet at Main Gate at 6:30am sharp.',
      type: 'announcement',
      timestamp: DateTime(2026, 2, 28, 5, 0),
    ),
    MessageModel(
      id: 'smsg_2',
      senderUid: 'user_kabir',
      senderName: 'Kabir Rawat',
      senderTag: 'eventHead',
      senderAccentColor: '#34D399',
      text: 'Bringing my 50mm and a wide angle. Old City light in the morning is unreal.',
      type: 'text',
      timestamp: DateTime(2026, 2, 28, 6, 0),
    ),
    MessageModel(
      id: 'smsg_3',
      senderUid: 'demo_user_001',
      senderName: 'Aryan Mehta',
      senderTag: 'member',
      senderAccentColor: '#00FFCC',
      text: 'On my way! Only have my phone but let\'s see what I can catch.',
      type: 'text',
      timestamp: DateTime(2026, 2, 28, 6, 10),
      reactions: {'❤️': ['user_riya', 'user_nisha']},
    ),
    MessageModel(
      id: 'smsg_4',
      senderUid: 'user_nisha',
      senderName: 'Nisha Gupta',
      senderTag: 'designLead',
      senderAccentColor: '#A78BFA',
      text: 'Phone cameras have come so far honestly. Don\'t sweat it Aryan.',
      type: 'text',
      timestamp: DateTime(2026, 2, 28, 6, 15),
    ),
    MessageModel(
      id: 'smsg_5',
      senderUid: 'user_tushar',
      senderName: 'Tushar Bose',
      senderTag: 'juniorCore',
      senderAccentColor: '#60A5FA',
      text: 'Sorry guys running 10 min late, save me a spot 😭',
      type: 'text',
      timestamp: DateTime(2026, 2, 28, 6, 22),
    ),
  ],
};

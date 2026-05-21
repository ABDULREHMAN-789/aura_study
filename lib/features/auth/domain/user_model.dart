class AuraUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final bool isPremium;
  final DateTime createdAt;

  const AuraUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.isPremium = false,
    required this.createdAt,
  });

  /// Factory to map from a Firebase User object
  factory AuraUser.fromFirebaseUser(dynamic firebaseUser) {
    // We use dynamic here to allow both Firebase User and Mock User definitions
    return AuraUser(
      uid: firebaseUser.uid as String,
      email: firebaseUser.email as String? ?? '',
      displayName: firebaseUser.displayName as String? ?? 'Aura Scholar',
      photoUrl: firebaseUser.photoURL as String?,
      isPremium: false,
      createdAt: DateTime.now(),
    );
  }

  /// Factory to create a mock user
  factory AuraUser.mock({
    String uid = 'aura-mock-dev-999',
    String email = 'developer@aurastudy.ai',
    String displayName = 'Aura Developer',
    bool isPremium = true,
  }) {
    return AuraUser(
      uid: uid,
      email: email,
      displayName: displayName,
      isPremium: isPremium,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isPremium': isPremium,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AuraUser.fromJson(Map<String, dynamic> json) {
    return AuraUser(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      isPremium: json['isPremium'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

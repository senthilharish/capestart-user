class UserModel {
  final String uid;
  final String username;
  final String phone;
  final String email;
  final String password;
  final Map<String, dynamic>? location;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.username,
    required this.phone,
    required this.email,
    required this.password,
    this.location,
    required this.createdAt,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'phone': phone,
      'email': email,
      'password': password,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON from Firestore
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? '',
      username: json['username'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      location: json['location'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  // Copy with method for updates
  UserModel copyWith({
    String? uid,
    String? username,
    String? phone,
    String? email,
    String? password,
    Map<String, dynamic>? location,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

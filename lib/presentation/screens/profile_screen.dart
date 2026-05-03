// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import '../viewmodels/auth_viewmodel.dart';
// // import 'login_screen.dart';

// // class ProfileScreen extends ConsumerWidget {
// //   const ProfileScreen({super.key});

// //   @override
// //   Widget build(BuildContext context, WidgetRef ref) {
// //     final authViewModel = ref.read(authViewModelProvider.notifier);

// //     final userName = authViewModel.userName ?? "User";
// //     final userEmail = authViewModel.userEmail ?? "";

// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Profile')),
// //       body: Padding(
// //         padding: const EdgeInsets.all(24.0),
// //         child: Column(
// //           children: [
// //             const CircleAvatar(radius: 60, child: Icon(Icons.person, size: 80)),
// //             const SizedBox(height: 24),
// //             Text(
// //               userName,
// //               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
// //             ),
// //             Text(userEmail, style: const TextStyle(color: Colors.grey)),
// //             const SizedBox(height: 40),

// //             ListTile(
// //               leading: const Icon(Icons.notifications),
// //               title: const Text('Notifications'),
// //               trailing: const Icon(Icons.chevron_right),
// //               onTap: () {},
// //             ),
// //             ListTile(
// //               leading: const Icon(Icons.dark_mode),
// //               title: const Text('Dark Mode'),
// //               trailing: const Icon(Icons.chevron_right),
// //             ),
// //             const Divider(),

// //             const Spacer(),
// // //logout button
// //             ElevatedButton.icon(
// //               onPressed: () async {
// //                 await authViewModel.signOut();
// //                 if (context.mounted) {
// //                   Navigator.pushAndRemoveUntil(
// //                     context,
// //                     MaterialPageRoute(builder: (_) => const LoginScreen()),
// //                     (route) => false,
// //                   );
// //                 }
// //               },
// //               icon: const Icon(Icons.logout),
// //               label: const Text('Logout'),
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: Colors.red,
// //                 minimumSize: const Size(double.infinity, 56),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:scrollguard/data/repositories/hive_repository.dart';
// import '../viewmodels/auth_viewmodel.dart';
// import 'login_screen.dart';

// class ProfileScreen extends ConsumerStatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends ConsumerState<ProfileScreen> {
//   final ImagePicker _picker = ImagePicker();
//   bool _isUploading = false;

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       setState(() => _isUploading = true);

//       final XFile? pickedFile = await _picker.pickImage(
//         source: source,
//         imageQuality: 80,
//         maxWidth: 800,
//       );

//       if (pickedFile != null && mounted) {
//         // TODO: Upload to Firebase Storage + update user profile
//         // For now, you can save locally or extend later
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Photo updated successfully!')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: ${e.toString()}')),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isUploading = false);
//     }
//   }

//   void _showPhotoBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.camera_alt),
//               title: const Text('Take Photo'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickImage(ImageSource.camera);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: const Text('Choose from Gallery'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickImage(ImageSource.gallery);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authViewModelProvider);
//     final authViewModel = ref.read(authViewModelProvider.notifier);

//     final userData = HiveRepository.userBox.get('currentUser');
//     final name = userData?['name'] ?? 'User';
//     final email = userData?['email'] ?? '';
//     final photoUrl = userData?['photoUrl'];

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           children: [
//             // Profile Picture
//             Stack(
//               children: [
//                 CircleAvatar(
//                   radius: 70,
//                   backgroundImage: photoUrl != null && photoUrl.isNotEmpty
//                       ? NetworkImage(photoUrl)
//                       : null,
//                   backgroundColor: Colors.deepPurple.shade100,
//                   child: photoUrl == null || photoUrl.isEmpty
//                       ? const Icon(Icons.person, size: 80, color: Colors.white)
//                       : null,
//                 ),
//                 Positioned(
//                   bottom: 0,
//                   right: 0,
//                   child: GestureDetector(
//                     onTap: _showPhotoBottomSheet,
//                     child: CircleAvatar(
//                       radius: 22,
//                       backgroundColor: Theme.of(context).primaryColor,
//                       child: _isUploading
//                           ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
//                           : const Icon(Icons.camera_alt, size: 20, color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 24),

//             // Name
//             Text(
//               name,
//               style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),

//             const SizedBox(height: 8),

//             // Email
//             Text(
//               email,
//               style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
//               textAlign: TextAlign.center,
//             ),

//             const SizedBox(height: 40),

//             // Settings List
//             Card(
//               elevation: 0,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//               child: Column(
//                 children: [
//                   ListTile(
//                     leading: const Icon(Icons.notifications_outlined),
//                     title: const Text('Notifications'),
//                     trailing: const Icon(Icons.chevron_right),
//                     onTap: () {},
//                   ),
//                   const Divider(height: 1),
//                   ListTile(
//                     leading: const Icon(Icons.dark_mode_outlined),
//                     title: const Text('Appearance'),
//                     trailing: const Icon(Icons.chevron_right),
//                     onTap: () {},
//                   ),
//                   const Divider(height: 1),
//                   ListTile(
//                     leading: const Icon(Icons.security),
//                     title: const Text('Privacy & Security'),
//                     trailing: const Icon(Icons.chevron_right),
//                     onTap: () {},
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 40),

//             // Logout Button
//             ElevatedButton.icon(
//               onPressed: authState.isLoading
//                   ? null
//                   : () async {
//                       final confirmed = await showDialog<bool>(
//                         context: context,
//                         builder: (context) => AlertDialog(
//                           title: const Text('Logout'),
//                           content: const Text('Are you sure you want to logout?'),
//                           actions: [
//                             TextButton(
//                               onPressed: () => Navigator.pop(context, false),
//                               child: const Text('Cancel'),
//                             ),
//                             TextButton(
//                               onPressed: () => Navigator.pop(context, true),
//                               child: const Text('Logout', style: TextStyle(color: Colors.red)),
//                             ),
//                           ],
//                         ),
//                       );

//                       if (confirmed == true && mounted) {
//                         await authViewModel.signOut();
//                         if (mounted) {
//                           Navigator.pushAndRemoveUntil(
//                             context,
//                             MaterialPageRoute(builder: (_) => const LoginScreen()),
//                             (route) => false,
//                           );
//                         }
//                       }
//                     },
//               icon: const Icon(Icons.logout),
//               label: const Text('Logout', style: TextStyle(fontSize: 16)),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size(double.infinity, 56),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollguard/data/repositories/hive_repository.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'login_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Request permission
      if (source == ImageSource.gallery) {
        await Permission.photos.request();
      } else {
        await Permission.camera.request();
      }

      setState(() => _isUploading = true);

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
      );

      if (pickedFile != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated successfully!')),
        );
        // TODO: Later - Upload to Firebase Storage and update user
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showPhotoBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.deepPurple),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Colors.deepPurple,
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = ref.read(authViewModelProvider.notifier);
    final userData = HiveRepository.userBox.get(
      'currentUser',
    ); // Make sure this import exists

    final name = userData?['name'] ?? 'User';
    final email = userData?['email'] ?? 'No email';
    final photoUrl = userData?['photoUrl'];

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Image
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 72,
                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: (photoUrl == null || photoUrl.isEmpty)
                      ? const Icon(Icons.person, size: 80)
                      : null,
                ),
                GestureDetector(
                  onTap: _showPhotoBottomSheet,
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: _isUploading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          )
                        : const Icon(
                            Icons.camera_alt,
                            size: 22,
                            color: Colors.white,
                          ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Text(
              name,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Text(
              email,
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),

            const SizedBox(height: 40),

            // Menu Cards
            _buildMenuCard(
              Icons.notifications_outlined,
              'Notifications',
              'Manage push notifications',
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifications settings coming soon'),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildMenuCard(
              Icons.dark_mode_outlined,
              'Appearance',
              'Theme & Display',
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Appearance settings coming soon'),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildMenuCard(
              Icons.security,
              'Privacy & Security',
              'Account protection',
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy settings coming soon')),
                );
              },
            ),

            const SizedBox(height: 50),

            // Logout
            ElevatedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await authViewModel.signOut();
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(icon, color: Colors.deepPurple, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class NavigationHub extends StatelessWidget {
  const NavigationHub({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      title: const Row(
        children: [
          Icon(Icons.explore, color: Colors.blueAccent),
          SizedBox(width: 10),
          Text(
            'Navigate Hub',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: const Text(
        'Quickly jump to your job application resources:',
        style: TextStyle(color: Colors.black87),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHubButton(
              context,
              icon: Icons.description,
              label: 'Resumes',
              onPressed: () {
                Navigator.of(context).pop(); 
                // TODO: Update route to match your team's resume page
                // Navigator.pushNamed(context, '/resumes');
              },
            ),
            const SizedBox(height: 12),
            _buildHubButton(
              context,
              icon: Icons.work,
              label: 'Job Profiles',
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Update route to match your team's job profiles page
                // Navigator.pushNamed(context, '/jobs');
              },
            ),
            const SizedBox(height: 12),
            _buildHubButton(
              context,
              icon: Icons.mark_email_read,
              label: 'Cover Letters',
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Update route to match your team's cover letters page
                // Navigator.pushNamed(context, '/cover_letters');
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHubButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 22),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/db_helper.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});
  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Map<String, dynamic>> _contacts = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final data = await DBHelper.instance.getAllContacts();
    setState(() => _contacts = data);
  }

  void _showContactDialog({Map<String, dynamic>? contact}) {
    final nameCtrl = TextEditingController(text: contact?['name'] ?? '');
    final phoneCtrl = TextEditingController(text: contact?['phone'] ?? '');
    final emailCtrl = TextEditingController(text: contact?['email'] ?? '');
    final linksCtrl = TextEditingController(text: contact?['links'] ?? '');
    final notesCtrl = TextEditingController(text: contact?['notes'] ?? '');

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: const Color(0xFF111E2D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24, right: 24, top: 24),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(contact == null ? 'Add Contact' : 'Edit Contact',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          for (final item in [
            [nameCtrl, 'Name *', Icons.person_outline],
            [phoneCtrl, 'Phone', Icons.phone_outlined],
            [emailCtrl, 'Email', Icons.email_outlined],
            [linksCtrl, 'Links (Instagram/etc)', Icons.link],
            [notesCtrl, 'Notes', Icons.notes],
          ]) ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1))),
              child: TextField(
                controller: item[0] as TextEditingController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: item[1] as String,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                  prefixIcon: Icon(item[2] as IconData, color: const Color(0xFF6B9E78), size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14))),
            ),
            const SizedBox(height: 10),
          ],
          Row(children: [
            if (contact != null) Expanded(child: OutlinedButton(
              onPressed: () async {
                await DBHelper.instance.deleteContact(contact['id']);
                Navigator.pop(ctx); _load();
              },
              style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Delete'))),
            if (contact != null) const SizedBox(width: 10),
            Expanded(child: ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                final row = {
                  'name': nameCtrl.text.trim(), 'phone': phoneCtrl.text.trim(),
                  'email': emailCtrl.text.trim(), 'links': linksCtrl.text.trim(),
                  'notes': notesCtrl.text.trim(),
                };
                if (contact == null) {
                  await DBHelper.instance.insertContact(row);
                } else {
                  await DBHelper.instance.updateContact({...row, 'id': contact['id']});
                }
                Navigator.pop(ctx); _load();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B9E78), foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(contact == null ? 'Add' : 'Update'))),
          ]),
          const SizedBox(height: 20),
        ])),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('Contacts', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D1B2A), elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactDialog(),
        backgroundColor: const Color(0xFF6B9E78),
        child: const Icon(Icons.person_add, color: Colors.white)),
      body: _contacts.isEmpty
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('👥', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text('No contacts yet', style: TextStyle(color: Colors.white.withOpacity(0.5))),
            Text('Tap + to add a contact 🌿',
              style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13)),
          ]))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _contacts.length,
            itemBuilder: (_, i) {
              final c = _contacts[i];
              return GestureDetector(
                onTap: () => _showContactDialog(contact: c),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.08))),
                  child: Row(children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF6B9E78).withOpacity(0.3),
                      child: Text(c['name'][0].toUpperCase(),
                        style: const TextStyle(color: Color(0xFF6B9E78),
                          fontWeight: FontWeight.bold))),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(c['name'], style: const TextStyle(color: Colors.white,
                        fontWeight: FontWeight.bold)),
                      if (c['phone'] != null && c['phone'].toString().isNotEmpty)
                        Text(c['phone'], style: TextStyle(
                          color: Colors.white.withOpacity(0.5), fontSize: 12)),
                      if (c['email'] != null && c['email'].toString().isNotEmpty)
                        Text(c['email'], style: TextStyle(
                          color: Colors.white.withOpacity(0.4), fontSize: 12)),
                    ])),
                    if (c['phone'] != null && c['phone'].toString().isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.phone, color: Color(0xFF6B9E78), size: 20),
                        onPressed: () => launchUrl(Uri.parse('tel:${c['phone']}'))),
                  ]),
                ),
              );
            }),
    );
  }
}
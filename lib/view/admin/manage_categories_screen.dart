import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quiz/model/category.dart';
import 'package:quiz/theme/theme.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Manage Categories",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Navigator.push(context, MaterialPageRoute(builder: builder) => AddCategoryScreen());
            },
            icon: Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _firestore.collection('categories').orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error"));
          }
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }
          final categories = snapshot.data!.docs
              .map(
                (doc) => Category.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList();

          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    color: AppTheme.textSecondaryColor,
                    size: 64,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No Category Found",
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Navigator.push(context, MaterialPageRoute(builder: builder) => AddCategoryScreen());
                    },
                    child: Text("Add Category"),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: categories.length,
            padding: EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                margin: EdgeInsets.all(12),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppTheme.primaryColor.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.category_outlined,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  subtitle: Text(category.description),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: "edit",
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.edit,
                            color: AppTheme.primaryColor,
                          ),
                          title: Text("Edit"),
                        ),
                      ),
                      PopupMenuItem(
                        value: "delete",
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.delete, color: Colors.redAccent),
                          title: Text("Delete"),
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      _handelCategoryAction(context, value, category);
                    },
                  ),
                  onTap: () {
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => QuizListScreen(categoryId: category.id)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handelCategoryAction(
    BuildContext context,
    String action,
    Category category,
  ) async {
    if (action == 'edit') {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => AddCategoryScreen( category: category)),
      // );
    } else if (action == "delete") {
      final confirm = showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Delete Category"),
          content: Text("Are you sure you want to delete this category"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text("cansle"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text("Delete", style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await _firestore.collection('categories').doc(category.id).delete();
      }
    }
  }
}

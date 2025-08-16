import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quiz/theme/theme.dart';
import 'package:quiz/view/admin/manage_categories_screen.dart';
import 'package:quiz/view/admin/manage_quizzes_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  // انشاء الأنستانس الاسى يعتبر الواجهه اللتى تتفاعل مع قواعد البيانات فى الفاير بيس
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // انشاء داله ترجع (عدد الفئات - عدد الاختبارات - اخر اختابارت محدده - ترجع بيانات كل الفئات كل فئه متمثله فى اسم الفئه وعدد الاختبارات بها)
  Future<Map<String, dynamic>> fetchStatistic() async {
    // يحسب عدد الفئات يرجعه فى categoriesCount.count
    final categoriesCount = await _fireStore
        .collection('categories')
        .count()
        .get();

    // يحسب عدد الاختبارات ويرجعه فى quizzesCount.count
    final quizzesCount = await _fireStore.collection('quizzes').count().get();

    // Get lastest quizzes
    final lastQuizzes = await _fireStore
        .collection('quizzes')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();

    // جلب جميع الوثائق فى مجموعة categories
    final categories = await _fireStore.collection('categories').get();
    // حساب عدد الاختارات فى كل فئه عن طريق انشاء قائمه تحتوى على اسم وعدد الاختارات فى كل فئه
    final categoryData = await Future.wait(
      categories.docs.map((category) async {
        final quizCount = await _fireStore
            .collection('quizzes')
            .where('categoryId', isEqualTo: category.id)
            .count()
            .get();
        return {
          'name': category.data()['name'] as String,
          'count': quizCount.count,
        };
      }),
    );
    // هذا ما ترجعه الداله
    return {
      'totalCategory': categoriesCount.count,
      'totalQuiz': quizzesCount.count,
      'lastestQuiz': lastQuizzes.docs,
      'categoryData': categoryData,
    };
  }

  String _formateDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: color.withOpacity(0.1),
              ),
              child: Icon(icon, color: color, size: 25),
            ),
            SizedBox(height: 24),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 32),
              ),
              SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: FutureBuilder(
        future: fetchStatistic(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final Map<String, dynamic> states = snapshot.data!;
          final List<dynamic> categoryData = states['categoryData'] ?? [];
          final List<QueryDocumentSnapshot> lastQuizzes =
              states['lastestQuizzes'] ?? [];

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Admin",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Hear's your application overview",
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          "Total Categories",
                          states['totalCategory'].toString(),
                          Icons.category_rounded,
                          AppTheme.primaryColor,
                        ),
                      ),
                      Expanded(
                        child: _buildStatCard(
                          "Total Quizzes",
                          states['totalQuiz'].toString(),
                          Icons.quiz_rounded,
                          AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.pie_chart_rounded,
                                color: AppTheme.primaryColor,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Category Statictic",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: categoryData.length,
                            itemBuilder: (context, index) {
                              final category = categoryData[index];
                              final totalQuizzes = categoryData.fold<int>(
                                0,
                                (sum, item) => (sum + (item['count'] as int)),
                              );
                              final precentage = totalQuizzes > 0
                                  ? (category['count'] as int) /
                                        totalQuizzes *
                                        100
                                  : 0;
                              return Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            category["name"] as String,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.textPrimaryColor,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            "${category['count']} ${(category['count'] as int) == 1 ? 'quiz' : "quizzes"}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  AppTheme.textSecondaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: AppTheme.primaryColor
                                            .withOpacity(0.1),
                                      ),
                                      child: Text(
                                        "${precentage.toStringAsFixed(1)}%",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.history_rounded,
                                color: AppTheme.primaryColor,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Recent Activity",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: lastQuizzes.length,
                            itemBuilder: (context, index) {
                              final quiz =
                                  lastQuizzes[index].data()
                                      as Map<String, dynamic>;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.quiz_rounded,
                                        color: AppTheme.primaryColor,
                                        size: 20,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            quiz['title'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textPrimaryColor,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            "${'Created on ${_formateDate(quiz['createdAt'].toDate())}'}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  AppTheme.textSecondaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.speed_rounded,
                                color: AppTheme.primaryColor,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Quis Actions",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.9,
                            children: [
                              _buildDashboardCard(
                                context,
                                'Quizzes',
                                Icons.quiz_rounded,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ManageQuizzesScreen(),
                                    ),
                                  );
                                },
                              ),
                              _buildDashboardCard(
                                context,
                                "Categories",
                                Icons.category_rounded,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ManageCategoriesScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quiz/theme/theme.dart';

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
    final categoryData = Future.wait(
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
    );
  }
}

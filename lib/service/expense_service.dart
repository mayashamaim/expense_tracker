import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/model/expense.dart';
import 'package:flutter/material.dart';

class ExpenseService {
  final CollectionReference _expenseCollection =
      FirebaseFirestore.instance.collection('expenses');

  Future<void> addExpense(Expense expense) async {
    await _expenseCollection.doc(expense.id).set({
      'title': expense.title,
      'amount': expense.amount,
      'date': expense.date.toIso8601String(),
      'category': expense.category.toString(),
    });
  }

  /// Updates an existing expense in Firestore.
  Future<void> updateExpense(Expense expense) async {
    await _expenseCollection.doc(expense.id).update({
      'title': expense.title,
      'amount': expense.amount,
      'date': expense.date.toIso8601String(),
      'category': expense.category.toString(),
    });
  }

  /// Deletes an expense from Firestore.
  Future<void> deleteExpense(String expenseId) async {
    await _expenseCollection.doc(expenseId).delete();
  }

  Future<List<Expense>> getExpenses() async {
    try {
      QuerySnapshot snapshot = await _expenseCollection.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Expense.fromMap(data, doc.id);
      }).toList();
    } catch (error) {
      debugPrint("Error fetching expenses: $error");
      return [];
    }
  }
}

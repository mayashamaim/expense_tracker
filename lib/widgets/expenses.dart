import 'package:expense_tracker/model/expense.dart';
import 'package:expense_tracker/service/expense_service.dart';
import 'package:expense_tracker/widgets/expenses-list/expenses_list.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:expense_tracker/widgets/edit_expense.dart'; 
import 'package:flutter/material.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  final ExpenseService _expenseService = ExpenseService();
  late Future<List<Expense>> _futureExpenses;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  // Fetch expenses from Firestore
  void _fetchExpenses() {
    _futureExpenses = _expenseService.getExpenses();
  }

  // Refresh expenses by re-fetching
  void _refreshExpenses() {
    setState(() {
      _fetchExpenses();
    });
  }

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewExpense(
        onAddExpense: (expense) async {
          await _expenseService.addExpense(expense);
          _refreshExpenses();
        },
      ),
    );
  }

  void _openEditExpenseOverlay(Expense expense) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => EditExpense(
        expense: expense,
        onUpdateExpense: (updatedExpense) async {
          await _expenseService.updateExpense(updatedExpense);
          _refreshExpenses();
        },
      ),
    );
  }

  Future<void> _removeExpense(Expense expense) async {
    await _expenseService.deleteExpense(expense.id);
    _refreshExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter ExpenseTracker'),
        actions: [
          IconButton(
            onPressed: _openAddExpenseOverlay,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder<List<Expense>>(
        future: _futureExpenses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final expenses = snapshot.data ?? [];
          if (expenses.isEmpty) {
            return const Center(
                child: Text('No expenses found. Start adding some!'));
          }
          return Column(
            children: [
              Chart(expenses: expenses),
              Expanded(
                child: ExpensesList(
                  expenses: expenses,
                  onRemoveExpense: _removeExpense,
                  onEditExpense: _openEditExpenseOverlay,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

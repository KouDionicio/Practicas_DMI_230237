import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ButtonsScreen extends StatelessWidget {
  static const String name = 'buttons_screen';

  const ButtonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buttons Screen')),
      body: const _ButtonsView(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () {
          context.pop();
        },
      ),
    );
  }
}

class _ButtonsView extends StatelessWidget {
  const _ButtonsView();

  void _showFeedback(BuildContext context, String button) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$button presionado')));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Wrap(
          spacing: 10,
          alignment: WrapAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _showFeedback(context, 'Elevated'),
              child: const Text('Elevated'),
            ),
            const ElevatedButton(
              onPressed: null,
              child: Text('Elevated Disabled'),
            ),

            ElevatedButton.icon(
              onPressed: () => _showFeedback(context, 'Elevated Icon'),
              icon: const Icon(Icons.access_alarm_rounded),
              label: const Text('Elevated Icon'),
            ),

            FilledButton(
              onPressed: () => _showFeedback(context, 'Filled'),
              child: const Text('Filled'),
            ),
            FilledButton.icon(
              onPressed: () => _showFeedback(context, 'Filled Icon'),
              icon: const Icon(Icons.accessibility_new),
              label: const Text('Filled Icon'),
            ),

            OutlinedButton(
              onPressed: () => _showFeedback(context, 'Outlined'),
              child: const Text('Outline'),
            ),
            OutlinedButton.icon(
              onPressed: () => _showFeedback(context, 'Outlined Icon'),
              label: const Text('Outline Icon'),
              icon: const Icon(Icons.terminal),
            ),

            TextButton(
              onPressed: () => _showFeedback(context, 'Text'),
              child: const Text('Text'),
            ),
            TextButton.icon(
              onPressed: () => _showFeedback(context, 'Text Icon'),
              icon: const Icon(Icons.account_box_outlined),
              label: const Text('Text Icon'),
            ),

            const CustomButton(),

            IconButton(
              onPressed: () => _showFeedback(context, 'IconButton'),
              icon: const Icon(Icons.app_registration_rounded),
            ),
            IconButton(
              onPressed: () => _showFeedback(context, 'IconButton estilizado'),
              icon: const Icon(Icons.app_registration_rounded),
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(colors.primary),
                iconColor: const WidgetStatePropertyAll(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  const CustomButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: colors.primary,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Botón personalizado presionado')),
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text('Hola Mundo', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

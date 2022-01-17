import 'stack_sort.dart';

export 'stack_sort.dart';

class StackConfig {
  final StackSort push;
  final StackSort pop;

  const StackConfig({
    this.push = StackSort.oldDown,
    this.pop = StackSort.oldUp,
  });
}

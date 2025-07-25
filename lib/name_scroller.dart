import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_demo/name_scroller_bloc.dart';

class NameScroller extends StatefulWidget {
  const NameScroller({super.key});

  @override
  State<NameScroller> createState() => _NameScrollerState();
}

class _NameScrollerState extends State<NameScroller>
    with TickerProviderStateMixin {
  late AnimationController _scrollAnimationController;
  late ScrollController _scrollController;
  late List<String> _displayParticipants;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _displayParticipants = [];

    _scrollAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50), // 更短的 duration，实现更频繁的更新
    )..addListener(() {
        if (_scrollController.hasClients && _scrollController.position.hasContentDimensions) {
          double scrollAmount = 5.0; // 每次滚动的像素量，可以调整速度
          double newOffset = _scrollController.offset + scrollAmount;

          if (newOffset >= _scrollController.position.maxScrollExtent) {
            newOffset = 0.0; // 循环回起点
          }
          _scrollController.jumpTo(newOffset);
        }
      });
  }

  @override
  void dispose() {
    _scrollAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startScrolling(List<String> participants) {
    _updateDisplayParticipants(participants);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollAnimationController.repeat();
      }
    });
  }

  void _stopScrolling(String? winner, List<String> participants) {
    _scrollAnimationController.stop();

    if (winner == null || participants.isEmpty || !_scrollController.hasClients || !_scrollController.position.hasContentDimensions) return;

    final itemHeight = 50.0;
    final scrollerHeight = _scrollController.position.viewportDimension;
    final currentOffset = _scrollController.offset;

    final winnerIndices = _displayParticipants
        .asMap()
        .entries
        .where((entry) => entry.value == winner)
        .map((entry) => entry.key)
        .toList();

    if (winnerIndices.isEmpty) return;

    final scrollerCenter = currentOffset + scrollerHeight / 2;
    int closestIndex = winnerIndices.reduce((a, b) {
      final aCenter = a * itemHeight + itemHeight / 2;
      final bCenter = b * itemHeight + itemHeight / 2;
      final aDiff = (aCenter - scrollerCenter).abs();
      final bDiff = (bCenter - scrollerCenter).abs();
      return aDiff < bDiff ? a : b;
    });

    double targetOffset =
        (closestIndex * itemHeight) - (scrollerHeight / 2) + (itemHeight / 2);

    targetOffset = targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent);

    _scrollController
        .animateTo(
          targetOffset,
          duration: const Duration(seconds: 3),
          curve: Curves.easeOut,
        )
        .whenComplete(() {
      if (mounted) {
        context.read<NameScrollerBloc>().add(ShowResult());
      }
    });
  }

  void _updateDisplayParticipants(List<String> participants) {
    if (participants.isEmpty) {
      _displayParticipants = [];
      return;
    }
    setState(() {
      _displayParticipants = List.generate(
        100,
        (index) => participants[index % participants.length],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NameScrollerBloc, NameScrollerState>(
      listener: (context, state) {
        if (state.status == ScrollerStatus.scrolling) {
          _startScrolling(state.participants);
        }
        else if (state.status == ScrollerStatus.stopped) {
          _stopScrolling(state.winner, state.participants);
        }
      },
      builder: (context, state) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black,
                Colors.black,
                Colors.transparent,
              ],
              stops: const [0.0, 0.25, 0.75, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: _displayParticipants.isEmpty
              ? const Center(child: Text('添加参与者'))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: _displayParticipants.length,
                  itemBuilder: (context, index) {
                    final name = _displayParticipants[index];
                    final isWinner = (state.status == ScrollerStatus.result || state.status == ScrollerStatus.stopped) &&
                        state.winner != null &&
                        name == state.winner;
                    return Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: isWinner
                          ? BoxDecoration(
                              color: Colors.amber.withOpacity(0.9),
                              border: Border.all(color: Colors.red, width: 3),
                              borderRadius: BorderRadius.circular(8),
                            )
                          : null,
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: isWinner ? 28 : 24,
                          fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                          color: isWinner ? Colors.red.shade900 : Colors.black87,
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
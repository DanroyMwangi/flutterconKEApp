import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttercon/common/data/enums/bookmark_status.dart';
import 'package:fluttercon/common/widgets/app_bar/app_bar.dart';
import 'package:fluttercon/core/theme/theme_colors.dart';
import 'package:fluttercon/features/sessions/cubit/fetch_grouped_sessions_cubit.dart';
import 'package:fluttercon/features/sessions/ui/widgets/day_sessions_view.dart';
import 'package:fluttercon/features/sessions/ui/widgets/day_tab_view.dart';

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen>
    with SingleTickerProviderStateMixin {
  int _viewIndex = 0;
  int _currentTab = 0;
  int _availableTabs = 3;

  bool _isBookmarked = false;

  @override
  void initState() {
    context.read<FetchGroupedSessionsCubit>().fetchGroupedSessions();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        selectedIndex: 2,
        selectedScheduleIndex: _viewIndex,
        onCompactTapped: () => setState(() {
          _viewIndex = 0;
        }),
        onScheduleTapped: () => setState(() {
          _viewIndex = 1;
        }),
      ),
      body: DefaultTabController(
        length: _availableTabs,
        child: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => <Widget>[
              SliverToBoxAdapter(
                child: Row(
                  children: [
                    BlocConsumer<FetchGroupedSessionsCubit,
                        FetchGroupedSessionsState>(
                      listener: (context, state) {
                        state.mapOrNull(
                          loaded: (loaded) {
                            setState(() {
                              _availableTabs = loaded.groupedSessions.length;
                            });
                          },
                        );
                      },
                      builder: (context, state) => state.maybeWhen(
                        orElse: () => const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: CircularProgressIndicator(),
                        ),
                        loaded: (groupedSessions) => TabBar(
                          onTap: (value) => setState(() {
                            Logger().d(value);
                            _currentTab = value;
                          }),
                          dividerColor: Colors.white,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          indicatorColor: Colors.white,
                          overlayColor:
                              WidgetStateProperty.all(Colors.transparent),
                          tabs: [
                            ...groupedSessions.keys.map(
                              (date) => DayTabView(
                                date: DateFormat.d().format(
                                  DateFormat('MM/dd/yyyy').parse(date),
                                ),
                                day: groupedSessions.keys
                                        .toList()
                                        .indexOf(date) +
                                    1,
                                isActive: _currentTab ==
                                    groupedSessions.keys.toList().indexOf(date),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          Switch(
                            value: _isBookmarked,
                            onChanged: (newValue) {
                              setState(() {
                                _isBookmarked = newValue;
                              });

                              if (_isBookmarked) {
                                context
                                    .read<FetchGroupedSessionsCubit>()
                                    .fetchGroupedSessions(
                                      bookmarkStatus: BookmarkStatus.bookmarked,
                                    );
                              }

                              if (!_isBookmarked) {
                                context
                                    .read<FetchGroupedSessionsCubit>()
                                    .fetchGroupedSessions();
                              }
                            },
                            trackOutlineWidth: WidgetStateProperty.all(1),
                            trackColor: WidgetStateProperty.all(Colors.black),
                            activeTrackColor: ThemeColors.orangeColor,
                            activeColor: ThemeColors.orangeColor,
                            thumbColor: WidgetStateProperty.all(Colors.white),
                            thumbIcon: WidgetStateProperty.all(
                              const Icon(Icons.star_border_rounded),
                            ),
                          ),
                          const Text(
                            'My Sessions',
                            style: TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: Colors.grey),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _isBookmarked ? 'My Sessions' : 'All Sessions',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.blueColor,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            ],
            body: BlocBuilder<FetchGroupedSessionsCubit,
                FetchGroupedSessionsState>(
              builder: (context, state) => state.maybeWhen(
                orElse: () => const Center(child: CircularProgressIndicator()),
                loaded: (groupedSessions) => TabBarView(
                  children: groupedSessions.values
                      .map(
                        (dailySessions) => DaySessionsView(
                          sessions: dailySessions,
                          isCompactView: _viewIndex == 0,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

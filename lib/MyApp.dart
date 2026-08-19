import 'package:flutter_quill/flutter_quill.dart'
    show FlutterQuillLocalizations;
import 'package:higherground/audio_player/player_page.dart';
import 'package:higherground/widgets/AppLogo.dart';
import 'package:higherground/audio_player/radio_player.dart';
import 'package:higherground/bible/BibleScreen.dart';
import 'package:higherground/bible/BibleSearchScreen.dart';
import 'package:higherground/bible/BibleTranslator.dart';
import 'package:higherground/bible/BibleVerseCompare.dart';
import 'package:higherground/bible/BibleVersionsScreen.dart';
import 'package:higherground/bible/ColoredHighightedVerses.dart';
import 'package:higherground/database/SQLiteDbProvider.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/livetvplayer/LivestreamsPlayer.dart';
import 'package:higherground/models/Articles.dart';
import 'package:higherground/models/Bible.dart';
import 'package:higherground/models/Books.dart';
import 'package:higherground/models/ChatMessages.dart';
import 'package:higherground/models/CommentsArguement.dart';
import 'package:higherground/models/Devotionals.dart';
import 'package:higherground/models/Downloads.dart';
import 'package:higherground/models/Events.dart';
import 'package:higherground/models/Groups.dart';
import 'package:higherground/models/Hymns.dart';
import 'package:higherground/models/Inbox.dart';
import 'package:higherground/models/LiveStreams.dart';
import 'package:higherground/models/Media.dart';
import 'package:higherground/models/Notes.dart';
import 'package:higherground/models/Playlists.dart';
import 'package:higherground/models/Prayers.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'package:higherground/models/Testimony.dart';
import 'package:higherground/models/UserEvents.dart';
import 'package:higherground/models/UserPosts.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/notes/NewNoteScreen.dart';
import 'package:higherground/notes/NotesEditorScreen.dart';
import 'package:higherground/notes/NotesListScreen.dart';
import 'package:higherground/providers/AudioPlayerModel.dart';
import 'package:higherground/providers/ChatManager.dart';
import 'package:higherground/providers/events.dart';
import 'package:higherground/screens/AddPlaylistScreen.dart';
import 'package:higherground/screens/ArticleViewer.dart';
import 'package:higherground/screens/ArticlesScreen.dart';
import 'package:higherground/screens/AudioScreen.dart';
import 'package:higherground/screens/AuthPage.dart';
import 'package:higherground/screens/BookmarkScreen.dart';
import 'package:higherground/screens/BookmarkedHymnsListScreen.dart';
import 'package:higherground/screens/BooksScreen.dart';
import 'package:higherground/screens/BooksViewerScreen.dart';
import 'package:higherground/screens/BranchesScreen.dart';
import 'package:higherground/screens/DevotionalViewerScreen.dart';
import 'package:higherground/screens/DevotionalsScreen.dart';
import 'package:higherground/screens/Downloader.dart';
import 'package:higherground/screens/EventsListScreen.dart';
import 'package:higherground/screens/EventsViewerScreen.dart';
import 'package:higherground/screens/GroupEventsListScreen.dart';
import 'package:higherground/screens/GroupsScreen.dart';
import 'package:higherground/screens/HymnsListScreen.dart';
import 'package:higherground/screens/HymnsViewerScreen.dart';
import 'package:higherground/screens/InboxListScreen.dart';
import 'package:higherground/screens/InboxViewerScreen.dart';
import 'package:higherground/screens/InitPage.dart';
import 'package:higherground/screens/ItemsViewer.dart';
import 'package:higherground/screens/LivestreamsScreen.dart';
import 'package:higherground/screens/MyGroupsScreen.dart';
import 'package:higherground/screens/OnboardingPage.dart';
import 'package:higherground/screens/PhotosScreen.dart';
import 'package:higherground/screens/PlaylistMediaScreen.dart';
import 'package:higherground/screens/PlaylistsScreen.dart';
import 'package:higherground/screens/PostPrayerScreen.dart';
import 'package:higherground/screens/PostTestimonyScreen.dart';
import 'package:higherground/screens/PrayerViewer.dart';
import 'package:higherground/screens/PrayersScreen.dart';
import 'package:higherground/screens/RadioScreen.dart';
import 'package:higherground/screens/SearchScreen.dart';
import 'package:higherground/screens/SettingsPage.dart';
import 'package:higherground/screens/TestimoniessScreen.dart';
import 'package:higherground/screens/TestimonyViewer.dart';
import 'package:higherground/screens/UpdateProfile.dart';
import 'package:higherground/screens/UserProfile.dart';
import 'package:higherground/screens/VideoScreen.dart';
import 'package:higherground/socials/FollowPeople.dart';
import 'package:higherground/socials/FollowPeopleSection.dart';
import 'package:higherground/socials/MakePostScreen.dart';
import 'package:higherground/socials/NotificationSection.dart';
import 'package:higherground/socials/PinnedPosts.dart';
import 'package:higherground/socials/PostCommentsScreen.dart';
import 'package:higherground/socials/PostRepliesScreen.dart';
import 'package:higherground/socials/SocialActivity.dart';
import 'package:higherground/socials/UpdateUserProfile.dart';
import 'package:higherground/socials/UserFollowersScreen.dart';
import 'package:higherground/socials/UserProfileScreen.dart';
import 'package:higherground/socials/UserdataPosts.dart';
import 'package:higherground/socials/chat/ChatConversations.dart';
import 'package:higherground/socials/chat/ChatUsersScreen.dart';
import 'package:higherground/models/MarketplaceItem.dart';
import 'package:higherground/screens/CounselingScreen.dart';
import 'package:higherground/screens/DonateScreen.dart';
import 'package:higherground/screens/MarketplaceBrowseScreen.dart';
import 'package:higherground/screens/MarketplaceItemDetailScreen.dart';
import 'package:higherground/screens/MarketplaceSubmitScreen.dart';
import 'package:higherground/screens/MyMarketplaceListingsScreen.dart';
import 'package:higherground/screens/SubmitCounselingScreen.dart';
import 'package:higherground/screens/WellnessScreen.dart';
import 'package:higherground/screens/PartnershipScreen.dart';
import 'package:higherground/screens/MyPartnershipScreen.dart';
import 'package:higherground/screens/PartnershipHistoryScreen.dart';
import 'package:higherground/screens/SubmitPartnershipScreen.dart';
import 'package:higherground/screens/PartnershipPaymentScreen.dart';
import 'package:higherground/models/PartnershipTier.dart';
import 'package:higherground/socials/chat/SelectChatPeople.dart';
import 'package:higherground/socials/chat/photoviewer.dart';
import 'package:higherground/socials/likesPostPeople.dart';
import 'package:higherground/utils/app_themes.dart';
import 'package:higherground/video_player/VideoPlayer.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import './screens/HomePage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import './service/Firebase.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  //AppStateManager appStateManager;
  AppLifecycleState? state;
  bool isChatOpen = false;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey(
    debugLabel: "Main Navigator",
  );

  navigateMedia(Media media) {
    print("push notification media = " + media.title!);
    List<Media?> mediaList = [];
    mediaList.add(media);
    if (media.mediaType!.toLowerCase() == "audio") {
      print("audio media = " + media.title!);
      Provider.of<AudioPlayerModel>(
        context,
        listen: false,
      ).preparePlaylist(mediaList, media);
      navigatorKey.currentState!.pushNamed(PlayPage.routeName);
    } else {
      print("video media = " + media.title!);

      navigatorKey.currentState!.pushNamed(
        VideoPlayer.routeName,
        arguments: ScreenArguements(
          position: 0,
          items: media,
          itemsList: mediaList,
        ),
      );
    }
  }

  navigateLivestreams(LiveStreams liveStreams) {
    navigatorKey.currentState!.pushNamed(
      LivestreamsPlayer.routeName,
      arguments: ScreenArguements(items: liveStreams),
    );
  }

  navigateInbox(Inbox inbox) {
    navigatorKey.currentState!.pushNamed(
      InboxViewerScreen.routeName,
      arguments: ScreenArguements(position: 0, items: inbox, itemsList: []),
    );
  }

  navigateSocials() {
    navigatorKey.currentState!.pushNamed(InboxListScreenState.routeName);
  }

  navigateChat(Userdata partner) async {
    Userdata? userdata = await SQLiteDbProvider.db.getUserData();
    if (userdata == null) {
      navigatorKey.currentState!.pushNamed(AuthPage.routeName);
      //eventBus.fire(AppEvents.ONCHATCONVERSATIONCLOSED);
    } else {
      if (isChatOpen) {
        navigatorKey.currentState!.pop();
      }
      eventBus.fire(StartPartnerChatEvent(partner));
      navigatorKey.currentState!.pushNamed(ChatConversations.routeName);
    }
  }

  navigateItem(String id, String type) {
    Map data = {"id": id.toString(), "type": type};
    print("map data =" + data.toString());
    navigatorKey.currentState!.pushNamed(
      ItemsViewer.routeName,
      arguments: data,
    );
  }

  @override
  void initState() {
    // No Firebase Web app is registered for this project, so FCM/push
    // setup (which needs Firebase.initializeApp() to have run) is skipped on web.
    if (!kIsWeb) {
      Firebase(
        navigateMedia,
        navigateSocials,
        navigateInbox,
        navigateLivestreams,
        navigateChat,
        navigateItem,
      ).init();
    }
    Provider.of<ChatManager>(context, listen: false).init();

    WidgetsBinding.instance.addObserver(this);
    eventBus.fire(OnAppStateChanged("active"));
    eventBus.on<OnChatOpen>().listen((event) {
      isChatOpen = event.isOpen;
    });
    eventBus.on<OnAppOffline>().listen((event) {
      print("App offline event called");
      print("please store = " + event.items.toString());
    });
    super.initState();
  }

  @override
  void dispose() {
    print("widget is disposed");
    WidgetsBinding.instance.removeObserver(this);
    //Provider.of<AudioPlayerModel>(context, listen: false).cleanUpResources();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appLifecycleState) async {
    state = appLifecycleState;
    print("Current app state = " + appLifecycleState.toString());
    print(":::::::");
    switch (state) {
      case null:
        break;
      case AppLifecycleState.paused:
        eventBus.fire(OnAppStateChanged("idle"));
        break;
      case AppLifecycleState.resumed:
        eventBus.fire(OnAppStateChanged("active"));
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    //appStateManager = Provider.of<AppStateManager>(context);
    final platform = Theme.of(context).platform;
    return RefreshConfiguration(
      footerTriggerDistance: 15,
      dragSpeedRatio: 0.91,
      headerBuilder: () => MaterialClassicHeader(),
      footerBuilder: () => ClassicFooter(),
      enableLoadingWhenNoData: false,
      shouldFooterFollowWhenNotFull: (state) {
        // If you want load more with noMoreData state ,may be you should return false
        return false;
      },
      //autoLoad: true,
      child: MaterialApp(
        theme: appThemeData[AppTheme.White],
        navigatorKey: navigatorKey,
        title: 'MFM Lekki',
        localizationsDelegates: [
          FlutterQuillLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [Locale("en"), Locale("pt"), Locale("fr")],
        locale: Locale("en"),
        home: SplashScreen(), //widget._defaultHome,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: (settings) {
          if (settings.name == OnboardingPage.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return OnboardingPage();
              },
            );
          }

          if (settings.name == InitPage.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return InitPage();
              },
            );
          }

          if (settings.name == BranchesScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return BranchesScreen();
              },
            );
          }

          if (settings.name == PrayersScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return PrayersScreen();
              },
            );
          }

          if (settings.name == FollowPeopleSection.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return FollowPeopleSection();
              },
            );
          }

          if (settings.name == GroupsScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return GroupsScreen();
              },
            );
          }

          if (settings.name == TestimoniessScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return TestimoniessScreen();
              },
            );
          }

          if (settings.name == SearchScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return SearchScreen();
              },
            );
          }

          if (settings.name == ArticleViewer.routeName) {
            //envisionaps@gmail.com
            return MaterialPageRoute(
              builder: (context) {
                return ArticleViewer(articles: settings.arguments as Articles);
              },
            );
          }

          if (settings.name == PrayerViewer.routeName) {
            //envisionaps@gmail.com
            return MaterialPageRoute(
              builder: (context) {
                return PrayerViewer(prayers: settings.arguments as Prayers);
              },
            );
          }

          if (settings.name == TestimonyViewer.routeName) {
            //envisionaps@gmail.com
            return MaterialPageRoute(
              builder: (context) {
                return TestimonyViewer(
                  testimony: settings.arguments as Testimony,
                );
              },
            );
          }

          if (settings.name == ArticleViewer.routeName) {
            //envisionaps@gmail.com
            return MaterialPageRoute(
              builder: (context) {
                return ArticleViewer(articles: settings.arguments as Articles);
              },
            );
          }

          if (settings.name == GroupEventsListScreen.routeName) {
            //envisionaps@gmail.com
            return MaterialPageRoute(
              builder: (context) {
                return GroupEventsListScreen(
                  groups: settings.arguments as Groups,
                );
              },
            );
          }

          if (settings.name == BooksViewerScreen.routeName) {
            //envisionaps@gmail.com
            return MaterialPageRoute(
              builder: (context) {
                return BooksViewerScreen(books: settings.arguments as Books);
              },
            );
          }

          if (settings.name == UpdateProfile.routeName) {
            //envisionaps@gmail.com
            return MaterialPageRoute(
              builder: (context) {
                return UpdateProfile(userdata: settings.arguments as Userdata);
              },
            );
          }

          if (settings.name == UserProfile.routeName) {
            //envisionaps@gmail.com
            return MaterialPageRoute(
              builder: (context) {
                return UserProfile(userdata: settings.arguments as Userdata);
              },
            );
          }

          if (settings.name == AuthPage.routeName) {
            bool status = settings.arguments == null
                ? false
                : settings.arguments as bool;
            return MaterialPageRoute(
              builder: (context) {
                return AuthPage(status);
              },
            );
          }

          if (settings.name == AddPlaylistScreen.routeName) {
            // Cast the arguments to the correct type: ScreenArguments.
            final ScreenArguements? args =
                settings.arguments as ScreenArguements?;
            return MaterialPageRoute(
              builder: (context) {
                return AddPlaylistScreen(media: args!.items as Media?);
              },
            );
          }

          if (settings.name == PlaylistMediaScreen.routeName) {
            // Cast the arguments to the correct type: ScreenArguments.
            final ScreenArguements? args =
                settings.arguments as ScreenArguements?;
            return MaterialPageRoute(
              builder: (context) {
                return PlaylistMediaScreen(
                  playlists: args!.items as Playlists?,
                );
              },
            );
          }

          if (settings.name == VideoPlayer.routeName) {
            // Cast the arguments to the correct type: ScreenArguments.
            final ScreenArguements? args =
                settings.arguments as ScreenArguements?;
            return MaterialPageRoute(
              builder: (context) {
                return VideoPlayer(
                  media: args!.items as Media?,
                  mediaList: args.itemsList as List<Media?>?,
                );
              },
            );
          }

          if (settings.name == BibleVerseCompare.routeName) {
            // Cast the arguments to the correct type: ScreenArguments.
            final ScreenArguements? args =
                settings.arguments as ScreenArguements?;
            return MaterialPageRoute(
              builder: (context) {
                return BibleVerseCompare(bible: args!.items as Bible?);
              },
            );
          }

          if (settings.name == BibleTranslator.routeName) {
            // Cast the arguments to the correct type: ScreenArguments.
            final ScreenArguements? args =
                settings.arguments as ScreenArguements?;
            return MaterialPageRoute(
              builder: (context) {
                return BibleTranslator(bible: args!.items as Bible?);
              },
            );
          }

          if (settings.name == LivestreamsPlayer.routeName) {
            // Cast the arguments to the correct type: ScreenArguments.
            final ScreenArguements? args =
                settings.arguments as ScreenArguements?;
            return MaterialPageRoute(
              builder: (context) {
                return LivestreamsPlayer(
                  liveStreams: args!.items as LiveStreams?,
                );
              },
            );
          }

          if (settings.name == ColoredHighightedVerses.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return ColoredHighightedVerses();
              },
            );
          }

          if (settings.name == BibleSearchScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return BibleSearchScreen();
              },
            );
          }

          if (settings.name == MyGroupsScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return MyGroupsScreen();
              },
            );
          }

          if (settings.name == PostPrayerScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return PostPrayerScreen();
              },
            );
          }

          if (settings.name == NotificationSection.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return NotificationSection();
              },
            );
          }

          if (settings.name == PostTestimonyScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return PostTestimonyScreen();
              },
            );
          }

          if (settings.name == BookmarksScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return BookmarksScreen();
              },
            );
          }

          if (settings.name == PlaylistsScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return PlaylistsScreen();
              },
            );
          }

          if (settings.name == EventsListScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return EventsListScreen();
              },
            );
          }

          if (settings.name == DevotionalsScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return DevotionalsScreen();
              },
            );
          }

          if (settings.name == NotesListScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return NotesListScreen();
              },
            );
          }

          if (settings.name == BibleScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return BibleScreen();
              },
            );
          }

          if (settings.name == EventsViewerScreen.routeName) {
            // Cast the arguments to the correct type: ScreenArguments.
            final ScreenArguements? args =
                settings.arguments as ScreenArguements?;
            return MaterialPageRoute(
              builder: (context) {
                return EventsViewerScreen(events: args!.items as Events?);
              },
            );
          }

          if (settings.name == DevotionalViewerScreen.routeName) {
            // Cast the arguments to the correct type: ScreenArguments.
            final ScreenArguements? args =
                settings.arguments as ScreenArguements?;
            return MaterialPageRoute(
              builder: (context) {
                return DevotionalViewerScreen(
                  devotionals: args!.items as Devotionals?,
                );
              },
            );
          }

          if (settings.name == HymnsViewerScreen.routeName) {
            // Cast the arguments to the correct type: ScreenArguments.
            final ScreenArguements? args =
                settings.arguments as ScreenArguements?;
            return MaterialPageRoute(
              builder: (context) {
                return HymnsViewerScreen(hymns: args!.items as Hymns?);
              },
            );
          }

          if (settings.name == BookmarkedHymnsListScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return BookmarkedHymnsListScreen();
              },
            );
          }

          if (settings.name == HymnsListScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return HymnsListScreen();
              },
            );
          }

          if (settings.name == InboxListScreenState.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return InboxListScreenState();
              },
            );
          }

          if (settings.name == InboxViewerScreen.routeName) {
            // Cast the arguments to the correct type: ScreenArguments.
            final ScreenArguements? args =
                settings.arguments as ScreenArguements?;
            return MaterialPageRoute(
              builder: (context) {
                return InboxViewerScreen(inbox: args!.items as Inbox?);
              },
            );
          }

          if (settings.name == BibleVersionsScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return BibleVersionsScreen();
              },
            );
          }

          if (settings.name == VideoScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return VideoScreen();
              },
            );
          }

          if (settings.name == AudioScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return AudioScreen();
              },
            );
          }

          if (settings.name == NotesEditorScreen.routeName) {
            final ScreenArguements? args =
                settings.arguments as ScreenArguements?;
            if (args != null) {
              return MaterialPageRoute(
                builder: (context) {
                  return NotesEditorScreen(notes: args.items as Notes?);
                },
              );
            }
            return MaterialPageRoute(
              builder: (context) {
                return NotesEditorScreen();
              },
            );
          }

          if (settings.name == PhotosScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return PhotosScreen();
              },
            );
          }

          if (settings.name == RadioScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return RadioScreen();
              },
            );
          }

          if (settings.name == ArticlesScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return ArticlesScreen();
              },
            );
          }

          if (settings.name == BooksScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return BooksScreen();
              },
            );
          }

          if (settings.name == ItemsViewer.routeName) {
            Map items = (settings.arguments as Map);
            return MaterialPageRoute(
              builder: (context) {
                return ItemsViewer(id: items['id'], type: items['type']);
              },
            );
          }

          if (settings.name == LivestreamsScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return LivestreamsScreen();
              },
            );
          }

          if (settings.name == NewNotesScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return NewNotesScreen();
              },
            );
          }

          if (settings.name == PlayPage.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return PlayPage();
              },
            );
          }

          if (settings.name == RadioPlayer.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return RadioPlayer();
              },
            );
          }

          if (settings.name == Downloader.routeName) {
            // Cast the arguments to the correct type: ScreenArguments.
            final ScreenArguements? args =
                settings.arguments as ScreenArguements?;
            return MaterialPageRoute(
              builder: (context) {
                return Downloader(
                  downloads: args!.items as Downloads?,
                  platform: platform,
                );
              },
            );
          }

          //socials
          if (settings.name == FollowPeople.routeName) {
            // Cast the arguments to the correct type: ScreenArguments.
            final ScreenArguements? args =
                settings.arguments as ScreenArguements?;
            return MaterialPageRoute(
              builder: (context) {
                return FollowPeople(check: args!.check);
              },
            );
          }

          if (settings.name == UserProfileScreen.routeName) {
            // Cast the arguments to the correct type: ScreenArguments.
            final ScreenArguements? args =
                settings.arguments as ScreenArguements?;
            return MaterialPageRoute(
              builder: (context) {
                return UserProfileScreen(user: args!.items as Userdata?);
              },
            );
          }

          if (settings.name == PinnedPosts.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return PinnedPosts();
              },
            );
          }

          if (settings.name == SocialActivity.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return SocialActivity();
              },
            );
          }

          if (settings.name == UpdateUserProfile.routeName) {
            final ScreenArguements? args =
                settings.arguments as ScreenArguements?;
            return MaterialPageRoute(
              builder: (context) {
                return UpdateUserProfile(check: args == null ? true : false);
              },
            );
          }

          if (settings.name == UserFollowersScreen.routeName) {
            // Cast the arguments to the correct type: ScreenArguments.
            final ScreenArguements? args =
                settings.arguments as ScreenArguements?;
            return MaterialPageRoute(
              builder: (context) {
                return UserFollowersScreen(
                  user: args!.items as Userdata?,
                  option: args.option,
                );
              },
            );
          }

          if (settings.name == SettingsPage.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return SettingsPage();
              },
            );
          }

          if (settings.name == ChatUsersScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return ChatUsersScreen();
              },
            );
          }

          if (settings.name == PhotoViewer.routeName) {
            // Cast the arguments to the correct type: ScreenArguments.
            final ScreenArguements? args =
                settings.arguments as ScreenArguements?;
            return MaterialPageRoute(
              builder: (context) {
                return PhotoViewer(chatMessages: args!.items as ChatMessages?);
              },
            );
          }

          if (settings.name == UserdataPosts.routeName) {
            // Cast the arguments to the correct type: ScreenArguments.
            final ScreenArguements? args =
                settings.arguments as ScreenArguements?;
            return MaterialPageRoute(
              builder: (context) {
                return UserdataPosts(user: args!.items as Userdata?);
              },
            );
          }

          if (settings.name == SelectChatPeople.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return SelectChatPeople();
              },
            );
          }

          if (settings.name == ChatConversations.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return ChatConversations();
              },
            );
          }

          if (settings.name == MakePostScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) {
                return MakePostScreen();
              },
            );
          }

          if (settings.name == MarketplaceBrowseScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) => const MarketplaceBrowseScreen(),
            );
          }

          if (settings.name == MarketplaceSubmitScreen.routeName) {
            final item = settings.arguments as MarketplaceItem?;
            return MaterialPageRoute(
              builder: (context) => MarketplaceSubmitScreen(item: item),
            );
          }

          if (settings.name == MarketplaceItemDetailScreen.routeName) {
            final itemId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => MarketplaceItemDetailScreen(itemId: itemId),
            );
          }

          if (settings.name == MyMarketplaceListingsScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) => const MyMarketplaceListingsScreen(),
            );
          }

          if (settings.name == DonateScreen.routeName) {
            final url = settings.arguments as String? ?? '';
            return MaterialPageRoute(
              builder: (context) => DonateScreen(url: url),
            );
          }

          if (settings.name == CounselingScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) => const CounselingScreen(),
            );
          }

          if (settings.name == SubmitCounselingScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) => const SubmitCounselingScreen(),
            );
          }

          if (settings.name == WellnessScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) =>
                  WellnessScreen(email: settings.arguments as String),
            );
          }

          if (settings.name == PartnershipScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) => const PartnershipScreen(),
            );
          }

          if (settings.name == MyPartnershipScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) => const MyPartnershipScreen(),
            );
          }

          if (settings.name == PartnershipHistoryScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) => const PartnershipHistoryScreen(),
              settings: settings,
            );
          }

          if (settings.name == SubmitPartnershipScreen.routeName) {
            final tiers = settings.arguments as List<PartnershipTier>? ?? [];
            return MaterialPageRoute(
              builder: (context) => const SubmitPartnershipScreen(),
              settings: RouteSettings(
                name: SubmitPartnershipScreen.routeName,
                arguments: tiers,
              ),
            );
          }

          if (settings.name == PartnershipPaymentScreen.routeName) {
            return MaterialPageRoute(
              builder: (context) => const PartnershipPaymentScreen(),
              settings: settings,
            );
          }

          if (settings.name == LikesPostPeople.routeName) {
            // Cast the arguments to the correct type: ScreenArguments.
            final ScreenArguements? args =
                settings.arguments as ScreenArguements?;
            return MaterialPageRoute(
              builder: (context) {
                return LikesPostPeople(userPost: args!.items as UserPosts?);
              },
            );
          }

          if (settings.name == PostCommentsScreen.routeName) {
            // Cast the arguments to the correct type: ScreenArguments.
            final CommentsArguement? args =
                settings.arguments as CommentsArguement?;
            return MaterialPageRoute(
              builder: (context) {
                return PostCommentsScreen(userPosts: args!.item as UserPosts?);
              },
            );
          }

          if (settings.name == PostRepliesScreen.routeName) {
            // Cast the arguments to the correct type: ScreenArguments.
            final CommentsArguement? args =
                settings.arguments as CommentsArguement?;
            return MaterialPageRoute(
              builder: (context) {
                return PostRepliesScreen(
                  item: args!.item,
                  repliesCount: args.commentCount,
                );
              },
            );
          }

          return MaterialPageRoute(
            builder: (context) {
              return HomePage();
            },
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.65,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 2400), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    if (kIsWeb) {
      Navigator.of(context).pushReplacementNamed(AuthPage.routeName);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('user_seen_onboarding_page') ?? false;
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
      seen ? InitPage.routeName : OnboardingPage.routeName,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4338ca), Color(0xFF6366f1), Color(0xFF818cf8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated logo icon
              ScaleTransition(
                scale: _scale,
                child: FadeTransition(
                  opacity: _fade,
                  child: AppLogo(size: 100, radius: 28),
                ),
              ),
              const SizedBox(height: 32),
              // Animated text block
              SlideTransition(
                position: _slide,
                child: FadeTransition(
                  opacity: _fade,
                  child: Column(
                    children: [
                      Text(
                        t.appname,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Your faith community, always with you',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.68),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

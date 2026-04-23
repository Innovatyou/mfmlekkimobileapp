
/*
 * Generated file. Do not edit.
 *
 * Locales: 4
 * Strings: 1364 (341.0 per locale)
 *
 * Built on 2024-04-10 at 16:22 UTC
 */

import 'package:flutter/widgets.dart';

const AppLocale _baseLocale = AppLocale.en;
AppLocale _currLocale = _baseLocale;

/// Supported locales, see extension methods below.
///
/// Usage:
/// - LocaleSettings.setLocale(AppLocale.en) // set locale
/// - Locale locale = AppLocale.en.flutterLocale // get flutter locale from enum
/// - if (LocaleSettings.currentLocale == AppLocale.en) // locale check
enum AppLocale {
	en, // 'en' (base locale, fallback)
	es, // 'es'
	fr, // 'fr'
	pt, // 'pt'
}

/// Method A: Simple
///
/// No rebuild after locale change.
/// Translation happens during initialization of the widget (call of t).
///
/// Usage:
/// String a = t.someKey.anotherKey;
/// String b = t['someKey.anotherKey']; // Only for edge cases!
_StringsEn _t = _currLocale.translations;
_StringsEn get t => _t;

/// Method B: Advanced
///
/// All widgets using this method will trigger a rebuild when locale changes.
/// Use this if you have e.g. a settings page where the user can select the locale during runtime.
///
/// Step 1:
/// wrap your App with
/// TranslationProvider(
/// 	child: MyApp()
/// );
///
/// Step 2:
/// final t = Translations.of(context); // Get t variable.
/// String a = t.someKey.anotherKey; // Use t variable.
/// String b = t['someKey.anotherKey']; // Only for edge cases!
class Translations {
	Translations._(); // no constructor

	static _StringsEn of(BuildContext context) {
		final inheritedWidget = context.dependOnInheritedWidgetOfExactType<_InheritedLocaleData>();
		if (inheritedWidget == null) {
			throw 'Please wrap your app with "TranslationProvider".';
		}
		return inheritedWidget.translations;
	}
}

class LocaleSettings {
	LocaleSettings._(); // no constructor

	/// Uses locale of the device, fallbacks to base locale.
	/// Returns the locale which has been set.
	static AppLocale useDeviceLocale() {
		final locale = AppLocaleUtils.findDeviceLocale();
		return setLocale(locale);
	}

	/// Sets locale
	/// Returns the locale which has been set.
	static AppLocale setLocale(AppLocale locale) {
		_currLocale = locale;
		_t = _currLocale.translations;

		// force rebuild if TranslationProvider is used
		_translationProviderKey.currentState?.setLocale(_currLocale);

		return _currLocale;
	}

	/// Sets locale using string tag (e.g. en_US, de-DE, fr)
	/// Fallbacks to base locale.
	/// Returns the locale which has been set.
	static AppLocale setLocaleRaw(String rawLocale) {
		final locale = AppLocaleUtils.parse(rawLocale);
		return setLocale(locale);
	}

	/// Gets current locale.
	static AppLocale get currentLocale {
		return _currLocale;
	}

	/// Gets base locale.
	static AppLocale get baseLocale {
		return _baseLocale;
	}

	/// Gets supported locales in string format.
	static List<String> get supportedLocalesRaw {
		return AppLocale.values
			.map((locale) => locale.languageTag)
			.toList();
	}

	/// Gets supported locales (as Locale objects) with base locale sorted first.
	static List<Locale> get supportedLocales {
		return AppLocale.values
			.map((locale) => locale.flutterLocale)
			.toList();
	}
}

/// Provides utility functions without any side effects.
class AppLocaleUtils {
	AppLocaleUtils._(); // no constructor

	/// Returns the locale of the device as the enum type.
	/// Fallbacks to base locale.
	static AppLocale findDeviceLocale() {
		final String? deviceLocale = WidgetsBinding.instance.window.locale.toLanguageTag();
		if (deviceLocale != null) {
			final typedLocale = _selectLocale(deviceLocale);
			if (typedLocale != null) {
				return typedLocale;
			}
		}
		return _baseLocale;
	}

	/// Returns the enum type of the raw locale.
	/// Fallbacks to base locale.
	static AppLocale parse(String rawLocale) {
		return _selectLocale(rawLocale) ?? _baseLocale;
	}
}

// context enums

// interfaces generated as mixins

// translation instances

late _StringsEn _translationsEn = _StringsEn.build();
late _StringsEs _translationsEs = _StringsEs.build();
late _StringsFr _translationsFr = _StringsFr.build();
late _StringsPt _translationsPt = _StringsPt.build();

// extensions for AppLocale

extension AppLocaleExtensions on AppLocale {

	/// Gets the translation instance managed by this library.
	/// [TranslationProvider] is using this instance.
	/// The plural resolvers are set via [LocaleSettings].
	_StringsEn get translations {
		switch (this) {
			case AppLocale.en: return _translationsEn;
			case AppLocale.es: return _translationsEs;
			case AppLocale.fr: return _translationsFr;
			case AppLocale.pt: return _translationsPt;
		}
	}

	/// Gets a new translation instance.
	/// [LocaleSettings] has no effect here.
	/// Suitable for dependency injection and unit tests.
	///
	/// Usage:
	/// final t = AppLocale.en.build(); // build
	/// String a = t.my.path; // access
	_StringsEn build() {
		switch (this) {
			case AppLocale.en: return _StringsEn.build();
			case AppLocale.es: return _StringsEs.build();
			case AppLocale.fr: return _StringsFr.build();
			case AppLocale.pt: return _StringsPt.build();
		}
	}

	String get languageTag {
		switch (this) {
			case AppLocale.en: return 'en';
			case AppLocale.es: return 'es';
			case AppLocale.fr: return 'fr';
			case AppLocale.pt: return 'pt';
		}
	}

	Locale get flutterLocale {
		switch (this) {
			case AppLocale.en: return const Locale.fromSubtags(languageCode: 'en');
			case AppLocale.es: return const Locale.fromSubtags(languageCode: 'es');
			case AppLocale.fr: return const Locale.fromSubtags(languageCode: 'fr');
			case AppLocale.pt: return const Locale.fromSubtags(languageCode: 'pt');
		}
	}
}

extension StringAppLocaleExtensions on String {
	AppLocale? toAppLocale() {
		switch (this) {
			case 'en': return AppLocale.en;
			case 'es': return AppLocale.es;
			case 'fr': return AppLocale.fr;
			case 'pt': return AppLocale.pt;
			default: return null;
		}
	}
}

// wrappers

GlobalKey<_TranslationProviderState> _translationProviderKey = GlobalKey<_TranslationProviderState>();

class TranslationProvider extends StatefulWidget {
	TranslationProvider({required this.child}) : super(key: _translationProviderKey);

	final Widget child;

	@override
	_TranslationProviderState createState() => _TranslationProviderState();

	static _InheritedLocaleData of(BuildContext context) {
		final inheritedWidget = context.dependOnInheritedWidgetOfExactType<_InheritedLocaleData>();
		if (inheritedWidget == null) {
			throw 'Please wrap your app with "TranslationProvider".';
		}
		return inheritedWidget;
	}
}

class _TranslationProviderState extends State<TranslationProvider> {
	AppLocale locale = _currLocale;

	void setLocale(AppLocale newLocale) {
		setState(() {
			locale = newLocale;
		});
	}

	@override
	Widget build(BuildContext context) {
		return _InheritedLocaleData(
			locale: locale,
			child: widget.child,
		);
	}
}

class _InheritedLocaleData extends InheritedWidget {
	final AppLocale locale;
	Locale get flutterLocale => locale.flutterLocale; // shortcut
	final _StringsEn translations; // store translations to avoid switch call

	_InheritedLocaleData({required this.locale, required Widget child})
		: translations = locale.translations, super(child: child);

	@override
	bool updateShouldNotify(_InheritedLocaleData oldWidget) {
		return oldWidget.locale != locale;
	}
}

// pluralization feature not used

// helpers

final _localeRegex = RegExp(r'^([a-z]{2,8})?([_-]([A-Za-z]{4}))?([_-]?([A-Z]{2}|[0-9]{3}))?$');
AppLocale? _selectLocale(String localeRaw) {
	final match = _localeRegex.firstMatch(localeRaw);
	AppLocale? selected;
	if (match != null) {
		final language = match.group(1);
		final country = match.group(5);

		// match exactly
		selected = AppLocale.values
			.cast<AppLocale?>()
			.firstWhere((supported) => supported?.languageTag == localeRaw.replaceAll('_', '-'), orElse: () => null);

		if (selected == null && language != null) {
			// match language
			selected = AppLocale.values
				.cast<AppLocale?>()
				.firstWhere((supported) => supported?.languageTag.startsWith(language) == true, orElse: () => null);
		}

		if (selected == null && country != null) {
			// match country
			selected = AppLocale.values
				.cast<AppLocale?>()
				.firstWhere((supported) => supported?.languageTag.contains(country) == true, orElse: () => null);
		}
	}
	return selected;
}

// translations

// Path: <root>
class _StringsEn {

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsEn.build();

	/// Access flat map
	dynamic operator[](String key) => _flatMap[key];

	// Internal flat map initialized lazily
	late final Map<String, dynamic> _flatMap = _buildFlatMap();

	late final _StringsEn _root = this; // ignore: unused_field

	// Translations
	String get appname => 'MFM Lekki';
	String get churchmotto => 'Towards global envagelism';
	String get initializingapp => 'Please wait while we setup a few things, it wont take long, we promise.';
	String get errorinitapp => 'Unfortunately, we could not complete setup at the moment, please check your internet connection, then click to retry';
	String get initappsucess => 'Congratulations, setup is now complete, you can now click to continue to app';
	String get retry => 'Try Again';
	String get continuetoapp => 'Continue to App';
	String get home => 'Home';
	String get media => 'Media';
	String get publications => 'Publications';
	String get connect => 'Connect';
	String get recentsermons => 'Recent Sermons';
	String get donate => 'Give Now';
	String get donatehint => 'God loves a cheerful giver.';
	String get bible => 'Bible';
	String get hymns => 'Hymns';
	String get devotionals => 'Devotionals';
	String get stayconnected => 'More ways to stay connected';
	String get radiostreams => 'Radio Streams';
	String get radiohint => 'Listen to our daily Radio Streams.';
	String get livestreams => 'Live Streams';
	String get livestreamshint => 'Connect to watch our live broadcasts.';
	String get video => 'Videos';
	String get videos => 'Video Messages';
	String get videoshint => 'Collection of video sermons.';
	String get audios => 'Audio Messages';
	String get audioshint => 'Collection of audio sermons';
	String get photos => 'Photo Gallery';
	String get photoshint => 'Browse through our church photo collections.';
	String get bookmarks => 'Bookmarks';
	String get playlists => 'Playlists';
	String get downloads => 'Downloads';
	String get books => 'Christian Books';
	String get recentarticles => 'Recent Articles';
	String get groups => 'Church Groups';
	String get groupshint => 'Church Groups are the best place to connect and fellowship with other believers.';
	String get Prayerrequests => 'Prayer Requests';
	String get prayerhint => 'Send a prayer request or join us to pray for other members.';
	String get testimonies => 'Testimonies';
	String get testimonyhint => 'Collection of personal testimonies of Gods healing power and deliverance.';
	String get churchlocation => 'Church Locations';
	String get churchlocationhint => 'Find a location near you and make plans to join us this Sunday!';
	String get facebookpage => 'Facebook Page';
	String get facebookpagehint => 'Connect with us on our Facebook community.';
	String get youtubepage => 'Youtube Page';
	String get youtubepagehint => 'Subscribe to our Youtube channel.';
	String get twitterpage => 'Twitter Page';
	String get twitterpagehint => 'Join the conversation on the Twitter platform.';
	String get instagrampage => 'Instagram Page';
	String get instagrampagehint => 'Follow us on Instagram to see the latest stories.';
	String get gosocial => 'Go Social';
	String get gosocialehint => 'Share your thought &\n chat with other members.';
	String get website => ' Our Website';
	String get terms => 'Terms & Conditions';
	String get privacy => 'Privacy Policy';
	String get about => 'About Us';
	String get rateapp => 'Rate App';
	String get account => 'Account';
	String get appsettings => 'App Settings';
	String get guestuser => 'Guest User';
	String get createanaccounthint => 'Create an account or login to app';
	String get viewmyprofile => 'View my profile';
	String get logoutfromapp => 'Logout from App';
	String get deletemyaccount => 'Delete my account';
	String get applanguage => 'App Language';
	String get recieveinbox => 'Receive inbox notifications';
	String get recieveevents => 'Events';
	String get sermonnotification => 'Sermons';
	String get articlenotification => 'Articles';
	String get devotionalnotification => 'Devotionals';
	String get chooseapplanguage => 'Select App Language';
	String get emailaddress => 'Email Address';
	String get password => 'Password';
	String get confirmpassword => 'Confirm Password';
	String get passwordsdontmatch => 'Passwords dont match!';
	String get login => 'LOG IN';
	String get createaccount => 'Create Account';
	String get forgotpassword => 'Forgot Password?';
	String get resetpassword => 'Reset Password';
	String get resetpasswordhint => 'A reset password link will be sent to your email.';
	String get resetpasswordsuccess => 'If the email exists in our platform, you should recieve an instruction on how to reset your password.';
	String get goback => 'Go Back';
	String get ok => 'OK';
	String get cancel => 'CANCEL';
	String get resendverifycode => 'Resend Verification Link';
	String get successregistermessage => 'You have successfully created an account, please check your email for a verification link and verify your email address.';
	String get successresendverifymessage => 'A verification link have been sent to your email.';
	String get resendverifylink => 'A verification link was sent to your email address, visit the link to verify your email. Did not get the email? click the link below to resend verification link.';
	String get processingpleasewait => 'Processing, please wait...';
	String get cannotprocess => 'The requested operation cannot be processed at the moment, please try again later.';
	String get oops => 'Ooops!';
	String get save => 'Save';
	String get error => 'Error';
	String get success => 'Success';
	String get skip => 'Skip';
	String get downloadbible => 'Download Bible';
	String get downloadversion => 'Download';
	String get downloading => 'Downloading';
	String get failedtodownload => 'Failed to download';
	String get pleaseclicktoretry => 'Please click to retry.';
	String get of => 'Of';
	String get nobibleversionshint => 'There is no bible data to display, click on the button below to download atleast one bible version.';
	String get downloaded => 'Downloaded';
	String get enteremailaddresstoresetpassword => 'Enter your email to reset your password';
	String get backtologin => 'BACK TO LOGIN';
	String get signintocontinue => 'Sign in to continue';
	String get signin => 'S I G N  I N';
	String get signinforanaccount => 'SIGN UP FOR AN ACCOUNT?';
	String get alreadyhaveanaccount => 'Already have an account?';
	String get updateprofile => 'Update Profile';
	String get updateprofilehint => 'To get started, please update your profile page, this will help us in connecting you with other people';
	String get searchbible => 'Search Bible';
	String get filtersearchoptions => 'Filter Search Options';
	String get narrowdownsearch => 'Use the filter button below to narrow down search for a more precise result.';
	String get searchbibleversion => 'Search Bible Version';
	String get searchbiblebook => 'Search Bible Book';
	String get search => 'Search';
	String get setBibleBook => 'Set Bible Book';
	String get oldtestament => 'Old Testament';
	String get newtestament => 'New Testament';
	String get limitresults => 'Limit Results';
	String get setfilters => 'Set Filters';
	String get bibletranslator => 'Bible Translator';
	String get chapter => ' Chapter ';
	String get verse => ' Verse ';
	String get translate => 'translate';
	String get bibledownloadinfo => 'Bible Download started, Please do not close this page until the download is done.';
	String get received => 'received';
	String get outoftotal => 'out of total';
	String get set => 'SET';
	String get selectColor => 'Select Color';
	String get switchbibleversion => 'Switch Bible Version';
	String get switchbiblebook => 'Switch Bible Book';
	String get gotosearch => 'Go to Chapter';
	String get changefontsize => 'Change Font Size';
	String get font => 'Font';
	String get readchapter => 'Read Chapter';
	String get showhighlightedverse => 'Show Highlighted Verses';
	String get downloadmoreversions => 'Download more versions';
	String get suggestedusers => 'Suggested users to follow';
	String get unfollow => 'UnFollow';
	String get follow => 'Follow';
	String get searchforpeople => 'Search for people';
	String get viewpost => 'View Post';
	String get viewprofile => 'View Profile';
	String get mypins => 'My Pins';
	String get viewpinnedposts => 'View Pinned Posts';
	String get personal => 'Personal';
	String get update => 'Update';
	String get phonenumber => 'Phone Number (Optional)';
	String get showmyphonenumber => 'Show my phone number to users';
	String get dateofbirth => 'Date of Birth';
	String get showmyfulldateofbirth => 'Show my full date of birth to people viewing my status';
	String get notifications => 'Notifications';
	String get notifywhenuserfollowsme => 'Notify me when a user follows me';
	String get notifymewhenusercommentsonmypost => 'Notify me when users comment on my post';
	String get notifymewhenuserlikesmypost => 'Notify me when users like my post';
	String get churchsocial => 'Church Social';
	String get shareyourthoughts => 'Share your thoughts';
	String get readmore => '...Read more';
	String get less => ' Less';
	String get couldnotprocess => 'Could not process requested action.';
	String get pleaseselectprofilephoto => 'Please select a profile photo to upload';
	String get pleaseselectprofilecover => 'Please select a cover photo to upload';
	String get optionalprofileinformation => 'Optional Profile Information';
	String get optionalhint => 'These fields are optional and not required to use the app.';
	String get updateprofileerrorhint => 'You need to fill your name, date of birth, gender, phone before you can proceed.';
	String get fullname => 'Full Name (Optional)';
	String get firstname => 'First Name (Optional)';
	String get lastname => 'Last Name (Optional)';
	String get occupation => 'Occupation';
	String get gender => 'Gender (Optional)';
	String get male => 'Male';
	String get female => 'Female';
	String get dob => 'Date Of Birth (Optional)';
	String get address => 'Current Address';
	String get aboutme => 'About Me';
	String get facebookprofilelink => 'Facebook Profile Link';
	String get twitterprofilelink => 'Twitter Profile Link';
	String get linkdln => 'Linkedln Profile Link';
	String get likes => 'Likes';
	String get likess => 'Like(s)';
	String get pinnedposts => 'My Pinned Posts';
	String get unpinpost => 'Unpin Post';
	String get unpinposthint => 'Do you wish to remove this post from your pinned posts?';
	String get postdetails => 'Post Details';
	String get posts => 'Posts';
	String get followers => 'Followers';
	String get followings => 'Followings';
	String get my => 'My';
	String get edit => 'Edit';
	String get delete => 'Delete';
	String get deletepost => 'Delete Post';
	String get deleteposthint => 'Do you wish to delete this post? Posts can still appear on some users feeds.';
	String get maximumallowedsizehint => 'Maximum allowed file upload reached';
	String get maximumuploadsizehint => 'The selected file exceeds the allowed upload file size limit.';
	String get makeposterror => 'Unable to make post at the moment, please click to retry.';
	String get makepost => 'Make Post';
	String get selectfile => 'Select File';
	String get images => 'Images';
	String get shareYourThoughtsNow => 'Share your thoughts ...';
	String get photoviewer => 'Photo Viewer';
	String get nochatsavailable => 'No Conversations available \n Click the add icon below \nto select users to chat with';
	String get typing => 'Typing...';
	String get photo => 'Photo';
	String get online => 'Online';
	String get offline => 'Offline';
	String get lastseen => 'Last Seen';
	String get deleteselectedhint => 'This action will delete the selected messages.  Please note that this only deletes your side of the conversation, \n the messages will still show on your partners device.';
	String get deleteselected => 'Delete selected';
	String get unabletofetchconversation => 'Unable to Fetch \nyour conversation with \n';
	String get loadmoreconversation => 'Load more conversations';
	String get sendyourfirstmessage => 'Send your first message to \n';
	String get unblock => 'Unblock ';
	String get block => 'Block';
	String get writeyourmessage => 'Write your message...';
	String get clearconversation => 'Clear Conversation';
	String get clearconversationhintone => 'This action will clear all your conversation with ';
	String get clearconversationhinttwo => '.\n  Please note that this only deletes your side of the conversation, the messages will still show on your partners chat.';
	String get logoutfromapphint => 'You wont be able to access some priviledges if you are not logged in.';
	String get deleteaccount => 'Delete my account';
	String get deleteaccounthint => 'This action will delete your account and remove all your data, once your data is deleted, it cannot be recovered.';
	String get deleteaccountsuccess => 'Account deletion was succesful';
	String get myprofile => 'My Profile';
	String get noitemstodisplay => 'No Items To Display';
	String get copiedtoclipboard => 'Copied to clipboard';
	String get biblebooks => 'Bible';
	String get searchhint => 'Search Audio & Video Messages';
	String get performingsearch => 'Searching Audios and Videos';
	String get nosearchresult => 'No results Found';
	String get nosearchresulthint => 'Try input more general keyword';
	String get dataloaderror => 'Could not load requested data at the moment, check your data connection and click to retry.';
	String get download => 'Download';
	String get addplaylist => 'Add to playlist';
	String get bookmark => 'Bookmark';
	String get unbookmark => 'UnBookmark';
	String get share => 'Share';
	String get deletemedia => 'Delete File';
	String get deletemediahint => 'Do you wish to delete this downloaded file? This action cannot be undone.';
	String get comments => 'Comments';
	String get replies => 'Replies';
	String get reply => 'Reply';
	String get logintoaddcomment => 'Login to add a comment';
	String get logintoreply => 'Login to reply';
	String get writeamessage => 'Write a message...';
	String get nocomments => 'No Comments found \nclick to retry';
	String get errormakingcomments => 'Cannot process commenting at the moment..';
	String get errordeletingcomments => 'Cannot delete this comment at the moment..';
	String get erroreditingcomments => 'Cannot edit this comment at the moment..';
	String get errorloadingmorecomments => 'Cannot load more comments at the moment..';
	String get deletingcomment => 'Deleting comment';
	String get editingcomment => 'Editing comment';
	String get deletecommentalert => 'Delete Comment';
	String get editcommentalert => 'Edit Comment';
	String get deletecommentalerttext => 'Do you wish to delete this comment? This action cannot be undone';
	String get loadmore => 'load more';
	String get errorReportingComment => 'Error Reporting Comment';
	String get reportingComment => 'Reporting Comment';
	String get reportcomment => 'Report Options';
	List<String> get reportCommentsList => [
		'Unwanted commercial content or spam',
		'Pornography or sexual explicit material',
		'Hate speech or graphic violence',
		'Harassment or bullying',
	];
	String get addtoplaylist => 'Add to playlist';
	String get newplaylist => 'New playlist';
	String get playlistitm => 'Playlist';
	String get mediaaddedtoplaylist => 'Media added to playlist.';
	String get mediaremovedfromplaylist => 'Media removed from playlist';
	String get clearplaylistmedias => 'Clear All Media';
	String get deletePlayList => 'Delete Playlist';
	String get clearplaylistmediashint => 'Go ahead and remove all media from this playlist?';
	String get deletePlayListhint => 'Go ahead and delete this playlist and clear all media?';
	String get pulluploadmore => 'pull up load';
	String get loadfailedretry => 'Load Failed!Click retry!';
	String get releaseloadmore => 'release to load more';
	String get nomoredata => 'No more Data';
	String get events => 'Events';
	String get myplaylists => 'My Playlists';
	String get articles => 'Articles';
	String get notes => 'Notes';
	String get savenotetitle => 'Note Title';
	String get nonotesfound => 'No notes found';
	String get newnote => 'New';
	String get deletenote => 'Delete Note';
	String get deletenotehint => 'Do you want to delete this note? This action cannot be reversed.';
	String get allitems => 'All Items';
	String get emptyplaylist => 'No Playlists';
	String get notsupported => 'Not Supported';
	String get cleanupresources => 'Cleaning up resources';
	String get grantstoragepermission => 'Please grant accessing storage permission to continue';
	String get sharefiletitle => 'Watch or Listen to ';
	String get sharefilebody => 'Via MyChurch App, Download now at ';
	String get sharetext => 'Enjoy unlimited Audio & Video streaming';
	String get sharetexthint => 'Join the Video and Audio streaming platform that lets you watch and listen to millions of files from around the world. Download now at';
	String get branches => 'Branches';
	String get inbox => 'Inbox';
	String get viewinmap => 'View Location in Map';
	String get member => 'Member(s)';
	String get join => 'Join Group';
	String get by => 'BY';
	String get prayertitle => 'Prayer Title';
	String get prayercontent => 'Prayer Content';
	String get testimonytitle => 'Testimony Title';
	String get testimonycontent => 'Testimony Content';
	String get successprayerposting => 'You have successfully added a prayer request, it will be published once it is approved.';
	String get successtestimonyposting => 'You have successfully added a new testimony, it will be published once it is approved.';
	String get addtestimony => 'Add Testimony';
	String get groupsibelongto => 'Groups i belong to';
	String get groupevents => 'Group Events/Activities';
	String get successjoinedgroup => 'You have successfully requested to join this group, You will be notified by email once this request is granted.';
	String get createnote => 'Create Note';
	String get tapaddcontent => 'Tap to add content';
	String get done => 'Done';
	String get youversionbible => 'Use Youversion Bible Reader';
	String get readbiblein => 'Read Bible in';
	String get nodevotionals => 'No devotionals for selected month';
	String get noevents => 'No events for selected month';
	String get devotionalshint => 'Daily readings for devoted living.';
	String get recentmessages => 'Recent Messages';
	String get eventshint => 'Events & announcements';
	String get digdeepbible => 'Dig deep into the word of God.';
	String get upcomingevents => 'Our Upcoming Events';
	String get searchmessagesbooks => 'Search for audio & video messages';
	String get exploredeep => 'Explore Deeper';
	String get missionstatement => 'Great to have you here, at Mychurch App, we strive for mastery at Gods word and preaching the gospel. ';
	String get next => 'Next';
	List<String> get onboardingpagetitles => [
		'Welcome to MFM Lekki TMPM 1',
		'Benefits of the App',
		'Audio, Video \n and Live Streaming',
		'Create Account',
	];
	List<String> get onboardingpagehints => [
		'A vibrant worship centre committed to prayer, deliverance, holiness, and raising champions for Christ.',
		'Stay connected with church updates, programmes, and spiritual resources designed to strengthen your walk with God.',
		'Access sermons, prayer sessions, and live services anytime from anywhere.',
		'Start your journey to a never-ending worship experience.',
	];
	String get youneedtologintoreply => 'You need to login to add a reply';
	String get youneedtologintoreportpost => 'You need to login to report a post';
	String get members => 'Members';
	String get logintolikeapost => 'You need to login to like a member post';
	String get logintopinapost => 'You need to login to pin a member post';
	String get logintoreportapost => 'You need to login to report post';
	String get bookmarkshint => 'Bookmark audio and video messages';
	String get downloadershint => 'Download and watch offline messages';
	String get playlistshint => 'Collection of audio and video messages';
}

// Path: <root>
class _StringsEs implements _StringsEn {

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsEs.build();

	/// Access flat map
	@override dynamic operator[](String key) => _flatMap[key];

	// Internal flat map initialized lazily
	@override late final Map<String, dynamic> _flatMap = _buildFlatMap();

	@override late final _StringsEs _root = this; // ignore: unused_field

	// Translations
	@override String get appname => 'Church App';
	@override String get churchmotto => 'Hacia el evangelismo global';
	@override String get initializingapp => 'Por favor, espere mientras configuramos algunas cosas, no tomará mucho tiempo, lo prometemos.';
	@override String get errorinitapp => 'Desafortunadamente, no pudimos completar la configuración en este momento, por favor revise su conexión a internet y luego haga clic para intentarlo de nuevo.';
	@override String get initappsucess => 'Felicitaciones, la configuración ahora está completa, ahora puede hacer clic para continuar con la aplicación.';
	@override String get retry => 'Intentar de nuevo';
	@override String get continuetoapp => 'Continuar con la aplicación';
	@override String get home => 'Inicio';
	@override String get media => 'Medios';
	@override String get publications => 'Publicaciones';
	@override String get connect => 'Conectar';
	@override String get recentsermons => 'Sermónes Recientes';
	@override String get donate => 'Dar Ahora';
	@override String get donatehint => 'Dios ama al dador alegre.';
	@override String get bible => 'Biblia';
	@override String get hymns => 'Himnos';
	@override String get devotionals => 'Devocionales';
	@override String get stayconnected => 'Más formas de estar conectado';
	@override String get radiostreams => 'Transmisiones de Radio';
	@override String get radiohint => 'Escuche nuestras transmisiones diarias de radio.';
	@override String get livestreams => 'Transmisiones en Vivo';
	@override String get livestreamshint => 'Conéctese para ver nuestras transmisiones en vivo.';
	@override String get video => 'Videos';
	@override String get videos => 'Mensajes de Video';
	@override String get videoshint => 'Colección de sermones en video.';
	@override String get audios => 'Mensajes de Audio';
	@override String get audioshint => 'Colección de sermones en audio';
	@override String get photos => 'Galería de Fotos';
	@override String get photoshint => 'Navegue por nuestras colecciones de fotos de la iglesia.';
	@override String get bookmarks => 'Marcadores';
	@override String get playlists => 'Listas de Reproducción';
	@override String get downloads => 'Descargas';
	@override String get books => 'Libros Cristianos';
	@override String get recentarticles => 'Artículos Recientes';
	@override String get groups => 'Grupos de Vida';
	@override String get groupshint => 'Los grupos de vida son el mejor lugar para conectarse y confraternizar con otros creyentes.';
	@override String get Prayerrequests => 'Peticiones de Oración';
	@override String get prayerhint => 'Envíe una petición de oración o únase a nosotros para orar por otros miembros.';
	@override String get testimonies => 'Testimonios';
	@override String get testimonyhint => 'Colección de testimonios personales del poder sanador y liberador de Dios.';
	@override String get churchlocation => 'Ubicaciones de la Iglesia';
	@override String get churchlocationhint => 'Encuentre una ubicación cerca de usted y haga planes para unirse a nosotros este domingo.';
	@override String get facebookpage => 'Página de Facebook';
	@override String get facebookpagehint => 'Conéctese con nosotros en nuestra comunidad de Facebook.';
	@override String get youtubepage => 'Página de Youtube';
	@override String get youtubepagehint => 'Suscríbase a nuestro canal de Youtube.';
	@override String get twitterpage => 'Página de Twitter';
	@override String get twitterpagehint => 'Únase a la conversación en la plataforma de Twitter.';
	@override String get instagrampage => 'Página de Instagram';
	@override String get instagrampagehint => 'Síganos en Instagram para ver las últimas historias.';
	@override String get gosocial => 'Ir Social';
	@override String get gosocialehint => 'Comparta sus pensamientos y charle con otros miembros.';
	@override String get website => 'Nuestro Sitio Web';
	@override String get terms => 'Términos y Condiciones';
	@override String get privacy => 'Política de Privacidad';
	@override String get about => 'Sobre Nosotros';
	@override String get rateapp => 'Calificar App';
	@override String get account => 'Cuenta';
	@override String get appsettings => 'Configuración de la App';
	@override String get guestuser => 'Usuario Invitado';
	@override String get createanaccounthint => 'Crea una cuenta o inicia sesión en la aplicación';
	@override String get viewmyprofile => 'Ver mi perfil';
	@override String get logoutfromapp => 'Cerrar Sesión de la App';
	@override String get deletemyaccount => 'Eliminar mi cuenta';
	@override String get applanguage => 'Idioma de la App';
	@override String get recieveinbox => 'Recibir notificaciones de bandeja de entrada';
	@override String get recieveevents => 'Eventos';
	@override String get sermonnotification => 'Sermónes';
	@override String get articlenotification => 'Artículos';
	@override String get devotionalnotification => 'Devocionales';
	@override String get chooseapplanguage => 'Seleccionar Idioma de la App';
	@override String get emailaddress => 'Dirección de Correo Electrónico';
	@override String get password => 'Contraseña';
	@override String get confirmpassword => 'Confirmar Contraseña';
	@override String get passwordsdontmatch => '¡Las contraseñas no coinciden!';
	@override String get login => 'INICIAR SESIÓN';
	@override String get createaccount => 'Crear Cuenta';
	@override String get forgotpassword => '¿Olvidó su Contraseña?';
	@override String get resetpassword => 'Restablecer Contraseña';
	@override String get resetpasswordhint => 'Se enviará un enlace para restablecer la contraseña a su correo electrónico.';
	@override String get resetpasswordsuccess => 'Si el correo electrónico existe en nuestra plataforma, debería recibir instrucciones sobre cómo restablecer su contraseña.';
	@override String get goback => 'Volver';
	@override String get ok => 'OK';
	@override String get cancel => 'CANCELAR';
	@override String get resendverifycode => 'Reenviar Enlace de Verificación';
	@override String get successregistermessage => 'Ha creado una cuenta correctamente, por favor revise su correo electrónico para un enlace de verificación y verifique su dirección de correo electrónico.';
	@override String get successresendverifymessage => 'Se ha enviado un enlace de verificación a su correo electrónico.';
	@override String get resendverifylink => 'Se envió un enlace de verificación a su dirección de correo electrónico, visite el enlace para verificar su correo electrónico. ¿No recibió el correo electrónico? haga clic en el enlace a continuación para reenviar el enlace de verificación.';
	@override String get processingpleasewait => 'Procesando, por favor espere...';
	@override String get cannotprocess => 'La operación solicitada no puede procesarse en este momento, por favor inténtelo de nuevo más tarde.';
	@override String get oops => '¡Ups!';
	@override String get save => 'Guardar';
	@override String get error => 'Error';
	@override String get success => 'Éxito';
	@override String get skip => 'Omitir';
	@override String get downloadbible => 'Descargar Biblia';
	@override String get downloadversion => 'Descargar';
	@override String get downloading => 'Descargando';
	@override String get failedtodownload => 'Error al descargar';
	@override String get pleaseclicktoretry => 'Por favor, haga clic para intentarlo de nuevo.';
	@override String get of => 'De';
	@override String get nobibleversionshint => 'No hay datos de la biblia para mostrar, haga clic en el botón a continuación para descargar al menos una versión de la biblia.';
	@override String get downloaded => 'Descargado';
	@override String get enteremailaddresstoresetpassword => 'Ingrese su correo electrónico para restablecer su contraseña';
	@override String get backtologin => 'REGRESAR AL INICIO DE SESIÓN';
	@override String get signintocontinue => 'Inicie sesión para continuar';
	@override String get signin => 'I N I C I A R S E S I Ó N';
	@override String get signinforanaccount => '¿REGISTRARSE PARA UNA CUENTA?';
	@override String get alreadyhaveanaccount => '¿Ya tienes una cuenta?';
	@override String get updateprofile => 'Actualizar Perfil';
	@override String get updateprofilehint => 'Para comenzar, actualice su página de perfil, esto nos ayudará a conectarnos con otras personas';
	@override String get searchbible => 'Buscar Biblia';
	@override String get filtersearchoptions => 'Opciones de Filtro de Búsqueda';
	@override String get narrowdownsearch => 'Use el botón de filtro a continuación para reducir la búsqueda para obtener un resultado más preciso.';
	@override String get searchbibleversion => 'Buscar Versión de la Biblia';
	@override String get searchbiblebook => 'Buscar Libro de la Biblia';
	@override String get search => 'Buscar';
	@override String get setBibleBook => 'Establecer Libro de la Biblia';
	@override String get oldtestament => 'Antiguo Testamento';
	@override String get newtestament => 'Nuevo Testamento';
	@override String get limitresults => 'Limitar Resultados';
	@override String get setfilters => 'Establecer Filtros';
	@override String get bibletranslator => 'Traductor de la Biblia';
	@override String get chapter => ' Capítulo ';
	@override String get verse => ' Versículo ';
	@override String get translate => 'traducir';
	@override String get bibledownloadinfo => 'La descarga de la Biblia ha comenzado, por favor no cierre esta página hasta que la descarga haya terminado.';
	@override String get received => 'recibido';
	@override String get outoftotal => 'de un total de';
	@override String get set => 'ESTABLECER';
	@override String get selectColor => 'Seleccionar Color';
	@override String get switchbibleversion => 'Cambiar Versión de la Biblia';
	@override String get switchbiblebook => 'Cambiar Libro de la Biblia';
	@override String get gotosearch => 'Ir al Capítulo';
	@override String get changefontsize => 'Cambiar Tamaño de Fuente';
	@override String get font => 'Fuente';
	@override String get readchapter => 'Leer Capítulo';
	@override String get showhighlightedverse => 'Mostrar Versículos Resaltados';
	@override String get downloadmoreversions => 'Descargar más versiones';
	@override String get suggestedusers => 'Usuarios Sugeridos para Seguir';
	@override String get unfollow => 'Dejar de Seguir';
	@override String get follow => 'Seguir';
	@override String get searchforpeople => 'Buscar personas';
	@override String get viewpost => 'Ver Publicación';
	@override String get viewprofile => 'Ver Perfil';
	@override String get mypins => 'Mis Pins';
	@override String get viewpinnedposts => 'Ver Posts Anclados';
	@override String get personal => 'Personal';
	@override String get update => 'Actualizar';
	@override String get phonenumber => 'Número de Teléfono (Opcional)';
	@override String get showmyphonenumber => 'Mostrar mi número de teléfono a los usuarios';
	@override String get dateofbirth => 'Fecha de Nacimiento';
	@override String get showmyfulldateofbirth => 'Mostrar mi fecha de nacimiento completa a las personas que ven mi estado';
	@override String get notifications => 'Notificaciones';
	@override String get notifywhenuserfollowsme => 'Notificarme cuando un usuario me sigue';
	@override String get notifymewhenusercommentsonmypost => 'Notificarme cuando los usuarios comenten en mi publicación';
	@override String get notifymewhenuserlikesmypost => 'Notificarme cuando los usuarios den me gusta a mi publicación';
	@override String get churchsocial => 'Social de la Iglesia';
	@override String get shareyourthoughts => 'Comparte tus pensamientos';
	@override String get readmore => '... Leer más';
	@override String get less => 'Menos';
	@override String get couldnotprocess => 'No se pudo procesar la acción solicitada.';
	@override String get pleaseselectprofilephoto => 'Por favor seleccione una foto de perfil para subir';
	@override String get pleaseselectprofilecover => 'Por favor seleccione una foto de portada para subir';
	@override String get optionalprofileinformation => 'Información de Perfil Opcional';
	@override String get optionalhint => 'Estos campos son opcionales y no son necesarios para usar la aplicación.';
	@override String get updateprofileerrorhint => 'Debe completar su nombre, fecha de nacimiento, género, y teléfono antes de continuar.';
	@override String get fullname => 'Nombre Completo (Opcional)';
	@override String get firstname => 'Nombre (Opcional)';
	@override String get lastname => 'Apellido (Opcional)';
	@override String get occupation => 'Ocupación';
	@override String get gender => 'Género (Opcional)';
	@override String get male => 'Masculino';
	@override String get female => 'Femenino';
	@override String get dob => 'Fecha de Nacimiento (Opcional)';
	@override String get address => 'Dirección Actual';
	@override String get aboutme => 'Acerca de Mí';
	@override String get facebookprofilelink => 'Enlace de Perfil de Facebook';
	@override String get twitterprofilelink => 'Enlace de Perfil de Twitter';
	@override String get linkdln => 'Enlace de Perfil de LinkedIn';
	@override String get likes => 'Gustos';
	@override String get likess => 'Gusto(s)';
	@override String get pinnedposts => 'Mis Posts Anclados';
	@override String get unpinpost => 'Desanclar Post';
	@override String get unpinposthint => '¿Desea eliminar este post de sus posts anclados?';
	@override String get postdetails => 'Detalles del Post';
	@override String get posts => 'Posts';
	@override String get followers => 'Seguidores';
	@override String get followings => 'Siguiendo';
	@override String get my => 'Mi';
	@override String get edit => 'Editar';
	@override String get delete => 'Eliminar';
	@override String get deletepost => 'Eliminar Post';
	@override String get deleteposthint => '¿Desea eliminar este post? Los posts aún pueden aparecer en los feeds de algunos usuarios.';
	@override String get maximumallowedsizehint => 'Tamaño máximo de carga permitido alcanzado';
	@override String get maximumuploadsizehint => 'El archivo seleccionado supera el límite de tamaño de carga permitido.';
	@override String get makeposterror => 'No se puede realizar el post en este momento, por favor haga clic para intentarlo de nuevo.';
	@override String get makepost => 'Crear Post';
	@override String get selectfile => 'Seleccionar Archivo';
	@override String get images => 'Imágenes';
	@override String get shareYourThoughtsNow => 'Comparte tus pensamientos ...';
	@override String get photoviewer => 'Visor de Fotos';
	@override String get nochatsavailable => 'No hay Conversaciones disponibles \n Haga clic en el ícono de agregar abajo \n para seleccionar usuarios con los que chatear';
	@override String get typing => 'Escribiendo...';
	@override String get photo => 'Foto';
	@override String get online => 'En línea';
	@override String get offline => 'Desconectado';
	@override String get lastseen => 'Última Conexión';
	@override String get deleteselectedhint => 'Esta acción eliminará los mensajes seleccionados. Tenga en cuenta que esto solo elimina su lado de la conversación, \n los mensajes seguirán mostrándose en el dispositivo de su pareja.';
	@override String get deleteselected => 'Eliminar seleccionado';
	@override String get unabletofetchconversation => 'No se pudo obtener su conversación con \n';
	@override String get loadmoreconversation => 'Cargar más conversaciones';
	@override String get sendyourfirstmessage => 'Envíe su primer mensaje a \n';
	@override String get unblock => 'Desbloquear ';
	@override String get block => 'Bloquear';
	@override String get writeyourmessage => 'Escribe tu mensaje...';
	@override String get clearconversation => 'Limpiar Conversación';
	@override String get clearconversationhintone => 'Esta acción limpiará toda su conversación con ';
	@override String get clearconversationhinttwo => '.\n Tenga en cuenta que esto solo elimina su lado de la conversación, los mensajes seguirán mostrándose en el chat de su pareja.';
	@override String get logoutfromapphint => 'No podrá acceder a algunos privilegios si no ha iniciado sesión.';
	@override String get deleteaccount => 'Eliminar mi cuenta';
	@override String get deleteaccounthint => 'Esta acción eliminará su cuenta y eliminará todos sus datos, una vez que se eliminen sus datos, no se podrán recuperar.';
	@override String get deleteaccountsuccess => 'Eliminación de la cuenta exitosa';
	@override String get myprofile => 'Mi Perfil';
	@override String get noitemstodisplay => 'No hay elementos para mostrar';
	@override String get copiedtoclipboard => 'Copiado al portapapeles';
	@override String get biblebooks => 'Biblia';
	@override String get searchhint => 'Buscar Mensajes de Audio y Video';
	@override String get performingsearch => 'Buscando Audios y Videos';
	@override String get nosearchresult => 'No se encontraron resultados';
	@override String get nosearchresulthint => 'Intente ingresar palabras clave más generales';
	@override String get dataloaderror => 'No se pudieron cargar los datos solicitados en este momento, verifique su conexión de datos y haga clic para intentarlo de nuevo.';
	@override String get download => 'Descargar';
	@override String get addplaylist => 'Agregar a lista de reproducción';
	@override String get bookmark => 'Agregar a favoritos';
	@override String get unbookmark => 'Eliminar de favoritos';
	@override String get share => 'Compartir';
	@override String get deletemedia => 'Eliminar Archivo';
	@override String get deletemediahint => '¿Desea eliminar este archivo descargado? Esta acción no se puede deshacer.';
	@override String get comments => 'Comentarios';
	@override String get replies => 'Respuestas';
	@override String get reply => 'Responder';
	@override String get logintoaddcomment => 'Inicie sesión para agregar un comentario';
	@override String get logintoreply => 'Inicie sesión para responder';
	@override String get writeamessage => 'Escribe un mensaje...';
	@override String get nocomments => 'No se encontraron comentarios \nhaga clic para intentarlo de nuevo';
	@override String get errormakingcomments => 'No se puede procesar el comentario en este momento..';
	@override String get errordeletingcomments => 'No se puede eliminar este comentario en este momento..';
	@override String get erroreditingcomments => 'No se puede editar este comentario en este momento..';
	@override String get errorloadingmorecomments => 'No se pueden cargar más comentarios en este momento..';
	@override String get deletingcomment => 'Eliminando comentario';
	@override String get editingcomment => 'Editando comentario';
	@override String get deletecommentalert => 'Eliminar Comentario';
	@override String get editcommentalert => 'Editar Comentario';
	@override String get deletecommentalerttext => '¿Desea eliminar este comentario? Esta acción no se puede deshacer';
	@override String get loadmore => 'cargar más';
	@override String get errorReportingComment => 'Error al Reportar Comentario';
	@override String get reportingComment => 'Reportando Comentario';
	@override String get reportcomment => 'Opciones de Reporte';
	@override List<String> get reportCommentsList => [
		'Contenido comercial no deseado o spam',
		'Pornografía o material sexual explícito',
		'Discurso de odio o violencia gráfica',
		'Acoso o intimidación',
	];
	@override String get addtoplaylist => 'Agregar a lista de reproducción';
	@override String get newplaylist => 'Nueva lista de reproducción';
	@override String get playlistitm => 'Lista de reproducción';
	@override String get mediaaddedtoplaylist => 'Medio agregado a lista de reproducción.';
	@override String get mediaremovedfromplaylist => 'Medio eliminado de lista de reproducción';
	@override String get clearplaylistmedias => 'Limpiar Todos los Medios';
	@override String get deletePlayList => 'Eliminar Lista de Reproducción';
	@override String get clearplaylistmediashint => '¿Desea eliminar todos los medios de esta lista de reproducción?';
	@override String get deletePlayListhint => '¿Desea eliminar esta lista de reproducción y borrar todos los medios?';
	@override String get pulluploadmore => 'tirar para cargar más';
	@override String get loadfailedretry => '¡Error al cargar! ¡Haga clic en reintentar!';
	@override String get releaseloadmore => 'suelta para cargar más';
	@override String get nomoredata => 'No hay más Datos';
	@override String get events => 'Eventos';
	@override String get myplaylists => 'Mis Listas de Reproducción';
	@override String get articles => 'Artículos';
	@override String get notes => 'Notas';
	@override String get savenotetitle => 'Título de la Nota';
	@override String get nonotesfound => 'No se encontraron notas';
	@override String get newnote => 'Nueva';
	@override String get deletenote => 'Eliminar Nota';
	@override String get deletenotehint => '¿Desea eliminar esta nota? Esta acción no se puede deshacer.';
	@override String get allitems => 'Todos los Elementos';
	@override String get emptyplaylist => 'Sin Listas de Reproducción';
	@override String get notsupported => 'No Soportado';
	@override String get cleanupresources => 'Limpiando recursos';
	@override String get grantstoragepermission => 'Por favor conceda acceso a la memoria para continuar';
	@override String get sharefiletitle => 'Ver o Escuchar ';
	@override String get sharefilebody => 'A través de MyChurch App, Descarga ahora en ';
	@override String get sharetext => 'Disfruta de transmisión ilimitada de Audio y Video';
	@override String get sharetexthint => 'Únete a la plataforma de transmisión de video y audio que te permite ver y escuchar millones de archivos de todo el mundo. Descarga ahora en';
	@override String get branches => 'Sucursales';
	@override String get inbox => 'Bandeja de Entrada';
	@override String get viewinmap => 'Ver Ubicación en Mapa';
	@override String get member => 'Miembro(s)';
	@override String get join => 'Unirse al Grupo';
	@override String get by => 'POR';
	@override String get prayertitle => 'Título de la Oración';
	@override String get prayercontent => 'Contenido de la Oración';
	@override String get testimonytitle => 'Título del Testimonio';
	@override String get testimonycontent => 'Contenido del Testimonio';
	@override String get successprayerposting => 'Ha añadido correctamente una solicitud de oración, se publicará una vez que sea aprobada.';
	@override String get successtestimonyposting => 'Ha añadido correctamente un nuevo testimonio, se publicará una vez que sea aprobado.';
	@override String get addtestimony => 'Añadir Testimonio';
	@override String get groupsibelongto => 'Grupos a los que pertenezco';
	@override String get groupevents => 'Eventos/Actividades del Grupo';
	@override String get successjoinedgroup => 'Ha solicitado unirse a este grupo correctamente. Se le notificará por correo electrónico una vez que se apruebe esta solicitud.';
	@override String get createnote => 'Crear Nota';
	@override String get tapaddcontent => 'Toque para agregar contenido';
	@override String get done => 'Hecho';
	@override String get youversionbible => 'Usar Youversion Biblia';
	@override String get readbiblein => 'Leer la Biblia en';
	@override String get nodevotionals => 'No hay devocionales para el mes seleccionado';
	@override String get noevents => 'No hay eventos para el mes seleccionado';
	@override String get devotionalshint => 'Lecturas diarias para una vida devota.';
	@override String get recentmessages => 'Mensajes Recientes';
	@override String get eventshint => 'Eventos y anuncios';
	@override String get digdeepbible => 'Profundiza en la palabra de Dios.';
	@override String get upcomingevents => 'Nuestros Próximos Eventos';
	@override String get searchmessagesbooks => 'Buscar mensajes de audio y video';
	@override String get exploredeep => 'Explorar más Profundo';
	@override String get missionstatement => 'Es genial tenerte aquí, en MyChurch App, nos esforzamos por dominar la palabra de Dios y predicar el evangelio.';
	@override String get next => 'Siguiente';
	@override List<String> get onboardingpagetitles => [
		'Bienvenido a Church App',
		'Lleno de Funciones',
		'Audio, Video \n y Transmisión en Vivo',
		'Crear Cuenta',
	];
	@override List<String> get onboardingpagehints => [
		'Vaya más allá de las mañanas de domingo y las cuatro paredes de su iglesia. Todo lo que necesita para comunicarse y comprometerse con un mundo enfocado en dispositivos móviles.',
		'Hemos reunido todas las principales características que su aplicación de iglesia debe tener. Eventos, Devocionales, Notificaciones, Notas y biblia multiversión.',
		'Permita que los usuarios de todo el mundo vean videos, escuchen mensajes de audio y vean transmisiones en vivo de los servicios de su iglesia.',
		'Comience su viaje hacia una experiencia de adoración interminable.',
	];
	@override String get youneedtologintoreply => 'Debe iniciar sesión para agregar una respuesta';
	@override String get youneedtologintoreportpost => 'Debe iniciar sesión para informar un post';
	@override String get members => 'Miembros';
	@override String get logintolikeapost => 'Debe iniciar sesión para dar me gusta a un post de un miembro';
	@override String get logintopinapost => 'Debe iniciar sesión para anclar un post de un miembro';
	@override String get logintoreportapost => 'Debe iniciar sesión para informar un post';
	@override String get bookmarkshint => 'Marcar mensajes de audio y video';
	@override String get downloadershint => 'Descargar y ver mensajes sin conexión';
	@override String get playlistshint => 'Colección de mensajes de audio y video';
}

// Path: <root>
class _StringsFr implements _StringsEn {

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsFr.build();

	/// Access flat map
	@override dynamic operator[](String key) => _flatMap[key];

	// Internal flat map initialized lazily
	@override late final Map<String, dynamic> _flatMap = _buildFlatMap();

	@override late final _StringsFr _root = this; // ignore: unused_field

	// Translations
	@override String get appname => 'Church App';
	@override String get churchmotto => 'Towards global envagelism';
	@override String get initializingapp => 'Please wait while we setup a few things, it wont take long, we promise.';
	@override String get errorinitapp => 'Unfortunately, we could not complete setup at the moment, please check your internet connection, then click to retry';
	@override String get initappsucess => 'Congratulations, setup is now complete, you can now click to continue to app';
	@override String get retry => 'Try Again';
	@override String get continuetoapp => 'Continue to App';
	@override String get home => 'Home';
	@override String get media => 'Media';
	@override String get publications => 'Publications';
	@override String get connect => 'Connect';
	@override String get recentsermons => 'Recent Sermons';
	@override String get donate => 'Give Now';
	@override String get donatehint => 'God loves a cheerful giver.';
	@override String get bible => 'Bible';
	@override String get hymns => 'Hymns';
	@override String get devotionals => 'Devotionals';
	@override String get stayconnected => 'More ways to connect';
	@override String get radiostreams => 'Radio Streams';
	@override String get radiohint => 'Listen to our daily Radio Streams.';
	@override String get livestreams => 'Live Streams';
	@override String get livestreamshint => 'Connect to watch our live broadcasts.';
	@override String get videos => 'Video Messages';
	@override String get video => 'Videos';
	@override String get videoshint => 'Collection of video sermons.';
	@override String get audios => 'Audio Messages';
	@override String get audioshint => 'Collection of audio sermons';
	@override String get photos => 'Photo Gallery';
	@override String get photoshint => 'Browse through our church photo collections.';
	@override String get bookmarks => 'Bookmarks';
	@override String get playlists => 'Playlists';
	@override String get downloads => 'Downloads';
	@override String get books => 'Christian Books';
	@override String get recentarticles => 'Recent Articles';
	@override String get groups => 'Church Groups';
	@override String get groupshint => 'Church Groups are the best place to connect and fellowship with other believers.';
	@override String get Prayerrequests => 'Prayer Requests';
	@override String get prayerhint => 'Send a prayer request or join us to pray for other members.';
	@override String get testimonies => 'Testimonies';
	@override String get testimonyhint => 'Collection of personal testimonies of Gods healing power and deliverance.';
	@override String get churchlocation => 'Church Locations';
	@override String get churchlocationhint => 'Find a location near you and make plans to join us this Sunday!';
	@override String get facebookpage => 'Facebook Page';
	@override String get facebookpagehint => 'Connect with us on our Facebook community.';
	@override String get youtubepage => 'Youtube Page';
	@override String get youtubepagehint => 'Subscribe to our Youtube channel.';
	@override String get twitterpage => 'Twitter Page';
	@override String get twitterpagehint => 'Join the conversation on the Twitter platform.';
	@override String get instagrampage => 'Instagram Page';
	@override String get instagrampagehint => 'Follow us on Instagram to see the latest stories.';
	@override String get gosocial => 'Go Social';
	@override String get gosocialehint => 'Share your thought &\n chat with other members.';
	@override String get website => ' Our Website';
	@override String get terms => 'Terms & Conditions';
	@override String get privacy => 'Privacy Policy';
	@override String get about => 'About Us';
	@override String get rateapp => 'Rate App';
	@override String get account => 'Account';
	@override String get appsettings => 'App Settings Fr';
	@override String get guestuser => 'Guest User';
	@override String get createanaccounthint => 'Create an account or login to app';
	@override String get viewmyprofile => 'View my profile';
	@override String get logoutfromapp => 'Logout from App';
	@override String get deletemyaccount => 'Delete my account';
	@override String get applanguage => 'App Language';
	@override String get recieveinbox => 'Receive inbox notifications';
	@override String get recieveevents => 'Events';
	@override String get sermonnotification => 'Sermons';
	@override String get articlenotification => 'Articles';
	@override String get devotionalnotification => 'Devotionals';
	@override String get chooseapplanguage => 'Select App Language';
	@override String get emailaddress => 'Email Address';
	@override String get password => 'Password';
	@override String get confirmpassword => 'Confirm Password';
	@override String get passwordsdontmatch => 'Passwords dont match!';
	@override String get login => 'LOG IN';
	@override String get createaccount => 'Create Account';
	@override String get forgotpassword => 'Forgot Password?';
	@override String get resetpassword => 'Reset Password';
	@override String get resetpasswordhint => 'A reset password link will be sent to your email.';
	@override String get resetpasswordsuccess => 'If the email exists in our platform, you should recieve an instruction on how to reset your password.';
	@override String get goback => 'Go Back';
	@override String get ok => 'OK';
	@override String get cancel => 'CANCEL';
	@override String get resendverifycode => 'Resend Verification Link';
	@override String get successregistermessage => 'You have successfully created an account, please check your email for a verification link and verify your email address.';
	@override String get successresendverifymessage => 'A verification link have been sent to your email.';
	@override String get processingpleasewait => 'Processing, please wait...';
	@override String get cannotprocess => 'The requested operation cannot be processed at the moment, please try again later.';
	@override String get resendverifylink => 'A verification link was sent to your email address, visit the link to verify your email. Did not get the email? click the link below to resend verification link.';
	@override String get oops => 'Ooops!';
	@override String get save => 'Save';
	@override String get error => 'Error';
	@override String get success => 'Success';
	@override String get skip => 'Skip';
	@override String get downloadbible => 'Download Bible';
	@override String get downloadversion => 'Download';
	@override String get downloading => 'Downloading';
	@override String get failedtodownload => 'Failed to download';
	@override String get pleaseclicktoretry => 'Please click to retry.';
	@override String get of => 'Of';
	@override String get nobibleversionshint => 'There is no bible data to display, click on the button below to download atleast one bible version.';
	@override String get downloaded => 'Downloaded';
	@override String get enteremailaddresstoresetpassword => 'Enter your email to reset your password';
	@override String get backtologin => 'BACK TO LOGIN';
	@override String get signintocontinue => 'Sign in to continue';
	@override String get signin => 'S I G N  I N';
	@override String get signinforanaccount => 'SIGN UP FOR AN ACCOUNT?';
	@override String get alreadyhaveanaccount => 'Already have an account?';
	@override String get updateprofile => 'Update Profile';
	@override String get updateprofilehint => 'To get started, please update your profile page, this will help us in connecting you with other people';
	@override String get searchbible => 'Search Bible';
	@override String get filtersearchoptions => 'Filter Search Options';
	@override String get narrowdownsearch => 'Use the filter button below to narrow down search for a more precise result.';
	@override String get searchbibleversion => 'Search Bible Version';
	@override String get searchbiblebook => 'Search Bible Book';
	@override String get search => 'Search';
	@override String get setBibleBook => 'Set Bible Book';
	@override String get oldtestament => 'Old Testament';
	@override String get newtestament => 'New Testament';
	@override String get limitresults => 'Limit Results';
	@override String get setfilters => 'Set Filters';
	@override String get bibletranslator => 'Bible Translator';
	@override String get chapter => ' Chapter ';
	@override String get verse => ' Verse ';
	@override String get translate => 'translate';
	@override String get bibledownloadinfo => 'Bible Download started, Please do not close this page until the download is done.';
	@override String get received => 'received';
	@override String get outoftotal => 'out of total';
	@override String get set => 'SET';
	@override String get selectColor => 'Select Color';
	@override String get switchbibleversion => 'Switch Bible Version';
	@override String get switchbiblebook => 'Switch Bible Book';
	@override String get gotosearch => 'Go to Chapter';
	@override String get changefontsize => 'Change Font Size';
	@override String get font => 'Font';
	@override String get readchapter => 'Read Chapter';
	@override String get showhighlightedverse => 'Show Highlighted Verses';
	@override String get downloadmoreversions => 'Download more versions';
	@override String get suggestedusers => 'Suggested users to follow';
	@override String get unfollow => 'UnFollow';
	@override String get follow => 'Follow';
	@override String get searchforpeople => 'Search for people';
	@override String get viewpost => 'View Post';
	@override String get viewprofile => 'View Profile';
	@override String get mypins => 'My Pins';
	@override String get viewpinnedposts => 'View Pinned Posts';
	@override String get personal => 'Personal';
	@override String get update => 'Update';
	@override String get phonenumber => 'Phone Number';
	@override String get showmyphonenumber => 'Show my phone number to users';
	@override String get dateofbirth => 'Date of Birth';
	@override String get showmyfulldateofbirth => 'Show my full date of birth to people viewing my status';
	@override String get notifications => 'Notifications';
	@override String get notifywhenuserfollowsme => 'Notify me when a user follows me';
	@override String get notifymewhenusercommentsonmypost => 'Notify me when users comment on my post';
	@override String get notifymewhenuserlikesmypost => 'Notify me when users like my post';
	@override String get churchsocial => 'Church Social';
	@override String get shareyourthoughts => 'Share your thoughts';
	@override String get readmore => '...Read more';
	@override String get less => ' Less';
	@override String get couldnotprocess => 'Could not process requested action.';
	@override String get pleaseselectprofilephoto => 'Please select a profile photo to upload';
	@override String get pleaseselectprofilecover => 'Please select a cover photo to upload';
	@override String get updateprofileerrorhint => 'You need to fill your name, date of birth, gender, phone before you can proceed.';
	@override String get fullname => 'Full Name';
	@override String get firstname => 'First Name';
	@override String get lastname => 'Last Name';
	@override String get occupation => 'Occupation';
	@override String get gender => 'Gender';
	@override String get male => 'Male';
	@override String get female => 'Female';
	@override String get dob => 'Date Of Birth';
	@override String get address => 'Current Address';
	@override String get aboutme => 'About Me';
	@override String get facebookprofilelink => 'Facebook Profile Link';
	@override String get twitterprofilelink => 'Twitter Profile Link';
	@override String get linkdln => 'Linkedln Profile Link';
	@override String get likes => 'Likes';
	@override String get likess => 'Like(s)';
	@override String get pinnedposts => 'My Pinned Posts';
	@override String get unpinpost => 'Unpin Post';
	@override String get unpinposthint => 'Do you wish to remove this post from your pinned posts?';
	@override String get postdetails => 'Post Details';
	@override String get posts => 'Posts';
	@override String get followers => 'Followers';
	@override String get followings => 'Followings';
	@override String get my => 'My';
	@override String get edit => 'Edit';
	@override String get delete => 'Delete';
	@override String get deletepost => 'Delete Post';
	@override String get deleteposthint => 'Do you wish to delete this post? Posts can still appear on some users feeds.';
	@override String get maximumallowedsizehint => 'Maximum allowed file upload reached';
	@override String get maximumuploadsizehint => 'The selected file exceeds the allowed upload file size limit.';
	@override String get makeposterror => 'Unable to make post at the moment, please click to retry.';
	@override String get makepost => 'Make Post';
	@override String get selectfile => 'Select File';
	@override String get images => 'Images';
	@override String get shareYourThoughtsNow => 'Share your thoughts ...';
	@override String get photoviewer => 'Photo Viewer';
	@override String get nochatsavailable => 'No Conversations available \n Click the add icon below \nto select users to chat with';
	@override String get typing => 'Typing...';
	@override String get photo => 'Photo';
	@override String get online => 'Online';
	@override String get offline => 'Offline';
	@override String get lastseen => 'Last Seen';
	@override String get deleteselectedhint => 'This action will delete the selected messages.  Please note that this only deletes your side of the conversation, \n the messages will still show on your partners device.';
	@override String get deleteselected => 'Delete selected';
	@override String get unabletofetchconversation => 'Unable to Fetch \nyour conversation with \n';
	@override String get loadmoreconversation => 'Load more conversations';
	@override String get sendyourfirstmessage => 'Send your first message to \n';
	@override String get unblock => 'Unblock ';
	@override String get block => 'Block';
	@override String get writeyourmessage => 'Write your message...';
	@override String get clearconversation => 'Clear Conversation';
	@override String get clearconversationhintone => 'This action will clear all your conversation with ';
	@override String get clearconversationhinttwo => '.\n  Please note that this only deletes your side of the conversation, the messages will still show on your partners chat.';
	@override String get logoutfromapphint => 'You wont be able to access some priviledges if you are not logged in.';
	@override String get deleteaccount => 'Delete my account';
	@override String get deleteaccounthint => 'This action will delete your account and remove all your data, once your data is deleted, it cannot be recovered.';
	@override String get deleteaccountsuccess => 'Account deletion was succesful';
	@override String get myprofile => 'My Profile';
	@override String get noitemstodisplay => 'No Items To Display';
	@override String get copiedtoclipboard => 'Copied to clipboard';
	@override String get biblebooks => 'Bible';
	@override String get searchhint => 'Search Audio & Video Messages';
	@override String get performingsearch => 'Searching Audios and Videos';
	@override String get nosearchresult => 'No results Found';
	@override String get nosearchresulthint => 'Try input more general keyword';
	@override String get dataloaderror => 'Could not load requested data at the moment, check your data connection and click to retry.';
	@override String get download => 'Download';
	@override String get addplaylist => 'Add to playlist';
	@override String get bookmark => 'Bookmark';
	@override String get unbookmark => 'UnBookmark';
	@override String get share => 'Share';
	@override String get deletemedia => 'Delete File';
	@override String get deletemediahint => 'Do you wish to delete this downloaded file? This action cannot be undone.';
	@override String get comments => 'Comments';
	@override String get replies => 'Replies';
	@override String get reply => 'Reply';
	@override String get logintoaddcomment => 'Login to add a comment';
	@override String get logintoreply => 'Login to reply';
	@override String get writeamessage => 'Write a message...';
	@override String get nocomments => 'No Comments found \nclick to retry';
	@override String get errormakingcomments => 'Cannot process commenting at the moment..';
	@override String get errordeletingcomments => 'Cannot delete this comment at the moment..';
	@override String get erroreditingcomments => 'Cannot edit this comment at the moment..';
	@override String get errorloadingmorecomments => 'Cannot load more comments at the moment..';
	@override String get deletingcomment => 'Deleting comment';
	@override String get editingcomment => 'Editing comment';
	@override String get deletecommentalert => 'Delete Comment';
	@override String get editcommentalert => 'Edit Comment';
	@override String get deletecommentalerttext => 'Do you wish to delete this comment? This action cannot be undone';
	@override String get loadmore => 'load more';
	@override String get errorReportingComment => 'Error Reporting Comment';
	@override String get reportingComment => 'Reporting Comment';
	@override String get reportcomment => 'Report Options';
	@override List<String> get reportCommentsList => [
		'Unwanted commercial content or spam',
		'Pornography or sexual explicit material',
		'Hate speech or graphic violence',
		'Harassment or bullying',
	];
	@override String get addtoplaylist => 'Add to playlist';
	@override String get newplaylist => 'New playlist';
	@override String get playlistitm => 'Playlist';
	@override String get mediaaddedtoplaylist => 'Media added to playlist.';
	@override String get mediaremovedfromplaylist => 'Media removed from playlist';
	@override String get clearplaylistmedias => 'Clear All Media';
	@override String get deletePlayList => 'Delete Playlist';
	@override String get clearplaylistmediashint => 'Go ahead and remove all media from this playlist?';
	@override String get deletePlayListhint => 'Go ahead and delete this playlist and clear all media?';
	@override String get pulluploadmore => 'pull up load';
	@override String get loadfailedretry => 'Load Failed!Click retry!';
	@override String get releaseloadmore => 'release to load more';
	@override String get nomoredata => 'No more Data';
	@override String get events => 'Events';
	@override String get myplaylists => 'My Playlists';
	@override String get articles => 'Articles';
	@override String get notes => 'Notes';
	@override String get savenotetitle => 'Note Title';
	@override String get nonotesfound => 'No notes found';
	@override String get newnote => 'New';
	@override String get deletenote => 'Delete Note';
	@override String get deletenotehint => 'Do you want to delete this note? This action cannot be reversed.';
	@override String get allitems => 'All Items';
	@override String get emptyplaylist => 'No Playlists';
	@override String get notsupported => 'Not Supported';
	@override String get cleanupresources => 'Cleaning up resources';
	@override String get grantstoragepermission => 'Please grant accessing storage permission to continue';
	@override String get sharefiletitle => 'Watch or Listen to ';
	@override String get sharefilebody => 'Via MyChurch App, Download now at ';
	@override String get sharetext => 'Enjoy unlimited Audio & Video streaming';
	@override String get sharetexthint => 'Join the Video and Audio streaming platform that lets you watch and listen to millions of files from around the world. Download now at';
	@override String get branches => 'Branches';
	@override String get inbox => 'Inbox';
	@override String get viewinmap => 'View Location in Map';
	@override String get member => 'Member(s)';
	@override String get join => 'Join Group';
	@override String get by => 'BY';
	@override String get prayertitle => 'Prayer Title';
	@override String get prayercontent => 'Prayer Content';
	@override String get testimonytitle => 'Testimony Title';
	@override String get testimonycontent => 'Testimony Content';
	@override String get successprayerposting => 'You have successfully added a prayer request, it will be published once it is approved.';
	@override String get successtestimonyposting => 'You have successfully added a new testimony, it will be published once it is approved.';
	@override String get addtestimony => 'Add Testimony';
	@override String get groupsibelongto => 'Groups i belong to';
	@override String get groupevents => 'Group Events/Activities';
	@override String get successjoinedgroup => 'You have successfully requested to join this group, You will be notified by email once this request is granted.';
	@override String get createnote => 'Create Note';
	@override String get tapaddcontent => 'Tap to add content';
	@override String get done => 'Done';
	@override String get youversionbible => 'Use Youversion Bible Reader';
	@override String get readbiblein => 'Read Bible in';
	@override String get nodevotionals => 'No devotionals for selected month';
	@override String get noevents => 'No events for selected month';
	@override String get devotionalshint => 'Daily readings for devoted living.';
	@override String get recentmessages => 'Recent Messages';
	@override String get eventshint => 'Events & announcements';
	@override String get digdeepbible => 'Dig deep into the word of God.';
	@override String get upcomingevents => 'Our Upcoming Events';
	@override String get searchmessagesbooks => 'Search for audio & video messages';
	@override String get exploredeep => 'Explore Deeper';
	@override String get missionstatement => 'Great to have you here, at Mychurch App, we strive for mastery at Gods word and preaching the gospel. ';
	@override String get next => 'Next';
	@override List<String> get onboardingpagetitles => [
		'Welcome to MFM Lekki TMPM 1 App',
		'Benefits of the App',
		'Audio, Video \n and Live Streaming',
		'Create Account',
	];
	@override List<String> get onboardingpagehints => [
		'A vibrant worship centre committed to prayer, deliverance, holiness, and raising champions for Christ.',
		'Stay connected with church updates, programmes, and spiritual resources designed to strengthen your walk with God.',
		'Access sermons, prayer sessions, and live services anytime from anywhere.',
		'Start your journey to a never-ending worship experience.',
	];
	@override String get youneedtologintoreply => 'You need to login to add a reply';
	@override String get youneedtologintoreportpost => 'You need to login to report a post';
	@override String get members => 'Members';
	@override String get logintolikeapost => 'You need to login to like a member post';
	@override String get logintopinapost => 'You need to login to pin a member post';
	@override String get logintoreportapost => 'You need to login to report post';
	@override String get bookmarkshint => 'Bookmark audio and video messages';
	@override String get downloadershint => 'Download and watch offline messages';
	@override String get playlistshint => 'Collection of audio and video messages';
	@override String get optionalprofileinformation => 'Informations de Profil Facultatives';
	@override String get optionalhint => 'Ces champs sont facultatifs et ne sont pas nécessaires pour utiliser l\'application.';
}

// Path: <root>
class _StringsPt implements _StringsEn {

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsPt.build();

	/// Access flat map
	@override dynamic operator[](String key) => _flatMap[key];

	// Internal flat map initialized lazily
	@override late final Map<String, dynamic> _flatMap = _buildFlatMap();

	@override late final _StringsPt _root = this; // ignore: unused_field

	// Translations
	@override String get appname => 'MyChurch App';
	@override String get churchmotto => 'Towards global envagelism';
	@override String get initializingapp => 'Please wait while we setup a few things, it wont take long, we promise.';
	@override String get errorinitapp => 'Unfortunately, we could not complete setup at the moment, please check your internet connection, then click to retry';
	@override String get initappsucess => 'Congratulations, setup is now complete, you can now click to continue to app';
	@override String get retry => 'Try Again';
	@override String get continuetoapp => 'Continue to App';
	@override String get home => 'Home';
	@override String get media => 'Media';
	@override String get publications => 'Publications';
	@override String get connect => 'Connect';
	@override String get recentsermons => 'Recent Sermons';
	@override String get donate => 'Give Now';
	@override String get donatehint => 'God loves a cheerful giver.';
	@override String get bible => 'Bible';
	@override String get hymns => 'Hymns';
	@override String get devotionals => 'Devotionals';
	@override String get stayconnected => 'More ways to connect';
	@override String get radiostreams => 'Radio Streams';
	@override String get radiohint => 'Listen to our daily Radio Streams.';
	@override String get livestreams => 'Live Streams';
	@override String get livestreamshint => 'Connect to watch our live broadcasts.';
	@override String get videos => 'Video Messages';
	@override String get video => 'Videos';
	@override String get videoshint => 'Collection of video sermons.';
	@override String get audios => 'Audio Messages';
	@override String get audioshint => 'Collection of audio sermons';
	@override String get photos => 'Photo Gallery';
	@override String get photoshint => 'Browse through our church photo collections.';
	@override String get bookmarks => 'Bookmarks';
	@override String get playlists => 'Playlists';
	@override String get downloads => 'Downloads';
	@override String get books => 'Christian Books';
	@override String get recentarticles => 'Recent Articles';
	@override String get groups => 'Church Groups';
	@override String get groupshint => 'Church Groups are the best place to connect and fellowship with other believers.';
	@override String get Prayerrequests => 'Prayer Requests';
	@override String get prayerhint => 'Send a prayer request or join us to pray for other members.';
	@override String get testimonies => 'Testimonies';
	@override String get testimonyhint => 'Collection of personal testimonies of Gods healing power and deliverance.';
	@override String get churchlocation => 'Church Locations';
	@override String get churchlocationhint => 'Find a location near you and make plans to join us this Sunday!';
	@override String get facebookpage => 'Facebook Page';
	@override String get facebookpagehint => 'Connect with us on our Facebook community.';
	@override String get youtubepage => 'Youtube Page';
	@override String get youtubepagehint => 'Subscribe to our Youtube channel.';
	@override String get twitterpage => 'Twitter Page';
	@override String get twitterpagehint => 'Join the conversation on the Twitter platform.';
	@override String get instagrampage => 'Instagram Page';
	@override String get instagrampagehint => 'Follow us on Instagram to see the latest stories.';
	@override String get gosocial => 'Go Social';
	@override String get gosocialehint => 'Share your thought &\n chat with other members.';
	@override String get website => ' Our Website';
	@override String get terms => 'Terms & Conditions';
	@override String get privacy => 'Privacy Policy';
	@override String get about => 'About Us';
	@override String get rateapp => 'Rate App';
	@override String get account => 'Account';
	@override String get appsettings => 'App Settings';
	@override String get guestuser => 'Guest User';
	@override String get createanaccounthint => 'Create an account or login to app';
	@override String get viewmyprofile => 'View my profile';
	@override String get logoutfromapp => 'Logout from App';
	@override String get deletemyaccount => 'Delete my account';
	@override String get applanguage => 'App Language';
	@override String get recieveinbox => 'Receive inbox notifications';
	@override String get recieveevents => 'Events';
	@override String get sermonnotification => 'Sermons';
	@override String get articlenotification => 'Articles';
	@override String get devotionalnotification => 'Devotionals';
	@override String get chooseapplanguage => 'Select App Language';
	@override String get emailaddress => 'Email Address';
	@override String get password => 'Password';
	@override String get confirmpassword => 'Confirm Password';
	@override String get passwordsdontmatch => 'Passwords dont match!';
	@override String get login => 'LOG IN';
	@override String get createaccount => 'Create Account';
	@override String get forgotpassword => 'Forgot Password?';
	@override String get resetpassword => 'Reset Password';
	@override String get resetpasswordhint => 'A reset password link will be sent to your email.';
	@override String get resetpasswordsuccess => 'If the email exists in our platform, you should recieve an instruction on how to reset your password.';
	@override String get goback => 'Go Back';
	@override String get ok => 'OK';
	@override String get cancel => 'CANCEL';
	@override String get resendverifycode => 'Resend Verification Link';
	@override String get successregistermessage => 'You have successfully created an account, please check your email for a verification link and verify your email address.';
	@override String get successresendverifymessage => 'A verification link have been sent to your email.';
	@override String get resendverifylink => 'A verification link was sent to your email address, visit the link to verify your email. Did not get the email? click the link below to resend verification link.';
	@override String get processingpleasewait => 'Processing, please wait...';
	@override String get cannotprocess => 'The requested operation cannot be processed at the moment, please try again later.';
	@override String get oops => 'Ooops!';
	@override String get save => 'Save';
	@override String get error => 'Error';
	@override String get success => 'Success';
	@override String get skip => 'Skip';
	@override String get downloadbible => 'Download Bible';
	@override String get downloadversion => 'Download';
	@override String get downloading => 'Downloading';
	@override String get failedtodownload => 'Failed to download';
	@override String get pleaseclicktoretry => 'Please click to retry.';
	@override String get of => 'Of';
	@override String get nobibleversionshint => 'There is no bible data to display, click on the button below to download atleast one bible version.';
	@override String get downloaded => 'Downloaded';
	@override String get enteremailaddresstoresetpassword => 'Enter your email to reset your password';
	@override String get backtologin => 'BACK TO LOGIN';
	@override String get signintocontinue => 'Sign in to continue';
	@override String get signin => 'S I G N  I N';
	@override String get signinforanaccount => 'SIGN UP FOR AN ACCOUNT?';
	@override String get alreadyhaveanaccount => 'Already have an account?';
	@override String get updateprofile => 'Update Profile';
	@override String get updateprofilehint => 'To get started, please update your profile page, this will help us in connecting you with other people';
	@override String get searchbible => 'Search Bible';
	@override String get filtersearchoptions => 'Filter Search Options';
	@override String get narrowdownsearch => 'Use the filter button below to narrow down search for a more precise result.';
	@override String get searchbibleversion => 'Search Bible Version';
	@override String get searchbiblebook => 'Search Bible Book';
	@override String get search => 'Search';
	@override String get setBibleBook => 'Set Bible Book';
	@override String get oldtestament => 'Old Testament';
	@override String get newtestament => 'New Testament';
	@override String get limitresults => 'Limit Results';
	@override String get setfilters => 'Set Filters';
	@override String get bibletranslator => 'Bible Translator';
	@override String get chapter => ' Chapter ';
	@override String get verse => ' Verse ';
	@override String get translate => 'translate';
	@override String get bibledownloadinfo => 'Bible Download started, Please do not close this page until the download is done.';
	@override String get received => 'received';
	@override String get outoftotal => 'out of total';
	@override String get set => 'SET';
	@override String get selectColor => 'Select Color';
	@override String get switchbibleversion => 'Switch Bible Version';
	@override String get switchbiblebook => 'Switch Bible Book';
	@override String get gotosearch => 'Go to Chapter';
	@override String get changefontsize => 'Change Font Size';
	@override String get font => 'Font';
	@override String get readchapter => 'Read Chapter';
	@override String get showhighlightedverse => 'Show Highlighted Verses';
	@override String get downloadmoreversions => 'Download more versions';
	@override String get suggestedusers => 'Suggested users to follow';
	@override String get unfollow => 'UnFollow';
	@override String get follow => 'Follow';
	@override String get searchforpeople => 'Search for people';
	@override String get viewpost => 'View Post';
	@override String get viewprofile => 'View Profile';
	@override String get mypins => 'My Pins';
	@override String get viewpinnedposts => 'View Pinned Posts';
	@override String get personal => 'Personal';
	@override String get update => 'Update';
	@override String get phonenumber => 'Phone Number';
	@override String get showmyphonenumber => 'Show my phone number to users';
	@override String get dateofbirth => 'Date of Birth';
	@override String get showmyfulldateofbirth => 'Show my full date of birth to people viewing my status';
	@override String get notifications => 'Notifications';
	@override String get notifywhenuserfollowsme => 'Notify me when a user follows me';
	@override String get notifymewhenusercommentsonmypost => 'Notify me when users comment on my post';
	@override String get notifymewhenuserlikesmypost => 'Notify me when users like my post';
	@override String get churchsocial => 'Church Social';
	@override String get shareyourthoughts => 'Share your thoughts';
	@override String get readmore => '...Read more';
	@override String get less => ' Less';
	@override String get couldnotprocess => 'Could not process requested action.';
	@override String get pleaseselectprofilephoto => 'Please select a profile photo to upload';
	@override String get pleaseselectprofilecover => 'Please select a cover photo to upload';
	@override String get updateprofileerrorhint => 'You need to fill your name, date of birth, gender, phone before you can proceed.';
	@override String get fullname => 'Full Name';
	@override String get firstname => 'First Name';
	@override String get lastname => 'Last Name';
	@override String get occupation => 'Occupation';
	@override String get gender => 'Gender';
	@override String get male => 'Male';
	@override String get female => 'Female';
	@override String get dob => 'Date Of Birth';
	@override String get address => 'Current Address';
	@override String get aboutme => 'About Me';
	@override String get facebookprofilelink => 'Facebook Profile Link';
	@override String get twitterprofilelink => 'Twitter Profile Link';
	@override String get linkdln => 'Linkedln Profile Link';
	@override String get likes => 'Likes';
	@override String get likess => 'Like(s)';
	@override String get pinnedposts => 'My Pinned Posts';
	@override String get unpinpost => 'Unpin Post';
	@override String get unpinposthint => 'Do you wish to remove this post from your pinned posts?';
	@override String get postdetails => 'Post Details';
	@override String get posts => 'Posts';
	@override String get followers => 'Followers';
	@override String get followings => 'Followings';
	@override String get my => 'My';
	@override String get edit => 'Edit';
	@override String get delete => 'Delete';
	@override String get deletepost => 'Delete Post';
	@override String get deleteposthint => 'Do you wish to delete this post? Posts can still appear on some users feeds.';
	@override String get maximumallowedsizehint => 'Maximum allowed file upload reached';
	@override String get maximumuploadsizehint => 'The selected file exceeds the allowed upload file size limit.';
	@override String get makeposterror => 'Unable to make post at the moment, please click to retry.';
	@override String get makepost => 'Make Post';
	@override String get selectfile => 'Select File';
	@override String get images => 'Images';
	@override String get shareYourThoughtsNow => 'Share your thoughts ...';
	@override String get photoviewer => 'Photo Viewer';
	@override String get nochatsavailable => 'No Conversations available \n Click the add icon below \nto select users to chat with';
	@override String get typing => 'Typing...';
	@override String get photo => 'Photo';
	@override String get online => 'Online';
	@override String get offline => 'Offline';
	@override String get lastseen => 'Last Seen';
	@override String get deleteselectedhint => 'This action will delete the selected messages.  Please note that this only deletes your side of the conversation, \n the messages will still show on your partners device.';
	@override String get deleteselected => 'Delete selected';
	@override String get unabletofetchconversation => 'Unable to Fetch \nyour conversation with \n';
	@override String get loadmoreconversation => 'Load more conversations';
	@override String get sendyourfirstmessage => 'Send your first message to \n';
	@override String get unblock => 'Unblock ';
	@override String get block => 'Block';
	@override String get writeyourmessage => 'Write your message...';
	@override String get clearconversation => 'Clear Conversation';
	@override String get clearconversationhintone => 'This action will clear all your conversation with ';
	@override String get clearconversationhinttwo => '.\n  Please note that this only deletes your side of the conversation, the messages will still show on your partners chat.';
	@override String get logoutfromapphint => 'You wont be able to access some priviledges if you are not logged in.';
	@override String get deleteaccount => 'Delete my account';
	@override String get deleteaccounthint => 'This action will delete your account and remove all your data, once your data is deleted, it cannot be recovered.';
	@override String get deleteaccountsuccess => 'Account deletion was succesful';
	@override String get myprofile => 'My Profile';
	@override String get noitemstodisplay => 'No Items To Display';
	@override String get copiedtoclipboard => 'Copied to clipboard';
	@override String get biblebooks => 'Bible';
	@override String get searchhint => 'Search Audio & Video Messages';
	@override String get performingsearch => 'Searching Audios and Videos';
	@override String get nosearchresult => 'No results Found';
	@override String get nosearchresulthint => 'Try input more general keyword';
	@override String get dataloaderror => 'Could not load requested data at the moment, check your data connection and click to retry.';
	@override String get download => 'Download';
	@override String get addplaylist => 'Add to playlist';
	@override String get bookmark => 'Bookmark';
	@override String get unbookmark => 'UnBookmark';
	@override String get share => 'Share';
	@override String get deletemedia => 'Delete File';
	@override String get deletemediahint => 'Do you wish to delete this downloaded file? This action cannot be undone.';
	@override String get comments => 'Comments';
	@override String get replies => 'Replies';
	@override String get reply => 'Reply';
	@override String get logintoaddcomment => 'Login to add a comment';
	@override String get logintoreply => 'Login to reply';
	@override String get writeamessage => 'Write a message...';
	@override String get nocomments => 'No Comments found \nclick to retry';
	@override String get errormakingcomments => 'Cannot process commenting at the moment..';
	@override String get errordeletingcomments => 'Cannot delete this comment at the moment..';
	@override String get erroreditingcomments => 'Cannot edit this comment at the moment..';
	@override String get errorloadingmorecomments => 'Cannot load more comments at the moment..';
	@override String get deletingcomment => 'Deleting comment';
	@override String get editingcomment => 'Editing comment';
	@override String get deletecommentalert => 'Delete Comment';
	@override String get editcommentalert => 'Edit Comment';
	@override String get deletecommentalerttext => 'Do you wish to delete this comment? This action cannot be undone';
	@override String get loadmore => 'load more';
	@override String get errorReportingComment => 'Error Reporting Comment';
	@override String get reportingComment => 'Reporting Comment';
	@override String get reportcomment => 'Report Options';
	@override List<String> get reportCommentsList => [
		'Unwanted commercial content or spam',
		'Pornography or sexual explicit material',
		'Hate speech or graphic violence',
		'Harassment or bullying',
	];
	@override String get addtoplaylist => 'Add to playlist';
	@override String get newplaylist => 'New playlist';
	@override String get playlistitm => 'Playlist';
	@override String get mediaaddedtoplaylist => 'Media added to playlist.';
	@override String get mediaremovedfromplaylist => 'Media removed from playlist';
	@override String get clearplaylistmedias => 'Clear All Media';
	@override String get deletePlayList => 'Delete Playlist';
	@override String get clearplaylistmediashint => 'Go ahead and remove all media from this playlist?';
	@override String get deletePlayListhint => 'Go ahead and delete this playlist and clear all media?';
	@override String get pulluploadmore => 'pull up load';
	@override String get loadfailedretry => 'Load Failed!Click retry!';
	@override String get releaseloadmore => 'release to load more';
	@override String get nomoredata => 'No more Data';
	@override String get events => 'Events';
	@override String get myplaylists => 'My Playlists';
	@override String get articles => 'Articles';
	@override String get notes => 'Notes';
	@override String get savenotetitle => 'Note Title';
	@override String get nonotesfound => 'No notes found';
	@override String get newnote => 'New';
	@override String get deletenote => 'Delete Note';
	@override String get deletenotehint => 'Do you want to delete this note? This action cannot be reversed.';
	@override String get allitems => 'All Items';
	@override String get emptyplaylist => 'No Playlists';
	@override String get notsupported => 'Not Supported';
	@override String get cleanupresources => 'Cleaning up resources';
	@override String get grantstoragepermission => 'Please grant accessing storage permission to continue';
	@override String get sharefiletitle => 'Watch or Listen to ';
	@override String get sharefilebody => 'Via MyChurch App, Download now at ';
	@override String get sharetext => 'Enjoy unlimited Audio & Video streaming';
	@override String get sharetexthint => 'Join the Video and Audio streaming platform that lets you watch and listen to millions of files from around the world. Download now at';
	@override String get branches => 'Branches';
	@override String get inbox => 'Inbox';
	@override String get viewinmap => 'View Location in Map';
	@override String get member => 'Member(s)';
	@override String get join => 'Join Group';
	@override String get by => 'BY';
	@override String get prayertitle => 'Prayer Title';
	@override String get prayercontent => 'Prayer Content';
	@override String get testimonytitle => 'Testimony Title';
	@override String get testimonycontent => 'Testimony Content';
	@override String get successprayerposting => 'You have successfully added a prayer request, it will be published once it is approved.';
	@override String get successtestimonyposting => 'You have successfully added a new testimony, it will be published once it is approved.';
	@override String get addtestimony => 'Add Testimony';
	@override String get groupsibelongto => 'Groups i belong to';
	@override String get groupevents => 'Group Events/Activities';
	@override String get successjoinedgroup => 'You have successfully requested to join this group, You will be notified by email once this request is granted.';
	@override String get createnote => 'Create Note';
	@override String get tapaddcontent => 'Tap to add content';
	@override String get done => 'Done';
	@override String get youversionbible => 'Use Youversion Bible Reader';
	@override String get readbiblein => 'Read Bible in';
	@override String get nodevotionals => 'No devotionals for selected month';
	@override String get noevents => 'No events for selected month';
	@override String get devotionalshint => 'Daily readings for devoted living.';
	@override String get recentmessages => 'Recent Messages';
	@override String get eventshint => 'Events & announcements';
	@override String get digdeepbible => 'Dig deep into the word of God.';
	@override String get upcomingevents => 'Our Upcoming Events';
	@override String get searchmessagesbooks => 'Search for audio & video messages';
	@override String get exploredeep => 'Explore Deeper';
	@override String get missionstatement => 'Great to have you here, at Mychurch App, we strive for mastery at Gods word and preaching the gospel. ';
	@override String get next => 'Next';
	@override List<String> get onboardingpagetitles => [
		'Welcome to MFM Lekki TMPM 1 App',
		'Benefits of the App',
		'Audio, Video \n and Live Streaming',
		'Create Account',
	];
	@override List<String> get onboardingpagehints => [
		'A vibrant worship centre committed to prayer, deliverance, holiness, and raising champions for Christ.',
		'Stay connected with church updates, programmes, and spiritual resources designed to strengthen your walk with God.',
		'Access sermons, prayer sessions, and live services anytime from anywhere.',
		'Start your journey to a never-ending worship experience.',
	];
	@override String get youneedtologintoreply => 'You need to login to add a reply';
	@override String get youneedtologintoreportpost => 'You need to login to report a post';
	@override String get members => 'Members';
	@override String get logintolikeapost => 'You need to login to like a member post';
	@override String get logintopinapost => 'You need to login to pin a member post';
	@override String get logintoreportapost => 'You need to login to report post';
	@override String get bookmarkshint => 'Bookmark audio and video messages';
	@override String get downloadershint => 'Download and watch offline messages';
	@override String get playlistshint => 'Collection of audio and video messages';
	@override String get optionalprofileinformation => 'Informações Opcionais do Perfil';
	@override String get optionalhint => 'Estes campos são opcionais e não são necessários para usar o aplicativo.';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on _StringsEn {
	Map<String, dynamic> _buildFlatMap() {
		return <String, dynamic>{
			'appname': 'MFM Lekki TMPM 1',
			'churchmotto': 'Towards global envagelism',
			'initializingapp': 'Please wait while we setup a few things, it wont take long, we promise.',
			'errorinitapp': 'Unfortunately, we could not complete setup at the moment, please check your internet connection, then click to retry',
			'initappsucess': 'Congratulations, setup is now complete, you can now click to continue to app',
			'retry': 'Try Again',
			'continuetoapp': 'Continue to App',
			'home': 'Home',
			'media': 'Media',
			'publications': 'Publications',
			'connect': 'Connect',
			'recentsermons': 'Recent Sermons',
			'donate': 'Give Now',
			'donatehint': 'God loves a cheerful giver.',
			'bible': 'Bible',
			'hymns': 'Hymns',
			'devotionals': 'Devotionals',
			'stayconnected': 'More ways to stay connected',
			'radiostreams': 'Radio Streams',
			'radiohint': 'Listen to our daily Radio Streams.',
			'livestreams': 'Live Streams',
			'livestreamshint': 'Connect to watch our live broadcasts.',
			'video': 'Videos',
			'videos': 'Video Messages',
			'videoshint': 'Collection of video sermons.',
			'audios': 'Audio Messages',
			'audioshint': 'Collection of audio sermons',
			'photos': 'Photo Gallery',
			'photoshint': 'Browse through our church photo collections.',
			'bookmarks': 'Bookmarks',
			'playlists': 'Playlists',
			'downloads': 'Downloads',
			'books': 'Christian Books',
			'recentarticles': 'Recent Articles',
			'groups': 'Church Groups',
			'groupshint': 'Church Groups are the best place to connect and fellowship with other believers.',
			'Prayerrequests': 'Prayer Requests',
			'prayerhint': 'Send a prayer request or join us to pray for other members.',
			'testimonies': 'Testimonies',
			'testimonyhint': 'Collection of personal testimonies of Gods healing power and deliverance.',
			'churchlocation': 'Church Locations',
			'churchlocationhint': 'Find a location near you and make plans to join us this Sunday!',
			'facebookpage': 'Facebook Page',
			'facebookpagehint': 'Connect with us on our Facebook community.',
			'youtubepage': 'Youtube Page',
			'youtubepagehint': 'Subscribe to our Youtube channel.',
			'twitterpage': 'Twitter Page',
			'twitterpagehint': 'Join the conversation on the Twitter platform.',
			'instagrampage': 'Instagram Page',
			'instagrampagehint': 'Follow us on Instagram to see the latest stories.',
			'gosocial': 'Go Social',
			'gosocialehint': 'Share your thought &\n chat with other members.',
			'website': ' Our Website',
			'terms': 'Terms & Conditions',
			'privacy': 'Privacy Policy',
			'about': 'About Us',
			'rateapp': 'Rate App',
			'account': 'Account',
			'appsettings': 'App Settings',
			'guestuser': 'Guest User',
			'createanaccounthint': 'Create an account or login to app',
			'viewmyprofile': 'View my profile',
			'logoutfromapp': 'Logout from App',
			'deletemyaccount': 'Delete my account',
			'applanguage': 'App Language',
			'recieveinbox': 'Receive inbox notifications',
			'recieveevents': 'Events',
			'sermonnotification': 'Sermons',
			'articlenotification': 'Articles',
			'devotionalnotification': 'Devotionals',
			'chooseapplanguage': 'Select App Language',
			'emailaddress': 'Email Address',
			'password': 'Password',
			'confirmpassword': 'Confirm Password',
			'passwordsdontmatch': 'Passwords dont match!',
			'login': 'LOG IN',
			'createaccount': 'Create Account',
			'forgotpassword': 'Forgot Password?',
			'resetpassword': 'Reset Password',
			'resetpasswordhint': 'A reset password link will be sent to your email.',
			'resetpasswordsuccess': 'If the email exists in our platform, you should recieve an instruction on how to reset your password.',
			'goback': 'Go Back',
			'ok': 'OK',
			'cancel': 'CANCEL',
			'resendverifycode': 'Resend Verification Link',
			'successregistermessage': 'You have successfully created an account, please check your email for a verification link and verify your email address.',
			'successresendverifymessage': 'A verification link have been sent to your email.',
			'resendverifylink': 'A verification link was sent to your email address, visit the link to verify your email. Did not get the email? click the link below to resend verification link.',
			'processingpleasewait': 'Processing, please wait...',
			'cannotprocess': 'The requested operation cannot be processed at the moment, please try again later.',
			'oops': 'Ooops!',
			'save': 'Save',
			'error': 'Error',
			'success': 'Success',
			'skip': 'Skip',
			'downloadbible': 'Download Bible',
			'downloadversion': 'Download',
			'downloading': 'Downloading',
			'failedtodownload': 'Failed to download',
			'pleaseclicktoretry': 'Please click to retry.',
			'of': 'Of',
			'nobibleversionshint': 'There is no bible data to display, click on the button below to download atleast one bible version.',
			'downloaded': 'Downloaded',
			'enteremailaddresstoresetpassword': 'Enter your email to reset your password',
			'backtologin': 'BACK TO LOGIN',
			'signintocontinue': 'Sign in to continue',
			'signin': 'S I G N  I N',
			'signinforanaccount': 'SIGN UP FOR AN ACCOUNT?',
			'alreadyhaveanaccount': 'Already have an account?',
			'updateprofile': 'Update Profile',
			'updateprofilehint': 'To get started, please update your profile page, this will help us in connecting you with other people',
			'searchbible': 'Search Bible',
			'filtersearchoptions': 'Filter Search Options',
			'narrowdownsearch': 'Use the filter button below to narrow down search for a more precise result.',
			'searchbibleversion': 'Search Bible Version',
			'searchbiblebook': 'Search Bible Book',
			'search': 'Search',
			'setBibleBook': 'Set Bible Book',
			'oldtestament': 'Old Testament',
			'newtestament': 'New Testament',
			'limitresults': 'Limit Results',
			'setfilters': 'Set Filters',
			'bibletranslator': 'Bible Translator',
			'chapter': ' Chapter ',
			'verse': ' Verse ',
			'translate': 'translate',
			'bibledownloadinfo': 'Bible Download started, Please do not close this page until the download is done.',
			'received': 'received',
			'outoftotal': 'out of total',
			'set': 'SET',
			'selectColor': 'Select Color',
			'switchbibleversion': 'Switch Bible Version',
			'switchbiblebook': 'Switch Bible Book',
			'gotosearch': 'Go to Chapter',
			'changefontsize': 'Change Font Size',
			'font': 'Font',
			'readchapter': 'Read Chapter',
			'showhighlightedverse': 'Show Highlighted Verses',
			'downloadmoreversions': 'Download more versions',
			'suggestedusers': 'Suggested users to follow',
			'unfollow': 'UnFollow',
			'follow': 'Follow',
			'searchforpeople': 'Search for people',
			'viewpost': 'View Post',
			'viewprofile': 'View Profile',
			'mypins': 'My Pins',
			'viewpinnedposts': 'View Pinned Posts',
			'personal': 'Personal',
			'update': 'Update',
			'phonenumber': 'Phone Number',
			'showmyphonenumber': 'Show my phone number to users',
			'dateofbirth': 'Date of Birth',
			'showmyfulldateofbirth': 'Show my full date of birth to people viewing my status',
			'notifications': 'Notifications',
			'notifywhenuserfollowsme': 'Notify me when a user follows me',
			'notifymewhenusercommentsonmypost': 'Notify me when users comment on my post',
			'notifymewhenuserlikesmypost': 'Notify me when users like my post',
			'churchsocial': 'Church Social',
			'shareyourthoughts': 'Share your thoughts',
			'readmore': '...Read more',
			'less': ' Less',
			'couldnotprocess': 'Could not process requested action.',
			'pleaseselectprofilephoto': 'Please select a profile photo to upload',
			'pleaseselectprofilecover': 'Please select a cover photo to upload',
			'updateprofileerrorhint': 'You need to fill your name, date of birth, gender, phone before you can proceed.',
			'fullname': 'Full Name',
			'firstname': 'First Name',
			'lastname': 'Last Name',
			'occupation': 'Occupation',
			'gender': 'Gender',
			'male': 'Male',
			'female': 'Female',
			'dob': 'Date Of Birth',
			'address': 'Current Address',
			'aboutme': 'About Me',
			'facebookprofilelink': 'Facebook Profile Link',
			'twitterprofilelink': 'Twitter Profile Link',
			'linkdln': 'Linkedln Profile Link',
			'likes': 'Likes',
			'likess': 'Like(s)',
			'pinnedposts': 'My Pinned Posts',
			'unpinpost': 'Unpin Post',
			'unpinposthint': 'Do you wish to remove this post from your pinned posts?',
			'postdetails': 'Post Details',
			'posts': 'Posts',
			'followers': 'Followers',
			'followings': 'Followings',
			'my': 'My',
			'edit': 'Edit',
			'delete': 'Delete',
			'deletepost': 'Delete Post',
			'deleteposthint': 'Do you wish to delete this post? Posts can still appear on some users feeds.',
			'maximumallowedsizehint': 'Maximum allowed file upload reached',
			'maximumuploadsizehint': 'The selected file exceeds the allowed upload file size limit.',
			'makeposterror': 'Unable to make post at the moment, please click to retry.',
			'makepost': 'Make Post',
			'selectfile': 'Select File',
			'images': 'Images',
			'shareYourThoughtsNow': 'Share your thoughts ...',
			'photoviewer': 'Photo Viewer',
			'nochatsavailable': 'No Conversations available \n Click the add icon below \nto select users to chat with',
			'typing': 'Typing...',
			'photo': 'Photo',
			'online': 'Online',
			'offline': 'Offline',
			'lastseen': 'Last Seen',
			'deleteselectedhint': 'This action will delete the selected messages.  Please note that this only deletes your side of the conversation, \n the messages will still show on your partners device.',
			'deleteselected': 'Delete selected',
			'unabletofetchconversation': 'Unable to Fetch \nyour conversation with \n',
			'loadmoreconversation': 'Load more conversations',
			'sendyourfirstmessage': 'Send your first message to \n',
			'unblock': 'Unblock ',
			'block': 'Block',
			'writeyourmessage': 'Write your message...',
			'clearconversation': 'Clear Conversation',
			'clearconversationhintone': 'This action will clear all your conversation with ',
			'clearconversationhinttwo': '.\n  Please note that this only deletes your side of the conversation, the messages will still show on your partners chat.',
			'logoutfromapphint': 'You wont be able to access some priviledges if you are not logged in.',
			'deleteaccount': 'Delete my account',
			'deleteaccounthint': 'This action will delete your account and remove all your data, once your data is deleted, it cannot be recovered.',
			'deleteaccountsuccess': 'Account deletion was succesful',
			'myprofile': 'My Profile',
			'noitemstodisplay': 'No Items To Display',
			'copiedtoclipboard': 'Copied to clipboard',
			'biblebooks': 'Bible',
			'searchhint': 'Search Audio & Video Messages',
			'performingsearch': 'Searching Audios and Videos',
			'nosearchresult': 'No results Found',
			'nosearchresulthint': 'Try input more general keyword',
			'dataloaderror': 'Could not load requested data at the moment, check your data connection and click to retry.',
			'download': 'Download',
			'addplaylist': 'Add to playlist',
			'bookmark': 'Bookmark',
			'unbookmark': 'UnBookmark',
			'share': 'Share',
			'deletemedia': 'Delete File',
			'deletemediahint': 'Do you wish to delete this downloaded file? This action cannot be undone.',
			'comments': 'Comments',
			'replies': 'Replies',
			'reply': 'Reply',
			'logintoaddcomment': 'Login to add a comment',
			'logintoreply': 'Login to reply',
			'writeamessage': 'Write a message...',
			'nocomments': 'No Comments found \nclick to retry',
			'errormakingcomments': 'Cannot process commenting at the moment..',
			'errordeletingcomments': 'Cannot delete this comment at the moment..',
			'erroreditingcomments': 'Cannot edit this comment at the moment..',
			'errorloadingmorecomments': 'Cannot load more comments at the moment..',
			'deletingcomment': 'Deleting comment',
			'editingcomment': 'Editing comment',
			'deletecommentalert': 'Delete Comment',
			'editcommentalert': 'Edit Comment',
			'deletecommentalerttext': 'Do you wish to delete this comment? This action cannot be undone',
			'loadmore': 'load more',
			'errorReportingComment': 'Error Reporting Comment',
			'reportingComment': 'Reporting Comment',
			'reportcomment': 'Report Options',
			'reportCommentsList.0': 'Unwanted commercial content or spam',
			'reportCommentsList.1': 'Pornography or sexual explicit material',
			'reportCommentsList.2': 'Hate speech or graphic violence',
			'reportCommentsList.3': 'Harassment or bullying',
			'addtoplaylist': 'Add to playlist',
			'newplaylist': 'New playlist',
			'playlistitm': 'Playlist',
			'mediaaddedtoplaylist': 'Media added to playlist.',
			'mediaremovedfromplaylist': 'Media removed from playlist',
			'clearplaylistmedias': 'Clear All Media',
			'deletePlayList': 'Delete Playlist',
			'clearplaylistmediashint': 'Go ahead and remove all media from this playlist?',
			'deletePlayListhint': 'Go ahead and delete this playlist and clear all media?',
			'pulluploadmore': 'pull up load',
			'loadfailedretry': 'Load Failed!Click retry!',
			'releaseloadmore': 'release to load more',
			'nomoredata': 'No more Data',
			'events': 'Events',
			'myplaylists': 'My Playlists',
			'articles': 'Articles',
			'notes': 'Notes',
			'savenotetitle': 'Note Title',
			'nonotesfound': 'No notes found',
			'newnote': 'New',
			'deletenote': 'Delete Note',
			'deletenotehint': 'Do you want to delete this note? This action cannot be reversed.',
			'allitems': 'All Items',
			'emptyplaylist': 'No Playlists',
			'notsupported': 'Not Supported',
			'cleanupresources': 'Cleaning up resources',
			'grantstoragepermission': 'Please grant accessing storage permission to continue',
			'sharefiletitle': 'Watch or Listen to ',
			'sharefilebody': 'Via MyChurch App, Download now at ',
			'sharetext': 'Enjoy unlimited Audio & Video streaming',
			'sharetexthint': 'Join the Video and Audio streaming platform that lets you watch and listen to millions of files from around the world. Download now at',
			'branches': 'Branches',
			'inbox': 'Inbox',
			'viewinmap': 'View Location in Map',
			'member': 'Member(s)',
			'join': 'Join Group',
			'by': 'BY',
			'prayertitle': 'Prayer Title',
			'prayercontent': 'Prayer Content',
			'testimonytitle': 'Testimony Title',
			'testimonycontent': 'Testimony Content',
			'successprayerposting': 'You have successfully added a prayer request, it will be published once it is approved.',
			'successtestimonyposting': 'You have successfully added a new testimony, it will be published once it is approved.',
			'addtestimony': 'Add Testimony',
			'groupsibelongto': 'Groups i belong to',
			'groupevents': 'Group Events/Activities',
			'successjoinedgroup': 'You have successfully requested to join this group, You will be notified by email once this request is granted.',
			'createnote': 'Create Note',
			'tapaddcontent': 'Tap to add content',
			'done': 'Done',
			'youversionbible': 'Use Youversion Bible Reader',
			'readbiblein': 'Read Bible in',
			'nodevotionals': 'No devotionals for selected month',
			'noevents': 'No events for selected month',
			'devotionalshint': 'Daily readings for devoted living.',
			'recentmessages': 'Recent Messages',
			'eventshint': 'Events & announcements',
			'digdeepbible': 'Dig deep into the word of God.',
			'upcomingevents': 'Our Upcoming Events',
			'searchmessagesbooks': 'Search for audio & video messages',
			'exploredeep': 'Explore Deeper',
			'missionstatement': 'Great to have you here, at Mychurch App, we strive for mastery at Gods word and preaching the gospel. ',
			'next': 'Next',
			'onboardingpagetitles.0': 'Welcome to MFM Lekki App',
			'onboardingpagetitles.1': 'Benefits of the App',
			'onboardingpagetitles.2': 'Audio, Video \n and Live Streaming',
			'onboardingpagetitles.3': 'Create Account',
			'onboardingpagehints.0': 'A vibrant worship centre committed to prayer, deliverance, holiness, and raising champions for Christ.',
			'onboardingpagehints.1': 'Stay connected with church updates, programmes, and spiritual resources designed to strengthen your walk with God.',
			'onboardingpagehints.2': 'Access messages, prayer sessions, and live services anytime from anywhere.',
			'onboardingpagehints.3': 'Start your journey to a never-ending worship experience.',
			'youneedtologintoreply': 'You need to login to add a reply',
			'youneedtologintoreportpost': 'You need to login to report a post',
			'members': 'Members',
			'logintolikeapost': 'You need to login to like a member post',
			'logintopinapost': 'You need to login to pin a member post',
			'logintoreportapost': 'You need to login to report post',
			'bookmarkshint': 'Bookmark audio and video messages',
			'downloadershint': 'Download and watch offline messages',
			'playlistshint': 'Collection of audio and video messages',
		};
	}
}

extension on _StringsEs {
	Map<String, dynamic> _buildFlatMap() {
		return <String, dynamic>{
			'appname': 'MFM Lekki App',
			'churchmotto': 'Hacia el evangelismo global',
			'initializingapp': 'Por favor, espere mientras configuramos algunas cosas, no tomará mucho tiempo, lo prometemos.',
			'errorinitapp': 'Desafortunadamente, no pudimos completar la configuración en este momento, por favor revise su conexión a internet y luego haga clic para intentarlo de nuevo.',
			'initappsucess': 'Felicitaciones, la configuración ahora está completa, ahora puede hacer clic para continuar con la aplicación.',
			'retry': 'Intentar de nuevo',
			'continuetoapp': 'Continuar con la aplicación',
			'home': 'Inicio',
			'media': 'Medios',
			'publications': 'Publicaciones',
			'connect': 'Conectar',
			'recentsermons': 'Sermónes Recientes',
			'donate': 'Dar Ahora',
			'donatehint': 'Dios ama al dador alegre.',
			'bible': 'Biblia',
			'hymns': 'Himnos',
			'devotionals': 'Devocionales',
			'stayconnected': 'Más formas de estar conectado',
			'radiostreams': 'Transmisiones de Radio',
			'radiohint': 'Escuche nuestras transmisiones diarias de radio.',
			'livestreams': 'Transmisiones en Vivo',
			'livestreamshint': 'Conéctese para ver nuestras transmisiones en vivo.',
			'video': 'Videos',
			'videos': 'Mensajes de Video',
			'videoshint': 'Colección de sermones en video.',
			'audios': 'Mensajes de Audio',
			'audioshint': 'Colección de sermones en audio',
			'photos': 'Galería de Fotos',
			'photoshint': 'Navegue por nuestras colecciones de fotos de la iglesia.',
			'bookmarks': 'Marcadores',
			'playlists': 'Listas de Reproducción',
			'downloads': 'Descargas',
			'books': 'Libros Cristianos',
			'recentarticles': 'Artículos Recientes',
			'groups': 'Grupos de Vida',
			'groupshint': 'Los grupos de vida son el mejor lugar para conectarse y confraternizar con otros creyentes.',
			'Prayerrequests': 'Peticiones de Oración',
			'prayerhint': 'Envíe una petición de oración o únase a nosotros para orar por otros miembros.',
			'testimonies': 'Testimonios',
			'testimonyhint': 'Colección de testimonios personales del poder sanador y liberador de Dios.',
			'churchlocation': 'Ubicaciones de la Iglesia',
			'churchlocationhint': 'Encuentre una ubicación cerca de usted y haga planes para unirse a nosotros este domingo.',
			'facebookpage': 'Página de Facebook',
			'facebookpagehint': 'Conéctese con nosotros en nuestra comunidad de Facebook.',
			'youtubepage': 'Página de Youtube',
			'youtubepagehint': 'Suscríbase a nuestro canal de Youtube.',
			'twitterpage': 'Página de Twitter',
			'twitterpagehint': 'Únase a la conversación en la plataforma de Twitter.',
			'instagrampage': 'Página de Instagram',
			'instagrampagehint': 'Síganos en Instagram para ver las últimas historias.',
			'gosocial': 'Ir Social',
			'gosocialehint': 'Comparta sus pensamientos y charle con otros miembros.',
			'website': 'Nuestro Sitio Web',
			'terms': 'Términos y Condiciones',
			'privacy': 'Política de Privacidad',
			'about': 'Sobre Nosotros',
			'rateapp': 'Calificar App',
			'account': 'Cuenta',
			'appsettings': 'Configuración de la App',
			'guestuser': 'Usuario Invitado',
			'createanaccounthint': 'Crea una cuenta o inicia sesión en la aplicación',
			'viewmyprofile': 'Ver mi perfil',
			'logoutfromapp': 'Cerrar Sesión de la App',
			'deletemyaccount': 'Eliminar mi cuenta',
			'applanguage': 'Idioma de la App',
			'recieveinbox': 'Recibir notificaciones de bandeja de entrada',
			'recieveevents': 'Eventos',
			'sermonnotification': 'Sermónes',
			'articlenotification': 'Artículos',
			'devotionalnotification': 'Devocionales',
			'chooseapplanguage': 'Seleccionar Idioma de la App',
			'emailaddress': 'Dirección de Correo Electrónico',
			'password': 'Contraseña',
			'confirmpassword': 'Confirmar Contraseña',
			'passwordsdontmatch': '¡Las contraseñas no coinciden!',
			'login': 'INICIAR SESIÓN',
			'createaccount': 'Crear Cuenta',
			'forgotpassword': '¿Olvidó su Contraseña?',
			'resetpassword': 'Restablecer Contraseña',
			'resetpasswordhint': 'Se enviará un enlace para restablecer la contraseña a su correo electrónico.',
			'resetpasswordsuccess': 'Si el correo electrónico existe en nuestra plataforma, debería recibir instrucciones sobre cómo restablecer su contraseña.',
			'goback': 'Volver',
			'ok': 'OK',
			'cancel': 'CANCELAR',
			'resendverifycode': 'Reenviar Enlace de Verificación',
			'successregistermessage': 'Ha creado una cuenta correctamente, por favor revise su correo electrónico para un enlace de verificación y verifique su dirección de correo electrónico.',
			'successresendverifymessage': 'Se ha enviado un enlace de verificación a su correo electrónico.',
			'resendverifylink': 'Se envió un enlace de verificación a su dirección de correo electrónico, visite el enlace para verificar su correo electrónico. ¿No recibió el correo electrónico? haga clic en el enlace a continuación para reenviar el enlace de verificación.',
			'processingpleasewait': 'Procesando, por favor espere...',
			'cannotprocess': 'La operación solicitada no puede procesarse en este momento, por favor inténtelo de nuevo más tarde.',
			'oops': '¡Ups!',
			'save': 'Guardar',
			'error': 'Error',
			'success': 'Éxito',
			'skip': 'Omitir',
			'downloadbible': 'Descargar Biblia',
			'downloadversion': 'Descargar',
			'downloading': 'Descargando',
			'failedtodownload': 'Error al descargar',
			'pleaseclicktoretry': 'Por favor, haga clic para intentarlo de nuevo.',
			'of': 'De',
			'nobibleversionshint': 'No hay datos de la biblia para mostrar, haga clic en el botón a continuación para descargar al menos una versión de la biblia.',
			'downloaded': 'Descargado',
			'enteremailaddresstoresetpassword': 'Ingrese su correo electrónico para restablecer su contraseña',
			'backtologin': 'REGRESAR AL INICIO DE SESIÓN',
			'signintocontinue': 'Inicie sesión para continuar',
			'signin': 'I N I C I A R S E S I Ó N',
			'signinforanaccount': '¿REGISTRARSE PARA UNA CUENTA?',
			'alreadyhaveanaccount': '¿Ya tienes una cuenta?',
			'updateprofile': 'Actualizar Perfil',
			'updateprofilehint': 'Para comenzar, actualice su página de perfil, esto nos ayudará a conectarnos con otras personas',
			'searchbible': 'Buscar Biblia',
			'filtersearchoptions': 'Opciones de Filtro de Búsqueda',
			'narrowdownsearch': 'Use el botón de filtro a continuación para reducir la búsqueda para obtener un resultado más preciso.',
			'searchbibleversion': 'Buscar Versión de la Biblia',
			'searchbiblebook': 'Buscar Libro de la Biblia',
			'search': 'Buscar',
			'setBibleBook': 'Establecer Libro de la Biblia',
			'oldtestament': 'Antiguo Testamento',
			'newtestament': 'Nuevo Testamento',
			'limitresults': 'Limitar Resultados',
			'setfilters': 'Establecer Filtros',
			'bibletranslator': 'Traductor de la Biblia',
			'chapter': ' Capítulo ',
			'verse': ' Versículo ',
			'translate': 'traducir',
			'bibledownloadinfo': 'La descarga de la Biblia ha comenzado, por favor no cierre esta página hasta que la descarga haya terminado.',
			'received': 'recibido',
			'outoftotal': 'de un total de',
			'set': 'ESTABLECER',
			'selectColor': 'Seleccionar Color',
			'switchbibleversion': 'Cambiar Versión de la Biblia',
			'switchbiblebook': 'Cambiar Libro de la Biblia',
			'gotosearch': 'Ir al Capítulo',
			'changefontsize': 'Cambiar Tamaño de Fuente',
			'font': 'Fuente',
			'readchapter': 'Leer Capítulo',
			'showhighlightedverse': 'Mostrar Versículos Resaltados',
			'downloadmoreversions': 'Descargar más versiones',
			'suggestedusers': 'Usuarios Sugeridos para Seguir',
			'unfollow': 'Dejar de Seguir',
			'follow': 'Seguir',
			'searchforpeople': 'Buscar personas',
			'viewpost': 'Ver Publicación',
			'viewprofile': 'Ver Perfil',
			'mypins': 'Mis Pins',
			'viewpinnedposts': 'Ver Posts Anclados',
			'personal': 'Personal',
			'update': 'Actualizar',
			'phonenumber': 'Número de Teléfono',
			'showmyphonenumber': 'Mostrar mi número de teléfono a los usuarios',
			'dateofbirth': 'Fecha de Nacimiento',
			'showmyfulldateofbirth': 'Mostrar mi fecha de nacimiento completa a las personas que ven mi estado',
			'notifications': 'Notificaciones',
			'notifywhenuserfollowsme': 'Notificarme cuando un usuario me sigue',
			'notifymewhenusercommentsonmypost': 'Notificarme cuando los usuarios comenten en mi publicación',
			'notifymewhenuserlikesmypost': 'Notificarme cuando los usuarios den me gusta a mi publicación',
			'churchsocial': 'Social de la Iglesia',
			'shareyourthoughts': 'Comparte tus pensamientos',
			'readmore': '... Leer más',
			'less': 'Menos',
			'couldnotprocess': 'No se pudo procesar la acción solicitada.',
			'pleaseselectprofilephoto': 'Por favor seleccione una foto de perfil para subir',
			'pleaseselectprofilecover': 'Por favor seleccione una foto de portada para subir',
			'updateprofileerrorhint': 'Debe completar su nombre, fecha de nacimiento, género, y teléfono antes de continuar.',
			'fullname': 'Nombre Completo',
			'firstname': 'Nombre',
			'lastname': 'Apellido',
			'occupation': 'Ocupación',
			'gender': 'Género',
			'male': 'Masculino',
			'female': 'Femenino',
			'dob': 'Fecha de Nacimiento',
			'address': 'Dirección Actual',
			'aboutme': 'Acerca de Mí',
			'facebookprofilelink': 'Enlace de Perfil de Facebook',
			'twitterprofilelink': 'Enlace de Perfil de Twitter',
			'linkdln': 'Enlace de Perfil de LinkedIn',
			'likes': 'Gustos',
			'likess': 'Gusto(s)',
			'pinnedposts': 'Mis Posts Anclados',
			'unpinpost': 'Desanclar Post',
			'unpinposthint': '¿Desea eliminar este post de sus posts anclados?',
			'postdetails': 'Detalles del Post',
			'posts': 'Posts',
			'followers': 'Seguidores',
			'followings': 'Siguiendo',
			'my': 'Mi',
			'edit': 'Editar',
			'delete': 'Eliminar',
			'deletepost': 'Eliminar Post',
			'deleteposthint': '¿Desea eliminar este post? Los posts aún pueden aparecer en los feeds de algunos usuarios.',
			'maximumallowedsizehint': 'Tamaño máximo de carga permitido alcanzado',
			'maximumuploadsizehint': 'El archivo seleccionado supera el límite de tamaño de carga permitido.',
			'makeposterror': 'No se puede realizar el post en este momento, por favor haga clic para intentarlo de nuevo.',
			'makepost': 'Crear Post',
			'selectfile': 'Seleccionar Archivo',
			'images': 'Imágenes',
			'shareYourThoughtsNow': 'Comparte tus pensamientos ...',
			'photoviewer': 'Visor de Fotos',
			'nochatsavailable': 'No hay Conversaciones disponibles \n Haga clic en el ícono de agregar abajo \n para seleccionar usuarios con los que chatear',
			'typing': 'Escribiendo...',
			'photo': 'Foto',
			'online': 'En línea',
			'offline': 'Desconectado',
			'lastseen': 'Última Conexión',
			'deleteselectedhint': 'Esta acción eliminará los mensajes seleccionados. Tenga en cuenta que esto solo elimina su lado de la conversación, \n los mensajes seguirán mostrándose en el dispositivo de su pareja.',
			'deleteselected': 'Eliminar seleccionado',
			'unabletofetchconversation': 'No se pudo obtener su conversación con \n',
			'loadmoreconversation': 'Cargar más conversaciones',
			'sendyourfirstmessage': 'Envíe su primer mensaje a \n',
			'unblock': 'Desbloquear ',
			'block': 'Bloquear',
			'writeyourmessage': 'Escribe tu mensaje...',
			'clearconversation': 'Limpiar Conversación',
			'clearconversationhintone': 'Esta acción limpiará toda su conversación con ',
			'clearconversationhinttwo': '.\n Tenga en cuenta que esto solo elimina su lado de la conversación, los mensajes seguirán mostrándose en el chat de su pareja.',
			'logoutfromapphint': 'No podrá acceder a algunos privilegios si no ha iniciado sesión.',
			'deleteaccount': 'Eliminar mi cuenta',
			'deleteaccounthint': 'Esta acción eliminará su cuenta y eliminará todos sus datos, una vez que se eliminen sus datos, no se podrán recuperar.',
			'deleteaccountsuccess': 'Eliminación de la cuenta exitosa',
			'myprofile': 'Mi Perfil',
			'noitemstodisplay': 'No hay elementos para mostrar',
			'copiedtoclipboard': 'Copiado al portapapeles',
			'biblebooks': 'Biblia',
			'searchhint': 'Buscar Mensajes de Audio y Video',
			'performingsearch': 'Buscando Audios y Videos',
			'nosearchresult': 'No se encontraron resultados',
			'nosearchresulthint': 'Intente ingresar palabras clave más generales',
			'dataloaderror': 'No se pudieron cargar los datos solicitados en este momento, verifique su conexión de datos y haga clic para intentarlo de nuevo.',
			'download': 'Descargar',
			'addplaylist': 'Agregar a lista de reproducción',
			'bookmark': 'Agregar a favoritos',
			'unbookmark': 'Eliminar de favoritos',
			'share': 'Compartir',
			'deletemedia': 'Eliminar Archivo',
			'deletemediahint': '¿Desea eliminar este archivo descargado? Esta acción no se puede deshacer.',
			'comments': 'Comentarios',
			'replies': 'Respuestas',
			'reply': 'Responder',
			'logintoaddcomment': 'Inicie sesión para agregar un comentario',
			'logintoreply': 'Inicie sesión para responder',
			'writeamessage': 'Escribe un mensaje...',
			'nocomments': 'No se encontraron comentarios \nhaga clic para intentarlo de nuevo',
			'errormakingcomments': 'No se puede procesar el comentario en este momento..',
			'errordeletingcomments': 'No se puede eliminar este comentario en este momento..',
			'erroreditingcomments': 'No se puede editar este comentario en este momento..',
			'errorloadingmorecomments': 'No se pueden cargar más comentarios en este momento..',
			'deletingcomment': 'Eliminando comentario',
			'editingcomment': 'Editando comentario',
			'deletecommentalert': 'Eliminar Comentario',
			'editcommentalert': 'Editar Comentario',
			'deletecommentalerttext': '¿Desea eliminar este comentario? Esta acción no se puede deshacer',
			'loadmore': 'cargar más',
			'errorReportingComment': 'Error al Reportar Comentario',
			'reportingComment': 'Reportando Comentario',
			'reportcomment': 'Opciones de Reporte',
			'reportCommentsList.0': 'Contenido comercial no deseado o spam',
			'reportCommentsList.1': 'Pornografía o material sexual explícito',
			'reportCommentsList.2': 'Discurso de odio o violencia gráfica',
			'reportCommentsList.3': 'Acoso o intimidación',
			'addtoplaylist': 'Agregar a lista de reproducción',
			'newplaylist': 'Nueva lista de reproducción',
			'playlistitm': 'Lista de reproducción',
			'mediaaddedtoplaylist': 'Medio agregado a lista de reproducción.',
			'mediaremovedfromplaylist': 'Medio eliminado de lista de reproducción',
			'clearplaylistmedias': 'Limpiar Todos los Medios',
			'deletePlayList': 'Eliminar Lista de Reproducción',
			'clearplaylistmediashint': '¿Desea eliminar todos los medios de esta lista de reproducción?',
			'deletePlayListhint': '¿Desea eliminar esta lista de reproducción y borrar todos los medios?',
			'pulluploadmore': 'tirar para cargar más',
			'loadfailedretry': '¡Error al cargar! ¡Haga clic en reintentar!',
			'releaseloadmore': 'suelta para cargar más',
			'nomoredata': 'No hay más Datos',
			'events': 'Eventos',
			'myplaylists': 'Mis Listas de Reproducción',
			'articles': 'Artículos',
			'notes': 'Notas',
			'savenotetitle': 'Título de la Nota',
			'nonotesfound': 'No se encontraron notas',
			'newnote': 'Nueva',
			'deletenote': 'Eliminar Nota',
			'deletenotehint': '¿Desea eliminar esta nota? Esta acción no se puede deshacer.',
			'allitems': 'Todos los Elementos',
			'emptyplaylist': 'Sin Listas de Reproducción',
			'notsupported': 'No Soportado',
			'cleanupresources': 'Limpiando recursos',
			'grantstoragepermission': 'Por favor conceda acceso a la memoria para continuar',
			'sharefiletitle': 'Ver o Escuchar ',
			'sharefilebody': 'A través de MyChurch App, Descarga ahora en ',
			'sharetext': 'Disfruta de transmisión ilimitada de Audio y Video',
			'sharetexthint': 'Únete a la plataforma de transmisión de video y audio que te permite ver y escuchar millones de archivos de todo el mundo. Descarga ahora en',
			'branches': 'Sucursales',
			'inbox': 'Bandeja de Entrada',
			'viewinmap': 'Ver Ubicación en Mapa',
			'member': 'Miembro(s)',
			'join': 'Unirse al Grupo',
			'by': 'POR',
			'prayertitle': 'Título de la Oración',
			'prayercontent': 'Contenido de la Oración',
			'testimonytitle': 'Título del Testimonio',
			'testimonycontent': 'Contenido del Testimonio',
			'successprayerposting': 'Ha añadido correctamente una solicitud de oración, se publicará una vez que sea aprobada.',
			'successtestimonyposting': 'Ha añadido correctamente un nuevo testimonio, se publicará una vez que sea aprobado.',
			'addtestimony': 'Añadir Testimonio',
			'groupsibelongto': 'Grupos a los que pertenezco',
			'groupevents': 'Eventos/Actividades del Grupo',
			'successjoinedgroup': 'Ha solicitado unirse a este grupo correctamente. Se le notificará por correo electrónico una vez que se apruebe esta solicitud.',
			'createnote': 'Crear Nota',
			'tapaddcontent': 'Toque para agregar contenido',
			'done': 'Hecho',
			'youversionbible': 'Usar Youversion Biblia',
			'readbiblein': 'Leer la Biblia en',
			'nodevotionals': 'No hay devocionales para el mes seleccionado',
			'noevents': 'No hay eventos para el mes seleccionado',
			'devotionalshint': 'Lecturas diarias para una vida devota.',
			'recentmessages': 'Mensajes Recientes',
			'eventshint': 'Eventos y anuncios',
			'digdeepbible': 'Profundiza en la palabra de Dios.',
			'upcomingevents': 'Nuestros Próximos Eventos',
			'searchmessagesbooks': 'Buscar mensajes de audio y video',
			'exploredeep': 'Explorar más Profundo',
			'missionstatement': 'Es genial tenerte aquí, en MyChurch App, nos esforzamos por dominar la palabra de Dios y predicar el evangelio.',
			'next': 'Siguiente',
			'onboardingpagetitles.0': 'Bienvenido a Church App',
			'onboardingpagetitles.1': 'Lleno de Funciones',
			'onboardingpagetitles.2': 'Audio, Video \n y Transmisión en Vivo',
			'onboardingpagetitles.3': 'Crear Cuenta',
			'onboardingpagehints.0': 'Vaya más allá de las mañanas de domingo y las cuatro paredes de su iglesia. Todo lo que necesita para comunicarse y comprometerse con un mundo enfocado en dispositivos móviles.',
			'onboardingpagehints.1': 'Hemos reunido todas las principales características que su aplicación de iglesia debe tener. Eventos, Devocionales, Notificaciones, Notas y biblia multiversión.',
			'onboardingpagehints.2': 'Permita que los usuarios de todo el mundo vean videos, escuchen mensajes de audio y vean transmisiones en vivo de los servicios de su iglesia.',
			'onboardingpagehints.3': 'Comience su viaje hacia una experiencia de adoración interminable.',
			'youneedtologintoreply': 'Debe iniciar sesión para agregar una respuesta',
			'youneedtologintoreportpost': 'Debe iniciar sesión para informar un post',
			'members': 'Miembros',
			'logintolikeapost': 'Debe iniciar sesión para dar me gusta a un post de un miembro',
			'logintopinapost': 'Debe iniciar sesión para anclar un post de un miembro',
			'logintoreportapost': 'Debe iniciar sesión para informar un post',
			'bookmarkshint': 'Marcar mensajes de audio y video',
			'downloadershint': 'Descargar y ver mensajes sin conexión',
			'playlistshint': 'Colección de mensajes de audio y video',
		};
	}
}

extension on _StringsFr {
	Map<String, dynamic> _buildFlatMap() {
		return <String, dynamic>{
			'appname': 'MFM Lekki TMPM 1',
			'churchmotto': 'Towards global envagelism',
			'initializingapp': 'Please wait while we setup a few things, it wont take long, we promise.',
			'errorinitapp': 'Unfortunately, we could not complete setup at the moment, please check your internet connection, then click to retry',
			'initappsucess': 'Congratulations, setup is now complete, you can now click to continue to app',
			'retry': 'Try Again',
			'continuetoapp': 'Continue to App',
			'home': 'Home',
			'media': 'Media',
			'publications': 'Publications',
			'connect': 'Connect',
			'recentsermons': 'Recent Sermons',
			'donate': 'Give Now',
			'donatehint': 'God loves a cheerful giver.',
			'bible': 'Bible',
			'hymns': 'Hymns',
			'devotionals': 'Devotionals',
			'stayconnected': 'More ways to connect',
			'radiostreams': 'Radio Streams',
			'radiohint': 'Listen to our daily Radio Streams.',
			'livestreams': 'Live Streams',
			'livestreamshint': 'Connect to watch our live broadcasts.',
			'videos': 'Video Messages',
			'video': 'Videos',
			'videoshint': 'Collection of video sermons.',
			'audios': 'Audio Messages',
			'audioshint': 'Collection of audio sermons',
			'photos': 'Photo Gallery',
			'photoshint': 'Browse through our church photo collections.',
			'bookmarks': 'Bookmarks',
			'playlists': 'Playlists',
			'downloads': 'Downloads',
			'books': 'Christian Books',
			'recentarticles': 'Recent Articles',
			'groups': 'Church Groups',
			'groupshint': 'Church Groups are the best place to connect and fellowship with other believers.',
			'Prayerrequests': 'Prayer Requests',
			'prayerhint': 'Send a prayer request or join us to pray for other members.',
			'testimonies': 'Testimonies',
			'testimonyhint': 'Collection of personal testimonies of Gods healing power and deliverance.',
			'churchlocation': 'Church Locations',
			'churchlocationhint': 'Find a location near you and make plans to join us this Sunday!',
			'facebookpage': 'Facebook Page',
			'facebookpagehint': 'Connect with us on our Facebook community.',
			'youtubepage': 'Youtube Page',
			'youtubepagehint': 'Subscribe to our Youtube channel.',
			'twitterpage': 'Twitter Page',
			'twitterpagehint': 'Join the conversation on the Twitter platform.',
			'instagrampage': 'Instagram Page',
			'instagrampagehint': 'Follow us on Instagram to see the latest stories.',
			'gosocial': 'Go Social',
			'gosocialehint': 'Share your thought &\n chat with other members.',
			'website': ' Our Website',
			'terms': 'Terms & Conditions',
			'privacy': 'Privacy Policy',
			'about': 'About Us',
			'rateapp': 'Rate App',
			'account': 'Account',
			'appsettings': 'App Settings Fr',
			'guestuser': 'Guest User',
			'createanaccounthint': 'Create an account or login to app',
			'viewmyprofile': 'View my profile',
			'logoutfromapp': 'Logout from App',
			'deletemyaccount': 'Delete my account',
			'applanguage': 'App Language',
			'recieveinbox': 'Receive inbox notifications',
			'recieveevents': 'Events',
			'sermonnotification': 'Sermons',
			'articlenotification': 'Articles',
			'devotionalnotification': 'Devotionals',
			'chooseapplanguage': 'Select App Language',
			'emailaddress': 'Email Address',
			'password': 'Password',
			'confirmpassword': 'Confirm Password',
			'passwordsdontmatch': 'Passwords dont match!',
			'login': 'LOG IN',
			'createaccount': 'Create Account',
			'forgotpassword': 'Forgot Password?',
			'resetpassword': 'Reset Password',
			'resetpasswordhint': 'A reset password link will be sent to your email.',
			'resetpasswordsuccess': 'If the email exists in our platform, you should recieve an instruction on how to reset your password.',
			'goback': 'Go Back',
			'ok': 'OK',
			'cancel': 'CANCEL',
			'resendverifycode': 'Resend Verification Link',
			'successregistermessage': 'You have successfully created an account, please check your email for a verification link and verify your email address.',
			'successresendverifymessage': 'A verification link have been sent to your email.',
			'processingpleasewait': 'Processing, please wait...',
			'cannotprocess': 'The requested operation cannot be processed at the moment, please try again later.',
			'resendverifylink': 'A verification link was sent to your email address, visit the link to verify your email. Did not get the email? click the link below to resend verification link.',
			'oops': 'Ooops!',
			'save': 'Save',
			'error': 'Error',
			'success': 'Success',
			'skip': 'Skip',
			'downloadbible': 'Download Bible',
			'downloadversion': 'Download',
			'downloading': 'Downloading',
			'failedtodownload': 'Failed to download',
			'pleaseclicktoretry': 'Please click to retry.',
			'of': 'Of',
			'nobibleversionshint': 'There is no bible data to display, click on the button below to download atleast one bible version.',
			'downloaded': 'Downloaded',
			'enteremailaddresstoresetpassword': 'Enter your email to reset your password',
			'backtologin': 'BACK TO LOGIN',
			'signintocontinue': 'Sign in to continue',
			'signin': 'S I G N  I N',
			'signinforanaccount': 'SIGN UP FOR AN ACCOUNT?',
			'alreadyhaveanaccount': 'Already have an account?',
			'updateprofile': 'Update Profile',
			'updateprofilehint': 'To get started, please update your profile page, this will help us in connecting you with other people',
			'searchbible': 'Search Bible',
			'filtersearchoptions': 'Filter Search Options',
			'narrowdownsearch': 'Use the filter button below to narrow down search for a more precise result.',
			'searchbibleversion': 'Search Bible Version',
			'searchbiblebook': 'Search Bible Book',
			'search': 'Search',
			'setBibleBook': 'Set Bible Book',
			'oldtestament': 'Old Testament',
			'newtestament': 'New Testament',
			'limitresults': 'Limit Results',
			'setfilters': 'Set Filters',
			'bibletranslator': 'Bible Translator',
			'chapter': ' Chapter ',
			'verse': ' Verse ',
			'translate': 'translate',
			'bibledownloadinfo': 'Bible Download started, Please do not close this page until the download is done.',
			'received': 'received',
			'outoftotal': 'out of total',
			'set': 'SET',
			'selectColor': 'Select Color',
			'switchbibleversion': 'Switch Bible Version',
			'switchbiblebook': 'Switch Bible Book',
			'gotosearch': 'Go to Chapter',
			'changefontsize': 'Change Font Size',
			'font': 'Font',
			'readchapter': 'Read Chapter',
			'showhighlightedverse': 'Show Highlighted Verses',
			'downloadmoreversions': 'Download more versions',
			'suggestedusers': 'Suggested users to follow',
			'unfollow': 'UnFollow',
			'follow': 'Follow',
			'searchforpeople': 'Search for people',
			'viewpost': 'View Post',
			'viewprofile': 'View Profile',
			'mypins': 'My Pins',
			'viewpinnedposts': 'View Pinned Posts',
			'personal': 'Personal',
			'update': 'Update',
			'phonenumber': 'Phone Number',
			'showmyphonenumber': 'Show my phone number to users',
			'dateofbirth': 'Date of Birth',
			'showmyfulldateofbirth': 'Show my full date of birth to people viewing my status',
			'notifications': 'Notifications',
			'notifywhenuserfollowsme': 'Notify me when a user follows me',
			'notifymewhenusercommentsonmypost': 'Notify me when users comment on my post',
			'notifymewhenuserlikesmypost': 'Notify me when users like my post',
			'churchsocial': 'Church Social',
			'shareyourthoughts': 'Share your thoughts',
			'readmore': '...Read more',
			'less': ' Less',
			'couldnotprocess': 'Could not process requested action.',
			'pleaseselectprofilephoto': 'Please select a profile photo to upload',
			'pleaseselectprofilecover': 'Please select a cover photo to upload',
			'updateprofileerrorhint': 'You need to fill your name, date of birth, gender, phone before you can proceed.',
			'fullname': 'Full Name',
			'firstname': 'First Name',
			'lastname': 'Last Name',
			'occupation': 'Occupation',
			'gender': 'Gender',
			'male': 'Male',
			'female': 'Female',
			'dob': 'Date Of Birth',
			'address': 'Current Address',
			'aboutme': 'About Me',
			'facebookprofilelink': 'Facebook Profile Link',
			'twitterprofilelink': 'Twitter Profile Link',
			'linkdln': 'Linkedln Profile Link',
			'likes': 'Likes',
			'likess': 'Like(s)',
			'pinnedposts': 'My Pinned Posts',
			'unpinpost': 'Unpin Post',
			'unpinposthint': 'Do you wish to remove this post from your pinned posts?',
			'postdetails': 'Post Details',
			'posts': 'Posts',
			'followers': 'Followers',
			'followings': 'Followings',
			'my': 'My',
			'edit': 'Edit',
			'delete': 'Delete',
			'deletepost': 'Delete Post',
			'deleteposthint': 'Do you wish to delete this post? Posts can still appear on some users feeds.',
			'maximumallowedsizehint': 'Maximum allowed file upload reached',
			'maximumuploadsizehint': 'The selected file exceeds the allowed upload file size limit.',
			'makeposterror': 'Unable to make post at the moment, please click to retry.',
			'makepost': 'Make Post',
			'selectfile': 'Select File',
			'images': 'Images',
			'shareYourThoughtsNow': 'Share your thoughts ...',
			'photoviewer': 'Photo Viewer',
			'nochatsavailable': 'No Conversations available \n Click the add icon below \nto select users to chat with',
			'typing': 'Typing...',
			'photo': 'Photo',
			'online': 'Online',
			'offline': 'Offline',
			'lastseen': 'Last Seen',
			'deleteselectedhint': 'This action will delete the selected messages.  Please note that this only deletes your side of the conversation, \n the messages will still show on your partners device.',
			'deleteselected': 'Delete selected',
			'unabletofetchconversation': 'Unable to Fetch \nyour conversation with \n',
			'loadmoreconversation': 'Load more conversations',
			'sendyourfirstmessage': 'Send your first message to \n',
			'unblock': 'Unblock ',
			'block': 'Block',
			'writeyourmessage': 'Write your message...',
			'clearconversation': 'Clear Conversation',
			'clearconversationhintone': 'This action will clear all your conversation with ',
			'clearconversationhinttwo': '.\n  Please note that this only deletes your side of the conversation, the messages will still show on your partners chat.',
			'logoutfromapphint': 'You wont be able to access some priviledges if you are not logged in.',
			'deleteaccount': 'Delete my account',
			'deleteaccounthint': 'This action will delete your account and remove all your data, once your data is deleted, it cannot be recovered.',
			'deleteaccountsuccess': 'Account deletion was succesful',
			'myprofile': 'My Profile',
			'noitemstodisplay': 'No Items To Display',
			'copiedtoclipboard': 'Copied to clipboard',
			'biblebooks': 'Bible',
			'searchhint': 'Search Audio & Video Messages',
			'performingsearch': 'Searching Audios and Videos',
			'nosearchresult': 'No results Found',
			'nosearchresulthint': 'Try input more general keyword',
			'dataloaderror': 'Could not load requested data at the moment, check your data connection and click to retry.',
			'download': 'Download',
			'addplaylist': 'Add to playlist',
			'bookmark': 'Bookmark',
			'unbookmark': 'UnBookmark',
			'share': 'Share',
			'deletemedia': 'Delete File',
			'deletemediahint': 'Do you wish to delete this downloaded file? This action cannot be undone.',
			'comments': 'Comments',
			'replies': 'Replies',
			'reply': 'Reply',
			'logintoaddcomment': 'Login to add a comment',
			'logintoreply': 'Login to reply',
			'writeamessage': 'Write a message...',
			'nocomments': 'No Comments found \nclick to retry',
			'errormakingcomments': 'Cannot process commenting at the moment..',
			'errordeletingcomments': 'Cannot delete this comment at the moment..',
			'erroreditingcomments': 'Cannot edit this comment at the moment..',
			'errorloadingmorecomments': 'Cannot load more comments at the moment..',
			'deletingcomment': 'Deleting comment',
			'editingcomment': 'Editing comment',
			'deletecommentalert': 'Delete Comment',
			'editcommentalert': 'Edit Comment',
			'deletecommentalerttext': 'Do you wish to delete this comment? This action cannot be undone',
			'loadmore': 'load more',
			'errorReportingComment': 'Error Reporting Comment',
			'reportingComment': 'Reporting Comment',
			'reportcomment': 'Report Options',
			'reportCommentsList.0': 'Unwanted commercial content or spam',
			'reportCommentsList.1': 'Pornography or sexual explicit material',
			'reportCommentsList.2': 'Hate speech or graphic violence',
			'reportCommentsList.3': 'Harassment or bullying',
			'addtoplaylist': 'Add to playlist',
			'newplaylist': 'New playlist',
			'playlistitm': 'Playlist',
			'mediaaddedtoplaylist': 'Media added to playlist.',
			'mediaremovedfromplaylist': 'Media removed from playlist',
			'clearplaylistmedias': 'Clear All Media',
			'deletePlayList': 'Delete Playlist',
			'clearplaylistmediashint': 'Go ahead and remove all media from this playlist?',
			'deletePlayListhint': 'Go ahead and delete this playlist and clear all media?',
			'pulluploadmore': 'pull up load',
			'loadfailedretry': 'Load Failed!Click retry!',
			'releaseloadmore': 'release to load more',
			'nomoredata': 'No more Data',
			'events': 'Events',
			'myplaylists': 'My Playlists',
			'articles': 'Articles',
			'notes': 'Notes',
			'savenotetitle': 'Note Title',
			'nonotesfound': 'No notes found',
			'newnote': 'New',
			'deletenote': 'Delete Note',
			'deletenotehint': 'Do you want to delete this note? This action cannot be reversed.',
			'allitems': 'All Items',
			'emptyplaylist': 'No Playlists',
			'notsupported': 'Not Supported',
			'cleanupresources': 'Cleaning up resources',
			'grantstoragepermission': 'Please grant accessing storage permission to continue',
			'sharefiletitle': 'Watch or Listen to ',
			'sharefilebody': 'Via MyChurch App, Download now at ',
			'sharetext': 'Enjoy unlimited Audio & Video streaming',
			'sharetexthint': 'Join the Video and Audio streaming platform that lets you watch and listen to millions of files from around the world. Download now at',
			'branches': 'Branches',
			'inbox': 'Inbox',
			'viewinmap': 'View Location in Map',
			'member': 'Member(s)',
			'join': 'Join Group',
			'by': 'BY',
			'prayertitle': 'Prayer Title',
			'prayercontent': 'Prayer Content',
			'testimonytitle': 'Testimony Title',
			'testimonycontent': 'Testimony Content',
			'successprayerposting': 'You have successfully added a prayer request, it will be published once it is approved.',
			'successtestimonyposting': 'You have successfully added a new testimony, it will be published once it is approved.',
			'addtestimony': 'Add Testimony',
			'groupsibelongto': 'Groups i belong to',
			'groupevents': 'Group Events/Activities',
			'successjoinedgroup': 'You have successfully requested to join this group, You will be notified by email once this request is granted.',
			'createnote': 'Create Note',
			'tapaddcontent': 'Tap to add content',
			'done': 'Done',
			'youversionbible': 'Use Youversion Bible Reader',
			'readbiblein': 'Read Bible in',
			'nodevotionals': 'No devotionals for selected month',
			'noevents': 'No events for selected month',
			'devotionalshint': 'Daily readings for devoted living.',
			'recentmessages': 'Recent Messages',
			'eventshint': 'Events & announcements',
			'digdeepbible': 'Dig deep into the word of God.',
			'upcomingevents': 'Our Upcoming Events',
			'searchmessagesbooks': 'Search for audio & video messages',
			'exploredeep': 'Explore Deeper',
			'missionstatement': 'Great to have you here, at Mychurch App, we strive for mastery at Gods word and preaching the gospel. ',
			'next': 'Next',
			'onboardingpagetitles.0': 'Welcome to MFM Lekki TMPM 1 App',
			'onboardingpagetitles.1': 'Benefits of the App',
			'onboardingpagetitles.2': 'Audio, Video \n and Live Streaming',
			'onboardingpagetitles.3': 'Create Account',
			'onboardingpagehints.0': 'A vibrant worship centre committed to prayer, deliverance, holiness, and raising champions for Christ.',
			'onboardingpagehints.1': 'Stay connected with church updates, programmes, and spiritual resources designed to strengthen your walk with God.',
			'onboardingpagehints.2': 'Access sermons, prayer sessions, and live services anytime from anywhere.',
			'onboardingpagehints.3': 'Start your journey to a never-ending worship experience.',
			'youneedtologintoreply': 'You need to login to add a reply',
			'youneedtologintoreportpost': 'You need to login to report a post',
			'members': 'Members',
			'logintolikeapost': 'You need to login to like a member post',
			'logintopinapost': 'You need to login to pin a member post',
			'logintoreportapost': 'You need to login to report post',
			'bookmarkshint': 'Bookmark audio and video messages',
			'downloadershint': 'Download and watch offline messages',
			'playlistshint': 'Collection of audio and video messages',
		};
	}
}

extension on _StringsPt {
	Map<String, dynamic> _buildFlatMap() {
		return <String, dynamic>{
			'appname': 'MyChurch App',
			'churchmotto': 'Towards global envagelism',
			'initializingapp': 'Please wait while we setup a few things, it wont take long, we promise.',
			'errorinitapp': 'Unfortunately, we could not complete setup at the moment, please check your internet connection, then click to retry',
			'initappsucess': 'Congratulations, setup is now complete, you can now click to continue to app',
			'retry': 'Try Again',
			'continuetoapp': 'Continue to App',
			'home': 'Home',
			'media': 'Media',
			'publications': 'Publications',
			'connect': 'Connect',
			'recentsermons': 'Recent Sermons',
			'donate': 'Give Now',
			'donatehint': 'God loves a cheerful giver.',
			'bible': 'Bible',
			'hymns': 'Hymns',
			'devotionals': 'Devotionals',
			'stayconnected': 'More ways to connect',
			'radiostreams': 'Radio Streams',
			'radiohint': 'Listen to our daily Radio Streams.',
			'livestreams': 'Live Streams',
			'livestreamshint': 'Connect to watch our live broadcasts.',
			'videos': 'Video Messages',
			'video': 'Videos',
			'videoshint': 'Collection of video sermons.',
			'audios': 'Audio Messages',
			'audioshint': 'Collection of audio sermons',
			'photos': 'Photo Gallery',
			'photoshint': 'Browse through our church photo collections.',
			'bookmarks': 'Bookmarks',
			'playlists': 'Playlists',
			'downloads': 'Downloads',
			'books': 'Christian Books',
			'recentarticles': 'Recent Articles',
			'groups': 'Church Groups',
			'groupshint': 'Church Groups are the best place to connect and fellowship with other believers.',
			'Prayerrequests': 'Prayer Requests',
			'prayerhint': 'Send a prayer request or join us to pray for other members.',
			'testimonies': 'Testimonies',
			'testimonyhint': 'Collection of personal testimonies of Gods healing power and deliverance.',
			'churchlocation': 'Church Locations',
			'churchlocationhint': 'Find a location near you and make plans to join us this Sunday!',
			'facebookpage': 'Facebook Page',
			'facebookpagehint': 'Connect with us on our Facebook community.',
			'youtubepage': 'Youtube Page',
			'youtubepagehint': 'Subscribe to our Youtube channel.',
			'twitterpage': 'Twitter Page',
			'twitterpagehint': 'Join the conversation on the Twitter platform.',
			'instagrampage': 'Instagram Page',
			'instagrampagehint': 'Follow us on Instagram to see the latest stories.',
			'gosocial': 'Go Social',
			'gosocialehint': 'Share your thought &\n chat with other members.',
			'website': ' Our Website',
			'terms': 'Terms & Conditions',
			'privacy': 'Privacy Policy',
			'about': 'About Us',
			'rateapp': 'Rate App',
			'account': 'Account',
			'appsettings': 'App Settings',
			'guestuser': 'Guest User',
			'createanaccounthint': 'Create an account or login to app',
			'viewmyprofile': 'View my profile',
			'logoutfromapp': 'Logout from App',
			'deletemyaccount': 'Delete my account',
			'applanguage': 'App Language',
			'recieveinbox': 'Receive inbox notifications',
			'recieveevents': 'Events',
			'sermonnotification': 'Sermons',
			'articlenotification': 'Articles',
			'devotionalnotification': 'Devotionals',
			'chooseapplanguage': 'Select App Language',
			'emailaddress': 'Email Address',
			'password': 'Password',
			'confirmpassword': 'Confirm Password',
			'passwordsdontmatch': 'Passwords dont match!',
			'login': 'LOG IN',
			'createaccount': 'Create Account',
			'forgotpassword': 'Forgot Password?',
			'resetpassword': 'Reset Password',
			'resetpasswordhint': 'A reset password link will be sent to your email.',
			'resetpasswordsuccess': 'If the email exists in our platform, you should recieve an instruction on how to reset your password.',
			'goback': 'Go Back',
			'ok': 'OK',
			'cancel': 'CANCEL',
			'resendverifycode': 'Resend Verification Link',
			'successregistermessage': 'You have successfully created an account, please check your email for a verification link and verify your email address.',
			'successresendverifymessage': 'A verification link have been sent to your email.',
			'resendverifylink': 'A verification link was sent to your email address, visit the link to verify your email. Did not get the email? click the link below to resend verification link.',
			'processingpleasewait': 'Processing, please wait...',
			'cannotprocess': 'The requested operation cannot be processed at the moment, please try again later.',
			'oops': 'Ooops!',
			'save': 'Save',
			'error': 'Error',
			'success': 'Success',
			'skip': 'Skip',
			'downloadbible': 'Download Bible',
			'downloadversion': 'Download',
			'downloading': 'Downloading',
			'failedtodownload': 'Failed to download',
			'pleaseclicktoretry': 'Please click to retry.',
			'of': 'Of',
			'nobibleversionshint': 'There is no bible data to display, click on the button below to download atleast one bible version.',
			'downloaded': 'Downloaded',
			'enteremailaddresstoresetpassword': 'Enter your email to reset your password',
			'backtologin': 'BACK TO LOGIN',
			'signintocontinue': 'Sign in to continue',
			'signin': 'S I G N  I N',
			'signinforanaccount': 'SIGN UP FOR AN ACCOUNT?',
			'alreadyhaveanaccount': 'Already have an account?',
			'updateprofile': 'Update Profile',
			'updateprofilehint': 'To get started, please update your profile page, this will help us in connecting you with other people',
			'searchbible': 'Search Bible',
			'filtersearchoptions': 'Filter Search Options',
			'narrowdownsearch': 'Use the filter button below to narrow down search for a more precise result.',
			'searchbibleversion': 'Search Bible Version',
			'searchbiblebook': 'Search Bible Book',
			'search': 'Search',
			'setBibleBook': 'Set Bible Book',
			'oldtestament': 'Old Testament',
			'newtestament': 'New Testament',
			'limitresults': 'Limit Results',
			'setfilters': 'Set Filters',
			'bibletranslator': 'Bible Translator',
			'chapter': ' Chapter ',
			'verse': ' Verse ',
			'translate': 'translate',
			'bibledownloadinfo': 'Bible Download started, Please do not close this page until the download is done.',
			'received': 'received',
			'outoftotal': 'out of total',
			'set': 'SET',
			'selectColor': 'Select Color',
			'switchbibleversion': 'Switch Bible Version',
			'switchbiblebook': 'Switch Bible Book',
			'gotosearch': 'Go to Chapter',
			'changefontsize': 'Change Font Size',
			'font': 'Font',
			'readchapter': 'Read Chapter',
			'showhighlightedverse': 'Show Highlighted Verses',
			'downloadmoreversions': 'Download more versions',
			'suggestedusers': 'Suggested users to follow',
			'unfollow': 'UnFollow',
			'follow': 'Follow',
			'searchforpeople': 'Search for people',
			'viewpost': 'View Post',
			'viewprofile': 'View Profile',
			'mypins': 'My Pins',
			'viewpinnedposts': 'View Pinned Posts',
			'personal': 'Personal',
			'update': 'Update',
			'phonenumber': 'Phone Number',
			'showmyphonenumber': 'Show my phone number to users',
			'dateofbirth': 'Date of Birth',
			'showmyfulldateofbirth': 'Show my full date of birth to people viewing my status',
			'notifications': 'Notifications',
			'notifywhenuserfollowsme': 'Notify me when a user follows me',
			'notifymewhenusercommentsonmypost': 'Notify me when users comment on my post',
			'notifymewhenuserlikesmypost': 'Notify me when users like my post',
			'churchsocial': 'Church Social',
			'shareyourthoughts': 'Share your thoughts',
			'readmore': '...Read more',
			'less': ' Less',
			'couldnotprocess': 'Could not process requested action.',
			'pleaseselectprofilephoto': 'Please select a profile photo to upload',
			'pleaseselectprofilecover': 'Please select a cover photo to upload',
			'updateprofileerrorhint': 'You need to fill your name, date of birth, gender, phone before you can proceed.',
			'fullname': 'Full Name',
			'firstname': 'First Name',
			'lastname': 'Last Name',
			'occupation': 'Occupation',
			'gender': 'Gender',
			'male': 'Male',
			'female': 'Female',
			'dob': 'Date Of Birth',
			'address': 'Current Address',
			'aboutme': 'About Me',
			'facebookprofilelink': 'Facebook Profile Link',
			'twitterprofilelink': 'Twitter Profile Link',
			'linkdln': 'Linkedln Profile Link',
			'likes': 'Likes',
			'likess': 'Like(s)',
			'pinnedposts': 'My Pinned Posts',
			'unpinpost': 'Unpin Post',
			'unpinposthint': 'Do you wish to remove this post from your pinned posts?',
			'postdetails': 'Post Details',
			'posts': 'Posts',
			'followers': 'Followers',
			'followings': 'Followings',
			'my': 'My',
			'edit': 'Edit',
			'delete': 'Delete',
			'deletepost': 'Delete Post',
			'deleteposthint': 'Do you wish to delete this post? Posts can still appear on some users feeds.',
			'maximumallowedsizehint': 'Maximum allowed file upload reached',
			'maximumuploadsizehint': 'The selected file exceeds the allowed upload file size limit.',
			'makeposterror': 'Unable to make post at the moment, please click to retry.',
			'makepost': 'Make Post',
			'selectfile': 'Select File',
			'images': 'Images',
			'shareYourThoughtsNow': 'Share your thoughts ...',
			'photoviewer': 'Photo Viewer',
			'nochatsavailable': 'No Conversations available \n Click the add icon below \nto select users to chat with',
			'typing': 'Typing...',
			'photo': 'Photo',
			'online': 'Online',
			'offline': 'Offline',
			'lastseen': 'Last Seen',
			'deleteselectedhint': 'This action will delete the selected messages.  Please note that this only deletes your side of the conversation, \n the messages will still show on your partners device.',
			'deleteselected': 'Delete selected',
			'unabletofetchconversation': 'Unable to Fetch \nyour conversation with \n',
			'loadmoreconversation': 'Load more conversations',
			'sendyourfirstmessage': 'Send your first message to \n',
			'unblock': 'Unblock ',
			'block': 'Block',
			'writeyourmessage': 'Write your message...',
			'clearconversation': 'Clear Conversation',
			'clearconversationhintone': 'This action will clear all your conversation with ',
			'clearconversationhinttwo': '.\n  Please note that this only deletes your side of the conversation, the messages will still show on your partners chat.',
			'logoutfromapphint': 'You wont be able to access some priviledges if you are not logged in.',
			'deleteaccount': 'Delete my account',
			'deleteaccounthint': 'This action will delete your account and remove all your data, once your data is deleted, it cannot be recovered.',
			'deleteaccountsuccess': 'Account deletion was succesful',
			'myprofile': 'My Profile',
			'noitemstodisplay': 'No Items To Display',
			'copiedtoclipboard': 'Copied to clipboard',
			'biblebooks': 'Bible',
			'searchhint': 'Search Audio & Video Messages',
			'performingsearch': 'Searching Audios and Videos',
			'nosearchresult': 'No results Found',
			'nosearchresulthint': 'Try input more general keyword',
			'dataloaderror': 'Could not load requested data at the moment, check your data connection and click to retry.',
			'download': 'Download',
			'addplaylist': 'Add to playlist',
			'bookmark': 'Bookmark',
			'unbookmark': 'UnBookmark',
			'share': 'Share',
			'deletemedia': 'Delete File',
			'deletemediahint': 'Do you wish to delete this downloaded file? This action cannot be undone.',
			'comments': 'Comments',
			'replies': 'Replies',
			'reply': 'Reply',
			'logintoaddcomment': 'Login to add a comment',
			'logintoreply': 'Login to reply',
			'writeamessage': 'Write a message...',
			'nocomments': 'No Comments found \nclick to retry',
			'errormakingcomments': 'Cannot process commenting at the moment..',
			'errordeletingcomments': 'Cannot delete this comment at the moment..',
			'erroreditingcomments': 'Cannot edit this comment at the moment..',
			'errorloadingmorecomments': 'Cannot load more comments at the moment..',
			'deletingcomment': 'Deleting comment',
			'editingcomment': 'Editing comment',
			'deletecommentalert': 'Delete Comment',
			'editcommentalert': 'Edit Comment',
			'deletecommentalerttext': 'Do you wish to delete this comment? This action cannot be undone',
			'loadmore': 'load more',
			'errorReportingComment': 'Error Reporting Comment',
			'reportingComment': 'Reporting Comment',
			'reportcomment': 'Report Options',
			'reportCommentsList.0': 'Unwanted commercial content or spam',
			'reportCommentsList.1': 'Pornography or sexual explicit material',
			'reportCommentsList.2': 'Hate speech or graphic violence',
			'reportCommentsList.3': 'Harassment or bullying',
			'addtoplaylist': 'Add to playlist',
			'newplaylist': 'New playlist',
			'playlistitm': 'Playlist',
			'mediaaddedtoplaylist': 'Media added to playlist.',
			'mediaremovedfromplaylist': 'Media removed from playlist',
			'clearplaylistmedias': 'Clear All Media',
			'deletePlayList': 'Delete Playlist',
			'clearplaylistmediashint': 'Go ahead and remove all media from this playlist?',
			'deletePlayListhint': 'Go ahead and delete this playlist and clear all media?',
			'pulluploadmore': 'pull up load',
			'loadfailedretry': 'Load Failed!Click retry!',
			'releaseloadmore': 'release to load more',
			'nomoredata': 'No more Data',
			'events': 'Events',
			'myplaylists': 'My Playlists',
			'articles': 'Articles',
			'notes': 'Notes',
			'savenotetitle': 'Note Title',
			'nonotesfound': 'No notes found',
			'newnote': 'New',
			'deletenote': 'Delete Note',
			'deletenotehint': 'Do you want to delete this note? This action cannot be reversed.',
			'allitems': 'All Items',
			'emptyplaylist': 'No Playlists',
			'notsupported': 'Not Supported',
			'cleanupresources': 'Cleaning up resources',
			'grantstoragepermission': 'Please grant accessing storage permission to continue',
			'sharefiletitle': 'Watch or Listen to ',
			'sharefilebody': 'Via MyChurch App, Download now at ',
			'sharetext': 'Enjoy unlimited Audio & Video streaming',
			'sharetexthint': 'Join the Video and Audio streaming platform that lets you watch and listen to millions of files from around the world. Download now at',
			'branches': 'Branches',
			'inbox': 'Inbox',
			'viewinmap': 'View Location in Map',
			'member': 'Member(s)',
			'join': 'Join Group',
			'by': 'BY',
			'prayertitle': 'Prayer Title',
			'prayercontent': 'Prayer Content',
			'testimonytitle': 'Testimony Title',
			'testimonycontent': 'Testimony Content',
			'successprayerposting': 'You have successfully added a prayer request, it will be published once it is approved.',
			'successtestimonyposting': 'You have successfully added a new testimony, it will be published once it is approved.',
			'addtestimony': 'Add Testimony',
			'groupsibelongto': 'Groups i belong to',
			'groupevents': 'Group Events/Activities',
			'successjoinedgroup': 'You have successfully requested to join this group, You will be notified by email once this request is granted.',
			'createnote': 'Create Note',
			'tapaddcontent': 'Tap to add content',
			'done': 'Done',
			'youversionbible': 'Use Youversion Bible Reader',
			'readbiblein': 'Read Bible in',
			'nodevotionals': 'No devotionals for selected month',
			'noevents': 'No events for selected month',
			'devotionalshint': 'Daily readings for devoted living.',
			'recentmessages': 'Recent Messages',
			'eventshint': 'Events & announcements',
			'digdeepbible': 'Dig deep into the word of God.',
			'upcomingevents': 'Our Upcoming Events',
			'searchmessagesbooks': 'Search for audio & video messages',
			'exploredeep': 'Explore Deeper',
			'missionstatement': 'Great to have you here, at Mychurch App, we strive for mastery at Gods word and preaching the gospel. ',
			'next': 'Next',
			'onboardingpagetitles.0': 'Welcome to MFM Lekki TMPM 1 App',
			'onboardingpagetitles.1': 'Benefits of the App',
			'onboardingpagetitles.2': 'Audio, Video \n and Live Streaming',
			'onboardingpagetitles.3': 'Create Account',
			'onboardingpagehints.0': 'A vibrant worship centre committed to prayer, deliverance, holiness, and raising champions for Christ.',
			'onboardingpagehints.1': 'Stay connected with church updates, programmes, and spiritual resources designed to strengthen your walk with God.',
			'onboardingpagehints.2': 'Access sermons, prayer sessions, and live services anytime from anywhere.',
			'onboardingpagehints.3': 'Start your journey to a never-ending worship experience.',
			'youneedtologintoreply': 'You need to login to add a reply',
			'youneedtologintoreportpost': 'You need to login to report a post',
			'members': 'Members',
			'logintolikeapost': 'You need to login to like a member post',
			'logintopinapost': 'You need to login to pin a member post',
			'logintoreportapost': 'You need to login to report post',
			'bookmarkshint': 'Bookmark audio and video messages',
			'downloadershint': 'Download and watch offline messages',
			'playlistshint': 'Collection of audio and video messages',
		};
	}
}


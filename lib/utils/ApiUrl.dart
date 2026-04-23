import 'package:higherground/utils/StringsUtils.dart';

class ApiUrl {
  // Development backend - XAMPP on local machine (physical device)
  // Machine IP: 192.168.100.12
 // static const String BASEURL = "http://192.168.100.12/churchapp/";
  
  // Production backend
   static const String BASEURL = "https://app.mfmlekkiphaseone.org/";
  
  // Emulator-only backend
  // static const String BASEURL = "http://10.0.2.2/churchapp/";
  
  static const String TERMS = BASEURL + "terms?_p=" + StringsUtils.API_TOKEN;
  static const String PRIVACY =
      BASEURL + "privacy?_p=" + StringsUtils.API_TOKEN;
  static const String ABOUT = "https://mfmlekkiphaseone.org/mfm-church/";
  static const String DONATE = BASEURL + "donate/" + StringsUtils.API_TOKEN;
  static const String YOUVERSIONBIBLE_ENG =
      "https://www.bible.com/bible/111/GEN.1.NIV";

  static const String YOUVERSIONBIBLE_FR =
      "https://www.bible.com/bible/64/GEN.1.FRDBY";
  static const String YOUVERSIONBIBLE_SP =
      "https://www.bible.com/bible/52/GEN.1.DHH94I";
  static const String YOUVERSIONBIBLE_PO =
      "https://www.bible.com/bible/215/GEN.1.ARC";

  //DO NOT EDIT THE LINES BELOW, ELSE THE APPLICATION WILL MISBEHAVE
  static const String INIT_APP = BASEURL + "initapp";
  static const String UNSEEN_MESSAGES = BASEURL + "getunseenmessages";
  static const String storeFcmToken = BASEURL + "storefcmtoken";

  static const String LOGIN_APP = BASEURL + "loginapp";
  static const String CREATE_ACCOUNT = BASEURL + "createaccount";
  static const String RESET_PASSWORD = BASEURL + "resetpassword";
  static const String RESEND_VERIFY_LINK = BASEURL + "resendVerificationMail";
  static const String updateUserProfile = BASEURL + "updateUserProfile";
  static const String DELETE_ACCOUNT = BASEURL + "deletemyaccount";
  static const String FETCH_MEDIA = BASEURL + "fetchmedia";
  static const String FETCH_PHOTOS = BASEURL + "fetchphotos";
  static const String FETCH_RADIO = BASEURL + "fetchradios";
  static const String FETCH_LIVESTREAMS = BASEURL + "fetchlivestreams";
  static const String FETCH_BOOKS = BASEURL + "fetchbooks";
  static const String FETCH_ARTICLES = BASEURL + "fetcharticles";
  static const String FETCH_BRANCHES = BASEURL + "fetchbranches";
  static const String FETCH_GROUPS = BASEURL + "fetchgroups";
  static const String FETCH_PRAYERS = BASEURL + "fetchprayers";
  static const String FETCH_TESTIMONIES = BASEURL + "fetchtestimonies";
  static const String update_media_total_views =
      BASEURL + "update_media_total_views";
  static const String SUBMIT_TESTIMONY = BASEURL + "submittestimony";
  static const String SUBMIT_PRAYER = BASEURL + "submitprayer";
  static const String FETCH_MY_GROUPS = BASEURL + "fetchmygroups";
  static const String JOIN_GROUP = BASEURL + "joingroup";
  static const String FETCH_GROUP_EVENTS = BASEURL + "fetchgroupevents";

  static const String EVENTS = BASEURL + "fetch_events";
  static const String DEVOTIONALS = BASEURL + "fetch_devotionals";
  static const String INBOX = BASEURL + "fetch_inbox";
  static const String HYMNS = BASEURL + "fetch_hymns";
  static const String SEARCH = BASEURL + "search";
  static const String GET_BIBLE = BASEURL + "getBibleVersions";

  static const String getUsersToFollow = BASEURL + "get_users_to_follow";
  static const String followUnfollowUser = BASEURL + "follow_unfollow_user";
  static const String userNotifications = BASEURL + "userNotifications";
  static const String fetchUserSettings = BASEURL + "fetch_user_settings";
  static const String updateUserSettings = BASEURL + "update_user_settings";
  static const String fetchUserPosts = BASEURL + "fetch_posts";
  static const String likeunlikepost = BASEURL + "likeunlikepost";
  static const String pinunpinpost = BASEURL + "pinunpinpost";
  static const String postLikesPeople = BASEURL + "post_likes_people";
  static const String fetchUserPins = BASEURL + "fetchUserPins";
  static const String loadpostcomments = BASEURL + "loadpostcomments";
  static const String makepostcomment = BASEURL + "makepostcomment";
  static const String editpostcomment = BASEURL + "editpostcomment";
  static const String deletepostcomment = BASEURL + "deletepostcomment";
  static const String reportpostcomment = BASEURL + "reportpostcomment";
  static const String loadpostreplies = BASEURL + "loadpostreplies";
  static const String replypostcomment = BASEURL + "replypostcomment";
  static const String editpostreply = BASEURL + "editpostreply";
  static const String deletepostreply = BASEURL + "deletepostreply";
  static const String userBioInfo = BASEURL + "userBioInfo";
  static const String fetchUserdataPosts = BASEURL + "fetchUserPostsflutter";
  static const String usersFollowPeopleList = BASEURL + "users_follow_people";
  static const String makePost = BASEURL + "make_post";
  static const String editPost = BASEURL + "editpost";
  static const String deletePost = BASEURL + "deletepost";
  static const String updateUserSocialFcmToken =
      BASEURL + "updateUserSocialFcmToken";

  static const String FETCH_USER_CHATS = BASEURL + "fetch_user_chats";
  static const String FETCH_PARTNER_CHATS = BASEURL + "fetch_user_partner_chat";
  static const String SAVE_CHAT_CONVERSATION =
      BASEURL + "save_user_conversation";
  static const String ONSEEN_USER_CONVERSATION =
      BASEURL + "on_seen_conversation";
  static const String ON_USER_TYPING = BASEURL + "on_user_typing";
  static const String UPDATE_ONLINE_PRESENCE =
      BASEURL + "update_user_online_status";
  static const String DELETE_SELECTED_CHATS =
      BASEURL + "delete_selected_chat_messages";
  static const String CLEAR_USER_CONVERSATION =
      BASEURL + "clear_user_conversation";
  static const String BLOCK_UNBLOCK_USER = BASEURL + "blockUnblockUser";
  static const String LOAD_MORE_CHATS = BASEURL + "load_more_chats";
  static const String CHECK_FOR_NEW_MESSAGES = BASEURL + "checkfornewmessages";
  static const String getitemdata = BASEURL + "getitemdata";
}



